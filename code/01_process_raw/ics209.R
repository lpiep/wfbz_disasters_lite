clean_ics209 <- function(event_ics209_raw){
	bind_rows(
		read_parquet(file.path(event_ics209_raw, 'current_cleaned.parquet')),
		read_parquet(file.path(event_ics209_raw, 'historical_cleaned.parquet'))
	) %>%
		mutate(
			ics_county = standardize_county_name(ics_county),
			ics_name = standardize_place_name(ics_name)
		) %>%
		select(
			ics_id,
			wildfire_name = ics_name,
			wildfire_poo_lat = ics_wildfire_poo_lat,
			wildfire_poo_lon = ics_wildfire_poo_lon,
			wildfire_counties = ics_county,
			wildfire_states = ics_state,
			wildfire_ignition_date = ics_wildfire_ignition_date,
			wildfire_area = ics_wildfire_area,
			wildfire_complex = ics_complex,
			wildfire_civil_fatalities = ics_wildfire_fatalities_civ,
			wildfire_total_fatalities = ics_wildfire_fatalities_tot,
			wildfire_struct_destroyed = ics_wildfire_struct_destroyed,
			irwin_id = ics_irwin_id
		) %>%
		filter( # get rid of hurricanes 
			!str_detect(wildfire_name, "TROPICAL STORM"),
			!str_detect(wildfire_name, "HURRICANE") & !str_detect(wildfire_name, "(HELENE|IRMA|MILTON|IAN|MICHAEL|JEANNE|FRANCES|SANDY|LAURA|MARIA)")
		)
}