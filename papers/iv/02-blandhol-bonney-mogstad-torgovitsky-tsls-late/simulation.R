#!/usr/bin/env Rscript
# Paper 02 — Blandhol, Bonney, Mogstad & Torgovitsky (2025),
# "When is TSLS Actually LATE?"
#
# What this simulation demonstrates:
#   In a world where the instrument Z is CONDITIONALLY random given a
#   covariate X (the setting that motivates including X in the TSLS
#   specification) and where compliance + LATEs are heterogeneous across
#   strata of X, the common empirical recipe
#       ivreg(Y ~ D + X | Z + X)
#   does NOT recover a non-negatively-weighted average of the stratum LATEs.
#   A "saturated" specification that interacts the instrument with X does.
#
# Why conditional randomization matters:
#   If Z were marginally independent of X, the unsaturated unconditional Wald
#   would already equal the population LATE and there would be no bias. The
#   Blandhol et al. critique hits the common case where Z is only valid once
#   you *condition on* X — then controlling for X linearly is not enough.
#
# DGP:
#   X ~ Bernoulli(0.5).
#   Z | X=0 ~ Bernoulli(0.15);  Z | X=1 ~ Bernoulli(0.55).
#     (Asymmetric on purpose — see note near pZ_X0, pZ_X1 below.)
#   X=0: complier share 0.20, stratum LATE = 3.0 (big effect, few compliers)
#   X=1: complier share 0.60, stratum LATE = 0.0 (no effect, many compliers)
#   Target estimand: population LATE, weighting stratum LATEs by their
#     complier mass = 0.75.
#
# MIT license. Repo: papers_explainer.

# Resolve the script's own directory so `source()` and `figures/` work whether
# this script is invoked from the repo root or from its own folder.
.args <- commandArgs(trailingOnly = FALSE)
.file <- .args[grepl("^--file=", .args)]
if (length(.file) > 0) setwd(dirname(sub("^--file=", "", .file[1])))

source("../../../shared/r-setup.R")

# -------- Parameters -------------------------------------------------------
N_SIM <- 500
N     <- 5000

# Compliance-type mix (always-taker, never-taker, complier), no defiers.
probs_X0 <- c(always = 0.10, never = 0.70, complier = 0.20)
probs_X1 <- c(always = 0.10, never = 0.30, complier = 0.60)

# P(Z=1 | X). Breaks marginal independence of Z and X; Z is valid ONLY
# conditional on X. These are deliberately asymmetric — if we picked
# (0.3, 0.7), the two strata would have identical Var(Z|X) by the
# p*(1-p) symmetry, and unsaturated TSLS would coincidentally recover
# the true LATE. The Blandhol et al. critique is about the WEIGHTS
# TSLS uses — we want those weights to be visibly wrong.
pZ_X0 <- 0.15
pZ_X1 <- 0.55

# Stratum-specific constant treatment effects. Deliberately different
# so the TSLS vs LATE gap is easy to see.
tau_X0 <- 3.0
tau_X1 <- 0.0

# Population LATE target, weighting by complier MASS:
#   mass_X0 = P(X=0) * complier share X=0 = 0.5 * 0.20 = 0.10
#   mass_X1 = P(X=1) * complier share X=1 = 0.5 * 0.60 = 0.30
true_LATE <- (0.10 * tau_X0 + 0.30 * tau_X1) / (0.10 + 0.30)  # = 0.75
# ---------------------------------------------------------------------------

run_once <- function() {
  X <- rbinom(N, 1, 0.5)
  # Z is conditionally random GIVEN X, not marginally random
  Z <- rbinom(N, 1, ifelse(X == 0, pZ_X0, pZ_X1))

  # Compliance type per unit
  type <- character(N)
  type[X == 0] <- sample(c("always", "never", "complier"),
                         sum(X == 0), replace = TRUE, prob = probs_X0)
  type[X == 1] <- sample(c("always", "never", "complier"),
                         sum(X == 1), replace = TRUE, prob = probs_X1)

  # D from (type, Z)
  D <- as.integer(
    type == "always" |
    (type == "complier" & Z == 1)
  )

  # Potential outcomes
  eps <- rnorm(N, 0, 1)
  tau <- ifelse(X == 0, tau_X0, tau_X1)
  Y   <- ifelse(D == 1, tau + eps, eps)

  df <- tibble(Y = Y, D = D, Z = Z, X = X)

  # ---- Estimator 1: unsaturated TSLS ---------------------------------------
  fit_unsat <- AER::ivreg(Y ~ D + X | Z + X, data = df)
  est_unsat <- unname(coef(fit_unsat)["D"])

  # ---- Estimator 2: stratum-wise Wald, pooled by complier mass -------------
  wald <- function(sub) {
    num <- mean(sub$Y[sub$Z == 1]) - mean(sub$Y[sub$Z == 0])
    den <- mean(sub$D[sub$Z == 1]) - mean(sub$D[sub$Z == 0])
    c(num = num, den = den, wald = num / den, size = nrow(sub))
  }
  w0 <- wald(dplyr::filter(df, X == 0))
  w1 <- wald(dplyr::filter(df, X == 1))
  mass0   <- (w0["size"] / N) * w0["den"]   # estimated complier mass in X=0
  mass1   <- (w1["size"] / N) * w1["den"]   # estimated complier mass in X=1
  est_sat <- unname((mass0 * w0["wald"] + mass1 * w1["wald"]) / (mass0 + mass1))

  # ---- Estimator 3: full-interaction TSLS, aggregated by COMPLIER mass -----
  # Y ~ D + X + D:X | Z + X + Z:X saturates the first stage. Note: the
  # complier-mass WEIGHTS (mass0, mass1) here come from the stratum Wald
  # first stage above, not from fit_int. This mix-and-match is an approximation
  # that works cleanly because X is binary and N is large. For continuous or
  # high-dimensional X, the "canonical" saturated IV is Estimator 2 (stratum
  # Wald pooled) or a target-parameter approach (UJIVE / MTW 2021) — not this
  # one-liner. See README section 10.
  df2 <- df |> mutate(DX = D * X, ZX = Z * X)
  fit_int  <- AER::ivreg(Y ~ D + X + DX | Z + X + ZX, data = df2)
  tau0_hat <- unname(coef(fit_int)["D"])                        # stratum X=0 LATE hat
  tau1_hat <- unname(coef(fit_int)["D"] + coef(fit_int)["DX"])  # stratum X=1 LATE hat
  est_full <- unname((mass0 * tau0_hat + mass1 * tau1_hat) / (mass0 + mass1))

  c(
    unsat    = est_unsat,
    sat_wald = est_sat,
    full_int = est_full,
    wald_X0  = unname(w0["wald"]),
    wald_X1  = unname(w1["wald"])
  )
}

# -------- Monte Carlo ------------------------------------------------------
cat("Running ", N_SIM, " Monte Carlo draws (N = ", N, ") ... ", sep = "")
results <- replicate(N_SIM, run_once())
cat("done.\n\n")

mean_by_row <- function(m) apply(m, 1, mean)
sd_by_row   <- function(m) apply(m, 1, sd)

summary_tbl <- tibble(
  estimator        = c("Unsaturated TSLS (Y ~ D + X | Z + X)",
                       "Saturated: stratum Wald, pooled by complier mass",
                       "Saturated: full interaction TSLS, pooled",
                       "Stratum Wald at X=0 only",
                       "Stratum Wald at X=1 only"),
  truth            = c(true_LATE, true_LATE, true_LATE, tau_X0, tau_X1),
  mean_estimate    = mean_by_row(results),
  mean_bias        = mean_by_row(results) - c(true_LATE, true_LATE, true_LATE, tau_X0, tau_X1),
  mc_sd            = sd_by_row(results)
)

cat("Monte Carlo summary:\n")
print(summary_tbl, n = Inf)
cat("\n")

# -------- Diagnostic plot --------------------------------------------------
plot_df <- tibble(
  estimate = c(results["unsat", ], results["sat_wald", ], results["full_int", ]),
  estimator = factor(
    rep(c("Unsaturated TSLS",
          "Saturated: stratum Wald pooled",
          "Saturated: full interaction"),
        each = N_SIM),
    levels = c("Unsaturated TSLS",
               "Saturated: stratum Wald pooled",
               "Saturated: full interaction")
  )
)

p <- ggplot(plot_df, aes(x = estimate, fill = estimator)) +
  geom_histogram(bins = 40, colour = "white") +
  geom_vline(xintercept = true_LATE, linetype = "dashed", linewidth = 0.9) +
  geom_vline(xintercept = tau_X0, linetype = "dotted", colour = "grey40") +
  geom_vline(xintercept = tau_X1, linetype = "dotted", colour = "grey40") +
  annotate("text", x = true_LATE, y = Inf, label = "  True pop LATE",
           hjust = 0, vjust = 1.3, size = 3.5) +
  annotate("text", x = tau_X0, y = Inf, label = "  LATE(X=0)",
           hjust = 0, vjust = 3.0, size = 3, colour = "grey40") +
  annotate("text", x = tau_X1, y = Inf, label = "  LATE(X=1)",
           hjust = 0, vjust = 3.0, size = 3, colour = "grey40") +
  facet_wrap(~ estimator, ncol = 1, scales = "free_y") +
  labs(
    title = "Under conditional randomization of Z, unsaturated TSLS misses the LATE",
    subtitle = paste0(N_SIM, " Monte Carlo draws, N = ", N, " per draw. Dashed = true LATE."),
    x = "Estimate", y = "Count"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "none")

dir.create("figures", showWarnings = FALSE)
ggsave("figures/tsls-vs-late.png", p, width = 8, height = 7, dpi = 150)
cat("Saved figures/tsls-vs-late.png\n\n")

# -------- Final commentary -------------------------------------------------
cat(strrep("-", 70), "\n", sep = "")
cat("Punchline:\n")
cat("  True pop LATE =", fmt(true_LATE), "\n")
cat("  Unsaturated TSLS mean         =", fmt(mean(results['unsat', ])),
    " (bias =", fmt(mean(results['unsat', ]) - true_LATE), ")\n")
cat("  Saturated (stratum Wald pooled) =", fmt(mean(results['sat_wald', ])),
    " (bias =", fmt(mean(results['sat_wald', ]) - true_LATE), ")\n")
cat("  Saturated (full interaction TSLS) =", fmt(mean(results['full_int', ])),
    " (bias =", fmt(mean(results['full_int', ]) - true_LATE), ")\n\n")
cat("When the instrument is only valid CONDITIONAL on X, you cannot\n")
cat("recover the LATE by adding X as a linear control in the TSLS.\n")
cat("The first stage must be saturated: interact Z with X (and D with X\n")
cat("in the structural equation) so every X stratum gets its own Wald\n")
cat("estimate, which you then aggregate by complier mass.\n")
cat(strrep("-", 70), "\n", sep = "")
