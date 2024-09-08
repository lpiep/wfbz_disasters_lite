# Documentation

## Inputs: 
- Fire perimeters for (1) continental US, (2) Hawaii, (3) Alaska
- Global Human Settlement Layer population estimates for 2000, 2005, 2010, 2015, 2020 (100m resolution, Molweide projection). Links in get_data.sh

## Analytic overview:

This script takes in a dataset of fire perimeters and a gridded population dataset. 

The parameters are: 
- Area threshold (area_thresh): this is the threshold by which we determine if a fire is large or small. Fires greater than or equal to 1000 acres are considered large. Based on size, fires get different buffers (one buffer for small fires and one for large). This is parameterized in square-meters.
- Large fire buffer (large_fire_buffer) = This is the buffer around the fire perimeter for large (>= 1000 acres) fires, in meters.
- Small fire buffer (small_fire_buffer) = This is the buffer around the fire perimeter for small (< 1000 acres) fires, in meters.
- Population averaging radius (pop_average_radius): This is the radius for a circle with the area that we are using in our denominator of population density. In other words, if our criteria is per 1 square-kilometer, this is the radius of a circle that has an area of 1 square-kilometer (or 1000 square-meters). This is parameterized in meters.
- Population density criteria (pop_density_criteria): This is the number of people per square-meter that are required to make an area a community.

The process is: 
1. It first buffers each fire, with a different buffer size based on whether the fire is big or small. A big fire is defined as a fire that is bigger than 1000 acres (converted to 4046856 meters). Big fires get buffered by 20km and small fires get buffered by 10km. 

2. Following the buffering of the fire, we create a bounding box around the fire that adds the radius of a `pop_average_radius` circle to each side of the fire. This is to ensure we pull enough of the population raster to do our density calculation correctly.

3. Once we have all of this information, we load a subset of our population raster using the bounding box that we created in step 2 to determine the subset loaded.

4. Using the population data, we build a kernel for the convolution - this is an average kernel.

5. We use our kernel to do a convolution -- for every pixel, we sum all the people within our radius of that pixel (currently 300m). The result of this is a raster of population density averaged to people per square kilometer.

6. Now, we can use our buffered fire perimeter to find the maximum value of population density for any individual pixel within the buffered perimeter. If any of them exceed our population density criteria (`pop_density_criteria`), then we determine that the fire overlaps with a community that exceeds our population density threshold and thus meets our population density criteria for the fire overlapping with a community. 


## Outputs: 
**Primary output**
- CSV with disaster_id and density_criteria_met variable
  
**Secondary outputs**
- Parquet file with metadata (disaster_id, density_criteria_met, state, year, buffer_distance, geometry, crs for that fire's utm)
- Diagnostic plots

## Next steps:
**To discuss with Milo**
- File of fires with no acreage (all_disaster_with_ics_poo_no_acreage_cont_us_select_vars) - have point location but not fire size.
- There are fires from puerto rico
