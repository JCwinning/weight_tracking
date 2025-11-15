# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Shiny web application for tracking personal weight and BMI over time with AI-powered health suggestions. The app allows users to:

- Track weight measurements with date stamps using `reactivePoll()` for real-time updates
- Calculate and visualize BMI trends with interactive Plotly charts
- Switch between metric (kg, cm) and imperial (pounds, inches) units with reactive UI updates
- Download data as Excel files and upload new weight data via Excel files
- Get personalized AI health suggestions using configurable AI providers
- Bookmark and share specific application states via URLs

## Architecture

### Core Application Structure

**Standard Shiny Application Pattern:**
- **`global.R`**: Enables URL-based bookmarking for state persistence
- **`ui.R`**: Multi-tab interface with sidebar controls, AI configuration panel, and visualization areas
- **`server.R`**: Reactive server logic with data management, plotting, and AI integration
- **`language.R`**: Internationalization system supporting English and Chinese languages

### AI Integration Architecture

**AI Provider Management:**
- **`ai_config.R`**: Centralized AI provider configuration with support for multiple providers
- **Provider Options**: Modelscope, OpenRouter, Gemini, OpenAI-compatible APIs
- **Dynamic Provider Selection**: Users can switch providers with automatic URL and model updates
- **AI Response Processing**: Markdown-to-HTML conversion for properly formatted AI suggestions

### Internationalization Architecture

**Multi-language Support:**
- **Language Switching**: Real-time language switching between English and Chinese
- **Text Rendering**: All UI elements dynamically render in selected language
- **Chart Localization**: Date formatting and hover text adapt to language selection
- **AI Prompts**: Language-specific AI prompts for localized health suggestions

### Data Flow Architecture

**Reactive Data Pipeline:**
1. **Data Source**: `weight.xlsx` (monitored via `reactivePoll()` every 1000ms)
2. **Data Processing**: Automatic BMI calculation, unit conversions, and derived metrics
3. **Real-time Updates**: File change detection triggers automatic UI refresh
4. **AI Data Pipeline**: Recent data extraction → language-specific prompt construction → markdown response → HTML rendering

## Key Development Commands

### Running the Application

```bash
# Standard execution
R -e "shiny::runApp()"

# Alternative method
Rscript -e "shiny::runApp()"

# Network-accessible deployment mode
R -e "shiny::runApp(host='0.0.0.0', port=3838)"
```

### Development Testing

```bash
# Test AI configuration functions
Rscript -e "source('ai_config.R'); get_current_provider_name()"

# Test language system functions
Rscript -e "source('language.R'); get_text('app_title', 'en'); get_text('app_title', 'zh')"

# Test syntax and imports
Rscript -e "
library(shiny); library(markdown); library(ellmer)
source('ai_config.R'); source('language.R'); source('ui.R'); source('server.R')
cat('✓ All components load successfully\n')
"

# Test complete application startup
Rscript -e "
shiny::runApp(
  appDir = getwd(),
  launch.browser = FALSE,
  host = '127.0.0.1',
  port = 3838
)
"
```

### Package Installation

```r
# Core dependencies
install.packages(c("shiny", "tidyverse", "readxl", "plotly", "anytime",
                   "bslib", "DT", "rsconnect", "markdown"))

# UI/UX enhancements
install.packages(c("shinyalert", "shinyjs", "shinydashboard",
                   "shinydashboardPlus", "shinyWidgets"))

# Data processing and AI integration
install.packages(c("openxlsx", "readr", "rvest", "curl", "httr", "RCurl", "ellmer"))
```

## Critical Implementation Details

### AI Provider Configuration Pattern

The `ai_config.R` file implements a provider management system:

```r
# Provider structure
ai_providers <- list(
  provider_name = list(
    provider_url = "api_endpoint",
    models = c("model1", "model2")
  )
)

# Key functions for server integration:
get_provider_url(provider_name)  # Returns API endpoint
get_provider_models(provider_name)  # Returns available models
set_current_provider(provider_name)  # Switches active provider
```

### Reactive Data Management

**File Monitoring System:**
- `reactivePoll(1000, session, checkFunc, valueFunc)` monitors `weight.xlsx`
- Automatic UI refresh when file changes detected
- Handles missing file scenarios gracefully

**Data Processing Pipeline:**
```r
data001() %>% mutate(
  date = anydate(date),
  height_cm = 180,  # Fixed default height
  height_inches = height_cm * 0.3937,
  weight_pounds = weight * 2.2046,
  bmi = weight_pounds / (height_inches^2) * 703,
  good_bmi = 24  # Target BMI reference
)
```

### AI Integration Pattern

**AI Suggestion Workflow:**
1. Extract recent 10 days of weight data
2. Construct contextual prompt with trend analysis
3. Send to selected AI provider via ellmer chat interface
4. Convert markdown response to HTML using `markdown::markdownToHTML()`
5. Display in styled card component with timestamp

**Error Handling Strategy:**
- Multiple fallback prompts (detailed → simple → error message)
- Graceful degradation when API calls fail
- User-friendly error messages with troubleshooting guidance

### UI Component Architecture

**Sidebar Layout:**
- Weight/BMI calculation with unit switching
- File upload/download for Excel data
- AI configuration panel with dynamic provider/model selection
- Bookmarking functionality

**Tab-based Navigation:**
- Plot tab: Interactive charts with AI suggestion button
- Code tabs: Display `ui.R` and `server.R` source code
- Data tab: Interactive data table with sorting/filtering

## Important Development Patterns

### State Management
- URL bookmarking preserves application state across sessions
- Reactive variables handle unit conversions and calculations
- AI provider selection persists during session
- Language preference maintained throughout session via `current_lang` reactive value

### File Operations
- Upload overwrites `weight.xlsx` with user confirmation via `shinyalert`
- Download exports complete dataset with calculated fields using `openxlsx`
- File change detection triggers automatic refresh through `reactivePoll()`

### Internationalization Implementation
- **Language State Management**: `current_lang` reactive value tracks selected language
- **Text Rendering**: All UI text uses `get_text(key, language)` for dynamic translation
- **Chart Localization**: Date formatting and hover text adapt to selected language
- **AI Prompt Localization**: Different prompts constructed based on language selection
- **Translation Keys**: Organized in nested list structure in `language.R`

### Styling and Theming
- Custom CSS for markdown content rendering with health app aesthetic
- Bootstrap components via bslib for responsive design
- Card-based layouts with professional styling
- Language-specific typography (Chinese font support in charts)

### Error Resilience
- Comprehensive tryCatch blocks for AI API calls with multiple fallback prompts
- File existence validation for data operations
- Graceful UI feedback for all error scenarios
- Language fallback system defaults to English for missing translations

## Data Format Specifications

**Input Excel Format (`weight.xlsx`):**
```
date        weight
2024-01-01  84.5
2024-01-02  84.3
```

**Calculated Fields (added automatically):**
- Height conversions (cm ↔ inches)
- Weight conversions (kg ↔ pounds)
- BMI calculations for both unit systems
- Target BMI comparison (24.0)

## Deployment Configuration

**ShinyApps.io Ready:**
- rsconnect integration included
- All required packages specified
- Production-ready error handling

**Docker Considerations:**
- rocker/shiny base image compatibility
- Package installation in Dockerfile
- Port 3838 exposure standard

## Language System Implementation

### Translation Architecture

**Language File Structure (`language.R`):**
```r
translations <- list(
  en = list(
    app_title = "Weight tracking",
    # ... more English translations
  ),
  zh = list(
    app_title = "体重追踪",
    # ... more Chinese translations
  )
)
```

**Key Functions:**
- `get_text(key, language)`: Retrieves translation for given key and language
- `get_bmi_text(category_key, language)`: Specialized function for BMI category translations
- `set_language(lang)`: Updates global language state
- `get_current_language()`: Returns current active language

### Adding New Languages

1. **Add Language Section**: Add new language entry to `translations` list in `language.R`
2. **Provide All Translations**: Ensure all keys from English version are translated
3. **Update Language Switcher**: Add new language button to `ui.R` (around lines 35-40)
4. **Test Implementation**: Verify all UI elements render correctly in new language

### Language Switching Implementation

**UI Language Buttons:**
- Located in top-right corner with absolute positioning
- `actionButton("lang_en", "EN")` and `actionButton("lang_zh", "中文")`
- Styled as secondary buttons with proper spacing

**Server-side Language Management:**
```r
# Initialize language state
current_lang <- reactiveVal("en")

# Language switching observers
observeEvent(input$lang_en, {
  current_lang("en")
  set_language("en")
})

observeEvent(input$lang_zh, {
  current_lang("zh")
  set_language("zh")
})
```