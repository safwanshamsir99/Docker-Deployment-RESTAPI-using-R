library(survey)
library(tidyverse)
library(jsonlite)

#' Calculate the weight from each respondent using rake() function in survey package
#'
#' @param json_data data frame in JSON format
#' @param sample_list_json list of the strata columns in the survey response in JSON format
#' @param pop_list_json list of the population data frames that contain strata column with the distribution value in JSON format
#' @param lower_limit lower limit for the trimmed_weight column
#' @param upper_limit upper limit for the trimmed_weight column
#'
#' @return "weighted data frame in  JSON format"
#' @export
#'
#' @examples
#' calc_weight(json_data, sample_list_json, pop_list_json, 0.3, 3)

calc_weight <- function(
    json_data,
    sample_list_json,
    pop_list_json,
    lower_limit,
    upper_limit){
  
  # Read json data 
  df <- fromJSON(json_data)
  sample_list_unjson <- fromJSON(sample_list_json)
  sample_list <- lapply(sample_list_unjson, function(x) as.formula(paste0("~", x)))
  pop_list <- lapply(fromJSON(pop_list_json), function(x) {
    x$freq <- as.numeric(x$freq)
    x
  })
  lower_limit <- as.numeric(lower_limit)
  upper_limit <- as.numeric(upper_limit)
  
  # Name for weight column
  col_names <- paste(sample_list_unjson, collapse = "_")
  col_name_untrimmed <- paste0("untrimmed_weight_", col_names)
  col_name_trimmed <- paste0("trimmed_weight_", col_names)
  
  # Create survey design
  svy.unweighted <- svydesign(ids = ~1, data = df)
  
  # Raking
  svy.rake <- rake(
    design = svy.unweighted,
    sample.margins = sample_list,
    population.margins = pop_list,
    control = list(
      maxit = 100,
      epsilon = 1,
      verbose = FALSE
    )
  )
  
  # Append untrimmed weight to the data frame
  df[[col_name_untrimmed]] <- weights(svy.rake)
  
  # Trim weights
  svy.rake.trim <- trimWeights(
    svy.rake,
    lower = lower_limit,
    upper = upper_limit,
    strict = TRUE
  )
  
  # Append trimmed weights
  df[[col_name_trimmed]] <- weights(svy.rake.trim)
  
  # Convert the resultant data frame into json format
  json_result <- toJSON(df, dataframe = "rows", pretty = TRUE)
  
  return(json_result)
}
