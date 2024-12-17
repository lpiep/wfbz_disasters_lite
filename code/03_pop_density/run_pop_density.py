from pathlib import Path
from scipy.signal import oaconvolve
import tqdm
import pandas as pd
import geopandas as gpd
import numpy as np
import rasterra as rt
import argparse
from shapely.validation import make_valid


import warnings
import time 
start_time = time.time()

#-----------------
# helper functions
def make_convolution_kernel(
    pixel_resolution_m: int | float,
    radius_m: int | float,
) :
    radius = int(radius_m // pixel_resolution_m)
    y, x = np.ogrid[-radius : radius + 1, -radius : radius + 1]

    kernel = (x**2 + y**2 < radius**2).astype(float)
    kernel = kernel / kernel.sum()
    return kernel


def make_spatial_average(
    tile: rt.RasterArray,
    radius: int | float,
) :
    arr = np.nan_to_num(tile.to_numpy())

    kernel = make_convolution_kernel(tile.x_resolution, radius) # tile.x_resolution is pulling the pop raster res, which is 100m in the ghsl data

    out_image = oaconvolve(arr, kernel, mode="same")

    out_raster = rt.RasterArray(
        out_image,
        transform=tile.transform,
        crs=tile.crs,
        no_data_value=tile.no_data_value,
    )
    return out_raster


def main(
    data_dir: Path,
    area_thresh: int,  # sq meters
    large_fire_buffer: int,  # meters
    small_fire_buffer: int,  # meters
    pop_average_radius: int,  # area for circle
    pop_density_criteria: int  # people per sq km, which is 250 people per sq mile
):

    mol_crs = "ESRI: 54009"

    #-----------------
    # read in data
    # fires
    fires_hi = gpd.read_parquet(data_dir / "01_raw/all_disaster_perimeters_ics_and_news_buffers_hawaii_select_variables.parquet")
    fires_ak = gpd.read_parquet(data_dir / "01_raw/all_disaster_perimeters_ics_and_news_buffers_alaska_select_variables.parquet")
    fires_conus = gpd.read_parquet(data_dir / "01_raw/all_disaster_perimeters_ics_and_news_buffers_conus_select_variables.parquet")

    # utm map
    utm_map = pd.read_csv(data_dir / "utm_popden.csv")
    utm_map['state_list'] = utm_map['states'].apply(lambda s: s.split(','))
    utm_map = utm_map.explode('state_list').set_index('state_list')['crs'].to_dict()
    utm_map = {s.strip(): f"EPSG:{crs}" for s, crs in utm_map.items()}
    utm_map["PR"] = "EPSG:3920"

    warnings.simplefilter("error", category=RuntimeWarning)

    #-----------------
    # run loop
    fire_dfs = []
    failed_ids = []
    for df in [fires_conus, fires_ak, fires_hi]: 
        keep_cols = ['disaster_id', 'year', 'states_aggregated_list', 'shape']
        row_tuples = list(df[keep_cols].itertuples(index=False, name=None))
        # row_tuples = row_tuples[-89:]
        for disaster_id, old_year, state_list, fire_poly in tqdm.tqdm(row_tuples):
            year = round(old_year / 5)*5
            state = state_list[:2]
            if fire_poly.is_empty:
                failed_ids.append(
                    (disaster_id, "empty_geometry")
                )
                continue
            # if fire_poly.geom_type != "Polygon" and fire_poly.geom_type != "MultiPolygon":
            #     print(
            #         f"Invalid geometry type for disaster_id {disaster_id}: "
            #         f"Expected Polygon or MultiPolygon, got {fire_poly.geom_type}"
            #     )
            #     failed_ids.append((disaster_id, f"invalid_geometry_type_{fire_poly.geom_type}"))
            #     continue
            fire_crs = utm_map[state]
            fire_series = gpd.GeoSeries([fire_poly], crs=df.crs).to_crs(fire_crs)
            if not fire_series.is_valid.iloc[0]:
                print(disaster_id, 'is invalid')
                failed_ids.append(
                    (disaster_id, "invalid_geometry")
                )
                fire_series.iloc[0] = make_valid(fire_series.iloc[0])

            buffer_dist = large_fire_buffer if fire_series.area.iloc[0] > area_thresh else small_fire_buffer 
            buffered_fire_series = fire_series.buffer(buffer_dist) # buffer dist in meters
            
            bounding_box = buffered_fire_series.envelope.buffer(pop_average_radius*1.1).to_crs(mol_crs).iloc[0]

            if bounding_box.area/1000**2 > 100_000: # 100k sq kilometers
                failed_ids.append(
                    (disaster_id, "bounding_box_too_large")
                )
                continue

            # II. load pop data 
            try:
                pop = rt.load_raster(data_dir / f"01_raw/pop_data/GHS_POP_E{year}_GLOBE_R2023A_54009_100_V1_0.tif", bounding_box).to_crs(fire_crs)
            except:
                import pdb; pdb.set_trace()
            pop_density_per_sq_km = pop * (1000**2 / pop.x_resolution**2)

            # III. build kernel and do convolution with kernel - for every pixel, sum all the people within a kilometer of that pixel,
            # so kernel should be all 1's and should be 10 pixels wide and 10 pixels tall
            # that convolution gives back a raster of pop density averaged to people per sq km
            mean_pop_density = make_spatial_average(pop_density_per_sq_km, pop_average_radius)

            # IV. determine if this fire meets density criteria by: 
            # i. take buffered fire poly and mask everything outside of that (set everything outside buffered poly to 0 which you can do w/ raster.mask)
            # ii. find max pixel val and if it exceeds your threshold then it overlaps with a communtiy that exceeds the threshold and is marked as TRUE in final csv. 
            max_pop_density = np.max(mean_pop_density.mask(buffered_fire_series).to_numpy())
            density_criteria_met = max_pop_density > pop_density_criteria

            # V. add to results df 
            df_fire = pd.DataFrame({
                'disaster_id': [str(disaster_id)],
                'density_criteria_met': [density_criteria_met],
                'max_pop_density': [max_pop_density],
                'state': [state],
                'year': [year],
                'buffer_distance': [buffer_dist],
                'geometry': [fire_series.iloc[0]],
                'crs': [fire_crs],
            })
            fire_dfs.append(df_fire)
    # print("\n".join(failed_ids))

    #-----------------
    # write out data
    df = pd.concat(fire_dfs, ignore_index = True)
    df['geometry'] = df['geometry'].apply(lambda geom: geom.wkt)
    df['area_thresh'] = area_thresh
    df['large_fire_buffer'] = large_fire_buffer
    df['small_fire_buffer'] = small_fire_buffer
    df['pop_average_radius'] = pop_average_radius
    df['pop_density_criteria'] = pop_density_criteria
    df['disaster_id'] = df['disaster_id'].astype(str)

    # write out data for plotting
    df.to_parquet(data_dir / "02_processed/fire_pop_density_criteria.parquet")
    # write out little csv 
    df[["disaster_id", "density_criteria_met"]].to_csv(data_dir / "02_processed/fire_pop_density_criteria.csv")
    # write out full dataset 
    fires_conus = fires_conus.merge(df[["disaster_id", "density_criteria_met"]], on='disaster_id', how='left')
    fires_ak = fires_ak.merge(df[["disaster_id", "density_criteria_met"]], on='disaster_id', how='left')
    fires_hi = fires_hi.merge(df[["disaster_id", "density_criteria_met"]], on='disaster_id', how='left')
    fires_conus.to_parquet(data_dir / "02_processed/fires_conus_pop_density.parquet", index=False)
    fires_conus.to_file(data_dir / "02_processed/fires_conus_pop_density.geojson", driver="GeoJSON")
    fires_ak.to_parquet(data_dir / "02_processed/fires_alaska_pop_density.parquet", index=False)
    fires_ak.to_file(data_dir / "02_processed/fires_alaska_pop_density.geojson", driver="GeoJSON")
    fires_hi.to_parquet(data_dir / "02_processed/fires_hawaii_pop_density.parquet", index=False)
    fires_hi.to_file(data_dir / "02_processed/fires_hawaii_pop_density.geojson", driver="GeoJSON")



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Population density criteria evaluations.")

    parser.add_argument("-o", "--data-dir", type=str, required=True, help="Path to data directory within wildfire repository")
    parser.add_argument("--area-thresh", type=int, default=1000, help="Threshold (acres) by which we determine if a fire is large or small. Fires greater than or equal to the area threshold are considered large. Based on size, fires get different buffers (we use one buffer for small fires and one for large).")
    parser.add_argument("--large-fire-buffer", type=int, default=20000, help="Large fire buffer in meters. This puts a buffer of this size around the perimeter of the wildfire in order to account for people being affected beyond the fire perimeter polygon.")
    parser.add_argument("--small-fire-buffer", type=int, default=10000, help="Small fire buffer in meters. This puts a buffer of this size around the perimeter of the wildfire in order to account for people being affected beyond the fire perimeter polygon.")
    parser.add_argument("--pop-average-area", type=int, default=300, help="This is the radius for a circle with the area that we are using in our denominator of population density. In other words, if our criteria is per 1 square-kilometer, this is the radius of a circle that has an area of 1 square-kilometer (or 1000 square-meters). This is parameterized in meters.")
    parser.add_argument("--pop-density-criteria", type=int, default=96, help="This is the average number of people per square-meter over the population average area that are required to make an area a community.")

    args = parser.parse_args()
    data_dir=Path(args.data_dir).expanduser().resolve()
    pop_average_radius = args.pop_average_area/np.sqrt(np.pi)
    area_thresh = args.area_thresh*4046.856

    main(
        data_dir=data_dir,
        area_thresh=area_thresh,
        large_fire_buffer=args.large_fire_buffer,
        small_fire_buffer=args.small_fire_buffer,
        pop_average_radius=pop_average_radius,
        pop_density_criteria=args.pop_density_criteria,
    )

end_time = time.time()
runtime = end_time - start_time

print(f"Script runtime: {runtime:.2f} seconds")

# python code/03_pop_density/run_pop_density.py -o data