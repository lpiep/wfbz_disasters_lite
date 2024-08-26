# National Interagency Fire Center Perimeter Data
 

Source: https://data-nifc.opendata.arcgis.com/datasets/nifc::interagencyfireperimeterhistory-all-years-view/about

## Summary 


Overview

The national fire history perimeter data developed in support of the WFDSS application and wildfire decision support for the 2021 fire season. The layer encompasses the final fire perimeter datasets gathered from several agencies. Requirements for fire perimeter inclusion, such as minimum acreage requirements, are set by the contributing agencies. WFIGS, NPS and CALFIRE data include Prescribed Burns. 

Includes data from: 

   * Alaska fire history 
   * USDA FS Regional Fire History Data 
   * BLM Fire Planning and Fuels 
   * National Park Service - Includes Prescribed Burns 
   * Fish and Wildlife Service
   * Bureau of Indian Affairs
   * CalFire FRAS - Includes Prescribed Burns
   * WFIGS - BLM & BIA and other S&L

## Fields 

* `IRWINID` - Primary key for linking to the IRWIN Incident dataset. The origin of this GUID is the wildland fire locations point data layer. (This unique identifier may NOT replace the GeometryID core attribute)

* `INCIDENT` - The name assigned to an incident; assigned by responsible land management unit. (IRWIN required). Officially recorded name.

* `FIRE_YEAR` (Alias) - Calendar year in which the fire started. Example: 2013. Value is of type integer (FIRE_YEAR_INT).

* `AGENCY` - Agency assigned for this fire - should be based on jurisdiction at origin.

* `SOURCE` - System/agency source of record from which the perimeter came.

* `DATE_CUR` - The last edit, update, or other valid date of this GIS Record. Example: mm/dd/yyyy.

* `MAP_METHOD` - Controlled vocabulary to define how the geospatial feature was derived. Map method may help define data quality.
    * Values: GPS-Driven; GPS-Flight; GPS-Walked; GPS-Walked/Driven; GPS-Unknown Travel Method; Hand Sketch; Digitized-Image; Digitized-Topo; Digitized-Other; Image Interpretation; Infrared Image; Modeled; Mixed Methods; Remote Sensing Derived; Survey/GCDB/Cadastral; Vector; Other

* `GIS_ACRES` - GIS calculated acres within the fire perimeter. Not adjusted for unburned areas within the fire perimeter. Total should include 1 decimal place. (ArcGIS: Precision=10; Scale=1). Example: 23.9

* `UNQE_FIRE_` - Unique fire identifier is the Year-Unit Identifier-Local Incident Identifier (yyyy-SSXXX-xxxxxx). SS = State Code or International Code, XXX or XXXX = A code assigned to an organizational unit, xxxxx = Alphanumeric with hyphens or periods. The unit identifier portion corresponds to the POINT OF ORIGIN RESPONSIBLE AGENCY UNIT IDENTIFIER (POOResonsibleUnit) from the responsible unit’s corresponding fire report. Example: 2013-CORMP-000001

* `LOCAL_NUM` - Local incident identifier (dispatch number). A number or code that uniquely identifies an incident for a particular local fire management organization within a particular calendar year. Field is string to allow for leading zeros when the local incident identifier is less than 6 characters. (IRWIN required). Example: 123456.

* `UNIT_ID` - NWCG Unit Identifier of landowner/jurisdictional agency unit at the point of origin of a fire. (NFIRS ID should be used only when no NWCG Unit Identifier exists). Example: CORMP

* `COMMENTS` - Additional information describing the feature. Free Text.

* `FEATURE_CA` - Type of wildland fire polygon: Wildfire (represents final fire perimeter or last daily fire perimeter available) or Prescribed Fire or Unknown

* `GEO_ID` - Primary key for linking geospatial objects with other database systems. Required for every feature. This field may be renamed for each standard to fit the feature. Globally Unique Identifier (GUID).

## Cross-Walk from sources (GeoID) and other processing notes

* AK: GEOID = OBJECT ID of provided file geodatabase (4580 Records thru 2021), other federal sources for AK data removed. 

* CA: GEOID = OBJECT ID of downloaded file geodatabase (12776 Records, federal fires removed, includes RX)

* FWS: GEOID = OBJECTID of service download combined history 2005-2021 (2052 Records). Handful of WFIGS (11) fires added that were not in FWS record.

* BIA: GEOID = "FireID" 2017/2018 data (416 records) provided or WFDSS PID (415 records). An additional 917 fires from WFIGS were added, GEOID=GLOBALID in source.

* NPS: GEOID = EVENT ID (IRWINID or FRM_ID from FOD), 29,943 records includes RX.

* BLM: GEOID = GUID from BLM FPER and GLOBALID from WFIGS. Date Current = best available modify_date, create_date, fire_cntrl_dt or fire_dscvr_dt to reduce the number of 9999 entries in FireYear. Source FPER (25,389 features), WFIGS (5357 features)

* USFS: GEOID=GLOBALID in source, 46,574 features. Also fixed Date Current to best available date from perimeterdatetime, revdate, discoverydatetime, dbsourcedate to reduce number of 1899 entries in FireYear.


