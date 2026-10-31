# Chapter 9: Bias and Fairness
# Machine Learning in Cardiology: A Practical R-Based Approach
# Runnable top to bottom. All data are simulated in the script.

# --------------------------------------------------------------------------
# Identifying Sources of Bias
# --------------------------------------------------------------------------

# Load required libraries
library(dplyr)
library(tidyr)
library(ggplot2)
set.seed(123)

# Generate synthetic patient data
n_patients <- 1000

# Create synthetic patient demographics and outcomes
patient_data <- data.frame(
  patient_id = 1:n_patients,
  age = rnorm(n_patients, mean = 60, sd = 15),
  gender = sample(c("Male", "Female"), n_patients, replace = TRUE, prob = c(0.6, 0.4)),
  race = sample(c("White", "Black", "Asian", "Hispanic"), n_patients, replace = TRUE),
  income_level = sample(c("Low", "Medium", "High"), n_patients, replace = TRUE),
  hospital_type = sample(c("Urban", "Rural"), n_patients, replace = TRUE),
  risk_score = runif(n_patients)
)

# Add biased outcomes
patient_data$outcome <- with(patient_data, {
  # Create biased probability based on demographics
  prob <- 0.3 + 
    0.2 * (gender == "Male") +  # Gender bias
    0.15 * (hospital_type == "Urban") +  # Hospital type bias
    0.1 * (income_level == "High")  # Income level bias
  
  # Generate outcomes
  rbinom(n_patients, 1, prob)
})

# Outcome disparities across demographics
outcome_disparities <- patient_data %>%
  group_by(gender, hospital_type, income_level) %>%
  summarize(
    outcome_rate = mean(outcome),
    n = n(),
    .groups = 'drop'
  )

# Figure 1: Intersectional bias visualization
ggplot(outcome_disparities, 
       aes(x = gender, y = outcome_rate, fill = hospital_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~income_level) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Intersectional Bias in Healthcare Outcomes",
       subtitle = "Outcome rates vary by gender, hospital type, and income level",
       y = "Outcome Rate",
       x = "Gender") +
  theme_minimal() +
  theme(legend.position = "bottom")


# --------------------------------------------------------------------------
# Fairness Metrics: Quantifying Disparate Impact
# --------------------------------------------------------------------------

# Calculate simple DI ratio for each attribute
di_results <- data.frame(
  attribute = c("Gender", "Hospital", "Income"),
  di_ratio = c(
    mean(patient_data$outcome[patient_data$gender == "Male"]) / 
      mean(patient_data$outcome[patient_data$gender == "Female"]),
    mean(patient_data$outcome[patient_data$hospital_type == "Urban"]) / 
      mean(patient_data$outcome[patient_data$hospital_type == "Rural"]),
    mean(patient_data$outcome[patient_data$income_level == "High"]) / 
      mean(patient_data$outcome[patient_data$income_level == "Low"])
  )
)

# Create simple visualization
ggplot(di_results, aes(x = attribute, y = di_ratio)) +
  geom_rect(xmin = -Inf, xmax = Inf, ymin = 0.8, ymax = 1.25, 
            fill = "lightgreen", alpha = 0.2) +
  geom_point(size = 4, color = "darkblue") +
  geom_hline(yintercept = 1, linetype = "dashed") +
  labs(title = "Disparate Impact Ratios",
       subtitle = "Green zone shows acceptable range (0.8-1.25)",
       y = "Disparate Impact Ratio") +
  theme_minimal()


# --------------------------------------------------------------------------
# Bias Mitigation Techniques: Re-weighting
# --------------------------------------------------------------------------

df <- data.frame(
  gender = factor(rep(c("Female", "Male"), c(300, 700))),
  risk = c(rnorm(300, 0.3, 0.1), rnorm(700, 0.7, 0.1))
)

# Compare unweighted vs weighted predictions
results <- data.frame(
  method = c("Unweighted", "Weighted"),
  prediction = c(
    mean(df$risk),  # Biased toward majority
    mean(c(mean(df$risk[df$gender == "Female"]), 
           mean(df$risk[df$gender == "Male"])))  # Equal group weights
  )
)

# Visualize
ggplot(df, aes(x = risk, fill = gender)) +
  geom_density(alpha = 0.5) +
  geom_vline(data = results, aes(xintercept = prediction, 
                                 color = method), linetype = "dashed") +
  labs(title = "Impact of Weighting on Predictions") +
  theme_minimal()


# --------------------------------------------------------------------------
# Sampling Techniques for Bias Mitigation
# --------------------------------------------------------------------------

library(ROSE)

# Apply ROSE to balance classes
balanced_df <- ROSE(gender ~ risk_score, data = patient_data)$data

# Compare distributions before and after
results <- data.frame(
  Method = c("Original", "Balanced"),
  Female_prop = c(
    mean(patient_data$gender == "Female"),
    mean(balanced_df$gender == "Female")
  )
)

print("\nProportion of females:")
print(results)


# --------------------------------------------------------------------------
# Understanding Bias in Algorithms
# --------------------------------------------------------------------------

# Demographics and outcomes visualization
patient_data %>%
  group_by(gender, hospital_type) %>%
  summarize(
    outcome_rate = mean(outcome),
    .groups = 'drop'
  ) %>%
  ggplot(aes(x = gender, y = outcome_rate, fill = hospital_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Outcome Rates by Gender and Hospital Type",
       y = "Rate") +
  theme_minimal()

# Income level disparity visualization
patient_data %>%
  group_by(income_level, gender) %>%
  summarize(
    outcome_rate = mean(outcome),
    .groups = 'drop'
  ) %>%
  ggplot(aes(x = income_level, y = outcome_rate, fill = gender)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Outcome Rates by Income Level and Gender",
       y = "Rate") +
  theme_minimal()


# --------------------------------------------------------------------------
# Mitigation Strategies
# --------------------------------------------------------------------------

# Fit three different approaches
# 1. Baseline model
base_preds <- predict(glm(outcome ~ gender + hospital_type, 
                          data = patient_data, 
                          family = "binomial"), type = "response")

# 2. Weighted model with inverse probability weights
weights <- ifelse(patient_data$gender == "Female", 
                  2 * mean(patient_data$gender == "Male"),
                  2 * mean(patient_data$gender == "Female"))
weight_preds <- predict(glm(outcome ~ gender + hospital_type, 
                            data = patient_data,
                            weights = weights, 
                            family = "binomial"), type = "response")

# 3. Threshold-adjusted predictions
female_threshold <- 0.4  # Lower threshold for underrepresented group
male_threshold <- 0.6    # Higher threshold for overrepresented group
thresh_preds <- ifelse(patient_data$gender == "Female",
                       base_preds > female_threshold,
                       base_preds > male_threshold)

# Combine predictions for visualization
results <- data.frame(
  Gender = rep(patient_data$gender, 3),
  Method = rep(c("Baseline", "Weighted", "Threshold-Adjusted"), each = nrow(patient_data)),
  Prediction = c(base_preds, weight_preds, as.numeric(thresh_preds))
) %>%
  group_by(Method, Gender) %>%
  summarize(Rate = mean(Prediction), .groups = 'drop')

# Visualize
ggplot(results, aes(x = Method, y = Rate, fill = Gender)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "grey50") +
  scale_fill_manual(values = c("#FF9999", "#66C2A5")) +
  labs(title = "Comparison of Bias Mitigation Techniques",
       y = "Average Prediction Rate") +
  theme_minimal()
