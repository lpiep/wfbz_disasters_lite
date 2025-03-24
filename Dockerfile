FROM ghcr.io/rocker-org/devcontainer/geospatial:4.2

# Copy workflow file
COPY ./wf.yml /wf.yml

# Set up Python environment (use libmamba for faster solving of environment)
COPY --from=continuumio/miniconda3:4.12.0 /opt/conda /opt/conda
ENV PATH=/opt/conda/bin:$PATH
RUN conda update -n base conda \
    && conda install -n base conda-libmamba-solver \
    && conda config --set solver libmamba \
    && conda env create -f /wf.yml \
    && conda clean --all -y

# Set up R environment
RUN Rscript -e "install.packages('remotes', repos = 'https://cran.rstudio.com/')" \
    && Rscript -e "remotes::install_cran(c('targets', 'tarchetypes', 'jsonlite', 'fs', 'clustermq', 'qs', 'stringdist'))" \
    && Rscript -e "remotes::install_github('qsbase/qs2')"

# Create app directory
RUN mkdir -p /app

WORKDIR /app

# Set default command (if needed)
CMD ["/usr/local/bin/R"]
