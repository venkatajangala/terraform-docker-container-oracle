# Terraform Oracle 26ai Docker Container

This Terraform configuration automates the deployment of Oracle 26ai Free database in Docker, providing a quick and reproducible way to set up a development Oracle database environment.

## Overview

This project uses Terraform and Docker to:
- Automatically pull the Oracle 26ai Free Docker image
- Create and configure an Oracle database container
- Persist database data on the host machine
- Expose the database on a configurable port
- Generate connection strings for easy access

## Prerequisites

Before using this Terraform configuration, ensure you have:

1. **Terraform** >= 1.0 installed
   - [Download Terraform](https://www.terraform.io/downloads.html)

2. **Docker** installed and running
   - [Download Docker](https://www.docker.com/products/docker-desktop)

3. **Oracle Account** (for pulling the Oracle image)
   - Log in to [container-registry.oracle.com](https://container-registry.oracle.com)
   - Authentication may be required when pulling the image for the first time

## Quick Start

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan -var="oracle_password=YourSecurePassword1"
```

### 3. Apply Configuration

```bash
terraform apply -var="oracle_password=YourSecurePassword1" -auto-approve
```

Replace `YourSecurePassword1` with a strong password of your choice.

### 4. Get Connection Details

After successful deployment:

```bash
terraform output connection_string
terraform output container_name
terraform output volume_name
```

## Storage Architecture

This configuration uses **Docker Managed Volumes** for data persistence:

- **Volume Name**: `{container_name}-volume` (default: `oracle-26ai-volume`)
- **Mount Point**: `/opt/oracle/oradata` inside the container
- **Host Location**: `/var/lib/docker/volumes/{volume_name}/_data`
- **Permissions**: Automatically managed by Docker (no manual chmod needed)

Docker volumes provide:
✅ Automatic permission handling for Oracle user  
✅ Better portability across systems  
✅ Native Docker integration  
✅ Easier backup and migration  

## Configuration Variables

The following variables can be customized:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `image` | string | `container-registry.oracle.com/database/free:23.26.0.0` | Docker image URL for Oracle 26ai Free |
| `oracle_password` | string | `AdminAdmi1!` | Password for SYS and SYSTEM accounts (required to override) |
| `container_name` | string | `oracle-26ai` | Name of the Docker container and volume prefix |
| `oracle_port` | number | `1521` | External port for database connections (1521 is standard) |

## Usage Examples

### Example 1: Default Configuration
```bash
terraform apply -var="oracle_password=MyPassword123" -auto-approve
```

### Example 2: Custom Port and Container Name
```bash
terraform apply \
  -var="oracle_password=MyPassword123" \
  -var="container_name=my-oracle-db" \
  -var="oracle_port=1522" \
  -auto-approve
```

### Example 3: Using Terraform Plan
```bash
terraform plan -var="oracle_password=MyPassword123" -out=plan.tfplan
terraform apply "plan.tfplan"
```

## Connecting to the Database

### Using SQL*Plus
```bash
sqlplus sys/YourPassword@//localhost:1521/FREE as sysdba
```

### Using SQLDeveloper
- Host: `localhost`
- Port: `1521`
- Service Name: `FREE`
- Username: `sys` or `system`
- Password: Your specified password
- Connection Type: Basic

### Using JDBC
```
jdbc:oracle:thin:@localhost:1521/FREE
```

### Using Python (cx_Oracle)
```python
import cx_Oracle

conn = cx_Oracle.connect('sys', 'YourPassword', 'localhost:1521/FREE', mode=cx_Oracle.SYSDBA)
```

## Docker Container Details

The Oracle container is configured with:

- **Restart Policy**: `unless-stopped` (automatically restarts unless explicitly stopped)
- **Port Mapping**: Maps container port 1521 to the host port (default 1521)
- **Volume Mount**: Docker volume named `{container_name}-volume` mounted at `/opt/oracle/oradata`
- **Permissions**: Automatically managed by Docker for the Oracle user
- **Environment Variables**:
  - `ORACLE_PWD`: Password for administrative accounts
  - `ORACLE_SID`: Set to `FREE` for Oracle Free Edition

## File Structure

```
.
├── main.tf           # Core resources (Docker image, container, volume)
├── variables.tf      # Input variables with defaults and descriptions
├── outputs.tf        # Output values (connection string, container name, volume name)
├── versions.tf       # Terraform version requirements
├── terraform.tfstate # State file (auto-generated after apply)
└── README.md         # This file
```

**Note**: Oracle data is stored in a Docker volume (not in a local `./data` directory)

## Cleanup

To remove the Oracle database container and free up resources:

```bash
terraform destroy -var="oracle_password=AdminAdmin1" -auto-approve
```

This will:
- Stop and remove the Docker container
- Remove the Docker volume and all data
- Remove the Docker image (if `keep_locally = false`)

**Note**: The `terraform.tfstate` file will be preserved for future operations.

## Troubleshooting

### Issue: Image Pull Error
**Problem**: Docker authentication fails when pulling the Oracle image.
**Solution**: Log in to Oracle Container Registry:
```bash
docker login container-registry.oracle.com
```

### Issue: Port Already in Use
**Problem**: Port 1521 is already in use.
**Solution**: Change the port using the variable:
```bash
terraform apply -var="oracle_port=1522" -var="oracle_password=YourPassword"
```

### Issue: Permission Denied on Volume
**Problem**: Container cannot write to the mount point.
**Solution**: This is handled automatically by Docker volumes. If issues persist, check Docker daemon status:
```bash
docker ps
docker volume ls
```

### Issue: Container Exits Immediately
**Problem**: Oracle container crashes on startup.
**Solution**: Check Docker logs:
```bash
docker logs oracle-26ai
```
Ensure sufficient disk space and system resources are available (Oracle requires ~20GB for initial setup).

### Issue: Lost Data After Destroy
**Problem**: Data persisted in Docker volume was removed.
**Solution**: To preserve data, manually backup the volume before destroy:
```bash
docker run --rm -v oracle-26ai-volume:/data -v $(pwd):/backup alpine tar czf /backup/oracle-backup.tar.gz /data
```

## Security Considerations

- **Password**: Change the default password immediately. Use a strong, unique password.
- **Network Access**: In production, restrict access to the database port (1521) using firewall rules.
- **Data Persistence**: Regularly backup Docker volumes to prevent data loss:
  ```bash
  docker run --rm -v oracle-26ai-volume:/data -v $(pwd):/backup alpine tar czf /backup/oracle-backup.tar.gz /data
  ```
- **State File**: The `terraform.tfstate` file contains sensitive information. Secure it appropriately.
- **Volume Access**: Docker volumes are accessible only from containers and the host. Ensure proper host security.

## Support & Documentation

- [Oracle Database Documentation](https://docs.oracle.com/)
- [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [Oracle Container Registry](https://container-registry.oracle.com)

## License

This Terraform configuration is provided as-is. Oracle Database Free Edition is subject to Oracle's license terms.
