#!/bin/bash

# Instalar y arrancar el Datadog Agent (API Key inyectada por Terraform)
DD_API_KEY="${dd_api_key}" DD_SITE="${dd_site}" DD_AGENT_MAJOR_VERSION=7 bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"
systemctl enable datadog-agent
systemctl start datadog-agent

yum update -y
yum install -y docker

# Iniciar el servicio de Docker
service docker start

# Descargar y descomprimir el archivo backend.zip desde S3
aws s3 cp s3://lti-project-code-bucket/backend.zip /home/ec2-user/backend.zip
unzip /home/ec2-user/backend.zip -d /home/ec2-user/

# Construir la imagen Docker para el backend
cd /home/ec2-user/backend
docker build -t lti-backend .

# Ejecutar el contenedor Docker
docker run -d -p 8080:8080 lti-backend

# Timestamp to force update
echo "Timestamp: ${timestamp}"
