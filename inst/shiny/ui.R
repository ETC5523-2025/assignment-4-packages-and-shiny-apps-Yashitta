shinydashboard::dashboardPage(
  skin = "red",

  #### Header ---------------------------------------------------------------
  shinydashboard::dashboardHeader(
    title = "quarrisk",
    titleWidth = 260
  ),

  #### Sidebar --------------------------------------------------------------
  shinydashboard::dashboardSidebar(
    width = 260,
    div(style = "padding: 12px;",
        div(style="font-weight:600; margin-bottom:6px; color:#fff; opacity:.9;", "Quick actions"),
        actionButton("reset_inputs", "Reset sliders", width = "100%"),
        tags$div(style="height:8px;"),
        actionButton("preset_308", "Use example: R0=3, VE=0, Cov=0.8", width = "100%"),
        tags$hr(style="border-color:rgba(255,255,255,.2);"),
        p(style="color:#cfd8dc; font-size:12px; line-height:1.35; margin:0;",
          "Tip: change R0, VE and Coverage on the left, then compare heatmaps in Risk Explorer.")
    )
  ),

  #### Body -----------------------------------------------------------------
  shinydashboard::dashboardBody(
    # --- Styling ------------------
    tags$head(tags$style(HTML("
      /* Top bar + logo */
      .skin-red .main-header .navbar,
      .skin-red .main-header .logo { background-color:#c20e05; }
      .skin-red .main-header .navbar .sidebar-toggle:hover { background-color:#a30c04; }
      /* Page background */
      .content-wrapper, .right-side { background-color:#f7f5f2; }
      /* Box styling */
    .box { border-radius:10px; overflow:hidden;
    }
    /* Top tabs (Overview / Risk Explorer / Timing Summary):
          rounded, red active, small gap */
    .nav-pills > li > a {
      border-radius:12px;
      padding:8px 14px;
      margin-right:8px;
      background:rgba(0,0,0,0.04);
    }
    .nav-pills > li.active > a,
    .nav-pills > li.active > a:focus,
    .nav-pills > li.active > a:hover {
      background:#c20e05;
      color:#fff !important;
    }
    .nav-pills { margin: 6px 0 0 6px; }
    .page-card .col-sm-3{ padding-left: 6px; }
    /* darker red rim */
    .nav-pills > li.active > a,
    .nav-pills > li.active > a:focus,
    .nav-pills > li.active > a:hover{
      border-color:#8f0a04 !important;
      box-shadow:0 0 0 2px #8f0a04 inset !important;
    }
    .tab-content { margin-top:10px;
    }
    /* Page card border */
    .page-card{
      background: #f7f5f2;
      border: 1px solid #e3e3e3;
      border-radius: 14px;
      padding: 14px;
    }
    /* Box headers */
    .box > .box-header,
    .box.box-primary > .box-header,
    .box.box-warning > .box-header,
    .box.box-info > .box-header,
    .box.box-success > .box-header,
    .box.box-danger > .box-header,
    .box.box-solid > .box-header{
      background-color:#c20e05 !important;
      color:#fff !important;
      border:0 !important;
    }
    /* Box borders (plots, tables) */
    .box,
    .box.box-primary,
    .box.box-warning,
    .box.box-info,
    .box.box-success,
    .box.box-danger{
      border: 1px solid #efc2bd;
      border-radius: 12px;
    }
    .box,
    .box.box-primary,
    .box.box-warning,
    .box.box-info,
    .box.box-success,
    .box.box-danger,
    .box.box-solid,
    .box.box-solid.box-primary,
    .box.box-solid.box-warning,
    .box.box-solid.box-info,
    .box.box-solid.box-success,
    .box.box-solid.box-danger{
      border: 1px solid #efc2bd !important;
      border-radius: 12px !important;
    }
    .box.box-primary,
    .box.box-warning,
    .box.box-info,
    .box.box-success,
    .box.box-danger{
      border-top-color: #efc2bd !important;
    }
    .plot-note { font-size:14px; color:#555; margin-top:8px; line-height:1.45; }
        table.dataTable tbody td { vertical-align: middle; }
      .dt-center { text-align:center; }
      .dataTables_wrapper .dataTables_paginate .paginate_button {
      padding: 0.2em 0.6em; }
      /* Sidebar */
      .main-sidebar .sidebar {
      padding: 16px 18px 20px 18px !important;
      }
      /* Sidebar Buttons */
      .main-sidebar .sidebar .btn,
      .main-sidebar .sidebar .action-button {
      display: block;
      width: 100%;
      max-width: 210px;
      margin: 8px auto;
      text-align: center;
      border-radius: 10px;
      }
      /* Body */
      .content-wrapper, .right-side { padding-left: 8px; }
      /* Separator line on the sidebar */
      .main-sidebar { box-shadow: inset -1px 0 0 #e3e3e3; }"))),

    # --- Top tabs across the page -----------------------------------------
    div(class = "page-card",
        tabsetPanel(id = "tabs_top", type = "pills",

                # ============================== TAB 1: OVERVIEW ======================
                tabPanel(
                  title = "Overview",

                  fluidRow(
                    # LEFT: value boxes + controls + explainer
                    column(
                      width = 3,

                      # four coloured value boxes
                      div(style = "margin-bottom:12px;", shinydashboard::valueBoxOutput("vb_r0",         width = 12)),
                      div(style = "margin-bottom:12px;", shinydashboard::valueBoxOutput("vb_ve",         width = 12)),
                      div(style = "margin-bottom:12px;", shinydashboard::valueBoxOutput("vb_coverage",   width = 12)),
                      div(style = "margin-bottom:12px;", shinydashboard::valueBoxOutput("vb_median_day", width = 12)),

                      shinydashboard::box(
                        title = "Scenario",
                        status = "primary", solidHeader = TRUE, width = 12,
                        sliderInput("r0", "R0", min = 1, max = 10, value = 2, step = 0.5),
                        sliderInput("ve", "Vaccine effectiveness (VE)", min = 0, max = 1, value = 0.80, step = 0.05),
                        sliderInput("coverage", "Coverage", min = 0, max = 1, value = 0.80, step = 0.05),
                        helpText("We snap to the nearest grid row in the packaged data.")
                      ),

                      shinydashboard::box(
                        title = "About these metrics",
                        status = "info", solidHeader = TRUE, collapsible = TRUE, width = 12,
                        HTML("
          <div style='font-size: 14px; line-height: 1.6;'>
            <p><strong>traveller_ob_prob / worker_ob_prob</strong> are the outbreak probabilities for
            traveller and worker seeding under the chosen scenario.</p>
            <p><strong>chance50 / chance95</strong> give the timing summaries (days until outbreak), at
            50% and 95% chance respectively, conditional on an outbreak.</p>
          </div>
        ")
                      )
                    ),

                    # RIGHT: plot + slice table
                    column(
                      width = 9,
                      shinydashboard::box(
                        title = "Outbreak probability at nearest scenario",
                        status = "primary", solidHeader = TRUE, width = 12,
                        plotly::plotlyOutput("prob_line_nearest", height = "420px"),
                        div(class = "plot-note", HTML("
                        <p><strong>What this shows:</strong> The outbreak probability under the
                        <em>nearest</em> scenario to your sliders, compared for two seeding pathways.</p>
                        <ul>
                        <li><strong>Bars:</strong> Probability that an outbreak takes off when seeded by a <em>traveller</em> vs a <em>worker</em>.</li>
                        <li><strong>Heights:</strong> Taller bar = higher risk under the current parameters.</li>
                        <li><strong>Reading change:</strong> Adjust R0, VE, or coverage on the left and watch which pathway is more dominant.</li>
                        <li><strong>Why 'nearest':</strong> The underlying data is on a grid; we snap your chosen values to the closest grid point to ensure a matched record.</li>
                        </ul>"))
                      ),

                      shinydashboard::box(
                        title = "Nearest scenario row",
                        status = "warning", solidHeader = TRUE, width = 12,
                        DT::dataTableOutput("slice_table"),
                        div(class = "plot-note", HTML("
                        <p><strong>What this table is:</strong> The exact grid row used for the chart above.
                        It lists parameters and outcomes for that scenario.</p>
                        <ul>
                        <li><code>r0</code>, <code>ve</code>, <code>coverage</code>: parameters of the matched grid point (nearest to your sliders).</li>
                        <li><code>traveller_ob_prob</code> / <code>worker_ob_prob</code>: outbreak probabilities for each seeding pathway.</li>
                        <li><code>chance50</code>, <code>chance95</code>: median and tail (95th percentile) days until outbreak, conditional on an outbreak occurring.</li>
                        </ul>
                        <p>Tip: sort columns to quickly spot parameter settings that produce very low or very high risk.</p>"))
                      )
                    )
                  )
                  ),

      # ========================== TAB 2: RISK EXPLORER =====================
      tabPanel(
        title = "Risk Explorer",

        fluidRow(
          # Controls
          column(
            width = 3,
            shinydashboard::box(
              title = "Filters",
              status = "primary", solidHeader = TRUE, width = NULL,
              sliderInput("risk_r0", "R0 (fix for plots)", min = 1, max = 10, value = 2, step = 0.5),
              sliderInput("risk_cov", "Coverage (fix for VE scan)", min = 0, max = 1, value = 0.8, step = 0.05),
              sliderInput("risk_ve", "VE (fix for heatmap slices)", min = 0, max = 1, value = 0.8, step = 0.05),
              helpText("Use these to drive the plots on the right.")
            ),

            shinydashboard::box(
              title = "Reading guide",
              status = "info", solidHeader = TRUE, collapsible = TRUE, width = NULL,
              HTML("
                <ul style='font-size: 13px; line-height:1.6;'>
                  <li><strong>Probability vs VE:</strong> Fix R0 and coverage, sweep VE.</li>
                  <li><strong>Heatmap:</strong> Probability across R0 × coverage at fixed VE.</li>
                </ul>
              ")
            )
          ),

          # Plots
          column(
            width = 9,
            shinydashboard::box(
              title = "Outbreak probability vs VE (fixed R0 & coverage)",
              status = "primary", solidHeader = TRUE, width = NULL,
              plotly::plotlyOutput("prob_vs_ve", height = "420px"),
              div(class = "plot-note", HTML("
              <p><strong>What this shows:</strong> How outbreak probability changes as
              <em>vaccine effectiveness (VE)</em> increases, holding R0 and coverage fixed (from the left-hand filters).</p>
              <ul>
              <li><strong>Lines:</strong> Separate curves for the <em>traveller</em> and <em>worker</em> pathways.</li>
              <li><strong>Interpretation:</strong> A downward slope means improved VE is reducing outbreak risk for that pathway.</li>
              <li><strong>Comparing pathways:</strong> The pathway with the higher curve is the risk driver at those settings.</li>
              <li><strong>Step/kink effects:</strong> Small steps can appear due to the discrete grid of scenarios in the dataset.</li>
              </ul>"))
            ),
            shinydashboard::box(
              title = "Outbreak probability heatmap (R0 × coverage at fixed VE)",
              status = "primary", solidHeader = TRUE, width = NULL,
              plotly::plotlyOutput("risk_heatmap", height = "520px"),
              div(class = "plot-note", HTML("
              <p><strong>What this shows:</strong> Outbreak probability across combinations of
              <em>R0</em> (x-axis) and <em>coverage</em> (y-axis) at the fixed VE you selected.</p>
              <ul>
              <li><strong>Colours:</strong> Darker red = higher probability (we plot the maximum of the two pathways).</li>
              <li><strong>Low-risk zone:</strong> Look for lighter cells—typically higher coverage and/or lower R0.</li>
              <li><strong>Use it to plan:</strong> Move between VE settings (left filters) to see how much extra coverage is needed to keep risk light.</li>
              </ul>"))
            )
          )
        )
        ),

      # ========================= TAB 3: TIMING SUMMARY =====================
      tabPanel(
        title = "Timing Summary",

        fluidRow(
          column(
            width = 12,
            h2("Timing summaries (days until outbreak)"),
            p(style = "font-size: 15px; color: #666; margin-bottom: 10px;",
              "Summaries from ", strong("ob_timings_summary"),
              " joined to probabilities. 95% refers to tail timing; the table also reports medians.")
          )
        ),

        fluidRow(
          column(
            width = 12,
            shinydashboard::box(
              title = "Tail timing (chance95)", status = "primary", solidHeader = TRUE, width = 12,
              plotly::plotlyOutput("timing_tail_plot", height = "420px"),
              div(class = "plot-note", HTML("
              <p><strong>What this shows:</strong> The <em>95th percentile</em> of days until outbreak
              (i.e., a conservative/late-onset scenario) as R0 changes, for your current VE and coverage.</p>
              <ul>
              <li><strong>Lower points:</strong> The worst-case outbreak arrives sooner—this indicates less time to respond.</li>
              <li><strong>Higher points:</strong> More breathing room before an outbreak becomes likely (conditional on an outbreak happening).</li>
              <li><strong>Reading change:</strong> Increase VE or coverage (Overview) and re-visit here to see if tail timing improves.</li>
              </ul>"))
            )
          )
        ),

        # --- Timing table ---
        fluidRow(
          shinydashboard::box(
            title = "Timing table",
            status = "warning", solidHeader = TRUE, width = 12,
            DT::dataTableOutput("timing_table"),
            div(class = "plot-note", HTML("
            <p><strong>What this table is:</strong> The full parameter grid with timing summaries.</p>
            <ul>
            <li><code>chance50</code>: median days until outbreak (conditional on outbreak).</li>
            <li><code>chance95</code>: tail (95th percentile) days—useful for planning under cautious assumptions.</li>
            <li><strong>How to use:</strong> Sort by columns to locate regimes that give both low probability and longer lead-times.</li>
            </ul>"))
          )
         )
        )
      )
    )
  )
)
