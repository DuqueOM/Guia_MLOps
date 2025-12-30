# 22. Infrastructure as Code (IaC) Empresarial

## 🎯 Objetivo

Dominar IaC para entornos ML multi-ambiente (Dev/Staging/Prod), gestión de estado Terraform y patrones de arquitectura enterprise.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  "Infrastructure as Code no es solo automatización:                          ║
║   es documentación viva, auditoría y reproducibilidad de tu plataforma."     ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Contenido

1. [Fundamentos de IaC Enterprise](#1-fundamentos)
2. [Gestión de Estado Terraform](#2-estado)
   - [2.1 State Locking con S3 + DynamoDB](#21-state-locking-con-s3--dynamodb)
   - [2.2 Creación del Backend (Bootstrap)](#22-creacion-del-backend-bootstrap)
   - [2.3 State Management Best Practices](#23-state-management-best-practices)
   - [2.4 🔬 Ingeniería Inversa Pedagógica: State Locking](#2x-ingenieria-inversa-iac) ⭐ NUEVO
3. [Arquitectura Multi-Ambiente](#3-multiambiente)
4. [Módulos Terraform Reutilizables](#4-modulos)
5. [CI/CD para Infraestructura](#5-cicd)
6. [Ejercicio: Refactorizar para Staging](#6-ejercicio)
7. [Preguntas de Entrevista Senior](#7-entrevista)

---

<a id="1-fundamentos"></a>


### 🧠 Mapa Mental de Conceptos

**Términos clave para este módulo:**
- Revisa los conceptos principales en las secciones siguientes
- Practica con los ejercicios del portafolio BankChurn
- Aplica los checkpoints para verificar tu comprensión

---



### 💻 Ejercicio Puente: Terraform

> **Meta**: Practica el concepto antes de aplicarlo al portafolio.

**Ejercicio básico:**
1. Lee la sección teórica siguiente
2. Identifica los patrones clave del código de ejemplo
3. Replica el patrón en un proyecto de prueba

---

### 🛠️ Práctica del Portafolio: IaC en BankChurn

> **Tarea**: Aplicar este módulo en BankChurn-Predictor.

```bash
cd BankChurn-Predictor
# Explora el código relacionado con Terraform
```

**Checklist:**
- [ ] Localicé el código relevante
- [ ] Entendí la implementación actual
- [ ] Identifiqué posibles mejoras

---

### ✅ Checkpoint de Conocimiento

**Pregunta 1**: ¿Cuál es el objetivo principal de IaC?

**Pregunta 2**: ¿Cómo se implementa en el portafolio?

**🔧 Escenario Debugging**: Si algo falla en Terraform, ¿cuál sería tu primer paso de diagnóstico?


## 1. Fundamentos de IaC Enterprise

### Principios

| Principio | Descripción | Implementación |
|-----------|-------------|----------------|
| **Immutable** | No modificar, reemplazar | Blue/Green deployments |
| **Declarative** | Definir estado deseado | Terraform, CloudFormation |
| **Versioned** | Todo en Git | PR reviews para infra |
| **Modular** | Componentes reutilizables | Terraform modules |
| **Testable** | Validar antes de aplicar | `terraform plan`, Terratest |

### Estructura de Proyecto Enterprise

```
infra/
├── modules/                    # Módulos reutilizables.
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   └── ml-serving/
├── environments/               # Configuración por ambiente.
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── backend.tf
├── shared/                     # Recursos compartidos.
│   ├── ecr/
│   ├── iam/
│   └── networking/
└── scripts/
    ├── apply.sh
    ├── plan.sh
    └── destroy.sh
```

---

<a id="2-estado"></a>

## 2. Gestión de Estado Terraform

### 2.1 State Locking con S3 + DynamoDB

```hcl
# environments/prod/backend.tf
# Backend remoto con locking para evitar conflictos.

terraform {
  backend "s3" {
    # Bucket para almacenar el estado.
    bucket = "mlops-portfolio-tfstate"
    key    = "prod/terraform.tfstate"     # Path único por ambiente.
    region = "us-east-1"
    
    # Tabla DynamoDB para locking.
    # Previene que dos personas apliquen cambios simultáneos.
    dynamodb_table = "mlops-portfolio-tflock"
    
    # Encriptación del estado (contiene secrets).
    encrypt = true
    
    # Versionado para rollback.
    versioning = true
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### 2.2 Creación del Backend (Bootstrap)

```hcl
# shared/backend-bootstrap/main.tf
# Este módulo se aplica UNA vez para crear el backend.

provider "aws" {
  region = "us-east-1"
}

# S3 Bucket para estado.
resource "aws_s3_bucket" "tfstate" {
  bucket = "mlops-portfolio-tfstate"
  
  # Prevenir eliminación accidental.
  lifecycle {
    prevent_destroy = true
  }
  
  tags = {
    Name        = "Terraform State"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Habilitar versionado.
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Encriptación server-side.
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# Bloquear acceso público.
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB para locking.
resource "aws_dynamodb_table" "tflock" {
  name         = "mlops-portfolio-tflock"
  billing_mode = "PAY_PER_REQUEST"  # Sin provisioning.
  hash_key     = "LockID"           # Requerido por Terraform.
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name        = "Terraform Lock Table"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

output "state_bucket" {
  value = aws_s3_bucket.tfstate.id
}

output "lock_table" {
  value = aws_dynamodb_table.tflock.name
}
```

### 2.3 State Management Best Practices

```python
# scripts/state_management.py
"""Utilidades para gestión de estado Terraform."""

import subprocess                                   # Ejecutar comandos del sistema.
import json                                         # Parsear output JSON de Terraform.
from pathlib import Path                            # Manejo de paths.
from typing import Dict, List                       # Type hints.
import logging                                      # Sistema de logging.

# Configurar logging básico.
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class TerraformStateManager:
    """
    Gestor de estado Terraform.
    
    Best practices implementadas:
    - Backup antes de operaciones destructivas.
    - Validación de drift (diferencias entre estado y realidad).
    - Importación de recursos existentes al estado.
    - Wrapper seguro para comandos Terraform.
    """
    
    def __init__(self, env_path: str):
        """
        Inicializa el gestor de estado.
        
        Args:
            env_path: Path al directorio del ambiente (ej: environments/prod).
        """
        self.env_path = Path(env_path)              # Convertir a Path object.
        self.state_file = self.env_path / "terraform.tfstate"  # Path al state file.
    
    def run_terraform(self, *args) -> subprocess.CompletedProcess:
        """
        Ejecuta comando Terraform de forma segura.
        
        Args:
            *args: Argumentos para el comando terraform.
            
        Returns:
            CompletedProcess con stdout, stderr y returncode.
        """
        cmd = ["terraform"] + list(args)            # Construir comando completo.
        logger.info(f"Running: {' '.join(cmd)}")    # Log del comando.
        return subprocess.run(
            cmd,                                    # Comando a ejecutar.
            cwd=self.env_path,                      # Directorio de trabajo.
            capture_output=True,                    # Capturar stdout/stderr.
            text=True,                              # Retornar como string.
        )
    
    def init(self, reconfigure: bool = False) -> bool:
        """
        Inicializa Terraform (descarga providers, configura backend).
        
        Args:
            reconfigure: Si True, reconfigura backend ignorando estado previo.
            
        Returns:
            True si la inicialización fue exitosa.
        """
        args = ["init"]                             # Comando base.
        if reconfigure:                             # Opción para reconfigurar.
            args.append("-reconfigure")             # Ignorar configuración previa.
        
        result = self.run_terraform(*args)          # Ejecutar.
        if result.returncode != 0:                  # Verificar éxito.
            logger.error(f"Init failed: {result.stderr}")
            return False
        return True
    
    def plan(self, out_file: str = "plan.out") -> Dict:
        """
        Genera plan de cambios sin aplicarlos.
        
        Args:
            out_file: Archivo donde guardar el plan.
            
        Returns:
            Dict con conteo de cambios: {"add": N, "change": N, "destroy": N}.
        """
        # Ejecutar plan con output JSON.
        result = self.run_terraform("plan", f"-out={out_file}", "-json")
        
        # Inicializar contadores.
        changes = {"add": 0, "change": 0, "destroy": 0}
        
        # Parsear cada línea del output JSON.
        for line in result.stdout.split("\n"):     # Terraform emite JSON line by line.
            if line.strip():                        # Ignorar líneas vacías.
                try:
                    data = json.loads(line)         # Parsear JSON.
                    if data.get("type") == "planned_change":  # Es un cambio.
                        action = data.get("change", {}).get("action")
                        if action == "create":      # Recurso nuevo.
                            changes["add"] += 1
                        elif action == "update":    # Recurso modificado.
                            changes["change"] += 1
                        elif action == "delete":    # Recurso a eliminar.
                            changes["destroy"] += 1
                except json.JSONDecodeError:        # Línea no es JSON válido.
                    pass                            # Ignorar (logs, etc).
        
        return changes                              # Retornar resumen.
    
    def detect_drift(self) -> List[str]:
        """
        Detecta drift entre estado guardado y realidad en el cloud.
        
        Drift ocurre cuando alguien modifica recursos fuera de Terraform.
        
        Returns:
            Lista de descripciones de recursos con drift.
        """
        # -detailed-exitcode: 0=sin cambios, 1=error, 2=hay cambios.
        result = self.run_terraform("plan", "-detailed-exitcode")
        
        # Exit code 2 = hay cambios (drift detectado).
        if result.returncode == 2:
            logger.warning("⚠️ Drift detected!")   # Advertir sobre drift.
            
            # Parsear output para identificar recursos afectados.
            drifted = []                            # Lista de recursos con drift.
            for line in result.stdout.split("\n"):
                # Buscar líneas que indican cambios.
                if "will be" in line or "must be" in line:
                    drifted.append(line.strip())    # Agregar a lista.
            return drifted
        
        logger.info("✅ No drift detected")         # Todo OK.
        return []                                   # Lista vacía = sin drift.
    
    def import_resource(
        self,
        address: str,                               # Dirección Terraform del recurso.
        resource_id: str,                           # ID del recurso en el cloud.
    ) -> bool:
        """
        Importa recurso existente al estado de Terraform.
        
        Útil cuando:
        - Recursos fueron creados manualmente.
        - Se migra infraestructura existente a IaC.
        
        Args:
            address: Dirección Terraform (ej: aws_instance.web).
            resource_id: ID del recurso en el cloud (ej: i-1234567890abcdef0).
            
        Returns:
            True si la importación fue exitosa.
        """
        result = self.run_terraform("import", address, resource_id)
        if result.returncode != 0:                  # Verificar éxito.
            logger.error(f"Import failed: {result.stderr}")
            return False
        logger.info(f"✅ Imported {address}")        # Confirmar éxito.
        return True
    
    def backup_state(self) -> str:
        """
        Crea backup del estado actual antes de operaciones riesgosas.
        
        Returns:
            Path al archivo de backup, o string vacío si falló.
        """
        from datetime import datetime               # Import local para timestamp.
        
        # Generar nombre único con timestamp.
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"terraform.tfstate.backup.{timestamp}"
        
        # Extraer estado actual del backend remoto.
        result = self.run_terraform("state", "pull")  # Pull state from backend.
        if result.returncode == 0:                  # Si tuvo éxito.
            backup_path = self.env_path / backup_name  # Path completo.
            backup_path.write_text(result.stdout)   # Escribir contenido.
            logger.info(f"✅ State backed up to {backup_path}")
            return str(backup_path)
        
        logger.error("Failed to backup state")      # Error al hacer backup.
        return ""                                   # Retornar vacío.


# ========== EJEMPLO DE USO ==========
if __name__ == "__main__":
    # Crear manager para el ambiente de producción.
    manager = TerraformStateManager("environments/prod")
    
    # Paso 1: Inicializar Terraform.
    manager.init()
    
    # Paso 2: Detectar drift (cambios fuera de Terraform).
    drift = manager.detect_drift()
    if drift:                                       # Si hay drift.
        print("Recursos con drift:")               # Mostrar afectados.
        for r in drift:
            print(f"  - {r}")
    
    # Paso 3: Generar plan de cambios.
    changes = manager.plan()                        # Plan sin aplicar.
    print(f"\nPlan: +{changes['add']} ~{changes['change']} -{changes['destroy']}")
```

---

<a id="2x-ingenieria-inversa-iac"></a>

### 2.4 🔬 Ingeniería Inversa Pedagógica: State Locking Real

> **Objetivo**: Entender por qué usamos DynamoDB y S3 para el estado de Terraform en lugar de un archivo local.

**Archivo**: `environments/prod/backend.tf`

#### El "Por Qué" Arquitectónico

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       PROBLEMA DE CONCURRENCIA EN IAC                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Escenario: Dev A y Dev B ejecutan 'terraform apply' al mismo tiempo.       │
│                                                                             │
│  SIN LOCKING (Local state):                                                 │
│  • Ambos leen el estado local (o git pull).                                 │
│  • A aplica cambios. B aplica cambios sobre versión vieja.                  │
│  • RESULTADO: Estado corrupto, recursos eliminados por error.               │
│                                                                             │
│  CON LOCKING (S3 + DynamoDB):                                               │
│  • A inicia apply → Terraform escribe un "lock" en DynamoDB.                │
│  • B inicia apply → Ve el lock y ESPERA (o falla).                          │
│  • A termina → Libera el lock.                                              │
│  • RESULTADO: Integridad garantizada.                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

#### Anatomía del Código

```hcl
terraform {
  backend "s3" {
    bucket         = "mlops-portfolio-tfstate"  # Dónde se guarda el JSON del estado
    key            = "prod/terraform.tfstate"   # Ruta única dentro del bucket
    region         = "us-east-1"
    
    # EL SECRETO DEL LOCKING
    dynamodb_table = "mlops-portfolio-tflock"   # Tabla para coordinar locks
    encrypt        = true                       # Encriptar datos sensibles en reposo
  }
}
```

#### Laboratorio de Replicación

1.  Crea la tabla DynamoDB manualmente (o con script bootstrap) con clave primaria `LockID`.
2.  Configura el backend en tu `main.tf`.
3.  Ejecuta `terraform init`.
4.  **Prueba de Fuego**: Abre dos terminales. En una ejecuta `terraform apply` y déjalo esperando confirmación ("Enter a value:"). En la otra intenta `terraform apply`. La segunda debe fallar con "Error acquiring the state lock".

---

<a id="3-multiambiente"></a>

## 3. Arquitectura Multi-Ambiente

### 3.1 Variables por Ambiente

```hcl
# environments/dev/variables.tf
# Variables específicas de desarrollo.

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type for ML serving"
  type        = string
  default     = "t3.small"  # Pequeño para dev.
}

variable "min_capacity" {
  description = "Minimum instances for auto-scaling"
  type        = number
  default     = 1  # Mínimo para dev.
}

variable "max_capacity" {
  description = "Maximum instances for auto-scaling"
  type        = number
  default     = 2  # Limitado para dev.
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false  # Ahorro en dev.
}
```

```hcl
# environments/staging/variables.tf
# Variables para staging (similar a prod pero más pequeño).

variable "environment" {
  type    = string
  default = "staging"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"  # Intermedio.
}

variable "min_capacity" {
  type    = number
  default = 2  # HA básica.
}

variable "max_capacity" {
  type    = number
  default = 4
}

variable "enable_monitoring" {
  type    = bool
  default = true  # Testear monitoring.
}
```

```hcl
# environments/prod/variables.tf
# Variables para producción.

variable "environment" {
  type    = string
  default = "prod"
}

variable "instance_type" {
  type    = string
  default = "t3.large"  # Más capacidad.
}

variable "min_capacity" {
  type    = number
  default = 3  # HA completa.
}

variable "max_capacity" {
  type    = number
  default = 10
}

variable "enable_monitoring" {
  type    = bool
  default = true
}
```

### 3.2 Main.tf Común con Módulos

```hcl
# environments/staging/main.tf
# Configuración de staging usando módulos compartidos.

terraform {
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "MLOps-Portfolio"
      ManagedBy   = "Terraform"
    }
  }
}

# VPC compartida.
module "vpc" {
  source = "../../modules/vpc"
  
  environment = var.environment
  cidr_block  = "10.1.0.0/16"  # Diferente CIDR por ambiente.
}

# EKS Cluster para ML workloads.
module "eks" {
  source = "../../modules/eks"
  
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  instance_types = [var.instance_type]
  
  # Staging: cluster más pequeño.
  desired_capacity = var.min_capacity
  min_capacity     = var.min_capacity
  max_capacity     = var.max_capacity
}

# ML Serving infrastructure.
module "ml_serving" {
  source = "../../modules/ml-serving"
  
  environment       = var.environment
  cluster_id        = module.eks.cluster_id
  instance_type     = var.instance_type
  enable_monitoring = var.enable_monitoring
  
  # Endpoints de modelos.
  models = {
    bankchurn = {
      image     = "123456789.dkr.ecr.us-east-1.amazonaws.com/bankchurn:staging"
      replicas  = var.min_capacity
      cpu       = "500m"
      memory    = "1Gi"
    }
    carvision = {
      image     = "123456789.dkr.ecr.us-east-1.amazonaws.com/carvision:staging"
      replicas  = 1  # GPU-based, menos réplicas.
      cpu       = "1000m"
      memory    = "4Gi"
      gpu       = 1
    }
  }
}

# Outputs.
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "model_endpoints" {
  value = module.ml_serving.endpoints
}
```

### 3.3 Terraform Workspaces (Alternativa)

```bash
# Alternativa a directorios: Terraform Workspaces.
# Útil para proyectos más simples.

# Crear workspaces.
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Cambiar de workspace.
terraform workspace select staging

# Listar workspaces.
terraform workspace list

# En código, usar: terraform.workspace
# Ejemplo:
# instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.small"
```

---

<a id="4-modulos"></a>

## 4. Módulos Terraform Reutilizables

### 4.1 Módulo de ML Serving

```hcl
# modules/ml-serving/main.tf
# Módulo reutilizable para desplegar modelos ML.

variable "environment" {
  type = string
}

variable "cluster_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "models" {
  description = "Map of models to deploy"
  type = map(object({
    image    = string
    replicas = number
    cpu      = string
    memory   = string
    gpu      = optional(number, 0)
  }))
}

# Namespace para ML workloads.
resource "kubernetes_namespace" "ml" {
  metadata {
    name = "ml-${var.environment}"
    labels = {
      environment = var.environment
      purpose     = "ml-serving"
    }
  }
}

# Deployment para cada modelo.
resource "kubernetes_deployment" "model" {
  for_each = var.models
  
  metadata {
    name      = each.key
    namespace = kubernetes_namespace.ml.metadata[0].name
    labels = {
      app         = each.key
      environment = var.environment
    }
  }
  
  spec {
    replicas = each.value.replicas
    
    selector {
      match_labels = {
        app = each.key
      }
    }
    
    template {
      metadata {
        labels = {
          app         = each.key
          environment = var.environment
        }
        annotations = {
          "prometheus.io/scrape" = var.enable_monitoring ? "true" : "false"
          "prometheus.io/port"   = "8000"
        }
      }
      
      spec {
        container {
          name  = each.key
          image = each.value.image
          
          resources {
            requests = {
              cpu    = each.value.cpu
              memory = each.value.memory
            }
            limits = {
              cpu    = each.value.cpu
              memory = each.value.memory
            }
          }
          
          port {
            container_port = 8000
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

# Service para cada modelo.
resource "kubernetes_service" "model" {
  for_each = var.models
  
  metadata {
    name      = each.key
    namespace = kubernetes_namespace.ml.metadata[0].name
  }
  
  spec {
    selector = {
      app = each.key
    }
    
    port {
      port        = 80
      target_port = 8000
    }
    
    type = "ClusterIP"
  }
}

# HPA para auto-scaling.
resource "kubernetes_horizontal_pod_autoscaler_v2" "model" {
  for_each = var.models
  
  metadata {
    name      = each.key
    namespace = kubernetes_namespace.ml.metadata[0].name
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = each.key
    }
    
    min_replicas = each.value.replicas
    max_replicas = each.value.replicas * 3
    
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }
  }
}

# Outputs.
output "endpoints" {
  value = {
    for k, v in kubernetes_service.model : k => {
      name      = v.metadata[0].name
      namespace = v.metadata[0].namespace
      port      = v.spec[0].port[0].port
    }
  }
}
```

---

<a id="5-cicd"></a>

## 5. CI/CD para Infraestructura

### 5.1 GitHub Actions para Terraform

```yaml
# .github/workflows/terraform.yml
name: Terraform CI/CD

on:
  push:
    branches: [main]
    paths:
      - 'infra/**'
  pull_request:
    branches: [main]
    paths:
      - 'infra/**'

env:
  TF_VERSION: '1.5.0'
  AWS_REGION: 'us-east-1'

jobs:
  # Job 1: Validación y Plan.
  plan:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging, prod]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Terraform Init
        run: terraform init
        working-directory: infra/environments/${{ matrix.environment }}
      
      - name: Terraform Validate
        run: terraform validate
        working-directory: infra/environments/${{ matrix.environment }}
      
      - name: Terraform Plan
        run: terraform plan -out=plan.tfplan
        working-directory: infra/environments/${{ matrix.environment }}
      
      # Guardar plan para apply posterior.
      - name: Upload Plan
        uses: actions/upload-artifact@v4
        with:
          name: plan-${{ matrix.environment }}
          path: infra/environments/${{ matrix.environment }}/plan.tfplan
  
  # Job 2: Apply (solo en main, con aprobación manual para prod).
  apply:
    needs: plan
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging]  # Prod requiere aprobación manual.
    
    environment: ${{ matrix.environment }}  # GitHub Environment para protección.
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Download Plan
        uses: actions/download-artifact@v4
        with:
          name: plan-${{ matrix.environment }}
          path: infra/environments/${{ matrix.environment }}
      
      - name: Terraform Init
        run: terraform init
        working-directory: infra/environments/${{ matrix.environment }}
      
      - name: Terraform Apply
        run: terraform apply -auto-approve plan.tfplan
        working-directory: infra/environments/${{ matrix.environment }}
  
  # Job 3: Apply Prod (requiere aprobación manual).
  apply-prod:
    needs: [plan, apply]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: prod  # Requiere aprobación manual en GitHub.
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}
      
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID_PROD }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY_PROD }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Download Plan
        uses: actions/download-artifact@v4
        with:
          name: plan-prod
          path: infra/environments/prod
      
      - name: Terraform Init
        run: terraform init
        working-directory: infra/environments/prod
      
      - name: Terraform Apply
        run: terraform apply -auto-approve plan.tfplan
        working-directory: infra/environments/prod
```

---

<a id="6-ejercicio"></a>

## 6. Ejercicio: Refactorizar para Staging

### Escenario

El directorio `infra/` actual solo tiene `dev/` y `prod/`. Tu objetivo: **crear ambiente `staging`** que:

1. Replica producción con instancias más pequeñas.
2. Usa el mismo módulo de ML-serving.
3. Tiene su propio state file.
4. Se integra al CI/CD.

### Template de Solución

```bash
# Paso 1: Crear estructura.
mkdir -p infra/environments/staging

# Paso 2: Copiar y modificar configuración.
cp infra/environments/prod/*.tf infra/environments/staging/

# Paso 3: Modificar variables para staging.
```

```hcl
# infra/environments/staging/terraform.tfvars
# Valores específicos para staging.

environment = "staging"

# Instancias más pequeñas que prod.
instance_type = "t3.medium"  # prod usa t3.large

# Menos réplicas.
min_capacity = 2  # prod usa 3
max_capacity = 4  # prod usa 10

# Monitoring habilitado para testing.
enable_monitoring = true

# Tags adicionales.
extra_tags = {
  CostCenter = "staging-testing"
  Owner      = "ml-team"
}
```

```hcl
# infra/environments/staging/backend.tf
# Backend separado para staging.

terraform {
  backend "s3" {
    bucket         = "mlops-portfolio-tfstate"
    key            = "staging/terraform.tfstate"  # Path único.
    region         = "us-east-1"
    dynamodb_table = "mlops-portfolio-tflock"
    encrypt        = true
  }
}
```

### Entregables

- [ ] Directorio `staging/` completo con todos los archivos.
- [ ] Backend configurado con state separado.
- [ ] Variables ajustadas (instancias más pequeñas).
- [ ] CI/CD actualizado para incluir staging.
- [ ] Documentación de diferencias vs prod.

---

<a id="7-entrevista"></a>

## 7. Preguntas de Entrevista Senior

### Conceptuales

1. **¿Por qué es importante el state locking en Terraform?**
2. **¿Cuándo usar Workspaces vs directorios separados?**
3. **¿Cómo manejas secrets en IaC?**

### Diseño

4. **Diseña una estrategia de promoción Dev → Staging → Prod.**
5. **¿Cómo implementarías drift detection automatizado?**
6. **¿Cómo harías rollback de infraestructura?**

### Caso Práctico

7. **Tu terraform apply falla a mitad de camino. ¿Qué haces?**

### Respuestas Clave

**P1**: State locking previene que dos personas apliquen cambios simultáneos, lo cual podría corromper el estado o crear recursos duplicados. DynamoDB proporciona locking atómico.

**P2**: 
- **Workspaces**: Proyectos simples, misma configuración con variables diferentes.
- **Directorios**: Proyectos complejos, configuraciones significativamente diferentes, mejor auditoría y separation of concerns.

**P3**: 
1. AWS Secrets Manager / HashiCorp Vault para secrets.
2. Variables de ambiente en CI/CD (nunca en código).
3. `terraform-docs` para documentar sin exponer.
4. `.gitignore` para `*.tfvars` con secrets.

**P7**: 
1. NO ejecutar `terraform apply` de nuevo inmediatamente.
2. Revisar estado con `terraform state list`.
3. Identificar recursos parcialmente creados.
4. Opción A: `terraform taint` recursos problemáticos y re-apply.
5. Opción B: Importar recursos existentes al estado.
6. Opción C: Rollback manual + `terraform destroy` selectivo.

---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [Terraform Best Practices](https://www.terraform-best-practices.com/) | Guía de patrones |
| 🟡 | [HashiCorp Learn](https://learn.hashicorp.com/terraform) | Tutoriales oficiales |
| 🟢 | [Terragrunt](https://terragrunt.gruntwork.io/) | DRY Terraform |

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **State** | Archivo que mapea recursos reales a configuración Terraform |
| **Backend** | Dónde se almacena el state (S3, GCS, etc.) |
| **Module** | Conjunto reutilizable de recursos Terraform |
| **Workspace** | Instancia separada del mismo código con state diferente |

---

<div align="center">

**Siguiente módulo** → [23. Proyecto Integrador](23_PROYECTO_INTEGRADOR.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
