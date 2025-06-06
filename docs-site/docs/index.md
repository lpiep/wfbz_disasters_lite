# Wildfire Disaster Dataset Harmonization

## Data Dictionary


### General Descriptors

| Variable      | Data Type     | Description|
| ------------- | ------------- | ---------- | 
`wildfire_id` | `character` | Wildfire ID generated as row number of output dataset | 
`wildfire_year` | `date` | Wildfire Year [YYYY] of Fire |
`wildfire_states` | `character` | Wildfire US State(s) in which fire occurred (comma-delimited if more than one) |
`wildfire_area` | `decimal` | Wildfire burned area in square kilometers |
`wildfire_complex` | `boolean` | Fire is a complex of multiple member fires |
`wildfire_complex_names` | `character` | List of wildfires in the wildfire complex |
`wildfire_evac` | `integer` | Number of people evacuated | 
`wildfire_cost` | `integer` | Cost of wildfire response in dollars (does not include damages) |
`wildfire_threatened_structures` | `integer` | Number of structures potentially threatened by the incident within the next 72 hours | 
`wildfire_buffered_avg_pop_den` | `float` | Average population density in the buffered wildfire burn zone (people per square meter) | 
`wildfire_max_pop_den` | `float` | Maximum population density in the wildfire burn zone (people per square meter) | 
`wildfire_injuries` | `integer` | Number of people who were injured | 

### Criteria 

| Variable      | Data Type     | Description|
| ------------- | ------------- | ---------- | 
`wildfire_total_fatalities` | `integer` | Total wildfire fatalities, firefighter and civilian combined. |
`wildfire_max_civil_fatalities` | `integer` | Best estimate of civilian fatalities from 2000-2019. From 2000-2013, only California RedBooks reported civilian fatalities alone. Therefore, from 2000-2013, this variable reports the maximum total fatalities for wildfires outside California but civilian specific fatalities from California. From 2014-2019, this variable reports the maximum civilian fatalities from each fire. |
`wildfire_civil_fatalities` | `integer` | Total wildfire civilian fatalities (before 2014, these data are only available from CalFire. all other states are missing information on civilian only fatalities prior to 2014). |
`wildfire_struct_destroyed` | `integer` | Wildfire criteria was met for number of structures destroyed. |
`wildfire_community_intersect` | `boolean` | Wildfire criteria was met for community intersection based on population density of 96 people per square kilometer. |
`wildfire_fema_dec` | `boolean` | | FEMA disaster declaration | 
`wildfire_disaster_criteria_met` | `integer` | Wildfire disaster criteria met, including civilian fatalities, structures burned, or an FMAG declaration, or a combination of these variables. |

### Dates

| Variable      | Data Type     | Description|
| ------------- | ------------- | ---------- | 
`wildfire_ignition_date` | `date` | Wildfire date of fire ignition (earliest recorded date) | 
`wildfire_containment_date` | `date` | Wildfire date of fire end (earliest recorded containment date) |
`wildfire_ignition_date_max` | `date` | Wildfire date of fire ignition (latest recorded date) | 
`wildfire_containment_date_max` | `date` | Wildfire date of fire end (latest recorded containment date) |
`wildfire_fema_dec_date` | `date` | Date of FEMA disaster declaration | 

### Location 

| Variable      | Data Type     | Description|
| ------------- | ------------- | ---------- | 
`wildfire_poo_lat` | `decimal` | Fire point of origin latitude in WGS84 |
`wildfire_poo_lon` | `decimal` | Fire point of origin longitude in WGS84 |
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


## General Notes

### Linkages

* `irwinid`: MTBS and NIFC

### Data cleaning

Changed abbreviation scheme to use [USPS rules](https://pe.usps.com/text/pub28/28apc_002.htm?_gl=1*1tbn36t*_gcl_au*NTMxMDc4MjUzLjE3MTg3NDkxMTQ.*_ga*NjkzNzQyODM0LjE3MTA4NjczMzQ.*_ga_3NXP3C8S9V*MTcxODc0OTExMy43LjEuMTcxODc0OTY2Ni4wLjAuMA..). 


## Data Sets Excluded

Geospatial Multi-Agency Coordination (GeoMAC) was shut down in 2020 and transferred to NIFC. 
