# FEMA Disaster Summaries

Source: https://www.fema.gov/openfema-data-page/disaster-declarations-summaries-v2

## Summary

Disaster Declarations Summaries is a summarized dataset describing all federally declared disasters. This dataset lists all official FEMA Disaster Declarations, beginning with the first disaster declaration in 1953 and features all three disaster declaration types: major disaster, emergency, and fire management assistance. The dataset includes declared recovery programs and geographic areas (county not available before 1964; Fire Management records are considered partial due to historical nature of the dataset).

Please note the unique structure of the disaster sequencing (due to a numbering system that originated in the 1950's-1970's):

0001-1999 Major Disaster Declaration

2000-2999 Fire Management

3000-3999 Emergency Declaration (Special Emergency)

4000-4999 Major Disaster Declaration

5000-5999 Fire Management

## Fields 

 * `femaDeclarationString`  - FEMA Declaration String  - text - Agency standard method for uniquely identifying Stafford Act declarations - Concatenation of declaration type, disaster number and state code. Ex: DR-4393-NC
 * `disasterNumber`  - Disaster Number  - smallint - Sequentially assigned number used to designate an event or incident declared as a disaster. For more information on the disaster process, please visit https://www.fema.gov/disasters/how-declared
 * `state`  - State  - text - The name or phrase describing the U.S. state, district, or territory
 * `declarationType`  - Declaration Type  - text - Two character code that defines if this is a major disaster, fire management, or emergency declaration. For more information on the disaster process, please visit https://www.fema.gov/disasters/how-declared
 * `declarationDate`  - Declaration Date  - date - Date the disaster was declared
 * `fyDeclared`  - FY Declared  - smallint - Fiscal year in which the disaster was declared
 * `incidentType`  - Incident Type  - text - Type of incident such as fire or flood. For more information on incident types, please visit https://www.fema.gov/disasters/how-declared.
 * `declarationTitle`  - Declaration Title  - text - Title for the disaster
 * `ihProgramDeclared`  - IH Program Declared  - boolean - Denotes whether the Individuals and Households program was declared for this disaster. For more information on the program, please visit https://www.fema.gov/assistance/individual/program. To determine which FEMA events have been authorized to receive Individual Assistance, use both ihProgramDeclared and iaProgramDeclared. For more information see https://www.fema.gov/about/openfema/faq
 * `iaProgramDeclared`  - IA Program Declared  - boolean - Denotes whether the Individual Assistance program was declared for this disaster. For more information on the program, please visit https://www.fema.gov/assistance/individual/program. To determine which FEMA events have been authorized to receive Individual Assistance, use both ihProgramDeclared and iaProgramDeclared. For more information see https://www.fema.gov/about/openfema/faq
 * `paProgramDeclared`  - PA Program Declared  - boolean - Denotes whether the Public Assistance program was declared for this disaster. For more information on the program, please visit https://www.fema.gov/assistance/public/program-overview
 * `hmProgramDeclared`  - HM Program Declared  - boolean - Denotes whether the Hazard Mitigation program was declared for this disaster. For more information on the program, please visit https://www.fema.gov/grants/mitigation/hazard-mitigation
 * `incidentBeginDate`  - Incident Begin Date  - date - Date the incident itself began
 * `incidentEndDate`  - Incident End Date  - date - Date the incident itself ended
 * `disasterCloseoutDate`  - Disaster Closeout Date  - date - Date all financial transactions for all programs are completed
 * `tribalRequest`  - Tribal Request  - boolean - Denotes that a declaration request was submitted directly to the President, independently of a state, by a Tribal Nation.
 * `fipsStateCode`  - FIPS State Code  - text - FIPS two-digit numeric code used to identify the United States, the District of Columbia, US territories, outlying areas of the US and freely associated states
 * `fipsCountyCode`  - FIPS County Code  - text - FIPS three-digit numeric code used to identify counties and county equivalents in the United States, the District of Columbia, US territories, outlying areas of the US and freely associated states. Please note that Indian Reservations are not counties and thus will not have a FIPS county code, please utilize the placeCode field instead. If the designation is made for the entire state, this value will be 000 as multiple (all) counties cannot be entered.
 * `placeCode`  - Place Code  - text - A unique code system FEMA uses internally to recognize locations that takes the numbers '99' + the 3-digit county FIPS code. There are some declared locations that dont have recognized FIPS county codes in which case we assigned a unique identifier
 * `designatedArea`  - Designated Area  - text - The name or phrase describing the geographic area that was included in the declaration
 * `declarationRequestNumber`  - Declaration Request Number  - text - Number assigned to the declaration request
 * `lastIAFilingDate`  - Last IA Filing Date  - date - Last date when IA requests can be filed. Data available after 1998 only. The date only applies if IA has been approved for the disaster.
 * `lastRefresh`  - Last Refresh  - datetime - Date the record was last updated in the API data store
 * `hash`  - Hash  - text - MD5 Hash of the fields and values of the record  - no
 * `id`  - ID  - uuid - Unique ID assigned to the record
 