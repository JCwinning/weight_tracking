#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#pak::pak(c('shinyalert','shinyjs','shinydashboard','shinydashboardPlus','shinyWidgets','RCurl'))

library(shiny)
library(tidyverse)
library(readxl)
library(plotly)
library(anytime)
library(bslib)
library(DT)
library(rsconnect)
library(shinyjs)
library(ellmer)

# Source AI configuration to get provider choices
source("ai_config.R")
# Source language configuration
source("language.R")


# Define UI for application that draws a histogram
ui <- function(request) {
  fluidPage(
    # Language switcher in top-right corner
    div(
      style = "position: absolute; top: 10px; right: 10px; z-index: 1000;",
      tags$div(class = "btn-group", role = "group",
        actionButton("lang_en", "EN", class = "btn-secondary btn-sm",
                    style = "margin-right: 5px;"),
        actionButton("lang_zh", "中文", class = "btn-secondary btn-sm")
      )
    ),

    # Application title
    titlePanel(
      title = span(img(src = "logo.png", height = 40), "Weight tracking"),
      # website tab content
      tags$head(
        tags$link(rel = "icon", type = "image/png", href = "logo.png"),
        tags$title("Weight tracking"),
        tags$style(HTML("
          .markdown-content h1 {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 0.75rem;
            color: #1e293b;
          }
          .markdown-content h2 {
            font-size: 1.1rem;
            font-weight: 600;
            margin-top: 1rem;
            margin-bottom: 0.5rem;
            color: #334155;
          }
          .markdown-content h3 {
            font-size: 1rem;
            font-weight: 600;
            margin-top: 0.75rem;
            margin-bottom: 0.25rem;
            color: #475569;
          }
          .markdown-content p {
            margin-bottom: 0.75rem;
            line-height: 1.6;
          }
          .markdown-content ul {
            margin-bottom: 0.75rem;
            padding-left: 1.5rem;
          }
          .markdown-content li {
            margin-bottom: 0.25rem;
          }
          .markdown-content strong {
            font-weight: 600;
            color: #1e293b;
          }
          .markdown-content em {
            font-style: italic;
          }
          .markdown-content hr {
            border-top: 1px solid #e2e8f0;
            margin: 1.5rem 0;
          }
          .markdown-content code {
            background-color: #f1f5f9;
            padding: 0.125rem 0.25rem;
            border-radius: 0.25rem;
            font-size: 0.875rem;
          }
          .markdown-content blockquote {
            border-left: 4px solid #3b82f6;
            padding-left: 1rem;
            margin: 1rem 0;
            color: #64748b;
            font-style: italic;
          }
        "))
      )
    ),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
      sidebarPanel(
        p(textOutput("last_input_date_label")),
        verbatimTextOutput("text"),
        p(textOutput("last_date_label")),
        verbatimTextOutput("text_most_date"),
        p(textOutput("current_weight_label")),
        verbatimTextOutput("text2"),
        selectInput(
          "type",
          textOutput("choose_unit_label"),
          choices = c("kg,cm", "pounds,inches")
        ),
        numericInput("weight_input", textOutput("your_weight_label"), 84),
        numericInput("height_input", textOutput("your_height_label"), 180),
        p(textOutput("your_bmi_label")),
        verbatimTextOutput("value"),
  
        p(textOutput("bmi_underweight_label")),
        p(textOutput("bmi_normal_label")),
        p(textOutput("bmi_overweight_label")),

        downloadButton("downloadData", textOutput("download_label")),
        br(),

        p(textOutput("upload_new_data_label")),
        fileInput("upload", NULL, accept = c(".xlsx")),
        #,actionButton("go", "write uploaded data into server")

        # tags$a(
        #   href = "https://tduan.shinyapps.io/weightshiny/",
        #   textOutput("bmi_tracking_shiny_label")
        # ),

        bookmarkButton(),

        br(),
        hr(),
        h5(textOutput("ai_config_label")),
        selectInput(
          "ai_provider",
          textOutput("ai_provider_label"),
          choices = setNames(get_available_providers(), get_available_providers()),
          selected = get_current_provider_name()
        ),
        textInput(
          "ai_provider_url",
          textOutput("ai_provider_url_label"),
          value = get_provider_url(),
          placeholder = textOutput("url_placeholder")
        ),
        selectInput(
          "ai_model",
          textOutput("ai_model_label"),
          choices = setNames(get_provider_models(), get_provider_models()),
          selected = get_provider_models()[1]
        ),
        passwordInput(
          "ai_api_key",
          textOutput("api_key_label"),
          #value = "",
          #placeholder = textOutput("api_key_placeholder")
        )
      ),

      # Show a plot of the generated distribution

      navset_card_underline(
        #title = "Visualizations",
        # Panel with plot ----
        nav_panel(
          br(),
          textOutput("plot_tab_label"),
          br(),
          plotlyOutput("linePlot"),
          br(),
          plotlyOutput("linePlot_bmi"),
          br(),
          br(),
          actionButton(
            "get_ai_suggestion",
            textOutput("get_ai_suggestion_label"),
            class = "btn-primary",
            icon = icon("robot")
          ),
          br(),
          br(),
          div(style = "font-size: 15pt;", uiOutput("ai_suggestion_output"))
        ),

        # Panel with ui ----
        nav_panel(textOutput("ui_tab_label"), verbatimTextOutput("ui_text")),

        # Panel with server ----
        nav_panel(textOutput("server_tab_label"), verbatimTextOutput("server_text")),

        # Panel with table ----
        nav_panel(textOutput("data_tab_label"), dataTableOutput('table'))
      )
    )
  )
}
