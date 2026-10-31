# Chapter 7: Survival Analysis
# Machine Learning in Cardiology: A Practical R-Based Approach
# Runnable top to bottom. All data are simulated in the script.

# --------------------------------------------------------------------------
# Cox Proportional Hazards Model
# --------------------------------------------------------------------------

set.seed(123)
n <- 1000

# Generate data frame with all variables at once
data <- data.frame(
  age = rnorm(n, 65, 12),
  ef = rnorm(n, 40, 15),
  creatinine = rlnorm(n, 0.5, 0.4),
  sodium = rnorm(n, 140, 4)
)

# Add survival times and events (using age, ef as main predictors)
# Generate data frame with all variables at once
data <- data.frame(
  age = rnorm(n, 65, 12),
  ef = rnorm(n, 40, 15),
  creatinine = rlnorm(n, 0.5, 0.4),
  sodium = rnorm(n, 140, 4)
)

# Add survival times and events (adjusted scale for ~70% events)
lambda <- exp(-3 + 0.03*scale(data$age) - 0.02*scale(data$ef))
data$obs_time <- rweibull(n, shape=1.2, scale=1/lambda)
data$event <- rbinom(n, 1, 0.7)  # About 70% events
data$cause <- ifelse(data$event == 0, 0, 
                     ifelse(runif(n) < 0.6, 1, 2))  # 0=censored, 1=CV death, 2=other

library(survival)
library(survminer)

# Create Kaplan-Meier plot
ggsurvplot(
  surv_fit(Surv(obs_time, event) ~ 1, data = data),
  xlab = "Time (days)",
  ylab = "Survival probability",
  title = "Overall Survival",
  conf.int = TRUE,
  risk.table = TRUE,
  risk.table.height = 0.25,
  ggtheme = theme_minimal()
)

library(survival)

cox_model <- coxph(Surv(obs_time, event) ~ age + ef + creatinine + sodium, data = data)

summary(cox_model)


# --------------------------------------------------------------------------
# Survival Random Forests
# --------------------------------------------------------------------------

library(randomForestSRC)

# Fit survival random forest
rf_mod <- rfsrc(Surv(obs_time, event) ~ age + ef + creatinine + sodium, 
                data = data, 
                ntree = 500)

# Summary results
print(rf_mod)

# Print variable importance
plot(vimp(rf_mod))


# --------------------------------------------------------------------------
# Competing Risks Analysis
# --------------------------------------------------------------------------

library(cmprsk)

# Calculate cumulative incidence
cif <- cuminc(data$obs_time, data$cause)

# Plot cumulative incidence
plot(cif, 
     xlab = "Time (days)",
     ylab = "Cumulative Incidence",
     lty = 1:2,
     lwd = 2)
legend("topright", 
       legend = c("Cardiovascular death", "Other cause"),
       lty = 1:2,
       lwd = 2)


# --------------------------------------------------------------------------
# Predicting Heart Failure Mortality
# --------------------------------------------------------------------------

train_idx <- sample(1:nrow(data), 0.7*nrow(data))
train_data <- data[train_idx,]
test_data <- data[-train_idx,]

# Fit both models
cox_mod <- coxph(Surv(obs_time, event) ~ age + ef + creatinine + sodium, 
                 data = train_data)

rf_mod <- rfsrc(Surv(obs_time, event) ~ age + ef + creatinine + sodium, 
                data = train_data, 
                ntree = 500)

# Get predictions
cox_pred <- predict(cox_mod, newdata = test_data, type = "risk")
rf_pred <- predict(rf_mod, newdata = test_data)$predicted

# Compare performance
# Corrected from the printed book (see ERRATA.md): both models are now scored
# the same way, on the held-out test set. Higher predictions mean higher risk
# for both models, so reverse = TRUE.
cox_cindex <- concordance(Surv(obs_time, event) ~ cox_pred, data = test_data,
                          reverse = TRUE)$concordance
rf_cindex <- concordance(Surv(obs_time, event) ~ rf_pred, data = test_data,
                         reverse = TRUE)$concordance

# Print results
results <- data.frame(
  Model = c("Cox PH", "Random Forest"),
  C_index = c(cox_cindex, rf_cindex)
)
print(results)
