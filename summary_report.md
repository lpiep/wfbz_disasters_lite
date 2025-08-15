Wildfire Disasters Lite Summary Report
================

``` r
library(tidyverse)
library(targets)
library(gt)
library(sf)
output_file <- tar_read(output_file)
data <- tar_read(pop_density)
head(data)
```

    ## [1] "data/02_processed/fire_pop_density_criteria.csv"

*Last run: 2025-08-15*

Output File Details:

wflite.geojson

-   File Size: 356M
-   File Checksum (md5): bdec9cace5850cdbda2e1b4a9af2cc4c

``` r
row_counts <- tribble(
    ~data_set, ~nobs_wflite, ~nobs_wfheavy,
    'event_fema'    , nrow(tar_read(event_fema)),     1339,
    'event_ics209'  , nrow(tar_read(event_ics209)),  32425,
    'event_redbook' , nrow(tar_read(event_redbook)),  1126,
    'event'         , nrow(tar_read(event)),         32512, 
    'spatial_fired' , nrow(tar_read(spatial_fired)), 98723,
    'spatial_mtbs'  , nrow(tar_read(spatial_mtbs)),  20644,
    'spatial_nifc'  , nrow(tar_read(spatial_nifc)),  54158,
    'spatial'       , nrow(tar_read(spatial)),        5461
)

row_counts
```

    ## # A tibble: 8 × 3
    ##   data_set      nobs_wflite nobs_wfheavy
    ##   <chr>               <int>        <dbl>
    ## 1 event_fema           1731         1339
    ## 2 event_ics209        36532        32425
    ## 3 event_redbook        1375         1126
    ## 4 event                7536        32512
    ## 5 spatial_fired      219383        98723
    ## 6 spatial_mtbs        14321        20644
    ## 7 spatial_nifc        62759        54158
    ## 8 spatial              7954         5461

Burn Perimeter Join Types

``` r
tar_read(spatial) %>%
    st_drop_geometry() %>% 
    group_by(geometry_method) %>%
    summarize(n_wflite = n())
```

    ## # A tibble: 6 × 2
    ##   geometry_method              n_wflite
    ##   <chr>                           <int>
    ## 1 FIRED by Place/Time              1312
    ## 2 ICS by Point of Origin, Size     4297
    ## 3 MTBS by ID                        456
    ## 4 MTBS by Name/Place/Time          1202
    ## 5 NIFC by ID                         86
    ## 6 NIFC by Name/Place/Time           601

## Documentation

See detailed documentation for the input and output data sets here:
<https://lpiep.github.io/wildfire_disasters_lite/>
