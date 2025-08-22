clean_ics209 <- function(event_ics209_raw){
	bind_rows(
		read_parquet(file.path(event_ics209_raw, 'current_cleaned.parquet')),
		read_parquet(file.path(event_ics209_raw, 'historical_cleaned.parquet'))
	) %>%
		mutate(
			ics_county = standardize_county_name(ics_county),
			ics_name = standardize_place_name(ics_name)
		) %>%
		transmute(
			ics_id,
			wildfire_name = ics_name,
			wildfire_poo_lat = ics_wildfire_poo_lat,
			wildfire_poo_lon = if_else(wildfire_poo_lat > 14, -abs(ics_wildfire_poo_lon), ics_wildfire_poo_lon), # assume positive numbers are shorthand (unless it's way far south like guam, then leave it alone)
			wildfire_counties = ics_county,
			wildfire_states = ics_state,
			wildfire_ignition_date = ics_wildfire_ignition_date,
			wildfire_area = ics_wildfire_area,
			wildfire_complex = ics_complex,
			wildfire_civil_fatalities = ics_wildfire_fatalities_civ,
			wildfire_total_fatalities = ics_wildfire_fatalities_tot,			
			wildfire_civil_injuries = ics_wildfire_injuries_civ,
			wildfire_total_injuries = ics_wildfire_injuries_tot,
			wildfire_civil_evacuation = ics_wildfire_evacuation_civ,
			wildfire_total_evacuation = ics_wildfire_evacuation_tot,
			wildfire_struct_destroyed = ics_wildfire_struct_destroyed,
			wildfire_struct_threatened = ics_wildfire_struct_threatened,
			wildfire_cost = ics_wildfire_cost,
			irwin_id = ics_irwin_id
		) %>%
		mutate( # get rid of hurricanes 
			hurricane = str_detect(wildfire_name, "TROPICAL STORM") | str_detect(wildfire_name, "HURRICANE") | str_detect(wildfire_name, "(\\bHELENE\\b|\\bIRMA\\b|\\bMILTON\\b|\\bIAN\\b|\\bMICHAEL\\b|\\bJEANNE\\b|\\bFRANCES\\b|\\bSANDY\\b|\\bLAURA\\b|\\bMARIA\\b)"),
			hurricane = if_else(is.na(wildfire_name), FALSE, hurricane)
		) %>%
		filter(!hurricane) %>%
		filter(wildfire_ignition_date >= as.Date('2000-01-01'))
}