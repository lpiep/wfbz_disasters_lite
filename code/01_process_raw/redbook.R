# srced from https://drive.google.com/drive/u/1/folders/1G0sy_DydeZt8NqcXHD7ryNMhWBtzy3TW

clean_redbook <- function(event_redbook_raw){
	
	redbooks_raw <- fs::dir_ls(event_redbook_raw, recurse = TRUE, glob = '*.csv') %>%
		map(read_csv, skip = 4) 
	
		
}