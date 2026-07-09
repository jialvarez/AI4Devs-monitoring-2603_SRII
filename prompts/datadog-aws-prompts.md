## 🛠️ Fase 1: Análisis del Estado Actual (Opcional pero recomendado)

Antes de escribir código, haz que Claude Code analice lo que ya tienes del ejercicio anterior para evitar conflictos de nombres o recursos.

```text
Analiza el código de Terraform actual en este repositorio. Identifica los recursos existentes (especialmente la instancia EC2 y el Security Group) y explícame brevemente cómo están estructurados los archivos principales. No hagas cambios todavía.

```

---

## 🔐 Fase 2: Configuración del Proveedor y Variables

Este prompt prepara el terreno añadiendo las dependencias de Datadog y las variables necesarias, asegurando que **no** se expongan credenciales (buenas prácticas).

```text
Vamos a empezar con el ejercicio de monitorización. Añade la configuración del proveedor de Datadog a Terraform. 

Para ello, debes:
1. Modificar `providers.tf` (o el archivo correspondiente) para incluir el proveedor oficial de Datadog junto al de AWS.
2. Crear o actualizar `variables.tf` para declarar las variables necesarias: `datadog_api_key`, `datadog_app_key` y la región de Datadog (ej. `datadog_api_url` si es EU). Asegúrate de que no tengan valores por defecto sensibles.
3. Asegurarte de que se configure el bloque `terraform` con los `required_providers`.

Haz los cambios directamente en los archivos correspondientes.


```

---

## 🤝 Fase 3: Integración AWS-Datadog (Roles y Políticas IAM)

Para que Datadog lea métricas de AWS (CloudWatch), necesita un rol de IAM con una política de lectura específica y un external ID generado por Datadog.

```text
Configura la integración nativa entre AWS y Datadog utilizando Terraform. Necesitamos crear los recursos para que Datadog pueda asumir un rol en nuestra cuenta de AWS para leer métricas.

Por favor, crea un archivo `datadog_integration.tf` que incluya:
1. Un recurso `datadog_integration_aws` (del proveedor de Datadog) configurando la cuenta de AWS y un `external_id`.
2. Un rol de IAM en AWS (`aws_iam_role`) que permita la política de confianza (assume role) para el principal de Datadog, validando el `external_id`.
3. Una política de IAM (`aws_iam_policy`) con los permisos mínimos estándar que requiere Datadog para leer métricas de CloudWatch y EC2, y asóciala al rol.

Utiliza variables para cualquier dato que deba ser parametrizable.

```

---

## 🚀 Fase 4: Instalación del Agente en la Instancia EC2

Modifica el `user_data` de la EC2 existente para instalar el agente de Datadog mediante script de inicio.

```text
Modifica la definición de la instancia EC2 existente en el código para instalar el agente de Datadog de forma automatizada mediante su script de inicio (user_data).

Pasos a seguir:
1. Localiza el recurso de la instancia EC2 y revisa si ya tiene un `user_data` o un script asociado.
2. Modifica o extiende ese script en Bash para que instale el agente de Datadog para Ubuntu/Debian (o la AMI que use el proyecto).
3. El script debe configurar la API Key de Datadog de manera dinámica (puedes usar la variable de Terraform introduciéndola en el script de user_data mediante plantillas o interpolación).
4. Asegúrate de habilitar e iniciar el servicio del agente (`datadog-agent`).

Modifica el archivo correspondiente directamente.

```

---

## 📊 Fase 5: Creación del Dashboard en Datadog

Definir la visualización de métricas clave (CPU, Memoria, Red de la EC2 y métricas de AWS CloudWatch).

```text
Crea un archivo llamado `datadog_dashboards.tf` para definir un dashboard en Datadog de forma declarativa usando el recurso `datadog_dashboard`.

El dashboard debe llamarse "AWS Infrastructure & EC2 Monitor" y debe tener una estructura de tipo 'ordered' o 'free'. Debe incluir los siguientes widgets (gráficos de líneas o de área):
1. Uso de CPU de la instancia EC2 (Métrica: `aws.ec2.cpuutilization`).
2. Estado de salud de la instancia (Status Check).
3. Créditos de CPU (si aplica a instancias t2/t3).
4. Un widget de texto que indique que este dashboard fue generado automáticamente mediante Terraform en el Máster de IA.

Asegúrate de filtrar las métricas por el ID de la instancia EC2 o los tags del entorno para que apunte a nuestra infraestructura.

```

---

## 📝 Fase 6: Generación de la Documentación (Cumpliendo el punto 4 y 5)

Una vez que Claude Code haya aplicado y probado todo, puedes pedirle que te genere los archivos de entrega redactados a la perfección.

```text
¡Excelente trabajo con el código! Ahora vamos a documentar el ejercicio tal y como pide el enunciado.

1. Crea la carpeta `prompts/` si no existe, y dentro genera el archivo `datadog-aws-prompts.md`. En él, documenta de forma estructurada y limpia todos los prompts que hemos utilizado a lo largo de esta sesión para generar el código de Terraform, explicando brevemente qué hacía cada uno.
2. Actualiza el archivo `README.md` de la raíz incluyendo:
   - Una sección explicando detalladamente todos los cambios que hemos realizado (Integración AWS-Datadog, agente en EC2, variables y dashboard).
   - Añade los placeholders tradicionales para las capturas de pantalla de la entrega (`![Dashboard Datadog](./capturas/dashboard.png)`).
   - Una sección de "Desafíos y Soluciones" que resuma de forma profesional cómo abordamos la inyección de la API key de forma segura en el user_data y la gestión de permisos IAM.

```

### 💡 Consejos para exprimir Claude Code en este ejercicio:

* **Ejecuta `terraform init` y `terraform validate` a través de Claude:** Puedes decirle en cualquier momento: *"Ejecuta `terraform init` y valida si la sintaxis del nuevo proveedor de Datadog es correcta"* y Claude Code ejecutará el comando en tu terminal para verificar que no hay errores.
* **Control de Ramas:** Antes de empezar, recuerda crear tu rama con tus iniciales (`git checkout -b tu-iniciales-monitoring`). Si se te olvida, puedes pedírselo al propio Claude: *"Crea una nueva rama de git llamada [TUS-INICIALES]-monitoring"*.