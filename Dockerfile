# A convoluted dockerfile to install everything in a way that works for rasterio
ARG GDAL=ubuntu-full-3.6.4
FROM ghcr.io/osgeo/gdal:${GDAL} AS gdal
ARG PYTHON_VERSION=3.12
ARG R_VERSION=4.4.3
ENV LANG="C.UTF-8" LC_ALL="C.UTF-8"
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    g++ \
    gdb \
    make \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY wf.yml /

# Install Miniconda
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && /bin/bash miniconda.sh -b -p $CONDA_DIR \
    && rm miniconda.sh \
    && $CONDA_DIR/bin/conda clean -tipy \
    && ln -s $CONDA_DIR/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate base" >> ~/.bashrc

# Configure conda-forge channel and libmamba solver
RUN conda config --add channels conda-forge \
    && conda config --set channel_priority strict \
    && conda install -n base conda-libmamba-solver \
    && conda config --set solver libmamba

# Install python packages
RUN conda update -n base conda \
    && conda env create -f /wf.yml \
    && echo "conda activate wf" >> ~/.bashrc

# Install R (into conda base env)
#pkgs <- c("targets", "tarchetypes", "sf", "tidyverse", "httr", "fs", "jsonlite", "qs", "qs2", "readxl", "glue", "arrow", "stringdist", "clustermq")

RUN conda install -n base r-base \
    && conda install -n base r-targets \
    && conda install -n base r-tarchetypes \
    && conda install -n base r-sf \
    && conda install -n base r-tidyverse \
    && conda install -n base r-httr \
    && conda install -n base r-fs \
    && conda install -n base r-jsonlite \
    && conda install -n base r-qs \
    && conda install -n base r-readxl \
    && conda install -n base r-glue \
    && conda install -n base r-arrow \
    && conda install -n base r-stringdist \
    && conda install -n base r-clustermq

CMD ["/bin/bash"]
