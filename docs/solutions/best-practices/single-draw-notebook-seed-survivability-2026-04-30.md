---
title: "Single-draw simulation notebooks: punchline survivability at the committed seed"
date: 2026-04-30
category: best-practices
module: papers_explainer
problem_type: best_practice
component: development_workflow
severity: medium
applies_when:
  - Authoring or simplifying a `simulation.ipynb` so it runs one representative draw instead of a Monte Carlo loop
  - The pedagogical punchline depends on a comparison the reader observes from the rendered output (truth-vs-estimate tibble, CI coverage indicator, bias direction)
  - The `set.seed(20260421)` repo-wide seed convention is non-negotiable
  - `jupyter nbconvert --to notebook --execute --inplace` exits 0 but you have not yet read the rendered output cells
tags:
  - simulation-notebooks
  - single-draw
  - monte-carlo
  - seed-discipline
  - punchline-verification
  - r-notebooks
  - nbconvert
---

# Single-draw simulation notebooks: punchline survivability at the committed seed

## Context

On 2026-04-30, the three R simulation notebooks (DID, IV, RDD) were rewritten as single-draw demonstrations rather than Monte Carlo loops. Dropping `replicate(N_SIM, run_once())` collapses an averaged result into one realization, which makes the reader-visible output **entirely seed-dependent**: whatever the truth-vs-estimate tibble and the diagnostic plot show at `set.seed(20260421)` is what the reader sees on GitHub and Colab forever, until someone re-executes the notebook.

The RDD notebook surfaced this hazard in the wild. At seed `20260421`, both the MSE-optimal + Conventional CI and the CER-optimal + Robust CI happened to cover the truth `tau = 0.5`. The paper's actual claim — that MSE-opt + Conventional under-covers (~92–93% empirical coverage vs. 95% nominal) — is a property of the sampling distribution that one draw cannot demonstrate. `nbconvert --execute` exited 0. The notebook *looked* fine. But §11 of the README would have read as a self-contradicting demo (table shows both rows covering, prose claims one should miss) if the punchline cell hadn't been rewritten honestly.

This entry codifies the discipline that turns "single-draw notebook compiles" into "single-draw notebook actually demonstrates what its README §11 claims."

## Guidance

### 1. `nbconvert` exit 0 is not a punchline check

A successful execution proves the R code runs without error. It does **not** prove that the rendered output cells contain the contrast the reader is supposed to see. After every re-execution of a single-draw notebook, open the committed `.ipynb` and read the actual output cells:

- Does the truth-vs-estimate tibble show the gap/contrast the prose claims?
- Does the diagnostic plot have the visual feature the prose calls out?
- If a `covers_truth` column is present, do the values match what the punchline cell asserts?

If the tibble silently flips direction (e.g., `bias` is now negative when the prose says "biased upward") or a coverage indicator silently flips, the notebook will exit 0 and the contradiction will ship. There is no automated guard for this in the current repo.

### 2. Re-anchor `set.seed(20260421)` immediately before the single representative draw

For Monte Carlo notebooks, `CLAUDE.md` requires re-anchoring the seed before any "representative draw" plot because the MC loop has consumed an `N_SIM`-dependent amount of RNG state. For single-draw notebooks, the seed is set once at the top of the notebook and the rest of the cells are deterministic — no re-anchor is needed for *correctness*. But re-anchoring immediately before the draw is still good hygiene if any cell between the top-of-notebook seed and the draw might consume RNG state in a future edit (e.g., a probe `runif(10)` left behind during development). When in doubt, anchor.

### 3. Increase N rather than change the seed if the punchline doesn't manifest

If you read the rendered output and the punchline isn't visible, the recovery moves are, in order of preference:

1. **Bump `N`** to reduce sampling noise around the population-level effect.
2. **Adjust DGP parameters** that amplify the effect being demonstrated (e.g., increase the curvature in `mu(X)`, widen the asymmetric `pZ_X*` for an IV weighting bug).
3. **Reframe the punchline** prose to match what the rendered draw *can* honestly demonstrate (e.g., "this shows the mechanism, not the coverage rate").
4. **Restructure as a Monte Carlo notebook** if the punchline really is a sampling-distribution claim that one draw cannot show.

What you must **not** do: sweep through seeds until you find one whose draw *happens* to demonstrate the effect. The repo-wide seed `20260421` is fixed by `CLAUDE.md` to keep all simulations cross-comparable and to prevent exactly this kind of selection. Changing the seed to get a "nicer" result is p-hacking the explainer — pedagogically dishonest, and it sets a precedent that no future contributor can cite the repo's seed convention against. The 2026-04-30 RDD case was handled by option 3 (reframed the punchline to be about bandwidth/CI-width *mechanism*, not coverage rate) precisely because options 1 and 2 had been tried and the punchline still didn't manifest at this seed.

### 4. State the single-draw caveat explicitly in the notebook and the README

Every single-draw notebook should say two things in plain language:

- "This is one draw at seed `20260421` and `N = …`."
- "The paper's claim is in expectation; one draw cannot prove it."

Both go in the punchline markdown cell of the notebook *and* in §11 of the paper's `README.md`. This protects against the reader misreading the rendered output as evidence of the population claim. If the rendered numbers look unusually clean, say so. If they look unusually noisy, say so. The 2026-04-30 RDD notebook does this verbatim ("At this seed both CIs cover the truth — that is the *exception*, not the contradiction it looks like…").

## Why This Matters

A pedagogical explainer that contradicts itself is worse than a more abstract one. If the reader opens `simulation.ipynb` and sees a tibble whose numbers don't match the punchline prose, they conclude either (a) the prose is wrong, or (b) the simulation is wrong, or (c) they don't understand the method. None of those is the intended takeaway. The committed-and-rendered output is a *promise* about what the reader will see, and the seed-dependent nature of single-draw demos makes it easy to ship a broken promise without noticing.

The four discipline points above are cheap (each is ≤2 minutes per re-execution) and they catch the silent-failure mode that `nbconvert` cannot. They are the cost of the simplicity gain that single-draw notebooks deliver — readers grasp the paper's intent in one screen, but only if the screen actually shows the intent.

## When to Apply

- Every time you re-execute a single-draw `simulation.ipynb`.
- Every time you change a DGP parameter, sample size, or seed location in a single-draw notebook.
- Every time you upgrade a dependency that could change estimator behavior (`AER`, `rdrobust`, etc. — these can change point estimates or CI calculations across versions).
- Every time you copy an existing single-draw notebook as the starting point for a new paper.
- Before opening a PR that touches any single-draw `simulation.ipynb` or its README §11.

## Examples

The 2026-04-30 RDD case, handled correctly:

```r
# Seed is set once at the top of the notebook.
set.seed(20260421)
# … parameters …
N        <- 2000
TAU_TRUE <- 0.5
# … DGP …
X <- runif(N, -1, 1)
D <- as.integer(X >= 0)
Y <- mu(X) + TAU_TRUE * D + rnorm(N, 0, SIGMA)

# Two specs, fitted on this single draw.
fit_mse <- rdrobust(y = Y, x = X, c = 0, p = 1, bwselect = 'mserd')
fit_cer <- rdrobust(y = Y, x = X, c = 0, p = 1, bwselect = 'cerrd')
```

Rendered output read after `nbconvert --execute`:

```
specification                estimate   ci_low   ci_high   covers_truth
p=1, MSE-opt, Conventional   0.494      0.339    0.649     TRUE
p=1, CER-opt, Robust (BC)    0.477      0.296    0.659     TRUE
```

Both rows show `TRUE`. The paper claims MSE-opt + Conventional under-covers — but the table doesn't show that miss. Tried bumping `N` from `600` to `2000`, tried sharper cubics, tried larger `SIGMA`. At seed `20260421` the punchline never materialized as a coverage failure.

What was done — option 3 from the recovery list, reframe honestly:

```markdown
> Both rows show `covers_truth = TRUE` at this seed — that is the *exception*,
> not the contradiction it looks like. The paper's coverage claim is in
> expectation across many draws (the MSE-opt + Conventional CI empirically
> covers around 92–93% under realistic curvature, vs. 95% nominal). One draw
> cannot prove an 8% miss rate; what one draw *can* show is the mechanism
> that drives it (next paragraph).
```

The notebook's diagnostic plot still demonstrates the *mechanism* (CER-opt picks a narrower bandwidth window, less of the curved cubic sits inside the local-linear fit) — that part *is* visible from one draw. The pedagogical contract was preserved by narrowing what the notebook claims to demonstrate, not by seed-shopping.

What was **not** done (and what no future contributor should do):

```r
# WRONG — never sweep seeds until the punchline materializes.
for (s in 20260400:20260500) {
  set.seed(s)
  # … run notebook, check if MSE-opt CI misses …
  # commit s as the new seed if it does
}
```

The repo-wide `20260421` seed exists exactly to prevent this. Change the *N*, the *DGP*, or the *prose* — never the seed.

## Related

- `docs/solutions/best-practices/claude-md-convention-edit-must-sweep-subagent-defs-2026-04-30.md` — the sibling lesson from the same incident, about keeping `CLAUDE.md` and `.claude/agents/*.md` in sync. That entry is about *convention drift*; this one is about *pedagogical honesty under seed dependence*. They share a root cause (the 2026-04-30 single-draw refactor) but address different failure modes.
- `docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md` — Prevention #1 ("test the exact documented invocation, not a wrapper around it") generalizes here: `nbconvert --execute` exit 0 is a wrapper-style success signal, not a punchline-correctness signal. Inspect the rendered cells.
- `CLAUDE.md` § "Notebook conventions" — the home of the `set.seed(20260421)` repo-wide rule and the relaxed `N_SIM` / re-anchor bullets that make single-draw notebooks first-class.
- `.claude/agents/simulation-notebook-expert.md` — the subagent that authors notebooks. Its "Do not fabricate numbers" rule of engagement is the same idea as this entry's #3 ("don't seed-shop"); this entry adds the *positive* discipline (read the rendered output, bump N first) the agent should follow.
- `docs/plans/2026-04-30-001-refactor-simplify-r-notebooks-plan.md` — the plan that drove the refactor. Its risk table calls out single-draw seed-survivability as a known hazard with mitigation; this entry is the post-incident codification of that mitigation.
