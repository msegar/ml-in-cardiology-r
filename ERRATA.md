# Errata and code changes

Corrections to the first printing (2025). The code in this repository includes them, except for those under [Further corrections](#further-corrections), which are listed so that readers can apply them. The scripts there still match the printed book.

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

## Further corrections

These were found in a later review of the printed book. The code in this repository has not been changed for them.

### Statistics and methods

| Chapter | Printed | Correction |
|---|---|---|
| 2 | `chisq.test()` is used with continuous heart rate | The test needs categorical variables. |
| 2 | A p-value above the threshold indicates "a lack of effect" | It means the data do not show a significant difference, which does not prove there is no effect. |
| 3 | Cross-validation mitigates overfitting and ensures generalization | It estimates performance. Folds are not independent, and generalization needs external validation. |
| 3 | ROC and calibration plots use the data the model was trained on | These results are optimistic. Evaluate on held-out data. |
| 3 | F1 is presented as a measure for imbalanced data | F1 depends on the threshold and prevalence, and it is a poor headline metric for risk models. |
| 4 | Mean or median imputation suffices under MCAR | These methods shrink variance and understate uncertainty. A complete-case analysis is unbiased under MCAR. |
| 4 | Multiple imputation handles MNAR data | Standard multiple imputation assumes MAR. MNAR needs sensitivity analysis. |
| 4 | SMOTE and resampling are presented as remedies for imbalance | Resampling can badly miscalibrate risk models without improving discrimination ([van den Goorbergh et al., 2022](https://doi.org/10.1093/jamia/ocac093)). Changing the threshold is usually better. Never resample before splitting. |
| 5 | The `gbm` text uses `n_estimators`, `max_depth` and `min_samples_leaf` | The `gbm` arguments are `n.trees`, `interaction.depth` and `n.minobsinnode`. |
| 5 | Gradient boosting reweights hard cases and takes gradients with respect to parameters | That reweighting describes AdaBoost. Gradient boosting fits each tree to the negative gradient of the loss with respect to the current predictions. |
| 5 | The calibration figure compares logistic regression and random forest | Logistic regression is in-sample and random forest is out-of-bag, so they are not comparable. Use the same held-out data for both. |
| 5 | Importance scores guide screening and prevention | Importance scores describe the model and do not show causation. |
| 6 | RNNs need sequential preprocessing, unlike CNNs | Both take the signal as a sequence with the same input shape. |
| 6 | Wavelet and Hilbert transforms are used for PSD features | The PSD is usually estimated with Fourier-based or autoregressive methods. Using LF/HF as a measure of sympathovagal balance is contested. |
| 7 | `crr()` estimates effects on the cause-specific hazard | Fine-Gray models the subdistribution hazard. |
| 7 | Time-varying ejection fraction uses `tt()` | Use counting-process data, `Surv(start, stop, event)`, built with `tmerge()`. |
| 7 | Stroke and sudden cardiac death are competing risks for cardiovascular death | These are usually cardiovascular deaths. Non-cardiovascular death is the competing event. |
| 7 | Text on the Kaplan-Meier assumption | The estimator assumes that censored patients have the same future risk as those still observed, which fails when competing events are treated as censoring. |
| 8 | "De novo" associations | In genetics this term means new mutations. The intended meaning is newly discovered associations. |
| 8 | The GWAS section | The code fits a LASSO model and does not run a GWAS. The section also omits linkage disequilibrium, the genome-wide significance threshold of 5e-8, and ancestry adjustment. |
| 8 | The t-test on raw counts | RNA-Seq analysis should use a method designed for counts, such as `DESeq2` or `limma`. |
| 9 | The disparate impact formula and the 0.8-1.25 range | The P(Y=1) terms cancel. The range comes from US employment law and is not a clinical standard. |
| 9 | Disparate impact is applied to observed outcomes and read as algorithmic discrimination | No model is involved, so these ratios only describe differences in the data. |

### Worked examples

These do not stop the code from running, but they affect how the results should be read.

| Chapter | Issue |
|---|---|
| 2 | `lab_matrix[1, 2]` returns 8.5, not 7.2. Add `byrow = TRUE` to match the text. |
| 3 | Simulated heart disease prevalence is about 88%. |
| 4 | The "normalized" columns are not min-max scaled. Use `center = min(x)` in `scale()`. |
| 5 | The importance plot is labeled generally but shows mean decrease in Gini. |
| 7 | Simulated events are unrelated to the predictors (see the first section), so the hazard ratios, p-values and concordance in the text should not be interpreted. |
| 8 | The PRS figure assumes a separation stronger than real scores usually show, and each group has a single peak, so "bimodal" is wrong. |
| 8 | The GWAS simulation has no intercept, which gives about 97% cases. |
| 8 | The integrated risk heatmap is random noise, so the "key insights" drawn from it are not valid. |
| 8 | The hub genes come from a random network and have no biological meaning. |
| 8 | Higher ejection fraction adds risk in the integrated score. The sign should be negative. |
| 9 | The re-weighting figure compares two averages and involves no model, so it does not show that bias was corrected. |
| 9 | `ROSE()` is applied to gender itself, which simulates the protected attribute. |
| 9 | Weighted predictions match the baseline, because gender is already in the model. |

### Regulation

| Chapter | Printed | Correction |
|---|---|---|
| 10 | PMA is necessary for complex algorithms | The pathway depends on device risk class and intended use. |
| 10 | The FDA issued guidance on GMLP | These are guiding principles, published in 2021 with Health Canada and the UK's MHRA. |
| 10 | Essential requirements of the MDR | The MDR term is general safety and performance requirements (Annex I). |
| 10 | Notified Bodies must consult expert panels | This applies only to certain high-risk devices. Software classification follows Rule 11 of Annex VIII. |
| 10 | GDPR enacted in 2018 | It was adopted in 2016 and has applied since May 2018. |
| 10 | HIPAA data minimization, purpose limitation and informed consent | HIPAA uses the minimum necessary standard. Treatment, payment and operations do not need authorization. Research generally needs authorization, a waiver or de-identified data. |

Regulations have also changed since printing, so check current sources before relying on Chapter 10.

### References and text

| Chapter | Issue |
|---|---|
| 1 | The quotation attributed to Dr. Bernard Lown could not be verified. |
| 1 | The Coleman et al. citation does not support the statement about Julia and MATLAB. |
| 1, 3, 4, 5 | "Clinical Trust Metric," "Adaptive Synthetic Data Engine" and similar "adaptive" components are not established methods. |
| 3 | The footnote attributing "necessity is the mother of invention" to Plato is not a direct quotation. |
| Appendix | The MIMIC-III citation is the wrong paper. The correct reference is [Johnson et al., 2016](https://doi.org/10.1038/sdata.2016.35). MIMIC-III's 53,423 refers to hospital admissions, not ICU stays. |
| Appendix | PTB-XL version 1.0.3 has 21,799 records from 18,869 patients. |
| Appendix | `new-col`, `mean-val` and `test-data` should use underscores. `ROCR::performance()` needs a `prediction()` object. |
| Appendix | The glossary points to a "Recurrent Neural Network" entry that does not exist. |
| Several | Markers such as `[^11]` printed in the text are unresolved footnotes and can be ignored. |
| Bibliography | The Breiman (2001) reference has no title. It is "Random Forests." |

## Using the snippets

Some Chapter 2 snippets use columns that the `patient_df` example does not have, such as `cholesterol` and `sbp`. The book treats these as placeholders for your own data.

The Keras snippet in Chapter 6 has not been tested. It needs a working TensorFlow install, and `keras3` is now the current R package.

Found something else? Please open an issue.
