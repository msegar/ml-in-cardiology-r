# Installs the packages used by the worked examples in scripts/.
# Usage, from the repository root: Rscript install.R

packages <- c(
  "caret",
  "cmprsk",
  "corrplot",
  "dplyr",
  "gbm",
  "ggplot2",
  "glmnet",
  "gridExtra",
  "igraph",
  "mice",
  "pracma",
  "pROC",
  "randomForest",
  "randomForestSRC",
  "ROSE",
  "rpart.plot",
  "smotefamily",
  "survminer",
  "tidyr",
  "tidyverse"
)

missing <- setdiff(packages, rownames(installed.packages()))

if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}

still_missing <- setdiff(packages, rownames(installed.packages()))

if (length(still_missing) > 0) {
  stop("Could not install: ", paste(still_missing, collapse = ", "))
}

message("All packages are installed.")
