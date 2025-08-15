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

row_counts %>% gt()
```

<div id="kzsnlkiojh" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#kzsnlkiojh table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#kzsnlkiojh thead, #kzsnlkiojh tbody, #kzsnlkiojh tfoot, #kzsnlkiojh tr, #kzsnlkiojh td, #kzsnlkiojh th {
  border-style: none;
}

#kzsnlkiojh p {
  margin: 0;
  padding: 0;
}

#kzsnlkiojh .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#kzsnlkiojh .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#kzsnlkiojh .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#kzsnlkiojh .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#kzsnlkiojh .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#kzsnlkiojh .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kzsnlkiojh .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#kzsnlkiojh .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#kzsnlkiojh .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#kzsnlkiojh .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#kzsnlkiojh .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#kzsnlkiojh .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#kzsnlkiojh .gt_spanner_row {
  border-bottom-style: hidden;
}

#kzsnlkiojh .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#kzsnlkiojh .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#kzsnlkiojh .gt_from_md > :first-child {
  margin-top: 0;
}

#kzsnlkiojh .gt_from_md > :last-child {
  margin-bottom: 0;
}

#kzsnlkiojh .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#kzsnlkiojh .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#kzsnlkiojh .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#kzsnlkiojh .gt_row_group_first td {
  border-top-width: 2px;
}

#kzsnlkiojh .gt_row_group_first th {
  border-top-width: 2px;
}

#kzsnlkiojh .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#kzsnlkiojh .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#kzsnlkiojh .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#kzsnlkiojh .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kzsnlkiojh .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#kzsnlkiojh .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#kzsnlkiojh .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#kzsnlkiojh .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#kzsnlkiojh .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#kzsnlkiojh .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#kzsnlkiojh .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#kzsnlkiojh .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#kzsnlkiojh .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#kzsnlkiojh .gt_left {
  text-align: left;
}

#kzsnlkiojh .gt_center {
  text-align: center;
}

#kzsnlkiojh .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#kzsnlkiojh .gt_font_normal {
  font-weight: normal;
}

#kzsnlkiojh .gt_font_bold {
  font-weight: bold;
}

#kzsnlkiojh .gt_font_italic {
  font-style: italic;
}

#kzsnlkiojh .gt_super {
  font-size: 65%;
}

#kzsnlkiojh .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#kzsnlkiojh .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#kzsnlkiojh .gt_indent_1 {
  text-indent: 5px;
}

#kzsnlkiojh .gt_indent_2 {
  text-indent: 10px;
}

#kzsnlkiojh .gt_indent_3 {
  text-indent: 15px;
}

#kzsnlkiojh .gt_indent_4 {
  text-indent: 20px;
}

#kzsnlkiojh .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="data_set">data_set</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="nobs_wflite">nobs_wflite</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="nobs_wfheavy">nobs_wfheavy</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="data_set" class="gt_row gt_left">event_fema</td>
<td headers="nobs_wflite" class="gt_row gt_right">1731</td>
<td headers="nobs_wfheavy" class="gt_row gt_right">1339</td></tr>
    <tr><td headers="data_set" class="gt_row gt_left">event_ics209</td>
<td headers="nobs_wflite" class="gt_row gt_right">36532</td>
<td headers="nobs_wfheavy" class="gt_row gt_right">32425</td></tr>
    <tr><td headers="data_set" class="gt_row gt_left">event_redbook</td>
<td headers="nobs_wflite" class="gt_row gt_right">1375</td>
<td headers="nobs_wfheavy" class="gt_row gt_right">1126</td></tr>
    <tr><td headers="data_set" class="gt_row gt_left">event</td>
<td headers="nobs_wflite" class="gt_row gt_right">7536</td>
<td headers="nobs_wfheavy" class="gt_row gt_right">32512</td></tr>
    <tr><td headers="data_set" class="gt_row gt_left">spatial_fired</td>
<td headers="nobs_wflite" class="gt_row gt_right">219383</td>
<td headers="nobs_wfheavy" class="gt_row gt_right">98723</td></tr>
    <tr><td headers="data_set" class="gt_row gt_left">spatial_mtbs</td>
<td headers="nobs_wflite" class="gt_row gt_right">14321</td>
<td headers="nobs_wfheavy" class="gt_row gt_right">20644</td></tr>
    <tr><td headers="data_set" class="gt_row gt_left">spatial_nifc</td>
<td headers="nobs_wflite" class="gt_row gt_right">62759</td>
<td headers="nobs_wfheavy" class="gt_row gt_right">54158</td></tr>
    <tr><td headers="data_set" class="gt_row gt_left">spatial</td>
<td headers="nobs_wflite" class="gt_row gt_right">7954</td>
<td headers="nobs_wfheavy" class="gt_row gt_right">5461</td></tr>
  </tbody>
  
  
</table>
</div>

Burn Perimeter Join Types

``` r
tar_read(spatial) %>%
    st_drop_geometry() %>% 
    group_by(geometry_method) %>%
    summarize(n_wflite = n()) %>%
    gt()
```

<div id="cwpruzlchc" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
<style>#cwpruzlchc table {
  font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

#cwpruzlchc thead, #cwpruzlchc tbody, #cwpruzlchc tfoot, #cwpruzlchc tr, #cwpruzlchc td, #cwpruzlchc th {
  border-style: none;
}

#cwpruzlchc p {
  margin: 0;
  padding: 0;
}

#cwpruzlchc .gt_table {
  display: table;
  border-collapse: collapse;
  line-height: normal;
  margin-left: auto;
  margin-right: auto;
  color: #333333;
  font-size: 16px;
  font-weight: normal;
  font-style: normal;
  background-color: #FFFFFF;
  width: auto;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #A8A8A8;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #A8A8A8;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
}

#cwpruzlchc .gt_caption {
  padding-top: 4px;
  padding-bottom: 4px;
}

#cwpruzlchc .gt_title {
  color: #333333;
  font-size: 125%;
  font-weight: initial;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-color: #FFFFFF;
  border-bottom-width: 0;
}

#cwpruzlchc .gt_subtitle {
  color: #333333;
  font-size: 85%;
  font-weight: initial;
  padding-top: 3px;
  padding-bottom: 5px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-color: #FFFFFF;
  border-top-width: 0;
}

#cwpruzlchc .gt_heading {
  background-color: #FFFFFF;
  text-align: center;
  border-bottom-color: #FFFFFF;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#cwpruzlchc .gt_bottom_border {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#cwpruzlchc .gt_col_headings {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
}

#cwpruzlchc .gt_col_heading {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 6px;
  padding-left: 5px;
  padding-right: 5px;
  overflow-x: hidden;
}

#cwpruzlchc .gt_column_spanner_outer {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: normal;
  text-transform: inherit;
  padding-top: 0;
  padding-bottom: 0;
  padding-left: 4px;
  padding-right: 4px;
}

#cwpruzlchc .gt_column_spanner_outer:first-child {
  padding-left: 0;
}

#cwpruzlchc .gt_column_spanner_outer:last-child {
  padding-right: 0;
}

#cwpruzlchc .gt_column_spanner {
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: bottom;
  padding-top: 5px;
  padding-bottom: 5px;
  overflow-x: hidden;
  display: inline-block;
  width: 100%;
}

#cwpruzlchc .gt_spanner_row {
  border-bottom-style: hidden;
}

#cwpruzlchc .gt_group_heading {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  text-align: left;
}

#cwpruzlchc .gt_empty_group_heading {
  padding: 0.5px;
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  vertical-align: middle;
}

#cwpruzlchc .gt_from_md > :first-child {
  margin-top: 0;
}

#cwpruzlchc .gt_from_md > :last-child {
  margin-bottom: 0;
}

#cwpruzlchc .gt_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  margin: 10px;
  border-top-style: solid;
  border-top-width: 1px;
  border-top-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 1px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 1px;
  border-right-color: #D3D3D3;
  vertical-align: middle;
  overflow-x: hidden;
}

#cwpruzlchc .gt_stub {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
}

#cwpruzlchc .gt_stub_row_group {
  color: #333333;
  background-color: #FFFFFF;
  font-size: 100%;
  font-weight: initial;
  text-transform: inherit;
  border-right-style: solid;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
  padding-left: 5px;
  padding-right: 5px;
  vertical-align: top;
}

#cwpruzlchc .gt_row_group_first td {
  border-top-width: 2px;
}

#cwpruzlchc .gt_row_group_first th {
  border-top-width: 2px;
}

#cwpruzlchc .gt_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#cwpruzlchc .gt_first_summary_row {
  border-top-style: solid;
  border-top-color: #D3D3D3;
}

#cwpruzlchc .gt_first_summary_row.thick {
  border-top-width: 2px;
}

#cwpruzlchc .gt_last_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#cwpruzlchc .gt_grand_summary_row {
  color: #333333;
  background-color: #FFFFFF;
  text-transform: inherit;
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
}

#cwpruzlchc .gt_first_grand_summary_row {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-top-style: double;
  border-top-width: 6px;
  border-top-color: #D3D3D3;
}

#cwpruzlchc .gt_last_grand_summary_row_top {
  padding-top: 8px;
  padding-bottom: 8px;
  padding-left: 5px;
  padding-right: 5px;
  border-bottom-style: double;
  border-bottom-width: 6px;
  border-bottom-color: #D3D3D3;
}

#cwpruzlchc .gt_striped {
  background-color: rgba(128, 128, 128, 0.05);
}

#cwpruzlchc .gt_table_body {
  border-top-style: solid;
  border-top-width: 2px;
  border-top-color: #D3D3D3;
  border-bottom-style: solid;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
}

#cwpruzlchc .gt_footnotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#cwpruzlchc .gt_footnote {
  margin: 0px;
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#cwpruzlchc .gt_sourcenotes {
  color: #333333;
  background-color: #FFFFFF;
  border-bottom-style: none;
  border-bottom-width: 2px;
  border-bottom-color: #D3D3D3;
  border-left-style: none;
  border-left-width: 2px;
  border-left-color: #D3D3D3;
  border-right-style: none;
  border-right-width: 2px;
  border-right-color: #D3D3D3;
}

#cwpruzlchc .gt_sourcenote {
  font-size: 90%;
  padding-top: 4px;
  padding-bottom: 4px;
  padding-left: 5px;
  padding-right: 5px;
}

#cwpruzlchc .gt_left {
  text-align: left;
}

#cwpruzlchc .gt_center {
  text-align: center;
}

#cwpruzlchc .gt_right {
  text-align: right;
  font-variant-numeric: tabular-nums;
}

#cwpruzlchc .gt_font_normal {
  font-weight: normal;
}

#cwpruzlchc .gt_font_bold {
  font-weight: bold;
}

#cwpruzlchc .gt_font_italic {
  font-style: italic;
}

#cwpruzlchc .gt_super {
  font-size: 65%;
}

#cwpruzlchc .gt_footnote_marks {
  font-size: 75%;
  vertical-align: 0.4em;
  position: initial;
}

#cwpruzlchc .gt_asterisk {
  font-size: 100%;
  vertical-align: 0;
}

#cwpruzlchc .gt_indent_1 {
  text-indent: 5px;
}

#cwpruzlchc .gt_indent_2 {
  text-indent: 10px;
}

#cwpruzlchc .gt_indent_3 {
  text-indent: 15px;
}

#cwpruzlchc .gt_indent_4 {
  text-indent: 20px;
}

#cwpruzlchc .gt_indent_5 {
  text-indent: 25px;
}
</style>
<table class="gt_table" data-quarto-disable-processing="false" data-quarto-bootstrap="false">
  <thead>
    
    <tr class="gt_col_headings">
      <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="geometry_method">geometry_method</th>
      <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1" scope="col" id="n_wflite">n_wflite</th>
    </tr>
  </thead>
  <tbody class="gt_table_body">
    <tr><td headers="geometry_method" class="gt_row gt_left">FIRED by Place/Time</td>
<td headers="n_wflite" class="gt_row gt_right">1312</td></tr>
    <tr><td headers="geometry_method" class="gt_row gt_left">ICS by Point of Origin, Size</td>
<td headers="n_wflite" class="gt_row gt_right">4297</td></tr>
    <tr><td headers="geometry_method" class="gt_row gt_left">MTBS by ID</td>
<td headers="n_wflite" class="gt_row gt_right">456</td></tr>
    <tr><td headers="geometry_method" class="gt_row gt_left">MTBS by Name/Place/Time</td>
<td headers="n_wflite" class="gt_row gt_right">1202</td></tr>
    <tr><td headers="geometry_method" class="gt_row gt_left">NIFC by ID</td>
<td headers="n_wflite" class="gt_row gt_right">86</td></tr>
    <tr><td headers="geometry_method" class="gt_row gt_left">NIFC by Name/Place/Time</td>
<td headers="n_wflite" class="gt_row gt_right">601</td></tr>
  </tbody>
  
  
</table>
</div>

## Documentation

See detailed documentation for the input and output data sets here:
<https://lpiep.github.io/wildfire_disasters_lite/>
