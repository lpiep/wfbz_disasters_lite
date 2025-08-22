#!/usr/bin/env bash

cd "$(dirname "$0")"

CONDABIN=$(which conda)

Rscript -e "renv::restore()"
Rscript -e "targets::tar_make()" 
