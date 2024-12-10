# Wildfire Disaster Dataset Harmonization

## Data Dictionary

| Variable      | Data Type     | Unique | Description|
| ------------- | ------------- | -------| ---------- | 
`wildfire_id` | `character` | True | Wildfire ID | 
`wildfire_year` | `date` | | Wildfire Year [YYYY] of Fire |
`wildfire_states` | `date` | | Wildfire US State(s) in which fire occurred (pipe-delimited if more than one) |
`wildfire_counties` | `date` | | Wildfire US County FIPS code(s) in which fire occurred (pipe-delimited if more than one) |
`wildfire_area` | `float` | | Wildfire burned area in square kilometers |
`wildfire_fema_dec` | `boolean` | |  FEMA disaster declaration |
`wildfire_fatalities` | `integer` | |  Wildfire number of fatalities ???? |
`wildfire_civil_fatalities` | `integer` | |  Wildfire number of civilian fatalities ???? |
`wildfire_struct_destroyed` | `integer` | |  Wildfire number of structures destroyed |
`wildfire_populated` | `boolean` | |  Wildfire criteria for whether a population center was affected |
`wildfire_ignition` | `date` | | Wildfire date of fire ignition | 
`wildfire_fema_dec_date` | `date` | | Date of FEMA disaster declaration | 
`wildfire_end` | `date` | | Wildfire date of fire end |
`wildfire_complex` | `boolean` | | Fire is a complex of multiple member fires |
`wildfire_poo_lat` | `decimal` | | Fire point of origin latitude in WGS84 |
`wildfire_poo_lon` | `decimal` | | Fire point of origin longitude in WGS84 |
`redbook_id` | `character` | | Native ID of associated Red Book data, if applicable | 
`ics_id` | `character` | | Native ID of associated ICS/209 data, if applicable | 
`fired_id` | `character` | | Native ID of associated FIRED data, if applicable | 
`mtbs_id` | `character` | | Native ID of associated MTBS data, if applicable | 
`nifc_id` | `character` | | Native ID of associated NIFC data, if applicable | 
`geometry_src`| `character` | | Data set from which `geometry` originates (One of "FIRED", "MTBS", "NIFC") | 
`geometry` | `geometry` | | Wildfire Geometry of Fire |


## General Notes

### Linkages

* `irwinid`: MTBS and NIFC

### Data cleaning

Changed abbreviation scheme to use [USPS rules](https://pe.usps.com/text/pub28/28apc_002.htm?_gl=1*1tbn36t*_gcl_au*NTMxMDc4MjUzLjE3MTg3NDkxMTQ.*_ga*NjkzNzQyODM0LjE3MTA4NjczMzQ.*_ga_3NXP3C8S9V*MTcxODc0OTExMy43LjEuMTcxODc0OTY2Ni4wLjAuMA..). 


## Data Sets Excluded

Geospatial Multi-Agency Coordination (GeoMAC) was shut down in 2020 and transferred to NIFC. 
