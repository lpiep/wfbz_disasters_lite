#-------------------------
# Convert RData to Parquet
# Purpose: Convert fire perimeter
#   rdata files to parquet
#   files for use in python
# Author: Lauren Wilner
# Date: 2024-08-24


#-------------------------
# setup
library(arrow)
library(sfarrow)

#-------------------------
# path
path <- "~/Desktop/Desktop/epidemiology_PhD/00_repos/wildfire_disasters_lite/data/01_raw/"

#-------------------------
# convert rdata to parquet
load(paste0(path, "all_disasters_select_vars.rdata"))
names(which(unlist(eapply(.GlobalEnv,is.data.frame))))

st_write_parquet(all_disaster_perimeters_ics_and_news_buffers_conus_select_variables,
    paste0(path, "all_disaster_perimeters_ics_and_news_buffers_conus_select_variables.parquet"))
st_write_parquet(all_disaster_perimeters_ics_and_news_buffers_alaska_select_variables,
    paste0(path, "all_disaster_perimeters_ics_and_news_buffers_alaska_select_variables.parquet"))
st_write_parquet(all_disaster_perimeters_ics_and_news_buffers_hawaii_select_variables,
    paste0(path, "all_disaster_perimeters_ics_and_news_buffers_hawaii_select_variables.parquet"))
# st_write_parquet(disasters_no_ics_poo_no_news_poo_select_variables,
#     paste0(path,"disasters_no_ics_poo_no_news_poo_select_variables.parquet"))
# st_write_parquet(disasters_with_ics_or_newspaper_poo_sf_conus_select_variables,
#     paste0(path,"disasters_with_ics_or_newspaper_poo_sf_conus_select_variables.parquet"))