# srced from https://drive.google.com/drive/u/1/folders/1G0sy_DydeZt8NqcXHD7ryNMhWBtzy3TW

clean_redbook <- function(event_redbook_raw){
	
	fs::dir_ls(event_redbook_raw, recurse = TRUE, glob = '*_csv.csv') %>%
		map(read_csv, show_col_types = FALSE, col_types = cols(.default = 'c'), na = c('', 'NA', 'na')) %>%
		bind_rows(.id = 'src') %>%
		transmute(
			src,
			redbook_id = row_number(),
			wildfire_name = standardize_place_name(incident_name),
			wildfire_year = as.numeric(start_year),
			wildfire_ignition_date = if_else(str_detect(date_start, '^[0-9]{5}$'), as.Date(as.numeric(date_start), origin = "1899-12-30"), mdy(date_start)), #excel date for csvs
			wildfire_containment_date = if_else(str_detect(date_cont, '^[0-9]{5}$'), as.Date(as.numeric(date_cont), origin = "1899-12-30"), mdy(date_cont)),
			wildfire_counties = standardize_county_name(county_unit),
			wildfire_struct_destroyed = as.numeric(structures_dest), 
			wildfire_civil_fatalities = as.numeric(fatalities_civilian),
			wildfire_total_fatalities = coalesce(wildfire_civil_fatalities, 0) + as.numeric(fatalities_fire),
			wildfire_area = as.numeric(acres_burned) * 0.00404686 # sq km
		) %>%
		filter(
			!is.na(wildfire_ignition_date),
			!is.na(wildfire_name),
			wildfire_year >= 2000,
			wildfire_year == year(wildfire_ignition_date)
		) %>% 
		suppressWarnings()
}
