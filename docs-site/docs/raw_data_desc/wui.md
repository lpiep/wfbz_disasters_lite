# Wildland-Urban Interface Delineation

Source: https://www.fs.usda.gov/rds/archive/catalog/RDS-2015-0012-4

## Summary

> The Wildland-Urban Interface (WUI) is the area where houses meet or intermingle with undeveloped 
> wildland vegetation. This makes the WUI a focal area for human-environment conflicts such as 
> wildland fires, habitat fragmentation, invasive species, and biodiversity decline. 
> Using geographic information systems (GIS), we integrated U.S. Census and USGS National 
> Land Cover Data, to map the Federal Register definition of WUI (Federal Register 66:751, 2001) 
> for the conterminous United States from 1990-2020. These data are useful within a GIS for 
> mapping and analysis at national, state, and local levels. Data are available as a geodatabase 
> and include information such as housing densities for 1990, 2000, 2010, and 2020; wildland 
> vegetation percentages for 1992, 2001, 2011, and 2019; as well as WUI classes in 1990, 2000, 
> 2010, and 2020.This WUI feature class is separate from the WUI datasets maintained by 
> individual forest unites, and it is not the authoritative source data of WUI for forest units. 
> This dataset shows change over time in the WUI data up to 2020.

## Fields 

 * `OBJECTID` - Internal feature number.
 * `Shape` -  Feature geometry.
 * `BLK20` - A unique number assigned to Census Blocks concatenated from State, County, Tract, and Block, and Water fields from US Census TIGER. The Census Bureau defines a block as the smallest geographic area for which the Bureau of the Census collects and tabulates decennial census data, [and] are formed by streets, roads, railroads, streams and other bodies of water, other visible and cultural features, and the legal boundaries shown on Census Bureau maps (U.S. Census Bureau).
 * `WATER20` -         Flag if polygon is a water body using 2020 TIGER water bodies (1=water)
 * `AWATER20PC` -      % of block area that is water
 * `POP2020` -      2020 population
 * `HU2020` -        2020 total housing units
 * `OCCHU2020` -         2020 occupied housing units
 * `VACHU2020` - 2020 vacant housing units
 * `POPDEN2020` -        2020 population density (persons / square km)
 * `HUDEN2020` -         2020 total housing density (units / square km)
 * `OCCHUDEN2020` -        2020 occupied housing density (units / square km)
 * `VACHUDEN2020` -       2020 vacant housing density (units / square km)
 * `PUBFLAG` -         Flag if polygon is a protected area (1=public land)
 * `STATE` -        2 letter state abbreviation
 * `HU1990` -        1990 total housing units (allocated)
 * `HUDEN1990` -   1990 housing density (units / square km)
 * `HU2000` -       2000 total housing units (allocated)
 * `HUDEN2000` -         2000 total housing density (units / square km)
 * `HU2010` -         2010 total housing units (allocated)
 * `HUDEN2010` -         2010 housing density (units / square km)
 * `VEG1992PC` -         Wildland Vegetation % in 1992 where wildland vegetation = (forests + grasslands + wetlands)
 * `VEG2001PC` -         Wildland Vegetation % in 2001 where wildland vegetation = (forests + grasslands + wetlands)
 * `VEG2011PC` -         Wildland Vegetation % in 2011 where wildland vegetation = (forests + grasslands + wetlands)
 * `VEG2019PC` -         Wildland Vegetation % in 2019 where wildland vegetation = (forests + grasslands + wetlands)
 * `WUIFLAG1990` -        Flag designating WUI (1=intermix; 2=interface) vs. non-WUI (0) areas in 1990
 * `WUICLASS1990` -        1990 WUI class (see enumerated domains for WUICLASS2020)
 * `WUIFLAG2000` -         Flag designating WUI (1=intermix; 2=interface) vs. non-WUI (0) areas in 2000
 * `WUICLASS2000` -         2000 WUI class (see enumerated domains for WUICLASS2020)
 * `WUIFLAG2010` -         Flag designating WUI (1=intermix; 2=interface) vs. non-WUI (0) areas in 2010
 * `WUICLASS2010` -        2010 WUI class (see enumerated domains for WUICLASS2020)
 * `WUIFLAG2020` -         Flag designating WUI (1=intermix; 2=interface) vs. non-WUI (0) areas in 2020
 * `WUICLASS2020` -        2020 WUI class
    * Water - open water
    * Med_Dens_Interface - housing density between 49.42108 and 741.3162 and wildland vegetation <= 50% and within 2.414 km of area with >= 75% wildland vegetation
    * High_Dens_Intermix - housing density >= 741.3162 and wildland vegetation > 50%
    * Low_Dens_Interface -     housing density between 6.177635 and 49.42108 and wildland vegetation <= 50% and within 2.414 km of area with >= 75% wildland vegetation
    * Med_Dens_Intermix -     housing density between 49.42108 and 741.3162 and wildland vegetation > 50%
    * Low_Dens_NoVeg -     housing density between 6.177635 and 49.42108 and wildland vegetation <= 50%
    * Med_Dens_NoVeg -     housing density between 49.42108 and 741.3162 and wildland vegetation <= 50%
    * Uninhabited_NoVeg -     housing density = 0 and wildland vegetation <= 50%
    * Low_Dens_Intermix -     housing density between 6.177635 and 49.42108 and wildland vegetation > 50%
    * High_Dens_Interface -     housing density >= 741.3162 and wildland vegetation <= 50% and within 2.414 km of area with >= 75% wildland vegetation
    * Very_Low_Dens_Veg -     housing density < 6.177635 and wildland vegetation > 50%
    * Uninhabited_Veg -     housing density = 0 and wildland vegetation > 50%
    * Very_Low_Dens_NoVeg -     housing density < 6.177635 and wildland vegetation <= 50%
    * High_Dens_NoVeg -     housing density >= 741.3162 and wildland vegetation <= 50%
 * `BUFVEG` - flag (1=inside, 0=outside) for polygons within potential interface buffers (2.14 km around dense vegetation areas >= 75% wildland vegetation and > 500 hectares in 2020)
 * `FIPS` -         U.S. County Federal Information Processing Standards (FIPS) code.

