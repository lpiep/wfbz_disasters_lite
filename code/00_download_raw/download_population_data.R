download_spatial_ghs_pop <- function(yr){
	dst <- 'data/01_raw/pop_data'
	unzip_url(
		glue('https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E{yr}_GLOBE_R2023A_54009_100/V1-0/GHS_POP_E{yr}_GLOBE_R2023A_54009_100_V1_0.zip'),
		dir_create(dst)
	)
	
	file.path(dst, glue('GHS_POP_E{yr}_GLOBE_R2023A_54009_100_V1_0.tif'))	
}
