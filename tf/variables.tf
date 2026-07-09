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

variable "datadog_aws_integration_role_name" {
  description = "Nombre del rol IAM que la integración nativa de Datadog asumirá en esta cuenta AWS"
  type        = string
  default     = "DatadogIntegrationRole"
}

variable "datadog_aws_integration_included_regions" {
  description = "Regiones AWS que Datadog debe monitorizar. Vacío = todas las regiones (include_all)."
  type        = list(string)
  default     = []
}
