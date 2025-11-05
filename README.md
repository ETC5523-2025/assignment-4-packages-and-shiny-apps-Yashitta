
<!-- README.md is generated from README.Rmd. Please edit that file -->

# quarrisk

<!-- badges: start -->

[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
<!-- badges: end -->

## Overview

**quarrisk** provides an interactive Shiny dashboard and helper
functions to explore **quarantine outbreak risk** under different
assumptions about basic reproduction number (**R₀**), vaccine
effectiveness (**VE**), and vaccination **coverage**.

It ships three tidy datasets:

- `ob_probs_travellers` — outbreak probabilities by traveller/worker
  pathway  
- `ob_timings_summary` — median (50%) and tail (95%) days until
  outbreak  
- `ob_summary` — a joined grid of probabilities + timings across R₀ × VE
  × coverage

The dashboard has three tabs: **Overview**, **Risk Explorer**, and
**Timing Summary**.

## Features

- 📦 **Three curated datasets** covering probabilities and timing  
- 🧭 **Overview**: nearest-scenario readout + quick comparison of
  traveller vs worker risk  
- 📈 **Risk Explorer**: lines and heatmaps to see how risk changes with
  VE, R₀, and coverage  
- ⏱️ **Timing Summary**: median and tail time-to-outbreak profiles  
- 🧰 **Helpers**: `slice_scenario()` to grab scenarios;
  `plot_risk_vs_ve()` to plot VE curves  
- 🖥️ **One-line app launcher**: `run_app()`

## Installation

You can install the development version of quarrisk from
[GitHub](https://github.com/) with:

``` r

install.packages("remotes")
remotes::install_github("ETC5523-2025/assignment-4-packages-and-shiny-apps-Yashitta")
```

## Quick Start

``` r

library(quarrisk)
```

## Explore the datasets

``` r

data(ob_probs_travellers)
head(ob_probs_travellers)
data(ob_timings_summary)
head(ob_timings_summary)
data(ob_summary)
dplyr::glimpse(ob_summary)
```

### Launch interactive dashboard

``` r

run_app()
```

## Dashboard Views

- **Overview** – Shows the nearest scenario to your chosen **R₀ / VE /
  coverage**, value boxes, and a quick traveller vs worker probability
  comparison.

- **Risk Explorer** –

  - **Lines:** outbreak probability vs **VE** at fixed **R₀** &
    **coverage**
  - **Heatmap:** probability across **R₀ × coverage** at fixed **VE**

- **Timing Summary** – Median (**chance50**) and tail (**chance95**)
  days vs **coverage / R₀** for the selected **VE**.

## Example Analysis

Compute the gap between traveller and worker outbreak probabilities for
a given scenario grid:

    #> 
    #> Attaching package: 'dplyr'
    #> The following objects are masked from 'package:stats':
    #> 
    #>     filter, lag
    #> The following objects are masked from 'package:base':
    #> 
    #>     intersect, setdiff, setequal, union
    #> # A tibble: 6 × 6
    #>      r0    ve coverage traveller_ob_prob worker_ob_prob    gap
    #>   <dbl> <dbl>    <dbl>             <dbl>          <dbl>  <dbl>
    #> 1    10   0.5      0.1            0.0210          0.203 -0.182
    #> 2    10   0.5      0.2            0.0210          0.200 -0.179
    #> 3     9   0.5      0.1            0.0203          0.197 -0.177
    #> 4    10   0.5      0.3            0.0196          0.195 -0.176
    #> 5     9   0.5      0.2            0.0205          0.191 -0.171
    #> 6    10   0.6      0.1            0.0175          0.188 -0.171

## Available Datasets

- `ob_probs_travellers` — Tibble with columns: `r0`, `ve`, `coverage`,
  `traveller_ob_prob`, `worker_ob_prob`.
- `ob_timings_summary` — Tibble with columns: `r0`, `ve`, `coverage`,
  `chance50`, `chance95`.
- `ob_summary` — Join of the two above across the full scenario grid.

## Functions

- `run_app()` — Launch the Shiny dashboard.
- `slice_scenario(r0, ve, coverage)` — Return rows matching (or nearest
  to) a scenario.
- `plot_risk_vs_ve(r0, coverage, pathway = c("traveller_ob_prob","worker_ob_prob"))`
  — Line plot of outbreak probability vs VE at fixed **R₀** & coverage.

## Documentation

- Package repo:
  <https://github.com/ETC5523-2025/assignment-4-packages-and-shiny-apps-Yashitta.git>
