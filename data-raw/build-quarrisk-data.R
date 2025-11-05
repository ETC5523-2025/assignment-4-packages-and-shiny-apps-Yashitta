## Code to prepare `ob_probs_travellers`, `ob_timings_summary`, `ob_summary` datasets
## (quarrisk package)

# ---- Libraries ----
library(tidyverse)
library(janitor)
library(usethis)

# ---- Read tidy inputs from data-raw/ ----
dr <- function(...) file.path("data-raw", ...)

ob_probs_travellers <- readr::read_csv(dr("ob_probs_travellers.csv"),
                                       show_col_types = FALSE) |>
  janitor::clean_names() |>
  mutate(across(where(is.character), ~ trimws(.x)))

ob_timings_summary <- readr::read_csv(dr("ob_timings_summary.csv"),
                                      show_col_types = FALSE) |>
  janitor::clean_names() |>
  mutate(across(where(is.character), ~ trimws(.x)))

# ---- Quick checks ----
required_probs   <- c("r0", "ve", "coverage", "traveller_ob_prob", "worker_ob_prob")
required_timings <- c("r0", "ve", "coverage", "chance50", "chance95")

stopifnot(all(required_probs   %in% names(ob_probs_travellers)))
stopifnot(all(required_timings %in% names(ob_timings_summary)))

# ---- Dataset 1: Outbreak probabilities ----
# `ob_probs_travellers` already tidy.

# ---- Dataset 2: Timing summaries ----
# `ob_timings_summary` already tidy.

# ---- Dataset 3 : One joined summary table ----
ob_summary <- ob_probs_travellers |>
  select(r0, ve, coverage, traveller_ob_prob, worker_ob_prob) |>
  left_join(
    ob_timings_summary |>
      select(r0, ve, coverage, chance50, chance95),
    by = c("r0", "ve", "coverage")
  ) |>
  arrange(r0, ve, coverage)

# ---- Save all datasets to data/ ----
usethis::use_data(
  ob_probs_travellers,
  ob_timings_summary,
  ob_summary,
  overwrite = TRUE
)

message("Saved: ", paste(list.files('data', '\\.rda$', full.names = FALSE), collapse = ', '))
