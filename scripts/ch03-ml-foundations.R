# Chapter 3: Machine Learning Foundations
# Machine Learning in Cardiology: A Practical R-Based Approach
# Runnable top to bottom. All data are simulated in the script.

# --------------------------------------------------------------------------
# Supervised vs. Unsupervised Learning
# --------------------------------------------------------------------------

# Required libraries
library(tidyverse)
set.seed(123) # for reproducibility

# Create synthetic patient dataset
n_patients <- 1000

# Generate features
age <- rnorm(n_patients, mean = 60, sd = 10)
systolic_bp <- rnorm(n_patients, mean = 130 + 0.5 * (age - 60), sd = 15)
cholesterol <- rnorm(n_patients, mean = 200 + 0.3 * (age - 60), sd = 30)
glucose <- rnorm(n_patients, mean = 100 + 0.2 * (age - 60), sd = 20)
bmi <- rnorm(n_patients, mean = 25 + 0.1 * (age - 60), sd = 4)

# Create binary outcome (heart disease risk)
logit <- -25 + 0.15 * age + 0.05 * systolic_bp + 
         0.02 * cholesterol + 0.03 * glucose + 0.25 * bmi
prob <- 1 / (1 + exp(-logit))
heart_disease <- rbinom(n_patients, 1, prob)

# Combine into dataset
patient_data <- data.frame(
  age = age,
  systolic_bp = systolic_bp,
  cholesterol = cholesterol,
  glucose = glucose,
  bmi = bmi,
  heart_disease = factor(heart_disease, 
                        levels = c(0, 1), 
                        labels = c("No", "Yes")))


# --------------------------------------------------------------------------
# Feature Engineering
# --------------------------------------------------------------------------

# Required libraries
library(tidyverse)
library(corrplot)

# Create correlation matrix visualization
correlation_matrix <- cor(patient_data[, 1:5])
corrplot(correlation_matrix, 
         method = "color",
         type = "upper",
         order = "hclust",
         addCoef.col = "black",
         tl.col = "black",
         tl.srt = 45,
         title = "Feature Correlations in Patient Data",
         mar = c(0,0,1,0))


# --------------------------------------------------------------------------
# Cross-Validation
# --------------------------------------------------------------------------

# Required libraries
library(tidyverse)
library(caret)

# Set up cross-validation
ctrl <- trainControl(
  method = "cv",
  number = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = TRUE
)

# Train model with cross-validation
cv_model <- train(
  heart_disease ~ .,
  data = patient_data,
  method = "glm",
  trControl = ctrl,
  metric = "ROC"
)

# Extract fold results
fold_results <- cv_model$resample

# Create better visualization
ggplot(fold_results, aes(y = ROC, x = "Logistic Regression")) +
  geom_boxplot(width = 0.3, fill = "lightblue", alpha = 0.5) +
  geom_jitter(width = 0.1, size = 3, alpha = 0.6, color = "darkblue") +
  geom_hline(yintercept = mean(fold_results$ROC), linetype = "dashed", color = "red") +
  labs(title = "Cross-Validation Results",
       subtitle = paste("Mean ROC-AUC:", round(mean(fold_results$ROC), 3),
                       "±", round(sd(fold_results$ROC), 3)),
       x = "",
       y = "ROC-AUC") +
  theme_minimal() +
  ylim(0.8, 1)


# --------------------------------------------------------------------------
# Bias-Variance Tradeoff
# --------------------------------------------------------------------------

# Required libraries
library(tidyverse)
library(caret)
library(rpart)
library(rpart.plot)

# Create training and test sets
set.seed(123)
train_index <- createDataPartition(patient_data$heart_disease, p = 0.7, list = FALSE)
train_data <- patient_data[train_index, ]
test_data <- patient_data[-train_index, ]

# Train models of different complexities
# Simple model (high bias)
simple_model <- glm(heart_disease ~ age + systolic_bp, 
                   data = train_data, 
                   family = "binomial")

# Complex model (high variance)
complex_model <- rpart(heart_disease ~ ., 
                      data = train_data,
                      control = rpart.control(cp = 0.001))

# Compare performances
models <- list(
  simple = simple_model,
  complex = complex_model
)

# Function to calculate error
calc_error <- function(model, data) {
  if (class(model)[1] == "glm") {
    preds <- predict(model, data, type = "response")
  } else {
    preds <- predict(model, data)[,2]
  }
  mean((as.numeric(data$heart_disease) - 1 - preds)^2)
}

# Calculate errors
results <- data.frame(
  model = c("Simple", "Complex"),
  train_error = c(
    calc_error(simple_model, train_data),
    calc_error(complex_model, train_data)
  ),
  test_error = c(
    calc_error(simple_model, test_data),
    calc_error(complex_model, test_data)
  )
)

# Plot results
results_long <- results %>%
  pivot_longer(cols = c(train_error, test_error),
               names_to = "error_type",
               values_to = "error")

ggplot(results_long, aes(x = model, y = error, fill = error_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("test_error" = "#E69F00", "train_error" = "#0072B2")) +
  labs(x = "Model Complexity",
       y = "Mean Squared Error",
       title = "Bias-Variance Tradeoff",
       fill = "Error Type") +
  theme_minimal()


# --------------------------------------------------------------------------
# Performance Metrics
# --------------------------------------------------------------------------

# Required libraries
library(pROC)
library(ggplot2)

# Generate predictions
predictions <- predict(cv_model, patient_data, type = "prob")[,"Yes"]

# Calculate ROC curve with smoothing
roc_obj <- roc(patient_data$heart_disease, predictions, 
               smooth = TRUE,      # Apply smoothing
               n.points = 1000)    # Increase number of points

# Convert ROC object to data frame for ggplot
roc_data <- data.frame(
  specificity = roc_obj$specificities,
  sensitivity = roc_obj$sensitivities
)

# Create improved ROC plot
ggplot(roc_data, aes(x = 1 - specificity, y = sensitivity)) +
  geom_line(color = "#0072B2", linewidth = 1.2) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray50") +
  scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
  labs(
    x = "1 - Specificity (False Positive Rate)",
    y = "Sensitivity (True Positive Rate)",
    title = "ROC Curve for Heart Disease Prediction",
    caption = sprintf("AUC = %.3f", auc(roc_obj))
  ) +
  theme_minimal()

# Create calibration plot
cal_data <- data.frame(
  pred_prob = predictions,
  actual = as.numeric(patient_data$heart_disease) - 1
)

cal_data <- cal_data %>%
  arrange(pred_prob) %>%
  mutate(bin = cut(pred_prob, breaks = 10)) %>%
  group_by(bin) %>%
  summarise(
    mean_pred = mean(pred_prob),
    mean_actual = mean(actual),
    n = n()
  )

ggplot(cal_data, aes(x = mean_pred, y = mean_actual)) +
  geom_point(aes(size = n)) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +
  geom_smooth(method = "loess", se = FALSE, color = "blue") +
  xlim(0, 1) + ylim(0, 1) +
  labs(x = "Predicted Probability",
       y = "Observed Proportion",
       title = "Calibration Plot") +
  theme_minimal()
