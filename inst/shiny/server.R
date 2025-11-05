library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(DT)
library(scales)
library(rlang)

# global plot style
theme_set(ggplot2::theme_bw(base_size = 14))

function(input, output, session) {

  # Load packaged datasets -------------------------------------------------
  data("ob_probs_travellers",  package = "quarrisk", envir = environment())
  data("ob_timings_summary",   package = "quarrisk", envir = environment())
  data("ob_summary",           package = "quarrisk", envir = environment())

  # Helpers ----------------------------------------------------------------

  # Numeric columns
  ob_summary <- ob_summary %>%
    dplyr::mutate(
      r0       = as.numeric(r0),
      ve       = as.numeric(ve),
      coverage = as.numeric(coverage),
      chance50 = as.numeric(chance50),
      chance95 = as.numeric(chance95)
    )

  r0_grid       <- sort(unique(ob_summary$r0))
  ve_grid       <- sort(unique(ob_summary$ve))
  coverage_grid <- sort(unique(ob_summary$coverage))
  nearest_to <- function(x, choices) choices[which.min(abs(choices - x))]

  # Palette for line/heatmap
  prob_palette <- c(
    "#fde725","#d0df36","#a5db49","#7ad35a","#54c568",
    "#34b679","#1f9e89","#24868e","#2b6c8e","#2c5182","#2a3359"
  )

  # Find nearest row in the scenario grid to (r0, ve, coverage)
  nearest_row <- function(df, r0_val, ve_val, cov_val) {
    df %>%
      mutate(
        dist2 = (.data$r0 - r0_val)^2 +
          (.data$ve - ve_val)^2 +
          (.data$coverage - cov_val)^2
      ) %>%
      arrange(.data$dist2) %>%
      slice(1) %>%
      select(-.data$dist2)
  }

  # Slice convenience
  slice_by <- function(df, r0_val = NULL, ve_val = NULL, cov_val = NULL) {
    out <- df
    if (!is.null(r0_val)) out <- dplyr::filter(out, .data$r0 == r0_val)
    if (!is.null(ve_val)) out <- dplyr::filter(out, .data$ve == ve_val)
    if (!is.null(cov_val)) out <- dplyr::filter(out, .data$coverage == cov_val)
    out
  }

  # =============================== TAB 1: OVERVIEW ========================

  # Reactive: nearest scenario row (from ob_summary)
  nearest_reactive <- reactive({
    nearest_row(ob_summary, input$r0, input$ve, input$coverage)
  })

  # Value boxes ------------------------------------------------------------
  output$vb_r0 <- renderValueBox({
    nv <- nearest_reactive(); req(nrow(nv) == 1)
    valueBox(nv$r0, "Nearest R0", icon = icon("wave-square"), color = "purple")
  })
  output$vb_ve <- renderValueBox({
    nv <- nearest_reactive(); req(nrow(nv) == 1)
    valueBox(percent(as.numeric(nv$ve), accuracy = 1), "Nearest VE",
             icon = icon("shield-virus"), color = "olive")
  })
  output$vb_coverage <- renderValueBox({
    nv <- nearest_reactive(); req(nrow(nv) == 1)
    valueBox(percent(as.numeric(nv$coverage), accuracy = 1), "Nearest Coverage",
             icon = icon("people-group"), color = "teal")
  })
  output$vb_median_day <- renderValueBox({
    nv <- nearest_reactive(); req(nrow(nv) == 1)
    valueBox(sprintf("%.2f", as.numeric(nv$chance50)), "Median days until outbreak",
             icon = icon("clock"), color = "yellow")
  })

  observeEvent(input$reset_inputs, ignoreInit = TRUE, {
    updateSliderInput(session, "r0", value = 2)
    updateSliderInput(session, "ve", value = 0.80)
    updateSliderInput(session, "coverage", value = 0.80)
  })
  observeEvent(input$preset_308, ignoreInit = TRUE, {
    updateSliderInput(session, "r0", value = 3)
    updateSliderInput(session, "ve", value = 0.00)
    updateSliderInput(session, "coverage", value = 0.80)
  })

  # Plot: probability at nearest scenario across traveller vs worker -------
  output$prob_line_nearest <- renderPlotly({
    nv <- nearest_reactive()

    prob_nearest_data <- tibble::tibble(
      type  = c("Traveller", "Worker"),
      prob  = c(nv$traveller_ob_prob, nv$worker_ob_prob)
    )

    gg <- ggplot(prob_nearest_data, aes(x = type, y = prob,
                                        text = paste0(type, ": ", scales::percent(prob, 0.1)))) +
      geom_segment(aes(xend = type, y = 0, yend = prob),
                   linewidth = 6, lineend = "round", color = "#c20e05") +
      geom_point(size = 9, shape = 21, fill = "#2c5182", color = "white", stroke = 2) +
      scale_y_continuous(labels = scales::percent,
                         limits = c(0, max(prob_nearest_data$prob) * 1.2)) +
      labs(x = NULL, y = "Outbreak probability") +
      theme_bw(base_size = 14) +
      theme(panel.grid.major.x = element_blank())

    ggplotly(gg, tooltip = "text")
  })

  # Table: exact nearest row --------------------------------------
  output$slice_table <- DT::renderDataTable({
    DT::datatable(
      nearest_reactive() %>%
        select(r0, ve, coverage, traveller_ob_prob, worker_ob_prob, chance50, chance95),
      rownames = FALSE,
      options = list(pageLength = 5, dom = "tip")
    ) %>%
      DT::formatPercentage(c("traveller_ob_prob","worker_ob_prob"), 1)
  })

  # ============================ TAB 2: RISK EXPLORER ======================

  # Plot: Probability vs VE
  output$prob_vs_ve <- renderPlotly({
    r0_sel  <- nearest_to(input$risk_r0,  r0_grid)
    cov_sel <- nearest_to(input$risk_cov, coverage_grid)

    ve_sweep_data <- ob_summary %>%
      dplyr::filter(r0 == r0_sel, coverage == cov_sel) %>%
      dplyr::select(ve, traveller_ob_prob, worker_ob_prob) %>%
      tidyr::pivot_longer(
        c(traveller_ob_prob, worker_ob_prob),
        names_to = "pathway", values_to = "prob"
      ) %>%
      dplyr::mutate(
        text = paste0("VE: ", scales::percent(ve, 1),
                      "<br>", pathway, ": ", scales::percent(prob, 0.1))
      ) %>%
      dplyr::arrange(ve)

    validate(need(nrow(ve_sweep_data) > 0, "No data for these R0/Coverage settings."))

    gg <- ggplot(ve_sweep_data, aes(x = ve, y = prob, linetype = pathway, group = pathway, text = text)) +
      geom_line(linewidth = 1.1, color = "#1f2937") +
      geom_point(size = 1.6, color = "#1f2937") +
      scale_x_continuous(labels = scales::percent) +
      scale_y_continuous(labels = scales::percent) +
      labs(x = "Vaccine effectiveness (VE)", y = "Outbreak probability", linetype = "Pathway") +
      theme_bw(base_size = 14)

    ggplotly(gg, tooltip = "text")
  })

  # Heatmap: probability across R0 × coverage
  heat_palette <- c("#fff5f5", "#fecaca", "#f87171", "#ef4444", "#b91c1c")

  output$risk_heatmap <- renderPlotly({
    ve_sel <- nearest_to(input$risk_ve, ve_grid)

    heatmap_data <- ob_summary %>%
      dplyr::filter(ve == ve_sel) %>%
      dplyr::mutate(
        prob  = pmax(traveller_ob_prob, worker_ob_prob, na.rm = TRUE),
        label = paste0(
          "R0: ", r0,
          "<br>Coverage: ", scales::percent(coverage, 1),
          "<br>Max prob: ", scales::percent(prob, 0.1)
        )
      )

    validate(need(nrow(heatmap_data) > 0, "No data for this VE."))

    gg <- ggplot(heatmap_data, aes(x = r0, y = coverage, fill = prob, text = label)) +
      geom_tile() +
      scale_y_continuous(labels = scales::percent) +
      scale_fill_gradientn(
        colors = heat_palette,
        labels = scales::percent,
        name   = "Probability",
        limits = range(heatmap_data$prob, na.rm = TRUE),
        oob    = scales::squish
      ) +
      labs(x = "R0", y = "Coverage")

    ggplotly(gg, tooltip = "text")
  })

  # ============================ TAB 3: TIMINGS ============================

  # Tail timing plot (chance95)
  output$timing_tail_plot <- renderPlotly({
    ve_sel  <- nearest_to(input$ve, ve_grid)
    cov_sel <- nearest_to(input$coverage, coverage_grid)

    tail_data <- ob_summary %>%
      dplyr::filter(ve == ve_sel, coverage == cov_sel) %>%
      dplyr::arrange(r0) %>%
      dplyr::mutate(
        text = paste0("R0: ", r0, "<br>95% days: ", round(chance95, 2))
      )

    validate(need(nrow(tail_data) > 0, "No data for these VE/Coverage settings."))

    gg <- ggplot(tail_data, aes(x = r0, y = chance95, text = text)) +
      geom_line(linewidth = 1.1, color = "#cc4778") +
      geom_point(size = 1.6, color = "#cc4778") +
      labs(x = "R0", y = "Tail days (chance95)")

    ggplotly(gg, tooltip = "text")
  })

  output$timing_table <- DT::renderDataTable({
    timing_table_data <- ob_summary %>%
      arrange(r0, ve, coverage) %>%
      transmute(
        r0,
        ve       = as.numeric(ve),
        coverage = as.numeric(coverage),
        chance50 = round(as.numeric(chance50), 2),
        chance95 = round(as.numeric(chance95), 2)
      )

    DT::datatable(
      timing_table_data,
      options = list(pageLength = 10, dom = "tip"),
      rownames = FALSE
    ) %>%
      DT::formatPercentage("ve", 0) %>%
      DT::formatPercentage("coverage", 0)
  })

}
