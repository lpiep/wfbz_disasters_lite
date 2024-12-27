# Load packages required to define the pipeline:
if(!require(pacman)){install.packages("pacman");require(pacman)}
pkgs <- c("targets", "tarchetypes", "sf", "tidyverse", "httr", "snakecase", "fs", "jsonlite", "qs", "readxl", "glue")
p_load(char = pkgs)

options(timeout = max(600, getOption("timeout")))
options(scipen = 999999)
options(readr.show_col_types = FALSE)
#options(wilfire_disasters_lite.cue_downloads = 'never') # Make 'always' for production

# Set target options:
tar_option_set(
  packages = pkgs, # packages that your targets need to run
  format = "qs" # default storage format
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# Run the R scripts in the R/ folder with your custom functions:
tar_source(files = 'code/')

list(
	### Non Spatial Source Files ###
  tar_target(
    name = event_fema_raw, # see https://www.fema.gov/api/open/v1/OpenFemaDataSetFields?$filter=openFemaDataSet%20eq%20%27FemaWebDisasterSummaries%27%20and%20datasetVersion%20eq%201 for metadata
    download_event_fema_raw(),
    format = 'file',
    cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = event_redbook_raw,
  	'data/01_raw/event/redbook/',
  	format = 'file',
  ),
  tar_target(
  	name = event_ics209_plus_raw,
  	download_event_ics209_plus_raw(),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  ### Spatial Source Files ###
  tar_target(
  	name = spatial_mtbs_raw,
  	download_spatial_mtbs_raw(),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_fired_raw,
  	download_spatial_fired_raw(),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_nifc_raw,
  	download_spatial_nifc_raw(),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  ### Census Files ###
  tar_target(
  	name = spatial_tiger_counties_2020_raw,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/TIGER2020/COUNTY/tl_2020_us_county.zip',
  		dir_create('data/reference/county_2020')
  	),	
  	format = 'file',  	
  	cue = tar_cue(mode = "never") # expected to be static
  ),
  tar_target(
  	name = spatial_tiger_counties_2010_raw,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/TIGER2010/COUNTY/2010/tl_2010_us_county10.zip',
  		dir_create('data/reference/county_2010')
  	),	
  	format = 'file',
  	cue = tar_cue(mode = "never") # expected to be static
  )
  ,
  tar_target(
  	name = spatial_tiger_counties_2000_raw,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/TIGER2010/COUNTY/2000/tl_2010_us_county00.zip',
  		dir_create('data/reference/county_2000')
  	),	
  	format = 'file',
  	cue = tar_cue(mode = "never") # expected to be static
  )
  ,
  tar_target(
  	name = spatial_tiger_counties_1990_raw,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/PREVGENZ/co/co90shp/co99_d90_shp.zip',
  		dir_create('data/reference/county_1990')
  	),	
  	format = 'file',
  	cue = tar_cue(mode = "never") # expected to be static
  ), 
  ### Clean Data ###
  tar_target(
  	name = spatial_mtbs,
  	clean_mtbs(spatial_mtbs_raw)
  ), 
  tar_target(
  	name = spatial_fired,
  	clean_fired(spatial_fired_raw)
  ), 
  tar_target(
  	name = spatial_nifc,
  	clean_nifc(spatial_nifc_raw)
  ),
  tar_target(
  	name = event_fema,
  	clean_fema(event_fema_raw)
  ),
  tar_target(
  	name = event_ics209_plus,
  	clean_ics209_plus(event_ics209_plus_raw)
  ),
  tar_target(
  	name = spatial_tiger_counties,
  	{
	  	list(
	  		`1990` = read_sf(spatial_tiger_counties_1990_raw, crs = 4269) %>% transmute(STATE_FIPS = ST, FIPS = paste0(ST, CO), NAME, CENSUS_YEAR = 1990),
	  		`2000` = read_sf(spatial_tiger_counties_2000_raw, crs = 4269) %>% transmute(STATE_FIPS = STATEFP00, COUNTY_FIPS = CNTYIDFP00, NAME = NAME00, CENSUS_YEAR = 2000),
	  		`2010` = read_sf(spatial_tiger_counties_2010_raw, crs = 4269) %>% transmute(STATE_FIPS = STATEFP10, COUNTY_FIPS = GEOID10, NAME = NAME10, CENSUS_YEAR = 2010),
	  		`2020` = read_sf(spatial_tiger_counties_2020_raw, crs = 4269) %>% transmute(STATE_FIPS = STATEFP, COUNTY_FIPS = GEOID, NAME = NAME, CENSUS_YEAR = 2020)
	  	)
  	}
  )
)