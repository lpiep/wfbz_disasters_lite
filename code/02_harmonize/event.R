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

	if(FALSE){
	fips <- readRDS('data/reference/fips_codes.rds') %>% mutate(COUNTY_FIPS = substr(COUNTY_FIPS, 3, 5))
	
	event_ics209_long <- event_ics209 %>% # for fires listed in more than one state/county (uses all combos of state/county)
		mutate(ics_county = str_split(ics_county, pattern = '\\|')) %>%
		mutate(ics_state = str_split(ics_state, pattern = '\\|')) %>%
		unnest(cols = c(ics_county)) %>% 
		unnest(cols = c(ics_state))	%>%
		#select(ics_id, ics_wildfire_ignition_date, ics_state, ics_county) %>% 
		inner_join(fips, by = c('ics_state'='STATE_NAME', 'ics_county'='COUNTY_NAME'), relationship = 'many-to-many') # some county names match multiple fips (independent cities)
	
	# Identify fires that are shared between data sets
	dupes <- 
		# Same county name
		inner_join(
			event_fema, #select(event_fema, fema_fema_declaration_string, fema_incident_begin_date, fema_fips_state_code, fema_fips_county_code),
			event_ics209_long,
			by = c('fema_state_code'='STATE_FIPS', 'fema_county_code'='COUNTY_FIPS'), 
			relationship = "many-to-many",
			suffix = c('_fema', '_ics209')
		) %>% 
			# and within 30 days of each other
			mutate(began_delta = as.numeric(wildfire_ignition_date_fema - wildfire_ignition_date_ics209)) %>%
			filter(began_delta >= -30 & began_delta <= 30) %>%
			# and similar name
			filter(
				stringdist(wildfire_name_ics209, wildfire_name_fema, method = 'jw', p = .1) <= .25 # threshold chosen by inspection
			) 
	}
	# Harmonize variables with more than one data point

	# need to figure out how to collapse by both ICS id AND FEMA id where any overlap becomes a single row
	## thoughts here: ##
	# library(tidygraph)
	# library(tidyverse)
	# 
	# # Sample data
	# df <- data.frame(
	# 	ID1 = c(1, 2, 3, 4, 5, 6, 6, 7),
	# 	ID2 = c(2, 3, 4, 5, 6, 7, 8, 8)
	# )
	# 
	# # Create a tidygraph object from the edge list
	# graph <- as_tbl_graph(df, directed = FALSE)
	# 
	# # Find connected components
	# 
	# graph <- graph %>%
	# 	mutate(group = group_components(type = "weak"))
	# 
	# # Add the group membership back to the original data
	# df_grouped <- graph %>%
	# 	activate(edges) %>%
	# 	as_tibble() %>%
	# 	left_join(
	# 		graph %>%
	# 			activate(nodes) %>%
	# 			as_tibble() %>%
	# 			select(node = name, group),
	# 		by = c("from" = "node")
	# 	) %>%
	# 	select(ID1 = from, ID2 = to, Group = group)
	# 
	# # View the result
	# print(df_grouped)
}