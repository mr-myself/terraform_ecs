variable "region" {
  description = "Region that the instances will be created"
}

variable "key_name" {
  description = "AWS key pair name"
}

/*====
environment specific variables
======*/

variable "staging_database_name" {
  description = "The database name for staging"
}

variable "staging_database_username" {
  description = "The username for the staging database"
}

variable "staging_database_password" {
  description = "The user password for the staging database"
}

variable "staging_secret_key_base" {
  description = "The Rails secret key for staging"
}

variable "domain" {
  default = "The domain of your application"
}

variable "repository_url" {
  description = "The repository url of ECR"
}

variable "repository_tag" {
  description = "The image tag of ECR"
}
