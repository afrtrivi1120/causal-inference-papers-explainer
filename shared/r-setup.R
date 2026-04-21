# shared/r-setup.R
# Common setup for every simulation.R in this repo.
# Loads required packages, sets a shared seed, and prints a clear
# install hint for anything missing instead of failing with a traceback.

required_pkgs <- c(
  "tidyverse",  # dplyr, ggplot2, purrr, tibble — data wrangling + plotting
  "fixest",     # feols() with fast fixed-effects estimation (DiD, panel)
  "did",        # Callaway-Sant'Anna DiD estimators
  "AER",        # ivreg() for classic TSLS
  "estimatr",   # iv_robust() and lm_robust() with HC SEs
  "rdrobust",   # Calonico-Cattaneo-Titiunik RDD with bias correction
  "rddensity",  # McCrary-style density tests for the running variable
  "ggplot2"     # explicit to keep plot code self-documenting
)

missing_pkgs <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(missing_pkgs) > 0) {
  message(
    "Missing R packages: ", paste(missing_pkgs, collapse = ", "), "\n",
    "Install with:\n",
    "  install.packages(c(", paste0('"', missing_pkgs, '"', collapse = ", "), "))\n"
  )
  stop("Install the packages above before running simulations.", call. = FALSE)
}

suppressPackageStartupMessages({
  for (p in required_pkgs) library(p, character.only = TRUE)
})

# Shared seed. Per-simulation scripts may override with set.seed(), but
# every script starts from this point of reproducibility.
set.seed(20260421)

# Small helper used across simulations.
fmt <- function(x, digits = 3) formatC(x, digits = digits, format = "f")
