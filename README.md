# Causal Inference Papers — Explainers

An alternative, accessible source for making sense of the sprawling literature on causal inference. Each entry is a walkthrough of a methodological paper paired with runnable R code on simulated data.

## Who this is for

Readers who want to *understand* methodological papers in causal inference without already being experts. You do not need prior econometrics. You do need curiosity about how we learn causal effects from messy data.

Each entry in this repo answers four questions about a paper:

1. What problem does it solve?
2. What is the intuition, without the matrix algebra?
3. What assumptions does the method need, and when do they break?
4. What does this look like in R, on data where we *know* the true effect?

## Contents

Papers are organized by methodology. The taxonomy we plan to cover includes **RCTs**, **difference-in-differences (DiD)**, **regression discontinuity (RDD)**, **instrumental variables (IV)**, **synthetic control**, and **causal AI / machine-learning-based methods**, among others. Methodology buckets are created lazily — a bucket folder appears under `papers/` only once the first paper in that category lands, so buckets you don't see yet simply have no entries yet. Paper numbering (`NN-`) is global across the repo and reflects arrival order, so numbers within any one bucket are typically non-contiguous.

### Difference-in-Differences (DiD)

| # | Paper | Folder | One-line takeaway |
|---|-------|--------|-------------------|
| 01 | Ghanem, Sant'Anna & Wüthrich — *Selection and Parallel Trends* | [`papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/`](papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/) | Parallel trends is a restriction on *how units select into treatment*, not a statement about trends alone — and selection-on-gains silently breaks it. |

### Instrumental Variables (IV)

| # | Paper | Folder | One-line takeaway |
|---|-------|--------|-------------------|
| 02 | Blandhol, Bonney, Mogstad & Torgovitsky — *When is TSLS Actually LATE?* | [`papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/`](papers/iv/02-blandhol-bonney-mogstad-torgovitsky-tsls-late/) | If your IV regression includes covariates and you don't interact them with the instrument, you're almost certainly *not* estimating a LATE. |

### Regression Discontinuity (RDD)

| # | Paper | Folder | One-line takeaway |
|---|-------|--------|-------------------|
| 03 | De Magalhães, Hangartner, Hirvonen, Meriläinen, Ruiz & Tukiainen — *When Can We Trust RDD Estimates from Close Elections?* | [`papers/rdd/03-demagalhaes-et-al-rdd-close-elections/`](papers/rdd/03-demagalhaes-et-al-rdd-close-elections/) | When E[Y|X] is curved near the cutoff, CER-optimal bandwidths with bias-corrected robust inference give you honest coverage; MSE-optimal + conventional SEs do not. |

## How to read an entry

Each paper folder contains:

- **`README.md`** — a plain-language explainer (TL;DR → glossary → intuition → method → assumptions → results → takeaways).
- **`simulation.R`** — a self-contained R script that defines a data-generating process with a *known* treatment effect, runs the estimator(s) the paper discusses, prints "truth vs estimate", and renders at least one diagnostic plot.
- **`references.md`** — citation, link to the official version, and 3–5 adjacent readings.

Start with the README. When you want to see the method "in motion", run `simulation.R`.

## How to run the R code

```bash
# From the repo root
Rscript papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R
```

**Requirements:** R ≥ 4.3. Packages (loaded via `shared/r-setup.R`):

```
tidyverse, AER, rdrobust, ggplot2
```

Install anything missing with:

```r
install.packages(c("tidyverse", "AER", "rdrobust", "ggplot2"))
```

Future papers may add to this list; `shared/r-setup.R` is the source of truth.

Every simulation is seeded (`set.seed(20260421)` in `shared/r-setup.R`) so re-running gives identical numbers. Each script exposes an `N_SIM` constant near the top so you can throttle Monte Carlo work for quick iteration.

## How to add a new paper

See [`CLAUDE.md`](CLAUDE.md) for the full pipeline. In short:

1. Drop the PDF in the repo root (it will be gitignored).
2. Create a new folder `papers/<method>/NN-<first-authors>-<short-topic>/`, where `<method>` is one of the kebab-case buckets (`did`, `iv`, `rdd`, `rct`, `synthetic-control`, `causal-ai`, ...). Create the bucket folder if it is the first paper in that category.
3. Use the four project subagents in `.claude/agents/` in order — causal-inference-expert → causal-inference-professor → r-coding-expert → git-github-expert.
4. Update the contents section above — add the row under the appropriate methodology sub-heading (or add a new sub-heading if this is the first paper in its bucket).

## Licensing and sources

- Code in this repo: MIT (see header in each `.R` file).
- Written explainers: CC-BY-4.0 — reuse them, attribute this repo.
- The source PDFs themselves are **not** redistributed here. Each paper's `references.md` links to the official or arXiv version.
