apply_pop_density <- function(data, pop_density_py_script, ...){
	tempfile <- 'data/02_processed/wui.geojson'
	if(file_exists(tempfile)) file_delete(tempfile)
	write_sf(data, tempfile)
	system(paste(conda, "run -n wf python", pop_density_py_script, '-o data'))
	unlink(tempfile)
	return('data/02_processed/fire_pop_density_criteria.csv')
}