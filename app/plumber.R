library(plumber)
library(survey)
library(tidyverse)
library(jsonlite)

#* @apiTitle Survey Weighting API
#* @apiDescription This is a survey weighting API that used rake() function from survey package.

#* Test the root
#* @get /
function() {
  list(status = "ok", type = "survey_weighting")
}

#* Calculate the weight from each respondent using rake() function in survey package
#* @post /calc_weight
#* @param survey_file:object <Survey file in JSON string format>
#* @param sample_list_json:object <list of the strata columns in the survey response>
#* @param pop_list_json:object <list of the population data frames that contain strata column with the distribution value>
#* @param limit:object <lower limit & upper limit for the trimmed_weight column>
#* 
#* @response 200 weighted data frame (df) in  JSON format

function(
    survey_file,
    sample_list_json,
    pop_list_json,
    limit){
  
  # Data processing for the input
  df <- as.data.frame(fromJSON(survey_file)$data)
  sample_list <- lapply(fromJSON(sample_list_json)$sample_list, 
                        function(x) as.formula(paste0("~", x)))
  pop_list <- lapply(pop_list_json, function(x) {
    x$freq <- as.numeric(x$freq)
    x
  })
  lower_limit <- as.numeric(fromJSON(limit)$lower_limit)
  upper_limit <- as.numeric(fromJSON(limit)$upper_limit)
  
  # Name for weight column
  col_names <- paste(fromJSON(sample_list_json)$sample_list, collapse = "_")
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
  
  return(df)
}
