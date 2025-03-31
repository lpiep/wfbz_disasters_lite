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
	fired_dir <- 'data/01_raw/spatial/fired'
	if(dir_exists(fired_dir)){ 
		dir_delete(fired_dir)
	}
	dir_create(fired_dir)
	
	# Hawaii
	url <-'https://scholar.colorado.edu/downloads/9g54xj85m'
	
	t <- file.path(fired_dir, 'hi_fired.zip')
	request(url) %>% 
  		req_user_agent("Mozilla/99.999 (Not really but you reject other agents)") %>%  # spoof firefox 
  		req_perform(path = t) 
	unzip(t, overwrite = TRUE, exdir = fired_dir)
	unlink(t, recursive = TRUE)
	
	# CONUS/AK
	url <-'https://scholar.colorado.edu/downloads/8623j034w'
	t <- file.path(fired_dir, 'conus_ak_fired.tar')
	request(url) %>% 
		req_user_agent("Mozilla/99.999 (Not really but you reject other agents)") %>%  # spoof firefox 
		req_perform(path = t) 
	untar(t, exdir = fired_dir) #this time it's a tar!
	ex <- dir_ls(file.path(fired_dir, 'conus_ak/'))
	file_move(path = ex, new_path = file.path(fired_dir, basename(ex)))
	unlink(t, recursive = TRUE)
		
	return(fired_dir)
}

download_spatial_nifc_raw <- function(){
	unzip_url(
		'https://opendata.arcgis.com/api/v3/datasets/e02b85c0ea784ce7bd8add7ae3d293d0_0/downloads/data?format=shp&spatialRefId=4326&where=1%3D1',
		dir_create('data/01_raw/spatial/nifc')
	)
}	
