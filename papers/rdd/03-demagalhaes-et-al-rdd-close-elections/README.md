# When Can We Trust RDD Estimates from Close Elections?

*Paper 03 — Regression Discontinuity Design*

## 1. Citation

De Magalhães, L., Hangartner, D., Hirvonen, S., Meriläinen, J., Ruiz, N. A., & Tukiainen, J. (2025). *When Can We Trust Regression Discontinuity Design Estimates from Close Elections? Evidence from Experimental Benchmarks*.

- Search / working-paper link: [Google Scholar](https://scholar.google.com/scholar?q=De+Magalh%C3%A3es+Hangartner+Hirvonen+Meril%C3%A4inen+Ruiz+Tukiainen+RDD+close+elections+experimental+benchmarks)
- A stable DOI or publisher URL was not available at the time of writing; see [`references.md`](references.md) for adjacent reading and update both files once a DOI is published.

## 2. TL;DR

Regression discontinuity designs (RDDs) around close-election thresholds are the workhorse of incumbency-effect research. But which flavor of RDD estimator should you believe? The literature offers a menu: different polynomial orders, different bandwidth selectors, different inference methods. De Magalhães et al. do something practically rare — they **validate each choice against a real experimental benchmark**: local elections in Colombia and Finland where exact ties are broken by a lottery. That lottery gives them the "truth" for the treatment effect in a close-elections RDD. They then compare estimators against that truth. The headline: when the conditional expectation function is roughly linear near the cutoff, all reasonable estimators agree. When there's visible non-linearity, **CER-optimal bandwidths with bias-corrected robust inference** give the most reliable coverage. That is what you should use as your default.

## 3. Why this paper matters

Most methodological RDD guidance comes from simulations or theoretical optimality results. Simulations let you control the DGP, so you can always build a world where your favorite estimator wins. Theory gives you asymptotic properties that may or may not bite at realistic sample sizes. **What's missing is a field test against a known-truth benchmark.**

Elections where candidates tie exactly, with the tie broken by a random lottery, give exactly that: a natural experiment embedded inside the standard RDD setup. The lottery-resolved sample lets you estimate the true incumbency effect at the threshold without relying on any RDD assumption — you just run a simple comparison of lottery winners and losers. The paper then asks: which RDD specification, applied to the full close-election sample, gets closest to that truth?

This matters because empirical researchers face real choices — p = 1 vs p = 2; MSE-optimal vs CER-optimal; conventional vs robust inference — and those choices can flip a "significant incumbency advantage" to "null result". A validation against experimental benchmarks grounds the choice in real data, not simulation.

## 4. The causal question

You have a cutoff rule: some candidates win elections (treatment) and some lose (control) based on their vote share at a threshold (typically 50% in two-candidate races, or 0% margin-of-victory). You want the **effect of winning on some outcome** (e.g., incumbency advantage in the next election, policy outcomes, career trajectories).

The RDD idea: near the cutoff, close winners and close losers are "almost the same" — they only differ in having been just above or just below the threshold. If other potential confounders change smoothly across the threshold, the jump in outcomes at the threshold is the causal effect.

The methodological question here: **which RDD estimator recovers that causal effect most reliably in realistic data?** And: **what does "reliably" even mean — bias, variance, coverage of confidence intervals, or all three?**

## 5. Glossary

- **Running variable `X`** — the variable on which the cutoff is defined. In close-election RDDs, usually the margin of victory.
- **Cutoff `c`** — the value of the running variable at which treatment flips. Often 0 (margin of victory = 0, i.e., a tied election).
- **Sharp RDD** — treatment is fully determined by whether `X ≥ c`. Winning an election fits this.
- **Conditional expectation function (CEF)** — `E[Y | X]`. The average outcome at each value of the running variable.
- **Local polynomial** — a polynomial of order `p` fit on observations within a bandwidth `h` of the cutoff, separately on each side. Standard local-linear uses `p = 1`.
- **Bandwidth `h`** — the half-width of the window used in the local polynomial regression. Narrower → less bias, more variance; wider → more bias, less variance.
- **MSE-optimal bandwidth (`mserd`)** — the bandwidth that minimizes the asymptotic mean-squared error of the point estimator. This is the classic Calonico-Cattaneo-Titiunik (CCT) default.
- **CER-optimal bandwidth (`cerrd`)** — the bandwidth that minimizes the *coverage error rate* of the confidence interval. Tends to be narrower than MSE-optimal because it trades variance for reduced bias, which is what matters for coverage.
- **Conventional inference** — the standard confidence interval from the local polynomial, treating the bias as negligible.
- **Bias-corrected (BC) inference** — subtract an estimate of the leading bias from the point estimate; useful when the bias isn't negligible at the chosen bandwidth.
- **Robust inference** — bias-corrected point estimate *plus* a variance adjusted for the extra uncertainty introduced by the bias correction. The CCT-recommended default for valid coverage.
- **Coverage** — the empirical frequency with which a 95% confidence interval contains the true parameter. Nominal coverage is 0.95.
- **McCrary test** — a test for manipulation of the running variable around the cutoff by comparing densities on either side.

## 6. Core idea

Here is the analogy. Imagine you're measuring how much taller kids get in a year by comparing two groups: "kids who are 8 when measured" vs "kids who just turned 9". You use a ruler to line them up by age and look at the jump in height at the 9-year birthday. That jump is "causal" only if you're measuring locally enough that 8-year-olds and 9-year-olds don't differ on anything else relevant.

How close is close enough? That's the **bandwidth** choice.

- Pick a **wide window** (8-to-10-year-olds): lots of data, small variance. But now you're contaminating your estimate with the fact that older kids are also better fed, better rested, richer, etc. The estimate is **biased**.
- Pick a **narrow window** (8y 11m to 9y 1m): clean comparison, but only a handful of kids in each group — your estimate is **noisy**.

The **MSE-optimal** bandwidth says: "trade off bias and variance so that the squared-error is smallest on average." That's fine if you want a point estimate. But if you want a **confidence interval that actually covers 95% of the time**, you need to reason about *both* the variance and the bias — because the bias term pushes the center of your CI away from the truth, and ordinary SEs don't know about it.

The **CER-optimal** bandwidth says: "narrow the window a bit, accepting more variance, so that the residual bias is small enough that your CI covers the truth at the nominal rate." That's often the safer default.

And the **bias-corrected robust inference** approach does two things simultaneously: it removes the leading bias from the point estimate, and it adjusts the CI width to reflect the added uncertainty from the bias correction. Combine it with CER-optimal bandwidths and you get the paper's recommended default.

## 7. Method walkthrough

**Step 1 — Extract the experimental benchmark.**
In Colombian municipal elections and Finnish local elections, some races produce *exact* ties between candidates. Tie-breaking is by a random lottery. The subset of tied races is therefore a randomized experiment. From these races, the authors estimate the causal effect of winning — the ground truth.

**Step 2 — Define a family of RDD estimators.**
The menu:
- polynomial order `p ∈ {1, 2}`
- bandwidth selector `bw ∈ {mse, cer}` (both single- and two-sided)
- inference `∈ {conventional, bias-corrected, robust}`

Every combination is a reasonable specification a practitioner might choose. The goal is to compare them *all* against the experimental benchmark.

**Step 3 — Apply each RDD specification to the close-elections sample.**
The full close-elections sample is much larger than the tied-elections subsample and includes races with small but nonzero margins. A good RDD should recover the experimental estimand from the much bigger, non-experimental but quasi-random close-elections data.

**Step 4 — Compare estimates to the benchmark.**
The authors report bias, RMSE, coverage of 95% CIs, and CI widths across specifications.

**Key qualitative findings:**
- When the CEF `E[Y|X]` is approximately linear near the cutoff, all reasonable specifications broadly agree — bias is small and coverage is close to nominal everywhere.
- When there is visible curvature — which is the typical concern and the typical motivation for RDD methodological caution — CER-optimal bandwidths with bias-corrected robust inference deliver the best coverage, closely followed by MSE-optimal bandwidths *with* bias correction.
- Conventional (non-bias-corrected) inference can show coverage gaps, especially with MSE-optimal bandwidths, because the bias at the MSE-optimal bandwidth is (by design) not negligible relative to the SE.
- Higher-order polynomials (p = 2) further reduce bias but at the cost of wider CIs.

**Step 5 — Practical recommendation.**
Default to CER-optimal bandwidths and bias-corrected robust inference. If you need a point estimate only, MSE-optimal bandwidths are fine. In doubt, report both.

## 8. Assumptions and when they fail

Even the best-chosen RDD specification assumes:

- **Continuity of potential outcomes at the cutoff.** The conditional mean of `Y(0)` and `Y(1)` are smooth functions of `X` at `c`. Violated if agents can precisely manipulate `X` (e.g., a candidate buying votes at the margin).
- **No manipulation of the running variable.** Usually tested with a McCrary density test. If the density jumps at the cutoff, you are not in an RDD world.
- **Relevant polynomial approximation.** Local polynomials approximate the CEF well inside the bandwidth. If curvature is extreme, a linear fit in-window can be badly biased; the paper's message is to use bias correction + a narrower bandwidth.
- **Large enough sample near the cutoff.** Coverage guarantees are asymptotic. With a few hundred observations near the cutoff, sampling error dominates any bandwidth subtlety.
- **Close elections are a valid setting.** This paper's validation uses *exact tie* lotteries, which are the most aggressive form of close-election randomization. Whether the RDD extrapolation from ties to "margin of victory ≤ 1%" elections is appropriate is exactly what the paper tests; for other cutoff regimes (fuzzy RDDs, non-electoral thresholds) the validation does not directly apply.

## 9. What the authors find

- Across Colombian and Finnish data, the lottery-based benchmark estimate is well-defined and statistically distinguishable from zero (there is a real incumbency advantage).
- RDD estimates from the close-elections sample are broadly consistent with the benchmark when the CEF is roughly linear.
- When curvature is present, **CER-optimal bandwidths + bias-corrected robust inference** consistently match the benchmark most closely, with the best coverage of 95% CIs.
- **MSE-optimal bandwidth + conventional inference** — the historical default — shows coverage gaps under curvature.
- The main practical recommendation to researchers: use `rdrobust` with `bwselect = "cerrd"` and report the Robust (bias-corrected) confidence interval.

## 10. What this means for a practitioner

- **Stop defaulting to MSE-optimal + conventional CIs.** The paper doesn't claim this is catastrophically wrong, but it is measurably worse than the alternative precisely where the alternative matters most (visible curvature near the cutoff).
- **Use `rdrobust::rdrobust` with `bwselect = "cerrd"`.** Report the Robust (bias-corrected) point estimate and CI as your main result. This is what the paper's practical recommendation maps to in R.
- **Show a polynomial-order comparison.** Report `p = 1` and `p = 2` side by side. If they disagree meaningfully, that is itself diagnostic — usually of curvature the local-linear fit is missing.
- **Plot the RDD.** An `rdplot` panel with the raw scatter, the local polynomial fit, and the bandwidth window makes the underlying smoothness assumption visible in one image.
- **Be explicit about the benchmark.** If you have a natural experiment anywhere in the data (a lottery, a random audit, a pilot rollout), use it as a validity check the way this paper does. It is the only way to directly benchmark an RDD to the truth.

## 11. Runnable example

[`simulation.ipynb`](simulation.ipynb) simulates a sharp RDD with:

- running variable `X ~ Uniform(-1, 1)`, cutoff at 0;
- a conditional mean `μ(X) = 0.5 + 3X + 50X² + 80X³` — deliberately strong curvature near the cutoff so the paper's warning case is live;
- true sharp treatment effect `τ = 0.5` at the cutoff.

The notebook draws **one dataset** of `N = 2000` and fits two specifications via `rdrobust::rdrobust`:

| Spec | Bandwidth | Inference |
|------|-----------|-----------|
| `p = 1` | MSE-optimal (`mserd`) | Conventional |
| `p = 1` | CER-optimal (`cerrd`) | Robust (BC) |

Representative output (seed `20260421`):

```
specification                estimate   ci_low   ci_high   bandwidth_h   covers_truth
p=1, MSE-opt, Conventional   0.494      0.339    0.649     0.10          TRUE
p=1, CER-opt, Robust (BC)    0.477      0.296    0.659     0.07          TRUE
```

What is visible from one draw at this seed: **bandwidth choice** and **CI width**. CER-opt picks a narrower window (`h ≈ 0.07` vs `0.10`) so less of the curved cubic sits inside the local-linear fit, and the robust CI is wider to reflect the bias-correction step.

What is *not* visible from one draw: the coverage claim itself. The paper's empirical-coverage tables come from thousands of draws — under realistic curvature MSE-opt + Conventional empirically covers around 92–93% (vs. 95% nominal) and CER-opt + Robust gets close to nominal. At this seed both happen to cover; the Monte Carlo is what proves the gap. Open the notebook on Colab and bump `SIGMA`, sharpen the cubic in `mu(X)`, or shrink `N` to draws where the MSE-opt CI misses more often.

The diagnostic plot renders the raw draw with the true cubic conditional mean overlaid, the cutoff dashed, and both bandwidth windows shaded — so the narrower CER window is unmistakable.

Run it — the Colab badge at the top of the notebook launches it in a free cloud kernel (pick *Runtime → Change runtime type → R* once per session; the first setup cell runs `install.packages('rdrobust')` if the dep is missing). Locally:

```bash
jupyter nbconvert --to notebook --execute --inplace \
  papers/rdd/03-demagalhaes-et-al-rdd-close-elections/simulation.ipynb
```

Change the coefficients of `mu(x)` at the top of the notebook to soften or sharpen the curvature and see how the bias contributions move.

## 12. Further reading

1. Calonico, Cattaneo & Titiunik (2014) — robust nonparametric RDD CIs, the foundational paper for `rdrobust`.
2. Calonico, Cattaneo & Farrell (2020) — coverage-error-optimal CIs for local polynomial regression.
3. Cattaneo, Idrobo & Titiunik (2019) — the Cambridge Elements volume; the most practical textbook treatment.
4. Imbens & Lemieux (2008) — earlier practitioner guide; still useful for historical context and fuzzy RDDs.
5. Gelman & Imbens (2019) — why high-order polynomials are a trap.

See [`references.md`](references.md) for full citations.
