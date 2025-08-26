# Wildfire Disaster Dataset Harmonization

## Description

The proximity of communities to wildfire burn zones is a growing concern due to the increase in wildfire frequency and 
urban development around wildlands. When burn zones come near or cross into communities, the heat, flames, and smoke 
can harm human health—directly or via psychosocial stressors—to the point of becoming a disaster. We harmonized six 
wildfire datasets to create the first U.S.-wide spatial dataset of wildfire burn zone disasters. Our criteria for a 
wildfire burn zone disaster were wildfires that burned near a community (according to a population density or housing
density threshold) and resulted in at least one civilian fatality, one destroyed structure, or received federal disaster 
relief. 

This work was funded by the National Institute for Environmental Health Sciences (NIEHS) P30ES009089 (JAC), 
P30ES007033 (JAC), and T32ES007322-22 (GYM), the National Institute on Aging (NIA) grant R01AG071024 
(TB, EMB, DB, JAC, MG, LBW), and the Canadian Institute for Health Research Doctoral Foreign Study Award (HM).

A paper describing this dataset is currently in review. 

## Data Dictionary

### General Descriptors

| Variable      | Data Type     | Description|
| ------------- | ------------- | ---------- | 
`wildfire_id` | `character` | Wildfire ID generated as row number of output dataset | 
`wildfire_year` | `date` | Wildfire year [YYYY] of fire |
`wildfire_states` | `character` | Wildfire US State(s) in which fire occurred (comma-delimited if more than one) |
`wildfire_area` | `decimal` | Wildfire burned area in square kilometers |
`wildfire_complex` | `boolean` | Fire is a complex of multiple member fires |
`wildfire_complex_names` | `character` | List of wildfires in the wildfire complex |
`wildfire_evac` | `integer` | Number of people evacuated | 
`wildfire_cost` | `integer` | Cost of wildfire response in USD (does not include damages) |
`wildfire_threatened_structures` | `integer` | Number of structures potentially threatened by the incident within the next 72 hours | 
`wildfire_buffered_avg_pop_den` | `float` | Average population density in the buffered wildfire burn zone (people per square meter) | 
`wildfire_max_pop_den` | `float` | Maximum population density in the wildfire burn zone (people per square meter) | 
`wildfire_wui` | `character` | Types of wildland-urban areas intersected by the burn zone ("interface" and/or "intermix"), pipe separated |
`wildfire_injuries` | `integer` | Number of people who were injured | 

### Criteria 

| Variable      | Data Type     | Description|
| ------------- | ------------- | ---------- | 
`wildfire_total_fatalities` | `integer` | Total wildfire fatalities, firefighter and civilian combined |
`wildfire_max_civil_fatalities` | `integer` | Best estimate of civilian fatalities from 2000-2019. From 2000-2013, only California RedBooks reported civilian fatalities alone. Therefore, from 2000-2013, this variable reports the maximum total fatalities for wildfires outside California but civilian specific fatalities from California. From 2014-2019, this variable reports the maximum civilian fatalities from each fire. |
`wildfire_civil_fatalities` | `integer` | Total wildfire civilian fatalities (before 2014, these data are only available from CalFire. all other states are missing information on civilian only fatalities prior to 2014). |
`wildfire_struct_destroyed` | `integer` | Wildfire criteria was met for number of structures destroyed |
`wildfire_community_intersect` | `boolean` | Wildfire criteria was met for community intersection based on population density of either 96 people per square kilometer or building density of 6.17 houses per square kilometer|
`wildfire_fema_dec` | `boolean` | FEMA disaster declaration | 
`wildfire_disaster_criteria_met` | `integer` | Wildfire disaster criteria met, including civilian fatalities, structures burned, or an FMAG declaration, or a combination of these variables |

### Dates

| Variable      | Data Type     | Description|
| ------------- | ------------- | ---------- | 
`wildfire_ignition_date` | `date` | Wildfire date of fire ignition (earliest recorded date) | 
`wildfire_containment_date` | `date` | Wildfire date of fire end (earliest recorded containment date) |
`wildfire_ignition_date_max` | `date` | Wildfire date of fire ignition (latest recorded date) | 
`wildfire_containment_date_max` | `date` | Wildfire date of fire end (latest recorded containment date) |
`wildfire_fema_dec_date` | `date` | Date of FEMA FMAG disaster declaration | 

### Location 

| Variable      | Data Type     | Description|
| ------------- | ------------- | ---------- | 
`wildfire_poo_lat` | `decimal` | Fire point of origin latitude in NAD83 (EPSG: 4269) |
`wildfire_poo_lon` | `decimal` | Fire point of origin longitude in NAD83 (EPSG: 4269) |
`geometry_src`| `character` | Data set from which `geometry` originates (One of "FIRED", "MTBS", "NIFC") | 
`geometry` | `geometry` | Geometry of Fire |

### Native IDs

| Variable      | Data Type     | Description|
| ------------- | ------------- | ---------- | 
`redbook_id` | `character` | Native ID of associated Red Book data, if applicable | 
`ics_id` | `character` | Native ID of associated ICS/209 data, if applicable | 
`fired_id` | `character` | Native ID of associated FIRED data, if applicable | 
`mtbs_id` | `character` | Native ID of associated MTBS data, if applicable | 
`usgs_id` | `character` | Native ID of associated USGS data, if applicable | 
`geomac_id` | `character` | Native ID of associated GEOMAC data, if applicable | 
`fema_id` | `character` | Native ID of associated FEMA data, if applicable | 

