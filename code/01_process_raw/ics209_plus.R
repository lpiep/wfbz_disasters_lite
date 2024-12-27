
### INCIDENT DATA ###

# # My join (the below is kind of complex) #
# clean_ics209_plus <- function(event_ics209_plus_raw){
# 	incidents <- read_csv(file.path(event_ics209_plus_raw, 'ics209plus-wildfire', 'ics209-plus-wf_incidents_1999to2020.csv'), name_repair = 'unique_quiet') %>% select(-`...1`)
# 	complexes <- read_csv(file.path(event_ics209_plus_raw, 'ics209plus-wildfire', 'ics209-plus-wf_complex_associations_1999to2020.csv'), name_repair = 'unique_quiet') %>% select(-`...1`)
# 	
# 	incident_complexes <- full_join(
# 		complexes, 
# 		incidents, 
# 		by = c("FODJ_INCIDENT_ID", "MTBS_FIRE_LIST", "FOD_FIRE_LIST"), 
# 		relationship = "many-to-many"
# 	)
# }

clean_ics209_plus_incidents <- function(event_ics209_plus_raw){
	# raw ICS-209-PLUS Wildfire Incident Summary dataset
	ics_209 <- read_csv(file.path(event_ics209_plus_raw, 'ics209plus-wildfire', 'ics209-plus-wf_incidents_1999to2020.csv'), name_repair = 'unique_quiet')
	
	# Convert columns to snakecase --------------------------------------------
	
	names(ics_209) <- to_snake_case(names(ics_209))
	
	# Paste ics_209 to nationwide column names -------------------------------------------
	
	ics_209 <- rename_with(
		ics_209, 
		.fn = function(x) paste0('ics_209_', x),
		.cols = -c(fodj_incident_id, mtbs_fire_list, fod_fire_list)
	)
	
	# fix any variable name prefixes ------------------------------------------
	
	names(ics_209) <- gsub("^ics_209_ics_209_", "ics_209_", names(ics_209))
	# Convert all characters to upper case ------------------------------------
	
	ics_209 <- ics_209 %>%
		mutate(across(where(is.character), toupper))
	
	# select columns ----------------------------------------------------------
	
	ics_209_select_vars <- ics_209 %>%
		dplyr::select(
			# ID info
			ics_209_incident_id,
			ics_209_incident_number,
			ics_209_inctyp_abbreviation,
			# time info
			ics_209_discovery_doy,
			ics_209_fod_discovery_doy,
			ics_209_fod_contain_doy,
			ics_209_wf_cessation_date,
			ics_209_wf_cessation_doy,
			ics_209_start_year,
			ics_209_discovery_date,
			ics_209_expected_containment_date,
			#name info
			ics_209_incident_name,
			ics_209_complex,
			ics_209_fod_complex_name,
			#fatality info
			ics_209_fatalities,
			ics_209_fatalities_public,
			ics_209_fatalities_responder,
			#structure info
			ics_209_str_destroyed_total,
			ics_209_str_destroyed_res_total,
			ics_209_str_destroyed_comm_total,
			ics_209_str_damaged_total,
			ics_209_str_damaged_res_total,
			ics_209_str_damaged_comm_total,
			ics_209_str_threatened_max,
			#evacuation
			ics_209_evacuation_reported,
			ics_209_peak_evacuations,
			#injury
			ics_209_injuries_total,
			#cause info
			ics_209_cause,
			ics_209_fod_cause,
			#place info
			ics_209_poo_state,
			ics_209_poo_county,
			ics_209_poo_city,
			ics_209_poo_short_location_desc,
			ics_209_poo_latitude,
			ics_209_poo_longitude,
			ics_209_lrgst_fod_latitude,
			ics_209_lrgst_fod_longitude,
			#perimeter ids
			mtbs_fire_list,
			ics_209_fired_id,
			#acre info
			ics_209_final_acres,
			ics_209_fired_acres
		)
	
	# create row id -----------------------------------------------------------
	
	ics_209_select_vars<-ics_209_select_vars%>%
		mutate(ics_209_row_num=row_number())
	
	ics_209

}

clean_ics209_plus_complexes <- function(event_ics209_plus_raw){
	
	# raw ICS-209-PLUS Wildfire Incident Summary dataset
	ics_209_complexes <- read_csv(file.path(event_ics209_plus_raw, 'ics209plus-wildfire', 'ics209-plus-wf_complex_associations_1999to2020.csv'), name_repair = 'unique_quiet')
	
	# Convert columns to snakecase --------------------------------------------
	
	names(ics_209_complexes) <- to_snake_case(names(ics_209_complexes))

	# Paste ics_209_complexes to nationwide column names -------------------------------------------
	
	ics_209_complexes <- rename_with(
		ics_209_complexes, 
		.fn = function(x) paste0('ics_209_complexes_', x),
		.cols = -c(fodj_incident_id, mtbs_fire_list, fod_fire_list)
	)
		
	
	# fix any variable name prefixes ------------------------------------------
	
	names(ics_209_complexes) <- gsub("^ics_209_complexes_ics_209_complexes_", "ics_209_complexes_", names(ics_209_complexes))
	
	names(ics_209_complexes) <- gsub("^ics_209_complexes_ics_209_", "ics_209_complexes_", names(ics_209_complexes))
	
	names(ics_209_complexes) <- gsub("^ics_209_complexes_ics_", "ics_209_complexes_", names(ics_209_complexes))
	
	# Convert all characters to upper case ------------------------------------
	
	ics_209_complexes <- ics_209_complexes %>%
		mutate(across(where(is.character), toupper))
	
	# select columns ----------------------------------------------------------
	
	ics_209_complexes_select_vars <- ics_209_complexes %>%
		dplyr::select(
			-ics_209_complexes_1,
			-ics_209_complexes_member_inc_identifier,
			-ics_209_complexes_cplx_inc_identifier
		)
	
	# create row id -----------------------------------------------------------
	
	ics_209_complexes_select_vars<-ics_209_complexes_select_vars%>%
		mutate(ics_209_complexes_row_num=row_number())
	
	ics_209_complexes_select_vars
	
}

parse_py_dict <- function(d){
	if(is.na(d)) return(list())
	reticulate::py_run_string(
		glue("x = {d}"), 
		convert = TRUE
	)$x 
}

clean_ics209_plus <- function(event_ics209_plus_raw, spatial_tiger_counties){
 	complexes <- clean_ics209_plus_complexes(event_ics209_plus_raw)
 	incidents <- clean_ics209_plus_incidents(event_ics209_plus_raw)
 	
 	incidents_complexes <- full_join(
 		complexes, 
 		incidents, 
 		by = c("fodj_incident_id", "mtbs_fire_list", "fod_fire_list"),
 		relationship = 'many-to-many'
 	) %>%
 		mutate(fod_fire_list2 = map(fod_fire_list, parse_py_dict)) %>%	# FOD_FIRE_LIST is a string rep of a python dict 
		mutate(
			wildfire_fatalities = ics_209_fatalities,
			wildfire_civil_fatalities = ics_209_fatalities_public,
			wildfire_struct_destroyed = ics_209_str_destroyed_total,
			criterion_met_fatalities = if_else( # use total fatalities for years before they were separately reported
				year(as.Date(ics_209_final_report_date)) <= 2013,
				coalesce(wildfire_fatalities, 0) > 0,
				coalesce(wildfire_civil_fatalities, 0) > 0
			),
			criterion_met_struct = coalesce(wildfire_struct_destroyed, 0) > 0
		)
 	
 	# spatialize and get counties within 10km
	incidents_complexes_spatial_county_long <- incidents_complexes %>%
 		st_as_sf(coords = c('ics_209_poo_longitude', 'ics_209_poo_latitude'), crs = 4269, na.fail = FALSE, remove = FALSE) %>%
 		st_join(bind_rows(spatial_tiger_counties), left = TRUE, join = function(x, y) st_is_within_distance(x, y, dist = 10000)) %>%
		filter(year(floor_date(as.Date(ics_209_final_report_date), '10 years')) == CENSUS_YEAR | is.na(CENSUS_YEAR)) %>%
		rename(harmonized_county_name = NAME) %>%
		rename(harmonized_county_fips = FIPS) %>% 
 		st_drop_geometry() 
	
	incidents_complexes_spatial_county <- incidents_complexes_spatial_county_long %>% 
		group_by(-matches('harmonized')) %>% 
 		nest()

 	# 
}
