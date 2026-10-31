# Machine Learning in Cardiology: R code

Companion code for *Machine Learning in Cardiology: A Practical R-Based Approach* by Matthew W. Segar, MD (ISBN 979-8-9927305-0-0).

All data in the worked examples are simulated inside the scripts, so there is nothing to download. The simulations are teaching examples, and their results say nothing about real patients. None of this code is intended for clinical use.

## Getting started

You need [R](https://cran.r-project.org/) (tested on 4.5.2). Clone the repository, open R in its folder, and run:

```r
source("install.R")                                     # installs the packages
source("scripts/ch05-risk-prediction.R", echo = TRUE)   # or any chapter
```

To run every chapter from a terminal, use `Rscript run_all.R`. Logs are written to `output/`.

`renv.lock` records the exact package versions used for testing. `renv::restore()` can reproduce them, but it may compile packages from source, which requires compilers such as `gfortran`.

## What's here

`scripts/` holds the worked examples, one file per chapter, in book order and labeled by section. Each one runs from top to bottom on its own.

`snippets/` holds the shorter code excerpts from the book. **These are illustrative and are not meant to be run as a file**: most assume your own data or files. They are checked for valid R syntax, but most have not been run. The packages they use, such as `keras`, `mlr3`, `oro.dicom` and `RHRV`, are not in `install.R`, so install those separately as needed.

| Chapter | Worked examples | Snippets |
|---|---|---|
| 1. Introduction | | [ch01](snippets/ch01-intro-snippets.R) |
| 2. R Fundamentals | [ch02](scripts/ch02-r-fundamentals.R) | [ch02](snippets/ch02-r-fundamentals-snippets.R), [report](snippets/ch02-example-report.Rmd), [Git](snippets/ch02-git-workflow.sh), [Docker](snippets/ch02-Dockerfile) |
| 3. ML Foundations | [ch03](scripts/ch03-ml-foundations.R) | |
| 4. Data Wrangling | [ch04](scripts/ch04-data-wrangling.R) | [ch04](snippets/ch04-data-wrangling-snippets.R) |
| 5. Risk Prediction | [ch05](scripts/ch05-risk-prediction.R) | |
| 6. Time Series | [ch06](scripts/ch06-time-series.R) | [ch06](snippets/ch06-time-series-snippets.R) |
| 7. Survival Analysis | [ch07](scripts/ch07-survival.R) | |
| 8. Genetics | [ch08](scripts/ch08-genetics.R) | |
| 9. Bias and Fairness | [ch09](scripts/ch09-bias.R) | |

Chapters 10 and 11 contain no code.

## Differences from the printed book

The code here has been corrected where the printed version had errors or no longer runs. [ERRATA.md](ERRATA.md) lists each change, including one correction to a printed result in Chapter 7.

Text output from the scripts otherwise matches the book, apart from the random forest results in Chapter 7. Figures were not compared. With package versions different from those in `renv.lock`, numbers may shift slightly.

## License

The code in this repository is under the [MIT License](LICENSE). The text of the book is not included here and remains all rights reserved.
