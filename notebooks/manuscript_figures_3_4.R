## ---------------------------
## EMB
## created: 2025-02-28
## last updated:
## goal:
##
## ---------------------------
## notes:
##
##
## ---------------------------
# setup ---------------------------
# install and load packages
if(!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")
pacman::p_load(here, readr, dplyr, tidyr, stringr, purrr,
               forcats, geofacet, lubridate, snakecase, ggplot2,
               ggthemes,rlang, ggmap, sf, tigris, tidyverse,
               ggnewscale, gridExtra, readxl, survey, gtsummary,
               MetBrewer, PNWColors, biscale, patchwork, arrow, geojsonR, cdlTools)
custom_pal <- c("#E38265", "#F4C988", "#EBAA6C", "#F2BF9D",
                "#DE858D", "#E9AC7F", "#FAEAB8")
rev_pal <- rev.default(custom_pal)
archambault <- c("#88A0DC", "#381A61", "#7C4B73", "#ED968C",
                 "#AB3329", "#E78429", "#F9D14A")
rev_archambault <- rev.default(archambault)

counties <- counties() %>%
  st_transform(counties, crs = "ESRI:102003") %>%
  select(c(STATEFP, NAME, geometry))
counties$state_abbr <- fips(counties$STATEFP, to = "Abbreviation")
ca_counties <- counties %>%
  filter(STATEFP == "06")
fl_counties  <- counties %>%
  filter(STATEFP == "12")

# read and clean data ---------------------------
# read in all 3 file using function to clean and create composite criteria
readin <- function(df_csv) {
  df <- st_read(df_csv) %>%
    filter(wildfire_community_intersect) %>%
    mutate(composite_measure = case_when(
      wildfire_disaster_criteria_met == "civilian_death|structures_destroyed|fema_fmag_declaration" ~ "All 3 Criteria Met",
      wildfire_disaster_criteria_met == "civilian_death" ~ "Civilian Fatality",
      wildfire_disaster_criteria_met == "structures_destroyed" ~ "Structure Destroyed",
      wildfire_disaster_criteria_met == "fema_fmag_declaration" ~ "FMAG",
      wildfire_disaster_criteria_met == "civilian_death|structures_destroyed" ~ "Civilian Fatality and Structure Destroyed",
      wildfire_disaster_criteria_met == "civilian_death|fema_fmag_declaration" ~ "Civilian Fatality and FMAG",
      wildfire_disaster_criteria_met == "structures_destroyed|fema_fmag_declaration" ~ "Structure Destroyed and FMAG",
      TRUE ~ "Unknown"
    ))
  df$composite_measure <- as.factor(df$composite_measure)
  df <- st_as_sf(df)
}

usa_disasters <- readin("wfbz.geojson")
ng_usa <- st_drop_geometry(usa_disasters)

# join df with counties to get unaggregated states for each fire (meaning
# if a fire occured in two states or counties it is double counted/counted for both)
usa_disaster_split <- st_join(usa_disasters, st_transform(counties, st_crs(usa_disasters)))

# now with counties and singular states remove geometry
ng_usa_split <- st_drop_geometry(usa_disaster_split)

# yearly wf counts by state using geofacet ---------------------------
# i am using the split state df so that if a wf crossed state lines
# it is counted in both states
ng_state_counts <- ng_usa_split %>%
  group_by(wildfire_year, STATEFP, state_abbr) %>%
  count() %>%
  mutate(adj_count_90 = case_when(n > 90 ~ 90, TRUE ~ n), 
         adj_count_75 = case_when(n > 75 ~ 75, TRUE ~ n),
         adj_count_50 = case_when(n > 50 ~ 50, TRUE ~ n),
         )

statewrap <- ggplot(ng_state_counts, aes(wildfire_year, adj_count_90)) +
  geom_col(fill="#92351E") +
  scale_x_continuous(breaks = c(2000, 2005, 2010, 2015, 2020)) +
  # scale_y_log10()+
   scale_y_continuous(breaks = c(0, 30, 60, 90)) +
  # ylim(0,75) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 90, size = 12),
    axis.text.y = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
  ) +
  labs(y = "Number of Wildfire Burn Zone Disasters",
       x = " ") +
  facet_geo(~state_abbr, grid = "us_state_without_DC_grid1")
statewrap
ggsave(here("figures", "statewrap_90.pdf"),
       statewrap,
       dpi=300, height=8, width=10, units="in")


# sectionheader ---------------------------

statewrap_test <- ggplot(ng_state_counts, aes(wildfire_year, adj_count_90)) +
  geom_col(fill="#92351E") +
  scale_x_continuous(breaks = c(2000, 2005, 2010, 2015, 2020)) +
  scale_y_continuous(breaks = c(0, 30, 60, 90)) +
  theme_bw() +
  theme(
    axis.text.x = element_text(angle = 90, size = 12, vjust = 0.5),
    # Adjust the margin for y-axis text to move it away from the axis
    axis.text.y = element_text(size = 12, margin = margin(r = 5, unit = "pt")),
    # Add padding to the tick marks to push labels outward
    axis.ticks.length = unit(0.3, "cm"),
    # Add padding around the plot panels
    panel.spacing = unit(0.5, "lines"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    # This will help create more space for the tick labels
    plot.margin = margin(t = 5, r = 5, b = 10, l = 10, unit = "pt")
  ) +
  labs(y = "Number of Wildfire Burn Zone Disasters",
       x = " ") +
  facet_geo(~state_abbr, grid = "us_state_without_DC_grid1")

statewrap_test <- statewrap_test + 
  theme(panel.spacing = unit(0.7, "lines"))  # Increase from default

ggsave(here("figures", "test.pdf"),
       statewrap_test,
       dpi=300, height=8, width=10, units="in")

# prepping for ca map ---------------------------
# similarly here using spilt so if boundary crossed county lines
# both counties will have that burn zone counted
ca_county_counts <- ng_usa_split %>%
  filter(STATEFP == c("06")) %>%
  group_by(NAME) %>%
  count()
ca_county_counts <- left_join(ca_counties, ca_county_counts, by = "NAME")
ca_county_counts <- ca_county_counts %>%
  mutate(n = coalesce(n, 0))

# creating labels for composite measures
comp.labs <- c("Structure Destroyed",
               "Structure Destroyed \n+ FMAG",
               "FMAG",
               "Civilian Fatality",
               "Met All \n3 Criteria",
               "Civilian Fatality \n+ Structure Destroyed")
names(comp.labs) <- c("Structure Destroyed",
                      "Structure Destroyed and FMAG",
                      "FMAG",
                      "Civilian Fatality",
                      "All 3 Criteria Met",
                      "Civilian Fatality and Structure Destroyed")
ca_polygons <- usa_disaster_split %>% filter(STATEFP %in% c("06"))
ca_cut <-st_intersection(ca_polygons, st_transform(ca_counties, st_crs(ca_polygons)))

# creating 2 maps and then patchworking ---------------------------
# 1. ca county counts map and 2. ca fire boundaries faceted by comp measure
comp_facet_map <- ggplot() +
  geom_sf(data = ca_counties, 
          fill = "#f0f0f0",
          size = 0.0001) +
  geom_sf(data = ca_cut, fill = "#E08214", color = "#E08214", size = 0.0001) +
	scale_fill_manual(values = c("#E08214")) +
  facet_wrap(~ composite_measure,
             labeller = labeller(composite_measure = comp.labs)) +
  theme_map()+
  theme(strip.text = element_text(size=11),
        strip.background = element_blank(),
        legend.position = "none")

county_map <- ggplot() +
  geom_sf(data = ca_county_counts, aes(fill=n)) +
  scale_fill_gradient(low = "white", high = "#E08214") +
  theme_map() +
  theme(legend.position = "bottom") +
  labs(fill = "Number of Wildfire \nBurn Zone Disasters")

california <- county_map + comp_facet_map +
  plot_layout(ncol = 2, widths = c(1, 1.5)) 

ggsave(here("figures", "california.pdf"),
       california,
       dpi=300, height=7.5, width=10, units="in")


# criteria bar plot whole US ---------------------------
# using the real counts so we do not double count disaster types
# criteria_barplot <- ng_usa %>%
#   arrange(composite_measure) %>%
#   mutate(composite_measure= factor(composite_measure,
#          levels=c("Structure Destroyed",
#           "Structure Destroyed and FMAG",
#           "FMAG",
#           "Civilian Fatality",
#           "All 3 Criteria Met",
#           "Civilian Fatality and Structure Destroyed",
#           "Civilian Fatality and FMAG"))) %>%
# ggplot(aes(x = composite_measure)) +
#   geom_bar(aes(fill=composite_measure), stat="count") +
#   coord_flip() +
#   scale_fill_manual(values = rev_pal) +
#   theme_classic() +
#   theme(legend.position = "none",
#         axis.text = element_text(size=13),
#         axis.title = element_text(size=15),
#         axis.ticks.y = ) +
#   labs(
#        y = "Number of Wildfire Disasters",
#        x = "Wildfire Disaster Criteria")
#
# criteria_barplot
#
# ggsave(here("figures", "criteria_barplot.png"),
#        criteria_barplot,
#        dpi=300, height=7.5, width=10, units="in")