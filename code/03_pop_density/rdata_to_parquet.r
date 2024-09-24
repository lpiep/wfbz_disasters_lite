#-------------------------
# Convert RData to Parquet
# Purpose: Convert fire perimeter
#   rdata files to parquet
#   files for use in python
# Author: Lauren Wilner
# Date: 2024-08-24

if(FALSE){
#-------------------------
# setup
library(arrow)
library(sfarrow)

#-------------------------
# path
path <- "~/Desktop/Desktop/epidemiology_PhD//00_repos/wildfire-disaster/data/raw/"

#-------------------------
# convert rdata to parquet
load(paste0(path, "all_disasters_select_vars.rdata"))
st_write_parquet(all_disaster_perimeters_buffers_conus_dist_select_vars,
    paste0(path, "all_disaster_perimeters_buffers_hawaii_dist_select_vars.parquet"))
st_write_parquet(all_disaster_perimeters_buffers_alaska_dist_select_vars,
    paste0(path, "all_disaster_perimeters_buffers_hawaii_dist_select_vars.parquet"))
st_write_parquet(all_disaster_perimeters_buffers_hawaii_dist_select_vars,
    paste0(path, "all_disaster_perimeters_buffers_hawaii_dist_select_vars.parquet"))
st_write_parquet(all_disaster_with_ics_poo_no_acreage_cont_us_select_vars,
    paste0(path,"all_disaster_with_ics_poo_no_acreage_cont_us_select_vars.parquet"))

}