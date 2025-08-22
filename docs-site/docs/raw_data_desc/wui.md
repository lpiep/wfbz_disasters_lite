# Wildland-Urban Interface Delineation

Source: https://silvis.forest.wisc.edu/globalwui/

## Summary

> The wildland-urban interface (WUI) is where buildings and wildland vegetation meet or intermingle. It is where human-environmental conflicts and risks are concentrated, including the loss of houses and lives to wildfire, habitat loss and fragmentation, and the spread of zoonotic diseases. However, a global analysis of the WUI has been lacking.
> 
> This dataset features a global, 10 m resolution map of the wildland-urban interface, representative for ca. 2020.
> 
> The data are organized in tiles of 100 km x 100 km and follow the EQUI7 tiling grid and projection system. The images are compressed GeoTiff files (*.tif). There is a mosaic in GDAL Virtual format (*.vrt), which can readily be opened in most Geographic Information Systems. Please consider the generation of image pyramids before using *.vrt files.
> 
> In addition, the data contain tabular data on WUI area, population and biomass in the WUI, as well as wildfire area and people affected by wildfire in the WUI per world region, country, subnational administrative unit and biome.

## Bands 

 * `WUI` - Values:
   * Forest/Shrub/Wetl.-dominated intermix WUI
   * Forest/Shrub/Wetl.-dominated interface WUI
   * Grassland-dominated intermix WUI
   * Grassland-dominated interface WUI
   * Non-WUI: Forest/Shrub/Wetland
   * Non-WUI: Grassland
   * Non-WUI: Urban
   * Non-WUI: Other