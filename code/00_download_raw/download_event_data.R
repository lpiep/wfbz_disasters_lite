# Functions to Download Disaster Event Data 
# (called in _targets.R)

source('code/helpers.R')

download_event_fema_raw <- function(){
	dst <- 'data/01_raw/event/fema.csv'
	dir_create(path_dir(dst))
	download.file(
		'https://www.fema.gov/api/open/v2/DisasterDeclarationsSummaries.csv',
		dst
	)
	dst
}

download_event_ics209_plus_raw <- function(){
	dst <- 'data/01_raw/event/ics209_plus'
	unzip_url(
		'https://figshare.com/ndownloader/files/38766504',
		dir_create('data/01_raw/event/ics209_plus')  	
	)
}

