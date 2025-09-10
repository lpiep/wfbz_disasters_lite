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
			event_id = list(event_id),
			wildfire_year = first(wildfire_year, na_rm = TRUE),
			wildfire_area = max(wildfire_area_mtbs, na.rm = TRUE),
			wildfire_complex = any(wildfire_complex_event | wildfire_complex_mtbs, na.rm = TRUE),
			wildfire_complex_names = dedupe_pipe_delim(paste(c(wildfire_name, wildfire_complex_names), collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_max_civil_fatalities = suppressWarnings(max(wildfire_max_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_threatened = suppressWarnings(max(wildfire_struct_threatened, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_injuries = suppressWarnings(max(wildfire_total_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_injuries = suppressWarnings(max(wildfire_civil_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_evacuation = suppressWarnings(max(wildfire_total_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_evacuation = suppressWarnings(max(wildfire_civil_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_cost = suppressWarnings(max(wildfire_cost, na.rm = TRUE)) %>% na_if(-Inf),
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
			event_id = list(event_id),
			wildfire_year = first(wildfire_year_nifc, na_rm = TRUE), # drop event year -- shouldn't be different
			wildfire_area = max(wildfire_area_nifc, na.rm = TRUE),
			wildfire_complex = any(wildfire_complex_event | wildfire_complex_nifc, na.rm = TRUE),
			wildfire_complex_names = dedupe_pipe_delim(paste(c(wildfire_name, wildfire_complex_names), collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_max_civil_fatalities = suppressWarnings(max(wildfire_max_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_threatened = suppressWarnings(max(wildfire_struct_threatened, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_injuries = suppressWarnings(max(wildfire_total_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_injuries = suppressWarnings(max(wildfire_civil_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_evacuation = suppressWarnings(max(wildfire_total_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_evacuation = suppressWarnings(max(wildfire_civil_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_cost = suppressWarnings(max(wildfire_cost, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_ignition_date, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = 'NIFC',
			redbook_id =  paste(unique(na.omit(redbook_id)), collapse = '|') %>% na_if(''),
			ics_id     =  paste(unique(na.omit(ics_id)), collapse = '|') %>% na_if(''),
			fired_id   =  NA_character_,
			mtbs_id    =  NA_character_,
			nifc_id    =  paste(unique(na.omit(nifc_id)), collapse = '|') %>% na_if(''),
			fema_id    =  paste(unique(na.omit(fema_id)), collapse = '|') %>% na_if(''),
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
			event_id = list(event_id),
			wildfire_year = first(wildfire_year, na_rm = TRUE),
			wildfire_area = max(wildfire_area_mtbs, na.rm = TRUE),
			wildfire_complex = any(wildfire_complex_event | wildfire_complex_mtbs, na.rm = TRUE),
			wildfire_complex_names = dedupe_pipe_delim(paste(c(wildfire_name, wildfire_complex_names), collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_max_civil_fatalities = suppressWarnings(max(wildfire_max_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_threatened = suppressWarnings(max(wildfire_struct_threatened, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_injuries = suppressWarnings(max(wildfire_total_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_injuries = suppressWarnings(max(wildfire_civil_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_evacuation = suppressWarnings(max(wildfire_total_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_evacuation = suppressWarnings(max(wildfire_civil_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_cost = suppressWarnings(max(wildfire_cost, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_ignition_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = 'MTBS',
			redbook_id =  paste(unique(na.omit(redbook_id)), collapse = '|') %>% na_if(''),
			ics_id     =  paste(unique(na.omit(ics_id)), collapse = '|') %>% na_if(''),
			fired_id   =  NA_character_,
			mtbs_id    =  paste(unique(na.omit(mtbs_id)), collapse = '|') %>% na_if(''),
			nifc_id    =  NA_character_,
			fema_id    =  paste(unique(na.omit(fema_id)), collapse = '|') %>% na_if(''),
			.groups = 'drop'
		) %>%
		select(-orig_rowid_mtbs)
	
	## Tier 3B: NIFC join on Date/Time/Name ## 
	
	event_t3_long <- event_t3_long %>% 
		filter(!(event_id %in% unlist(t3a$event_id)))
	
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
			event_id = list(event_id),
			wildfire_year = first(wildfire_year_nifc, na_rm = TRUE), # drop event year -- shouldn't be different
			wildfire_area = max(wildfire_area_nifc, na.rm = TRUE),
			wildfire_complex = any(wildfire_complex_event | wildfire_complex_nifc, na.rm = TRUE),
			wildfire_complex_names = dedupe_pipe_delim(paste(c(wildfire_name, wildfire_complex_names), collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_max_civil_fatalities = suppressWarnings(max(wildfire_max_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_threatened = suppressWarnings(max(wildfire_struct_threatened, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_injuries = suppressWarnings(max(wildfire_total_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_injuries = suppressWarnings(max(wildfire_civil_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_evacuation = suppressWarnings(max(wildfire_total_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_evacuation = suppressWarnings(max(wildfire_civil_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_cost = suppressWarnings(max(wildfire_cost, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date, na.rm = TRUE)), 
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_ignition_date, na.rm = TRUE)), 
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = 'NIFC',
			redbook_id =  paste(unique(na.omit(redbook_id)), collapse = '|') %>% na_if(''),
			ics_id     =  paste(unique(na.omit(ics_id)), collapse = '|') %>% na_if(''),
			fired_id   =  NA_character_,
			mtbs_id    =  NA_character_,
			nifc_id    =  paste(unique(na.omit(nifc_id)), collapse = '|') %>% na_if(''),
			fema_id    =  paste(unique(na.omit(fema_id)), collapse = '|') %>% na_if(''),
			.groups = 'drop'
		) %>%
		select(-orig_rowid_nifc)
	
	## Tier 3C: FIRED join on Time/POO ##
	
	event_t3_long <- event_t3_long %>% 
		filter(!(event_id %in% unlist(t3b$event_id)))
	
	
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
			event_id = list(event_id),
			wildfire_year = first(wildfire_year, na_rm = TRUE), 
			wildfire_area = max(wildfire_area_fired),
			wildfire_complex = any(wildfire_complex),
			wildfire_complex_names = dedupe_pipe_delim(paste(wildfire_complex_names, collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_max_civil_fatalities = suppressWarnings(max(wildfire_max_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_threatened = suppressWarnings(max(wildfire_struct_threatened, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_injuries = suppressWarnings(max(wildfire_total_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_injuries = suppressWarnings(max(wildfire_civil_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_evacuation = suppressWarnings(max(wildfire_total_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_evacuation = suppressWarnings(max(wildfire_civil_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_cost = suppressWarnings(max(wildfire_cost, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date_event, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_containment_date_event, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date_event, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = 'FIRED',
			redbook_id =  paste(unique(na.omit(redbook_id)), collapse = '|') %>% na_if(''),
			ics_id     =  paste(unique(na.omit(ics_id)), collapse = '|') %>% na_if(''),
			fired_id   =  paste(unique(na.omit(fired_id)), collapse = '|') %>% na_if(''),
			mtbs_id    =  NA_character_,
			nifc_id    =  NA_character_,
			fema_id    =  paste(unique(na.omit(fema_id)), collapse = '|') %>% na_if(''),
			.groups = 'drop'
		) %>%
		select(-orig_rowid_fired)
	
	### Tier 4: Approximate Burn Zone from ICS POO ###
	
	t4 <- event %>% 
		filter(
			!(event_id %in% c(unlist(t1$event_id), unlist(t2$event_id), unlist(t3a$event_id), unlist(t3b$event_id), unlist(t3c$event_id)))
		) %>%
		mutate(tier = 4, geometry_src = 'ICS209') %>%
		filter(!is.na(wildfire_poo_lat), !is.na(wildfire_poo_lon), !is.na(wildfire_area)) %>%
		mutate(
			radius = sqrt(wildfire_area/pi)*1000
		) %>%
		st_as_sf(coords = c('wildfire_poo_lon', 'wildfire_poo_lat'), remove = FALSE, crs = 4269) %>% 
		st_buffer(.$radius) %>%
		select(-radius, -wildfire_states) %>%
		filter(wildfire_area <= (5284*2))  # cutoff for believability of resulting geometry (twice the largest reported fire between 2000 and 2025: Alaska's Taylor Fire)
		
	t5 <- event %>% 
		filter(
			!(event_id %in% c(unlist(t1$event_id), unlist(t2$event_id), unlist(t3a$event_id), unlist(t3b$event_id), unlist(t3c$event_id)))
		) %>%
		mutate(tier = 4, geometry_src = 'ICS209') %>%
		filter(!is.na(wildfire_poo_lat), !is.na(wildfire_poo_lon), is.na(wildfire_area)) %>%
		st_as_sf(coords = c('wildfire_poo_lon', 'wildfire_poo_lat'), remove = FALSE, crs = 4269) %>% 
		select(-wildfire_states)
	
	### combine and shine
	all_tiers <- bind_rows(
		`MTBS by ID` = t1 %>% mutate(priority = 1),
		`NIFC by ID` = t2 %>% mutate(priority = 2),
		`MTBS by Name/Place/Time` = t3a %>% mutate(priority = 3),
		`NIFC by Name/Place/Time` = t3b %>% mutate(priority = 4),
		`FIRED by Place/Time` = t3c %>% mutate(priority = 5),
		`ICS by Point of Origin, Size` = t4 %>% mutate(event_id = map(event_id, list)) %>% mutate(priority = 6), 
		`ICS by Point of Origin, POO-only` = t5 %>% mutate(event_id = map(event_id, list)) %>% mutate(priority = 7), 
		.id = 'geometry_method'
	) %>%
		mutate(across(where(is.Date), ~if_else(is.infinite(.x), NA_Date_, .x))) %>%
		mutate(temp_id = row_number())
	
	# Final round of deduping (joining disjoint groups into one)
	#   Take geometry from best join, integrate attributes from all available
	all_tiers$wildfire_id <- assign_clusters(all_tiers$event_id)
	all_tiers_sf <- all_tiers %>% select(temp_id, geometry)
	all_tiers <- all_tiers %>%
		st_drop_geometry() %>% # temporarily get rid of geom to play nice with summarize
		group_by(wildfire_id) %>%
		arrange(desc(priority), wildfire_area) %>% 
		summarize(
			temp_id = first(temp_id),
			event_id = list(event_id),
			wildfire_year = first(wildfire_year, na_rm = TRUE), 
			wildfire_area = suppressWarnings(max(wildfire_area)) %>% na_if(Inf),
			wildfire_complex = any(wildfire_complex),
			wildfire_complex_names = dedupe_pipe_delim(paste(wildfire_complex_names, collapse = '|')),
			wildfire_total_fatalities = suppressWarnings(max(wildfire_total_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_fatalities = suppressWarnings(max(wildfire_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_max_civil_fatalities = suppressWarnings(max(wildfire_max_civil_fatalities, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_destroyed = suppressWarnings(max(wildfire_struct_destroyed, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_struct_threatened = suppressWarnings(max(wildfire_struct_threatened, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_injuries = suppressWarnings(max(wildfire_total_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_injuries = suppressWarnings(max(wildfire_civil_injuries, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_total_evacuation = suppressWarnings(max(wildfire_total_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_civil_evacuation = suppressWarnings(max(wildfire_civil_evacuation, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_cost = suppressWarnings(max(wildfire_cost, na.rm = TRUE)) %>% na_if(-Inf),
			wildfire_fema_dec = any(wildfire_fema_dec, na.rm = TRUE),
			wildfire_ignition_date        = suppressWarnings(min(wildfire_ignition_date, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date     = suppressWarnings(min(wildfire_containment_date, na.rm = TRUE)),
			wildfire_ignition_date_max    = suppressWarnings(max(wildfire_ignition_date_max, na.rm = TRUE)), # event only -- see below
			wildfire_containment_date_max = suppressWarnings(max(wildfire_containment_date_max, na.rm = TRUE)),
			wildfire_fema_dec_date        = suppressWarnings(min(wildfire_fema_dec_date, na.rm = TRUE)),
			wildfire_poo_lat = first(wildfire_poo_lat, na_rm = TRUE),
			wildfire_poo_lon = first(wildfire_poo_lon, na_rm = TRUE),
			geometry_src = first(geometry_src),
			redbook_id =  paste(unique(na.omit(redbook_id)), collapse = '|') %>% na_if(''),
			ics_id     =  paste(unique(na.omit(ics_id)), collapse = '|') %>% na_if(''),
			fired_id   =  paste(unique(na.omit(fired_id)), collapse = '|') %>% na_if(''),
			mtbs_id    =  first(mtbs_id),
			nifc_id    =  first(nifc_id),
			fema_id    =  first(fema_id),
			geometry_method = first(geometry_method),
			priority = first(priority)
		) 
		all_tiers <- inner_join(all_tiers_sf, all_tiers, by = 'temp_id') # join the geom back in

	### Add State/County from final geometry

	wildfire_states <- all_tiers %>%
		st_join(spatial_tiger_counties$`2020`) %>%
		st_drop_geometry() %>% 
		filter(STATE_ABB %in% unique(readRDS("data/reference/fips_codes.rds")$STATE_NAME)) %>%
		group_by(wildfire_id) %>% 
		summarize(wildfire_states = paste(unique(STATE_ABB), collapse = '|')) 

	inner_join(all_tiers, wildfire_states, by = 'wildfire_id') %>%
		mutate(
			civ_crit    = if_else(
				coalesce(wildfire_max_civil_fatalities, wildfire_civil_fatalities, 0) > 0 | (is.na(wildfire_max_civil_fatalities) & (coalesce(wildfire_total_fatalities, 0) > 0)), 
				'civilian_death', 
				NA_character_
			),
			struct_crit = if_else(
				coalesce(wildfire_struct_destroyed, 0) > 0, 
				'structures_destroyed', 
				NA_character_
			),
			fema_crit   = if_else(wildfire_fema_dec, 'fema_fmag_declaration', NA_character_)
		) %>%
		unite(wildfire_disaster_criteria_met, c(civ_crit, struct_crit, fema_crit), sep = '|', na.rm = TRUE) %>%
		filter(wildfire_disaster_criteria_met != '') #%>% # when fatalities are the only passing criteria and we know that there were deaths, but no civ deaths
		#select(-event_id)
}

