# Functions to Download Fire Perimeters 
# (called in _targets.R)

source('code/helpers.R')

download_spatial_mtbs_raw <- function(){
	unzip_url(
		'https://edcintl.cr.usgs.gov/downloads/sciweb1/shared/MTBS_Fire/data/composite_data/burned_area_extent_shapefile/mtbs_perimeter_data.zip',
		dir_create('data/01_raw/spatial/mtbs')  	
	)
}

download_spatial_fired_raw <- function(){
	if(!file.exists('data/01_raw/spatial/fired/fired_conus-ak_events_nov2001-march2021.gpkg')){
		url <-'https://scholar.colorado.edu/downloads/h702q749s'
		t <- 'data/01_raw/spatial/fired/fired.zip'
		dst <- dirname(t)
		if(!dir_exists(dst)) dir_create(dst)
		request('http://scholar.colorado.edu/downloads/h702q749s') %>% 
    		req_user_agent("Mozilla/99.999 (Not really but you reject other agents)") %>%  # spoof firefox 
    		req_perform(path = t) 

		unzip(t, overwrite = TRUE, exdir = dst)
  		unlink(t, recursive = TRUE)
  		dst

	}
	return('data/01_raw/spatial/fired')
}

download_spatial_nifc_raw <- function(){
	unzip_url(
		'https://opendata.arcgis.com/api/v3/datasets/e02b85c0ea784ce7bd8add7ae3d293d0_0/downloads/data?format=shp&spatialRefId=4326&where=1%3D1',
		dir_create('data/01_raw/spatial/nifc')
	)
}	
