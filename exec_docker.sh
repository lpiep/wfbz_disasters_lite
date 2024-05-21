#!/usr/bin/env sh
docker run -ti --rm -v "$PWD":/home/docker -w /home/docker -u docker rocker/geospatial Rscript main.R