# Wildfire Disasters Lite Summary Report


    [1] "data/02_processed/fire_pop_density_criteria.csv"

*Last run: 2025-08-15*

Output File Details:

wflite.geojson

- File Size: 356M
- File Checksum (md5): bdec9cace5850cdbda2e1b4a9af2cc4c

| data_set      | nobs_wflite | nobs_wfheavy |
|:--------------|------------:|-------------:|
| event_fema    |        1731 |         1339 |
| event_ics209  |       36532 |        32425 |
| event_redbook |        1375 |         1126 |
| event         |        7536 |        32512 |
| spatial_fired |      219383 |        98723 |
| spatial_mtbs  |       14321 |        20644 |
| spatial_nifc  |       62759 |        54158 |
| spatial       |        7954 |         5461 |

Burn Perimeter Join Types

| geometry_method              | n_wflite |
|:-----------------------------|---------:|
| FIRED by Place/Time          |     1312 |
| ICS by Point of Origin, Size |     4297 |
| MTBS by ID                   |      456 |
| MTBS by Name/Place/Time      |     1202 |
| NIFC by ID                   |       86 |
| NIFC by Name/Place/Time      |      601 |

## Documentation

See detailed documentation for the input and output data sets here:
<https://lpiep.github.io/wildfire_disasters_lite/>
