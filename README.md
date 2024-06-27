# Wildfire Disaster Data Harmonization
## "Lite" Version

This program will harmonize wildfire and disaster data from several sources to produce a single geospatial data set. 
It is off Milo Gordon's work that created a harmonized data set for the years 2000-2019, which involved a large amount
of manual data cleaning. This project aims to reproduce that work for future data releases, sacrificing some accuracy 
and completeness in favor of a more automated process. 

## Run

Clone this repo, and run `main.R` in R. I include a script to run the same code using the `rocker/geospatial` docker image as 
well for reproducibility. 

With your system R:

```
$ Rscript main.R
```

With Singularity installed:

```
$ chmod +x exec_singularity.sh
$ ./exec_singularity.sh
```

With Docker installed:

```
$ chmod +x exec_docker.sh
$ ./exec_docker.sh
```

## Data Sources

### Spatial 

* MBTS 
	* Will be updated
	* Included here
* FIRED
  * Will be updated
  * Included here
* USGS
	* Unsure about updates per authors
	* Not included here
* GEOMAC
  * Will not be updated (migrated to NIFT in 2020)
  * Not included here
* NIFC 
  * Will be updated
  * Included here


### Non-Spatial

* FEMA Disaster Declarations
  * Will be updated
  * Included here
* ICS 
  * Not updated
  * Included here
  * Could possibly be replicated on future data using their code, though it may already be in FEMA data? 
* REDBOOKS _to do_
  
https://github.com/katiemcconnell/ICS-209-PLUS_spatiotemporal_linkage