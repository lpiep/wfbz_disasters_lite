# Wildfire Disaster Dataset Harmonization

## Data Dictionary

| Variable      | Data Type     | Unique | Description|
| ------------- | ------------- | -------| ---------- | 
`harm_id` | `character` | True | Harmonized ID | 
`harm_year` | `date` | | Harmonized Year [YYYY] of Fire |
`harm_states` | `date` | | Harmonized US State(s) in which fire occurred (pipe-delimited if more than one) |
`harm_area` | `float` | | Harmonized burned area in square miles |
`harm_fatalities` | `integer` | |  Harmonized number of fatalities ???? |
`harm_civil_fatalities` | `integer` | |  Harmonized number of civilian fatalities ???? |
`harm_struct_destroyed` | `integer` | |  Harmonized number of structures destroyed |
`harm_community` | `boolean` | |  Harmonized criteria for whether a population center was affected |
`redbook_id` | `character` | | Native ID of associated Red Book data, if applicable | 
`ics_id` | `character` | | Native ID of associated ICS/209 data, if applicable | 
`fired_id` | `character` | | Native ID of associated FIRED data, if applicable | 
`mtbs_id` | `character` | | Native ID of associated MTBS data, if applicable | 
`nifc_id` | `character` | | Native ID of associated NIFC data, if applicable | 
`geometry_src`| `character` | | Data set from which `geometry` originates (One of "FIRED", "MTBS", "NIFC") | 
`geometry` | `geometry` | | Harmonized Geometry of Fire |


## General Notes

### Linkages

* `irwinid`: MTBS and NIFC

### Data cleaning

Changed abbreviation scheme to use [USPS rules](https://pe.usps.com/text/pub28/28apc_002.htm?_gl=1*1tbn36t*_gcl_au*NTMxMDc4MjUzLjE3MTg3NDkxMTQ.*_ga*NjkzNzQyODM0LjE3MTA4NjczMzQ.*_ga_3NXP3C8S9V*MTcxODc0OTExMy43LjEuMTcxODc0OTY2Ni4wLjAuMA..). 


## Data Sets Excluded

Geospatial Multi-Agency Coordination (GeoMAC) was shut down in 2020 and transferred to NIFC. 
