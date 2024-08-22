# Description -------------------------------------------------------------

# Author: Benjamin Steiger
# Date: 04/27/2023
# Last Update: 06/24/2024 # Logan Piepmeier changed to function and to go through present
# Goal: Create Cleaned NIFC Interagency All Years Perimeter File, 2000-pres

clean_nifc <- function(spatial_nifc_raw){
	# Interagency All Years Perimeters
	nifc_all_years <- st_read(spatial_nifc_raw)
	
	# fix year variable -------------------------------------------------------
	
	nifc_all_years%>%filter(FIRE_YEAR!=FIRE_YEAR_)%>%nrow()
	
	nifc_all_years<-nifc_all_years%>%select(-FIRE_YEAR_)
	
	# Convert all column names to snakecase ----------------------------------
	
	names(nifc_all_years) <- snakecase::to_snake_case(names(nifc_all_years))
	
	# Paste "nifc_ " to all column names except the geometric column------------------------------------
	
	column_names <- setdiff(names(nifc_all_years), c("geometry"))
	
	nifc_all_years <- nifc_all_years %>%
		rename_at(vars(all_of(column_names)), ~ paste0("nifc_", .))
	
	rm(column_names)
	
	# Select variables --------------------------------------------------------
	
	nifc_all_years <- nifc_all_years %>%
		dplyr::select(
			nifc_fire_year,
			nifc_date_cur,
			nifc_irwinid,
			nifc_unqe_fire,
			nifc_local_num,
			nifc_unit_id,
			nifc_incident,
			nifc_gis_acres,
			nifc_comments,
			geometry
		)
	
	# make year numeric -------------------------------------------------------
	
	nifc_all_years<-nifc_all_years%>%
		mutate(nifc_fire_year=as.numeric(nifc_fire_year))
	
	# Reproject to NAD83 CONUS ------------------------------------------------------
	
	nifc_all_years <-
		st_transform(nifc_all_years, crs = 4269)
	
	# Calculate acreage using st_area -----------------------------------------
	
	nifc_all_years <- nifc_all_years %>%
		mutate(nifc_st_area_sq_m = st_area(st_make_valid(geometry)),
					 nifc_st_area_sq_m = as.numeric(nifc_st_area_sq_m))
	
	# Calculate acreage using st_area -----------------------------------------
	
	nifc_all_years<-nifc_all_years%>%
		mutate(
			nifc_st_area_sq_acre=nifc_st_area_sq_m/4046.8564224,
			nifc_st_area_sq_acre=as.numeric(nifc_st_area_sq_acre))
	
	# Convert year to factor -------------------------------------
	
	nifc_all_years <- nifc_all_years %>%
		mutate_at(c('nifc_fire_year'), as.factor)
	
	# Remove brackets from unqe_fire id --------------------------------------
	
	nifc_all_years <- nifc_all_years %>%
		mutate(nifc_unqe_fire = str_remove_all(nifc_unqe_fire, "\\{"),
					 nifc_unqe_fire = str_remove_all(nifc_unqe_fire, "\\}"))
	
	# create state variable ---------------------------------------------------
	
	# change any "NA" to NA in unqe_fire
	
	nifc_all_years <- nifc_all_years %>%
		mutate(nifc_unqe_fire = gsub("NA", NA, nifc_unqe_fire))
	
	# when unqe_fire contains alphabetic characters, extract the 6th and 7th characters in the string
	
	nifc_all_years <- nifc_all_years %>%
		mutate(nifc_state_from_id = 
					 	case_when(
					 		str_detect(nifc_unqe_fire, "[[:alpha:]]") ~ substr(nifc_unqe_fire, 6, 7),
					 		TRUE ~ NA_character_
					 	)
		)
	
	# create state abbreviation vector
	
	state_abbreviations <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
													 "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
													 "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
													 "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
													 "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
	
	# if state is not in the state_abbreviations vector, then change to NA
	
	nifc_all_years <- nifc_all_years %>%
		mutate(nifc_state_from_id = if_else(nifc_state_from_id %in% state_abbreviations, nifc_state_from_id, NA_character_))
	
	# create a row number id for nifc -----------------------------------------
	
	nifc_all_years<-nifc_all_years%>%
		mutate(row_num=row_number())
	
	
	# Make all character columns uppercase ------------------------------------
	
	nifc_all_years <- nifc_all_years %>%
		mutate(across(where(is.character), toupper))
	
	# Create new incident name column -----------------------------------------
	
	nifc_all_years <- nifc_all_years %>%
		mutate(nifc_incident_name_match = nifc_incident)
	
	# Edit incident name ------------------------------------------------------
	
	# remove all mention of fire and wildfire
	# change "MTN" to "MOUNTAIN"
	# change "HWY" to "HIGHWAY"
	# change "RD" to "ROAD"
	# change "MT" to "MOUNT"
	# change "MP" to "MILE POST"
	# change "MILEPOST" to "MILE POST"
	# change "CR." to "CREEK"
	# remove "." and "#"
	# change "MM" and "MILEMARKER" to "MILE MARKER"
	# change "AVE" to "AVENUE"
	# change complex string variations to "COMPLEX"
	
	nifc_all_years <- nifc_all_years %>%
		mutate(
			nifc_incident_name_match = str_remove_all(nifc_incident_name_match, 
																								"FIRES|FIRE|WILDFIRE|-FIRE|-WILDFIRE|WF | WF -"),
			nifc_incident_name_match = gsub('HWY', 'HIGHWAY ', nifc_incident_name_match),
			nifc_incident_name_match = gsub('MTN', 'MOUNTAIN', nifc_incident_name_match),
			nifc_incident_name_match = gsub('MTN[.]', 'MOUNTAIN', nifc_incident_name_match),
			nifc_incident_name_match = gsub(' RD', ' ROAD', nifc_incident_name_match),
			nifc_incident_name_match = gsub('MT ', 'MOUNT ', nifc_incident_name_match),
			nifc_incident_name_match = gsub(' MT', ' MOUNTAIN', nifc_incident_name_match),
			nifc_incident_name_match = gsub('MILEPOST', 'MILE POST', nifc_incident_name_match),
			nifc_incident_name_match = if_else(substr(nifc_incident_name_match,
																								1,2)=="MP",
																				 gsub('MP ','MILE POST ',nifc_incident_name_match),
																				 nifc_incident_name_match),
			nifc_incident_name_match = gsub(' MM ', ' MILE MARKER ', nifc_incident_name_match),
			nifc_incident_name_match = gsub('MILEMARKER', 'MILE MARKER ', nifc_incident_name_match),
			nifc_incident_name_match = if_else(substr(nifc_incident_name_match,
																								1,2)=="MM",
																				 gsub('MM','MILE MARKER ', nifc_incident_name_match),
																				 nifc_incident_name_match),
			nifc_incident_name_match = gsub('_', ' ', nifc_incident_name_match),
			nifc_incident_name_match = if_else(str_detect(nifc_incident_name_match,
																										"MM[0-9]"),
																				 gsub('MM','MILE MARKER ', nifc_incident_name_match),
																				 nifc_incident_name_match),
			nifc_incident_name_match = str_remove_all(nifc_incident_name_match, "\\."),
			nifc_incident_name_match = str_remove_all(nifc_incident_name_match, "\\#"),
			nifc_incident_name_match = gsub("CX|CMPLX", "COMPLEX", nifc_incident_name_match)
		)
	
	# Create complex name -----------------------------------------------------
	
	# use variety of complex strings
	
	nifc_all_years <- nifc_all_years %>%
		mutate(nifc_complex_name = case_when(str_detect(nifc_incident_name_match, "COMPLEX|CPLX|CX|CMP|CMPL|CMPLX|COMPL|COMPL|COMPLE|COMPLX|COMLX|CLX|CPX|-COM[.]") ~ nifc_incident_name_match))
	
	# Repeat edits to incident name in complex name ---------------------------
	
	# remove all mention of fire and wildfire
	# change "MTN" to "MOUNTAIN"
	# change "HWY" to "HIGHWAY"
	# change "RD" to "ROAD"
	# change "MT" to "MOUNT"
	# change "MP" to "MILE POST"
	# change "MILEPOST" to "MILE POST"
	# change "CR." to "CREEK"
	# remove "." and "#"
	# change "MM" and "MILEMARKER" to "MILE MARKER"
	# change "AVE" to "AVENUE"
	
	nifc_all_years <- nifc_all_years %>%
		mutate(
			nifc_complex_name = str_remove_all(nifc_complex_name, 
																				 "FIRES|FIRE|WILDFIRE|-FIRE|-WILDFIRE|WF | WF -"),
			nifc_complex_name = gsub('HWY', 'HIGHWAY ', nifc_complex_name),
			nifc_complex_name = gsub('MTN', 'MOUNTAIN', nifc_complex_name),
			nifc_complex_name = gsub('MTN[.]', 'MOUNTAIN', nifc_complex_name),
			nifc_complex_name = gsub(' RD', ' ROAD', nifc_complex_name),
			nifc_complex_name = gsub('MT ', 'MOUNT ', nifc_complex_name),
			nifc_complex_name = gsub(' MT', ' MOUNTAIN', nifc_complex_name),
			nifc_complex_name = gsub('MILEPOST', 'MILE POST', nifc_complex_name),
			nifc_complex_name = if_else(substr(nifc_complex_name,
																				 1,2)=="MP",
																	gsub('MP ','MILE POST ',nifc_complex_name),
																	nifc_complex_name),
			nifc_complex_name = gsub(' MM ', ' MILE MARKER ', nifc_complex_name),
			nifc_complex_name = gsub('MILEMARKER', 'MILE MARKER ', nifc_complex_name),
			nifc_complex_name = if_else(substr(nifc_complex_name,
																				 1,2)=="MM",
																	gsub('MM','MILE MARKER ', nifc_complex_name),
																	nifc_complex_name),
			nifc_complex_name = gsub('_', ' ', nifc_complex_name),
			nifc_complex_name = if_else(str_detect(nifc_complex_name,
																						 "MM[0-9]"),
																	gsub('MM','MILE MARKER ', nifc_complex_name),
																	nifc_complex_name),
			nifc_complex_name = str_remove_all(nifc_complex_name, "\\."),
			nifc_complex_name = str_remove_all(nifc_complex_name, "\\#"))
	
	# remove complex strings from incident_name_match
	
	nifc_all_years <- nifc_all_years %>%
		mutate(nifc_incident_name_match = str_remove_all(nifc_incident_name_match, "COMPLEX|CPLX|CX|CMP|CMPL|CMPLX|COMPL|COMPL|COMPLE|COMPLX|COMLX|CLX|CPX|-COM[.]"))
	
	# Trim white space from all data -------------------------------
	
	nifc_all_years <- nifc_all_years %>% 
		mutate(across(where(is.character), str_trim),
					 across(where(is.character), str_squish))
	
	# check for duplicates --------------------------------------------------------
	
	duplicate_rows <- nifc_all_years[
		duplicated(nifc_all_years$row_num) | 
			duplicated(nifc_all_years$row_num, fromLast = TRUE), ] #821
	
	# select variables --------------------------------------------------------
	
	nifc_all_years <- nifc_all_years %>%
		dplyr::select(
			nifc_fire_year,
			nifc_state_from_id,
			nifc_irwinid,
			nifc_unqe_fire,
			nifc_local_num,
			nifc_unit_id,
			nifc_incident,
			nifc_incident_name_match,
			nifc_complex_name,
			nifc_st_area_sq_acre,
			nifc_st_area_sq_m,
			nifc_date_cur,
			nifc_comments,
			geometry
		)
	nifc_all_years
# note: the date variable is a reference to the last time the date was edited
}
