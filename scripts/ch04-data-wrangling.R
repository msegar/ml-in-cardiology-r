# Chapter 4: Data Wrangling
# Machine Learning in Cardiology: A Practical R-Based Approach
# Runnable top to bottom. All data are simulated in the script.

# --------------------------------------------------------------------------
# Handling Missing Values
# --------------------------------------------------------------------------

library(tidyverse)  # For data manipulation
set.seed(123)

# Generate synthetic patient data
n_patients <- 1000

# Generate baseline characteristics
synthetic_data <- tibble(
  patient_id = 1:n_patients,
  age = rnorm(n_patients, mean = 65, sd = 12),
  gender = sample(c("M", "F"), n_patients, replace = TRUE),
  bmi = rnorm(n_patients, mean = 28, sd = 5),
  systolic_bp = rnorm(n_patients, mean = 130, sd = 20),
  diastolic_bp = rnorm(n_patients, mean = 80, sd = 10),
  heart_rate = rnorm(n_patients, mean = 75, sd = 12),
  
  # Create some missing values
  lvef = case_when(
    runif(n_patients) < 0.2 ~ NA_real_,  # 20% missing
    TRUE ~ rnorm(n_patients, mean = 55, sd = 10)
  ),
  
  # Create some outliers
  cholesterol = case_when(
    runif(n_patients) < 0.05 ~ rnorm(n_patients, mean = 400, sd = 30),  # 5% outliers
    TRUE ~ rnorm(n_patients, mean = 200, sd = 30)
  ),
  
  # Create imbalanced outcome
  cardiac_event = rbinom(n_patients, 1, prob = 0.1)  # 10% event rate
)

# Clean up values
synthetic_data <- synthetic_data %>%
  mutate(across(where(is.numeric), ~ round(.x, 2)))


# --------------------------------------------------------------------------
# Outlier Detection and Treatment
# --------------------------------------------------------------------------

library(tidyverse)  # For ggplot2 and data manipulation

# Calculate z-scores for numerical variables
z_scores <- synthetic_data %>%
  select(where(is.numeric)) %>%
  select(-patient_id, -cardiac_event) %>%
  scale() %>%
  as.data.frame()

# Create boxplot for key variables
synthetic_data %>%
  select(cholesterol, systolic_bp, lvef) %>%
  gather(key = "variable", value = "value") %>%
  ggplot(aes(x = variable, y = value)) +
  geom_boxplot(fill = "#0072B2", alpha = 0.7) +
  labs(
    title = "Outlier Detection Using Boxplots",
    x = "Variable",
    y = "Value"
  ) +
  theme_minimal()


# --------------------------------------------------------------------------
# Feature Scaling: Normalization and Standardization
# --------------------------------------------------------------------------

library(tidyverse)  # For ggplot2 and data manipulation
library(gridExtra)  # For arranging multiple plots

# Apply different scaling methods
scaled_data <- synthetic_data %>%
  select(cholesterol, systolic_bp) %>%
  mutate(
    cholesterol_normalized = scale(cholesterol, center = FALSE, scale = diff(range(cholesterol))),
    cholesterol_standardized = scale(cholesterol),
    systolic_bp_normalized = scale(systolic_bp, center = FALSE, scale = diff(range(systolic_bp))),
    systolic_bp_standardized = scale(systolic_bp)
  )

# Create comparison plots
p1 <- ggplot(scaled_data, aes(x = cholesterol)) +
  geom_density(fill = "#0072B2", alpha = 0.5) +
  labs(title = "Original Distribution", x = "Value", y = "Density") +
  theme_minimal()

p2 <- ggplot(scaled_data, aes(x = cholesterol_normalized)) +
  geom_density(fill = "#009E73", alpha = 0.5) +
  labs(title = "Normalized Distribution", x = "Value", y = "Density") +
  theme_minimal()

p3 <- ggplot(scaled_data, aes(x = cholesterol_standardized)) +
  geom_density(fill = "#D55E00", alpha = 0.5) +
  labs(title = "Standardized Distribution", x = "Value", y = "Density") +
  theme_minimal()

grid.arrange(p1, p2, p3, ncol = 3)


# --------------------------------------------------------------------------
# Addressing Class Imbalance
# --------------------------------------------------------------------------

library(smotefamily)
library(tidyverse)
library(mice)
library(gridExtra)

smote_data <- synthetic_data %>%
  select_if(is.numeric) %>%
  select(-patient_id) # Remove ID column

# Get the first imputed dataset
imp <- mice(smote_data, m = 5, method = 'pmm', printFlag = FALSE)
complete_data <- complete(imp)  

# Now apply SMOTE on the imputed data
smote_result <- SMOTE(X = complete_data, 
                      target = complete_data$cardiac_event,
                      K = 5,
                      dup_size = 2)

# Create balanced dataset
balanced_data <- smote_result$data %>%
  select(-cardiac_event) %>%  # remove original cardiac_event column
  rename(cardiac_event = class)  # rename class to cardiac_event

# Visualize the class distribution before and after SMOTE
p1 <- ggplot(complete_data, aes(x = factor(cardiac_event))) +
  geom_bar(fill = "#56B4E9") +
  labs(
    title = "Original Class Distribution\n(After Imputation)",
    x = "Cardiac Event",
    y = "Count"
  ) +
  theme_minimal() +
  scale_x_discrete(labels = c("No Event", "Event"))

p2 <- ggplot(balanced_data, aes(x = factor(cardiac_event))) +
  geom_bar(fill = "#009E73") +
  labs(
    title = "Distribution After SMOTE",
    x = "Cardiac Event",
    y = "Count"
  ) +
  theme_minimal() +
  scale_x_discrete(labels = c("No Event", "Event"))

# Add imputation diagnostics
p3 <- complete_data %>%
  select(lvef) %>%  # choosing LVEF as example
  ggplot(aes(x = lvef)) +
  geom_density(fill = "#CC79A7", alpha = 0.7) +
  labs(
    title = "Distribution of Imputed LVEF",
    x = "LVEF (%)",
    y = "Density"
  ) +
  theme_minimal()

# Arrange all plots
grid.arrange(p1, p2, p3, 
             layout_matrix = rbind(c(1,2), c(3,3)),
             heights = c(1, 0.8))
