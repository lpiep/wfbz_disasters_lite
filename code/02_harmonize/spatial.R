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
		spatial_tiger
){

	event <- event %>% mutate(
		tier = case_when(
			irwin_id %in% na.omit(spatial_mtbs$irwin_id) ~ 1,
			irwin_id %in% na.omit(spatial_nifc$irwin_id) ~ 2,
			TRUE ~ 3
		)
	)
	
	### Tier 1: Match MTBS by ID ###
	t1 <- spatial_mtbs %>% 
		inner_join(filter(event, tier == 1), by = 'irwin_id', relationship = 'one-to-many', suffix = c('_mtbs', '_event')) %>%
		group_by(irwin_id, wildfire_ignition_date_mtbs) %>%
		summarize(
			wildfire_year = first(wildfire_year),
			#wildfire_states = paste(na.omit(wildfire_states), collapse = '|'),
			#wildfire_counties = paste(na.omit(wildfire_counties), collapse = '|'),
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
			wildfire_poo_lat = first(wildfire_poo_lat),
			wildfire_poo_lon = first(wildfire_poo_lon),
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
			wildfire_ignition_date = pmin(wildfire_ignition_date_max, wildfire_ignition_date_mtbs, na.rm = TRUE),
			wildfire_ignition_date_max = pmax(wildfire_ignition_date_max, wildfire_ignition_date_mtbs, na.rm = TRUE)
		) %>% 
		select(-wildfire_ignition_date_mtbs)
	
	### Tier 2: Match NIFC by ID ###
	t2 <- spatial_nifc %>% 
		inner_join(filter(event, tier == 2), by = 'irwin_id', relationship = 'one-to-many', suffix = c('_nifc', '_event')) %>%
		group_by(irwin_id) %>%
		summarize(
			wildfire_year = first(wildfire_year_nifc), # drop event year -- shouldn't be different
			#wildfire_states = paste(na.omit(wildfire_states), collapse = '|'),
			#wildfire_counties = paste(na.omit(wildfire_counties), collapse = '|'),
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
			wildfire_poo_lat = first(wildfire_poo_lat),
			wildfire_poo_lon = first(wildfire_poo_lon),
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
	
	## Tier 3A: MTBS ##
	st_drop_geometry(append_county(spatial_mtbs)) 
	
	## Tier 3B: FIRED ##
	
	### Tier 3C: Approximate Burn Zone from ICS POO ###
	
	### Add State/County from final geometry
	
}

