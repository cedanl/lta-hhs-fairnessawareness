FROM rocker/r-ver:4.4.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgit2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libglpk-dev \
    libgsl-dev \
    libcairo2-dev \
    libbz2-dev \
    libsodium-dev \
    libmagick++-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install R packages that are typically used
RUN install2.r --error --skipinstalled \
    tidyverse \
    ggplot2 \
    dplyr \
    tidyr \
    readr \
    purrr \
    tibble \
    stringr \
    forcats \
    languageserver

# Install Quarto
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.39/quarto-1.6.39-linux-amd64.deb \
    && dpkg -i quarto-1.6.39-linux-amd64.deb \
    && rm quarto-1.6.39-linux-amd64.deb

# Set working directory
WORKDIR /workspaces

# Install renv
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org/')"

# Set up renv
COPY renv.lock ./
RUN R -e "renv::consent(provided = TRUE); renv::init()"

# Add .Rprofile after renv is initialized
RUN echo 'source("renv/activate.R")' > .Rprofile

# Create the R library directories with appropriate permissions
RUN mkdir -p /home/vscode/R/library && \
    chmod -R 777 /home/vscode/R && \
    chmod -R 777 /usr/local/lib/R/site-library

# Set R library path environment variables
ENV R_LIBS_USER=/home/vscode/R/library
ENV R_LIBS_SITE=/usr/local/lib/R/site-library

CMD ["bash"]
