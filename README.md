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
