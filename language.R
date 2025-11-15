# Language translation mappings for Weight Tracking App
# This file contains all text translations for English and Chinese

# Create language data structure
translations <- list(
  en = list(
    app_title = "Weight tracking",
    last_input_date = "last input date:",
    last_date = "last date:",
    current_weight = "current weight:",
    choose_unit = "Choose measurement unite:",
    your_weight = "Your weight:",
    your_height = "Your height:",
    your_bmi = "Your BMI:",
    bmi_categories = list(
      underweight = "Underweight = <18.5",
      normal = "Normal weight = 18.5–24.9",
      overweight = "Overweight = 25–29.9"
    ),
    download = "Download weight data",
    upload_new_data = "upload new weight data",
    bmi_tracking_shiny = "BMI trackig shiny",
    ai_config = "AI API Configuration",
    ai_provider = "AI Provider:",
    ai_provider_url = "AI Provider URL:",
    ai_model = "Model:",
    api_key = "API Key:",
    api_key_placeholder = "Enter your API key",
    url_placeholder = "AI Provider URL will be set automatically",
    plot_tab = "Plot",
    ui_tab = "ui.R",
    server_tab = "server.R",
    data_tab = "data",
    get_ai_suggestion = "Get AI Suggestion",
    ai_suggestion_initial = "Enter AI API key and Click 'Get AI Suggestion' to receive personalized health advice based on your recent weight data.",
    ai_getting_suggestion = "Getting AI suggestion...",
    no_weight_data = "No weight data available for AI analysis.",
    please_provide_api_key = "Please provide an API key",
    please_provide_model_name = "Please provide a model name",
    ai_error_check_config = "Please check your API configuration and try again.",
    ai_note = "*Note: This is AI-generated advice. Please consult healthcare professionals for medical guidance.*",
    ai_header = "AI Health & Fitness Suggestion",
    chart_weight_title = "daily personal weight",
    chart_bmi_title = "daily personal BMI",
    chart_weight_legend = "Weight(KG)",
    chart_bmi_legend = "My BMI",
    chart_bmi_good = "Good BMI"
  ),

  zh = list(
    app_title = "体重追踪",
    last_input_date = "最后输入日期:",
    last_date = "最后日期:",
    current_weight = "当前体重:",
    choose_unit = "选择测量单位:",
    your_weight = "您的体重:",
    your_height = "您的身高:",
    your_bmi = "您的BMI:",
    bmi_categories = list(
      underweight = "偏瘦 = <18.5",
      normal = "正常体重 = 18.5–24.9",
      overweight = "超重 = 25–29.9"
    ),
    download = "下载体重数据",
    upload_new_data = "上传新体重数据",
    bmi_tracking_shiny = "BMI追踪应用",
    ai_config = "AI API配置",
    ai_provider = "AI提供商:",
    ai_provider_url = "AI提供商URL:",
    ai_model = "模型:",
    api_key = "API密钥:",
    api_key_placeholder = "输入您的API密钥",
    url_placeholder = "AI提供商URL将自动设置",
    plot_tab = "图表",
    ui_tab = "ui.R",
    server_tab = "server.R",
    data_tab = "数据",
    get_ai_suggestion = "获取AI建议",
    ai_suggestion_initial = "输入AI API密钥并点击'获取AI建议'，根据您最近的体重数据接收个性化健康建议。",
    ai_getting_suggestion = "正在获取AI建议...",
    no_weight_data = "没有可用于AI分析的体重数据。",
    please_provide_api_key = "请提供API密钥",
    please_provide_model_name = "请提供模型名称",
    ai_error_check_config = "请检查您的API配置并重试。",
    ai_note = "*注意：这是AI生成的建议。请咨询医疗专业人员获取医疗指导。*",
    ai_header = "AI健康与健身建议",
    chart_weight_title = "每日个人体重",
    chart_bmi_title = "每日个人BMI",
    chart_weight_legend = "体重(公斤)",
    chart_bmi_legend = "我的BMI",
    chart_bmi_good = "健康BMI"
  )
)

# Default language storage (will be initialized in server.R)
current_language <- "en"

# Function to get translation text
get_text <- function(key, language = current_language) {
  if (is.null(translations[[language]][[key]])) {
    return(translations[["en"]][[key]]) # Fallback to English
  }
  return(translations[[language]][[key]])
}

# Function to get BMI category text
get_bmi_text <- function(category_key, language = current_language) {
  if (is.null(translations[[language]]$bmi_categories[[category_key]])) {
    return(translations[["en"]]$bmi_categories[[category_key]]) # Fallback to English
  }
  return(translations[[language]]$bmi_categories[[category_key]])
}

# Function to set current language
set_language <- function(lang) {
  current_language <<- lang
}

# Function to get current language
get_current_language <- function() {
  return(current_language)
}