variable "environment" {
  description = "Name of the environment."
  type        = string
  default     = ""
}

variable "owner" {
  description = "Owner of the resource"
  type        = string
  default     = "n/a"
}

variable "location" {
  description = "Azure region to deploy to."
  type        = string
  default     = "westeurope"
}

variable "release_version" {
  description = "Version of the infrastructure automation"
  type        = string
  default     = "latest"
}

variable "app_service_plan" {
  description = "App service plan sku"
  type        = string
  default     = "B1"
}

variable "deploy_test_vm" {
  description = "Deploy the test vm"
  type        = bool
  default     = false
}

