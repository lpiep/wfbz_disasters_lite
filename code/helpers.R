STATE_FIPS <- data.frame(
   STATE_ABB = c("AL", "AK", "AZ", "AR", "CA", "CO", 
             "CT", "DE", "DC", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", 
             "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", 
             "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", 
             "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", 
             "WY", "AS", "GU", "MP", "PR", "UM", "VI"), 
   STATE_FIPS = c("01", 
                 "02", "04", "05", "06", "08", "09", "10", "11", "12", "13", "15", 
                 "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", 
                 "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", 
                 "38", "39", "40", "41", "42", "44", "45", "46", "47", "48", "49", 
                 "50", "51", "53", "54", "55", "56", "60", "66", "69", "72", "74", 
                 "78")
)

unzip_url <- function(url, dst) {
  download.file(
    url = url,
    destfile = t <- tempfile(fileext = ".zip")
  )
  unzip(t, overwrite = TRUE, exdir = dst)
  unlink(t, recursive = TRUE)
  dst
}

# Defaults: up to one hour total
unzip_url <- function(url, dst, timeout = 60*60) {

	if (!dir.exists(dst)) {
		dir.create(dst, recursive = TRUE)
	}
	
	temp_zip <- tempfile(fileext = ".zip")
	on.exit(unlink(temp_zip, force = TRUE), add = TRUE)
	
	cat("Starting streaming download of", basename(url), "...\n")
	
	# Stream download (for very large files)
	tryCatch({
		response <- httr::GET(
			url,
			httr::write_disk(temp_zip, overwrite = TRUE),
			httr::progress(),
			httr::timeout(timeout)
		)
		
		httr::stop_for_status(response)
		
		if (!file.exists(temp_zip) || file.size(temp_zip) == 0) {
			stop("Streaming download failed or file is empty")
		}
		
	}, error = function(e) {
		stop("Streaming download failed: ", e$message)
	})
	
	cat("Extracting files...\n")
	
	tryCatch({
		extracted_files <- unzip(temp_zip, exdir = dst, overwrite = TRUE)
		cat("Successfully extracted", length(extracted_files), "files to", dst, "\n")
		
	}, error = function(e) {
		stop("Extraction failed: ", e$message)
	})
	
	return(dst)
}

# For spatial data frames, use TIGER data to identify county or counties. Will create a duplicate row for each overlapping county
append_county <- function(dat_sf, refdate, spatial_tiger_counties){
   stopifnot('sf' %in% class(dat_sf))
   
   # Split by decade & join in appropriate census
   dat_sf <- dat_sf %>% 
      split(year(floor_date(refdate, '10 years')))
   
   map(names(dat_sf), function(decade) st_join(dat_sf[[decade]], spatial_tiger_counties[[decade]], left = TRUE)) %>%
      bind_rows()
   
}

dedupe_pipe_delim <- function(z){
   str_split(z, pattern = '\\|') %>% 
      map(unique) %>% 
			map(~ setdiff(.x, 'NA')) %>% 
			map(sort) %>% 
			map(paste, collapse = '|') %>% 
      unlist() %>%
      na_if('')
}

standardize_county_name <- function(county_name){

   county_name <- str_replace_all(county_name,"[^[:graph:]]", " ") # replace non-printable chars
   
   # try to split multiple counties with bar
   county_name <- str_replace_all(county_name, '\\s*(/|,|&)\\s*', '|') 
   county_name <- str_replace_all(county_name, '\\s+AND\\s+', '|') 
   county_name <- str_replace_all(county_name, '-', '|') 
   
   # get dangling state abbreviations
   county_name <- str_replace(county_name, '[\\ ,][A-Z]{2}$', '')
   county_name <- str_replace_all(county_name, '[\\ ,][A-Z]{2}(?=\\|)', '')
   
   county_name <- toupper(county_name)
   county_name <- na_if(county_name, 'N/A') 
   county_name <- na_if(county_name, 'NA') 
   county_name <- str_replace(county_name, ', [A-Z]{2}$', '') # remove state abbreviations
   county_name <- str_replace(county_name, '\\s+(COUNTY|CTY|CO|CITY|BOROUGH|BORO|PARISH|CENSUS AREA)$', '') # remove "county" or equiv
   county_name <- str_replace(county_name, 'LEWIS\\|CLARK', 'LEWIS AND CLARK') # fix these counties with an AND in name
   county_name <- str_replace(county_name, 'LAKE\\|PENINSULA', 'LAKE AND PENINSULA') # fix these counties with an AND in name
   county_name <- str_replace(county_name, 'KING\\|QUEEN', 'KING AND QUEEN') # fix these counties with an AND in name
   county_name <- str_replace(county_name, '\\bSTE(\\.|\\s)\\s*', 'SAINTE ') # Unabbreviate SAINTE
   county_name <- str_replace(county_name, '\\bST(\\.|\\s)\\s*', 'SAINT ') # Unabbreviate SAINT
   
   # standardize some important counties
   county_name <- str_replace(county_name, 'MIAMI DADE', 'MIAMI-DADE') 
   county_name <- str_replace(county_name, '\\bLA$', 'LOS ANGELES') 
   county_name <- str_replace_all(county_name, '\\bLA(?=\\|)', 'LOS ANGELES')
   
   # fix counties that really should have dashes
   county_name <- str_replace(county_name, 'HOONAH\\|ANGOON', 'HOONAH-ANGOON')
   county_name <- str_replace(county_name, 'MATANUSKA\\|SUSITNA', 'MATANUSKA-SUSITNA')
   county_name <- str_replace(county_name, 'PRINCE OF WALES\\|HYDER', 'PRINCE OF WALES-HYDER')
   county_name <- str_replace(county_name, 'PRINCE OF WALES\\|OUTER KETCHIKAN', 'PRINCE OF WALES-OUTER KETCHIKAN')
   county_name <- str_replace(county_name, 'SKAGWAY\\|YAKUTAT\\|ANGOON', 'SKAGWAY-YAKUTAT-ANGOON')
   county_name <- str_replace(county_name, 'SKAGWAY\\|HOONAH\\|ANGOON', 'SKAGWAY-HOONAH-ANGOON')
   county_name <- str_replace(county_name, 'VALDEZ\\|CORDOVA', 'VALDEZ-CORDOVA')
   county_name <- str_replace(county_name, 'WRANGELL\\|PETERSBURG', 'WRANGELL-PETERSBURG')
   county_name <- str_replace(county_name, 'YUKON\\|KOYUKUK', 'YUKON-KOYUKUK')
   county_name <- str_replace(county_name, 'MIAMI\\|DADE', 'MIAMI-DADE')

   str_squish(county_name)
}

standardize_place_name <- function(place_name) {
	place_name <- toupper(place_name) 
	
  # Remove refs to fire itself, handle mile markers/posts
	place_name <- str_remove_all(place_name, "COMPLEX|FIRES|FIRE|WILDFIRE|-FIRE|-WILDFIRE|WF | WF -")
   place_name <- if_else(substr(place_name, 1, 2) == "MP", gsub("MP ", "MILE POST ", place_name), place_name)
   place_name <- if_else(str_detect(place_name, "MM[0-9]|MM [0-9]"),
      gsub("MM", "MILE MARKER ", place_name),
      place_name
   )
   place_name <- str_remove_all(place_name, "\\.")
   place_name <- str_remove_all(place_name, "\\#")
   
   # standardize anything else according to USPS pub 28 standard
   pub28 <- c(`\\bALLEY\\b` = "ALY", `\\bALLEE\\b` = "ALY", `\\bALLY\\b` = "ALY",  
   					 `\\bANEX\\b` = "ANX", `\\bANNEX\\b` = "ANX", `\\bANNX\\b` = "ANX", 
   					 `\\bARCADE\\b` = "ARC", `\\bAVENUE\\b` = "AVE", `\\bAV\\b` = "AVE", 
   					 `\\bAVEN\\b` = "AVE", `\\bAVENU\\b` = "AVE", `\\bAVN\\b` = "AVE", `\\bAVNUE\\b` = "AVE", 
   					 `\\bBAYOU\\b` = "BYU", `\\bBAYOO\\b` = "BYU", `\\bBEACH\\b` = "BCH", 
   					 `\\bBEND\\b` = "BND", `\\bBLUFF\\b` = "BLF", `\\bBLUF\\b` = "BLF", 
   					 `\\bBLUFFS\\b` = "BLFS", `\\bBOTTOM\\b` = "BTM", `\\bBOT\\b` = "BTM", 
   					 `\\bBOTTM\\b` = "BTM", `\\bBOULEVARD\\b` = "BLVD", `\\bBOUL\\b` = "BLVD", 
   					 `\\bBOULV\\b` = "BLVD", `\\bBRANCH\\b` = "BR", `\\bBRNCH\\b` = "BR", 
   					 `\\bBRIDGE\\b` = "BRG", `\\bBRDGE\\b` = "BRG", `\\bBROOK\\b` = "BRK", 
   					 `\\bBROOKS\\b` = "BRKS", `\\bBURG\\b` = "BG", `\\bBURGS\\b` = "BGS", 
   					 `\\bBYPASS\\b` = "BYP", `\\bBYPA\\b` = "BYP", `\\bBYPAS\\b` = "BYP", 
   					 `\\bBYPS\\b` = "BYP", `\\bCAMP\\b` = "CP", `\\bCMP\\b` = "CP", `\\bCANYON\\b` = "CYN", 
   					 `\\bCANYN\\b` = "CYN", `\\bCNYN\\b` = "CYN", `\\bCAPE\\b` = "CPE", 
   					 `\\bCAUSEWAY\\b` = "CSWY", `\\bCAUSWA\\b` = "CSWY", `\\bCENTER\\b` = "CTR", 
   					 `\\bCEN\\b` = "CTR", `\\bCENT\\b` = "CTR", `\\bCENTR\\b` = "CTR", `\\bCENTRE\\b` = "CTR", 
   					 `\\bCNTER\\b` = "CTR", `\\bCNTR\\b` = "CTR", `\\bCENTERS\\b` = "CTRS", 
   					 `\\bCIRCLE\\b` = "CIR", `\\bCIRC\\b` = "CIR", `\\bCIRCL\\b` = "CIR", 
   					 `\\bCRCL\\b` = "CIR", `\\bCRCLE\\b` = "CIR", `\\bCIRCLES\\b` = "CIRS", 
   					 `\\bCLIFF\\b` = "CLF", `\\bCLIFFS\\b` = "CLFS", `\\bCLUB\\b` = "CLB", 
   					 `\\bCOMMON\\b` = "CMN", `\\bCOMMONS\\b` = "CMNS", `\\bCORNER\\b` = "COR", 
   					 `\\bCORNERS\\b` = "CORS", `\\bCOURSE\\b` = "CRSE", `\\bCOURT\\b` = "CT", 
   					 `\\bCOURTS\\b` = "CTS", `\\bCOVE\\b` = "CV", `\\bCOVES\\b` = "CVS", 
   					 `\\bCREEK\\b` = "CRK", `\\bCRESCENT\\b` = "CRES", `\\bCRSENT\\b` = "CRES", 
   					 `\\bCRSNT\\b` = "CRES", `\\bCREST\\b` = "CRST", `\\bCROSSING\\b` = "XING", 
   					 `\\bCRSSNG\\b` = "XING", `\\bCROSSROAD\\b` = "XRD", `\\bCROSSROADS\\b` = "XRDS", 
   					 `\\bCURVE\\b` = "CURV", `\\bDALE\\b` = "DL", `\\bDAM\\b` = "DM", `\\bDIVIDE\\b` = "DV", 
   					 `\\bDIV\\b` = "DV", `\\bDVD\\b` = "DV", `\\bDRIVE\\b` = "DR", `\\bDRIV\\b` = "DR", 
   					 `\\bDRV\\b` = "DR", `\\bDRIVES\\b` = "DRS", `\\bESTATE\\b` = "EST", 
   					 `\\bESTATES\\b` = "ESTS", `\\bEXPRESSWAY\\b` = "EXPY", `\\bEXP\\b` = "EXPY", 
   					 `\\bEXPR\\b` = "EXPY", `\\bEXPRESS\\b` = "EXPY", `\\bEXPW\\b` = "EXPY", 
   					 `\\bEXTENSION\\b` = "EXT", `\\bEXTN\\b` = "EXT", `\\bEXTNSN\\b` = "EXT", 
   					 `\\bEXTENSIONS\\b` = "EXTS", `\\bFALLS\\b` = "FLS", `\\bFERRY\\b` = "FRY", 
   					 `\\bFRRY\\b` = "FRY", `\\bFIELD\\b` = "FLD", `\\bFIELDS\\b` = "FLDS", 
   					 `\\bFLAT\\b` = "FLT", `\\bFLATS\\b` = "FLTS", `\\bFORD\\b` = "FRD", 
   					 `\\bFORDS\\b` = "FRDS", `\\bFOREST\\b` = "FRST", `\\bFORESTS\\b` = "FRST", 
   					 `\\bFORGE\\b` = "FRG", `\\bFORG\\b` = "FRG", `\\bFORGES\\b` = "FRGS", 
   					 `\\bFORK\\b` = "FRK", `\\bFORKS\\b` = "FRKS", `\\bFORT\\b` = "FT", 
   					 `\\bFRT\\b` = "FT", `\\bFREEWAY\\b` = "FWY", `\\bFREEWY\\b` = "FWY", 
   					 `\\bFRWAY\\b` = "FWY", `\\bFRWY\\b` = "FWY", `\\bGARDEN\\b` = "GDN", 
   					 `\\bGARDN\\b` = "GDN", `\\bGRDEN\\b` = "GDN", `\\bGRDN\\b` = "GDN", 
   					 `\\bGARDENS\\b` = "GDNS", `\\bGRDNS\\b` = "GDNS", `\\bGATEWAY\\b` = "GTWY", 
   					 `\\bGATEWY\\b` = "GTWY", `\\bGATWAY\\b` = "GTWY", `\\bGTWAY\\b` = "GTWY", 
   					 `\\bGLEN\\b` = "GLN", `\\bGLENS\\b` = "GLNS", `\\bGREEN\\b` = "GRN", 
   					 `\\bGREENS\\b` = "GRNS", `\\bGROVE\\b` = "GRV", `\\bGROV\\b` = "GRV", 
   					 `\\bGROVES\\b` = "GRVS", `\\bHARBOR\\b` = "HBR", `\\bHARB\\b` = "HBR", 
   					 `\\bHARBR\\b` = "HBR", `\\bHRBOR\\b` = "HBR", `\\bHARBORS\\b` = "HBRS", 
   					 `\\bHAVEN\\b` = "HVN", `\\bHEIGHTS\\b` = "HTS", `\\bHT\\b` = "HTS", 
   					 `\\bHIGHWAY\\b` = "HWY", `\\bHIGHWY\\b` = "HWY", `\\bHIWAY\\b` = "HWY", 
   					 `\\bHIWY\\b` = "HWY", `\\bHWAY\\b` = "HWY", `\\bHILL\\b` = "HL", `\\bHILLS\\b` = "HLS", 
   					 `\\bHOLLOW\\b` = "HOLW", `\\bHLLW\\b` = "HOLW", `\\bHOLLOWS\\b` = "HOLW", 
   					 `\\bHOLWS\\b` = "HOLW", `\\bINLET\\b` = "INLT", `\\bISLAND\\b` = "IS", 
   					 `\\bISLND\\b` = "IS", `\\bISLANDS\\b` = "ISS", `\\bISLNDS\\b` = "ISS", 
   					 `\\bISLES\\b` = "ISLE", `\\bJUNCTION\\b` = "JCT", `\\bJCTION\\b` = "JCT", 
   					 `\\bJCTN\\b` = "JCT", `\\bJUNCTN\\b` = "JCT", `\\bJUNCTON\\b` = "JCT", 
   					 `\\bJUNCTIONS\\b` = "JCTS", `\\bJCTNS\\b` = "JCTS", `\\bKEY\\b` = "KY", 
   					 `\\bKEYS\\b` = "KYS", `\\bKNOLL\\b` = "KNL", `\\bKNOL\\b` = "KNL", 
   					 `\\bKNOLLS\\b` = "KNLS", `\\bLAKE\\b` = "LK", `\\bLAKES\\b` = "LKS", 
   					 `\\bLAND\\b` = "LAND", `\\bLANDING\\b` = "LNDG", `\\bLNDNG\\b` = "LNDG", 
   					 `\\bLANE\\b` = "LN", `\\bLIGHT\\b` = "LGT", `\\bLIGHTS\\b` = "LGTS", 
   					 `\\bLOAF\\b` = "LF", `\\bLOCK\\b` = "LCK", `\\bLOCKS\\b` = "LCKS", 
   					 `\\bLODGE\\b` = "LDG", `\\bLDGE\\b` = "LDG", `\\bLODG\\b` = "LDG", 
   					 `\\bLOOPS\\b` = "LOOP", `\\bMALL\\b` = "MALL", `\\bMANOR\\b` = "MNR", 
   					 `\\bMANORS\\b` = "MNRS", `\\bMEADOW\\b` = "MDW", `\\bMEADOWS\\b` = "MDWS", 
   					 `\\bMDW\\b` = "MDWS", `\\bMEDOWS\\b` = "MDWS", `\\bMEWS\\b` = "MEWS", 
   					 `\\bMILL\\b` = "ML", `\\bMILLS\\b` = "MLS", `\\bMISSION\\b` = "MSN", 
   					 `\\bMISSN\\b` = "MSN", `\\bMSSN\\b` = "MSN", `\\bMOTORWAY\\b` = "MTWY", 
   					 `\\bMOUNT\\b` = "MT", `\\bMNT\\b` = "MT", `\\bMOUNTAIN\\b` = "MTN", 
   					 `\\bMNTAIN\\b` = "MTN", `\\bMNTN\\b` = "MTN", `\\bMOUNTIN\\b` = "MTN", 
   					 `\\bMTIN\\b` = "MTN", `\\bMOUNTAINS\\b` = "MTNS", `\\bMNTNS\\b` = "MTNS", 
   					 `\\bNECK\\b` = "NCK", `\\bORCHARD\\b` = "ORCH", `\\bORCHRD\\b` = "ORCH", 
   					 `\\bOVL\\b` = "OVAL", `\\bOVERPASS\\b` = "OPAS", `\\bPARKS\\b` = "PARK", 
   					 `\\bPARKWAY\\b` = "PKWY", `\\bPARKWY\\b` = "PKWY", `\\bPKWAY\\b` = "PKWY", 
   					 `\\bPKY\\b` = "PKWY", `\\bPARKWAYS\\b` = "PKWY", `\\bPKWYS\\b` = "PKWY", 
   					 `\\bPASS\\b` = "PASS", `\\bPASSAGE\\b` = "PSGE", `\\bPATHS\\b` = "PATH", 
   					 `\\bPIKES\\b` = "PIKE", `\\bPINE\\b` = "PNE", `\\bPINES\\b` = "PNES", 
   					 `\\bPLACE\\b` = "PL", `\\bPLAIN\\b` = "PLN", `\\bPLAINS\\b` = "PLNS", 
   					 `\\bPLAZA\\b` = "PLZ", `\\bPLZA\\b` = "PLZ", `\\bPOINT\\b` = "PT", 
   					 `\\bPOINTS\\b` = "PTS", `\\bPORT\\b` = "PRT", `\\bPORTS\\b` = "PRTS", 
   					 `\\bPRAIRIE\\b` = "PR", `\\bPRR\\b` = "PR", `\\bRADIAL\\b` = "RADL", 
   					 `\\bRAD\\b` = "RADL", `\\bRADIEL\\b` = "RADL", `\\bRAMP\\b` = "RAMP", 
   					 `\\bRANCH\\b` = "RNCH", `\\bRANCHES\\b` = "RNCH", `\\bRNCHS\\b` = "RNCH", 
   					 `\\bRAPID\\b` = "RPD", `\\bRAPIDS\\b` = "RPDS", `\\bREST\\b` = "RST", 
   					 `\\bRIDGE\\b` = "RDG", `\\bRDGE\\b` = "RDG", `\\bRIDGES\\b` = "RDGS", 
   					 `\\bRIVER\\b` = "RIV", `\\bRVR\\b` = "RIV", `\\bRIVR\\b` = "RIV", `\\bROAD\\b` = "RD", 
   					 `\\bROADS\\b` = "RDS", `\\bROUTE\\b` = "RTE", `\\bROW\\b` = "ROW", 
   					 `\\bRUE\\b` = "RUE", `\\bRUN\\b` = "RUN", `\\bSHOAL\\b` = "SHL", `\\bSHOALS\\b` = "SHLS", 
   					 `\\bSHORE\\b` = "SHR", `\\bSHOAR\\b` = "SHR", `\\bSHORES\\b` = "SHRS", 
   					 `\\bSHOARS\\b` = "SHRS", `\\bSKYWAY\\b` = "SKWY", `\\bSPRING\\b` = "SPG", 
   					 `\\bSPNG\\b` = "SPG", `\\bSPRNG\\b` = "SPG", `\\bSPRINGS\\b` = "SPGS", 
   					 `\\bSPNGS\\b` = "SPGS", `\\bSPRNGS\\b` = "SPGS", `\\bSPURS\\b` = "SPUR", 
   					 `\\bSQUARE\\b` = "SQ", `\\bSQR\\b` = "SQ", `\\bSQRE\\b` = "SQ", `\\bSQU\\b` = "SQ", 
   					 `\\bSQUARES\\b` = "SQS", `\\bSQRS\\b` = "SQS", `\\bSTATION\\b` = "STA", 
   					 `\\bSTATN\\b` = "STA", `\\bSTN\\b` = "STA", `\\bSTRAVENUE\\b` = "STRA", 
   					 `\\bSTRAV\\b` = "STRA", `\\bSTRAVEN\\b` = "STRA", `\\bSTRAVN\\b` = "STRA", 
   					 `\\bSTRVN\\b` = "STRA", `\\bSTRVNUE\\b` = "STRA", `\\bSTREAM\\b` = "STRM", 
   					 `\\bSTREME\\b` = "STRM", `\\bSTREET\\b` = "ST", `\\bSTRT\\b` = "ST", 
   					 `\\bSTR\\b` = "ST", `\\bSTREETS\\b` = "STS", `\\bSUMMIT\\b` = "SMT", 
   					 `\\bSUMIT\\b` = "SMT", `\\bSUMITT\\b` = "SMT", `\\bTERRACE\\b` = "TER", 
   					 `\\bTERR\\b` = "TER", `\\bTHROUGHWAY\\b` = "TRWY", `\\bTRACE\\b` = "TRCE", 
   					 `\\bTRACES\\b` = "TRCE", `\\bTRACK\\b` = "TRAK", `\\bTRACKS\\b` = "TRAK", 
   					 `\\bTRK\\b` = "TRAK", `\\bTRKS\\b` = "TRAK", `\\bTRAFFICWAY\\b` = "TRFY", 
   					 `\\bTRAIL\\b` = "TRL", `\\bTRAILS\\b` = "TRL", `\\bTRLS\\b` = "TRL", 
   					 `\\bTRAILER\\b` = "TRLR", `\\bTRLRS\\b` = "TRLR", `\\bTUNNEL\\b` = "TUNL", 
   					 `\\bTUNEL\\b` = "TUNL", `\\bTUNLS\\b` = "TUNL", `\\bTUNNELS\\b` = "TUNL", 
   					 `\\bTUNNL\\b` = "TUNL", `\\bTURNPIKE\\b` = "TPKE", `\\bTRNPK\\b` = "TPKE", 
   					 `\\bTURNPK\\b` = "TPKE", `\\bUNDERPASS\\b` = "UPAS", `\\bUNION\\b` = "UN", 
   					 `\\bUNIONS\\b` = "UNS", `\\bVALLEY\\b` = "VLY", `\\bVALLY\\b` = "VLY", 
   					 `\\bVLLY\\b` = "VLY", `\\bVALLEYS\\b` = "VLYS", `\\bVIADUCT\\b` = "VIA", 
   					 `\\bVDCT\\b` = "VIA", `\\bVIADCT\\b` = "VIA", `\\bVIEW\\b` = "VW", 
   					 `\\bVIEWS\\b` = "VWS", `\\bVILLAGE\\b` = "VLG", `\\bVILL\\b` = "VLG", 
   					 `\\bVILLAG\\b` = "VLG", `\\bVILLG\\b` = "VLG", `\\bVILLIAGE\\b` = "VLG", 
   					 `\\bVILLAGES\\b` = "VLGS", `\\bVILLE\\b` = "VL", `\\bVISTA\\b` = "VIS", 
   					 `\\bVIST\\b` = "VIS", `\\bVST\\b` = "VIS", `\\bVSTA\\b` = "VIS", `\\bWALKS\\b` = "WALK", 
   					 `\\bWALL\\b` = "WALL", `\\bWY\\b` = "WAY", `\\bWAYS\\b` = "WAYS", `\\bWELL\\b` = "WL", 
   					 `\\bWELLS\\b` = "WLS")
   place_name <- str_replace_all(place_name, pattern = pub28)
   place_name <- str_squish(place_name)
   place_name
}


assign_clusters <- function(lol){ # take list of lists, do a union find to assign group membership
																	# according to connectedness
	
	dt <- data.table(lol = lol)
	dt_exp <- dt[, .(lol = unlist(lol)), by = .(row = .I)]
	dt_links <- dt_exp[dt_exp, on = .(lol), allow.cartesian = TRUE, nomatch = 0]
	dt_links <- dt_links[I < i.I, .(I, i.I)] #uniquify
	
	# Union-Find (connected components)
	uf <- function(n, edges) {
		parent <- seq_len(n)
		find <- function(x) { 
			while (parent[x] != x) x <- parent[x]
			x
		}
		union <- function(x, y) {
			px <- find(x); py <- find(y)
			if (px != py) parent[py] <<- px
		}
		for (i in seq_len(nrow(edges))) union(edges$I[i], edges$i.I[i])
		sapply(seq_len(n), find)
	}
	
	uf(nrow(dt), dt_links)
	
}

as_numeric <- function(x) as.numeric(gsub(",", "", x))
