FROM rocker/rstudio:4.4.2

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
    && rm -rf /var/lib/apt/lists/*

# Install R packages that are typically in verse image
RUN install2.r --error --skipinstalled \
    tidyverse \
    ggplot2 \
    dplyr \
    tidyr \
    readr \
    purrr \
    tibble \
    stringr \
    forcats

# Install Quarto
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.39/quarto-1.6.39-linux-amd64.deb \
    && dpkg -i quarto-1.6.39-linux-amd64.deb \
    && rm quarto-1.6.39-linux-amd64.deb

# Set working directory
WORKDIR /workspaces/project

# Install renv
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org/')"

# Set up renv - FIXED SECTION
COPY renv.lock ./
RUN R -e "renv::consent(provided = TRUE); renv::init()"

# Add .Rprofile after renv is initialized
RUN echo 'source("renv/activate.R")' > .Rprofile

# Expose RStudio Server port
EXPOSE 8787

# Set environment variables for RStudio
ENV DISABLE_AUTH=true
ENV ROOT=true
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

# Set up entry point to start RStudio Server
CMD ["/init"]
