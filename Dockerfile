FROM rocker/verse:4.4.2

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
    && rm -rf /var/lib/apt/lists/*

# Install Quarto
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.39/quarto-1.6.39-linux-amd64.deb && \
    dpkg -i quarto-1.6.39-linux-amd64.deb && \
    rm quarto-1.6.39-linux-amd64.deb

# Set up renv
RUN R -e "install.packages('renv', repos = 'https://cloud.r-project.org/')"

# Create and set working directory
WORKDIR /workspaces/project

# Copy renv.lock file (if it exists)
COPY renv.lock* ./

# Create .Rprofile with proper settings (in case it doesn't exist)
RUN echo 'source("renv/activate.R")' > .Rprofile

# Initialize renv
RUN R -e 'renv::consent(provided = TRUE)'
RUN R -e 'renv::init()'

# The renv restore will be done after the container starts
# because the full project needs to be mounted

# Set up an entry command for GitHub Codespaces
# This will restore the renv environment when the container starts
ENTRYPOINT ["/bin/bash", "-c", "if [ -f renv.lock ]; then R -e 'renv::restore()'; fi && exec \"$@\"", "--"]

# Default command
CMD ["bash"]
