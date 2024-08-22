# Description -------------------------------------------------------------

# Author: Benjamin Steiger
# Date: 06/13/2023
# Last Update: 06/18/2024 # Logan Piepmeier changed to function and to go through present
# Goal: Clean FIRED CONUS-AK Perimeter Dataset for Matching to Disaster Data, 2000-Present

#-----------------------------------------

clean_fired <- function(spatial_fired_raw){
	
	fired_all_years <- st_read(fs::dir_ls(spatial_fired_raw, regexp = 'daily.*gpkg$')[1])
	fired_all_years <- st_set_geometry(fired_all_years, "geometry")
	
	# Paste "fired_ " to all column names except the geometric column------------------------------------
	
	column_names <- setdiff(names(fired_all_years), c("geometry"))
	
	
	fired_all_years <- fired_all_years %>%
		rename_at(vars(all_of(column_names)), ~ paste0("fired_", .))
	
	rm(column_names)
	
	
	
	
	# select variables --------------------------------------------------------
	fired_all_years<-fired_all_years%>%
		select(fired_id, 
					 fired_ig_date,
					 fired_ig_year,
					 fired_last_date,
					 fired_event_dur
		)
	
	# Make ig_date and last_date Y-M-D dates -----------------------------------------------------
	
	fired_all_years <- fired_all_years %>%
		mutate(ig_date = as.Date(as.character(fired_ig_date), format = "%Y-%m-%d"),
					 last_date = as.Date(as.character(fired_last_date), format = "%Y-%m-%d"))
	
	# Filter to 2000-pres  ----------------------------------------------------
	
	fired_2000_pres <- fired_all_years %>%
		filter(fired_ig_year >= 2000) #98723
	
	rm(fired_all_years)
	
	# validate all the geometries -------------------------------------------
	
	#invalid_index <- which(!st_is_valid(fired_2000_pres)) #154
	
	fired_2000_pres <- st_make_valid(fired_2000_pres)
	
	#table(st_geometry_type(fired_2000_pres))
	
	# Create NAD83 CONUS projection string ------------------------------------------
	
	#epsg: 102003 - NAD83 CONUS with meters unit
	
	nad83_proj_conus <-
		"+proj=aea +lat_0=37.5 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +type=crs"
	
	# Reproject to NAD83 CONUS ------------------------------------------------------
	
	fired_2000_pres <-
		st_transform(fired_2000_pres, crs = nad83_proj_conus)
	
	# remove nad83 string -----------------------------------------------------
	
	rm(nad83_proj_conus)
	
	# Calculate st_area in square meters and in acres ------------------------------------------------------
	
	fired_2000_pres <- fired_2000_pres %>%
		mutate(
			fired_st_area_sq_m = st_make_valid(geometry) %>%
				st_area(),
			fired_st_area_sq_m=as.numeric(fired_st_area_sq_m))
	
	# Calculate st_area in acres ------------------------------------------------------
	
	fired_2000_pres<-fired_2000_pres%>%
		mutate(
			fired_st_area_sq_acre=fired_st_area_sq_m/4046.8564224,
			fired_st_area_sq_acre=as.numeric(fired_st_area_sq_acre)
		)
	
	
	# make fired id a factor --------------------------------------------------
	
	fired_2000_pres<-
		fired_2000_pres%>%
		mutate(fired_id=as.factor(fired_id))
	
	# Select variables --------------------------------------------------------
	
	fired_2000_pres <- fired_2000_pres %>%
		dplyr::select(fired_id,
									fired_ig_date,
									fired_last_date,
									fired_ig_year,
									fired_st_area_sq_m,
									fired_st_area_sq_acre,
									fired_st_area_sq_acre)
	
	fired_2000_pres
	
}