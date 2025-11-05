#' Outbreak probabilities by traveller type
#'
#' @description
#' Scenario grid of outbreak probabilities for **travellers** and **workers**,
#' indexed by basic reproduction number (R0), vaccine effectiveness (VE),
#' and vaccine coverage. Values are probabilities in \[0, 1\].
#'
#' @format A tibble with one row per scenario:
#' \describe{
#'   \item{r0}{Basic reproduction number used for the scenario.}
#'   \item{ve}{Vaccine effectiveness (0–1).}
#'   \item{coverage}{Population vaccine coverage (0–1).}
#'   \item{traveller_ob_prob}{Outbreak probability for the traveller pathway.}
#'   \item{worker_ob_prob}{Outbreak probability for the worker pathway.}
#' }
#'
#' @details
#' Scenarios form a regular grid over R0, VE and coverage. Probabilities are
#' derived from the branching-process model used in the assignment brief.
#'
#' @source `data-raw/ob_probs_travellers.csv`
#'
#' @seealso [ob_timings_summary], [ob_summary]
#'
#' @examples
#' data(ob_probs_travellers)
#' # quick peek
#' head(ob_probs_travellers)
"ob_probs_travellers"

#' Outbreak timing summary
#'
#' @description
#' Summary of expected time to an outbreak under the same scenario grid,
#' reported as median days and 95th-percentile days.
#'
#' @format A tibble with one row per scenario:
#' \describe{
#'   \item{r0}{Basic reproduction number.}
#'   \item{ve}{Vaccine effectiveness (0–1).}
#'   \item{coverage}{Vaccine coverage (0–1).}
#'   \item{chance50}{Median days to outbreak.}
#'   \item{chance95}{95th-percentile days to outbreak.}
#' }
#'
#' @details
#' Larger values of \code{chance50} and \code{chance95} indicate slower expected
#' outbreak timing (i.e. more time until an outbreak occurs).
#'
#' @source `data-raw/ob_timings_summary.csv`
#'
#' @seealso [ob_probs_travellers], [ob_summary]
#'
#' @examples
#' data(ob_timings_summary)
#' # typical ranges by R0
#' dplyr::group_by(ob_timings_summary, r0) |>
#'   dplyr::summarise(med = median(chance50), p95 = median(chance95))
"ob_timings_summary"

#' Combined outbreak summary (probabilities + timings)
#'
#' @description
#' Convenience dataset that joins probabilities and timing measures on the
#' common scenario grid. Handy for plotting and Shiny filtering without
#' performing a join at runtime.
#'
#' @format A tibble with columns from both sources:
#' \describe{
#'   \item{r0}{Basic reproduction number.}
#'   \item{ve}{Vaccine effectiveness (0–1).}
#'   \item{coverage}{Vaccine coverage (0–1).}
#'   \item{traveller_ob_prob}{Outbreak probability for travellers.}
#'   \item{worker_ob_prob}{Outbreak probability for workers.}
#'   \item{chance50}{Median days to outbreak.}
#'   \item{chance95}{95th-percentile days to outbreak.}
#' }
#'
#' @details
#' Created in \code{data-raw/build-quarrisk-data.R} by an inner join of
#' \code{ob_probs_travellers} and \code{ob_timings_summary}.
#'
#' @seealso [ob_probs_travellers], [ob_timings_summary]
#'
#' @examples
#' data(ob_summary)
#' dplyr::glimpse(ob_summary)
"ob_summary"

