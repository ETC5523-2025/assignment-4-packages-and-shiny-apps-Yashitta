#' Launch the quarrisk Interactive Dashboard
#'
#' @description
#' Launches an interactive Shiny dashboard for exploring outbreak risk scenarios
#' using the packaged datasets \code{ob_probs_travellers}, \code{ob_timings_summary},
#' and the joined \code{ob_summary}. The app includes:
#' \itemize{
#'   \item \strong{Overview:} Headline metrics for the nearest scenario
#'   \item \strong{Risk vs VE:} Traveller/worker outbreak probability across VE
#'   \item \strong{Timing:} Median / 95th percentile days-to-outbreak summaries
#' }
#'
#' @param ... Passed to \code{\link[shiny]{runApp}} (e.g., \code{port}, \code{host},
#'   \code{launch.browser}).
#'
#' @return No return value; called for side effects (starts the app).
#'
#' @seealso [ob_summary], [ob_probs_travellers], [ob_timings_summary]
#'
#' @examples
#' \dontrun{
#'   # Launch the dashboard (default browser)
#'   run_app()
#'
#'   # Launch on a specific port
#'   run_app(port = 3838)
#'
#'   # Launch without opening the browser automatically
#'   run_app(launch.browser = FALSE)
#' }
#'
#' @importFrom shiny runApp
#' @export
run_app <- function(...) {
  # Required runtime packages for the app
  required_pkgs <- c("shiny", "ggplot2", "bslib")
  missing_pkgs <- required_pkgs[!vapply(required_pkgs, requireNamespace, logical(1), quietly = TRUE)]

  if (length(missing_pkgs)) {
    stop(
      "These packages are required to run the app but are not installed:\n  ",
      paste(missing_pkgs, collapse = ", "), "\n\n",
      "Install with:\n  install.packages(c('",
      paste(missing_pkgs, collapse = "', '"), "'))",
      call. = FALSE
    )
  }

  # Locate the bundled app directory
  app_dir <- system.file("shiny", package = "quarrisk")
  if (app_dir == "") {
    stop("Could not find Shiny app directory. Try reinstalling `quarrisk`.", call. = FALSE)
  }

  shiny::runApp(app_dir, display.mode = "normal", ...)
}
