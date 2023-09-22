terraform {
  required_providers {
    basistheory = {
      source  = "basis-theory/basistheory"
      version = ">= 0.8.0"
    }
  }
}

variable "bt_management_api_key" {}
variable "marqeta_application_token" {}
variable "marqeta_access_token" {}
variable "priceline_ref_id" {}
variable "priceline_api_key" {}

provider "basistheory" {
  api_key = var.bt_management_api_key
}

resource "basistheory_application" "backend_application" {
  name        = "Backend Application"
  type        = "private"
  permissions = ["token:use"]
}

resource "basistheory_reactor_formula" "priceline_formula" {
  type        = "private"
  name        = "Priceline Reactor Formula"
  description = "Obtains card information from Issuer API and uses it to book a flight"
  code        = file("./reactor.js")
  configuration {
    type        = "string"
    name        = "MARQETA_APPLICATION_TOKEN"
    description = "Marqeta's Application Token used to authenticate against their API"
  }
  configuration {
    type        = "string"
    name        = "MARQETA_ACCESS_TOKEN"
    description = "Marqeta's Access Token used to authenticate against their API"
  }
  configuration {
    type        = "string"
    name        = "PRICELINE_REF_ID"
    description = "Priceline's identifier assigned to your API Key"
  }
  configuration {
    type        = "string"
    name        = "PRICELINE_API_KEY"
    description = "Priceline's API Key used to authenticate against their API"
  }
}

resource "basistheory_reactor" "priceline_reactor" {
  formula_id = basistheory_reactor_formula.priceline_formula.id
  name       = "Priceline Reactor"
  configuration = {
    MARQETA_APPLICATION_TOKEN = var.marqeta_application_token
    MARQETA_ACCESS_TOKEN = var.marqeta_access_token
    PRICELINE_REF_ID = var.priceline_ref_id
    PRICELINE_API_KEY = var.priceline_api_key
  }
}

output "priceline_reactor_id" {
  value     = basistheory_reactor.priceline_reactor.id
}

output "backend_application_key" {
  value     = basistheory_application.backend_application.key
  sensitive = true
}
