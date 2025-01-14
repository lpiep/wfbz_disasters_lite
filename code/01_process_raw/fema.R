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
		filter(incidentType == 'Fire') %>%
		filter(incidentBeginDate >= ymd("2000-01-01")) %>% 
		mutate( # Disaggregate Area (usually county or equivalent) name from type -- mark native areas as "AIAN Area" and take their place name as is 
			designatedArea_name = na_if(designatedArea, 'Statewide'),
			designatedArea_name = str_extract(designatedArea, '.*(?=\\()'),
			designatedArea_type = str_extract(designatedArea, '(?<=\\().*(?=\\))'),
			designatedArea_type = if_else(str_detect(designatedArea, '(Tribe|Reservation|ANV)') | tribalRequest == 1, 'AIAN Area', designatedArea_type),
			designatedArea_name = if_else(str_detect(designatedArea, '(Tribe|Reservation|ANV)') | tribalRequest == 1, designatedArea, designatedArea_name)
		) %>%
		mutate( # Standardize the fire name
			declarationTitle_standardized = standardize_place_name(declarationTitle)
		) %>%
		mutate(across(matches('Date'), as.Date)) # convert datetime cols to date
	
	names(fema_all) <- paste0('fema_', to_snake_case(names(fema_all))) 
	fema_all
}
	
clean_fema_OLD <- function(event_fema_raw){
	fema_all <- read_csv(tar_read(event_fema_raw)) %>%

	
	# Convert all column names to snake case ----------------------------------
	
	names(fema_all) <- to_snake_case(names(fema_all))
	
	
	# Convert all character columns to uppercase ------------------------------
	
	fema_all <- fema_all %>%
		mutate(across(where(is.character), toupper))
	
	# Filter to 2000-pres ----------
	
	fm_2000_pres <- fema_all %>%
		filter(
			incident_begin_date >= "2000-01-01" 
		)

	
	# remove fema_all ---------------------------------------------------------
	
	rm (fema_all)
	
	# Filter to FM declarations -----------------------------------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		filter(
			declaration_type == "FM"
		)

	# Remove anything in parentheses from designated_area ------------------------------------
	
	# this will remove (COUNTY), (BOROUGH), (PARISH), etc.
	fm_2000_pres <- fm_2000_pres %>%
		mutate(
			designated_area_backup = designated_area,
			designated_area = gsub("\\([^\\)]+\\)", "", designated_area)
		)
	
	# Convert date variables to dates -----------------------------------------
	# consider moving this up before creating declaration year
	fm_2000_pres <- fm_2000_pres %>%
		mutate_at(
			c(
				'declaration_date',
				'incident_begin_date',
				'incident_end_date',
				'disaster_closeout_date'
			),
			as.Date
		)
	# Create declaration year variable -------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(declaration_year = year(declaration_date))
	
	# Convert disaster number and declaration year to factor ------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate_at(c('declaration_year',
								'disaster_number'),
							as.factor)
	
	
	# create fire name match variable -----------------------------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(fire_name_match = declaration_title)
	
	# Remove spaces before and after hyphens in fire_name_match variab --------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(
			fire_name_match = gsub("\\s*-\\s*", "-", fire_name_match))
	
	# Remove "wildfire" and "fire" from fire_name_match ------------------------------------------------
	
	# Remove "FIRES", "FIRE", WILDFIRE", "-FIRE", and "-WILDFIRE" from the declaration name
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(
			fire_name_match =
				str_remove_all(
					fire_name_match,
					"-WILDFIRE|WILDFIRES|WILDFIRE|-FIRES|-FIRE|FIRES|FIRE"))
	
	# Remove state from fire_name_match --------
	
	# if the first two letters are the state
	# and the third character is a space, dash, or comma
	# remove the first three characters
	# don't remove if it's "MT " or "LA " because MT could be MOUNT
	# and LA could be LA as in LA PERLA
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(
			fire_name_match = ifelse(
				substr(fire_name_match, 1, 2) == state &
					substr(fire_name_match, 3, 3) %in% c(" ", "-", ",") &
					substr(fire_name_match, 1, 3) != "MT |LA " ,
				substring(fire_name_match, first = 4),
				fire_name_match
			)
		)
	
	
	# Remove extra white space from fire_name_match ----------------------------------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(fire_name_match = trimws(fire_name_match, "b"))
	
	# Make patterns of dates ------------------------------------------------------------
	
	# use this value to detect dates with hyphens in fire_name_match
	
	date_pattern_hyphen <-
		' ?(0|1)?[0-9]-([0-9]{4}|[0-9]{2}|[1-9]{1})-([0-9]{4}|[0-9]{2}) ?'
	
	# use this value to detect dates with slashes in fire_name_match
	
	date_pattern_slash  <-
		' ?(0|1)?[0-9]/([0-9]{4}|[0-9]{2}|[1-9]{1})/([0-9]{4}|[0-9]{2}) ?'
	
	# Replace "--" with "-" in fire_name_match ------------------------------
	
	# This standardizes dates in fire_name_match that have a double hyphen
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(fire_name_match = str_replace(fire_name_match, "--", "-"))
	
	# Remove dates from fire_name_match -------------------------------------
	
	# Remove dates with slashes and hyphens
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(
			fire_name_match = str_remove_all(fire_name_match, date_pattern_hyphen),
			fire_name_match = str_remove_all(fire_name_match, date_pattern_slash),
			fire_name_match = str_remove(fire_name_match, "-0823-00"),
			fire_name_match = str_remove(fire_name_match, "-JULY 23")
		)
	
	# Remove date patterns from environment -----------------------------------
	
	rm(date_pattern_hyphen,date_pattern_slash)
	
	# Fix abbreviations ----------------------------------
	
	# change "MTN" to "MOUNTAIN"
	# change "MT" to "MOUNT"
	# change "HWY" to "HIGHWAY"
	# Remove "#" symbol
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(
			fire_name_match = gsub('HWY', 'HIGHWAY', fire_name_match),
			fire_name_match = gsub('MTN', 'MOUNTAIN', fire_name_match),
			fire_name_match = gsub('MT ', 'MOUNT ', fire_name_match),
			fire_name_match = str_replace(fire_name_match, "#", "")
		)
	
	# Remove white space in fire_name_match ------------------------------------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(fire_name_match = trimws(fire_name_match, "b"))
	
	# Remove year from fire name match variable ---------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(
			fire_name_match = str_remove_all(
				fire_name_match,
				as.character(declaration_year))
		)
	
	# Remove declaration string number ----------------------------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(
			fire_name_match = str_remove_all(fire_name_match, as.character(disaster_number))
		)
	
	# Remove white space in fire_name_match ------------------------------------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(fire_name_match = trimws(fire_name_match, "b"))
	
	# Remove hyphens at the end of fire_name_match ----------------------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(fire_name_match = sub("-$", "", fire_name_match))
	
	# Remove hyphens at the end of fire_name_match ----------------------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(fire_name_match = sub("^-", "", fire_name_match))
	
	# Remove parentheses from fire_name_match when appropriate -------------------------------
	
	# There are a few declaration names that are in parentheses.
	# This code identifies declaration names that start with an open parenthesis.
	# Then it removes the first and last character of fire_name_match name
	# (both of which are parentheses).
	# If fire_name_match doesn't start with "(", fire_name_match stays as is.
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(fire_name_match = if_else(
			substr(fire_name_match, start = 1, stop = 1) == "(",
			gsub('^.|.$', '', fire_name_match),
			fire_name_match
		))
	
	
	# Create Complex Name variable --------------------------------------------
	
	fm_2000_pres <-
		fm_2000_pres %>%
		mutate(complex_name = case_when(str_detect(fire_name_match, "COMPLEX") ~ fire_name_match))
	
	# Remove "COMPLEX" from fire_name_match -----------------------------------
	
	fm_2000_pres <-
		fm_2000_pres %>%
		mutate(fire_name_match = str_remove_all(fire_name_match, "COMPLEX"))
	
	# Remove all extra whitespace ---------------------------------------------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(across(where(is.character), str_squish),
					 across(where(is.character), str_trim))
	
	# Remove comma (or special characters) at end of fire_name_match ----------
	
	fm_2000_pres <- fm_2000_pres %>%
		mutate(fire_name_match = sub(",$", "", fire_name_match))
	
	# remove extra spaces between slashes -------------------------------------
	
	# standardize numbers for zones? standardize slashes vs dashes?
	
	# Paste "fema_" before all columns ----------------------------------------
	
	names(fm_2000_pres) <-
		paste0("fema_", names(fm_2000_pres))
	
	# Rename fema_declaration string to remove extra "fema" title ------------
	
	fm_2000_pres <- fm_2000_pres %>%
		rename(fema_declaration_string = fema_fema_declaration_string)
	
	
	# Filter to unique FM declaration only -----------------------------------
	
	fm_2000_pres_all_counties<-fm_2000_pres
	
	fm_2000_pres <- fm_2000_pres %>%
		filter(!duplicated(fema_declaration_string)) 
	
	fm_2000_pres
}