# Fire Event Delineation Data 

Source: https://scholar.colorado.edu/concern/datasets/d504rm74m

See Also: https://www.mdpi.com/2072-4292/12/21/3498

## Summary 

This is event- and daily-level polygons for the Fire event delineation (FIRED) product for the coterminous United States from November 2001 to March 2021. It is derived from the MODIS MCD64A1 burned area product (see https://lpdaac.usgs.gov/products/mcd64a1v006/ for more details). The MCD64A1 is a monthly raster grid of estimated burned dates. Firedpy (www.github.com/earthlab/firedpy) is an algorithm that converts these rasters into events by stacking the entire time series into a spatial-temporal data cube, then uses an algorithm to assign event identification numbers to pixels that fit into the same 3-dimensional spatial temporal window. This particular dataset was created using a spatial parameter of 5 pixels and 11 days. The primary benefit to this dataset over others is the ability to calculate fire spread rate. For each of these products (events and daily) the event identification numbers are the same, but the event-level product has only single polygons for each entire event, while the daily product has separate polygons for each date per event.

This download contains a "daily" and "event" format. Daily has a unique polygon for each day _and_ event. We will use the "event" format (`fired_conus-ak_events_nov2001-mar2021.gpkg`)

## Fields

_Bold fields are carried over into harmonized data set._

* `id` -  **Unique identifier of the fire event.**
* `ig_date` -  **The earliest date contained in the event**
* `ig_day`  -  The day of the year of the earliest date contained in the event
* `ig_month`  -  The month of the earliest date contained in the event
* `ig_year` -  The year of the earliest date contained in the event.
* `last_date` -  The latest date contained in the event
* `event_day`  -  Days since ignition date + 1 (ignition date is day 1)
* `pixels` -  Total number of pixels burned that day. 
* `tot_px`  -   Total pixels burned for the entire event. 
* `tot_ar_km2` -  **Area burned in square kilometers for the entire event (Units converted to square miles in harmonized data set).** 
* `fsr_px_dy` -  Total pixels burned for the entire event divided by the duration of the fire event. 
* `fsr_km2_dy` -  Total kilometers burned for the entire event divided by the duration of the fire event. 
* `mx_grw_px` -  maximum growth in pixels
* `mn_grw_px` -  minimum growth in pixels
* `mu_grw_px` -  mean growth in pixels
* `mx_grw_km2` -  maximum growth in square kilometers
* `mn_grw_km2` -  minimum growth in square kilometers 
* `mu_grw_km2` -  mean growth in square kilometers
* `mx_grw_dte` -  date of maximum
* `lc_code` -  Numeric code for the landcover type extracted from the MODIS landcover product for the year preceding the fire. 
* `lc_mode` -  Numeric code for the landcover type extracted from the MODIS landcover product for the year preceding the fire. 
* `lc_name` -  Character string of the landcover type from the year before the fire. 
* `lc_desc` -  Character string description of the landcover type from the year before the fire. 
* `lc_type` -  Which landcover classification type was used from the MCD12Q1 product? Default is IGBP global vegetation classification scheme
* `eco_mode` -  Modal ecoregion code
* `eco_type` -  Which type and level of ecoregion classification was used (North america EPA (levels 1-3) vs World Wildlife Federation)
* `eco_name` -  Character string of the ecoregion type where the event occurred. 
* `ig_utm_x` -  estimated ignition x coordinate
* `ig_utm_y` -  estimated ignition y coordinate
* `tot_perim` -  Total perimeter of the fire event
