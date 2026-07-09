variable "datadog_api_key" {
  description = "API Key de Datadog (Organization Settings > API Keys)"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Application Key de Datadog (Organization Settings > Application Keys)"
  type        = string
  sensitive   = true
}

variable "datadog_api_url" {
  description = "URL del sitio Datadog. Usa https://api.datadoghq.eu para cuentas de la región EU."
  type        = string
  default     = "https://api.us5.datadoghq.com"
}
