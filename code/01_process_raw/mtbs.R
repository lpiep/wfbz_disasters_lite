# Description -------------------------------------------------------------

# Author: Benjamin Steiger
# Date: 02/15/2023
# Last Update: 06/18/2024 Logan Piepmeier to attempt years after 2019
# Goal: Clean MTBS Fire Perimeter Dataset for Matching to Disaster Data, 2000-present
# ------------------
	
clean_mtbs <- function(spatial_mbts_raw){ 
		
	# raw MTBS Burned Areas Boundaries Dataset
	mtbs_all_years <- st_read(spatial_mbts_raw)
	
	#28982
	
	# Convert all column names to snakecase ----------------------------------
	
	names(mtbs_all_years) <- to_snake_case(names(mtbs_all_years))
	
	# Paste "mtbs_ " to all column names except the geometric column------------------------------------
	
	column_names <- setdiff(names(mtbs_all_years), c("shape"))
	
	mtbs_all_years <- mtbs_all_years %>%
		rename_at(vars(all_of(column_names)), ~ paste0("mtbs_", .))
	
	rm(column_names)
	
	# rename "geometry" column "shape" ----------------------------------------
	
	mtbs_all_years <- st_set_geometry(mtbs_all_years, "shape")
	
	# Select variables --------------------------------------------------------
	
	mtbs_all_years<-mtbs_all_years%>%
		select(mtbs_event_id, 
					 mtbs_incid_name,
					 mtbs_incid_type,
					 mtbs_burn_bnd_ac,
					 mtbs_burn_bnd_lat,
					 mtbs_burn_bnd_lon,
					 mtbs_ig_date)
	
	
	# Make ig_date a date -----------------------------------------------------
	
	mtbs_all_years <- mtbs_all_years %>%
		mutate(mtbs_ig_date = as.Date(as.character(mtbs_ig_date), format = "%Y-%m-%d"))
	
	# Extract year from ig_date -----------------------------------------------
	
	mtbs_all_years <- mtbs_all_years %>%
		mutate(mtbs_year = year(mtbs_ig_date)) 
	
	# Validate all the geometries -------------------------------------------
	
	#invalid_index <- which(!st_is_valid(mtbs_all_years)) #154
	
	mtbs_all_years <- st_make_valid(mtbs_all_years)
	
	#table(st_geometry_type(mtbs_all_years)) #28982 are multipolygon
	
	# Filter to 2000-pres  ----------------------------------------------------
	
	mtbs_2000_pres <- mtbs_all_years %>%
		filter(mtbs_year >= 2000)
	#20644
	
	# Remove mtbs_all_years -------------------------------------------------------------
	
	rm(mtbs_all_years)
	
	# Change all character columns to uppercase -------------------------------
	
	mtbs_2000_pres <- mtbs_2000_pres %>%
		mutate(across(where(is.character), toupper))
	
	# Filter out prescribed burns ----------------------------------
	
	mtbs_2000_pres <- mtbs_2000_pres %>%
		filter(mtbs_incid_type != "PRESCRIBED FIRE")
	#13966
	
	# Validate all the geometries -------------------------------------------
	
	#invalid_index <- which(!st_is_valid(mtbs_all_years)) #154
	
	mtbs_2000_pres <- st_make_valid(mtbs_2000_pres)
	
	#table(st_geometry_type(mtbs_all_years)) #28982 are multipolygon
	
	# Create NAD83 CONUS projection string ------------------------------------------

	mtbs_2000_pres <-
		st_transform(mtbs_2000_pres, crs = 4269)
	
	
	# remove nad83 string -----------------------------------------------------
	
	rm(nad83_proj_conus)
	
	# Calculate st_area in square meters and in acres ------------------------------------------------------
	
	mtbs_2000_pres <- mtbs_2000_pres %>%
		mutate(
			mtbs_st_area_sq_m = st_area(shape),
			mtbs_st_area_sq_m=as.numeric(mtbs_st_area_sq_m))
	
	# Calculate st_area in acres ------------------------------------------------------
	
	mtbs_2000_pres<-mtbs_2000_pres%>%
		mutate(
			mtbs_st_area_acre=mtbs_st_area_sq_m/4046.8564224,
			mtbs_st_area_acre=as.numeric(mtbs_st_area_acre))
	
	# I'm having an issue with this part of the code
	
	# Extract state from event_id ---------------------------------------------
	
	mtbs_2000_pres <- mtbs_2000_pres %>%
		mutate(mtbs_state = substr(mtbs_event_id, start = 1, stop = 2))
	

	# Create mtbs_fire_name_standardized column -------------------------------
	
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
	
	mtbs_2000_pres <- mtbs_2000_pres %>%
		mutate(mtbs_fire_name_standardized = standardize_place_name(mtbs_incid_name))
	
	# Create mtbs_complex_name column --------------------------------------
	
	mtbs_2000_pres <- mtbs_2000_pres %>%
		mutate(mtbs_complex_name = if_else(str_detect(mtbs_fire_name_standardized,
																									"COMPLEX"),
																			 mtbs_fire_name_standardized, NA_character_))
	
	# remove "complex" from fire_name_match
	
	mtbs_2000_pres <- mtbs_2000_pres %>%
		mutate(mtbs_fire_name_standardized = str_remove_all(mtbs_fire_name_standardized, "COMPLEX"))
	
	# Trim white space from all data -------------------------------
	
	mtbs_2000_pres <- mtbs_2000_pres %>% 
		mutate(across(where(is.character), str_trim),
					 across(where(is.character), str_squish))
	
	
	# create an edited complex name variable ----------------------------------
	
	mtbs_2000_pres<-mtbs_2000_pres%>%
		mutate(mtbs_complex_name_standardized=gsub(" COMPLEX", "", mtbs_complex_name))
	
	# Select columns ----------------------------------------------------------
	
	mtbs_2000_pres <- mtbs_2000_pres %>%
		dplyr::select(
			mtbs_year,
			mtbs_state,
			mtbs_event_id,
			mtbs_incid_name,
			mtbs_fire_name_standardized,
			mtbs_complex_name_standardized,
			mtbs_ig_date,
			mtbs_st_area_sq_m,
			mtbs_st_area_acre,
			shape
		)
	
	return(mtbs_2000_pres)
}