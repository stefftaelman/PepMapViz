# Use the official R image with Shiny Server pre-installed
FROM rocker/shiny:4.5.2

# Set the maintainer label
LABEL maintainer="PepMapViz Team <support@pepmapviz.com>"
LABEL description="Docker container for PepMapViz Shiny application"
LABEL version="1.1.0"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV RENV_VERSION=1.1.5

# Install system dependencies required for R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libgit2-dev \
    cmake \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install renv first for package management
RUN R -e "install.packages('renv', repos='https://cran.rstudio.com/')"

# Create app directory
RUN mkdir -p /srv/shiny-server/pepmapviz

# Set working directory
WORKDIR /srv/shiny-server/pepmapviz

# Copy the entire PepMapViz package
COPY . .

# Install R dependencies using the package's requirements
RUN R -e "install.packages(c('shiny', 'ggplot2', 'stringr', 'ggforce', 'ggh4x', 'ggnewscale', 'data.table', 'rlang', 'DT', 'knitr', 'rmarkdown', 'testthat'), repos='https://cran.rstudio.com/', dependencies=TRUE)"

# Install the PepMapViz package itself
RUN R -e "install.packages('.', repos=NULL, type='source')"

# Create a custom Shiny app launcher script
RUN echo '#!/usr/bin/env Rscript' > /usr/local/bin/run_pepmapviz.R && \
    echo 'library(PepMapViz)' >> /usr/local/bin/run_pepmapviz.R && \
    echo 'app_dir <- system.file("shiny_apps", "PepMapVizApp", package = "PepMapViz")' >> /usr/local/bin/run_pepmapviz.R && \
    echo 'if(app_dir == "") stop("Could not find Shiny app directory")' >> /usr/local/bin/run_pepmapviz.R && \
    echo 'cat("Starting PepMapViz Shiny App...\\n")' >> /usr/local/bin/run_pepmapviz.R && \
    echo 'shiny::runApp(app_dir, host="0.0.0.0", port=3838, launch.browser=FALSE)' >> /usr/local/bin/run_pepmapviz.R && \
    chmod +x /usr/local/bin/run_pepmapviz.R

# Copy the Shiny app to the default Shiny server location
RUN cp -r /srv/shiny-server/pepmapviz/inst/shiny_apps/PepMapVizApp/* /srv/shiny-server/

# Create a simple index.html to redirect to the app
RUN echo '<!DOCTYPE html>' > /srv/shiny-server/index.html && \
    echo '<html><head><title>PepMapViz</title></head>' >> /srv/shiny-server/index.html && \
    echo '<body><h1>Welcome to PepMapViz</h1>' >> /srv/shiny-server/index.html && \
    echo '<p><a href="/PepMapVizApp/">Launch PepMapViz App</a></p></body></html>' >> /srv/shiny-server/index.html

# Expose port 3838 for Shiny Server
EXPOSE 3838

# Set proper permissions for Shiny Server
RUN chown -R shiny:shiny /srv/shiny-server/
RUN chmod -R 755 /srv/shiny-server/

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3838/ || exit 1

# Start Shiny Server
CMD ["/init"]