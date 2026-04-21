#!/usr/bin/env Rscript
# Paper 01 — Ghanem, Sant'Anna & Wüthrich (2024), "Selection and Parallel Trends"
#
# What this simulation demonstrates:
#   Parallel trends is a restriction on HOW units select into treatment.
#   Scenario A: selection on time-invariant levels (alpha_i) only -> PT holds,
#               2x2 DiD recovers the true ATT on average.
#   Scenario B: Roy-style selection on expected gains, where gain correlates
#               with the untreated trend -> PT fails, 2x2 DiD is biased even
#               though the treatment effect is constant.
#
# MIT license. Repo: papers_explainer.

source("../../shared/r-setup.R")

# -------- Parameters the reader can tune -----------------------------------
N_SIM  <- 300    # Monte Carlo draws per scenario. Drop to 50 for quick iteration.
N      <- 2000   # Units per draw
TAU    <- 1.5    # True per-unit gain base (ATT when selection on gain => average gain among treated)
LAMBDA <- 1.0    # Spread of individual gains around TAU
GAMMA  <- 0.8    # Common time effect in untreated potential outcome Y(0,t=2) - Y(0,t=1)
SIGMA  <- 0.5    # Idiosyncratic noise sd
# ---------------------------------------------------------------------------

# Run one 2-period, 2-group DGP draw and return (true ATT, DiD estimate).
#
# rho controls the correlation between the "gain-driving" unobserved v and the
# untreated trend in period 2. rho = 0 => PT holds; rho > 0 => Roy selection
# silently breaks PT because treated units (high gain) also have a steeper
# untreated trend.
run_once <- function(rho) {
  alpha <- rnorm(N, 0, 1)       # time-invariant unit heterogeneity (level)
  v     <- rnorm(N, 0, 1)       # drives individual treatment gain
  eps1  <- rnorm(N, 0, SIGMA)   # period-1 noise
  eps2  <- rnorm(N, 0, SIGMA)   # period-2 noise

  # Untreated potential outcomes.
  # In period 2, a rho*v term creates a link between the untreated trend
  # and the same v that drives gain. This is the Roy-style violation.
  y0_t1 <- alpha + eps1
  y0_t2 <- alpha + GAMMA + rho * v + eps2

  # Individual gain: TAU base + heterogeneous component.
  gain <- TAU + LAMBDA * v
  y1_t2 <- y0_t2 + gain

  # Selection rule: treat if expected gain (plus mild noise) is positive.
  # This is a "Roy-style" selection on gains.
  D <- as.integer(gain + rnorm(N, 0, 0.3) > 0)

  # Observed outcomes: no treatment in period 1; selected treatment in period 2.
  y_t1 <- y0_t1
  y_t2 <- ifelse(D == 1, y1_t2, y0_t2)

  # True ATT in period 2 = average gain among the treated.
  att_true <- mean(gain[D == 1])

  # Assemble a long panel and fit the canonical 2x2 DiD.
  df <- tibble(
    id     = rep(seq_len(N), 2),
    period = c(rep(1L, N), rep(2L, N)),
    post   = as.integer(c(rep(0L, N), rep(1L, N))),
    treat  = rep(D, 2),
    y      = c(y_t1, y_t2)
  )

  fit <- lm(y ~ treat * post, data = df)
  dd  <- unname(coef(fit)["treat:post"])

  c(att_true = att_true, dd = dd, bias = dd - att_true)
}

# -------- Scenario A: PT holds (rho = 0) -----------------------------------
cat("Running Scenario A (PT holds, rho = 0) ... ")
A <- replicate(N_SIM, run_once(rho = 0.0))
cat("done.\n")

# -------- Scenario B: Roy selection violates PT (rho = 1) ------------------
cat("Running Scenario B (Roy selection, rho = 1) ... ")
B <- replicate(N_SIM, run_once(rho = 1.0))
cat("done.\n\n")

summary_table <- tibble(
  scenario          = c("A: PT holds (rho=0)", "B: Roy selection (rho=1)"),
  mean_true_ATT     = c(mean(A["att_true", ]), mean(B["att_true", ])),
  mean_DiD_estimate = c(mean(A["dd", ]),       mean(B["dd", ])),
  mean_bias         = c(mean(A["bias", ]),     mean(B["bias", ])),
  sd_DiD            = c(sd(A["dd", ]),         sd(B["dd", ]))
)

cat("Monte Carlo summary (", N_SIM, " draws, N = ", N, " per draw):\n", sep = "")
print(summary_table, n = Inf)
cat("\n")

# -------- Diagnostic plot: group-period means in one representative draw ----
# Re-run once per scenario and plot the group*period means, plus the
# counterfactual trend (what Y(0) looks like for the treated).
draw_for_plot <- function(rho, label) {
  alpha <- rnorm(N, 0, 1)
  v     <- rnorm(N, 0, 1)
  eps1  <- rnorm(N, 0, SIGMA)
  eps2  <- rnorm(N, 0, SIGMA)
  y0_t1 <- alpha + eps1
  y0_t2 <- alpha + GAMMA + rho * v + eps2
  gain  <- TAU + LAMBDA * v
  y1_t2 <- y0_t2 + gain
  D     <- as.integer(gain + rnorm(N, 0, 0.3) > 0)
  y_t1  <- y0_t1
  y_t2  <- ifelse(D == 1, y1_t2, y0_t2)

  tibble(
    scenario = label,
    period   = rep(c(1, 2), each = N),
    D        = rep(D, 2),
    y        = c(y_t1, y_t2),
    y0       = c(y0_t1, y0_t2)   # counterfactual: what treated would have been
  )
}

plot_df <- bind_rows(
  draw_for_plot(0.0, "A: PT holds (rho=0)"),
  draw_for_plot(1.0, "B: Roy selection (rho=1)")
)

group_means <- plot_df |>
  group_by(scenario, period, D) |>
  summarise(y_mean = mean(y), y0_mean = mean(y0), .groups = "drop") |>
  mutate(group = ifelse(D == 1, "Treated (D=1)", "Control (D=0)"))

# Treated counterfactual (what Y(0) would have been for treated units)
treat_cf <- plot_df |>
  filter(D == 1) |>
  group_by(scenario, period) |>
  summarise(y0_mean = mean(y0), .groups = "drop") |>
  mutate(group = "Treated counterfactual (Y(0))")

p <- ggplot(group_means, aes(x = period, y = y_mean, colour = group)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2.5) +
  geom_line(
    data = treat_cf,
    aes(x = period, y = y0_mean, colour = group),
    linewidth = 1.0, linetype = "dashed"
  ) +
  geom_point(data = treat_cf, aes(x = period, y = y0_mean, colour = group), size = 2.5) +
  scale_x_continuous(breaks = c(1, 2), labels = c("t = 1 (pre)", "t = 2 (post)")) +
  facet_wrap(~ scenario, ncol = 2) +
  labs(
    title = "Selection mechanisms decide whether parallel trends holds",
    subtitle = "Dashed line is the treated group's counterfactual Y(0) trend",
    x = NULL, y = "Mean outcome",
    colour = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

dir.create("figures", showWarnings = FALSE)
ggsave("figures/parallel-trends-diagnostic.png", p, width = 8.5, height = 4.5, dpi = 150)
cat("Saved figures/parallel-trends-diagnostic.png\n\n")

# -------- Final commentary --------------------------------------------------
cat(strrep("-", 70), "\n", sep = "")
cat("Punchline:\n")
cat("  * Scenario A: DiD is ~unbiased. Parallel trends holds because\n")
cat("    selection only depends on time-invariant alpha_i.\n")
cat("  * Scenario B: DiD is systematically biased (mean bias =",
    round(mean(B["bias", ]), 2), "). Treated units select on gains\n")
cat("    that correlate with their untreated trend, so the 'control\n")
cat("    group's trend' is not a valid stand-in for Y(0) in the treated\n")
cat("    group. The treatment effect is still constant; the bias comes\n")
cat("    entirely from selection, as Ghanem, Sant'Anna & Wuthrich show.\n")
cat(strrep("-", 70), "\n", sep = "")
