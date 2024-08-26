# Monitoring Trends in Burn Severity Data

Source: https://mtbs.gov/direct-download

## Summary

The Monitoring Trends in Burn Severity (MTBS) Program assesses the frequency, extent, and magnitude (size and severity) of all large wildland fires (including wildfires and prescribed fires) in the conterminous United States (CONUS), Alaska, Hawaii, and Puerto Rico for the period of 1984 and beyond. All fires reported as greater than 1,000 acres in the western U.S. and greater than 500 acres in the eastern U.S. are mapped across all ownerships. MTBS produces a series of geospatial and tabular data for analysis at a range of spatial, temporal, and thematic scales and are intended to meet a variety of information needs that require consistent data about fire effects through space and time. This map layer is a vector polygon shapefile of the location of all currently inventoried fires occurring between calendar year 1984 and 2022 for CONUS, Alaska, Hawaii, and Puerto Rico. Fires omitted from this mapped inventory are those where suitable satellite imagery was not available, or fires were not discernable from available imagery.

## Fields
  * `FID` - Internal feature number. 
  * `Shape` - Feature geometry. 
  * `Event_ID` - Event ID. 
  * `irwinID` - IRWIN ID. 
  * `Incid_Name` - Name of fire (UNNAMED if not identifiable from source fire occurrence databases). 
  * `Incid_Type` - Documented type of fire (WF: Wildfire, Rx: Prescribed Fire; UNK:Unknown). 
  * `Map_ID` - Mapping ID. 
  * `Map_Prog` - Mapping program/protocol the fire was mapped with. 
  * `Asmnt_Type` - Fire mapping assessment label (Initial (SS) (SS=single scene), Initial, Extended, Extended (SS) (SS=single scene), Emergency, or Emergency (SS)). 
  * `BurnBndAc` - Number of acres mapped. 
  * `BurnBndLat` - Latitude of the mapped centroid of fire perimeter. 
  * `BurnBndLon` - Longitude of the mapped centroid of fire perimeter. 
  * `Ig_Date` - Date of fire ignition (from source fire occurrence databases). 
  * `Pre_ID` - Landsat or Sentinel pre scene ID. 
  * `Post_ID` - Landsat or Sentinel post scene ID. 
  * `Perim_ID` - Landsat or Sentinel perimeter scene ID. Used to help delineate perimeter of an Extended or Extended (SS) assessment. Not always utilized, sometimes field will be populated, other times not. 
  * `dNBR_offst` - The mean dNBR value sampled from an unburned area outside the fire perimeter. 
  * `dNBR_stdDv` - The standard deviation of the mean dNBR value sampled from an unburned area outside the fire perimeter. 
  * `NoData_T` - No data threshold (in dNBR index values; NBR index units for single scene assessments). 
  * `IncGreen_T` - Increased greenness threshold (in dNBR index values; NBR index units for single scene assessments). 
  * `Low_T` - Unburned/Low threshold (in dNBR index values; NBR index units for single scene assessments). 
  * `Mod_T` - Low/Moderate burn severity threshold (in dNBR index values; NBR index units for single scene assessments). 
  * `High_T` - Moderate/High burn severity threshold (in dNBR index values; NBR index units for single scene assessments). 
  * `Comment` - As needed comments or notes provided by the mapping analyst to the end user.