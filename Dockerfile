FROM ghcr.io/rocker-org/devcontainer/geospatial:4.3
RUN Rscript -e "remotes::install_cran(c('targets', 'tarchetypes', 'clustermq', 'remotes', 'qs2', 'jsonlite', 'fs'))"

# Copy everything from the current directory to the container's working directory
COPY . /app
WORKDIR /app

RUN mkdir -p /app/output

# Set the command to run your script
CMD ["Rscript", "run.R"]
