output "connection_string" {
  description = "JDBC connection string for Oracle Free"
  value       = "jdbc:oracle:thin:@localhost:${var.oracle_port}/FREE"
}

output "container_name" {
  value = docker_container.oracle.name
}

output "volume_name" {
  description = "Docker volume name for persistent data"
  value       = docker_volume.oracle_data.name
}
