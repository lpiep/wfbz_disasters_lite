# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)

options(timeout = max(600, getOption("timeout")))
options(wilfire_disasters_lite.cue_downloads = 'always') # Make 'always' for production

# Set target options:
tar_option_set(
  packages = c("sf", "tidyverse", "httr", "snakecase", "fs", "jsonlite"), # packages that your targets need to run
  format = "rds" # default storage format
)

# tar_make_clustermq() configuration (okay to leave alone):
options(clustermq.scheduler = "multicore")

# tar_make_future() configuration (okay to leave alone):
future::plan(future.callr::callr)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

list(
	### Non Spatial Source Files ###
  tar_target(
    name = event_fema_raw, # see https://www.fema.gov/api/open/v1/OpenFemaDataSetFields?$filter=openFemaDataSet%20eq%20%27FemaWebDisasterSummaries%27%20and%20datasetVersion%20eq%201 for metadata
    {
	    dst <- 'data/raw/nonstatic/event/fema.csv'
    	download.file(
    		'https://www.fema.gov/api/open/v2/DisasterDeclarationsSummaries.csv',
    		dst
	    )
    	dst
    },
    format = 'file',
    cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = event_ics_raw_current_year,
  	{
  		dst <- 'data/raw/nonstatic/event/ics_raw.json'
  		httr::GET(
  			url = 'https://famdwh-dev.nwcg.gov/sit209/cognos_report_queries/sit209_data_report',
  			authenticate('famdwhapiusr', 'Welcome1234!', type = "basic"), # non-secret authentication
  			write_disk(path = dst, overwrite = TRUE)
  		)
  		dst
  	},
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  ### Spatial Source Files ###
  tar_target(
  	name = spatial_mtbs_raw,
  	unzip_url(
  		'https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip',
  		'data/raw/nonstatic/spatial/mtbs'  	
  	),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_fired_raw,
  	unzip_url(
  		'https://scholar.colorado.edu/downloads/h702q749s',
  		'data/raw/nonstatic/spatial/fired'
  	),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_nifc_raw,
  	unzip_url(
  		'https://opendata.arcgis.com/api/v3/datasets/e02b85c0ea784ce7bd8add7ae3d293d0_0/downloads/data?format=shp&spatialRefId=4326&where=1%3D1',
  		'data/raw/nonstatic/spatial/nifc'
  	),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wilfire_disasters_lite.cue_downloads'))
  ),
  ### Census Files ###
  tar_target(
  	name = spatial_tiger_counties_2020_raw,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/TIGER2020/COUNTY/tl_2020_us_county.zip',
  		'data/reference/county_2020'
  	),	
  	format = 'file',  	
  	cue = tar_cue(mode = "never") # expected to be static
  ),
  tar_target(
  	name = spatial_tiger_counties_2010_raw,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/TIGER2010/COUNTY/2010/tl_2010_us_county10.zip',
  		'data/reference/county_2010'
  	),	
  	format = 'file',
  	cue = tar_cue(mode = "never") # expected to be static
  )
  ,
  tar_target(
  	name = spatial_tiger_counties_2000_raw,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/TIGER2010/COUNTY/2000/tl_2010_us_county00.zip',
  		'data/reference/county_2000'
  	),	
  	format = 'file',
  	cue = tar_cue(mode = "never") # expected to be static
  )
  ,
  tar_target(
  	name = spatial_tiger_counties_1990_raw,
  	unzip_url(
  		'https://www2.census.gov/geo/tiger/PREVGENZ/co/co90shp/co99_d90_shp.zip',
  		'data/reference/county_1990'
  	),	
  	format = 'file',
  	cue = tar_cue(mode = "never") # expected to be static
  ), 
  
  ### Clean Data ###
  # See R/process_raw #
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
  	name = spatial_tiger_counties,
  	{
	  	list(
	  		`1990` = read_sf(spatial_tiger_counties_1990_raw) %>% transmute(FIPS = paste0(ST, CO), NAME, CENSUS_YEAR = 1990),
	  		`2000` = read_sf(spatial_tiger_counties_2000_raw) %>% transmute(FIPS = CNTYIDFP00, NAME = NAME00, CENSUS_YEAR = 2000),
	  		`2010` = read_sf(spatial_tiger_counties_2010_raw) %>% transmute(FIPS = GEOID10, NAME = NAME10, CENSUS_YEAR = 2010),
	  		`2020` = read_sf(spatial_tiger_counties_2020_raw) %>% transmute(FIPS = GEOID, NAME = NAME, CENSUS_YEAR = 2020)
	  	)
  	}
  )
)