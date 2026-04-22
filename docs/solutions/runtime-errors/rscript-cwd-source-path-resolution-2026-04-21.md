---
title: "Rscript invoked from repo root fails to resolve relative source() path in simulation scripts"
date: 2026-04-21
category: runtime-errors
module: papers_explainer
problem_type: runtime_error
component: tooling
severity: high
symptoms:
  - "Error in file(filename, \"r\", encoding = encoding): cannot open the connection"
  - "cannot open file '../../shared/r-setup.R': No such file or directory"
  - "Rscript papers/<method>/NN-.../simulation.R from repo root exits immediately with no output"
  - "figures/ directory and output PNGs written at repo root instead of inside the paper folder"
root_cause: config_error
resolution_type: code_fix
tags:
  - r
  - rscript
  - relative-path
  - source
  - reproducibility
  - working-directory
  - setwd
related_components:
  - development_workflow
  - documentation
---

# Rscript invoked from repo root fails to resolve relative `source()` path in simulation scripts

## Problem

Every `simulation.R` script at the time opened with a bare `source("../../shared/r-setup.R")`, a path that R resolves against its **current working directory** at the moment the call executes — not against the script's own file location. The documented invocation in `README.md` and `CLAUDE.md` was `Rscript papers/NN-*/simulation.R` **from the repo root**, which meant R looked for `shared/r-setup.R` two directories *above* the repo root, found nothing, and halted immediately. The scripts only worked if the user first `cd`'d into the paper folder. (The `papers/NN-*/` flat layout has since been reorganized into `papers/<method>/NN-*/` buckets, and the relative `source()` path accordingly deepened from `../../` to `../../../` — see the postscript at the end of this entry.)

## Symptoms

- Running the documented command from the repo root produces:
  ```
  Error in file(filename, "r", encoding = encoding) :
    cannot open the connection
  In addition: Warning message:
  In file(filename, "r", encoding = encoding) :
    cannot open file '../../shared/r-setup.R': No such file or directory
  Execution halted
  ```
- The script exits before any other line executes; no Monte-Carlo output, no plots, no `cat()` messages.
- Same CWD dependency silently affects `dir.create("figures", showWarnings = FALSE)` and every subsequent `ggsave("figures/...")`: when invoked from the repo root, a post-fix script would otherwise scatter PNGs under the repo root rather than inside the paper folder.
- The failure did **not** fire when the caller first `cd`'d into the paper folder and ran `Rscript simulation.R` — because then R's CWD was already the paper folder.

## What Didn't Work

The author's own Unit-6 end-to-end verification script (commit `fe0c062`) used:

```bash
(cd "$dir" && Rscript simulation.R)
```

This sub-shell `cd` pattern is *not* the same as the documented command — it pre-changes the working directory so that the buggy `../../shared/r-setup.R` path resolves correctly. Because the verification wrapper always pre-`cd`'d, the failure path was never exercised, and the bug survived the author's full verification pass.

The divergence was only caught when an independent reviewer (ce:review's `correctness-reviewer`, finding **COR-01 P1**) ran the exact command documented in `README.md`:

```bash
Rscript papers/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R
```

and saw the `cannot open the connection` error immediately.

## Solution

Prepend a 4-line preamble to every `simulation.R` before the `source()` call:

**Before**

```r
source("../../shared/r-setup.R")
```

**After**

```r
# Resolve the script's own directory so `source()` and `figures/` work whether
# this script is invoked from the repo root or from its own folder.
.args <- commandArgs(trailingOnly = FALSE)
.file <- .args[grepl("^--file=", .args)]
if (length(.file) > 0) setwd(dirname(sub("^--file=", "", .file[1])))

source("../../shared/r-setup.R")
```

Applied to all three papers in commit `f2b16cd`. `CLAUDE.md` was updated in the same commit to declare this preamble a required convention for every new `simulation.R`, and the `r-coding-expert` subagent definition was updated to emit it automatically.

## Why This Works

- `source()` is a wrapper around `file()`, which resolves relative paths against `getwd()` — R's **current working directory**, a process-level property that defaults to wherever the shell stood when `Rscript` was launched. The script's filesystem location plays no role in path resolution unless something changes the CWD first.
- `Rscript` always injects the script's path into `commandArgs(trailingOnly = FALSE)` as a `--file=<path>` element. Filtering for `^--file=`, stripping the prefix, and calling `dirname()` yields the script's own directory regardless of where the caller was standing. This is the standard base-R idiom for a script to discover its own location at runtime — more reliable than `sys.frame` tricks, which only work inside sourced contexts.
- `setwd(dirname(...))` then anchors R's CWD to the script's folder for the remainder of the process, so every subsequent relative path (`../../shared/r-setup.R`, `figures/plot.png`, any `read_csv("data/raw.csv")`) resolves from the author's mental anchor of "paths are relative to where the script lives."
- The `if (length(.file) > 0)` guard makes the preamble safe when the script is sourced interactively (from RStudio, from another script, or via `source()` in a REPL) — in those contexts `--file=` is not injected, so the `setwd()` is skipped and the caller's CWD is preserved.

## Prevention

1. **Test the exact documented invocation, not a wrapper around it.** `(cd "$dir" && Rscript simulation.R)` and `Rscript papers/<method>/NN-*/simulation.R` look similar but are semantically different the moment the script uses any relative path. In CI and in project verification scripts, run the literal command from the user-facing docs — do not abstract it into a helper that pre-`cd`'s.

2. **Use the chdir preamble whenever a script has `source(...)` or relative-path file I/O and is meant to be invokable from multiple directories.** Copy it from an existing `simulation.R`; do not reinvent it every time. `CLAUDE.md` codifies this as a convention for this repo.

3. **Alternatives and their tradeoffs:**

   | Approach | Pros | Cons |
   |---|---|---|
   | `commandArgs(--file=)` preamble (this fix) | Base R, no dependencies, 4 lines, safe in interactive contexts | Must be copy-pasted into each new script |
   | `here::here()` package | Intuitive API; anchors to project root via `.here` or `DESCRIPTION`; idiomatic in tidyverse projects | Extra dependency; behavior depends on where `.here` sentinel is placed |
   | `withr::with_dir()` | Scoped CWD change, auto-restored on exit | Extra dependency; awkward to wrap a whole top-level script |
   | Just `cd` before invoking | Zero code change | Shifts burden to every caller; documentation becomes fragile |

   For a dependency-minimal repo where scripts are small and standalone, the 4-line base-R preamble is the right fit. For long-lived tidyverse projects with many scripts, `here::here()` is worth considering.

4. **Structurally align "how we test" with "how we document."** The root cause of this bug surviving a full verification pass was that the verification script used a subtly different invocation than the one documented. If the docs say `Rscript papers/<method>/NN-*/simulation.R`, the verification script should run that literal command from the repo root — not a subshell wrapper, not a Makefile that first `cd`'s. Otherwise the test suite guarantees one thing and the user experiences another.

## Related Issues

- `CLAUDE.md` lines ~55–62 — the repo's authoritative R conventions now mandate the preamble and describe the `figures/` handling that depends on it.
- `.claude/agents/r-coding-expert.md` — the subagent that writes new `simulation.R` files has been instructed to copy the preamble verbatim from any existing paper and never reinvent it.
- `papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R` — canonical reference implementation; lines immediately after the file header.
- ce:review finding **COR-01** (correctness reviewer, run `20260421-175010-3b900f41`), which surfaced the bug independently of the author's own verification pass.
- No prior `docs/solutions/` entries existed on this problem (this is the repo's first learning).

## Postscript — 2026-04-22 path-depth update

On 2026-04-22 the `papers/NN-*/` flat layout was reorganized into `papers/<method>/NN-*/` methodology buckets (commit `b19d313`). The `commandArgs(--file=)` preamble itself is location-independent and survived the move byte-identical. Only the one line below it changed: `source("../../shared/r-setup.R")` became `source("../../../shared/r-setup.R")` so the script still reaches `shared/r-setup.R` from its new three-levels-deep location. The historical **Before / After** code block above is preserved verbatim because it documents the fix as it landed on 2026-04-21 (commit `f2b16cd`) — read it as "how the preamble looked when it was introduced", not as the current canonical code. The current canonical code is at `papers/did/01-ghanem-santanna-wuthrich-selection-parallel-trends/simulation.R`.
