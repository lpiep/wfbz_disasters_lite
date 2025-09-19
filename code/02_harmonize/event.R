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
			fuzzystart_any = pmin(fuzzystart_ics209, fuzzystart_redbook, na.rm = TRUE),
			fuzzyend_any = pmax(fuzzyend_ics209, fuzzyend_redbook, na.rm = TRUE)
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
	
	# Some fires will have dropped out because they *did* fall in the same date range / location as other fires
	#.  but did not match any of those by name. We will add those back in here.
	nomatch_ics209 <- anti_join(event_ics209_long, event_merged, by = 'ics_id')
	nomatch_redbook <- anti_join(event_redbook_long, event_merged, by = 'redbook_id')
	nomatch_fema <- anti_join(event_fema_long, event_merged, by = 'fema_id')
	
	event_merged <- bind_rows(
		event_merged,
		nomatch_ics209,
		nomatch_redbook,
		nomatch_fema
	)
			
	# re-collapse state/county
	event_merged <- event_merged %>%
		mutate(gid = coalesce(as.character(redbook_id), as.character(ics_id), as.character(fema_id))) %>% 
		group_by(gid) %>% 
		nest(data = c(wildfire_counties, wildfire_states)) %>%
		mutate(
			wildfire_counties = map(data, ~ pluck(.x, 'wildfire_counties') %>% na.omit() %>% unique() %>% paste(collapse = '|')) %>% unlist(), 
			wildfire_states = map(data, ~ pluck(.x, 'wildfire_states') %>% na.omit() %>% unique() %>% paste(collapse = '|')) %>% unlist(),
		) %>%
		select(-data) %>%
		summarize( # summarize across rows
			ics_id = dedupe_pipe_delim(paste(ics_id, collapse = '|')),
			wildfire_name_ics209 = dedupe_pipe_delim(paste(wildfire_name_ics209, collapse = '|')),
			wildfire_poo_lat_ics209 = first((wildfire_poo_lat_ics209), na_rm = TRUE),
			wildfire_poo_lon_ics209 = first((wildfire_poo_lon_ics209), na_rm = TRUE),
			wildfire_counties = dedupe_pipe_delim(paste(wildfire_counties, collapse = '|')),
			wildfire_states =  dedupe_pipe_delim(paste(wildfire_states, collapse = '|')),
			wildfire_ignition_date_ics209 = suppressWarnings(min(wildfire_ignition_date_ics209, na.rm = TRUE)) %>% na_if(as.Date(Inf)) %>% na_if(as.Date(-Inf)),
			wildfire_area_ics209 = suppressWarnings(max(wildfire_area_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_complex_ics209 = any(wildfire_complex_ics209, na.rm = TRUE),
			wildfire_civil_fatalities_ics209 = suppressWarnings(max(wildfire_civil_fatalities_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_total_fatalities_ics209 = suppressWarnings(max(wildfire_total_fatalities_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_civil_injuries_ics209 = suppressWarnings(max(wildfire_civil_injuries_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_total_injuries_ics209 = suppressWarnings(max(wildfire_total_injuries_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_civil_evacuation_ics209 = suppressWarnings(max(wildfire_civil_evacuation_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_total_evacuation_ics209 = suppressWarnings(max(wildfire_total_evacuation_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_struct_destroyed_ics209 = suppressWarnings(max(wildfire_struct_destroyed_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_struct_threatened_ics209 = suppressWarnings(max(wildfire_struct_threatened_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_cost_ics209 = suppressWarnings(max(wildfire_cost_ics209, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			irwin_id = dedupe_pipe_delim(paste(irwin_id, collapse = '|')),
			redbook_id = dedupe_pipe_delim(paste(redbook_id, collapse = '|')),
			wildfire_name_redbook = dedupe_pipe_delim(paste(wildfire_name_redbook, collapse = '|')),
			wildfire_year_redbook = first((wildfire_year_redbook), na_rm = TRUE),
			wildfire_ignition_date_redbook = suppressWarnings(min(wildfire_ignition_date_redbook, na.rm = TRUE)) %>% na_if(as.Date(Inf)) %>% na_if(as.Date(-Inf)),
			wildfire_containment_date_redbook = suppressWarnings(max(wildfire_containment_date_redbook, na.rm = TRUE)) %>% na_if(as.Date(Inf)) %>% na_if(as.Date(-Inf)),
			wildfire_struct_destroyed_redbook = suppressWarnings(max(wildfire_struct_destroyed_redbook, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_civil_fatalities_redbook = suppressWarnings(max(wildfire_civil_fatalities_redbook, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_total_fatalities_redbook = suppressWarnings(max(wildfire_total_fatalities_redbook, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			wildfire_area_redbook = suppressWarnings(max(wildfire_area_redbook, na.rm = TRUE)) %>% na_if(Inf) %>% na_if(-Inf),
			fuzzystart_any = suppressWarnings(min(fuzzystart_any, na.rm = TRUE)) %>% na_if(as.Date(Inf)) %>% na_if(as.Date(-Inf)),
			fuzzyend_any = suppressWarnings(max(fuzzyend_any, na.rm = TRUE)) %>% na_if(as.Date(Inf)) %>% na_if(as.Date(-Inf)),
			fema_id = dedupe_pipe_delim(paste(fema_id, collapse = '|')),
			wildfire_year_fema = first((wildfire_year_fema), na_rm = TRUE),
			wildfire_fema_dec_date_fema = suppressWarnings(min(wildfire_fema_dec_date_fema, na.rm = TRUE)) %>% na_if(as.Date(Inf)) %>% na_if(as.Date(-Inf)),
			wildfire_name_fema = dedupe_pipe_delim(paste(wildfire_name_fema, collapse = '|')),
			wildfire_ignition_date_fema = suppressWarnings(min(wildfire_ignition_date_fema, na.rm = TRUE)) %>% na_if(as.Date(Inf)) %>% na_if(as.Date(-Inf)),
			wildfire_containment_date_fema = suppressWarnings(max(wildfire_containment_date_fema, na.rm = TRUE)) %>% na_if(as.Date(Inf)) %>% na_if(as.Date(-Inf))
		) %>% 
		ungroup() 
	
	# create disaster criteria and filter
	event_merged <- event_merged %>% # still contains dupes (in a complex way)
		 mutate(
		 	wildfire_year = coalesce(wildfire_year_redbook, year(pmin(wildfire_ignition_date_fema, wildfire_ignition_date_ics209, wildfire_ignition_date_redbook, na.rm = TRUE))),
		 	wildfire_fema_dec = !is.na(wildfire_fema_dec_date_fema),
		 	wildfire_struct_destroyed = coalesce(wildfire_struct_destroyed_redbook, wildfire_struct_destroyed_ics209),
		 	wildfire_civil_fatalities = coalesce(wildfire_civil_fatalities_redbook, wildfire_civil_fatalities_ics209),
		 	wildfire_total_fatalities = coalesce(wildfire_total_fatalities_redbook, wildfire_total_fatalities_ics209),
		 	wildfire_max_civil_fatalities = case_when(
		 		str_detect(wildfire_states, 'CA') & wildfire_year < 2014 ~ wildfire_civil_fatalities_redbook,
		 		str_detect(wildfire_states, 'CA') & wildfire_year >= 2014 ~ pmax(wildfire_civil_fatalities_ics209, wildfire_civil_fatalities_redbook, na.rm = TRUE),
		 		!str_detect(wildfire_states, 'CA') & wildfire_year < 2014 ~ wildfire_total_fatalities_ics209,
		 		!str_detect(wildfire_states, 'CA') & wildfire_year >=2014 ~ wildfire_civil_fatalities_ics209
		 	), # hopefully do the below:
		 	#Best estimate of civilian fatalities from 2000-2019. From 2000-2013, only California RedBooks reported civilian 
		 	#fatalities alone. Therefore, from 2000-2013, this variable reports the maximum total fatalities for wildfires 
		 	#outside California but civilian specific fatalities from California. From 2014-2019, this variable reports 
		 	#the maximum civilian fatalities from each fire. 	Best estimate of civilian fatalities from 2000-2019. From 2000-2013, 
		 	#only California RedBooks reported civilian fatalities alone. Therefore, from 2000-2013, this variable reports the maximum 
		 	#total fatalities for wildfires outside California but civilian specific fatalities from California. From 2014-2019, 
		 	#this variable reports the maximum civilian fatalities from each fire.
		 	wildfire_total_fatalities = if_else(wildfire_total_fatalities < wildfire_max_civil_fatalities, wildfire_max_civil_fatalities, wildfire_total_fatalities), # fix weird cases where total reported as less than civil
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
		mutate(
			event_id = row_number(),
			wildfire_year,
			wildfire_states,
			wildfire_counties,
			wildfire_area = coalesce(wildfire_area_redbook, wildfire_area_ics209) ,
			wildfire_complex = wildfire_complex_ics209, 
			wildfire_complex_names = dedupe_pipe_delim(wildfire_complex_names), # rm dupes
			wildfire_total_fatalities,
			wildfire_civil_fatalities,
			wildfire_max_civil_fatalities,
			wildfire_struct_destroyed,
			wildfire_struct_threatened = wildfire_struct_threatened_ics209,
			wildfire_total_injuries = wildfire_total_injuries_ics209,
			wildfire_civil_injuries = wildfire_civil_injuries_ics209,
			wildfire_total_evacuation = wildfire_total_evacuation_ics209,
			wildfire_civil_evacuation = wildfire_civil_evacuation_ics209,
			wildfire_cost = wildfire_cost_ics209,
			wildfire_fema_dec,
			wildfire_ignition_date = coalesce(wildfire_ignition_date_redbook, pmin(wildfire_ignition_date_fema, wildfire_ignition_date_ics209, na.rm = TRUE)),
			wildfire_containment_date = coalesce(wildfire_containment_date_redbook, pmin(wildfire_containment_date_fema, wildfire_containment_date_redbook, na.rm = TRUE)),
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
