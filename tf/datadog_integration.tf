# Integración nativa AWS <-> Datadog: Datadog asume un rol en esta cuenta
# (vía external_id) para leer métricas de CloudWatch y metadatos de EC2.

data "aws_caller_identity" "current" {}

# ARN de la cuenta AWS de Datadog que asume el rol. Es un valor fijo publicado
# por Datadog (no depende de nuestra cuenta ni de la región), igual para
# todos los clientes: https://docs.datadoghq.com/integrations/amazon_web_services/
locals {
  datadog_aws_principal_arn = "arn:aws:iam::464622532012:root"
}

# 1. Recurso de integración en Datadog: registra nuestra cuenta AWS y genera
#    el external_id que exigiremos en la trust policy del rol.
resource "datadog_integration_aws_account" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_partition  = "aws"

  auth_config {
    aws_auth_config_role {
      role_name = var.datadog_aws_integration_role_name
    }
  }

  aws_regions {
    include_all  = length(var.datadog_aws_integration_included_regions) == 0
    include_only = length(var.datadog_aws_integration_included_regions) == 0 ? null : var.datadog_aws_integration_included_regions
  }

  # Solo activamos recolección de métricas: sin logs, sin traces, sin CSPM.
  metrics_config {
    enabled = true
    namespace_filters {}
  }

  resources_config {
    cloud_security_posture_management_collection = false
    extended_collection                          = false
  }

  traces_config {
    xray_services {}
  }

  logs_config {
    lambda_forwarder {}
  }
}

# 2. Rol IAM que Datadog puede asumir, condicionado al external_id generado
#    por el recurso de integración anterior.
data "aws_iam_policy_document" "datadog_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.datadog_aws_principal_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [datadog_integration_aws_account.this.auth_config.aws_auth_config_role.external_id]
    }
  }
}

resource "aws_iam_role" "datadog_integration" {
  name               = var.datadog_aws_integration_role_name
  description        = "Rol asumido por Datadog para la integración nativa AWS"
  assume_role_policy = data.aws_iam_policy_document.datadog_assume_role.json
}

# 3. Permisos mínimos estándar que exige Datadog para leer métricas de
#    CloudWatch y EC2 (https://docs.datadoghq.com/integrations/amazon_web_services/#permissions).
data "aws_iam_policy_document" "datadog_integration_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "datadog_integration_permissions" {
  name        = "DatadogIntegrationPolicy"
  description = "Permisos mínimos para que Datadog lea métricas de CloudWatch y EC2"
  policy      = data.aws_iam_policy_document.datadog_integration_permissions.json
}

resource "aws_iam_role_policy_attachment" "datadog_integration" {
  role       = aws_iam_role.datadog_integration.name
  policy_arn = aws_iam_policy.datadog_integration_permissions.arn
}
