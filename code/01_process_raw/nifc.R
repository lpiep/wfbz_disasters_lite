
clean_nifc <- function(spatial_nifc_raw){

	# Interagency All Years Perimeters
	nifc_all_years <- st_read(spatial_nifc_raw) %>% 
		mutate(FIRE_YEAR=as.numeric(FIRE_YEAR)) %>%
		st_transform(crs = 4269) %>% 
		mutate(UNQE_FIRE_ = gsub("NA", NA, UNQE_FIRE_)) %>%
		mutate(
			wildfire_complex = str_detect(toupper(INCIDENT), "COMPLEX|CPLX|CX|CMP|CMPL|CMPLX|COMPL|COMPL|COMPLE|COMPLX|COMLX|CLX|CPX|-COM[.]"),
			INCIDENT = standardize_place_name(INCIDENT)
		) %>% 
		mutate( # pull state from IDs where it is present
			state_from_id = if_else(
				str_sub(UNQE_FIRE_, 6, 7) %in% c(state.abb, 'PR', 'GU', 'DC', 'VI'), 
				str_sub(UNQE_FIRE_, 6, 7), 
				NA_character_
			)
		) %>%
		st_make_valid() 
		

  nifc_all_years %>%
		transmute(
			wildfire_year = FIRE_YEAR,
			wildfire_state = state_from_id,
			irwin_id = IRWINID,
			nifc_id = OBJECTID,
			wildfire_name = INCIDENT,
			wildfire_complex,
			wildfire_area = st_area(geometry)/1000/1000 # area in km
		)
}
