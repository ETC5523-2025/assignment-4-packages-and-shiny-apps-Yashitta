#' Plot outbreak probability vs vaccine effectiveness (VE)
#'
#' @description
#' For a given basic reproduction number (R0) and vaccine coverage, this
#' function plots the outbreak probability against vaccine effectiveness (VE)
#' using the \code{ob_summary} grid. Both traveller and worker pathways are
#' shown for comparison.
#'
#' @param data Tibble with columns \code{r0}, \code{ve}, \code{coverage},
#'   \code{traveller_ob_prob}, \code{worker_ob_prob}. Defaults to
#'   \code{quarrisk::ob_summary}.
#' @param r0 Numeric, target basic reproduction number.
#' @param coverage Numeric in \[0, 1\], target vaccine coverage.
#' @param show_points Logical; if \code{TRUE}, also draw points on the lines.
#'
#' @return A \pkg{ggplot2} object showing outbreak probability vs VE for the
#'   specified \code{r0} and \code{coverage}.
#'
#' @details
#' The function filters the scenario grid to rows with the requested
#' \code{r0} and \code{coverage} (exact matches on the grid), then plots both
#' traveller and worker outbreak probabilities as a function of VE.
#'
#' @examples
#' \dontrun{
#'   # Basic usage
#'   plot_risk_vs_ve(r0 = 2, coverage = 0.8)
#'
#'   # With points
#'   plot_risk_vs_ve(r0 = 3, coverage = 0.6, show_points = TRUE)
#' }
#'
#' @seealso [slice_scenario], [ob_summary]
#'
#' @export
plot_risk_vs_ve <- function(data = quarrisk::ob_summary,
                            r0,
                            coverage,
                            show_points = FALSE) {

  stopifnot(all(c("r0","ve","coverage",
                  "traveller_ob_prob","worker_ob_prob") %in% names(data)))

  d <- subset(data, r0 == r0 & coverage == coverage)
  if (nrow(d) == 0) {
    stop("No rows match the requested r0 and coverage on the grid.", call. = FALSE)
  }

  # long format for a simple legend
  dd <- tidyr::pivot_longer(
    d,
    cols   = c(traveller_ob_prob, worker_ob_prob),
    names_to  = "pathway",
    values_to = "prob"
  )

  p <- ggplot2::ggplot(dd, ggplot2::aes(x = ve, y = prob, linetype = pathway)) +
    ggplot2::geom_line(linewidth = 0.9) +
    { if (show_points) ggplot2::geom_point() else ggplot2::geom_blank() } +
    ggplot2::scale_linetype_manual(values = c("solid", "dashed")) +
    ggplot2::labs(
      x = "Vaccine effectiveness (VE)",
      y = "Outbreak probability",
      linetype = "Pathway",
      subtitle = sprintf("R0 = %.1f, coverage = %.2f", r0, coverage)
    ) +
    ggplot2::theme_minimal()

  p
}
