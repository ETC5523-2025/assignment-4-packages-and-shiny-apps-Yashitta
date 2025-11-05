#' Slice the scenario grid (nearest R0 / VE / coverage)
#'
#' @description
#' Convenience helper for `quarrisk` datasets. Given a desired basic
#' reproduction number (R0), vaccine effectiveness (VE), and vaccine coverage,
#' this finds the **nearest** scenario on the model grid (e.g. [ob_summary])
#' and returns that row as a tibble.
#'
#' @param data A tibble/data.frame containing columns `r0`, `ve`, `coverage`
#'   (typically [ob_summary] or one of its filtered variants).
#' @param r0 Numeric, desired basic reproduction number.
#' @param ve Numeric in \[0, 1\], desired vaccine effectiveness.
#' @param coverage Numeric in \[0, 1\], desired vaccine coverage.
#'
#' @return A 1-row tibble with the matched scenario, including:
#' \describe{
#'   \item{r0}{Nearest R0 on the grid.}
#'   \item{ve}{Nearest VE on the grid.}
#'   \item{coverage}{Nearest coverage on the grid.}
#'   \item{traveller_ob_prob}{Outbreak probability (traveller pathway).}
#'   \item{worker_ob_prob}{Outbreak probability (worker pathway).}
#'   \item{chance50}{Median days to outbreak.}
#'   \item{chance95}{95th-percentile days to outbreak.}
#' }
#'
#' @details
#' “Nearest” is computed independently along each axis (R0, VE, coverage) by
#' choosing the grid value with minimum absolute difference to the requested
#' value. This mirrors how sliders in the Shiny app snap to the nearest
#' available scenario.
#'
#' @seealso [ob_summary], [ob_probs_travellers], [ob_timings_summary]
#'
#' @export
#' @examples
#' \dontrun{
#'   data(ob_summary)
#'   slice_scenario(ob_summary, r0 = 2, ve = 0.80, coverage = 0.80)
#' }
slice_scenario <- function(data, r0, ve, coverage) {
  stopifnot(all(c("r0", "ve", "coverage") %in% names(data)))
  pick <- function(v, pool) pool[which.min(abs(pool - v))]
  r0_ <- pick(r0, unique(data$r0))
  ve_ <- pick(ve, unique(data$ve))
  cv_ <- pick(coverage, unique(data$coverage))
  dplyr::as_tibble(subset(data, r0 == r0_ & ve == ve_ & coverage == cv_))
}

