# shared/r-setup.R
# Common setup for every simulation.R in this repo.
# Loads required packages, sets a shared seed, and prints a clear
# install hint for anything missing instead of failing with a traceback.

required_pkgs <- c(
  "tidyverse",  # dplyr, ggplot2, purrr, tibble — data wrangling + plotting
  "AER",        # ivreg() for classic TSLS (paper 02)
  "rdrobust",   # Calonico-Cattaneo-Titiunik RDD with bias correction (paper 03)
  "ggplot2"     # explicit to keep plot code self-documenting
)
# Additional packages that a future paper may need (add to the vector above
# when it is actually used by a simulation, not before):
#   fixest    — feols() for fast fixed-effects estimation (DiD, panel)
#   did       — Callaway-Sant'Anna DiD estimators
#   estimatr  — iv_robust() / lm_robust() with HC SEs
#   rddensity — McCrary-style density tests for the running variable

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
