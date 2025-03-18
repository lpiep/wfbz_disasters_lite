# Load packages required to define the pipeline:
if(!require(pacman)){install.packages("pacman");require(pacman)}
pkgs <- c("targets", "tarchetypes", "sf", "tidyverse", "httr", "snakecase", "fs", "jsonlite", "qs2", "readxl", "glue", "arrow", "stringdist", "clustermq")
p_load(char = pkgs)

options(timeout = max(30*60, getOption("timeout"))) # 30 minute timeout on downloads (or larger if env var "timeout" is set to larger number)
options(scipen = 999999)
options(readr.show_col_types = FALSE)
options(wilfire_disasters_lite.cue_downloads = 'never') # Make 'always' for production

# Set target options:
tar_option_set(
  packages = pkgs, # packages that your targets need to run
  format = "qs", # default storage format
  error = "trim" # still finish healthy branches on error 
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
  	name = event_ics209_raw,
  	download_event_ics209_raw(),	
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
  ### Population Density Files ###
  tar_target(
  	name = spatial_ghs_pop_raw_2000,
  	download_spatial_ghs_pop(2000),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_ghs_pop_raw_2005,
  	download_spatial_ghs_pop(2005),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_ghs_pop_raw_2010,
  	download_spatial_ghs_pop(2010),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_ghs_pop_raw_2015,
  	download_spatial_ghs_pop(2015),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_ghs_pop_raw_2020,
  	download_spatial_ghs_pop(2020),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),

  ### Census Files ###
  tar_target(
  	name = spatial_tiger_counties_raw_2020,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/TIGER2020/COUNTY/tl_2020_us_county.zip',
  		dir_create('data/reference/county_2020')
  	),	
  	format = 'file',  	
  	cue = tar_cue(mode = "never") # expected to be static
  ),
  tar_target(
  	name = spatial_tiger_counties_raw_2010,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/TIGER2010/COUNTY/2010/tl_2010_us_county10.zip',
  		dir_create('data/reference/county_2010')
  	),	
  	format = 'file',
  	cue = tar_cue(mode = "never") # expected to be static
  )
  ,
  tar_target(
  	name = spatial_tiger_counties_raw_2000,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/TIGER2010/COUNTY/2000/tl_2010_us_county00.zip',
  		dir_create('data/reference/county_2000')
  	),	
  	format = 'file',
  	cue = tar_cue(mode = "never") # expected to be static
  )
  ,
  tar_target(
  	name = spatial_tiger_counties_raw_1990,
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
  	name = event_ics209,
  	clean_ics209(event_ics209_raw)
  ),
  tar_target(
  	name = event_redbook,
  	clean_redbook(event_redbook_raw)
  ),
  tar_target(
  	name = spatial_tiger_counties,
  	{
	  	list(
	  		`1990` = read_sf(spatial_tiger_counties_raw_1990, crs = 4269) %>% 
	  			transmute(STATE_FIPS = ST, COUNTY_FIPS = paste0(ST, CO), COUNTY_NAME = standardize_county_name(NAME), CENSUS_YEAR = 1990) %>%
	  			left_join(STATE_FIPS, by = 'STATE_FIPS'),
	  		`2000` = read_sf(spatial_tiger_counties_raw_2000, crs = 4269) %>% 
	  			transmute(STATE_FIPS = STATEFP00, COUNTY_FIPS = CNTYIDFP00, COUNTY_NAME = standardize_county_name(NAME00), CENSUS_YEAR = 2000) %>% 
	  			left_join(STATE_FIPS, by = 'STATE_FIPS'),
	  		`2010` = read_sf(spatial_tiger_counties_raw_2010, crs = 4269) %>% 
	  			transmute(STATE_FIPS = STATEFP10, COUNTY_FIPS = GEOID10, COUNTY_NAME = standardize_county_name(NAME10), CENSUS_YEAR = 2010) %>% 
	  			left_join(STATE_FIPS, by = 'STATE_FIPS'),
	  		`2020` = read_sf(spatial_tiger_counties_raw_2020, crs = 4269) %>% 
	  			transmute(STATE_FIPS = STATEFP, COUNTY_FIPS = GEOID, COUNTY_NAME = standardize_county_name(NAME), CENSUS_YEAR = 2020) %>%
	  			left_join(STATE_FIPS, by = 'STATE_FIPS')
	  	) 
  	}
  ),
  ### Harmonize Data ###
  tar_target(
  	event,
	  harmonize_event(
			event_ics209,
      event_redbook,
			event_fema
	  )
  ),
  tar_target(
  	spatial,
  	harmonize_spatial(
  		event,
  		spatial_mtbs,
  		spatial_fired,
  		spatial_nifc,
  		spatial_tiger_counties
  	)
  ),
  tar_target(
  	pop_density_py_script,
  	'code/03_pop_density/run_pop_density.py',
  	format = 'file'
  ),
  tar_target(
  	pop_density,
  	apply_pop_density(
  		spatial,
  		pop_density_py_script,
  		spatial_ghs_pop_raw_2000,
  		spatial_ghs_pop_raw_2005,
  		spatial_ghs_pop_raw_2010,
  		spatial_ghs_pop_raw_2015,
  		spatial_ghs_pop_raw_2020
  	)
  ),
  tar_render(
  	summary_report, 
  	"summary_report.Rmd"
  ),
  tar_target(
  	output_file, 
  	command = {file_delete('wflite.geojson'); write_sf(pop_density, 'wflite.geojson'); 'wflite.geojson'},
  	format = 'file'
  )
)