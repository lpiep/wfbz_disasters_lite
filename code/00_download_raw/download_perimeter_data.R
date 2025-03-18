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
		unzip_url(
			'https://scholar.colorado.edu/downloads/h702q749s',
			dir_create('data/01_raw/spatial/fired')
		)
	}
	return('data/01_raw/spatial/fired')
}

download_spatial_nifc_raw <- function(){
	unzip_url(
		'https://opendata.arcgis.com/api/v3/datasets/e02b85c0ea784ce7bd8add7ae3d293d0_0/downloads/data?format=shp&spatialRefId=4326&where=1%3D1',
		dir_create('data/01_raw/spatial/nifc')
	)
}	
