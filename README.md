# Getting Started

- Learning repository for the deployment of R functions as a RESTful API using Docker.

# Development
## Run API Locally
```
> plumber::plumb(file='app/plumber.R')$run()
```

## File Tree
```
├── Dockerfile
├── README.md
├── app
│   └── plumber.R
├── tests/testthat/
│   └── test-backend_test.R
└── functions.R
```
### Files Details
1. `Dockerfile` - Docker file for Docker image building in docker. 
2. `app/plumber.R` - REST API endpoint to be deployed as an R functions from `functions.R` using Docker.
3. `tests/testthat/test-backend_test.R` - Unit testing for `functions.R`
4. `functions.R` - Simple functions using R programming language.

# Testing
## Run all tests (make sure you are in the parent directory)
```
# RStudio Console
> testthat::test_file("tests/testthat/test-backend_test.R")
```

## Container
1. Build a Docker container locally
```bash
docker build -t rake .
```
2. Run the container locally
```bash
docker run -p 8000:8000 rake
```
3. Copy and paste the URL in your browser to open the Swagger UI.