# Chapter 5: Risk Prediction
# Machine Learning in Cardiology: A Practical R-Based Approach
# Runnable top to bottom. All data are simulated in the script.

# --------------------------------------------------------------------------
# Logistic Regression
# --------------------------------------------------------------------------

library(tidyverse)  # for data manipulation
set.seed(123)
n <- 500

# Generate dataset with correlated risk factors
cvd_data <- data.frame(
  age = rnorm(n, mean = 50, sd = 15),
  sbp = rnorm(n, mean = 130, sd = 20),
  cholesterol = rnorm(n, mean = 200, sd = 35),
  smoker = factor(rbinom(n, 1, 0.3), labels = c("No", "Yes"))
)

# Add CVD outcome based on risk factors
cvd_data$risk <- with(cvd_data, 
  plogis(-10 + 0.08 * age + 0.02 * sbp + 0.01 * cholesterol + 
         1.5 * (smoker == "Yes")))
cvd_data$cvd <- factor(rbinom(n, 1, cvd_data$risk), 
                       labels = c("No", "Yes"))

library(pROC)   # for roc, auc
# Fit model
log_model <- glm(cvd ~ age + sbp + cholesterol + smoker, 
                 data = cvd_data, 
                 family = binomial())

# Plot ROC curve
roc_obj <- roc(cvd_data$cvd, predict(log_model, type = "response"))

plot(roc_obj, 
     main = "Logistic Regression ROC Curve",
     col = "#0072B2", 
     lwd = 2)
legend("bottomright", 
       legend = sprintf("AUC = %.3f", auc(roc_obj)),
       bty = "n")


# --------------------------------------------------------------------------
# Decision Trees
# --------------------------------------------------------------------------

library(rpart)      # for decision tree creation
# Fit and plot decision tree
tree_model <- rpart(cvd ~ age + sbp + cholesterol + smoker, 
                   data = cvd_data,
                   method = "class",
                   control = rpart.control(maxdepth = 3))

library(rpart.plot) # for tree visualization
rpart.plot(tree_model,
           main = "CVD Risk Decision Tree",
           extra = 2)


# --------------------------------------------------------------------------
# Random Forests
# --------------------------------------------------------------------------

library(randomForest)  # for random forest

# Fit random forest and plot importance
rf_model <- randomForest(cvd ~ age + sbp + cholesterol + smoker, 
                        data = cvd_data,
                        ntree = 100,
                        importance = TRUE)

# Calculate feature importance
importance_data <- importance(rf_model)
barplot(importance_data[,4],
        names.arg = rownames(importance_data),
        main = "RF Feature Importance",
        col = "#0072B2",
        las = 2)


# --------------------------------------------------------------------------
# Gradient Boosting Machines
# --------------------------------------------------------------------------

library(gbm)

# Fit GBM model
gbm_model <- gbm(
  formula = as.numeric(cvd) - 1 ~ age + sbp + cholesterol + smoker,
  data = cvd_data,
  distribution = "bernoulli",
  n.trees = 100,
  interaction.depth = 3,
  shrinkage = 0.01,
  cv.folds = 5
)

summary(gbm_model, 
        plotit = TRUE, 
        cBars = 4,
        main = "GBM Feature Importance")


# --------------------------------------------------------------------------
# Model Calibration
# --------------------------------------------------------------------------

# Get predictions from each model
pred_logistic <- predict(log_model, type = "response")
pred_rf <- predict(rf_model, type = "prob")[,2]

# Create bins for calibration
bins <- cut(pred_logistic, breaks = seq(0, 1, length.out = 11))
cal_log <- data.frame(
  pred = tapply(pred_logistic, bins, mean),
  obs = tapply(cvd_data$cvd == "Yes", bins, mean)
)

bins <- cut(pred_rf, breaks = seq(0, 1, length.out = 11))
cal_rf <- data.frame(
  pred = tapply(pred_rf, bins, mean),
  obs = tapply(cvd_data$cvd == "Yes", bins, mean)
)

# Plot calibration curves
plot(0:1, 0:1, type = "l", lty = 2, col = "gray",
     xlab = "Predicted Probability",
     ylab = "Observed Proportion",
     main = "Calibration Curves")

lines(cal_log$pred, cal_log$obs, col = "blue", lwd = 2)
lines(cal_rf$pred, cal_rf$obs, col = "red", lwd = 2)

legend("bottomright", 
       legend = c("Ideal", "Logistic", "Random Forest"),
       col = c("gray", "blue", "red"),
       lty = c(2, 1, 1),
       lwd = c(1, 2, 2))
