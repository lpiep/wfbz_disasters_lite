# CALFIRE Red Books

Source: https://www.fire.ca.gov/our-impact/statistics (and direct correspondence Cal Fire)

## Summary

Lists of large fire incidents compiled by Cal Fire using state and federal data. Note that these data
are not released in a consistent, machine-readable format. When contacted, a representative at Cal
Fire did not believe there was a single database from which the annual report is drawn, and that there
was no guarantee about data format in the future. 

Data is pulled from the "Large Fires 300 Acres and Greater" table in each report. The subtitle for this
table indicates:

> The information on this list is gathered from the ICS 209 incident reports and Damage Inspection (DINS) 
database, then verified in the California Incident Data and Statistics (CalStats) database and includes 
information on fire activity within the Direct Protection Areas of CAL FIRE and Contract Counties.

## Fields 

_Field names may span rows._

* `Incident #` - Unclear what this links to
* `County` - County Name (e.g. "BUTTE")
* `Fire Name` - E.g. "AIRPORT"
* `Date Start` - start date of fire (MM/DD/YY)
* `Date Contained` - containment date of fire (MM/DD/YY)
* `Origin DPA` - The agency on whose Direct Protection Area (DPA) the fires started. (
"CC": Contract Counties, 
"LOCAL" = Local Fire Departments, 
"MIL" = Military Land, 
"BLM" = Bureau of Land Management, 
"BIA" = Bureau of Indian Affairs,
"FWS" = Fish and Wildlife Service,
"NPS" = National Park Service,
"USFS" = United States Forest Service). 
* `Acres Burned Total` - total area burned (sometimes also reported broken out by areas protected and not protected
by Cal Fire. 
* `Veg. Type` - Vegetation Type ("T" = Timber, "B" = Brush, "W" = Woodland, "G" = Grass, "A" = Agricultural Products)
* `Cause` - Free text. Categorization does not appear to be consistent across years. 
* `Structures Dest.` - Residence, commercial property, outbuilding, or other structure that is declared unusable.
* `Structures Dam.` - Residence, commercial property, outbuilding, or other structure that its usefulness or value is impaired.
* `Fatalities Fire` - Death of fire service personnel assigned to the incident.
* `Fatalities Civil` - Death of civilian service personnel assigned to the incident.

