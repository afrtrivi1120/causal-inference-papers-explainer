# When is TSLS Actually LATE?

*Paper 02 — Instrumental Variables / Two-Stage Least Squares*

## 1. Citation

Blandhol, C., Bonney, J., Mogstad, M., & Torgovitsky, A. (2025). *When is TSLS Actually LATE?*

- NBER working paper: <https://www.nber.org/papers/w29709>
- See [`references.md`](references.md) for adjacent reading.

## 2. TL;DR

Most applied papers using instrumental variables run a two-stage least squares (TSLS) regression that includes control variables — and then summarize the result with "this is our LATE estimate". Blandhol, Bonney, Mogstad & Torgovitsky show that **this interpretation is almost always wrong**. Unless the first stage is **saturated** (i.e., the instrument is interacted with every covariate value), the TSLS coefficient is a weighted combination of subgroup treatment effects whose weights can be negative. They survey 99 published IV papers and find only 5 used saturated specifications. The fix is simple: saturate. The discipline is the work.

## 3. Why this paper matters

Adding covariates to a TSLS regression is the default empirical move. It's in every IV paper. Practitioners add covariates when the instrument is valid only *conditional on* those covariates — a totally normal and well-motivated setup. The community has long known (Imbens-Angrist 1994) that the LATE theorem requires a *saturated* specification to hold. What Blandhol et al. did is **look at what everyone is actually doing** and show, concretely, how often the saturation condition is violated in published work. Almost always.

The consequence: a large share of the published "LATE" literature is not estimating a LATE. What it's estimating is a weighted average of subgroup effects where the weights come from OLS projection mechanics, not from a causal interpretation, and where some weights can be negative. The same paper can make a more or less honest claim, and the statistical machinery is identical — only the specification differs.

## 4. The causal question

You have:
- a binary or continuous treatment `D`,
- an outcome `Y`,
- an instrument `Z` that is as-if randomly assigned **conditional on** a covariate vector `X`,
- heterogeneity in how different types of people respond to both the instrument (compliance) and the treatment (effects).

You want a clean causal parameter from your TSLS regression. In particular, you'd like it to be the **LATE** — the average treatment effect among compliers, meaning the subset of people whose treatment status actually responds to the instrument.

Under what conditions does your TSLS coefficient on `D` equal a LATE (or at least a non-negatively-weighted average of LATEs)?

## 5. Glossary

- **Instrument `Z`** — a variable that affects treatment `D` but is assumed unrelated to `Y` except through `D`. The validity arguments usually have "conditional on X" attached.
- **Conditional independence of `Z` and potential outcomes** — `Z` is as-if randomly assigned *within each stratum of X*. This is weaker than marginal independence. In most applied settings it is the defensible version.
- **Treatment `D`** — binary indicator for being treated. The observed outcome is `Y = D·Y(1) + (1-D)·Y(0)`.
- **First stage** — the regression of `D` on `Z` (and covariates). The coefficient on `Z` is the "strength" of the instrument.
- **Exclusion restriction** — the instrument affects the outcome *only through* treatment. If `Z` touches `Y` through any other channel, IV breaks.
- **Complier** — a unit that would take the treatment if given `Z=1` and would not if given `Z=0`. The LATE is defined as the treatment effect for compliers.
- **Always-taker / Never-taker / Defier** — units that take treatment regardless of `Z`, refuse treatment regardless of `Z`, or do the opposite of what `Z` would suggest. Monotonicity rules out defiers.
- **Monotonicity** — the assumption that no one is a defier. Required for LATE to be well-defined.
- **LATE (local average treatment effect)** — `E[Y(1) − Y(0) | complier]`. The causal effect for the subpopulation that responds to the instrument.
- **TSLS (two-stage least squares)** — predict `D` from `Z` (and `X`), then regress `Y` on the predicted `D` (and `X`).
- **Saturated specification** — a TSLS first stage that includes the instrument interacted with every covariate value, so that within each covariate stratum the instrument has its own slope. Equivalent to running separate TSLS regressions stratum by stratum and aggregating.
- **Unsaturated specification** — TSLS with covariates included linearly (`Y ~ D + X | Z + X`), without instrument × covariate interactions. This is the common empirical practice.
- **Complier mass** — `P(X = x) × P(complier | X = x)`. The proportion of the whole population that is a complier at covariate value `x`.

## 6. Core idea

Here is the analogy. A coupon company mails a discount code `Z` to some people and not others. The company targeted the mailing by zip code (`X`): in cheap zip codes (`X=0`), 15% of addresses got the coupon; in rich zip codes (`X=1`), 55% did.

Now you want to estimate "how much does using a coupon (`D`) raise sales (`Y`)?".

- Among people in cheap zip codes, very few respond to the coupon (small complier share), but those who do are price-sensitive and buy a lot more — big per-complier effect.
- Among people in rich zip codes, many respond (large complier share), but the price was never really binding — small per-complier effect.

The **true population LATE** weights each zip code by the number of actual compliers there. But **unsaturated TSLS** weights each zip code by how variable `Z` is within it (the variance of the coupon mailing, times the compliance rate). Because the two zip codes have very different `P(Z=1|X)`, the TSLS weighting is not the same as the complier-mass weighting.

Result: the TSLS coefficient is a weighted average of the two subgroup effects — but with the wrong weights. Blandhol et al. show this formally, and further show that in richer specifications some weights can go *negative*, which destroys any convex-combination interpretation.

The fix is the saturated specification: run TSLS separately within each zip code (and aggregate), or equivalently, interact `Z` with `X` in the first stage and `D` with `X` in the structural equation. Now each subgroup's effect is estimated with its own clean Wald ratio, and you aggregate by the correct weights.

## 7. Method walkthrough

**Step 1 — State the target.** Under monotonicity and conditional `Z`-randomization, the average complier effect is
```
LATE(x) = E[Y(1) − Y(0) | complier, X = x].
```
A natural population summary is the complier-mass-weighted average of `LATE(x)` across `x`.

**Step 2 — Decompose unsaturated TSLS.** Let `Z̃ = Z − E[Z | X]` be the residualized instrument. Then the TSLS coefficient on `D` (controlling for `X` linearly) is
```
β_TSLS = Cov(Y, Z̃) / Cov(D, Z̃).
```
A Frisch-Waugh / weighted decomposition shows
```
β_TSLS = Σ_x ω(x) · LATE(x),
```
where the weight on subgroup `x` is
```
ω(x) ∝ P(X = x) · Var(Z | X = x) · first_stage(x),
```
normalized to sum to 1.

**Step 3 — Compare to the target weights.** The complier-mass weights are
```
ω*(x) ∝ P(X = x) · first_stage(x).
```
The difference is the extra `Var(Z | X = x)` factor in the TSLS weights. If `Var(Z | X)` is not constant across strata — the normal case when `Z` is only conditionally random — the TSLS weights differ from the target weights and `β_TSLS ≠ complier-mass LATE`.

**Step 4 — Saturate.** If you include `Z·1{X = x}` in the first stage and `D·1{X = x}` in the structural equation for every value of `x` (or equivalently, run separate TSLS within each stratum), then each stratum's LATE is identified by its own Wald ratio. Aggregating with the correct complier-mass weights yields the population LATE. This is the saturated specification the authors recommend.

**Step 5 — Survey.** The authors survey 99 published IV papers, classify specifications by saturation status, and find only 5 are saturated in a way that would justify a LATE interpretation without extra assumptions. They also document how often the "negative weight" problem bites in empirically realistic settings.

## 8. Assumptions and when they fail

- **Conditional random assignment of `Z`.** `Z` is as-if random within each `X` stratum. Usually the whole reason `X` is in the model. If this fails, neither saturated nor unsaturated TSLS has a causal interpretation.
- **Exclusion restriction.** `Z` affects `Y` only through `D`. Classic IV assumption — unchanged by saturation.
- **Monotonicity / no defiers.** Required for LATE to be well-defined. Also unchanged by saturation.
- **Saturation of the first stage** (the new one). Required for the TSLS coefficient to have a LATE interpretation with non-negatively-weighted stratum LATEs. Failing this is the paper's central concern.
- **Complier heterogeneity matters.** If compliers across strata have the same treatment effect (homogeneous LATE), unsaturated TSLS is fine. Heterogeneity is what makes the weights matter.
- **Non-binary covariates.** With a high-dimensional `X`, full saturation may be infeasible (not enough observations per stratum). The authors discuss partial saturation and present alternative estimators (e.g., UJIVE) that approximate the saturated target.

## 9. What the authors find

- The standard TSLS specification with covariates added linearly is generally *not* a non-negatively-weighted average of LATEs.
- Sufficient conditions for `β_TSLS` to have a LATE interpretation require either (i) saturating in `X`, or (ii) strong parametric assumptions (constant treatment effects, homogeneous compliance).
- In a sample of 99 published IV papers using TSLS with covariates, 94 use specifications that do not justify a LATE interpretation without additional assumptions.
- Practical recommendations: saturate where feasible; when not feasible, use estimators like UJIVE or report the TSLS estimand without the LATE label.

## 10. What this means for a practitioner

- **Default to saturation.** Replace `Y ~ D + X | Z + X` with a specification that interacts `Z` with every value (or cell) of `X`. In R this is `AER::ivreg(Y ~ D*X | Z*X, data = df)`.
- **Aggregate stratum LATEs by complier mass.** Per-stratum TSLS is unbiased for the per-stratum LATE. To report a single number, weight by the *estimated complier mass* in each stratum, not by `P(X = x)` alone.
- **If full saturation is infeasible** (too many covariate cells), consider UJIVE or an explicit target-parameter approach (Mogstad, Torgovitsky & Walters, 2021) rather than reporting `β_TSLS` and calling it a LATE.
- **If you must report unsaturated TSLS**, say what it is: a weighted average of subgroup effects whose weights depend on the variance of the instrument within strata and on first-stage strength, not on the distribution of compliers.

## 11. Runnable example

[`simulation.ipynb`](simulation.ipynb) simulates a population with:

- binary covariate `X`;
- conditionally-random instrument `Z`: `P(Z=1 | X=0) = 0.15`, `P(Z=1 | X=1) = 0.55`;
- binary treatment `D`, with compliance types (always/never/complier) drawn per stratum;
- stratum-specific treatment effects `LATE(X=0) = 3.0` and `LATE(X=1) = 0.0`;
- complier shares 0.20 at `X=0` and 0.60 at `X=1`;
- true population LATE (complier-mass weighted) = **0.75**.

The notebook draws **one dataset** of `N = 20000` and fits two estimators side by side:

1. **Unsaturated TSLS** — `ivreg(Y ~ D + X | Z + X)`.
2. **Saturated stratum Wald**, pooled by estimated complier mass.

Representative output (seed `20260421`):

```
True population LATE                              = 0.750
Unsaturated TSLS  (Y ~ D + X | Z + X)             = 0.504   (gap = -0.246)
Saturated stratum Wald (pooled by complier mass)  = 0.835   (gap = +0.085)
```

The unsaturated estimate sits *one third below* the true LATE — it is mixing `LATE(X=0) = 3.0` and `LATE(X=1) = 0.0` with the wrong weights. The saturated stratum-Wald sits near 0.75 (the residual gap is one-draw sampling noise). The inline ggplot2 figure makes both contrasts visible: dashed line at the true LATE, dotted lines at the two stratum LATEs.

This is one simulated draw at large `N`. The paper's bias claim is in expectation; one draw at this sample size is enough that sampling noise around each estimate is small relative to the population-level weighting bug.

Run it — the Colab badge at the top of the notebook launches it in a free cloud kernel (pick *Runtime → Change runtime type → R* once per session). Locally:

```bash
jupyter nbconvert --to notebook --execute --inplace \
  papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.ipynb
```

## 12. Further reading

1. Imbens & Angrist (1994) — the original LATE theorem.
2. Angrist & Imbens (1995) — TSLS with variable treatment intensity.
3. Słoczyński (2022) — when linear IV is and is not a LATE.
4. Kolesár (2013) — treatment-effect heterogeneity in IV.
5. Mogstad, Torgovitsky & Walters (2021) — causal interpretation of TSLS with multiple instruments.

See [`references.md`](references.md) for full citations.
