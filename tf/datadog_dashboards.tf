# Dashboard declarativo de Datadog para las instancias EC2 del proyecto.
# Filtramos por el tag "name" (Datadog importa el tag EC2 "Name" en minúsculas)
# con el prefijo común de nuestras instancias, en vez de por instance-id, para
# no depender de IDs que solo se conocen tras el apply.
locals {
  datadog_ec2_filter = "name:lti-project-*"
}

resource "datadog_dashboard" "aws_infra_ec2_monitor" {
  title       = "AWS Infrastructure & EC2 Monitor"
  description = "Monitorización de las instancias EC2 (backend/frontend) del proyecto lti-project"
  layout_type = "ordered"

  # 1. Uso de CPU
  widget {
    timeseries_definition {
      title = "EC2 CPU Utilization (%)"
      request {
        q            = "avg:aws.ec2.cpuutilization{${local.datadog_ec2_filter}} by {instance-id}"
        display_type = "line"
      }
    }
  }

  # 2. Estado de salud de la instancia (status checks de AWS/CloudWatch)
  widget {
    timeseries_definition {
      title = "EC2 Status Check Failed (0 = healthy)"
      request {
        q            = "avg:aws.ec2.status_check_failed{${local.datadog_ec2_filter}} by {instance-id}"
        display_type = "area"
      }
    }
  }

  # 3. Créditos de CPU (solo aplica a instancias burstable t2/t3; nuestras
  #    instancias son t2.micro y t2.medium, así que aplica a ambas)
  widget {
    timeseries_definition {
      title = "EC2 CPU Credit Balance (t2/t3)"
      request {
        q            = "avg:aws.ec2.cpucreditbalance{${local.datadog_ec2_filter}} by {instance-id}"
        display_type = "area"
      }
    }
  }

  # 4. Nota informativa
  widget {
    note_definition {
      content          = "Este dashboard fue generado automáticamente mediante Terraform en el Máster de IA (AI4Devs)."
      background_color = "blue"
      font_size        = "14"
      text_align       = "left"
    }
  }
}
