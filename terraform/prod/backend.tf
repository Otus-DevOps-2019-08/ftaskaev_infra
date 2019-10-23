terraform {
  backend "gcs" {
    bucket  = "otus-devops-infra-ftaskaev"
    prefix  = "terraform/state/prod"
  }
}
