FROM rstudio/plumber

# SETUP DIRECTORY
RUN echo "### --- Directory setup --- ###"
RUN mkdir /app
WORKDIR /app
COPY ./app .

# PACKAGES 
RUN echo "### --- R packages installation --- ###"
RUN R -e "install.packages(c('logger','jsonlite', 'survey', 'tidyverse','plumber'))"

EXPOSE 8000

CMD ["Rscript", "/app/plumber.R"]
