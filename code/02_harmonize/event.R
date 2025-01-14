# --------------------------------
# Description: 
# Date: 
#
# Logan Piepmeier
# --------------------------------

harmonize_event <- function(
		event_fema,
		event_ics209
){
	
	# ALL combinations where dates are within 30 days of each other
	temporal_candidates <- cross_join(
		select(event_fema, fema_fema_declaration_string, fema_incident_begin_date, fema_fips_state_code, fema_fips_county_code),
		select(event_ics209, ics_id, ics_wildfire_ignition_date, ics_state, ics_county)
	) %>% 
		mutate(began_delta = as.numeric(fema_incident_begin_date - ics_wildfire_ignition_date)) %>%
		filter(began_delta >= -30 & began_delta <= 30)
	
	## IN PROGRESS 
	# County Candidates
	fips <- readRDS('data/reference/fips_codes.rds')
	event_ics209 <- event_ics209 %>%
		mutate(ics_county = str_split(ics_county, pattern = '\\|')) %>%
		unnest(cols = c(ics_county)) %>%
		left_join(fips, by = c('ics_state'='STATE_NAME', 'ics_county'='COUNTY_NAME'), relationship = 'many-to-many') # some county names match multiple fips (independent cities)
}