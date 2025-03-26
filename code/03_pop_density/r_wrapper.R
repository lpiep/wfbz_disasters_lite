apply_pop_density <- function(spatial, pop_density_py_script, ...){
	tempfile <- 'data/02_processed/spatial.geojson'
	if(file_exists(tempfile)) file_delete(tempfile)
	write_sf(spatial, 'data/02_processed/spatial.geojson')
	system(paste(conda, "run -n wf python", pop_density_py_script))
	return('data/02_processed/fire_pop_density_criteria.csv')
}