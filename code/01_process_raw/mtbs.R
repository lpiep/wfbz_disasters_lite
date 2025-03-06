
clean_mtbs <- function(spatial_mtbs_raw){ 
		
	mtbs <- st_read(spatial_mtbs_raw)

	mtbs <- mtbs %>%
		transmute(
			Event_ID, 
			Incid_Name,
			Incid_Type,
			Ig_Date = as.Date(as.character(Ig_Date), format = "%Y-%m-%d"),
			irwinID = na_if(irwinID, 'No IRWINID')
		)  %>%
		filter(year(Ig_Date) >= 2000) %>%
		filter(Incid_Type != "Prescribed Fire") %>%
		mutate(wildfire_state = substr(Event_ID, start = 1, stop = 2)) %>%
		mutate(
			wildfire_complex = str_detect(toupper(Incid_Name), 'COMPLEX'),
			Incid_Name = standardize_place_name(Incid_Name)
		) 
	mtbs <- st_make_valid(mtbs) %>% # Repair geometries and transform
		st_transform(mtbs, crs = 4269)
	
	mtbs <- bind_rows( # fix rare cases where multiple fires share an irwin ID
		mtbs %>% filter(is.na(irwinID)), 
		mtbs %>% filter(!is.na(irwinID)) %>% 
			group_by(irwinID) %>%
			summarize(
				Event_ID =  paste(unique(Event_ID), collapse = '|'),
				Incid_Name =  paste(unique(Incid_Name), collapse = '|'),
				wildfire_complex = any(wildfire_complex),
				Ig_Date = min(Ig_Date),
				wildfire_state = paste(unique(wildfire_state), collapse = '|'),
				geometry = st_union(geometry)
			)
	)
	
	mtbs %>%
		transmute(
			wildfire_state,
			mtbs_id = Event_ID,
			wildfire_name = Incid_Name,
			wildfire_complex,
			wildfire_ignition_date = Ig_Date,
			wildfire_area = as.numeric(st_area(geometry))/1000/1000, # area in sq km
			irwin_id = irwinID
		)
}