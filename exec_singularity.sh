#!/usr/bin/env sh
singularity exec --no-home --bind $PWD docker://rocker/geospatial:4.2.2 Rscript main.R
