library(testthat)
library(jsonlite)
source("../../functions.R")

test_that("test calc_weight", {
  df <- read.csv("test_weighting.csv", check.names = FALSE)
  json_data = toJSON(df, dataframe = "rows", pretty = TRUE)
  sample_list_json <- toJSON(c("Gender", "IncomeGroup"))
  gender.dist <- data.frame(
    
    Gender = c("Male", "Female"),
    freq = nrow(df) * c(0.4985, 0.5015)
    
  )
  incomegroup.dist <- data.frame(
    
    IncomeGroup = c("B40", "M40", "T20"),
    freq = nrow(df) * c(0.40, 0.40, 0.20)
    
  )
  pop_list_json <- toJSON(list(gender.dist, incomegroup.dist))
  lower_limit <- 0.3
  upper_limit <- 3
  
  json_result <- calc_weight(json_data, sample_list_json, pop_list_json, lower_limit, upper_limit)
  
  result <- fromJSON(json_result)

  expect_is(result, "data.frame")

  expect_equal(colnames(result), c(
    "1. [LIKERT] Opinions" ,
    "2. What is your dream job field?",
    "Gender",
    "IncomeGroup", 
    "untrimmed_weight_Gender_IncomeGroup", 
    "trimmed_weight_Gender_IncomeGroup"))

  expect_true(all(result$trimmed_weight_Gender_IncomeGroup >= lower_limit))
  expect_true(all(result$trimmed_weight_Gender_IncomeGroup <= upper_limit))
})