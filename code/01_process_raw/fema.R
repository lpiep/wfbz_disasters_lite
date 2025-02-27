clean_fema <- function(event_fema_raw){
	fema_all <- read_csv(
			event_fema_raw, 
			col_types = cols_only(
				femaDeclarationString = col_character(),
				disasterNumber = col_character(),
				state = col_character(),
				declarationType = col_character(),
				declarationDate = col_datetime(),
				incidentType = col_character(),
				declarationTitle = col_character(),
				incidentBeginDate = col_datetime(),
				incidentEndDate = col_datetime(),
				tribalRequest = col_logical(),
				designatedArea = col_character(),
				fipsStateCode = col_character(),
				fipsCountyCode = col_character(),
				lastRefresh = col_datetime()
			)
		) %>%
		filter(incidentType == 'Fire' & declarationType == 'FM') %>%
		select(-declarationType) %>%
		filter(incidentBeginDate >= ymd("2000-01-01")) %>% 
		# mutate( # Disaggregate Area (usually county or equivalent) name from type -- mark native areas as "AIAN Area" and take their place name as is 
		# 	designatedArea_name = na_if(designatedArea, 'Statewide'),
		# 	designatedArea_name = str_extract(designatedArea, '.*(?=\\()'),
		# 	designatedArea_type = str_extract(designatedArea, '(?<=\\().*(?=\\))'),
		# 	designatedArea_type = if_else(str_detect(designatedArea, '(Tribe|Reservation|ANV)') | tribalRequest == 1, 'AIAN Area', designatedArea_type),
		# 	designatedArea_name = if_else(str_detect(designatedArea, '(Tribe|Reservation|ANV)') | tribalRequest == 1, designatedArea, designatedArea_name)
		# ) %>%
		mutate( # Standardize the fire name
			declarationTitle = standardize_place_name(str_trim(declarationTitle))
		) %>%
		mutate(across(matches('Date'), as.Date)) # convert datetime cols to date
	
	fips <- readRDS('data/reference/fips_codes.rds')
	
	fema_all <- fema_all %>% 
		mutate(COUNTY_FIPS = paste0(fipsStateCode, fipsCountyCode)) %>%
		left_join(fips, by = 'COUNTY_FIPS')

	fema_all <- fema_all %>%
		transmute(
			fema_id = femaDeclarationString,
			wildfire_states = state,
			wilfire_year = year(declarationDate),
			wildfire_fema_dec_date = declarationDate,
			wildfire_name = declarationTitle,
			wildfire_ignition_date = incidentBeginDate,
			wildfire_containment_date = incidentEndDate ,
			wildfire_counties = COUNTY_NAME
		)

	fema_all
}
