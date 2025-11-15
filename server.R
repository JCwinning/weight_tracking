#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(readxl)
library(plotly)
library(anytime)
library(openxlsx)
library(readr)
library(shinyalert)
library(shinyjs)
library(DT)
library(ellmer)
library(htmltools)
library(markdown)

library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(tidyverse)
library(rvest)
library(curl)
library(httr)
library(RCurl)

# Source AI configuration
source("ai_config.R")
# Source language configuration
source("language.R")

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # Initialize language to English
  current_lang <- reactiveVal("en")

  # Language switching event handlers
  observeEvent(input$lang_en, {
    current_lang("en")
    set_language("en")
  })

  observeEvent(input$lang_zh, {
    current_lang("zh")
    set_language("zh")
  })

  # Note: app_title is now hardcoded in ui.R to avoid textOutput() rendering issues
  # Reactive title could be added later if needed via JavaScript or other methods

  output$last_input_date_label <- renderText({
    get_text("last_input_date", current_lang())
  })

  output$last_date_label <- renderText({
    get_text("last_date", current_lang())
  })

  output$current_weight_label <- renderText({
    get_text("current_weight", current_lang())
  })

  output$choose_unit_label <- renderText({
    get_text("choose_unit", current_lang())
  })

  output$your_weight_label <- renderText({
    get_text("your_weight", current_lang())
  })

  output$your_height_label <- renderText({
    get_text("your_height", current_lang())
  })

  output$your_bmi_label <- renderText({
    get_text("your_bmi", current_lang())
  })

  output$bmi_underweight_label <- renderText({
    get_bmi_text("underweight", current_lang())
  })

  output$bmi_normal_label <- renderText({
    get_bmi_text("normal", current_lang())
  })

  output$bmi_overweight_label <- renderText({
    get_bmi_text("overweight", current_lang())
  })

  output$download_label <- renderText({
    get_text("download", current_lang())
  })

  output$upload_new_data_label <- renderText({
    get_text("upload_new_data", current_lang())
  })

  output$bmi_tracking_shiny_label <- renderText({
    get_text("bmi_tracking_shiny", current_lang())
  })

  output$ai_config_label <- renderText({
    get_text("ai_config", current_lang())
  })

  output$ai_provider_label <- renderText({
    get_text("ai_provider", current_lang())
  })

  output$ai_provider_url_label <- renderText({
    get_text("ai_provider_url", current_lang())
  })

  output$url_placeholder <- renderText({
    get_text("url_placeholder", current_lang())
  })

  output$ai_model_label <- renderText({
    get_text("ai_model", current_lang())
  })

  output$api_key_label <- renderText({
    get_text("api_key", current_lang())
  })

  output$api_key_placeholder <- renderText({
    get_text("api_key_placeholder", current_lang())
  })

  output$plot_tab_label <- renderText({
    get_text("plot_tab", current_lang())
  })

  output$ui_tab_label <- renderText({
    get_text("ui_tab", current_lang())
  })

  output$server_tab_label <- renderText({
    get_text("server_tab", current_lang())
  })

  output$data_tab_label <- renderText({
    get_text("data_tab", current_lang())
  })

  output$get_ai_suggestion_label <- renderText({
    get_text("get_ai_suggestion", current_lang())
  })

  output$ai_suggestion_initial_label <- renderText({
    get_text("ai_suggestion_initial", current_lang())
  })

  output$ai_getting_suggestion_label <- renderText({
    get_text("ai_getting_suggestion", current_lang())
  })

  output$ai_header_label <- renderText({
    get_text("ai_header", current_lang())
  })

  data001 <- reactivePoll(
    1000,
    session,
    # This function returns the time that 'weight.xlsx' was last modified
    checkFunc = function() {
      if (file.exists('weight.xlsx')) {
        file.info('weight.xlsx')$mtime[1]
      } else {
        ""
      }
    },
    # This function returns the content of 'weight.xlsx'
    valueFunc = function() {
      read_excel('weight.xlsx') %>%
        mutate(
          date = anydate(date),
          height_cm = 180,
          height_inches = height_cm * 0.3937,
          weight_pounds = weight * 2.2046,
          bmi = weight_pounds / (height_inches^2) * 703,
          good_bmi = 24
        )
    }
  )

  output$table = renderDataTable({
    data001() %>% arrange(desc(date))
  })

  # AI Provider Management
  observeEvent(input$ai_provider, {
    # Update provider URL
    new_url <- get_provider_url(input$ai_provider)
    updateTextInput(session, "ai_provider_url", value = new_url)

    # Update available models
    new_models <- get_provider_models(input$ai_provider)
    updateSelectInput(
      session,
      "ai_model",
      choices = setNames(new_models, new_models),
      selected = new_models[1]
    ) # First model as default
  })

  # Disable the AI provider URL input field (managed by app)
  disable("ai_provider_url")

  output$linePlot <- renderPlotly({
    # Configure x-axis formatting based on current language
    xaxis_config <- list(range = c((min(data001()$date)), (max(data001()$date))))

    if (current_lang() == "zh") {
      xaxis_config$tickformat <- "%Y年%-m月"
      xaxis_config$tickfont <- list(family = "Arial, sans-serif")
    }

    # Create hover text based on current language
    if (current_lang() == "zh") {
      # Chinese month names
      chinese_months <- c("1月", "2月", "3月", "4月", "5月", "6月",
                         "7月", "8月", "9月", "10月", "11月", "12月")

      hover_text <- paste0(
        format(data001()$date, "%Y年"),
        chinese_months[as.numeric(format(data001()$date, "%m"))],
        format(data001()$date, "%d日"),
        "<br>",
        get_text("chart_weight_legend", current_lang()),
        ": ",
        round(data001()$weight, 1),
        " kg"
      )
    } else {
      hover_text <- paste0(
        format(data001()$date, "%B %d, %Y"),
        "<br>",
        get_text("chart_weight_legend", current_lang()),
        ": ",
        round(data001()$weight, 1),
        " kg"
      )
    }

    plot_ly(
      data = data001(),
      x = ~date,
      y = ~weight,
      mode = 'lines',
      name = get_text("chart_weight_legend", current_lang()),
      text = hover_text,
      hoverinfo = 'text'
    ) %>%
      layout(
        title = list(
          text = get_text("chart_weight_title", current_lang()),
          font = list(size = 16)
        ),
        showlegend = TRUE,
        margin = list(t = 80, b = 50, l = 50, r = 50),
        xaxis = xaxis_config
      )
  })

  output$linePlot_bmi <- renderPlotly({
    # Configure x-axis formatting based on current language
    xaxis_config <- list(range = c((min(data001()$date)), (max(data001()$date))))

    if (current_lang() == "zh") {
      xaxis_config$tickformat <- "%Y年%-m月"
      xaxis_config$tickfont <- list(family = "Arial, sans-serif")
    }

    # Create hover text based on current language
    if (current_lang() == "zh") {
      # Chinese month names
      chinese_months <- c("1月", "2月", "3月", "4月", "5月", "6月",
                         "7月", "8月", "9月", "10月", "11月", "12月")

      hover_text <- paste0(
        format(data001()$date, "%Y年"),
        chinese_months[as.numeric(format(data001()$date, "%m"))],
        format(data001()$date, "%d日"),
        "<br>",
        get_text("chart_bmi_legend", current_lang()),
        ": ",
        round(data001()$bmi, 1)
      )
    } else {
      hover_text <- paste0(
        format(data001()$date, "%B %d, %Y"),
        "<br>",
        get_text("chart_bmi_legend", current_lang()),
        ": ",
        round(data001()$bmi, 1)
      )
    }

    plot_ly(
      data = data001(),
      x = ~date,
      y = ~bmi,
      name = get_text("chart_bmi_legend", current_lang()),
      type = 'scatter',
      mode = 'lines',
      text = hover_text,
      hoverinfo = 'text'
    ) %>%
      add_trace(y = ~good_bmi, name = get_text("chart_bmi_good", current_lang()), mode = 'lines+markers') %>%
      layout(
        title = list(
          text = get_text("chart_bmi_title", current_lang()),
          font = list(size = 16)
        ),
        showlegend = TRUE,
        margin = list(t = 80, b = 50, l = 50, r = 50),
        xaxis = xaxis_config
      )
  })

  output$text <- renderText({
    as.character(date(file.info('weight.xlsx')$ctime))
  })

  output$text_most_date <- renderText({
    as.character(tail(data001()$date, 1))
  })

  output$text2 <- renderText({
    tail(data001()$weight, 1)
  })

  output$ui_text <- renderText({
    read_file("ui.R")
  })

  output$server_text <- renderText({
    read_file("server.R")
  })

  output$value <- renderText({
    if (input$type == 'kg,cm') {
      round(input$weight_input / (input$height_input / 100)^2, 1)
    } else {
      round(
        (input$weight_input / 2.2046) / ((input$height_input / 0.3937) / 100)^2,
        1
      )
    }
  })

  output$downloadData <- downloadHandler(
    filename = function() {
      # Use the selected dataset as the suggested file name
      paste0("dataset", ".xlsx")
    },
    content = function(file) {
      # Write the dataset to the `file` that will be downloaded
      write.xlsx(data001(), file)
    }
  )

  observe({
    if (is.null(input$upload)) {
      return()
    }
    # write excel
    file.copy(input$upload$datapath, "weight.xlsx", overwrite = TRUE)
    shinyalert("write into server")

    Sys.sleep(2)
    #session$reload()
  })

  observeEvent(input$type, {
    # We'll use the input$controller variable multiple times, so save it as x
    # for convenience.
    x_label = if (input$type == 'kg,cm') {
      'kg'
    } else {
      'pounds'
    }
    y_label = if (input$type == 'kg,cm') {
      'cm'
    } else {
      'inches'
    }
    x = if (input$type == 'kg,cm') {
      84
    } else {
      round(84 * 2.2046)
    }
    y = if (input$type == 'kg,cm') {
      180
    } else {
      round(180 * 0.3937)
    }

    updateNumericInput(
      session,
      "weight_input",
      label = paste("Your weight in ", x_label),
      value = x
    )

    updateNumericInput(
      session,
      "height_input",
      label = paste("Your height in ", y_label),
      value = y
    )
  })

  # AI Suggestion functionality using ellmer
  observeEvent(input$get_ai_suggestion, {
    # Show loading message
    output$ai_suggestion_output <- renderUI({
      div(
        class = "alert alert-info",
        icon("spinner fa-spin"),
        get_text("ai_getting_suggestion", current_lang())
      )
    })

    # Get recent 500 days of data
    recent_data <- data001() %>%
      arrange(desc(date)) %>%
      head(500) %>%
      arrange(date)

    # Check if we have data
    if (nrow(recent_data) == 0) {
      output$ai_suggestion_output <- renderUI({
        div(
          class = "alert alert-warning",
          icon("exclamation-triangle"),
          get_text("no_weight_data", current_lang())
        )
      })
      return()
    }

    # Check if API key is provided
    if (input$ai_api_key == "") {
      output$ai_suggestion_output <- renderUI({
        div(
          class = "alert alert-warning",
          icon("exclamation-triangle"),
          get_text("please_provide_api_key", current_lang())
        )
      })
      return()
    }

    # Check if model is provided
    if (input$ai_model == "") {
      output$ai_suggestion_output <- renderUI({
        div(
          class = "alert alert-warning",
          icon("exclamation-triangle"),
          get_text("please_provide_model_name", current_lang())
        )
      })
      return()
    }

    # Prepare data for AI with language-specific prompt
    current_language <- current_lang()

    if (current_language == "zh") {
      data_summary <- paste(
        "最近的体重和BMI数据（过去10天或可用条目）：",
        paste(
          sapply(1:nrow(recent_data), function(i) {
            paste(sprintf(
              "第%d天: 日期: %s, 体重: %.1f公斤, BMI: %.1f",
              i,
              as.character(recent_data$date[i]),
              recent_data$weight[i],
              recent_data$bmi[i]
            ))
          }),
          collapse = "\n"
        ),
        "",
        paste("当前BMI:", round(tail(recent_data$bmi, 1), 1)),
        paste("当前体重:", round(tail(recent_data$weight, 1), 1), "公斤"),
        "",
        "请根据这些体重和BMI趋势数据提供健康和健身建议，控制在500字以内。请考虑：",
        "1. 趋势是上升、下降还是稳定？",
        "2. 当前BMI是否在健康范围内（18.5-24.9）？",
        "3. 会给出具体饮食和锻炼的建议。",

        "请提供实用、鼓励性的建议，语气友好。请用中文回答。",
        sep = "\n"
      )
    } else {
      data_summary <- paste(
        "Recent weight and BMI data (last 10 days or available entries):",
        paste(
          sapply(1:nrow(recent_data), function(i) {
            paste(sprintf(
              "Day %d: Date: %s, Weight: %.1f kg, BMI: %.1f",
              i,
              as.character(recent_data$date[i]),
              recent_data$weight[i],
              recent_data$bmi[i]
            ))
          }),
          collapse = "\n"
        ),
        "",
        paste("Current BMI:", round(tail(recent_data$bmi, 1), 1)),
        paste("Current weight:", round(tail(recent_data$weight, 1), 1), "kg"),
        "",
        "Please provide health and fitness advice based on this weight and BMI trend data within 200 words. Consider:",
        "1. Is the trend going up, down, or stable?",
        "2. Is the current BMI in a healthy range (18.5-24.9)?",
        "3. provide specific diet and exercise recommendations.",

        "Please provide practical, encouraging advice in a friendly tone. Please respond in English.",
        sep = "\n"
      )
    }

    # Make AI call using ellmer
    tryCatch(
      {
        # Create chat instance with custom provider URL, API key, and model
        chat_instance <- chat_openai(
          base_url = input$ai_provider_url,
          api_key = input$ai_api_key,
          model = input$ai_model,
          echo = "output"
        )

        # Get AI response with better error handling
        ai_response <- NULL

        # Try the main prompt with error handling
        tryCatch(
          {
            ai_response <- chat_instance$chat(data_summary)
          },
          error = function(e) {
            cat("Main prompt error:", e$message, "\n")
          }
        )

        # Check if response is valid and try fallback
        if (is.null(ai_response) || nchar(trimws(ai_response)) == 0) {
          tryCatch(
            {
              # Try with a simpler prompt
              if (current_language == "zh") {
                simple_prompt <- paste(
                  "我当前的BMI是",
                  round(tail(recent_data$bmi, 1), 1),
                  "，体重是",
                  round(tail(recent_data$weight, 1), 1),
                  "公斤。",
                  "请给我2-3句简短的健康建议。请用中文回答。"
                )
              } else {
                simple_prompt <- paste(
                  "My current BMI is",
                  round(tail(recent_data$bmi, 1), 1),
                  "and my weight is",
                  round(tail(recent_data$weight, 1), 1),
                  "kg.",
                  "Give me brief health advice in 2-3 sentences. Please respond in English."
                )
              }
              ai_response <- chat_instance$chat(simple_prompt)
              cat("Simple prompt attempted\n")
            },
            error = function(e) {
              cat("Simple prompt error:", e$message, "\n")
            }
          )
        }

        # If still empty, provide helpful message
        if (is.null(ai_response) || nchar(trimws(ai_response)) == 0) {
          ai_response <- paste(
            "The AI service responded but the content appears to be empty.",
            "This can happen with certain models or API configurations.",
            "Please try: 1) Using the model 'ZhipuAI/GLM-4.6', 2) Wait a few minutes and try again,",
            "3) Check if your API key has sufficient permissions and quota."
          )
        } else {
          ai_response <- trimws(ai_response)
        }

        # Display AI response with proper markdown rendering
        output$ai_suggestion_output <- renderUI({
          # Convert markdown to HTML
          html_content <- markdown::markdownToHTML(
            text = paste(
              ai_response,
              "\n\n---\n\n",
              get_text("ai_note", current_language)
            ),
            fragment.only = TRUE
          )

          div(
            class = "card border-success",
            div(
              class = "card-header bg-success text-white",
              h6(
                class = "mb-0",
                icon("robot"),
                " ",
                get_text("ai_header", current_language)
              ),
              tags$small(
                class = "text-white-50",
                paste("Generated on:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
              )
            ),
            div(
              class = "card-body",
              # Render markdown content as HTML
              div(class = "card-text markdown-content", HTML(html_content))
            )
          )
        })
      },
      error = function(e) {
        # Handle error
        output$ai_suggestion_output <- renderUI({
          div(
            class = "alert alert-danger",
            icon("exclamation-circle"),
            paste(
              "Error:",
              e$message,
              "- ",
              get_text("ai_error_check_config", current_language)
            )
          )
        })
      }
    )
  })

  # Initialize empty AI suggestion output
  output$ai_suggestion_output <- renderUI({
    div(
      class = "alert alert-info",
      icon("info-circle"),
      get_text("ai_suggestion_initial", current_lang())
    )
  })
}
