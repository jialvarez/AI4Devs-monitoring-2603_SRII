#!/bin/bash
yum update -y
yum install -y docker

# Instalar y arrancar el Datadog Agent (API Key inyectada por Terraform)
DD_API_KEY="${dd_api_key}" DD_SITE="${dd_site}" DD_AGENT_MAJOR_VERSION=7 bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"
systemctl enable datadog-agent
systemctl start datadog-agent

# Iniciar el servicio de Docker
service docker start

# Descargar y descomprimir el archivo frontend.zip desde S3
aws s3 cp s3://lti-project-code-bucket/frontend.zip /home/ec2-user/frontend.zip
unzip /home/ec2-user/frontend.zip -d /home/ec2-user/

# Construir la imagen Docker para el frontend
cd /home/ec2-user/frontend
docker build -t lti-frontend .

# Ejecutar el contenedor Docker
docker run -d -p 3000:3000 lti-frontend

# Timestamp to force update
echo "Timestamp: ${timestamp}"
