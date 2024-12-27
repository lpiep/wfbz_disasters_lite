#! /usr/bin/env bash

mkdir -p $(dirname "$0")/../data/01_raw/pop_data
cd $(dirname "$0")/../data/01_raw/pop_data 

# download ghsl data (100m resolution)

# download raw zips
curl https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2000_GLOBE_R2023A_54009_100/V1-0/GHS_POP_E2000_GLOBE_R2023A_54009_100_V1_0.zip --output GHS_POP_E2000_GLOBE_R2023A_54009_100_V1_0.zip
curl https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2005_GLOBE_R2023A_54009_100/V1-0/GHS_POP_E2005_GLOBE_R2023A_54009_100_V1_0.zip --output GHS_POP_E2005_GLOBE_R2023A_54009_100_V1_0.zip
curl https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2010_GLOBE_R2023A_54009_100/V1-0/GHS_POP_E2010_GLOBE_R2023A_54009_100_V1_0.zip --output GHS_POP_E2010_GLOBE_R2023A_54009_100_V1_0.zip 
curl https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2015_GLOBE_R2023A_54009_100/V1-0/GHS_POP_E2015_GLOBE_R2023A_54009_100_V1_0.zip --output GHS_POP_E2015_GLOBE_R2023A_54009_100_V1_0.zip 
curl https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2020_GLOBE_R2023A_54009_100/V1-0/GHS_POP_E2020_GLOBE_R2023A_54009_100_V1_0.zip --output GHS_POP_E2020_GLOBE_R2023A_54009_100_V1_0.zip

# unzip files
unzip -j GHS_POP_E2000_GLOBE_R2023A_54009_100_V1_0.zip GHS_POP_E2000_GLOBE_R2023A_54009_100_V1_0.tif
unzip -j GHS_POP_E2005_GLOBE_R2023A_54009_100_V1_0.zip GHS_POP_E2005_GLOBE_R2023A_54009_100_V1_0.tif
unzip -j GHS_POP_E2010_GLOBE_R2023A_54009_100_V1_0.zip GHS_POP_E2010_GLOBE_R2023A_54009_100_V1_0.tif
unzip -j GHS_POP_E2015_GLOBE_R2023A_54009_100_V1_0.zip GHS_POP_E2015_GLOBE_R2023A_54009_100_V1_0.tif
unzip -j GHS_POP_E2020_GLOBE_R2023A_54009_100_V1_0.zip GHS_POP_E2020_GLOBE_R2023A_54009_100_V1_0.tif


# Download raw zips
# wget -v https://socscape.edu.pl/socscape_data/us_grids/us_pop/us_pop2000myc.zip
# wget -v https://socscape.edu.pl/socscape_data/us_grids/us_pop/us_pop2010myc.zip
# wget -v https://socscape.edu.pl/socscape_data/us_grids/us_pop/us_pop2020myc.zip
# wget -v https://data.worldpop.org/GIS/Population/Global_2000_2020_1km/2000/USA/50_US_states_1km_2000.zip
# wget -v https://data.worldpop.org/GIS/Population/Global_2000_2020_1km/2010/USA/50_US_states_1km_2010.zip
# wget -v https://data.worldpop.org/GIS/Population/Global_2000_2020_1km/2020/USA/50_US_states_1km_2020.zip

# Extract full 30m zips
# unzip us_pop2000myc.zip
# unzip us_pop2010myc.zip
# unzip us_pop2020myc.zip

# Extract needed files from 1km zips
# unzip -j 50_US_states_1km_2000.zip US-HI_ppp_2000_1km.tif  
# unzip -j 50_US_states_1km_2000.zip US-AK_ppp_2000_1km.tif 
# unzip -j 50_US_states_1km_2010.zip US-HI_ppp_2010_1km.tif  
# unzip -j 50_US_states_1km_2010.zip US-AK_ppp_2010_1km.tif 
# unzip -j 50_US_states_1km_2020.zip US-HI_ppp_2020_1km.tif  
# unzip -j 50_US_states_1km_2020.zip US-AK_ppp_2020_1km.tif 

# Remove unneeded zips
# rm -f us_pop20*myc.zip
# rm -f 50_US_states_1km_20*.zip 
