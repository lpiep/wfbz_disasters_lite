# --------------------------------
# Description: 
# Date: 
#
# Logan Piepmeier
# --------------------------------
harmonize_event <- function(
		event_ics209,		
		event_redbook,
		event_fema
){
	unnest_state_county <- function(x){ # for fires listed in more than one state/county (uses all combos of state/county)
		x %>%
			mutate(wildfire_counties = str_split(wildfire_counties, pattern = '\\|')) %>%
			mutate(wildfire_states = str_split(wildfire_states, pattern = '\\|')) %>%
			unnest(cols = c(wildfire_counties)) %>% 
			unnest(cols = c(wildfire_states))
	}
		
	# unnest and create fuzzy dates
	event_ics209_long <- unnest_state_county(event_ics209) %>% mutate(fuzzystart = wildfire_ignition_date - 15, fuzzyend = wildfire_ignition_date + 15)
	event_redbook_long <- unnest_state_county(mutate(event_redbook, wildfire_states = 'CA')) %>% mutate(fuzzystart = wildfire_ignition_date - 15, fuzzyend = wildfire_ignition_date + 15)
	event_fema_long <- unnest_state_county(event_fema) %>% mutate(fuzzystart = wildfire_ignition_date - 15, fuzzyend = wildfire_ignition_date + 15)

	# apply source name to non-join columns
	event_ics209_long <- event_ics209_long %>% rename_with(.cols = -c(ics_id, irwin_id, wildfire_states, wildfire_counties), .fn = ~ paste0(.x, '_ics209'))
	event_redbook_long <- event_redbook_long %>% rename_with(.cols = -c(redbook_id, wildfire_states, wildfire_counties), .fn = ~ paste0(.x, '_redbook'))
	event_fema_long <- event_fema_long %>% rename_with(.cols = -c(fema_id, wildfire_states, wildfire_counties), .fn = ~ paste0(.x, '_fema'))

	# create join indicator variable
	event_ics209_long$match_ics209 <- TRUE
	event_redbook_long$match_redbook <- TRUE
	event_fema_long$match_fema <- TRUE
	
	# join ICS and redbook
	event_merged <- full_join(
		event_ics209_long,
		event_redbook_long, 
		join_by(wildfire_states, wildfire_counties, overlaps(fuzzystart_ics209, fuzzyend_ics209, fuzzystart_redbook, fuzzyend_redbook))
	) %>%
		mutate(
			fuzzystart_any = pmin(fuzzystart_ics209, fuzzystart_redbook),
			fuzzyend_any = pmax(fuzzyend_ics209, fuzzyend_redbook)
		) %>%
		filter( # keep un-matched and matches with similar names
			xor(is.na(match_ics209), is.na(match_redbook)) | 
			stringdist(wildfire_name_ics209, wildfire_name_redbook, method = 'jw', p = .1) <= .25 # threshold chosen by inspection
		) %>% 
		# Join fema
		full_join(
			event_fema_long,
			join_by(wildfire_states, wildfire_counties, overlaps(fuzzystart_any, fuzzyend_any, fuzzystart_fema, fuzzyend_fema))
		) %>% 
		filter( # keep un-matched and matches with similar names
			is.na(match_fema) | 
			stringdist(wildfire_name_ics209, wildfire_name_fema, method = 'jw', p = .1) <= .25 |
			stringdist(wildfire_name_redbook, wildfire_name_fema, method = 'jw', p = .1) <= .25 # threshold chosen by inspection
		)

	# re-collapse state/county
	event_merged <- event_merged %>%
		group_by(ics_id, redbook_id, fema_id) %>% 
		nest(data = c(wildfire_counties, wildfire_states)) %>%
		mutate(
			wildfire_counties = map(data, ~ pluck(.x, 'wildfire_counties') %>% na.omit() %>% unique() %>% paste(collapse = '|')) %>% unlist(), 
			wildfire_states = map(data, ~ pluck(.x, 'wildfire_states') %>% na.omit() %>% unique() %>% paste(collapse = '|')) %>% unlist(),
		) %>%
		select(-data, -matches('fuzzy')) %>%
		ungroup() 
	
	# create disaster criteria and filter
	event_merged <- event_merged %>% # still contains dupes (in a complex way)
		 mutate(
		 	wildfire_fema_dec = !is.na(wildfire_fema_dec_date_fema),
		 	wildfire_struct_destroyed = pmax(wildfire_struct_destroyed_ics209, wildfire_struct_destroyed_redbook, na.rm = TRUE),
		 	wildfire_civil_fatalities = pmax(wildfire_civil_fatalities_ics209, wildfire_civil_fatalities_redbook, na.rm = TRUE),
		 	wildfire_total_fatalities = pmax(wildfire_total_fatalities_ics209, wildfire_total_fatalities_redbook, na.rm = TRUE),
		 	wildfire_max_civil_fatalities = case_when(
		 		wildfire_year_redbook < 2014 & !is.na(wildfire_civil_fatalities_redbook) ~ wildfire_civil_fatalities_redbook,
		 		TRUE ~ wildfire_civil_fatalities
		 	)
		 ) %>%
		filter(
			wildfire_fema_dec | 
			coalesce(wildfire_struct_destroyed, 0) > 0 |
			coalesce(wildfire_civil_fatalities, 0) > 0 | 
			coalesce(wildfire_total_fatalities, 0) > 0
		) 

	# take records from sources in order of precedence (redbook > ics209 > fema) or by min/maxing
	event_merged %>% 
		unite('wildfire_complex_names', c(wildfire_name_redbook, wildfire_name_ics209, wildfire_name_fema), sep = '|', na.rm = TRUE) %>% 
		transmute(
			wildfire_year = coalesce(wildfire_year_redbook, year(pmin(wildfire_ignition_date_fema, wildfire_ignition_date_ics209, wildfire_ignition_date_redbook, na.rm = TRUE))),
			wildfire_states,
			wildfire_counties,
			wildfire_area = coalesce(wildfire_area_redbook, wildfire_area_ics209) ,
			wildfire_complex = wildfire_complex_ics209, 
			wildfire_complex_names = dedupe_pipe_delim(wildfire_complex_names), # rm dupes
			wildfire_total_fatalities,
			wildfire_civil_fatalities,
			wildfire_max_civil_fatalities,
			wildfire_struct_destroyed = coalesce(wildfire_struct_destroyed_redbook, wildfire_struct_destroyed_ics209),
			wildfire_fema_dec,
			wildfire_ignition_date = pmin(wildfire_ignition_date_fema, wildfire_ignition_date_ics209, wildfire_ignition_date_redbook, na.rm = TRUE),
			wildfire_containment_date = pmin(wildfire_containment_date_fema, wildfire_containment_date_redbook, na.rm = TRUE),
			wildfire_ignition_date_max = pmax(wildfire_ignition_date_fema, wildfire_ignition_date_ics209, wildfire_ignition_date_redbook, na.rm = TRUE),
			wildfire_containment_date_max = pmax(wildfire_containment_date_fema, wildfire_containment_date_redbook, na.rm = TRUE),
			wildfire_fema_dec_date = wildfire_fema_dec_date_fema,
			wildfire_poo_lat = wildfire_poo_lat_ics209,
			wildfire_poo_lon = wildfire_poo_lon_ics209,
			redbook_id = as.character(redbook_id),
			ics_id,
			fema_id,
			irwin_id
		)
}
