# srced from https://drive.google.com/drive/u/1/folders/1G0sy_DydeZt8NqcXHD7ryNMhWBtzy3TW

clean_redbook <- function(event_redbook_raw){
	
	redbooks_raw <- fs::dir_ls(event_redbook_raw, recurse = TRUE, glob = '*.xlsx') %>%
		map(read_excel, sheet = 1, skip = 2) 
	
		
}