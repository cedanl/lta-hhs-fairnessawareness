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

# Set up renv
COPY renv.lock ./
RUN R -e "renv::consent(provided = TRUE); renv::init()"

# Add .Rprofile after renv is initialized
RUN echo 'source("renv/activate.R")' > .Rprofile

# Expose RStudio Server port
EXPOSE 8787

# Set environment variables for RStudio
ENV DISABLE_AUTH=true
ENV RSTUDIO_AUTH_NONE=true
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

# Configure RStudio Server for passwordless login
RUN echo "auth-none=1" >> /etc/rstudio/rserver.conf
RUN echo "www-port=8787" >> /etc/rstudio/rserver.conf

# Create vscode user and set it as default
RUN useradd -m -s /bin/bash vscode && \
    usermod -aG sudo vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode && \
    chown -R vscode:vscode /workspaces && \
    chmod -R 755 /workspaces && \
    # Grant vscode user permissions to run as rstudio-server
    usermod -aG rstudio-server vscode && \
    # Create R package library for vscode user
    mkdir -p /home/vscode/R/library && \
    chown -R vscode:vscode /home/vscode/R && \
    # Give write permission to the site-library directory
    chmod -R 777 /usr/local/lib/R/site-library

# Set R library path for vscode user
ENV R_LIBS_USER=/home/vscode/R/library
ENV R_LIBS_SITE=/usr/local/lib/R/site-library

# Set up symbolic link for the project
RUN ln -s /workspaces/lta-hhs-fairnessawareness /home/vscode/lta-hhs-fairnessawareness

# Use vscode user (default for Codespaces)
USER vscode
CMD ["/usr/lib/rstudio-server/bin/rserver", "--www-port", "8787", "--server-daemonize=0"]
