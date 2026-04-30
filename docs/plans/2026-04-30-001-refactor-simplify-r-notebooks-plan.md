---
title: "refactor: Simplify R simulation notebooks to single-draw, punchline-only demos"
type: refactor
status: active
date: 2026-04-30
---

# refactor: Simplify R simulation notebooks to single-draw, punchline-only demos

## Overview

The three current `simulation.ipynb` notebooks (DID, IV, RDD) each run Monte Carlo loops of 300–500 draws across multiple scenarios or estimators, with helper functions, label-safe lookup utilities, and dense inline comments. Total code volume is 134–149 lines per notebook. This plan rewrites all three as **single-draw demonstrations** that keep only the contrast that is each paper's punchline, with concise comments. The goal is intuition: a reader who opens the notebook on GitHub should grasp the empirical paper's point in one screen of code and one plot.

## Problem Frame

The repo's audience is a motivated learner with no econometrics background (per `CLAUDE.md`). The current notebooks were written to be statistically rigorous — they compute Monte Carlo bias, RMSE, and coverage so the punchline holds *in expectation*. That rigor is valuable but it costs intuition: the reader has to mentally decode `replicate(N_SIM, run_once())`, `apply(mc['est', , ], 1, mean)`, helper closures, and label-safe lookups before reaching the result. A simpler single-draw illustration gets the paper's intent across in fewer lines, with comments that read like a tour rather than a defensive shield.

## Requirements Trace

- **R1.** Each notebook shows the paper's core methodological point with a single simulated dataset rather than a Monte Carlo loop.
- **R2.** Each notebook keeps only the estimator contrast (or scenario contrast) that is the paper's punchline; secondary estimators and specifications are dropped.
- **R3.** Each notebook still satisfies the inline-rendering bar from `CLAUDE.md`: a truth-vs-estimate structured object printed inline, and at least one diagnostic `ggplot2` plot rendered inline.
- **R4.** Comments in code cells are concise (one short line, no multi-paragraph rationale) and explain *why* a step is non-obvious, not *what* well-named code already says.
- **R5.** Section 11 ("Runnable example") of each paper's `README.md` matches the new notebook structure.
- **R6.** Project conventions in `CLAUDE.md` are updated minimally so that single-draw notebooks are first-class — i.e., `N_SIM` and the "re-anchor seed before representative plot" rule become conditional on whether a notebook uses Monte Carlo.

## Scope Boundaries

- The 12-section `README.md` template stays the same. Only section 11 is touched, and only where the new notebook structure changes its description.
- Sections 1–10 and 12 of each `README.md` are out of scope (citation, TL;DR, glossary, method walkthrough, etc.).
- `references.md` files are out of scope.
- Adding new papers, new methodology buckets, or Spanish translations are out of scope.

### Deferred to Separate Tasks

- Adding a Monte Carlo "appendix" cell at the bottom of each notebook for readers who want the sampling-distribution claim: out of scope for this plan. The user opted for the cleanest single-draw version. If demand surfaces, a follow-up plan can append an appendix block.
- CI that re-runs notebooks on PR (already listed as a future extension in `CLAUDE.md`).

## Context & Research

### Relevant Code and Patterns

- `papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.ipynb` — current DID notebook, 134 lines. Punchline contrast: parallel trends holds (`rho=0`) vs Roy-style selection breaks parallel trends (`rho=1`). Worth keeping both scenarios because the contrast IS the punchline.
- `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.ipynb` — current IV notebook, 140 lines. Three estimators today: unsaturated TSLS, stratum-Wald pooled by complier mass, full-interaction TSLS pooled. The stratum-Wald and full-interaction estimators arrive at the same point — the paper's punchline only needs one saturated baseline, so the full-interaction TSLS is dropped.
- `papers/rdd/03-demagalhaes-et-al-rdd-close-elections/simulation.ipynb` — current RDD notebook, 149 lines. Six specifications today (p=1/p=2 × MSE/CER × Conventional/Robust). The paper's central claim — that close-elections RDD coverage is sensitive to the bandwidth/inference combination — is illustrated cleanly by p=1 MSE-opt Conventional vs p=1 CER-opt Robust. The p=2 rows and the "Bias-Corrected" row are dropped.
- `CLAUDE.md` § *Notebook conventions* — the contract every notebook must follow. Two clauses become conditional on whether the notebook uses Monte Carlo: the `N_SIM` constant and the "re-anchor with `set.seed(20260421)` before any representative plot draw" rule.
- `.claude/agents/simulation-notebook-expert.md` (referenced by `CLAUDE.md`) — owns notebook structure and section 11 of the README. The agent's contract is unchanged; only the conventions it enforces are relaxed for single-draw notebooks.

### Institutional Learnings

- `docs/solutions/best-practices/structural-reorg-relative-path-depth-changes-2026-04-22.md` — when notebook locations change, README cross-links and Colab badge URLs need a sweep. Not a concern here because notebooks stay in place; only their contents change.
- `docs/solutions/runtime-errors/rscript-cwd-source-path-resolution-2026-04-21.md` — irrelevant to this plan; concerns Rscript path resolution, not notebooks.

### External References

Not used. The change is mechanical (rewrite three notebooks against an existing convention); no external research is needed.

## Key Technical Decisions

- **Single representative draw at a larger N rather than Monte Carlo.** Each notebook fixes `set.seed(20260421)` and draws once at a sample size large enough that the punchline is visible without averaging across replications. Targets: DID `N = 4000`, IV `N = 20000`, RDD `N = 2000`. Larger N replaces the variance-reduction role that `N_SIM` used to play. Rationale: keeps the result deterministic and obvious, and lets readers grasp the contrast from a single tibble. Honesty caveat: the notebook should not claim "unbiased on average" — it shows one draw, and prose should say so.
- **Use `tibble` printing for truth-vs-estimate, not `cat()` / `sprintf` blocks.** Jupyter's R kernel renders tibbles as formatted tables inline. Removing `cat(sprintf(...))` blocks is a meaningful comment-and-noise reduction.
- **Inline simulation, no helper closures.** Today's notebooks define `draw_dgp()`, `run_once()`, `coef_by_name()`, `do_fit()`, etc. so they can be called inside `replicate()`. Without Monte Carlo there is no caller, so the helpers go away and the simulation is straight-line code. The reader sees the DGP and the estimator side by side.
- **Drop the label-safe `coef_by_name` helper for `rdrobust`.** It exists to defend against rdrobust reordering its result rows under `replicate()`. With one fit and one row of interest per estimator, indexing by row name (`fit$coef['Conventional', 1]`) directly is fine and more readable. Keep a one-line `stopifnot()` that asserts the expected row name exists.
- **Comment density target.** Each code cell averages no more than one short comment per ~5 lines of code, and only where the code is non-obvious (a bias mechanism, a non-default argument, a numerical caveat). Remove all comments that re-state what the next line of code visibly does.
- **Relax `CLAUDE.md` conventions, do not break them.** Two notebook conventions are tied to Monte Carlo (`N_SIM` constant, re-anchor seed before plot). They become "if the notebook uses Monte Carlo" rather than universal. All other conventions (R kernel, defensive `install.packages`, `suppressPackageStartupMessages`, `set.seed(20260421)`, version print, tidyverse, inline plot, no PDFs / secrets / hard-coded paths, label-safe lookups when the underlying object is structured) stay verbatim.
- **Keep the Colab badge and the install-packages defensive line.** These belong to the project's "runs in a fresh Colab R kernel" guarantee and are independent of MC.
- **Re-execute notebooks with `jupyter nbconvert --to notebook --execute --inplace` before commit.** This is non-negotiable per the pre-commit checklist in `CLAUDE.md`.

## Open Questions

### Resolved During Planning

- *How aggressive should the simplification be?* Resolved: single-draw, no Monte Carlo (user choice).
- *Which estimators / specs survive in IV and RDD?* Resolved: keep only the punchline contrast (user choice). IV → unsaturated TSLS vs stratum-Wald saturated. RDD → p=1 MSE-opt Conventional vs p=1 CER-opt Robust.
- *Should DID keep both scenarios?* Resolved: yes — the PT-holds vs Roy-selection contrast IS the paper's punchline, not a Monte Carlo robustness check.
- *Does dropping MC violate `CLAUDE.md`?* Resolved: it violates two specific clauses (`N_SIM`, re-anchor before plot). Update those clauses minimally so single-draw notebooks are compliant.

### Deferred to Implementation

- **Exact figure dimensions and aesthetic polish.** `options(repr.plot.width = ..., repr.plot.height = ...)` values may need a small adjustment per notebook once the plot is laid out; not worth pre-deciding.
- **Whether the IV plot should be a bar chart of three numbers or a horizontal-CI strip.** Either reads cleanly; the notebook author picks during implementation.
- **Whether the RDD plot keeps both bandwidth-shaded rectangles (current behavior) or just one.** Implementation-time call once the simplified scatter is laid out.
- **Final `N` per notebook.** Targets above are starting points; the author may bump `N` if the single-draw point estimate sits more than a clearly-noticeable fraction of an SE from the truth (would defeat the "intuitive" goal).

## Implementation Units

- [ ] **Unit 1: Relax `CLAUDE.md` notebook conventions for single-draw notebooks**

**Goal:** Make `N_SIM` and the "re-anchor seed before representative plot" rule conditional on whether the notebook uses Monte Carlo, so the three rewritten notebooks comply with the project's own conventions.

**Requirements:** R6.

**Dependencies:** None. Lands first because Units 2–4 should comply with the updated convention text rather than violate the old one.

**Files:**
- Modify: `CLAUDE.md` (section *Notebook conventions*)

**Approach:**
- Edit the `N_SIM` bullet to read: "If the notebook uses a Monte Carlo loop, expose an `N_SIM` constant near the top so readers can throttle draws for quick iteration. Single-draw demonstrations omit `N_SIM`."
- Edit the re-anchor bullet to read: "When the notebook uses Monte Carlo, re-anchor the RNG with `set.seed(20260421)` before any 'representative' plot draw, because the Monte Carlo loop consumes an `N_SIM`-dependent amount of RNG state. Single-draw notebooks set the seed once at the top and need no re-anchor."
- Leave every other bullet in *Notebook conventions* untouched (kernel, install-packages, version print, tidyverse, truth-vs-estimate tibble, inline plot, label-safe lookups, no PDFs/secrets/absolute-paths, commit with rendered outputs).

**Patterns to follow:**
- The two existing bullets being edited.

**Test scenarios:**
- Test expectation: none — this is a documentation tweak with no behavioral surface. Verification is by review reading.

**Verification:**
- The two edited bullets read naturally for both single-draw and MC notebooks.
- No other bullet was disturbed.
- A grep for `N_SIM` in `CLAUDE.md` returns only the relaxed bullet.

- [ ] **Unit 2: Rewrite the DID notebook as a single-draw two-scenario demo**

**Goal:** Show the paper's punchline — that selection on gains breaks parallel trends — using one draw per scenario and one before/after plot. The reader should see, in one screen of code, that DiD recovers the ATT when `rho = 0` and biases it when `rho = 1`.

**Requirements:** R1, R2, R3, R4, R5.

**Dependencies:** Unit 1.

**Files:**
- Modify: `papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.ipynb`
- Modify: `papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/README.md` (section 11 only)

**Approach:**
- Keep the markdown title cell unchanged (Colab badge + paper citation + hook + DGP summary). If the DGP summary references "Monte Carlo", trim it to one sentence about a single draw per scenario.
- Setup cell: keep the defensive `install.packages` (none needed beyond `tidyverse` for this notebook), `suppressPackageStartupMessages`, single `set.seed(20260421)`, version print. Drop the comment block explaining Colab/local install — the README and `CLAUDE.md` already say this.
- Parameters cell: replace the seven-constant block with five (`N`, `TAU`, `LAMBDA`, `GAMMA`, `SIGMA`). Drop `N_SIM` and its accompanying comment. Set `N = 4000`. Each constant gets a one-line comment only if non-obvious (e.g., what `LAMBDA` controls).
- DGP + estimation as one straight-line cell per scenario: draw `(alpha, v, eps1, eps2)`, compute `y0_t1`, `y0_t2`, `gain`, `D` with Roy-style selection, build the long-format `df`, fit `lm(y ~ treat * post)`, pull `coef('treat:post')`. No `draw_dgp()` or `run_once()` helpers. Two cells, one per `rho`. Or one cell with a tiny loop over `c(rho_A = 0, rho_B = 1)` if it reads more cleanly with less duplication — implementation-time call.
- Truth-vs-estimate tibble: two rows, columns `scenario`, `true_ATT`, `DiD_estimate`, `bias`. Print directly (Jupyter renders the tibble).
- Diagnostic plot: same conceptual figure as today (group-period means with treated counterfactual dashed line), but built from the two single draws rather than a fresh re-anchored draw. Drop the `geom_point(... y0_mean ...)` extra layer if it does not add to the punchline. No `set.seed(20260421)` re-anchor before the plot — the seed was set once at top.
- Closing markdown "Punchline" cell: keep the two-bullet structure but update wording from "DiD is ~unbiased" → "DiD recovers the ATT" since we are no longer averaging across draws.
- README section 11: rewrite to describe a single-draw two-scenario demonstration rather than 300-draw Monte Carlo. Keep the Colab-badge mention.

**Patterns to follow:**
- Markdown title-cell shape (badge + citation + hook + DGP) from today's notebook.
- Tidyverse-first data handling.
- Inline plot with `options(repr.plot.width = ..., repr.plot.height = ...)`.

**Test scenarios:**
- Happy path: `jupyter nbconvert --to notebook --execute --inplace papers/did/01-*/simulation.ipynb` exits 0.
- Happy path: rendered output of the truth-vs-estimate tibble visibly shows `bias ≈ 0` for `rho = 0` and `bias > 0` for `rho = 1`.
- Happy path: rendered ggplot has the treated-counterfactual dashed line parallel to the control trend in the `rho = 0` panel and not parallel in the `rho = 1` panel.
- Edge case: setup cell still works on a fresh Colab R runtime (defensive `install.packages` for any package not pre-installed).
- Integration: README section 11's DGP description matches the notebook's DGP.

**Verification:**
- Notebook executes clean with rendered outputs committed.
- Code cell count drops materially relative to today (target: ≤ 4 code cells, was 5).
- Total code line count drops materially (target: ≤ 70 lines, was 134).
- No `replicate(`, `N_SIM`, or helper closures (`draw_dgp`, `run_once`) remain in the file.

- [ ] **Unit 3: Rewrite the IV notebook as a single-draw two-estimator demo**

**Goal:** Show the paper's punchline — that adding `X` linearly to TSLS does not recover the LATE when `Z` is only conditionally valid — using one draw and two estimators side by side.

**Requirements:** R1, R2, R3, R4, R5.

**Dependencies:** Unit 1.

**Files:**
- Modify: `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/simulation.ipynb`
- Modify: `papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/README.md` (section 11 only)

**Approach:**
- Keep the markdown title cell, badge, citation, hook, and DGP summary — trim Monte Carlo phrasing.
- Setup cell: keep defensive `install.packages('AER')`, `suppressPackageStartupMessages` of `tidyverse` and `AER`, single `set.seed(20260421)`, version print.
- Parameters cell: same population stratum-mix, treatment-effect, and `pZ_X*` constants as today, plus `N = 20000` (replaces the `N = 5000`, `N_SIM = 500` pair). Keep the `true_LATE = 0.75` derivation and its explanatory comment — it is the punchline anchor.
- Single draw cell: inline `X`, `Z`, compliance `type`, `D`, `Y`. No helper functions.
- Estimator 1 — unsaturated TSLS: `AER::ivreg(Y ~ D + X | Z + X)`, pull `coef('D')`. One line.
- Estimator 2 — stratum-Wald saturated, pooled by complier mass: compute Wald numerator/denominator on each `X` stratum, pool with weights `(n_x / N) * (mean(D|Z=1, x) - mean(D|Z=0, x))`. Roughly 8–10 lines of straight code, no closure. Drop the third estimator (full-interaction TSLS) entirely.
- Truth-vs-estimate tibble: three rows — `Truth (LATE)`, `Unsaturated TSLS`, `Saturated stratum-Wald`. Columns `estimator`, `estimate`, `gap_vs_truth`.
- Plot: a bar plot of the two estimates with `geom_hline(yintercept = true_LATE, linetype = 'dashed')` and dotted reference lines at `tau_X0 = 3.0` and `tau_X1 = 0.0`. Drop the three-panel histogram (it is meaningless without a Monte Carlo). No `geom_histogram`.
- Closing markdown "Punchline" cell: keep but reword to single-draw language.
- README section 11: rewrite to describe a single-draw two-estimator comparison rather than 500-draw Monte Carlo across three estimators.

**Patterns to follow:**
- Same top-of-notebook structure as Unit 2.
- Use the Wald formula written out explicitly rather than a closure.

**Test scenarios:**
- Happy path: `jupyter nbconvert --to notebook --execute --inplace papers/iv/02-*/simulation.ipynb` exits 0.
- Happy path: rendered tibble shows the unsaturated TSLS estimate measurably away from `0.75` while the stratum-Wald estimate sits at or near `0.75`. With `N = 20000` and one draw, the gap should be unmistakable.
- Edge case: defensive `install.packages('AER')` works on a fresh Colab R runtime.
- Edge case: if the unsaturated estimate happens to land near `0.75` for the chosen seed, the punchline visually disappears. Mitigation: keep the asymmetric `pZ_X0 = 0.15`, `pZ_X1 = 0.55` (today's values), which were chosen specifically so the weighting bug is large. Verify the gap is non-trivial under the committed seed.
- Integration: README section 11 matches notebook structure.

**Verification:**
- Notebook executes clean with rendered outputs committed.
- Code cell count drops materially (target: ≤ 4 code cells, was 5).
- Total code line count drops materially (target: ≤ 75 lines, was 140).
- No `replicate(`, `N_SIM`, full-interaction TSLS (`Y ~ D + X + DX | Z + X + ZX`), or helper closures remain.

- [ ] **Unit 4: Rewrite the RDD notebook as a single-draw two-spec demo**

**Goal:** Show the paper's punchline — that close-elections RDD coverage is sensitive to bandwidth choice and inference flavor — using one draw and two specifications.

**Requirements:** R1, R2, R3, R4, R5.

**Dependencies:** Unit 1.

**Files:**
- Modify: `papers/rdd/03-demagalhaes-et-al-rdd-close-elections/simulation.ipynb`
- Modify: `papers/rdd/03-demagalhaes-et-al-rdd-close-elections/README.md` (section 11 only)

**Approach:**
- Keep the markdown title cell, badge, citation, hook, DGP summary — trim Monte Carlo phrasing.
- Setup cell: keep defensive `install.packages('rdrobust')`, libraries, single `set.seed(20260421)`, version print.
- Parameters cell: keep `N = 600` (small-sample is the point of this paper) — but consider `N = 2000` if a single-draw point estimate at `N = 600` is too noisy to read cleanly. Implementation-time call. Drop `N_SIM` and the `specs` 6-row tibble.
- Single draw cell: `X <- runif(N, -1, 1)`, `D <- as.integer(X >= 0)`, `Y <- mu(X) + TAU_TRUE * D + rnorm(N, 0, SIGMA)`. Keep the cubic `mu()` — it is what makes MSE-optimal bandwidth biased. One short comment that says so.
- Two fits: `fit_mse <- rdrobust::rdrobust(Y, X, c = 0, p = 1, bwselect = 'mserd')` for the MSE-opt-Conventional combo, and `fit_cer <- rdrobust::rdrobust(Y, X, c = 0, p = 1, bwselect = 'cerrd')` for the CER-opt-Robust combo. Drop the four-fit dictionary and the six-spec selector loop.
- Drop the `coef_by_name()` helper. Index `rdrobust` results by row name directly: `fit_mse$coef['Conventional', 1]`, `fit_mse$ci['Conventional', ]`, `fit_cer$coef['Robust', 1]`, `fit_cer$ci['Robust', ]`. Add a one-line `stopifnot(all(c('Conventional','Robust') %in% rownames(fit_mse$coef)))` to assert the labels exist (CLAUDE.md *Label-safe lookups* rule still applies).
- Truth-vs-estimate tibble: two rows — `p=1, MSE-opt, Conventional` and `p=1, CER-opt, Robust`. Columns `specification`, `estimate`, `ci_low`, `ci_high`, `covers_truth` (`TRUE` if `[ci_low, ci_high]` contains `TAU_TRUE`).
- Plot: keep the `(X, Y)` scatter with cubic conditional-mean overlay, cutoff line, and shaded MSE/CER bandwidth windows. Drop the second plot (coverage bar chart) — it is a Monte Carlo summary and meaningless from one draw.
- Closing markdown "Punchline" cell: keep but reword to "in one draw at this seed and `N`, the MSE-opt + Conventional CI miss the truth and the CER-opt + Robust CI covers it; the paper's Monte Carlo coverage tables generalize this to many draws."
- README section 11: rewrite to describe a single-draw two-spec demonstration; mention the dropped specs are still discussed in the paper (and the Monte Carlo conclusions still stand).

**Patterns to follow:**
- Same top-of-notebook structure as Units 2–3.
- Keep the existing scatter plot's cubic-mean overlay and bandwidth shading — they are the most intuitive visual in any of the three notebooks.

**Test scenarios:**
- Happy path: `jupyter nbconvert --to notebook --execute --inplace papers/rdd/03-*/simulation.ipynb` exits 0.
- Happy path: rendered tibble shows `covers_truth = FALSE` for the MSE-opt + Conventional row and `covers_truth = TRUE` for the CER-opt + Robust row at the committed seed. If not, bump `N` or revisit `SIGMA` so the punchline is visible (the paper's whole point is that this often happens).
- Happy path: scatter plot shows the cubic conditional-mean curve, the cutoff vertical line, and the two bandwidth-shaded windows.
- Edge case: defensive `install.packages('rdrobust')` works on a fresh Colab R runtime.
- Edge case: rdrobust changes its row labels in a future version → `stopifnot()` fails fast with a clear message rather than silently returning the wrong row.
- Integration: README section 11 matches notebook structure.

**Verification:**
- Notebook executes clean with rendered outputs committed.
- Code cell count drops materially (target: ≤ 4 code cells, was 6).
- Total code line count drops materially (target: ≤ 70 lines, was 149).
- No `replicate(`, `N_SIM`, six-row `specs` tibble, four-fit list, `coef_by_name()` helper, or coverage bar chart remain.

- [ ] **Unit 5: Re-execute, sanity-check, and commit**

**Goal:** Land the changes as a single conventional commit with rendered outputs and verify the repo's pre-commit checklist still passes.

**Requirements:** R3 (rendered outputs), R5 (README section 11 in sync).

**Dependencies:** Units 1–4.

**Files:**
- Re-execute (in place): the three `papers/**/simulation.ipynb` files
- Stage: `CLAUDE.md`, the three notebooks, and the three READMEs (only the files that actually changed)

**Approach:**
- Re-run `jupyter nbconvert --to notebook --execute --inplace` on each notebook one final time to ensure the committed file matches the most recent edits.
- Spot-check each notebook's rendered output against its truth-vs-estimate tibble and plot.
- Spot-check each updated README section 11 against the notebook it now describes.
- `git status` to verify only intended files are touched. Confirm `git check-ignore *.pdf` still ignores any local PDFs.
- `git diff --stat` and `git diff CLAUDE.md` for a final read-through.
- One conventional commit, e.g. `refactor(papers): simplify R notebooks to single-draw demos`. The `CLAUDE.md` change rides in the same commit because it exists *to make* the notebook rewrites compliant — separating it would leave a transient state where the notebooks violate the conventions.
- If `origin` exists, `git push`. If not, stop at the commit (per `CLAUDE.md` §*Pushing*).

**Patterns to follow:**
- The pre-commit checklist in `CLAUDE.md` § *Committing, pushing, and publishing*.
- Conventional-commit subjects already present in the log (e.g. `fix(...)`, `docs(...)`).
- Stage files individually — never `git add .`, never `git add -A`, never `git commit -am`.

**Test scenarios:**
- Happy path: all three `jupyter nbconvert --execute` runs exit 0.
- Happy path: `git diff --stat` shows changes only to `CLAUDE.md`, three `simulation.ipynb` files, and three `README.md` files.
- Edge case: `git check-ignore *.pdf` still reports any root-level PDFs as ignored.
- Error path: a notebook fails to execute → fix the underlying code in the relevant notebook unit and re-run; do not bypass with `--no-verify`.

**Verification:**
- Single commit on the working branch with all six modified files.
- `git log -1` shows a conventional-commit subject.
- If a remote exists, the commit is pushed.

## System-Wide Impact

- **Interaction graph:** The three notebooks are independent of each other and of any non-notebook code. The only shared surface is `CLAUDE.md`'s notebook-conventions section, which is updated minimally.
- **API surface parity:** None — there is no public API. The "surface" exposed to readers is the *output* (truth-vs-estimate tibble + plot) of each notebook, which is preserved in spirit (same punchline) but visibly simplified in form.
- **Integration coverage:** The cross-cutting concern is README ↔ notebook agreement: section 11 of each README must describe what the notebook actually does. Treated as integration scenarios in Units 2–4.
- **Unchanged invariants:**
  - The 12-section README template (sections 1–10 and 12).
  - The Colab-badge contract (every notebook still opens in Colab, still works on a fresh R runtime).
  - All notebook conventions in `CLAUDE.md` not explicitly relaxed in Unit 1 (R kernel, `set.seed(20260421)`, defensive `install.packages`, version print, tidyverse, inline truth-vs-estimate object, inline ggplot, no PDFs/secrets/absolute paths, label-safe lookups for structured estimator output, commit with rendered outputs).
  - The repo folder layout, methodology buckets, and numbering.
  - The subagent pipeline and the agents themselves.

## Risks & Dependencies

| Risk | Mitigation |
|------|------------|
| A single-draw RDD result happens to cover the truth at the committed seed, defeating the punchline. | The DGP (cubic `mu`, small `N`, modest `SIGMA`) was chosen specifically so this is unlikely, but verify on the committed seed. If it covers, increase `N` modestly or perturb `SIGMA`; do not change the seed (`set.seed(20260421)` is repo-wide convention). |
| Likewise for IV: the unsaturated TSLS lands near `0.75` by chance. | The asymmetric `pZ_X0 / pZ_X1` already maximizes the weighting bug. Verify the gap is non-trivial; if not, raise `N` (kills sampling noise) before considering any other change. |
| Reader concludes "DiD is unbiased" / "stratum-Wald is right" from a single draw, missing the *in expectation* nuance. | The Punchline markdown cell in each notebook explicitly says "this is one simulated draw; the paper's claim is in expectation." README section 11 says the same. |
| `rdrobust`'s `$coef` row labels change in a future package version and `fit$coef['Conventional', 1]` silently breaks. | Keep the `stopifnot()` label assertion (CLAUDE.md *Label-safe lookups* rule still applies). Failing fast with a clear message is the desired behavior. |
| Editing `CLAUDE.md` and the notebooks in the same commit looks like scope creep. | The `CLAUDE.md` change is *minimal* (two bullets relaxed) and exists only to keep the rewritten notebooks compliant with the project's own conventions. Bundling them avoids a transient violation. The commit message and diff make this obvious. |
| Comment-density target ("≤ 1 comment per ~5 lines") becomes an arbitrary lint. | Treat it as a default, not a rule. Keep any comment that names a non-obvious *why* (a numerical caveat, an asymmetry-on-purpose, a label-safety guard). Drop comments that re-state code. |

## Documentation / Operational Notes

- No runbooks, monitoring, or rollout concerns — this is a documentation/explainer repo.
- The three updated `README.md` section 11 blocks are the user-visible documentation impact, all bundled into Units 2–4 alongside the notebook rewrites so README and notebook never drift.
- The `CLAUDE.md` *Notebook conventions* relaxation is the one piece of "convention documentation" that changes; it lives in Unit 1.

## Sources & References

- Existing notebook source files (already linked in *Relevant Code and Patterns*).
- `CLAUDE.md` § *Notebook conventions*, § *Committing, pushing, and publishing*, § *Adding a new paper — checklist*.
- `.claude/agents/simulation-notebook-expert.md` (referenced via `CLAUDE.md`).
