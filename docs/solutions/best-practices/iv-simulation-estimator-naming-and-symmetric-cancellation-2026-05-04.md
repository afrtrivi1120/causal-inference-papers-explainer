---
title: "IV simulation notebooks: pin the estimator name to the estimand, and acknowledge 0/0 cancellation in symmetric DGPs"
date: 2026-05-04
category: best-practices
module: papers_explainer
problem_type: best_practice
component: development_workflow
severity: medium
applies_when:
  - Authoring a simulation notebook for an IV paper that contrasts linear IV (`ivreg(Y ~ D + X | Z + X)`) with a τ-targeting or saturated alternative (e.g. Słoczyński 2022's per-stratum Wald aggregated by `|ω̂(X)|`)
  - The DGP is fully symmetric across covariate cells in a way that makes the linear-IV reduced form and first stage cancel in expectation (equal `P(X)`, equal `Var(Z|X)`, opposite-sign conditional first stages)
  - The simulation punchline compares a "biased" linear-IV number to an "unbiased" alternative and the prose names a specific estimate value (e.g. "−0.026")
  - An IV explainer attributes a prescribed estimator (e.g. "saturate and instrument") to a named prior method (e.g. Angrist-Imbens 1995 interacted 2SLS) without verifying the weighting kernel against the paper's defining equation
tags:
  - iv
  - simulation-notebooks
  - estimand-naming
  - symmetric-dgp
  - late
  - tsls
  - weighting-kernel
  - punchline-verification
  - r-notebooks
---

# IV simulation notebooks: pin the estimator name to the estimand, and acknowledge 0/0 cancellation in symmetric DGPs

## Context

On 2026-05-04, the simulation-notebook-expert agent produced `papers/iv/sloczynski-linear-iv-late/simulation.ipynb` — a single-draw R notebook demonstrating Słoczyński's (2022) negative-weights result for noninteracted linear IV under weak monotonicity. The notebook executed clean, the diagnostic plots rendered correctly, and the truth-vs-estimate tibble printed sensible-looking numbers. A subsequent `/ce:review` pass surfaced two technically-distinct but pedagogically-related issues that both stemmed from a single instinct: the simulation-notebook-expert wanted the punchline prose to read clean, and in the process committed two soft errors that ce:review caught and auto-fixed.

**Issue 1 — sampling-noise overcommitment.** The first-pass punchline prose said *"the noninteracted estimate lands near −0.026, a gap of over one unit from the truth, even though every individual has a treatment effect of 1.0."* The DGP is fully symmetric (equal stratum sizes `P(X=0) = P(X=1) = 0.5`, equal instrument variance `Var(Z|X=x) = 0.25` in both strata, opposite-sign first stages `ω(0) = +0.5` and `ω(1) = −0.5`, identical conditional LATEs `τ(0) = τ(1) = 1.0`). Under that design the *population-level* linear-IV estimand is exactly `0 / 0` — both the numerator (`Cov(Y, Z̃)`) and the denominator (`Cov(D, Z̃)`) cancel by construction. The `−0.026` printed at `set.seed(20260421)` is one draw's sampling noise; sign and magnitude are both seed-dependent. Asserting it as a stable population property is misleading.

**Issue 2 — estimator mislabeling.** The same first-pass labeled the τ-targeting alternative as `"AI interacted Wald (pooled by |ω̂(X)|)"`. Słoczyński's paper carefully distinguishes two related-but-non-identical alternatives to noninteracted linear IV: (a) the Angrist-Imbens (1995) interacted 2SLS regression (`β_2SLS` in the paper, eq. 3) which by Theorem 3.2 weights conditional LATEs by `π(X)² · Var(Z|X)`; and (b) the τ_LATE estimator (eq. 8) defined as `E[π(X) · τ(X)] / E[π(X)]`. The notebook's per-stratum Wald aggregated by `|ω̂(x)|` computes (b), not (a). Both are positive-weighted; they are different positively-weighted aggregations of the same `τ(X)`. Calling the τ_LATE estimator "AI interacted Wald" makes the explainer technically wrong in a way that readers learning the paper's taxonomy will carry forward.

Both errors were corrected before the explainer shipped. The lesson — and the reason this doc exists — is that **the simulation-notebook-expert's pedagogical instincts (show a contrast; label the estimator) outran its technical grounding (verify the population estimand exists; verify the estimator's weight expression matches the named estimand)**. Both errors are systematic enough to recur on future IV explainers if the discipline isn't encoded.

A note on session-historian context: the original Blandhol et al. IV simulation (April 21, 2026) deliberately *broke* symmetry in its DGP — `P(Z=1|X=0) = 0.15` vs. `P(Z=1|X=1) = 0.55` — precisely so the unsaturated-TSLS bias would be visible. The Słoczyński simulation deliberately keeps the design symmetric because the *weight visualization* is the paper's signature (the negative bar on the wrong stratum). The two design choices are correct for their respective papers; what changed is that the symmetric design induces a degenerate estimand, which the prose then has to acknowledge. (session history)

## Guidance

### Rule 1 — Pin every IV estimator name to its exact weight expression

When a paper distinguishes named estimands (`β_IV`, `β_2SLS`, `β_AI`, `τ_LATE`), the simulation must label its computed estimator with the *exact* name that matches its weight expression — not the name of a merely related estimator.

**Procedure:**

1. Before writing any estimator label, read the paper's defining equations for *each* estimand you intend to compare. For Słoczyński (2022) the ledger is:
    - **Linear IV estimand `β_IV`** (eq. 2): the everyday `ivreg(Y ~ D + X | Z + X)` recipe; weights conditional LATEs proportional to `P(X=x) · ω(x) · Var(Z|X)` — sign matches `ω(x)`, can be negative.
    - **AI(1995) interacted 2SLS `β_2SLS`** (eq. 3 / Theorem 3.2): the `Y ~ D·G | Z·G` specification with full Z×covariate-stratum interactions; weights conditional LATEs by `P(X=x) · π(X)² · Var(Z|X)`, all non-negative.
    - **τ_LATE estimator** (eq. 8): defined as `E[π(X) · τ(X)] / E[π(X)]`; weights conditional LATEs by `P(X=x) · π(X)`, all non-negative. Under WM, by Lemma 2.1(ii), `π(x) = |ω(x)|`, so a per-stratum Wald pooled by `|ω̂(x)|` is this estimand.
2. Verify the weight expression your code actually computes matches the equation you cite. If you compute a Wald ratio per stratum and aggregate by `|ω̂(x)| · P(X=x)`, you are computing the τ_LATE estimator (eq. 8), *not* AI's interacted β_2SLS (eq. 3 / Theorem 3.2). Both are positively-weighted; they target different convex combinations of `τ(x)`.
3. Use the equation-derived label in every location where the estimator name appears: notebook cell-0 header, estimator-comparison markdown, result tibble, weight-plot fill labels, estimates-plot fill labels, punchline markdown, and README §11.
4. Add a clarifying parenthetical wherever the two positive-weighted alternatives could be confused: *"This is the τ_LATE estimator under WM (eq. 8 + Lemma 2.1(ii)), closely related to but distinct from AI's interacted 2SLS; per Theorem 3.2, AI's 2SLS weights conditional LATEs by π(X)² · Var(Z|X) rather than π(X)."*

### Rule 2 — In symmetric DGPs, frame the punchline around the weights, not the estimate value

A fully-symmetric DGP (equal stratum shares, equal `Var(Z|X)` across strata, opposite-sign first stages) is pedagogically clean for showing **weight sign-flipping** but mathematically degenerate for the **estimate value**: both numerator and denominator of the linear-IV ratio cancel in expectation, producing a `0/0` population estimand. Any finite-sample estimate is pure sampling noise — sign and magnitude both seed-dependent.

**Procedure:**

1. Before writing prose that asserts a specific estimate value, verify: are both `Cov(Y, Z̃)` and `Cov(D, Z̃)` non-zero in expectation under the chosen DGP? Trace it analytically — substitute the DGP parameters into the linear-IV closed form. If either is zero by construction, the point estimate is sampling noise; say so explicitly.
2. In the punchline cell and README §11, use the formulation: *"the noninteracted estimate lands near zero — in this fully-symmetric design the population-level estimand is `0/0`; the exact value and sign are sampling noise. What is robust across seeds is that the estimate collapses near zero."*
3. Still report the drawn value (it contextualizes the magnitude of noise for the reader) but immediately qualify it as sampling noise. A rendered tibble showing `−0.026` with the qualifier is honest; prose saying "a gap of over one unit from the truth" without the qualifier is not, because it implies the gap is a population property when it is not.
4. Lead with the *weight plot*, not the estimate plot. The weight plot's negative bar for the problematic stratum is determined by `ω̂(x)`, which is structurally stable in expectation across seeds. The weight plot is the claim you can safely make under a symmetric DGP. The estimate plot is illustrative, not load-bearing.
5. If the punchline fundamentally requires a stable non-zero linear-IV estimate to demonstrate the magnitude of bias (rather than just the sign-flip mechanism), introduce slight asymmetry into the DGP — different `P(X=x)` across strata, or slightly unequal `Var(Z|X)` — so the population estimand is non-zero (but still wrongly-weighted). Document the asymmetry in the DGP table at the top of the notebook so readers don't mistake it for an oversight. (This was the deliberate choice in the original Blandhol et al. IV simulation; Słoczyński's notebook keeps the design symmetric on purpose because the weights visualization is the headline.) (session history)

## Why This Matters

**Mislabeling creates the wrong conceptual map.** A reader who sees "AI interacted Wald" in the explainer associates the positive-weights property with Angrist-Imbens's interacted 2SLS specification. They carry that association to the next paper and to their own empirical work. In fact, what makes the per-stratum Wald positive-weighted is the use of `|ω̂(x)|` as the aggregation weight — that's eq. 8 (τ_LATE), not the AI interacted regression (Theorem 3.2). The two are both positive-weighted but target different weighted averages of `τ(x)`. A reader who conflates them gets confused when they read the paper itself and find two distinct alternatives. The explainer's job is to clarify, not to add a new source of confusion.

**Asserting a noisy value as stable misleads the re-running reader.** The committed `.ipynb` renders with a specific printed value — `−0.026` in the Słoczyński case. A reader who runs the notebook with a modified seed (or on a different R version where the RNG path diverges) may see `+0.031`. They will conclude one of three things: their code is wrong; the explainer is wrong; or the method is more erratic than it seemed. None is correct — the issue is that the DGP makes the estimand `0/0` and the committed draw's specific value was never a claim the explainer should have made. Qualifying the value as "sampling noise" in the same breath as printing it eliminates all three misreadings.

**The error mode is systematic, not one-off.** Both insights surfaced in the same `/ce:review` pass and were auto-applied as one batch. The simulation-notebook-expert agent produced both errors in good faith; the pedagogical instincts were sound (show a contrast, label the estimator) but the technical grounding was missing (check whether the contrast is well-defined; verify the weighting formula before naming the estimator). Without this discipline encoded, the next IV paper that contrasts a "saturate" prescription with a τ-targeting alternative will recreate the same errors. (session history: prior compound entry on punchline survivability flagged a related but distinct hazard — bad-luck draws making a stable estimand look unstable; the current case is the inverse — a structurally-undefined estimand making sampling noise look like bias.)

## When to Apply

- **Adding any new IV explainer** under `papers/iv/<slug>/` that contrasts noninteracted linear IV against a τ-targeting or saturated alternative. Before finalizing estimator labels, trace each label to its defining equation in the paper and verify the weight expressions match.
- **Single-draw notebooks where the punchline is a numerical comparison**, especially when the DGP is constructed to be symmetric or clean across strata or covariate cells. Symmetric designs are aesthetically pleasing but can degenerate the estimand to `0/0`. Verify the population-level numerator and denominator before writing prose that names a specific value.
- **Any README §11 block that reports a printed estimate** as a representative outcome and asserts it as a stable property. If the value is sampling noise, say so in the same sentence. If it is a stable population property, verify it analytically before asserting.
- **Any notebook weight-decomposition figure** that attributes weight signs to a named estimator. Confirm which paper equation the estimator comes from before writing the fill-label string.

## Examples

### Estimator naming — before and after

**Before (mislabeled):**

```r
# Estimator 2 — AI interacted Wald (pooled by |omega_hat(X)|)
```

```r
estimator = c('Noninteracted linear IV', 'AI interacted Wald (pooled by |omega_hat(X)|)')
```

```markdown
## Two estimators
2. **AI interacted Wald** — per-stratum Wald ratio, aggregated by `|ω̂(X)|`.
```

**After (correct):**

```r
# Estimator 2 — tau_LATE Wald: per-stratum Wald, aggregated by |omega_hat(x)| * P(X=x).
# This is the tau_LATE estimator (eq. 8 + Lemma 2.1(ii)), not AI's interacted 2SLS.
# AI's 2SLS (Theorem 3.2) weights by pi(X)^2 * Var(Z|X), not by pi(X).
```

```r
estimator = c(
  'Noninteracted linear IV',
  'tau_LATE Wald (per stratum, pooled by |omega_hat(X)|)'
)
```

```markdown
## Two estimators

2. **τ_LATE Wald (per stratum, pooled by `|ω̂(X)|`)** — a Wald ratio within each
   stratum, aggregated by estimated mover mass `π̂(x) = |ω̂(x)|`. By eq. 8 +
   Lemma 2.1(ii), this targets `τ_LATE` under WM. Note this is **not** the
   AI(1995) interacted 2SLS (β_2SLS): per Theorem 3.2, AI's 2SLS weights
   conditional LATEs by `π(X)² · Var(Z|X)`, not by `π(X)`. The per-stratum
   Wald is the cleaner pedagogical comparison; AI's 2SLS would also avoid
   negative weights but recover a different positively-weighted average.
```

Weight-plot fill label:

```r
# Before
'AI interacted Wald'

# After
'tau_LATE (|omega_hat(X)|-pooled)'
```

### Symmetric-DGP prose — before and after

**Before (overcommits to a noisy value):**

> The noninteracted estimate lands near −0.026, a gap of over one unit from the truth, even though every individual has a treatment effect of 1.0.

**After (acknowledges the `0/0` structure):**

> The noninteracted estimate lands **near zero**, roughly one unit away from the truth, even though every individual has a treatment effect of 1.0. The exact value (and even its sign) at this seed is sampling noise: in this fully-symmetric design — equal stratum sizes, equal `Var(Z | X)`, opposite-sign `ω(x)` — the population-level linear-IV estimand is in fact `0 / 0`, with both numerator and denominator canceling. What is robust across seeds is that the estimate *collapses near zero*; the −0.026 we report is one draw's particular noise. The τ_LATE Wald is 1.018, within rounding of the truth.

**Punchline cell — before (implies stability):**

```markdown
## Punchline

The noninteracted IV returns −0.026, more than one unit below the truth of 1.0,
because stratum X=1 enters with a negative weight that offsets stratum X=0.
The AI interacted estimator recovers 1.018, close to the truth.
```

**Punchline cell — after (explicit about noise and correct labeling):**

```markdown
## Punchline

When opposite-sign first stages force a single average slope, the noninteracted
linear IV estimate collapses **near zero**. In this fully-symmetric design the
population-level estimand is `0/0` (numerator and denominator both cancel);
the sign and magnitude of any draw are sampling noise. The *weight plot* is the
robust claim: stratum X=1's bar goes below zero under noninteracted IV — the
paper's headline result — while the τ_LATE Wald keeps both weights near 0.5.

The second plot confirms the consequence: the τ_LATE Wald estimate is near 1.0;
the noninteracted estimate is near 0. The τ_LATE Wald (eq. 8 + Lemma 2.1(ii))
is closely related to but distinct from AI's interacted 2SLS (Theorem 3.2);
AI's 2SLS weights by `π(X)² · Var(Z|X)` rather than `π(X)` and would also
avoid negative weights while targeting a different positively-weighted average.
```

## Related entries

- [`single-draw-notebook-seed-survivability-2026-04-30.md`](single-draw-notebook-seed-survivability-2026-04-30.md) — sister learning. Covers the *stochastic* failure mode (a bad-luck draw masks the paper's claim). The current doc covers the *deterministic* failure mode (the population estimand itself is `0/0` by DGP construction). The recovery moves overlap (reframe the punchline; lead with the stable claim) but the diagnoses differ — bump `N` rescues a stochastic shortfall but cannot rescue a structurally-undefined estimand.
- [`claude-md-convention-edit-must-sweep-subagent-defs-2026-04-30.md`](claude-md-convention-edit-must-sweep-subagent-defs-2026-04-30.md) — relevant if Rule 1 or Rule 2 is encoded into `CLAUDE.md` notebook conventions or `.claude/agents/simulation-notebook-expert.md`. Any update to those surfaces requires sweeping the others in the same commit.
