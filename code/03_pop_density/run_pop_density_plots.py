from pathlib import Path
import pandas as pd
import geopandas as gpd
import numpy as np
import rasterra as rt
from shapely import wkt
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import tqdm
import PyPDF2
import argparse
from run_pop_density import make_convolution_kernel
from run_pop_density import make_spatial_average



#-----------------
# plotting function
# plots 
def plot_fires(
    df_plot
) : 
    cmap = "seismic"
    mol_crs = "ESRI: 54009"
    fire_poly = wkt.loads(df_plot["geometry"])
    crs = df_plot['crs']
    year = df_plot['year']
    area_thresh = df_plot['area_thresh']
    large_fire_buffer = df_plot['large_fire_buffer']
    small_fire_buffer = df_plot['small_fire_buffer']
    pop_average_radius = df_plot['pop_average_radius']
    pop_density_criteria = df_plot['pop_density_criteria']

    fire_series = gpd.GeoSeries([fire_poly], crs=crs)
    buffer_dist = large_fire_buffer if fire_series.area.iloc[0] > area_thresh else small_fire_buffer 
    buffered_fire_series = fire_series.buffer(buffer_dist)
    fire_poly_plus_buffer = gpd.GeoSeries([fire_poly, buffered_fire_series.iloc[0]], crs=crs)
    bounding_box = buffered_fire_series.envelope.buffer(pop_average_radius * 1.1).to_crs(mol_crs).iloc[0]
    pop = rt.load_raster(data_dir / f"01_raw/pop_data/GHS_POP_E{year}_GLOBE_R2023A_54009_100_V1_0.tif", bounding_box).to_crs(crs)
    pop_density_per_sq_km = pop * (1000**2 / pop.x_resolution**2)
    mean_pop_density = make_spatial_average(pop_density_per_sq_km, pop_average_radius)

    
    # gridspec layout 
    fig = plt.figure(figsize=(15, 7))
    gs = gridspec.GridSpec(1, 2, figure=fig)
    
    # fig 1: fire poly, buffered fire poly, pop
    ax1 = fig.add_subplot(gs[0])
    pop_density_per_sq_km_transformed = pop_density_per_sq_km/pop_density_criteria # proportion of the criteria met in each pixel in native data
    pop_density_per_sq_km_transformed.plot(ax=ax1, cmap = cmap, vmin = 1e-4, vmax = 2, under_color = "lightgrey")
    fire_poly_plus_buffer.boundary.plot(ax=ax1, linewidth=1.5, edgecolor = 'limegreen')
    ax1.set_title(f"Population per $km^2$", fontsize=16)
    ax1.set_axis_off()
    
    # fig 2: fire poly, buffered fire poly, pop density
    ax2 = fig.add_subplot(gs[1])
    pop_density_transformed = mean_pop_density/pop_density_criteria # ratio of mean pop density to criteria = what prop of the criteria is met? what prop of criteria is fulfilled at each pixel? 
    pop_density_transformed.plot(ax=ax2, cmap = cmap, vmin = 1e-4, vmax = 2, under_color = "lightgrey")
    fire_poly_plus_buffer.boundary.plot(ax=ax2, linewidth=1.5, edgecolor = 'limegreen')
    ax2.set_title(f"Population density", fontsize=16)
    ax2.set_axis_off()
     
    fig.suptitle(f"Fire polygon with buffer (buffer distance: {buffer_dist} meters) \nDisaster ID: {df_plot['disaster_id']}, State: {df_plot['state']}, Year: {df_plot['year']} \nCriteria met: {df_plot["density_criteria_met"]}", fontsize=20)
    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    pdf_filename = plot_dir / f"fire_pop_dens_{df_plot['disaster_id']}.pdf"
    plt.savefig(pdf_filename, format='pdf')
    plt.close(fig)

#-----------------
# run plots 
def main(
    data_dir: Path,
    plot_dir: Path
) :
    df_main = pd.read_parquet(data_dir / "02_processed/fire_pop_density_criteria.parquet")
    disaster_ids = df_main["disaster_id"]
    fires_included_prop = round(len(df_main[df_main["density_criteria_met"] == True])/len(df_main)*100, 2)

    #-----------------
    # histograms 
    fig = plt.figure(figsize=(15, 7))
    gs = gridspec.GridSpec(2, 2, width_ratios=[1, 1], height_ratios=[2, 1])

    df_fig = df_main[df_main["max_pop_density"]<100000]
    # fig 1: histogram of max_pop_density for all fires
    ax1 = fig.add_subplot(gs[:, 0])
    ax1.hist(df_fig['max_pop_density'], bins=150, color='firebrick', edgecolor='black')
    ax1.set_title('Histogram of maximum population density for all fires, subset to density < 100000')
    ax1.set_xlabel('Max population density')
    ax1.set_ylabel('Frequency')

    # fig 2: histogram of max_pop_density where density_criteria_met = True
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.hist(df_fig[df_fig['density_criteria_met'] == True]['max_pop_density'], bins=150, color='salmon', edgecolor='black')
    ax2.set_title('Max population density, subset to density < 100000 (criteria met)')
    ax2.set_xlabel('Max population density')
    ax2.set_ylabel('Frequency')

    # fig 3: histogram of max_pop_density where density_criteria_met = False
    ax3 = fig.add_subplot(gs[1, 1])
    ax3.hist(df_fig[df_fig['density_criteria_met'] == False]['max_pop_density'], bins=150, color='peachpuff', edgecolor='black')
    ax3.set_title('Max population density (criteria not met)')
    ax3.set_xlabel('Max population density')
    ax3.set_ylabel('Frequency')

    plt.tight_layout()

    fig.suptitle(f"Population density histograms (percent included = {fires_included_prop}%)", fontsize=20)
    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    pdf_filename = plot_dir / f"histograms.pdf"
    plt.savefig(pdf_filename, format='pdf')
    plt.close(fig)

    #-----------------
    # disaster plots 
    for disaster in tqdm.tqdm(disaster_ids): 
        df_plot = df_main[df_main["disaster_id"] == disaster].iloc[0]
        plot_fires(df_plot)

    pdf_dir = plot_dir
    pdf_files = sorted(pdf_dir.glob("fire_pop_dens_*.pdf"))
    histogram_pdf = pdf_dir / "histograms.pdf"
    output_pdf = pdf_dir / "compiled/combined_fire_plots.pdf"
    pdf_merger = PyPDF2.PdfMerger()

    #-----------------
    # compile plots by looping through each fire's pdf and histograms to create one file
    with open(histogram_pdf, 'rb') as f:
        pdf_merger.append(f)

    for pdf_file in pdf_files:
        with open(pdf_file, 'rb') as f:
            pdf_merger.append(f)
    with open(output_pdf, 'wb') as output_file:
        pdf_merger.write(output_file)
    pdf_merger.close()
    print(f"Combined PDF saved as {output_pdf}")



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Diagnostic plots for wildfire population density evaluations.")

    parser.add_argument("-i", "--data-dir", type=str, required=True, help="Path to data directory within wildfire repository")
    parser.add_argument("-o", "--plot-dir", type=str, required=True, help="Path to plot directory within wildfire repository")
    args = parser.parse_args()
    data_dir=Path(args.data_dir).expanduser().resolve()
    plot_dir=Path(args.plot_dir).expanduser().resolve()

    main(
        data_dir=data_dir,
        plot_dir=plot_dir
    )   

# python code/03_pop_density/run_pop_density_plots.py -i data -o ~/Desktop/Desktop/epidemiology_PhD/02_projects/wildfire-disaster/plots/
