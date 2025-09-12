apply_pop_density <- function(data, pop_density_py_script, ...){
	tempfile <- 'data/02_processed/wui.geojson'
	if(file_exists(tempfile)) file_delete(tempfile)
	write_sf(filter(data, !is.na(wildfire_states)), tempfile)
	return_code <- system(paste(conda, "run -n wf python", pop_density_py_script, '-o data'))
	unlink(tempfile)
	stopifnot(return_code == 0)
	return('data/02_processed/fire_pop_density_criteria.csv')
}