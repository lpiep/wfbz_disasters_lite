# Description -------------------------------------------------------------

# Author: Benjamin Steiger
# Date: 06/13/2023
# Last Update: 06/18/2024 # Logan Piepmeier changed to function and to go through present
# Goal: Clean FIRED CONUS-AK Perimeter Dataset for Matching to Disaster Data, 2000-Present
#
# We initially used the daily data here, which I think is not a good way to do it since
# we don't care about how the fire perimeter changed over time, only its max extent.
# Previously we also calculated fire area, but the area column provided was almost exactly
# equivalent to our calculation. 
#-----------------------------------------

clean_fired <- function(spatial_fired_raw){
	
	fired <- st_read(fs::dir_ls(spatial_fired_raw, regexp = 'event.*gpkg$')) %>%
		st_set_geometry("geometry") %>% 
		st_transform(4269) %>% 
		st_make_valid() %>% 
		rename_at(vars(!matches('geometry')), ~ paste0("fired_", .)) %>% 
		mutate(across(matches('date'), ymd)) %>% 
		filter(fired_ig_year >= 2000) %>%
		transmute(
			fired_id, 
			wildfire_ignition_date = fired_ig_date,
			wildfire_containment_date = fired_last_date
		)
	
	fired
}
