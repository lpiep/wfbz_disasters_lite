# # --------------------------------
# # Description: Harmonize Spatial Data
# 
# # Logan Piepmeier
# # --------------------------------
# 
# 
# library(sf)
# library(dplyr)
# library(purrr)
# 
# boundaries <- list(
# 	mtbs = st_read('data/raw/nonstatic/spatial/mbts/mtbs_perims_DD.shp'),
# 	nifc = st_read('data/raw/nonstatic/spatial/nifc/InterAgencyFirePerimeterHistory_All_Years_View.shp') %>% filter(FIRE_YEAR > 2000),
# 	fired_daily = st_read('data/raw/nonstatic/spatial/fired/fired_conus-ak_daily_nov2001-march2021.gpkg'),
# 	fired_event = st_read('data/raw/nonstatic/spatial/fired/fired_conus-ak_events_nov2001-march2021.gpkg')
# ) %>% 
# 	map(st_transform, 4326)
# 
# boundaries <- map(boundaries, st_make_valid)
# 
# ## MBTS
# 
# boundaries$mtbs <- boundaries$mtbs %>%
# 	rename_with(tolower, everything()) 
# 
# 
# ## NIFC
# 
# boundaries$nifc <- boundaries$nifc %>%
# 	rename_with(tolower, everything()) 
# 
