# Chapter 2: R Fundamentals
# Machine Learning in Cardiology: A Practical R-Based Approach
# Runnable top to bottom. All data are simulated in the script.

# --------------------------------------------------------------------------
# Data Structures in R
# --------------------------------------------------------------------------

# Create a numeric vector of heart rates
heart_rates <- c(60, 75, 82, 90, 68)

# Create a character vector of patient names
patient_names <- c('Alice', 'Bob', 'Charlie', 'David', 'Eve')

# Create a logical vector indicating hypertension status
hypertension <- c(TRUE, FALSE, TRUE, TRUE, FALSE)

# Create a data frame of patient data
patient_df <- data.frame(
  name = patient_names,
  age = c(62, 55, 78, 49, 68),
  heart_rate = heart_rates,
  hypertension = hypertension
)


# --------------------------------------------------------------------------
# Essential R Packages for Cardiology
# --------------------------------------------------------------------------

library(tidyverse)

# Assuming `patient_df' is loaded
filtered_df <- patient_df %>%
  filter(age > 60) %>%
  select(name, heart_rate)


# --------------------------------------------------------------------------
# Data Visualization with ggplot2
# --------------------------------------------------------------------------

ggplot(patient_df, aes(x = age, y = heart_rate)) +
  geom_point() +
  labs(title = 'Age vs. Heart Rate', x = 'Age (years)', y = 'Heart Rate (bpm)') +
  theme_minimal()

ggplot(patient_df, aes(x = age, y = heart_rate, color = hypertension)) +
  geom_point(size = 5) +
  labs(title = 'Age vs. Heart Rate', x = 'Age (years)', y = 'Heart Rate (bpm)',color = 'Hypertension') +
  theme_minimal()


# --------------------------------------------------------------------------
# Basic Statistical Analysis in R
# --------------------------------------------------------------------------

# Assuming `patient_df' is loaded
summary(patient_df)
