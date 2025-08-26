# Load packages required to define the pipeline:
pkgs <- c("targets", "tarchetypes", "geotargets", "sf", "tidyverse", "httr", "fs", 
					"jsonlite", "qs", "qs2", "httr2", "readxl", "glue", "arrow",
					"stringdist", "exactextractr", "terra", "data.table")
lapply(pkgs, library, character.only = TRUE)

options(timeout = max(90*60, getOption("timeout"))) # 30 minute timeout on downloads (or larger if env var "timeout" is set to larger number)
options(scipen = 9999)
options(readr.show_col_types = FALSE)
options(wildfire_disasters_lite.cue_downloads = 'never') # Make 'always' for production
conda = Sys.getenv("CONDABIN", unset = glue('{Sys.getenv("HOME", "~")}/miniconda3/bin/conda')) #YOUR CONDA HERE!!!
message("Conda is: ", conda)

# Set target options:
tar_option_set(
  packages = pkgs, # packages that your targets need to run
  format = "qs", # default storage format
  error = "abridge" # still finish healthy branches on error 
)

# Parallelization
future::plan(future.mirai::mirai_multisession, workers = 4L)
set.seed(8675309, kind = "L'Ecuyer-CMRG")

# Run the R scripts in the R/ folder with your custom functions:
tar_source(files = 'code/')

proj_crs <- 'PROJCS["USA_Contiguous_Lambert_Conformal_Conic",
    GEOGCS["GCS_North_American_1983",
        DATUM["D_North_American_1983",
        SPHEROID["GRS_1980",6378137.0,298.257222101]],
        PRIMEM["Greenwich",0.0],
        UNIT["Degree",0.0174532925199433]],
    PROJECTION["Lambert_Conformal_Conic"],
    PARAMETER["False_Easting",0.0],
    PARAMETER["False_Northing",0.0],
    PARAMETER["Central_Meridian",-96.0],
    PARAMETER["Standard_Parallel_1",33.0],
    PARAMETER["Standard_Parallel_2",45.0],
    PARAMETER["Latitude_Of_Origin",39.0],
    UNIT["Meter",1.0]]'

list(
	### Non Spatial Source Files ###
  tar_target(
    name = event_fema_raw, # see https://www.fema.gov/api/open/v1/OpenFemaDataSetFields?$filter=openFemaDataSet%20eq%20%27FemaWebDisasterSummaries%27%20and%20datasetVersion%20eq%201 for metadata
    download_event_fema_raw(),
    format = 'file',
    cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
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
  	cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
  ### Spatial Source Files ###
  tar_target(
  	name = spatial_mtbs_raw,
  	download_spatial_mtbs_raw(),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_fired_raw,
  	download_spatial_fired_raw(),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_nifc_raw,
  	download_spatial_nifc_raw(),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
	  name = spatial_wui_raw,
	  {
		  unzip_url(
		  	'https://geoserver.silvis.forest.wisc.edu/geodata/globalwui/NA.zip',
		  	dir_create('data/01_raw/spatial/wui')
		  )
	  	'data/01_raw/spatial/wui/NA/mosaic/WUI.vrt'
	  },	
	  format = 'file',
	  cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
  ### Population Density Files ###
  tar_target(
  	name = spatial_ghs_pop_raw_2000,
  	download_spatial_ghs_pop(2000),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_ghs_pop_raw_2005,
  	download_spatial_ghs_pop(2005),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_ghs_pop_raw_2010,
  	download_spatial_ghs_pop(2010),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_ghs_pop_raw_2015,
  	download_spatial_ghs_pop(2015),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
  tar_target(
  	name = spatial_ghs_pop_raw_2020,
  	download_spatial_ghs_pop(2020),	
  	format = 'file',
  	cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
  ),
	tar_target(
		name = spatial_ghs_pop_raw_2025,
		download_spatial_ghs_pop(2025),	
		format = 'file',
		cue = tar_cue(mode = getOption('wildfire_disasters_lite.cue_downloads'))
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
	# tar_target(
	# 	name = spatial_wui,
	# 	st_read(
	# 		spatial_wui_raw, 
	# 		query = '
	# 			select FIPS, WUICLASS2000, WUICLASS2010, WUICLASS2020, Shape
	# 			from CONUS_WUI_block_1990_2020_change_v4
	# 			where (WUIFLAG2020 = 1 or WUIFLAG2010 = 1 or WUIFLAG2000 = 1)'
	# 	) %>% 
	# 		pivot_longer(-c(FIPS, Shape), names_to = 'year', values_to = 'wuiclass') %>% 
	# 		mutate(
	# 			county = substr(FIPS, 1, 5),
	# 			year = as.numeric(str_sub(year, 9, 12)), 
	# 			wuiclass = str_extract(wuiclass, '(Intermix|Interface)')
	# 		) %>% 
	# 		filter(!is.na(wuiclass)) %>% 
	# 		st_set_geometry('geometry') %>%
	# 		group_by(county, year, wuiclass) %>% 
	# 		summarize(
	# 			geometry = st_simplify(st_union(geometry), dTolerance = 10),
	# 			.groups = 'drop'
	# 		) %>%
	# 		st_make_valid() 
	# ),
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
  # tar_terra_vect(
  # 	spatial_vect,
  # 	vect(spatial)
  # ),
  tar_target(
  	wui,
  	{
  		z <- spatial # need to copy explicitly here for some reason
  		# temporarily turn points into very small polygons to satisfy exact_extract
  		z$geometry_temp <- st_geometry(z)
  		st_geometry(z)[st_geometry_type(z$geometry) == 'POINT'] <- st_buffer(z$geometry[st_geometry_type(z$geometry) == 'POINT'], .01)
  		wui_rast <- rast(spatial_wui_raw)
   		extracted_values <- exact_extract(
  			x = wui_rast, 
  			y = z, 
				fun = function(values, coverage_fractions) {
					unique(values[coverage_fractions > 0])
				}
			) # list of values in each fire
  		intermix <- sapply(extracted_values, function(x) any(x %in% c(1, 3)))
  		interface <- sapply(extracted_values, function(x) any(x %in% c(2, 4)))
  		
  		z %>% 
  			mutate(
  				intermix  = sapply(extracted_values, function(x) any(x %in% c(1, 3))),
  				interface = sapply(extracted_values, function(x) any(x %in% c(2, 4))),
  				wildfire_wui = case_when(
  					intermix & interface ~ 'interface|intermix',
  					intermix ~ 'intermix',
  					interface ~ 'interface',
  					TRUE ~ NA_character_
  				),
  				geometry = geometry_temp
  			) %>%
  			select(-geometry_temp) # put back original geometry
  	},
  ),
  tar_target(
  	pop_density_py_script,
  	'code/03_pop_density/run_pop_density.py',
  	format = 'file'
  ),
  tar_target(
  	pop_density,
  	apply_pop_density(
  		data = wui,
  		pop_density_py_script = pop_density_py_script,
  		spatial_ghs_pop_raw_2000,
  		spatial_ghs_pop_raw_2005,
  		spatial_ghs_pop_raw_2010,
  		spatial_ghs_pop_raw_2015,
  		spatial_ghs_pop_raw_2020,
  		spatial_ghs_pop_raw_2025
  	),
  	format = 'file'
  ),
  tar_quarto(
  	summary_report, 
  	"summary_report.qmd"
  ),
  tar_target(
  	output_file, 
  	command = {
  		if(file_exists('wfbz.geojson')){file_delete('wfbz.geojson')}
  		out <- left_join(wui, read_csv(pop_density), by = 'wildfire_id')
  		out <- out %>%
  			select(
  				wildfire_id,
  				wildfire_year,
  				wildfire_states,
  				wildfire_area,
  				wildfire_complex,
  				wildfire_complex_names,
  				wildfire_total_fatalities,
  				wildfire_max_civil_fatalities, 
  				wildfire_civil_fatalities,
  				wildfire_civil_injuries,
  				wildfire_total_injuries,
  				wildfire_civil_evacuation,
  				wildfire_total_evacuation,
  				wildfire_struct_destroyed,
  				wildfire_struct_threatened,
  				wildfire_cost,
          wildfire_community_intersect,
					wildfire_max_pop_den,
					wildfire_buffered_avg_pop_den,
					wildfire_wui,
  				wildfire_fema_dec,
  				wildfire_disaster_criteria_met,
  				wildfire_ignition_date,
  				wildfire_containment_date,
  				wildfire_ignition_date_max,
  				wildfire_containment_date_max,
  				wildfire_fema_dec_date,
  				wildfire_poo_lat,
  				wildfire_poo_lon,
  				geometry_src,
					geometry_method,
  				redbook_id,
  				ics_id,
  				fired_id,
  				mtbs_id,
  				fema_id
  			)
  		write_sf(out, 'wfbz.geojson')
  		'wfbz.geojson'
  	},
  	format = 'file'
  )
)
