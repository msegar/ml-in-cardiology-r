# Runs every chapter script in its own R process and reports pass or fail.
# Usage, from the repository root: Rscript run_all.R
scripts <- sort(list.files("scripts", pattern = "\\.R$", full.names = TRUE))
dir.create("output", showWarnings = FALSE)

status <- vapply(scripts, function(s) {
  log <- file.path("output", sub("\\.R$", ".log", basename(s)))
  system2("Rscript", shQuote(s), stdout = log, stderr = log)
}, integer(1))

print(data.frame(script = basename(scripts),
                 result = ifelse(status == 0, "ok", "FAILED"),
                 row.names = NULL))
quit(status = as.integer(any(status != 0)))
