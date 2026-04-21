# Causal Inference Papers — Plain-Language Explainers

A growing library of plain-language walkthroughs of methodological papers in causal inference, each paired with runnable R code on simulated data.

## Who this is for

Readers who want to *understand* methodological papers in causal inference without already being experts. You do not need prior econometrics. You do need curiosity about how we learn causal effects from messy data.

Each entry in this repo answers four questions about a paper:

1. What problem does it solve?
2. What is the intuition, without the matrix algebra?
3. What assumptions does the method need, and when do they break?
4. What does this look like in R, on data where we *know* the true effect?

## Contents

| # | Paper | Method | Folder | One-line takeaway |
|---|-------|--------|--------|-------------------|
| 01 | Ghanem, Sant'Anna & Wüthrich — *Selection and Parallel Trends* | Difference-in-Differences | [`papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/`](papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/) | Parallel trends is a restriction on *how units select into treatment*, not a statement about trends alone — and selection-on-gains silently breaks it. |
| 02 | Blandhol, Bonney, Mogstad & Torgovitsky — *When is TSLS Actually LATE?* | Instrumental Variables / TSLS | [`papers/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/`](papers/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/) | If your IV regression includes covariates and you don't interact them with the instrument, you're almost certainly *not* estimating a LATE. |
| 03 | De Magalhães, Hangartner, Hirvonen, Meriläinen, Ruiz & Tukiainen — *When Can We Trust RDD Estimates from Close Elections?* | Regression Discontinuity | [`papers/03-demagalhaes-et-al-rdd-close-elections/`](papers/03-demagalhaes-et-al-rdd-close-elections/) | When E[Y|X] is curved near the cutoff, CER-optimal bandwidths with bias-corrected robust inference give you honest coverage; MSE-optimal + conventional SEs do not. |

## How to read an entry

Each paper folder contains:

- **`README.md`** — a plain-language explainer (TL;DR → glossary → intuition → method → assumptions → results → takeaways).
- **`simulation.R`** — a self-contained R script that defines a data-generating process with a *known* treatment effect, runs the estimator(s) the paper discusses, prints "truth vs estimate", and renders at least one diagnostic plot.
- **`references.md`** — citation, link to the official version, and 3–5 adjacent readings.

Start with the README. When you want to see the method "in motion", run `simulation.R`.

## How to run the R code

```bash
# From the repo root
Rscript papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R
```

**Requirements:** R ≥ 4.3. Packages (loaded via `shared/r-setup.R`):

```
tidyverse, fixest, did, AER, estimatr, rdrobust, rddensity, ggplot2
```

Install anything missing with:

```r
install.packages(c("tidyverse","fixest","did","AER","estimatr","rdrobust","rddensity"))
```

Every simulation is seeded (`set.seed(20260421)` in `shared/r-setup.R`) so re-running gives identical numbers. Each script exposes an `N_SIM` constant near the top so you can throttle Monte Carlo work for quick iteration.

## How to add a new paper

See [`CLAUDE.md`](CLAUDE.md) for the full pipeline. In short:

1. Drop the PDF in the repo root (it will be gitignored).
2. Create a new folder `papers/NN-<first-authors>-<short-topic>/`.
3. Use the four project subagents in `.claude/agents/` in order — causal-inference-expert → causal-inference-professor → r-coding-expert → git-github-expert.
4. Update the contents table above with the new row.

## Licensing and sources

- Code in this repo: MIT (see header in each `.R` file).
- Written explainers: CC-BY-4.0 — reuse them, attribute this repo.
- The source PDFs themselves are **not** redistributed here. Each paper's `references.md` links to the official or arXiv version.
