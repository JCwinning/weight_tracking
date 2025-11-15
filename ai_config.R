# AI Provider Configuration
# This file contains configuration for different AI providers and functions to manage them

# Provider configurations
ai_providers <- list(
  modelscope = list(
    provider_url = "https://api-inference.modelscope.cn/v1",
    models = c("zhipuAI/GLM-4.6", "Qwen/Qwen3-Next-80B-A3B-Instruct")
  ),

  openrouter = list(
    provider_url = "https://openrouter.ai/api/v1",
    models = c("openai/gpt-oss-120b:exacto", "minimax/minimax-m2:free")
  ),

  Gemini = list(
    provider_url = "https://generativelanguage.googleapis.com/v1beta/openai/",
    models = c("gemini-2.5-flash", "gemini-2.5-pro")
  ),

  OpenAI_compatible = list(
    provider_url = "https://api.openai.com/v1",
    models = c("gpt-5-mini", "gpt-5")
  )
)

# Default provider
current_provider <- "modelscope"

# Function to get current provider configuration
get_current_config <- function() {
  return(ai_providers[[current_provider]])
}

# Function to get provider URL
get_provider_url <- function(provider = current_provider) {
  return(ai_providers[[provider]]$provider_url)
}

# Function to get provider models
get_provider_models <- function(provider = current_provider) {
  return(ai_providers[[provider]]$models)
}

# Function to set current provider
set_current_provider <- function(provider_name) {
  if (provider_name %in% names(ai_providers)) {
    current_provider <<- provider_name
    return(TRUE)
  } else {
    warning(paste(
      "Provider",
      provider_name,
      "not found. Available providers:",
      paste(names(ai_providers), collapse = ", ")
    ))
    return(FALSE)
  }
}

# Function to get available providers
get_available_providers <- function() {
  return(names(ai_providers))
}

# Function to add new provider
add_provider <- function(provider_name, provider_url, models) {
  ai_providers[[provider_name]] <<- list(
    provider_url = provider_url,
    models = models
  )
  return(TRUE)
}

# Convenience function to get current provider name
get_current_provider_name <- function() {
  return(current_provider)
}
