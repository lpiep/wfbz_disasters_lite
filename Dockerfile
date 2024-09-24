FROM ghcr.io/rocker-org/devcontainer/geospatial:4.3
RUN Rscript -e "remotes::install_cran('targets')"
RUN Rscript -e "remotes::install_cran('tarchetypes')"
RUN Rscript -e "remotes::install_cran('clustermq')"
RUN Rscript -e "remotes::install_cran('snakecase')"
RUN Rscript -e "remotes::install_cran('fs')"
RUN Rscript -e "remotes::install_cran('jsonlite')"
RUN Rscript -e "remotes::install_cran('qs')"
