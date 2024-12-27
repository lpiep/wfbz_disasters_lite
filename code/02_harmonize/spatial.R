# # --------------------------------
# # Description: Harmonize Spatial Data
# 
# # Logan Piepmeier
# # --------------------------------

# Create a lookup using spatial join to Census county file, standardized date, bounding box to be used in fuzzy matching
spacetime_index <- function(dat_sf, native_id, ig_date){
	
	stopifnot(native_id %in% names(dat_sf))
	stopifnot(!any(duplicated(dat_sf[[native_id]])))
	stopifnot(ig_date %in% names(dat_sf))
	stopifnot('sf' %in% class(dat_sf))
	
	if(str_detect(as.character(ig_date), '^[0-9]{4}$')){ 
		dat_sf <- dat_sf %>% 
			mutate(
				ig_date = ymd(paste0(ig_date, '-01-01')),
				last_date = ymd(paste0(ig_date, '-12-31'))
			)
	}else{
		dat_sf <- dat_sf %>% 
			mutate(
				ig_date = ymd(ig_date),
				last_date = ymd(last_date)
			)
	}
	
	# Split by decade & join in appropriate census
	dat_sf <- dat_sf %>% 
		split(year(floor_date(dat_sf[[ig_date]], '10 years')))
	
	map(names(dat_sf), function(decade) st_join(dat_sf[[decade]], spatial_tiger_counties[[decade]], left = TRUE)) %>%
		bind_rows()

}
# 
# bind_rows(
# 	fired = spacetime_index(spatial_fired, native_id = 'fired_id', ig_date = 'fired_ig_date'),
# 	mtbs =  spacetime_index(spatial_mtbs),
# 	nifc =  spacetime_index(spatial_nifc),
# 	.id = 'src'
# )