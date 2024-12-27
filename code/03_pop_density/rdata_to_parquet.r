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
path <- "~/Desktop/Desktop/epidemiology_PhD/00_repos/wildfire_disasters_lite/data/01_raw/"

#-------------------------
# convert rdata to parquet
load(paste0(path, "joined_disaster_fires_2000_2019_select.rdata"))
names(which(unlist(eapply(.GlobalEnv,is.data.frame))))

st_write_parquet(joined_disaster_fires_2000_2019_conus_aggregated_select,
    paste0(path, "all_disaster_perimeters_ics_and_news_buffers_conus_select_variables.parquet"))
st_write_parquet(joined_disaster_fires_2000_2019_alaska_aggregated_select,
    paste0(path, "all_disaster_perimeters_ics_and_news_buffers_alaska_select_variables.parquet"))
st_write_parquet(joined_disaster_fires_2000_2019_hawaii_aggregated_select,
    paste0(path, "all_disaster_perimeters_ics_and_news_buffers_hawaii_select_variables.parquet"))

}
