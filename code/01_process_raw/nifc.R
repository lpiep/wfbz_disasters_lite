
clean_nifc <- function(spatial_nifc_raw){

	# Interagency All Years Perimeters
	nifc <- st_read(spatial_nifc_raw) %>% 
		mutate(FIRE_YEAR=as.numeric(FIRE_YEAR)) %>%
		st_transform(crs = 4269) %>% 
		mutate(UNQE_FIRE_ = gsub("NA", NA, UNQE_FIRE_)) %>%
		mutate(
			wildfire_complex = str_detect(toupper(INCIDENT), "COMPLEX|CPLX|CX|CMP|CMPL|CMPLX|COMPL|COMPL|COMPLE|COMPLX|COMLX|CLX|CPX|-COM[.]"),
			INCIDENT = standardize_place_name(INCIDENT),
			IRWINID = str_replace_all(IRWINID, '(^\\{|\\}$)', '') # remove {brackets} around ID
		) %>% 
		mutate( # pull state from IDs where it is present
			state_from_id = if_else(
				str_sub(UNQE_FIRE_, 6, 7) %in% c(state.abb, 'PR', 'GU', 'DC', 'VI'), 
				str_sub(UNQE_FIRE_, 6, 7), 
				NA_character_
			)
		) %>%
		st_make_valid() 

	# deal with near-duplicates (usually same fire with negligible differences)
	# This issue seems to be restricted to fires assigned an irwin id
	nifc <- bind_rows( 
		nifc %>% filter(is.na(IRWINID)), 
		nifc %>% filter(!is.na(IRWINID)) %>% 
			group_by(FIRE_YEAR, IRWINID) %>%
			summarize(
				OBJECTID =  paste(unique(OBJECTID), collapse = '|'),
				INCIDENT =  paste(unique(INCIDENT), collapse = '|'),
				wildfire_complex = any(wildfire_complex),
				state_from_id = paste(unique(state_from_id), collapse = '|'),
				geometry = st_union(geometry)
			)
	)
	

  nifc %>%
		transmute(
			wildfire_year = FIRE_YEAR,
			wildfire_state = state_from_id,
			irwin_id = IRWINID,
			nifc_id = OBJECTID,
			wildfire_name = INCIDENT,
			wildfire_complex,
			wildfire_area = as.numeric(st_area(geometry))/1000/1000 # area in km
		)
}
