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

download_event_ics209_raw <- function(){
	dst <- 'data/01_raw/event/ics209'
	if(fs::dir_exists(dst)) fs::dir_delete(dst)
	fs::dir_create(dst)
	download.file('https://github.com/lpiep/ics209_minimal/raw/refs/heads/main/data/historical/historical_cleaned.parquet', file.path(dst, 'historical_cleaned.parquet'))
	download.file('https://github.com/lpiep/ics209_minimal/raw/refs/heads/main/data/current/current_cleaned.parquet',  file.path(dst, 'current_cleaned.parquet'))
	dst
}

