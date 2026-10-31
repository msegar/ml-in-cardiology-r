# Chapter 8: Genetics
# Machine Learning in Cardiology: A Practical R-Based Approach
# Runnable top to bottom. All data are simulated in the script.

# --------------------------------------------------------------------------
# Polygenic Risk Scores (PRS)
# --------------------------------------------------------------------------

library(dplyr)
library(tidyr)
set.seed(123)

# Create synthetic genotype data for 100 individuals and 5 SNPs
n_individuals <- 100
n_snps <- 5

# Generate random genotypes (0, 1, 2) for each individual
genotype_data <- data.frame(
  SNP = paste0("rs", 1:n_snps),
  matrix(sample(0:2, n_individuals * n_snps, replace = TRUE), 
         nrow = n_snps, ncol = n_individuals)
)

# Create synthetic GWAS summary statistics
gwas_summary_stats <- data.frame(
  SNP = paste0("rs", 1:n_snps),
  beta = rnorm(n_snps, mean = 0, sd = 0.1)  # Effect sizes
)

# Calculate PRS for each individual
prs_data <- genotype_data %>%
  gather(individual, num_alleles, -SNP) %>%
  left_join(gwas_summary_stats, by = "SNP") %>%
  group_by(individual) %>%
  summarize(PRS = sum(num_alleles * beta, na.rm = TRUE))

# View first few PRS scores
head(prs_data,n=3)

# PRS Distribution Visualization
library(ggplot2)
library(dplyr)

data_prs <- data.frame(
  prs = c(rnorm(500, 0.5, 1), rnorm(500, -0.5, 1)),
  status = factor(rep(c("Case", "Control"), each = 500))
)

ggplot(data_prs, aes(x = prs, fill = status)) +
  geom_density(alpha = 0.7) +
  theme_minimal() +
  labs(title = "Polygenic Risk Score Distribution",
       x = "PRS", y = "Density")


# --------------------------------------------------------------------------
# Genome-Wide Association Studies (GWAS)
# --------------------------------------------------------------------------

library(glmnet)

# Generate synthetic GWAS data
n_samples <- 1000
n_snps <- 100

# Create synthetic SNP matrix
X <- matrix(sample(0:2, n_samples * n_snps, replace = TRUE), 
           nrow = n_samples, ncol = n_snps)
colnames(X) <- paste0("SNP", 1:n_snps)

# Generate synthetic disease status (0/1)
# Using 5 causal SNPs with stronger effects
true_betas <- rep(0, n_snps)
causal_snps <- c(5, 20, 40, 60, 80)
true_betas[causal_snps] <- runif(5, 0.5, 1)

# Calculate disease probability and status
logit <- X %*% true_betas
prob <- 1/(1 + exp(-logit))
y <- rbinom(n_samples, 1, prob)

# Fit LASSO model
cv_fit <- cv.glmnet(X, y, family = "binomial", alpha = 1)
best_lambda <- cv_fit$lambda.min
lasso_fit <- glmnet(X, y, family = "binomial", alpha = 1, lambda = best_lambda)

# Get non-zero coefficients
coef_lasso <- coef(lasso_fit)[-1]  # Exclude intercept
selected_snps <- which(coef_lasso != 0)
print(paste("Selected SNPs:", paste(selected_snps, collapse = ", ")))


# --------------------------------------------------------------------------
# Gene Expression Analysis
# --------------------------------------------------------------------------

n <- 1000
counts <- matrix(rnbinom(n * 20, size = 3, mu = 100), nrow = n)

# Make first 50 genes differential in treated samples (last 10 samples)
counts[1:50, 11:20] <- matrix(rnbinom(50 * 10, size = 3, mu = 400), nrow = 50)

condition <- factor(rep(c("control", "treated"), each = 10))
results <- data.frame(
  gene = paste0("gene", 1:n),
  pvalue = sapply(1:n, function(i) t.test(counts[i, 1:10], counts[i, 11:20])$p.value),
  logFC = log2(rowMeans(counts[, 11:20]) / rowMeans(counts[, 1:10]))
)

sig_genes <- subset(results, p.adjust(pvalue, "BH") < 0.05 & abs(logFC) > 1)
print(head(sig_genes))


# --------------------------------------------------------------------------
# Pathway Analysis and Network Modeling
# --------------------------------------------------------------------------

library(igraph)

# Create simple network with 20 genes and their interactions
edges <- data.frame(
  source = sample(paste0("Gene", 1:20), 50, replace = TRUE),
  target = sample(paste0("Gene", 1:20), 50, replace = TRUE)
)

# Create network and find hub genes
net <- graph_from_data_frame(edges, directed = FALSE)
hubs <- head(sort(degree(net), decreasing = TRUE), 5)

# Print results
print("Top hub genes and their connections:")
print(hubs)

# Plot network
plot(net, 
     vertex.size = degree(net)*2,  # Size nodes by connections
     vertex.label.cex = 0.8,       # Adjust label size
     layout = layout_with_fr,      # Use Fruchterman-Reingold layout
     main = "Gene Interaction Network")


# --------------------------------------------------------------------------
# Integrating Genomic Data with Clinical Data
# --------------------------------------------------------------------------

# Risk Integration Heatmap
data_integrated <- data.frame(
  patient = rep(1:20, 4),
  data_type = rep(c("Genomic", "Clinical", "Expression", "Imaging"), each = 20),
  risk = scale(rnorm(80))
)

ggplot(data_integrated, aes(x = factor(patient), y = data_type, fill = risk)) +
  geom_tile() +
  theme_minimal() +
  scale_fill_viridis_c() +
  labs(title = "Integrated Patient Risk Profiles",
       x = "Patient ID", y = "Data Type")

# Load required libraries
library(dplyr)
library(tidyr)

# Generate synthetic integrated dataset
n_patients <- 200

# Clinical data
clinical_data <- data.frame(
  patient_id = paste0("P", 1:n_patients),
  age = rnorm(n_patients, mean = 60, sd = 10),
  sex = sample(c("M", "F"), n_patients, replace = TRUE),
  bp_systolic = rnorm(n_patients, mean = 130, sd = 20),
  bp_diastolic = rnorm(n_patients, mean = 80, sd = 10),
  bmi = rnorm(n_patients, mean = 27, sd = 4)
)

# Genomic risk scores (from previous PRS calculation)
genomic_data <- data.frame(
  patient_id = paste0("P", 1:n_patients),
  prs_score = rnorm(n_patients, mean = 0, sd = 1),
  risk_allele_count = sample(0:10, n_patients, replace = TRUE)
)

# Imaging data (simplified metrics)
imaging_data <- data.frame(
  patient_id = paste0("P", 1:n_patients),
  ejection_fraction = rnorm(n_patients, mean = 60, sd = 10),
  left_ventricle_mass = rnorm(n_patients, mean = 150, sd = 30)
)

# Integrate all data sources
integrated_data <- clinical_data %>%
  left_join(genomic_data, by = "patient_id") %>%
  left_join(imaging_data, by = "patient_id")

# Create risk score combining all factors
integrated_data <- integrated_data %>%
  mutate(
    risk_score = scale(
      0.3 * scale(prs_score) +
      0.2 * scale(bp_systolic) +
      0.2 * scale(ejection_fraction) +
      0.2 * scale(age) +
      0.1 * scale(bmi)
    )
  )

# Identify high-risk patients (top 10%)
high_risk <- integrated_data %>%
  arrange(desc(risk_score)) %>%
  slice_head(n = n_patients / 10)

print(paste("Number of high-risk patients identified:", nrow(high_risk)))


# --------------------------------------------------------------------------
# Predicting Heart Failure Risk
# --------------------------------------------------------------------------

# Load required libraries
library(glmnet)
library(caret)

# Generate synthetic dataset for cardiomyopathy prediction
n_samples <- 500

# Create feature matrix combining clinical and genomic data
data <- data.frame(
  # Clinical features
  age = rnorm(n_samples, mean = 60, sd = 10),
  bmi = rnorm(n_samples, mean = 27, sd = 4),
  systolic_bp = rnorm(n_samples, mean = 130, sd = 20),
  
  # Genetic features (5 key SNPs)
  snp1 = sample(0:2, n_samples, replace = TRUE),
  snp2 = sample(0:2, n_samples, replace = TRUE),
  snp3 = sample(0:2, n_samples, replace = TRUE),
  snp4 = sample(0:2, n_samples, replace = TRUE),
  snp5 = sample(0:2, n_samples, replace = TRUE)
)

# Generate cardiomyopathy status based on features
risk_score <- with(data, 
  0.3 * scale(age) +
  0.2 * scale(bmi) +
  0.2 * scale(systolic_bp) +
  0.1 * (snp1 + snp2 + snp3 + snp4 + snp5)
)
prob <- plogis(risk_score)
data$cardiomyopathy <- rbinom(n_samples, 1, prob)

# Split data into training and testing sets
train_idx <- sample(1:n_samples, 0.7 * n_samples)
X_train <- as.matrix(data[train_idx, -9])  # Exclude cardiomyopathy status
X_test <- as.matrix(data[-train_idx, -9])
y_train <- data$cardiomyopathy[train_idx]
y_test <- data$cardiomyopathy[-train_idx]

# Train LASSO model
cv_fit <- cv.glmnet(X_train, y_train, family = "binomial", alpha = 1)
best_lambda <- cv_fit$lambda.min

# Make predictions
predictions <- predict(cv_fit, X_test, s = "lambda.min", type = "response")

# Calculate performance metrics
thresh <- 0.5
pred_class <- ifelse(predictions > thresh, 1, 0)
accuracy <- mean(pred_class == y_test)
sensitivity <- sum(pred_class & y_test) / sum(y_test)
specificity <- sum(!pred_class & !y_test) / sum(!y_test)

# Create performance metrics dataframe
metrics <- data.frame(
  Metric = c("Accuracy", "Sensitivity", "Specificity"),
  Value = c(
    mean(pred_class == y_test),
    sum(pred_class & y_test) / sum(y_test),
    sum(!pred_class & !y_test) / sum(!y_test)
  )
)

# Create plot
ggplot(metrics, aes(x = Metric, y = Value, fill = Metric)) +
  geom_bar(stat = "identity") +
  scale_y_continuous(limits = c(0, 1), labels = scales::percent) +
  labs(title = "Cardiomyopathy Prediction Model Performance",
       y = "Score") +
  theme_minimal() +
  theme(legend.position = "none") +
  coord_flip()
