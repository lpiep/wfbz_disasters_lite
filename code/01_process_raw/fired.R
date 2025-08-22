# Description -------------------------------------------------------------

# Author: Benjamin Steiger
# Date: 06/13/2023
# Last Update: 06/18/2024 # Logan Piepmeier changed to function and to go through present
# Goal: Clean FIRED CONUS-AK Perimeter Dataset for Matching to Disaster Data, 2000-Present
#
# We initially used the daily data here, which I think is not a good way to do it since
# we don't care about how the fire perimeter changed over time, only its max extent.
# Previously we also calculated fire area, but the area column provided was almost exactly
# equivalent to our calculation. 
#-----------------------------------------

clean_fired <- function(spatial_fired_raw){
	
	fired <- fs::dir_ls(spatial_fired_raw, regexp = 'event.*gpkg$') %>%
		map(read_sf) %>%
		map(select, -ig_day) %>% # drop problematic column
		bind_rows() %>% 
		st_set_geometry("geometry") %>% 
		st_transform(4269) %>% 
		st_make_valid() %>% 
		rename_at(vars(!matches('geometry')), ~ paste0("fired_", .)) %>% 
		mutate(across(matches('date'), ~ymd(substr(.x, 1, 10)))) %>% 
		filter(fired_ig_year >= 2000) %>%
		transmute(
			fired_id, 
			wildfire_ignition_date = fired_ig_date,
			wildfire_containment_date = fired_last_date,
			wildfire_area = as.numeric(st_area(geometry))/1000/1000
		)
	
	batches <- tibble(yr = 2000:year(today())) %>%
		mutate(
			batch_start = ymd(glue('{yr}-01-01')) - 31L,
			batch_end = ymd(glue('{yr}-12-31')) + 31L
		)
	
	fired <- inner_join( # batch by year (with 1 month tails into prior and subsequent years)
		fired,
		batches,
		join_by(overlaps(x$wildfire_ignition_date, x$wildfire_containment_date, y$batch_start, y$batch_end))
	) %>%
		select(-batch_start, -batch_end) %>%
		split(.$yr)
	
	merge_neighbors <- function(fired){
		# Combine fires that occurred in the same place (within a km) and within a month of each other
		neighbors <- st_join(fired, fired, join = st_is_within_distance, dist = 1000) %>% 
			st_drop_geometry() %>% 
			filter(between(wildfire_ignition_date.x, wildfire_ignition_date.y - 30L, wildfire_ignition_date.y + 30L)) %>% 
			select(fired_id.x, fired_id.y)
		
		complex <- rep(NA_integer_, nrow(fired))
		for(i in 1:nrow(neighbors)){ # assign arbitrary complex names to each cluster of fires by iteratively checking each fire and its immediate neighbors
			neighbor_idxes <- neighbors$fired_id.y[which(neighbors$fired_id.x == neighbors$fired_id.x[i])]
			subcomplex <- na.omit(unique(complex[which(fired$idx %in% neighbor_idxes)]))
			if(length(subcomplex) == 0){ complex_label <- i}else{ complex_label <- min(subcomplex) }
			complex[which(complex %in% subcomplex | fired$fired_id %in% neighbor_idxes)] <- complex_label
		}

		fired$complex <- complex
		
		fired
	}
	
	fired <- parallel::mclapply(fired, merge_neighbors, mc.cores = parallel::detectCores() - 1L)
	
	bind_rows(fired, .id = 'batch') %>% 
		filter(!is.na(complex)) %>% 
		group_by(complex, batch) %>%
		filter(year(min(wildfire_ignition_date, na.rm = TRUE)) == yr | year(max(wildfire_containment_date, na.rm = TRUE)) == yr) %>% # rm any clusters that were found only in the date buffers
		summarize(
			fired_id = paste(fired_id, collapse = '|'),
			wildfire_ignition_date = min(wildfire_ignition_date, na.rm = TRUE),
			wildfire_containment_date = max(wildfire_containment_date, na.rm = TRUE),
			wildfire_area = sum(wildfire_area),
			geometry = st_make_valid(st_union(geometry))
		) %>%
		ungroup() %>%
		select(-complex, -batch) %>%
		filter(wildfire_ignition_date >= as.Date('2000-01-01'))
}
