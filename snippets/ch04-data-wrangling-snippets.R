# Chapter 4: Data Wrangling
# Machine Learning in Cardiology: A Practical R-Based Approach
# ILLUSTRATIVE ONLY. Do not source this file: most of these snippets assume
# your own data frames (e.g. echo_data, ecg_data) or files that are not provided.

# --------------------------------------------------------------------------
# Handling Missing Values
# --------------------------------------------------------------------------

# Assuming 'echo_data' is a data frame with missing LVEF values
mean_lvef <- mean(echo_data$LVEF, na.rm = TRUE)
echo_data$LVEF[is.na(echo_data$LVEF)] <- mean_lvef

# Assuming 'echo_data' is a data frame with missing values
# impute is on Bioconductor, not CRAN: BiocManager::install('impute')
library(impute)
echo_data_imputed <- impute.knn(as.matrix(echo_data), k = 10)$data

# Assuming 'echo_data' is a data frame with missing values
library(mice)
imputation_model <- mice(echo_data, m = 5, method = 'pmm', seed = 123)
echo_data_imputed <- complete(imputation_model, 1)

library(tidyverse)  # For ggplot2 and data manipulation
library(scales)     # For scale adjustments

# Create missing data visualization
missing_pattern <- synthetic_data %>%
  # Convert all columns to character type first to allow gathering
  mutate(across(everything(), as.character)) %>%
  pivot_longer(cols = -patient_id,
              names_to = "variable", 
              values_to = "value") %>%
  mutate(is_missing = is.na(value))

# Create the visualization
ggplot(missing_pattern, aes(x = variable, y = factor(patient_id), fill = is_missing)) +
  geom_tile(color = "white") +
  labs(
    title = "Missing Data Patterns",
    x = "Variables",
    y = "Patient ID",
    fill = "Data Status"
  )


# --------------------------------------------------------------------------
# Feature Scaling: Normalization and Standardization
# --------------------------------------------------------------------------

#Min-Max Scaling
min_max_scaling <- function(x) {
  (x - min(x)) / (max(x) - min(x))
}

patient_df$age_normalized <- min_max_scaling(patient_df$age)

#Z-score Standardization
zscore_standardize <- function(x) {
  (x - mean(x)) / sd(x)
}

patient_df$cholesterol_standardized <- zscore_standardize(patient_df$cholesterol)


# --------------------------------------------------------------------------
# Addressing Class Imbalance
# --------------------------------------------------------------------------

# Example: Applying SMOTE in R. The book used DMwR, which is no longer on CRAN;
# this version uses smotefamily, as in the worked example in this chapter.
library(smotefamily)
# Assuming 'data' has numeric predictors and 'target' is the target variable
smote_result <- SMOTE(X = data[, setdiff(names(data), 'target')],
                      target = data$target,
                      K = 5,
                      dup_size = 2)
balanced_data <- smote_result$data


# --------------------------------------------------------------------------
# Data Mapping and Transformation
# --------------------------------------------------------------------------

# Example pseudo-code for data transformation
library(dplyr)
data_standardized <- data_raw %>%
  mutate(
    # Convert all dates to standard ISO format
    date_recorded = as.Date(date_recorded, format = "%Y-%m-%d"),
    # Map local lab codes to LOINC
    lab_code = map_local_to_loinc(lab_code)
  ) %>%
  filter(!is.na(patient_id))
