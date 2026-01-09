variable "image" {
  type    = string
  default = "container-registry.oracle.com/database/free:23.26.0.0"
  description = "Docker image to run for Oracle 26ai Free"
}

variable "oracle_password" {
  type    = string
  default = "AdminAdmi1!"
  description = "SYS and SYSTEM password for Oracle 26ai image"
}

variable "container_name" {
  type    = string
  default = "oracle-26ai"
}

variable "oracle_port" {
  type    = number
  default = 1521
}

variable "data_dir" {
  type    = string
  default = ""
  description = "Host path to persist Oracle data. If empty, the module will use '<module path>/data' (computed at runtime)."
}
