resource "aws_s3_bucket" "code_bucket" {
  # Los nombres de bucket S3 son únicos a nivel global (no solo por cuenta);
  # "lti-project-code-bucket" a secas ya está en uso por otra cuenta, así que
  # le añadimos el account id para garantizar unicidad.
  bucket = "lti-project-code-bucket-${data.aws_caller_identity.current.account_id}"
  acl    = "private"
}

resource "null_resource" "generate_zip" {
  provisioner "local-exec" {
    # El script asume que se ejecuta desde la raíz del repo (usa rutas
    # relativas "backend"/"frontend"/"./backend.zip"), pero terraform corre
    # con cwd = tf/, así que hay que entrar a la raíz antes de invocarlo.
    command     = "sh generar-zip.sh"
    working_dir = "${path.module}/.."
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "aws_s3_bucket_object" "backend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "backend.zip"
  source     = "../backend.zip"
  depends_on = [null_resource.generate_zip]
}

resource "aws_s3_bucket_object" "frontend_zip" {
  bucket     = aws_s3_bucket.code_bucket.bucket
  key        = "frontend.zip"
  source     = "../frontend.zip"
  depends_on = [null_resource.generate_zip]
}
