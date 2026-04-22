---
date: 2026-04-22
topic: jupyter-notebook-migration
---

# Migrate `simulation.R` to Jupyter notebooks with in-browser execution

## Problem Frame

The repo currently ships each methodological paper as a folder with `README.md` (the 12-section explainer), `simulation.R` (the runnable demo of the paper's estimator on a known DGP), and rendered PNGs under `figures/`. To actually run a simulation, a reader must clone the repo, install R ≥ 4.3 plus a growing list of CRAN packages (`tidyverse`, `AER`, `rdrobust`), and invoke `Rscript papers/<method>/NN-*/simulation.R` from the repo root. That is a real friction wall for a typical reader of methodological causal-inference papers in 2026, whose default computing environment is Python and who may not have any R toolchain installed.

The goal of this migration is to make every paper's simulation executable **without leaving the browser** — land on the paper's folder on GitHub, see the rendered notebook (prose, code, plot) inline, click an "Open in Colab" badge to launch a free cloud Python kernel, and run every cell. No clone, no `install.packages`, no `Rscript`. The motivational estimators in all three existing papers have faithful Python equivalents — including `rdrobust-python` maintained by the same Calonico-Cattaneo-Titiunik group that ships the R `rdrobust` package — so the migration is methodologically lossless.

## Requirements

**Notebook artifact (per paper)**

- R1. Each paper under `papers/<method>/NN-*/` ships a `simulation.ipynb` in place of the current `simulation.R`. The notebook produces the same quantitative comparison (truth vs. estimate) and at least one diagnostic plot that the retired R script produced.
- R2. The top of each notebook carries an "Open in Colab" badge linking to `https://colab.research.google.com/github/<owner>/<repo>/blob/master/papers/<method>/NN-*/simulation.ipynb`, so a reader opens the notebook in a free Colab kernel with one click.
- R3. The first executable cell installs all notebook-specific dependencies via `!pip install ...` so a fresh Colab kernel (or a local Jupyter with only `jupyter` installed) boots without further prep.
- R4. Notebooks are committed **with rendered cell outputs** (plot images, result tables) so GitHub's native `.ipynb` renderer shows the full reader experience without requiring execution. Re-runs that change only RNG-induced noise should not churn the notebook; use a fixed seed (`np.random.seed(20260421)`, matching the existing R convention) so outputs are stable.
- R5. Every notebook remains runnable **locally** via `jupyter lab` after `pip install -r requirements.txt` from the repo root. The Colab path is the recommended reader experience; the local path is the escape hatch for contributors and for offline use.

**Existing paper content**

- R6. The 12-section `README.md` template stays intact for every paper; only the "Runnable example" section (section 11) and any prose that references `simulation.R` or `Rscript` are updated to reference `simulation.ipynb` and Colab.
- R7. All three existing papers (DiD 01, IV 02, RDD 03) are migrated in this pass. Methodological results must match the retired R simulations within reasonable RNG tolerance for seeded estimators.

**Repo-level scaffolding**

- R8. A `requirements.txt` (or `environment.yml`) at the repo root lists top-level Python dependencies with pinned major/minor versions. `shared/r-setup.R` is retired. A tiny `shared/py-setup.py` (or inlined setup cells per notebook) re-anchors the RNG and centralizes constants that every simulation shares.
- R9. `CLAUDE.md`'s "R conventions" section is replaced with a "Notebook conventions" section (seed, plot-save path, first-cell-installs-deps idiom, committed-outputs policy). The "Running the simulations" block replaces its three `Rscript` examples with the equivalent Colab-badge + local-`jupyter lab` guidance.
- R10. The top-level `README.md` "How to run the R code" section becomes "How to run the notebooks," documenting both the Colab badge path (primary) and the local Jupyter path (fallback).
- R11. The landing-README contents table grows one column per paper row for the Colab badge, so a reader browsing the contents can one-click directly into a live simulation.

**Subagent pipeline**

- R12. The `.claude/agents/r-coding-expert.md` subagent is retired and replaced by a notebook-focused equivalent (working name: `simulation-notebook-expert`) that owns `simulation.ipynb` creation + section-11 README prose. The pipeline order stays expert → professor → simulation-notebook-expert → git.
- R13. References in the other three subagent definitions (`causal-inference-expert`, `causal-inference-professor`, `git-github-expert`) are updated to reflect notebook artifacts where they currently reference `.R` / `Rscript` / `shared/r-setup.R`.

**docs/solutions continuity**

- R14. The two existing `docs/solutions/` entries that reference R tooling (the 2026-04-21 `rscript-cwd-source-path-resolution` entry and the 2026-04-22 `structural-reorg-relative-path-depth-changes` entry) are not deleted or rewritten. Each receives a dated Postscript noting that the simulation layer has moved from R to Python notebooks, which of their lessons still apply (higher-order principles: "test the documented command verbatim" and the six-pattern reorg playbook) and which are now historical only (R-specific `source()` CWD semantics). This follows the best-practice in the 2026-04-22 entry itself.

## Success Criteria

- A reader with **no local R or Python install** can open any of the three paper notebooks on github.com, see the rendered plot and result table inline, click the Colab badge, and produce the same plot + numbers in a Colab session in under a minute.
- A contributor adding paper 04 invokes the four-step subagent pipeline and the new `simulation-notebook-expert` produces a runnable `simulation.ipynb` — no R toolchain is required anywhere in the contributor flow.
- All three existing papers' notebooks, executed top-to-bottom in a fresh Colab kernel with the seed pinned to `20260421`, reproduce the retired R simulations' headline numbers (bias, coverage, MC SE) within tolerance: exact match for deterministic estimators (IV, RDD point estimates), and seed-driven reproducibility for Monte Carlo statistics.
- `git grep -l 'Rscript\|install\.packages\|shared/r-setup'` returns zero live hits in `CLAUDE.md`, `README.md`, `.claude/agents/`, and any `papers/**/README.md`. (Historical hits in `docs/solutions/*` are fine and expected.)

## Scope Boundaries

- **Not in scope: dual-language maintenance.** The migration is a replacement, not an addition. The three existing `simulation.R` files and `shared/r-setup.R` are deleted; they are preserved via git history and (optionally) a pre-migration git tag for historical reference.
- **Not in scope: Quarto / `.qmd` / other notebook formats.** Jupyter `.ipynb` is the target. Quarto would give cleaner git diffs but lose Colab one-click support.
- **Not in scope: merging the 12-section `README.md` prose into the notebook.** The README stays as a separate markdown file (decision locked in Phase 1 of this brainstorm). The notebook is a swap-in replacement for `simulation.R`, not for the whole paper.
- **Not in scope: GitHub Codespaces / mybinder.org / devcontainer setup.** Colab is the execution path for the reader; local `jupyter lab` is the escape hatch. Codespaces would add a devcontainer.json, cold-start latency, and a larger maintenance surface for no meaningful reader-side benefit beyond what Colab already delivers.
- **Not in scope: interactive widgets (`ipywidgets`, Panel, Shiny for Python).** Notebooks remain static-per-run; readers who want to sweep parameters edit the cell and re-run it.
- **Not in scope: retitling the repo or adjusting the taxonomy.** The `did`/`iv`/`rdd`/`rct`/`synthetic-control`/`causal-ai` bucket names stay exactly as `CLAUDE.md` defines them today.
- **Not in scope: a shared "DGP library" that multiple notebooks import.** Each notebook stays self-contained. Extracting common DGPs into `shared/dgp/` is a plausible future extension once papers 4-6 make the duplication concrete; do not build the abstraction preemptively.
- **Not in scope: publishing the notebooks as a standalone HTML site (GitHub Pages, Quarto site, Jupyter Book).** GitHub's native `.ipynb` rendering is enough for the current audience.

## Key Decisions

- **Language: Python** — decided. Chosen because (a) the reader audience is Python-first in 2026, (b) `rdrobust-python` (Calonico-Cattaneo-Titiunik) gives methodological parity on RDD, (c) Python is unambiguously the right language for the future `causal-ai` bucket (`econml`, `dowhy`, `causalml`), and (d) Colab is a Python-first cloud kernel.
- **Execution model: static render on GitHub + Colab badge** — decided in Phase 1 Q2. Commit notebooks with outputs so GitHub shows the full reader experience without execution; Colab badge gives one-click live kernel. No Codespaces, no Binder, no Jupyter Book.
- **Artifact shape: notebook replaces `simulation.R` only; `README.md` stays separate** — decided in Phase 1 Q3. The 12-section template is stable and doesn't need to migrate into JSON cells; the subagent pipeline's division of labor (expert/professor own markdown prose; the simulation author owns the runnable) is preserved.
- **Migration mode: wholesale replacement, not dual-track** — the user's framing was explicit ("replace the R scripts"). A bilingual repo would double the subagent set and double the per-paper maintenance for no reader-side value.
- **Seed convention: `np.random.seed(20260421)`** — unchanged from the R seed value, so any reader who cross-references old Git history against the new notebooks sees the same intent even though the RNG streams differ.
- **Output policy: commit with outputs** — chosen over `nbstripout`. For an explainer repo, the reader-side render value of committed outputs outweighs the diff noise of the occasional re-run. Re-runs with a fixed seed should be rare and stable.

## Dependencies / Assumptions

- **Assumption (verifiable in planning):** `rdrobust-python` (PyPI) provides API-equivalent `rdrobust`, `rdbwselect`, and `rdplot` functions with the same MSE-optimal + CER-optimal bandwidth selectors and conventional/bias-corrected robust inference options that the R `rdrobust` package ships. Paper 03's simulation relies on these; if the Python port has gaps, the planner needs to resolve them.
- **Assumption (verifiable in planning):** `linearmodels.iv.IV2SLS` and friends cover the saturated (fully-interacted) TSLS specifications paper 02 uses. The interaction specification `Y ~ D + X + D:X | Z + X + Z:X` must work without additional scaffolding.
- **Assumption:** GitHub's `.ipynb` renderer correctly displays matplotlib (or plotnine) output for the plots papers 01 and 03 currently produce. Colab's kernel size is not the binding constraint for the current papers' settings, which are per-paper: paper 01 `N_SIM = 300`, `N = 2000`; paper 02 `N_SIM = 500`, `N = 5000`; paper 03 `N_SIM = 500`, `N = 600` with four `rdrobust` fits per draw. **Runtime** (not kernel size) is the real risk — paper 03 in particular calls `rdrobust-python` inside the MC loop, and the Python port is noticeably slower per call than the R version. Planning should verify that a fresh Colab kernel "Run All" for paper 03 completes in a bounded time, or expose a small-N_SIM fast-path alongside the committed headline numbers.

## Alternatives Considered

- **Dual-track (keep R, add Python notebooks alongside)** — rejected. Doubles the subagent surface and the per-paper maintenance. The session's recent `best-practices/` entry on cross-surface sweeps is a direct warning against optional duplication.
- **Quarto `.qmd` with Python kernel** — rejected for this pass. Cleaner git diffs (plain markdown + fenced code), supports both R and Python kernels. But no Colab one-click, and the reader would need `quarto` installed to re-render locally. A possible future migration if `.ipynb` diff noise becomes a real pain.
- **Static notebooks only (no Colab execution)** — rejected. Loses the single biggest reader-side win of this migration. Committing outputs addresses the "can I see the plot?" question; Colab addresses the "can I tweak the DGP and see what happens?" question. Both are load-bearing for an explainer repo.
- **GitHub Codespaces with devcontainer** — rejected as overkill. Good fit for multi-file repos where readers want to edit across files; this repo's simulations are single-notebook, so Colab's lightweight one-click wins on friction.
- **Future extension — shared DGP library** — deliberately out of scope. Once the repo has 4-6 papers and per-notebook DGP duplication becomes visible, extract a `shared/dgp/` library so readers can compose DGPs across papers. Premature now; concrete once the duplication is concrete.

## Outstanding Questions

### Resolve Before Planning

_(None — the brainstorm resolved the three product-shaping questions: language, execution model, artifact shape.)_

### Deferred to Planning

**Dependencies & libraries**

- [Affects R1, R7][Technical][Needs verification] Which specific Python package lands each paper's estimator cleanest: paper 01 (DiD 2×2) is hand-rolled either way; paper 02 → `linearmodels.iv.IV2SLS`; paper 03 → `rdrobust-python`. Planning should verify that `rdrobust-python` exposes the same `bwselect="mserd"` / `"cerrd"` options and `vce` choices paper 03 needs, and that `linearmodels` 2SLS accepts saturated-interaction specs paper 02 needs.
- [Affects R3, R4][Technical] Whether Colab's pre-installed scientific Python stack already includes the deps paper 01 needs (numpy/pandas/statsmodels/matplotlib) versus the deps paper 03 needs (`rdrobust-python`, probably not pre-installed). Planning confirms per-notebook `!pip install` cell contents.
- [Affects R4, R5][Technical][Needs research] Plotting library choice: `matplotlib` (native, guaranteed-render) versus `plotnine` (ggplot2 grammar port, more familiar to R-to-Python migrators) versus `seaborn`. Consistent across papers is better than per-paper idiosyncrasy. Likely `matplotlib` as the single choice for GitHub-render reliability.
- [Affects R8][Technical] Environment file format: `requirements.txt` (simplest, pip-native) versus `environment.yml` (conda, better reproducibility but not Colab-native). Likely `requirements.txt` for Colab alignment.

**Development tooling**

- [Affects R4][Technical] Confirm contributor-level `nbstripout` guidance: per the Output Policy in Key Decisions, `nbstripout` is **not** applied as a project-level pre-commit hook, because master-branch commits must carry rendered outputs for GitHub's inline renderer. Planning may still document an optional per-developer use of `nbstripout` on local feature branches for cleaner intermediate diffs, re-rendering outputs before the merge-to-master commit.

**Subagent & pipeline**

- [Affects R12][Technical] Final name of the replacement subagent — `simulation-notebook-expert`, `python-simulation-expert`, or keep `r-coding-expert` renamed in-place. Affects `.claude/agents/` filenames and `CLAUDE.md` subagent-routing table.

**Deployment & URLs**

- [Affects R2, R11][Technical] Exact Colab URL template once the repo has a canonical default branch (currently `master`). The badge URL must hard-code the branch; planning confirms or parameterizes.

**Documentation**

- [Affects R14][Technical] Exact wording of the postscripts on the `docs/solutions/` entries — planning follows the postscript pattern from the 2026-04-22 entry itself.

## Next Steps

`-> /ce:plan` for structured implementation planning. The brainstorm has resolved the three product-shaping decisions (language, execution model, artifact shape) and enumerated 14 concrete requirements plus 8 deferred-technical questions for the planner to work through.
