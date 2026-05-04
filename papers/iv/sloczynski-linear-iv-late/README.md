# When Should We (Not) Interpret Linear IV Estimands as LATE?

*Instrumental Variables / Two-Stage Least Squares*

## 1. Citation

Słoczyński, T. (2022). *When Should We (Not) Interpret Linear IV Estimands as LATE?* arXiv:2011.06695 (this version v8, April 2026; forthcoming in *Quantitative Economics*).

- [arXiv](https://arxiv.org/abs/2011.06695)
- See [`references.md`](references.md) for adjacent reading.

## 2. TL;DR

When researchers run an IV regression that includes control variables — the everyday `Y ~ D + X | Z + X` recipe — they typically report one number and call it "our LATE estimate". Słoczyński shows that this label can be badly wrong, for a specific and diagnosable reason: the standard regression assumes the instrument pushes everyone in the same direction, but if some subgroups are pushed up and others are pushed down, the resulting coefficient can place **negative weight** on some subgroups' effects. An average that goes negative on some terms is not really an average at all — it can end up with the opposite sign of every individual treatment effect in the population. The fix that survives this problem — Angrist and Imbens's interacted specification — does guarantee a genuine average, but it is still not the LATE most readers have in mind; recovering that requires a further re-weighting step. A survey of nearly a thousand published IV regressions finds the problematic regime applies in more than 70% of cases.

## 3. Why this paper matters

The everyday IV recipe — `Y ~ D + X | Z + X`, instrument plus covariates added linearly — is reported in thousands of empirical papers as "our LATE estimate". Słoczyński shows that this label requires a quietly strong assumption: **strong monotonicity** (SM), i.e. the instrument's first-stage effect on treatment must have the *same sign* at every covariate value. Under the genuinely weaker version, **weak monotonicity** (WM) — where some subgroups have positive first stages and others have negative ones — the linear-IV estimand can place **negative weights** on conditional LATEs and is no longer interpretable as a causal summary. The headline empirical result: in a survey of 988 IV regressions from 25 papers in journals of the American Economic Association (2006–2015), Słoczyński rejects the null of first-stage homogeneity — the empirical fingerprint of SM — in **more than 70% of specifications**. The paper rehabilitates Angrist & Imbens's (1995) interacted 2SLS specification, which delivers a positively-weighted average of conditional LATEs even under WM, and ships a companion `fejiv` package for estimating it consistently when many strata trigger many-instrument bias.

This is the complement to Blandhol et al. (2025): both papers say "linear IV with covariates is not what you think it is", but they target different sources of trouble. Blandhol et al. focus on misspecification of the implicit propensity score (saturation of `Z` in `X`); Słoczyński focuses on misspecification of the conditional first stage (homogeneity of the slope `ω(X)`). The two diagnoses overlap but are not identical.

## 4. The causal question

You have a binary treatment `D`, an outcome `Y`, and an instrument `Z` that shifts treatment take-up — but only after you condition on some covariates `X`. Different covariate groups may respond to the instrument in different directions: in some subgroups a higher `Z` raises the probability of treatment; in others it may lower it.

You run the standard IV regression — treatment, outcome, and covariates in a single equation — and get one coefficient. The question is: **what does that coefficient actually measure?**

Specifically:
- Is it a weighted average of the true treatment effects for each subgroup?
- If so, are all those weights non-negative — meaning the coefficient at least points in the right direction?
- And if the weights are non-negative, do they match the weights needed to recover the LATE — the average treatment effect for the people whose treatment status actually responds to the instrument?

Słoczyński answers: under the standard recipe, the first two conditions can both fail when the instrument pushes different subgroups in opposite directions. Under a corrected interacted specification, the first two conditions hold — but the third does not, because the interacted estimand still uses different weights than the ones that define the LATE.

## 5. Glossary

- **Treatment `D`** — binary indicator with potential treatment states `D(1)` and `D(0)` under instrument values `Z=1` and `Z=0`. Observed treatment is `D = D(Z)`.
- **Outcome `Y`** — observed outcome; `Y(1)` and `Y(0)` are potential outcomes. The structural single-equation model `Y = Dβ + Xρ + υ` (eq. 1) is **allowed to be misspecified**; the paper studies the probability limit of the IV / 2SLS coefficient under that possible misspecification.
- **Instrument `Z`** — binary instrument valid only after conditioning on covariates `X`.
- **Covariates `X`** — row vector `(1, X_1, …, X_J)`, typically discrete or discretized into `K` strata. When `X` is fully discretized, group membership `G ∈ {1, …, K}` indexes strata.
- **Linear IV estimand (`β_IV`)** — probability limit of the noninteracted IV regression `Y ~ D + X | Z + X` (eq. 2 of the paper). Reduced-form and first-stage projections of `Y` and `D` on `(Z, X)` exclude `Z·X` interactions. The paper also calls this the "usual" or "standard" specification.
- **2SLS estimand (`β_2SLS`)** — probability limit of two-stage least squares using the **interacted instrument vector** `Z_C = (Z, ZG_1, …, ZG_{K−1})` along with `X = (1, G_1, …, G_{K−1})` (eq. 3 of the paper). This is Angrist & Imbens's (1995) interacted specification. In Słoczyński's terminology, "2SLS" is reserved for *this* fully-interacted estimand; the noninteracted recipe is "linear IV" even though most software still labels it 2SLS.
- **AI interacted specification** — synonym for the 2SLS estimand above. Includes a complete set of `Z × G_k` interactions.
- **Conditional first stage** — the function `E[D | X, Z] = ψ(X) + ω(X)·Z` (eq. 4). The map `ω(x)` (eq. 5) is the conditional first-stage slope coefficient.
- **First-stage homogeneity restriction** — the noninteracted linear IV imposes `ω(X) = ω` constant. This is the "implicit homogeneity restriction on the effects of the instrument" the abstract refers to.
- **Conditional Wald (`β(x)`)** — the conditional IV / Wald estimand at `X = x`, eq. 6: ratio of the conditional reduced form to the conditional first stage at stratum `x`.
- **Conditional LATE (`τ(x)`)** — `τ(x) = E[Y(1) − Y(0) | D(1) ≠ D(0), X = x]` (eq. 9). The average treatment effect at stratum `x` for individuals whose treatment status responds to the instrument (compliers and, when WM is invoked, defiers).
- **Conditional proportion of movers (`π(x)`)** — `π(x) = P[D(1) ≠ D(0) | X = x]` (eq. 10). The mass of compliers and/or defiers in stratum `x`. The "desired" weights for `τ_LATE` (eq. 8) put `π(x)` on each conditional LATE.
- **Population LATE (`τ_LATE`)** — `τ_LATE = E[π(X) · τ(X)] / E[π(X)]` (eq. 8). The complier-mass-weighted average of conditional LATEs. Following Kolesár (2013), Słoczyński defines this on the union of compliers and defiers, so the parameter remains well-defined even when SM fails.
- **Compliance types** — always-takers (`D(1) = D(0) = 1`), never-takers (`D(1) = D(0) = 0`), compliers (`D(1) = 1, D(0) = 0`), defiers (`D(1) = 0, D(0) = 1`).
- **Strong monotonicity (Assumption SM)** — `P[D(1) ≥ D(0) | X] = 1` almost surely. The instrument has a non-negative effect on treatment uptake at *every* covariate value. Equivalent to ruling out defiers everywhere; due to Abadie (2003).
- **Weak monotonicity (Assumption WM)** — there exists a subset of the support of `X` on which `P[D(1) ≥ D(0) | X] = 1` and on its complement `P[D(1) ≤ D(0) | X] = 1`. Different subgroups may have first stages of opposite signs, but each subgroup is internally monotone (no within-stratum mix of compliers and defiers). SM ⇒ WM, but not the reverse.
- **Conditional independence (Assumption IV(i))** — `(Y(0,0), Y(0,1), Y(1,0), Y(1,1), D(0), D(1)) ⊥ Z | X`. The instrument is as-good-as-random within strata.
- **Exclusion restriction (Assumption IV(ii))** — `P[Y(1, d) = Y(0, d) | X] = 1` for `d ∈ {0, 1}`. The instrument affects outcomes only through treatment.
- **Relevance (Assumption IV(iii))** — `0 < P[Z = 1 | X] < 1` and `P[D(1) = 1 | X] ≠ P[D(0) = 1 | X]`, both almost surely. The instrument has variation and a non-zero conditional first stage.
- **Sign function `c(x)`** — `c(x) = sgn(P[D(1) ≥ D(0) | X = x] − P[D(1) ≤ D(0) | X = x])` (eq. 11). Equals `+1` on the complier region (compliers and possibly always/never-takers, no defiers), `−1` on the defier region (defiers and possibly always/never-takers, no compliers).
- **`σ²(X)`** — `σ²(X) = Var(E[D | X, Z] | X) = E[(E[D|X,Z] − E[D|X])² | X]`. The conditional variance of the first-stage prediction. Słoczyński proves (Theorem 3.2) that under WM, `σ²(X) = π(X)² · Var(Z | X)`.
- **FEJIV** — fixed-effect jackknife IV estimator of Chao, Swanson & Woutersen (2023). Used to estimate the AI interacted specification consistently when the number of interacted instruments is large and 2SLS suffers many-instrument bias (Bekker 1994).
- **`fejiv` package** — companion software (CRAN, SSC for Stata, MATLAB File Exchange) implementing FEJIV for the AI specification.
- **Mikusheva–Sun (2022) pretest** — a pretest for weak identification with many instruments, used in the paper's simulation study and pretrial-detention application to verify that the interacted instruments are jointly strong enough.
- **Negative weights problem** — the paper's headline pathology: under IV + WM (but not SM), the noninteracted linear IV estimand is a weighted average of conditional LATEs with weights that can be negative on subgroups where the conditional first stage flips sign. The estimand can then take the opposite sign of every individual treatment effect in the population.

## 6. Core idea

The paper's clearest illustration comes from air pollution research (Deryugina et al. 2019, discussed on pp. 7–8 of the paper). The instrument is wind direction on a given day. In San Francisco, an east wind blows pollution *in* from inland sources — so easterly wind raises local pollution. In Boston, an east wind blows pollution *out* to sea — so easterly wind lowers local pollution. Both cities respond to wind direction, but in opposite directions.

Now imagine someone runs a single national IV regression using wind direction as the instrument and ignores the city-level sign difference. The regression imposes one average relationship between wind direction and pollution, but that average is mixing a positive relationship (San Francisco) and a negative relationship (Boston). When you force a single coefficient to cover both, you implicitly end up putting **negative weight** on one city's contribution. The resulting estimate could tell you that more pollution increases life expectancy, not because that is true anywhere, but because the averaging went wrong.

This is exactly what Słoczyński proves happens to a standard IV regression when the instrument's effect on treatment runs in different directions across subgroups. The regression imposes a single first-stage slope across all subgroups. In subgroups where the instrument actually has a negative slope, the regression's implicit weight on that subgroup's treatment effect becomes negative. The final coefficient is not a clean average of anyone's treatment effect — it is a distorted mixture that can point in the wrong direction entirely.

The paper proves two things from this starting point. First, there is a corrected specification — Angrist and Imbens's interacted version — that gives each subgroup its own first-stage slope and therefore avoids the negative-weight problem: the resulting coefficient is a genuine (non-negative) weighted average of subgroup treatment effects even when the sign of the first stage varies. Second, even that corrected estimand is not the LATE as conventionally defined, because its weights (proportional to the square of the subgroup's first-stage strength times the local variance of the instrument) do not match the weights needed to recover the LATE (proportional to the subgroup's share of movers). Getting exactly to the LATE requires a further re-weighting step after the interacted specification is estimated.

## 7. Method walkthrough

The paper sets up two specifications, two monotonicity assumptions, and three identification statements. The walkthrough below maps the 9-page main text (Sections 1, 2, 3.1) and flags where Section 3.2 and Section 4 — both in the appendix material outside the main-text cut — extend the argument.

**Step 1 — The two specifications, in the paper's language.**

Both specifications start from a possibly-misspecified linear model `Y = Dβ + Xρ + υ` (eq. 1) where `X` and `Z` are uncorrelated with `υ`. The paper studies probability limits of two estimators of `β`:

- *Linear IV* (eq. 2): single instrument `Z`, single endogenous regressor `D`, with `X` entered linearly. Reduced-form and first-stage projections of `Y` and `D` on `(Z, X)` **exclude** any `Z × X` interaction. Słoczyński calls this "noninteracted" or the "usual" specification.
- *2SLS in the AI sense* (eq. 3): the same structural equation, but with `X` discretized into `K` strata indexed by `G ∈ {1, …, K}`, and the instrument vector replaced by `Z_C = (Z, ZG_1, …, ZG_{K−1})`. First-stage and reduced-form regressions now include the **full set of** `Z × G_k` interactions. This is the Angrist & Imbens (1995) interacted specification.

The notational discipline matters: throughout the paper, `β_IV` is the probability limit of the noninteracted regression and `β_2SLS` is the probability limit of the AI-interacted regression. Standard software calls both "2SLS"; the paper does not.

**Step 2 — The two monotonicity assumptions, in the paper's language.**

Assumption IV (p. 7) bundles conditional independence, exclusion, and relevance. Identification of conditional LATEs and complier masses requires monotonicity in addition. The paper states two versions:

- **Strong Monotonicity (SM)**: `P[D(1) ≥ D(0) | X] = 1` a.s. The instrument's effect on treatment uptake has the same (non-negative) sign at every covariate value. Equivalent to "no defiers anywhere" (Abadie 2003).
- **Weak Monotonicity (WM)**: there exists a subset of the support of `X` on which `P[D(1) ≥ D(0) | X] = 1` and on its complement `P[D(1) ≤ D(0) | X] = 1`. Each stratum is internally monotone (no within-stratum mix of compliers and defiers), but the *direction* of monotonicity can flip across strata.

SM implies WM but not vice versa. The wind-direction example of Deryugina et al. (2019), discussed on pp. 7–8: an east wind raises pollution in San Francisco (geographic source to the east) but lowers it in Boston (source to the west). Each city is internally monotone; the sign of `ω(x)` differs by city. WM is satisfied; SM is not.

**Step 3 — Conditional identification: Lemma 2.1.**

The first-stage regression `E[D | X, Z] = ψ(X) + ω(X)·Z` (eq. 4) decomposes the conditional first stage stratum by stratum. The conditional Wald `β(x)` (eq. 6) is the ratio of the conditional reduced form to the conditional first stage at `X = x`. Lemma 2.1 then states two identification results:

- *(i)* Under IV + SM: `τ(x) = β(x)` and `π(x) = ω(x)`.
- *(ii)* Under IV + WM: `τ(x) = β(x)` and `π(x) = |ω(x)| = c(x) · ω(x)`, where `c(x) ∈ {+1, −1}` is the sign function in eq. 11.

The Wald identification of the **conditional LATE** is unchanged: `τ(x) = β(x)` under either assumption. What changes is identification of the **mover mass** `π(x)`. Under SM, `π(x) = ω(x)` directly; under WM, `π(x) = |ω(x)|`, which means recovering `π(x)` requires a sign-estimation step — knowing or estimating which side of the support `x` lies on. This is the technical pivot of the paper.

**Step 4 — The "desired" weights.**

The unconditional LATE has the closed-form expression
```
τ_LATE = E[π(X) · τ(X)] / E[π(X)]    (eq. 8)
```
i.e. a convex combination of conditional LATEs weighted by the conditional mass of movers. These are the **desired weights**: any estimand that recovers `τ_LATE` must reproduce this weighting (or equal it on average).

**Step 5 — Lemma 3.1: AI's 2SLS estimand under WM.**

Under IV + WM, with `X` fully discretized into strata `G` and the AI-interacted instrument vector `Z_C`, the 2SLS estimand admits the Angrist-Imbens / Kolesár representation
```
β_2SLS = E[σ²(X) · τ(X)] / E[σ²(X)]
```
where `σ²(X) = Var(E[D | X, Z] | X)` is the conditional variance of the first-stage prediction. The weights `σ²(X)` are non-negative, so `β_2SLS` is a convex combination of conditional LATEs even under WM — a result Kolesár (2013) had already established in greater generality.

**Step 6 — Theorem 3.2: an explicit formula for the 2SLS weights.**

Słoczyński's Theorem 3.2 (p. 9) sharpens Lemma 3.1 by computing `σ²(X)` explicitly. Under IV + WM,
```
σ²(X) = π(X)² · Var(Z | X)
```
so
```
β_2SLS = E[π(X)² · Var(Z | X) · τ(X)] / E[π(X)² · Var(Z | X)].    (Theorem 3.2)
```
The weights are non-negative — AI's interacted specification therefore avoids the negative-weights problem under WM. But comparing to the desired weights `π(X)` in eq. 8, two distortions remain:

- the **squared** `π(X)` in the AI weights overweights subgroups with strong first stages relative to subgroups with weak ones;
- the additional `Var(Z | X)` factor overweights subgroups where the instrument is balanced (close to `P(Z = 1 | X) = 0.5`).

The AI interacted estimand is therefore a positively-weighted average of conditional LATEs, but **not** `τ_LATE`. Recovering `τ_LATE` requires re-weighting by `1 / (π(X) · Var(Z | X))` after the fact.

**Step 7 — Section 3.2 (in the appendix): negative weights for noninteracted linear IV.**

The body of v8's main-text PDF stops at Theorem 3.2. In Section 3.2, the paper proves the corresponding representation for noninteracted linear IV under WM and shows that some weights can be **negative** on conditional LATEs at strata where `c(x) = −1`. This is the paper's most-cited result; the proof is in the appendix. The intuition matches Lemma 2.1(ii): the noninteracted regression identifies the conditional first stage as `ω(x)` rather than `|ω(x)|`, and using `ω(x)` as a weight where `ω(x) < 0` flips the sign on that subgroup's contribution. Under SM the weights are non-negative (because `ω(x) ≥ 0` everywhere); under WM, that floor is gone.

The headline practical consequence (also developed in Section 3.2 / appendix): under WM, the linear-IV estimand can take a sign opposite to every conditional LATE in the population. It is no longer a useful summary of treatment effects.

**Step 8 — Section 4 (in the appendix): empirical bite.**

The paper surveys 988 IV regressions from 25 papers in journals of the American Economic Association published 2006–2015. Every regression in the sample uses a noninteracted linear first stage (the homogeneity restriction). The paper formally tests `H_0: ω(x) = ω` constant — the null implied by SM — and **rejects in more than 70% of specifications** in an average paper, after correcting for multiple hypothesis testing. The pretrial-detention application based on Stevenson (2018) shows: AI-interacted estimates are smaller in magnitude than noninteracted linear-IV estimates and the difference is often statistically significant; the Mikusheva-Sun (2022) pretest rejects weak identification in every case examined, supporting the use of the interacted specification.

**Step 9 — Estimation of AI's specification: the FEJIV companion package.**

When `K` is large, AI's specification creates many interacted instruments and 2SLS is biased (Bekker 1994). Słoczyński recommends the fixed-effect jackknife IV (FEJIV) estimator of Chao, Swanson & Woutersen (2023). The companion `fejiv` package — released for R (CRAN), Stata (SSC), and MATLAB (File Exchange) — implements FEJIV for the AI specification. A Stata package implementing the Mikusheva-Sun (2022) pretest is available separately from Sun (2023).

## 8. Assumptions and when they fail

Under the paper's framework, every result is keyed to which combination of Assumption IV plus a monotonicity assumption holds. Distinguishing them carefully matters because the paper's headline — "linear IV places negative weights on conditional LATEs" — only bites in the IV + WM (not SM) regime.

- **Assumption IV(i): Conditional independence.** `(Y(0,0), Y(0,1), Y(1,0), Y(1,1), D(0), D(1)) ⊥ Z | X`. *Fails when*: covariates fail to absorb the channels through which `Z` is non-randomly assigned; e.g., latent geography that affects both the instrument and the outcome and is not in `X`. Failure of (i) breaks identification of conditional LATEs at the root; nothing else in the paper can rescue it.
- **Assumption IV(ii): Exclusion restriction.** `P[Y(1, d) = Y(0, d) | X] = 1` for each `d`. *Fails when*: `Z` affects `Y` through a channel other than `D` — the classic IV concern. Saturation / interaction does nothing for a violated exclusion restriction.
- **Assumption IV(iii): Relevance.** `0 < P[Z = 1 | X] < 1` and `P[D(1) = 1 | X] ≠ P[D(0) = 1 | X]` a.s. *Fails when*: the instrument has no variation in some stratum, or has no first-stage effect in some stratum. The conditional Wald is undefined where (iii) fails.
- **Assumption SM (Strong Monotonicity).** `P[D(1) ≥ D(0) | X] = 1` a.s. *Fails when*: the first-stage sign differs across subgroups (e.g., the wind-direction example). Failure of SM is what motivates the paper. Słoczyński's empirical survey rejects the testable implication of SM — first-stage homogeneity — in more than 70% of the 988 surveyed regressions.
- **Assumption WM (Weak Monotonicity).** Existence of a partition of the support of `X` into a complier region (where `P[D(1) ≥ D(0) | X] = 1`) and a defier region (where `P[D(1) ≤ D(0) | X] = 1`). *Fails when*: a single stratum mixes compliers and defiers internally — i.e., monotonicity fails *within* a covariate cell. WM is genuinely weaker than SM but is not assumption-free; if even WM fails, neither linear IV nor AI's specification has a clean LATE interpretation.

What Słoczyński proves under each combination, as the paper states it:

- **Under IV + SM** — both noninteracted linear IV and AI's interacted 2SLS deliver convex combinations of conditional LATEs. The two specifications use different (positive) weights, so they target different population summaries: linear IV overweights groups with high `Var(Z | X)`; AI 2SLS overweights groups with both high `Var(Z | X)` and strong first stages `π(X)²`. The desired weights `π(X)` agree with neither.
- **Under IV + WM (but not SM)** — AI's interacted 2SLS still delivers a convex combination of conditional LATEs (Theorem 3.2), with weights `π(X)² · Var(Z | X)`. Noninteracted linear IV does **not**: in Section 3.2 (appendix) the paper proves that some weights on conditional LATEs are **negative**, and the linear-IV estimand can take the opposite sign of every individual treatment effect in the population.

Two practical caveats the paper explicitly hedges:

- *Sign-estimation under WM.* Lemma 2.1(ii) identifies `π(x) = c(x) · ω(x)`, which depends on consistently estimating the sign `c(x)` of the conditional first stage in each stratum. When `|ω(x)|` is small or the per-stratum sample is limited, sign estimation is noisy. The paper discusses this in the simulation study and points to the Mikusheva-Sun (2022) pretest as a diagnostic; the precise regularity condition (typically a uniform lower bound on `|ω(x)|` away from zero) is stated in the paper's appendix.
- *Many-instrument bias under AI.* AI's specification with `K` strata creates `K − 1` extra interacted instruments. With small per-stratum samples, 2SLS suffers Bekker (1994) bias. Słoczyński does not claim 2SLS is reliable in this regime; his recommendation is the FEJIV estimator of Chao, Swanson & Woutersen (2023), implemented in the `fejiv` package.

A separate caveat for downstream agents to preserve: even when AI's specification works as advertised, **its estimand is not `τ_LATE`**. It is a positively-weighted average of conditional LATEs with weights `π(X)² · Var(Z | X)`, not the `π(X)` weights that define `τ_LATE`. Reporting AI's estimate as "the LATE" without that caveat is the same kind of label-stretching the paper criticizes in the noninteracted recipe.

## 9. What the authors find

The paper has four headline findings, paraphrased as the paper states them.

1. **Theorem 3.2 (the new formula).** Under Assumption IV and Weak Monotonicity, with `X` discretized into `K` strata and instruments fully interacted as `Z_C = (Z, ZG_1, …, ZG_{K−1})`, the 2SLS estimand equals
   ```
   β_2SLS = E[π(X)² · Var(Z | X) · τ(X)] / E[π(X)² · Var(Z | X)],
   ```
   a convex combination of conditional LATEs with non-negative weights. The weights overweight subgroups with strong conditional first stages and high instrument variance relative to the desired weights `π(X)` in eq. 8. (Theorem 3.2, p. 9.)
2. **Negative weights for noninteracted linear IV under WM.** In Section 3.2 (in the appendix, which the main-text PDF references but does not contain), the paper proves that the noninteracted linear IV estimand can be written as a weighted sum of conditional LATEs whose weights may be negative under WM. The paper states this as the first contribution in the introduction (p. 2): "the weights on some conditional LATEs may be negative in the usual application of IV, which restricts the first-stage effects of the instrument to be homogeneous." A direct consequence highlighted in the abstract: the IV estimand can be negative even when treatment effects are positive for everyone in the population.
3. **Empirical survey: 988 regressions, 25 AEA papers.** In a sample drawn from American Economic Association journals 2006–2015, every specification uses a noninteracted linear first stage. The paper formally tests the null of first-stage homogeneity and **rejects in more than 70% of specifications** in an average paper, accounting for multiple hypothesis testing. The paper interprets this as direct evidence that the WM-but-not-SM regime is the empirically common case (Section 4 / appendix; abstract, p. 1).
4. **Pretrial-detention application (Stevenson, 2018).** Implementing several saturated specifications and applying the Mikusheva-Sun (2022) pretest, the paper rejects sign homogeneity of the conditional first stage. Estimates under AI's interacted specification are **smaller in magnitude** than the noninteracted linear-IV estimates, and the difference is often statistically significant. The pretest does not reject identification in any of the cases examined, supporting the use of the AI specification.

The paper also delivers, as a software contribution, the companion `fejiv` packages (R/CRAN, Stata/SSC, MATLAB File Exchange), built on the MATLAB code of Chao et al. (2023), implementing the fixed-effect jackknife IV estimator for AI's specification.

## 10. What this means for a practitioner

**Step 1 — Run the homogeneity test before you label anything a LATE.**

The regime that causes trouble — where some subgroups have a positive first stage and others have a negative one — has a testable fingerprint: the slope of `D` on `Z` is not constant across covariate groups. Run a test for first-stage heterogeneity before reporting your coefficient as a LATE. Słoczyński's empirical survey found this test rejects in more than 70% of the 988 regressions examined; the problematic case is the rule, not the exception.

**Step 2 — Switch to the interacted (AI) specification, and use FEJIV when you have many strata.**

Replace the standard first stage `D ~ Z + X` with a fully interacted version: `D ~ Z * G` where `G` is your covariate group indicator (discretize continuous covariates first). This is the Angrist-Imbens interacted specification. It gives each subgroup its own first-stage slope, which eliminates the negative-weight problem. When you have many subgroups, the interacted specification creates many instruments and plain 2SLS becomes biased (many-instrument bias). Use the FEJIV estimator from the companion `fejiv` package (available on R/CRAN, Stata/SSC, MATLAB File Exchange) instead of standard 2SLS in that case. Also apply the Mikusheva-Sun (2022) pretest to verify that your interacted instruments are collectively strong enough — this package is available separately from Sun (2023).

**Step 3 — Understand what the interacted specification gives you, and what it does not.**

This is where Słoczyński's advice diverges from that in Blandhol et al. (2025), the companion paper in this repository. Both papers recommend the interacted specification, and both are right that it eliminates negative weights. But Słoczyński's Theorem 3.2 shows precisely what the interacted estimand *is*: a positively-weighted average of subgroup treatment effects with weights proportional to `π(X)² · Var(Z | X)` — where `π(X)` is the share of movers in that subgroup and `Var(Z | X)` is how variable the instrument is within the subgroup. That is **not** the same as the LATE, which weights subgroups by their mover share `π(X)` alone. Reporting the interacted estimand as "the LATE" is a more defensible claim than reporting the standard estimand as "the LATE" — but it is still not quite right.

**Step 4 — If you want τ_LATE specifically, re-weight after the interacted estimation.**

After estimating per-stratum treatment effects using the interacted specification, recover the population LATE by re-weighting each stratum's effect by `1 / (π(X) · Var(Z | X))` — that is, divide out the extra weighting factors that the interacted estimand puts in. Słoczyński discusses this step; the `fejiv` package provides tools to implement it.

**Step 5 — If you must keep the standard specification, report it honestly.**

If full interaction is infeasible (too many covariate cells, too few observations per stratum), do not label the result "the LATE". Report it as a weighted average of subgroup effects whose weights depend on the variance of the instrument within strata and on first-stage strength — not on the distribution of people who respond to the instrument. That is a more honest description of what the number means.

## 11. Runnable example

The [Open in Colab](https://colab.research.google.com/github/afrtrivi1120/causal-inference-papers-explainer/blob/master/papers/iv/sloczynski-linear-iv-late/simulation.ipynb) badge at the top of `simulation.ipynb` lets you run the full demonstration in-browser with no local R install. After clicking the badge, pick *Runtime → Change runtime type → R* once per session, then *Run all*.

**DGP.** The simulation uses `N = 20000` observations split equally between two strata `X ∈ {0, 1}`. Stratum `X = 0` contains only compliers (50%) and never-takers (50%), giving a conditional first stage `ω(0) = +0.5`. Stratum `X = 1` contains only defiers (50%) and always-takers (50%), giving a conditional first stage `ω(1) = −0.5`. The instrument `Z` is randomly assigned with probability 0.5 in both strata. Both strata share the same true treatment effect `τ(0) = τ(1) = 1`, so the population LATE — the `|ω(X)|`-weighted average of `τ(X)` — equals exactly 1.0. The setup satisfies weak monotonicity (WM) but not strong monotonicity (SM), which is precisely the regime where the noninteracted IV's negative-weight problem bites.

**Two estimators are compared side by side.** The noninteracted linear IV runs `AER::ivreg(Y ~ D + X | Z + X)` — the everyday recipe. The AI interacted estimator computes a separate Wald ratio within each stratum and aggregates using estimated mover-mass weights `π̂(x) = |ω̂(x)|`. With `set.seed(20260421)` and `N = 20000`, the output tibble reads:

```
  estimator                                      estimate  gap_vs_truth
  Truth (population LATE)                                 1.000         0.000
  Noninteracted linear IV  (Y ~ D + X | Z + X)           -0.026        -1.026
  τ_LATE Wald (per stratum, pooled by |ω̂(X)|)            1.018         0.018
```

The noninteracted estimate lands **near zero**, roughly one unit away from the truth, even though every individual has a treatment effect of 1.0. The exact value (and even its sign) at this seed is sampling noise: in this fully-symmetric design — equal stratum sizes, equal `Var(Z | X)`, opposite-sign `ω(x)` — the population-level linear-IV estimand is in fact `0 / 0`, with both numerator and denominator canceling. What is robust across seeds is that the estimate *collapses near zero*; the −0.026 we report is one draw's particular noise. The τ_LATE Wald is 1.018, within rounding of the truth.

**The diagnostic plots make the mechanism concrete.** The first plot shows the implied weights that each estimand places on each stratum's LATE. Under the noninteracted IV, stratum `X = 1` receives a large negative weight — because its conditional first stage `ω̂(1) ≈ −0.495` enters the averaging formula with the wrong sign. The τ_LATE Wald uses `|ω̂(X)|` as its weight, so both strata receive weights near 0.5. The second plot then shows the direct consequence: the noninteracted estimate near zero versus the τ_LATE estimate near 1.0, against the dashed line at the true LATE. Because both strata have `τ = 1`, the opposite-sign weights cancel near-perfectly, confirming Słoczyński's theoretical result that the noninteracted estimand can be near zero even when every individual effect is positive.

**A note on the estimator label.** The pooled per-stratum Wald used here is the τ_LATE-targeting estimator under WM (see Section 7). It is closely related to but not identical to the Angrist-Imbens (1995) interacted 2SLS. Per Theorem 3.2 of the paper, AI's interacted 2SLS recovers a positively-weighted average of conditional LATEs but with weights `π(X)² · Var(Z | X)`, not `π(X)`. Both estimators avoid negative weights; they differ in *which* positively-weighted aggregation they target.

## 12. Further reading

1. Imbens & Angrist (1994) — original LATE theorem; defines monotonicity and proves the LATE interpretation under SM.
2. Angrist & Imbens (1995) — interacted 2SLS specification this paper rehabilitates.
3. Kolesár (2013) — closest antecedent; weak-monotonicity 2SLS interpretation in greater generality.
4. Blandhol, Bonney, Mogstad & Torgovitsky (2025) — sibling paper on saturation and the propensity-score channel.
5. Mogstad, Torgovitsky & Walters (2021) — TSLS interpretation with multiple instruments.

See [`references.md`](references.md) for full citations.
