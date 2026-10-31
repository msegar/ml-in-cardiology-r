# Chapter 2: R Fundamentals
# Machine Learning in Cardiology: A Practical R-Based Approach
# ILLUSTRATIVE ONLY. Do not source this file: most of these snippets assume
# your own data frames (e.g. echo_data, ecg_data) or files that are not provided.

# --------------------------------------------------------------------------
# Installing and Configuring R
# --------------------------------------------------------------------------

install.packages('tidyverse')

library(tidyverse)

# The book showed options(memory.limit=8000). R 4.2 removed this limit on
# Windows, and it never applied on macOS or Linux, so no setting is needed.


# --------------------------------------------------------------------------
# Data Structures in R
# --------------------------------------------------------------------------

# Create a matrix of lab values (rows = patients, cols = lab tests)
lab_matrix <- matrix(c(150, 7.2, 220, 8.5, 180, 9.1), nrow = 3, ncol = 2)

# Create a list containing patient information
patient_list <- list(name = 'Alice', age = 62, heart_rate = heart_rates, hypertension = TRUE)

# Read data from a CSV file
cardiology_data <- read.csv('cardiology-data.csv')

# Convert a matrix to a data frame
lab_df <- as.data.frame(lab_matrix)


# --------------------------------------------------------------------------
# Essential R Packages for Cardiology
# --------------------------------------------------------------------------

install.packages('caret')
library(caret)

# Assuming `train_data' and `test_data' are data frames
model <- train(
  cvd_risk ~ age + sbp + ldl + smoker,
  data = train_data,
  method = 'glm',
  family = 'binomial'
)

install.packages('mlr3')
library(mlr3)

install.packages('survival')
library(survival)

# Assuming `survival_data' is a data frame with `time' and `status' columns
cox_model <- coxph(Surv(time, status) ~ age + cholesterol + bmi, data = survival_data)


# --------------------------------------------------------------------------
# Data Visualization with ggplot2
# --------------------------------------------------------------------------

ggplot(patient_df, aes(x = age, y = heart_rate)) +
  geom_point() +
  theme_minimal()

ggplot(ecg_data, aes(x = time, y = signal)) +
  geom_line() +
  labs(title = 'ECG Signal Over Time', x = 'Time (ms)', y = 'Voltage (mV)')

ggplot(arrhythmia_counts, aes(x = arrhythmia, y = count)) +
  geom_bar(stat = 'identity') +
  labs(title = 'Arrhythmia Distribution', x = 'Arrhythmia Type', y = 'Number of Patients')

ggplot(patient_df, aes(x = age)) +
  geom_histogram(binwidth = 5) +
  labs(title = 'Age Distribution of Patients', x = 'Age (years)', y = 'Number of Patients')

ggplot(heart_failure_data, aes(x = heart_failure_class, y = ejection_fraction)) +
  geom_boxplot() +
  labs(title = 'Ejection Fraction by Heart Failure Class', x = 'Heart Failure Class', y = 'Ejection Fraction (%)')


# --------------------------------------------------------------------------
# Basic Statistical Analysis in R
# --------------------------------------------------------------------------

# Calculate the mean age
mean(patient_df$age)

# Calculate the standard deviation of cholesterol levels
sd(patient_df$cholesterol)

#Create a histogram of ejection fraction
hist(heart_failure_data$ejection_fraction)

# Perform a t-test to compare age between hypertension and non-hypertension patients
t.test(age ~ hypertension, data = patient_df)

# Perform a chi-squared test to assess the association between hypertension status and heart rate
chisq.test(patient_df$hypertension, patient_df$heart_rate)

# Fit a linear regression model
linear_model <- lm(sbp ~ age + heart_rate + hypertension, data = patient_df)

# Fit a logistic regression model (assuming additional data is included)
logistic_model <- glm(cvd_risk ~ age + sbp + ldl + smoker,
  data = patient_df, family = binomial())


# --------------------------------------------------------------------------
# R for Reproducible Research
# --------------------------------------------------------------------------


# --------------------------------------------------------------------------
# Working with Medical Data Formats (DICOM, HL7, CSV)
# --------------------------------------------------------------------------

library(oro.dicom)

# Read a DICOM file
dcm_file <- readDICOMFile('path/to/dicom/file.dcm')

# Extract header information
header_info <- extractHeader(dcm_file$hdr, 'PatientName', numeric = FALSE)

#Access image data
image_data <- dcm_file$img

# The book's HL7 example is omitted: it used a package named 'ha7r', which is
# not on CRAN and could not be confirmed to exist. See ERRATA.md.

library(readr)

# Read data from a CSV file
lab_data <- read_csv('path/to/lab-data.csv')

# View the first few rows of the data frame
head(lab_data)


# --------------------------------------------------------------------------
# Synthetic Data Generation in R
# --------------------------------------------------------------------------

# Example: Generating synthetic patient data
set.seed(123)
generate_synthetic_patients <- function(n = 100) {
  data.frame(
    age = rnorm(n, mean = 65, sd = 10),
    cholesterol = rnorm(n, mean = 200, sd = 30),
    sbp = rnorm(n, mean = 130, sd = 15),
    cvd = sample(c(0, 1), n, replace = TRUE, prob = c(0.7, 0.3))
  )
}
synthetic_data <- generate_synthetic_patients(1000)
