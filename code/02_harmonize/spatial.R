# # --------------------------------
# # Description: Harmonize Spatial Data with Event Data
# 
# # Logan Piepmeier
# # --------------------------------

harmonize_spatial <- function(
		event,
		spatial_mtbs,
		spatial_fired,
		spatial_nifc, 
		spatial_tiger_counties
){

	event <- event %>% 
		mutate(
			tier = case_when(
				irwin_id %in% na.omit(spatial_mtbs$irwin_id) ~ 1,
				irwin_id %in% na.omit(spatial_nifc$irwin_id) ~ 2,
				TRUE ~ 3
			)
		)
	
	unnest_state_county <- function(x){ # for fires listed in more than one state/county (uses all combos of state/county)
		x %>%
			mutate(wildfire_counties = str_split(wildfire_counties, pattern = '\\|')) %>%
			mutate(wildfire_states = str_split(wildfire_states, pattern = '\\|')) %>%
			unnest(cols = c(wildfire_counties)) %>% 
			unnest(cols = c(wildfire_states))
	}
	
	### Tier 1: Match MTBS by ID ###
	t1 <- spatial_mtbs %>% 
		inner_join(filter(event, tier == 1), by = 'irwin_id', relationship = 'one-to-many', suffix = c('_mtbs', '_event')) %>%
		group_by(irwin_id, wildfire_ignition_date_mtbs) %>%
		summarize(
			wildfire_year = first(wildfire_year, na_rm = TRUE),
			#wildfire_states = paste(na.omit(wildfire_states), collapse = '|'),
			wildfire_area = max(wildfire_area_mtbs, na.rm = TRUE),
			wildfire_complex = any(wildfire_complex_event | wildfire_complex_mtbs, na.rm = TRUE),
			wildfire_complex_names = dedupe_pipe_delim(paste(wildfire_name, wildfire_complex_names, collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_ignition_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = 'MTBS',
			redbook_id =  paste(unique(redbook_id), collapse = '|') %>% na_if('NA'),
			ics_id     =  paste(unique(ics_id), collapse = '|') %>% na_if('NA'),
			fired_id   =  NA_character_,
			mtbs_id    =  paste(unique(mtbs_id), collapse = '|') %>% na_if('NA'),
			nifc_id    =  NA_character_,
			fema_id    =  paste(unique(fema_id), collapse = '|') %>% na_if('NA'),
			.groups = 'drop'
		) %>% 
		mutate( # resolve data that also appears in mtbs
			wildfire_ignition_date = pmin(wildfire_ignition_date, wildfire_ignition_date_mtbs, na.rm = TRUE),
			wildfire_ignition_date_max = pmax(wildfire_ignition_date_max, wildfire_ignition_date_mtbs, na.rm = TRUE)
		) %>% 
		select(-wildfire_ignition_date_mtbs)
	
	### Tier 2: Match NIFC by ID ###
	t2 <- spatial_nifc %>% 
		inner_join(filter(event, tier == 2), by = 'irwin_id', relationship = 'one-to-many', suffix = c('_nifc', '_event')) %>%
		group_by(irwin_id) %>%
		summarize(
			wildfire_year = first(wildfire_year_nifc, na_rm = TRUE), # drop event year -- shouldn't be different
			#wildfire_states = paste(na.omit(wildfire_states), collapse = '|'),
			wildfire_area = max(wildfire_area_nifc, na.rm = TRUE),
			wildfire_complex = any(wildfire_complex_event | wildfire_complex_nifc, na.rm = TRUE),
			wildfire_complex_names = dedupe_pipe_delim(paste(wildfire_name, wildfire_complex_names, collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_ignition_date, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = 'NIFC',
			redbook_id =  paste(unique(redbook_id), collapse = '|') %>% na_if('NA'),
			ics_id     =  paste(unique(ics_id), collapse = '|') %>% na_if('NA'),
			fired_id   =  NA_character_,
			mtbs_id    =  NA_character_,
			nifc_id    =  paste(unique(nifc_id), collapse = '|') %>% na_if('NA'),
			fema_id    =  paste(unique(fema_id), collapse = '|') %>% na_if('NA'),
			.groups = 'drop'
		) 
	
	### Tier 3: Match by Name/Place/Time ###
	
	event_t3_long <- event %>% 
		filter(tier == 3) %>%
		mutate(orig_rowid_event = row_number()) %>% 
		unnest_state_county() %>%
		mutate(
			fuzzystart = wildfire_ignition_date - 15L,
			fuzzyend = wildfire_ignition_date_max + 15L
		)
	
	## Tier 3A: MTBS ##
	
	mtbs_long <- spatial_mtbs %>%  # expand by state/county and calculate dates for fuzzy match
		mutate(orig_rowid_mtbs = row_number()) %>% 
		append_county(.$wildfire_ignition_date, spatial_tiger_counties) %>%
		st_drop_geometry() %>%
		mutate(
			fuzzystart = wildfire_ignition_date - 15L,
			fuzzyend = wildfire_ignition_date + 15L
		)
	
	t3a_xwalk <- inner_join( # fuzzy join on name, county name
		mtbs_long %>% rename(wildfire_states = STATE_ABB),
		event_t3_long,
		join_by(wildfire_states, overlaps(x$fuzzystart, x$fuzzyend, y$fuzzystart, y$fuzzyend)),
		suffix = c('_mtbs', '_event')
	) %>%
		filter(
			stringdist(wildfire_name, wildfire_complex_names, method = 'jw', p = .1) <= .25, 
			stringdist(wildfire_counties, COUNTY_NAME, method = 'jw', p = .1) <= .25 
		) %>%
		select(orig_rowid_mtbs, orig_rowid_event) %>%
		distinct() 
	
	t3a <- spatial_mtbs %>% 
		mutate(orig_rowid_mtbs = row_number()) %>%
		inner_join(t3a_xwalk, by = 'orig_rowid_mtbs') %>% 
		inner_join(
			event %>% 
				filter(tier == 3) %>%
				mutate(orig_rowid_event = row_number()),
			by = 'orig_rowid_event',
			suffix = c('_mtbs', '_event')
		) %>% 
		group_by(orig_rowid_mtbs) %>%
		summarize(
			wildfire_year = first(wildfire_year, na_rm = TRUE),
			#wildfire_states = paste(na.omit(wildfire_states), collapse = '|'),
			wildfire_area = max(wildfire_area_mtbs, na.rm = TRUE),
			wildfire_complex = any(wildfire_complex_event | wildfire_complex_mtbs, na.rm = TRUE),
			wildfire_complex_names = dedupe_pipe_delim(paste(wildfire_name, wildfire_complex_names, collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_ignition_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = 'MTBS',
			redbook_id =  paste(unique(redbook_id), collapse = '|') %>% na_if('NA'),
			ics_id     =  paste(unique(ics_id), collapse = '|') %>% na_if('NA'),
			fired_id   =  NA_character_,
			mtbs_id    =  paste(unique(mtbs_id), collapse = '|') %>% na_if('NA'),
			nifc_id    =  NA_character_,
			fema_id    =  paste(unique(fema_id), collapse = '|') %>% na_if('NA'),
			.groups = 'drop'
		) %>%
		select(-orig_rowid_mtbs)
	
	## Tier 3B: NIFC join on Date/Time/Name ## 
	
	nifc_long <- spatial_nifc %>%  # expand by state/county and calculate dates for fuzzy match
		mutate(
			orig_rowid_nifc = row_number(),
		) %>% 
		append_county(ymd(paste0(.$wildfire_year, '-01-01')), spatial_tiger_counties) %>%
		st_drop_geometry() %>%
		mutate(
			fuzzystart = ymd(paste0(wildfire_year, '-01-01')) - 15L,
			fuzzyend = ymd(paste0(wildfire_year, '-12-31')) + 15L
		) %>%
		select(-wildfire_states)
	
	t3b_xwalk <- inner_join( # fuzzy join on name, county name
		nifc_long %>% rename(wildfire_states = STATE_ABB),
		event_t3_long,
		join_by(wildfire_states, overlaps(x$fuzzystart, x$fuzzyend, y$fuzzystart, y$fuzzyend)),
		suffix = c('_nifc', '_event')
	) %>%
		filter(
			stringdist(wildfire_name, wildfire_complex_names, method = 'jw', p = .1) <= .25, 
			stringdist(wildfire_counties, COUNTY_NAME, method = 'jw', p = .1) <= .25 
		) %>%
		select(orig_rowid_nifc, orig_rowid_event) %>%
		distinct() 
	
	t3b <- spatial_nifc %>% 
		mutate(orig_rowid_nifc = row_number()) %>%
		inner_join(t3b_xwalk, by = 'orig_rowid_nifc') %>% 
		inner_join(
			event %>% 
				filter(tier == 3) %>%
				mutate(orig_rowid_event = row_number()),
			by = 'orig_rowid_event',
			suffix = c('_nifc', '_event')
		) %>% 
		group_by(orig_rowid_nifc) %>%
		summarize(
			wildfire_year = first(wildfire_year_nifc, na_rm = TRUE), # drop event year -- shouldn't be different
			#wildfire_states = paste(na.omit(wildfire_states), collapse = '|'),
			wildfire_area = max(wildfire_area_nifc, na.rm = TRUE),
			wildfire_complex = any(wildfire_complex_event | wildfire_complex_nifc, na.rm = TRUE),
			wildfire_complex_names = dedupe_pipe_delim(paste(wildfire_name, wildfire_complex_names, collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date, na.rm = TRUE)), 
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_ignition_date, na.rm = TRUE)), 
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = 'NIFC',
			redbook_id =  paste(unique(redbook_id), collapse = '|') %>% na_if('NA'),
			ics_id     =  paste(unique(ics_id), collapse = '|') %>% na_if('NA'),
			fired_id   =  NA_character_,
			mtbs_id    =  NA_character_,
			nifc_id    =  paste(unique(nifc_id), collapse = '|') %>% na_if('NA'),
			fema_id    =  paste(unique(fema_id), collapse = '|') %>% na_if('NA'),
			.groups = 'drop'
		) %>%
		select(-orig_rowid_nifc)
	
	# get rid of any already identified in t3a
	ics_found <- c(t1$ics_id, t2$ics_id, t3a$ics_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()
	redbook_found <- c(t1$redbook_id, t2$redbook_id, t3a$redbook_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()
	fema_found <- c(t1$fema_id, t2$fema_id, t3a$fema_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()
	
	t3b <- t3b %>% 
		filter(
			!unlist(map(str_split(ics_id, pattern = '\\|'), ~any(.x %in% ics_found))),
			!unlist(map(str_split(redbook_id, pattern = '\\|'), ~any(.x %in% redbook_found))),
			!unlist(map(str_split(fema_id, pattern = '\\|'), ~any(.x %in% fema_found)))
		)
			
		
	
	## Tier 3C: FIRED join on Time/POO ##
	
	fired_long <- spatial_fired %>%  # expand by state/county and calculate dates for fuzzy match
		mutate(orig_rowid_fired = row_number()) %>% 
		append_county(.$wildfire_ignition_date, spatial_tiger_counties) %>%
		mutate(
			fuzzystart = wildfire_ignition_date - 15L,
			fuzzyend = wildfire_containment_date + 15L
		)
	
	t3c_xwalk <- inner_join( # fuzzy join on date, location
		tibble(fired_long %>% rename(wildfire_states = STATE_ABB)),
		tibble(st_as_sf(event_t3_long, coords = c('wildfire_poo_lon', 'wildfire_poo_lat'), na.fail = FALSE, crs = st_crs(fired_long), remove = FALSE)),
		join_by(wildfire_states, overlaps(x$fuzzystart, x$fuzzyend, y$fuzzystart, y$fuzzyend)),
		suffix = c('_fired', '_event')
	) %>%
	filter(
		as.numeric(st_distance(geometry_fired, geometry_event, by_element = TRUE)) < 10000 # within 10 km
	) %>%
		select(orig_rowid_fired, orig_rowid_event) %>%
		distinct() 
	
	t3c <- spatial_fired %>% 
		mutate(orig_rowid_fired = row_number()) %>%
		inner_join(t3c_xwalk, by = 'orig_rowid_fired') %>% 
		inner_join(
			event %>% 
				filter(tier == 3) %>%
				mutate(orig_rowid_event = row_number()),
			by = 'orig_rowid_event',
			suffix = c('_fired', '_event')
		) %>% 
		group_by(orig_rowid_fired) %>%
		summarize(
			wildfire_year = first(wildfire_year, na_rm = TRUE), 
			#wildfire_states = paste(na.omit(wildfire_states), collapse = '|'),
			wildfire_area = max(wildfire_area_fired),
			wildfire_complex = any(wildfire_complex),
			wildfire_complex_names = dedupe_pipe_delim(paste(wildfire_complex_names, collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date_event, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_containment_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date_event, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = 'FIRED',
			redbook_id =  paste(unique(redbook_id), collapse = '|') %>% na_if('NA'),
			ics_id     =  paste(unique(ics_id), collapse = '|') %>% na_if('NA'),
			fired_id   =  paste(unique(fired_id), collapse = '|') %>% na_if('NA'),
			mtbs_id    =  NA_character_,
			nifc_id    =  NA_character_,
			fema_id    =  paste(unique(fema_id), collapse = '|') %>% na_if('NA'),
			.groups = 'drop'
		) %>%
		select(-orig_rowid_fired)
	
	
	# get rid of any already identified in t3a or t3b
	ics_found <- c(t1$ics_id, t2$ics_id, t3a$ics_id, t3b$ics_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()
	redbook_found <- c(t1$redbook_id, t2$redbook_id, t3a$redbook_id, t3b$redbook_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()
	fema_found <- c(t1$fema_id, t2$fema_id, t3a$fema_id, t3b$fema_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()
	
	t3c <- t3c %>% 
		filter(
			!unlist(map(str_split(ics_id, pattern = '\\|'), ~any(.x %in% ics_found))),
			!unlist(map(str_split(redbook_id, pattern = '\\|'), ~any(.x %in% redbook_found))),
			!unlist(map(str_split(fema_id, pattern = '\\|'), ~any(.x %in% fema_found)))
		)
	
	
	### Tier 4: Approximate Burn Zone from ICS POO ###
	
	ics_found <- c(t1$ics_id, t2$ics_id, t3a$ics_id, t3b$ics_id, t3c$ics_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()
	# get rid of any already identified in t3a or t3b
	ics_found <- c(t1$ics_id, t2$ics_id, t3a$ics_id, t3b$ics_id, t3c$ics_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()
	redbook_found <- c(t1$redbook_id, t2$redbook_id, t3a$redbook_id, t3b$redbook_id, t3c$redbook_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()
	fema_found <- c(t1$fema_id, t2$fema_id, t3a$fema_id, t3b$fema_id, t3c$fema_id) %>%
		str_split(pattern = '\\|') %>% 
		unlist() %>%
		unique()

	t4 <- event %>% 
		filter(
			!unlist(map(str_split(ics_id, pattern = '\\|'), ~any(.x %in% ics_found))),
			!unlist(map(str_split(redbook_id, pattern = '\\|'), ~any(.x %in% redbook_found))),
			!unlist(map(str_split(fema_id, pattern = '\\|'), ~any(.x %in% fema_found)))
		) %>% 
		mutate(tier = 4) %>%
		filter(!is.na(wildfire_poo_lat), !is.na(wildfire_poo_lon), !is.na(wildfire_area)) %>%
		mutate(
			radius = sqrt(wildfire_area/pi)*1000
		) %>%
		st_as_sf(coords = c('wildfire_poo_lon', 'wildfire_poo_lat'), remove = FALSE, crs = 4269) %>% 
		st_buffer(.$radius) %>%
		select(-radius)
		
	
	### Add State/County from final geometry
	
	
	### combine and shine
	bind_rows(
		t1,
		t2,
		t3a,
		t3b,
		t3c,
		t4
	)

}

