# Errata and code changes

Corrections to the first printing (2025). The code in this repository already includes them.

## Changes to a printed result

### Chapter 7, Predicting Heart Failure Mortality

The comparison of the Cox and random forest models had two errors:

1. `get.cindex()` was called with its arguments in the wrong order. The correct order is `(time, censoring, predicted)`, and the function returns 1 minus the C-index. On current versions of `randomForestSRC` the printed call stops with an error.
2. The Cox C-index was computed on the training data and the random forest C-index on the test data, although the text describes both as evaluated on unseen data.

Both models are now scored on the test set with `survival::concordance()`.

| Model | C-index, printed | C-index, corrected |
|---|---|---|
| Cox PH | 0.535 | 0.497 |
| Random Forest | 0.497 | 0.471 |

Neither model discriminates better than chance here, which is expected from the simulation: `event` is drawn independently of the predictors, and `obs_time` depends only weakly on age and ejection fraction. The example shows how to run the comparison, and it should not be read as evidence that one model outperforms the other.

The random forest output earlier in the chapter (error rates and variable importance) also differs from print, and it changes between `randomForestSRC` versions. Since the predictors have little or no real effect in the simulation, the variable importance ranking mostly reflects noise.

The corrected values may also come from a different train/test split than the printed ones. Running the printed Cox calculation today gives 0.525, not 0.535, even though the Cox model fitted to the full data matches print exactly. The cause has not been determined.

## Code in the printed book that does not run

### Hyphens in object names

Many excerpts in the book use hyphens where R needs underscores, as R reads `min-max-scaling` as subtraction. These are fixed in `snippets/`:

| Chapter | Printed | Corrected |
|---|---|---|
| 2 | `cardiology-data`, `cvd-risk`, `survival-data` | `cardiology_data`, `cvd_risk`, `survival_data` |
| 2 | `heart_failure-class`, `ejection-fraction` | `heart_failure_class`, `ejection_fraction` |
| 2 | `knitr::opts-chunk` | `knitr::opts_chunk` |
| 4 | `min-max-scaling()` | `min_max_scaling()` |
| 6 | `input-shape`, `binary-crossentropy`, `theme-minimal()` | `input_shape`, `binary_crossentropy`, `theme_minimal()` |

### Other corrections

| Chapter | Printed | Change |
|---|---|---|
| 2 | `ha7r` package for parsing HL7 | Removed. No such package is on CRAN and we could not confirm it exists. |
| 2 | `options(memory.limit=8000)` | Removed. This limit no longer exists in current R. |
| 2 | `install.packages('survival')` followed by `coxph()` | Added `library(survival)`. |
| 2 | `extractHeader(dcm_file$hdr, 'PatientName')` | Added `numeric = FALSE`, since patient names are text. |
| 2 | `library(readr)` followed by `read.csv()` | Now `read_csv()`, the `readr` function. |
| 2 | R Markdown example, Dockerfile and Git commands | Restored chunk fences and corrected quote characters. |
| 4 | Missing-data plot | Added the `+` missing before `labs()`. |
| 4 | SMOTE with `DMwR` | Now uses `smotefamily`, since `DMwR` is no longer on CRAN. |
| 4 | `library(impute)` | Added a note that `impute` is on Bioconductor, not CRAN. |
| 6 | `library(kmeans)` | Removed. `kmeans()` is part of base R. |

## Smaller updates to the worked examples

These do not change any results.

- Chapter 3: `size` is now `linewidth` in `geom_line()`, following the `ggplot2` change.
- Chapter 4: `across(..., round, 2)` is now `across(..., ~ round(.x, 2))`, following the `dplyr` change.
- Chapter 7: The cumulative incidence plot's axis now reads "Time (days)", matching the Kaplan-Meier plot. The printed book used days in one and years in the other, though the simulated time has no real unit.
- Chapter 2: Added `set.seed(123)` to the synthetic data snippet.

The code that typesets Table "Bias Mitigation Strategies" in Chapter 9 is left out, because it only formats text for the book.

## Using the snippets

Some Chapter 2 snippets use columns that the `patient_df` example does not have, such as `cholesterol` and `sbp`. The book treats these as placeholders for your own data.

The Keras snippet in Chapter 6 has not been tested. It needs a working TensorFlow install, and `keras3` is now the current R package.

Found something else? Please open an issue.
