# 📋 Examen de Hito 4: Deployment

> **Formato**: Self-Correction Code Review  
> **Duración**: 45-60 minutos  
> **Puntaje mínimo**: 70/100

---

## Ejercicio 1: Dockerfile con Errores (30 puntos)

### Código a Revisar

```dockerfile
FROM python:3.11

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

EXPOSE 8000

CMD python app/fastapi_app.py
```

### Tu Respuesta

| # | Problema | Severidad | Corrección |
|---|----------|-----------|------------|

---

<details>
<summary>📝 Ver Solución</summary>

| # | Problema | Severidad | Corrección |
|---|----------|-----------|------------|
| 1 | `python:3.11` es muy pesado (~1GB) | 🟡 Medio | Usar `python:3.11-slim` |
| 2 | `COPY . .` antes de deps | 🔴 Crítico | COPY requirements.txt primero (cache) |
| 3 | Sin `.dockerignore` | 🟡 Medio | Crear archivo para excluir .git, __pycache__ |
| 4 | Sin `--no-cache-dir` en pip | 🟢 Menor | Reduce tamaño de imagen |
| 5 | Corre como root | 🔴 Crítico | Crear usuario non-root |
| 6 | CMD sin exec form | 🟡 Medio | Usar `["python", "..."]` |
| 7 | Sin multi-stage build | 🟡 Medio | Separar build de runtime |
| 8 | Sin HEALTHCHECK | 🟢 Menor | Añadir healthcheck |

### Dockerfile Corregido

```dockerfile
# ═══════════════════════════════════════════════════════════════════════════
# Stage 1: Builder (solo para instalar deps)
# ═══════════════════════════════════════════════════════════════════════════
FROM python:3.11-slim as builder

WORKDIR /app

# Instalar deps de compilación
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copiar SOLO requirements (cache de Docker)
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ═══════════════════════════════════════════════════════════════════════════
# Stage 2: Runtime (imagen final ligera)
# ═══════════════════════════════════════════════════════════════════════════
FROM python:3.11-slim

WORKDIR /app

# Variables de entorno
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:$PATH"

# Crear usuario non-root
RUN useradd --create-home --shell /bin/bash appuser

# Copiar deps instaladas desde builder
COPY --from=builder /root/.local /home/appuser/.local

# Copiar código (después de deps para mejor cache)
COPY --chown=appuser:appuser src/ ./src/
COPY --chown=appuser:appuser app/ ./app/
COPY --chown=appuser:appuser configs/ ./configs/

# Cambiar a usuario non-root
USER appuser

# Puerto
EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD curl -f http://localhost:8000/health || exit 1

# Comando (exec form)
CMD ["uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000"]
```

</details>

---

## Ejercicio 2: FastAPI con Vulnerabilidades (25 puntos)

### Código a Revisar

```python
# app/fastapi_app.py
from fastapi import FastAPI
import pickle
import pandas as pd

app = FastAPI()

model = pickle.load(open("model.pkl", "rb"))

@app.post("/predict")
def predict(data: dict):
    df = pd.DataFrame([data])
    prediction = model.predict(df)[0]
    return {"prediction": prediction}

@app.get("/model-info")
def model_info():
    return {
        "type": str(type(model)),
        "params": model.get_params(),
    }
```

### Tu Respuesta

| # | Problema | Severidad | Corrección |
|---|----------|-----------|------------|

---

<details>
<summary>📝 Ver Solución</summary>

| # | Problema | Severidad | Corrección |
|---|----------|-----------|------------|
| 1 | `data: dict` sin validación | 🔴 Crítico | Usar Pydantic model |
| 2 | Path hardcodeado `model.pkl` | 🟡 Medio | Usar variable de entorno |
| 3 | Carga modelo al importar | 🔴 Crítico | Lazy loading o startup event |
| 4 | Sin manejo de errores | 🔴 Crítico | try/except con HTTPException |
| 5 | `/model-info` expone internos | 🟡 Medio | Limitar información o proteger |
| 6 | Sin versionado de API | 🟢 Menor | Añadir `/v1/predict` |
| 7 | Sin logging | 🟡 Medio | Añadir logs estructurados |

### FastAPI Corregido

```python
# app/fastapi_app.py
import os
from contextlib import asynccontextmanager
from pathlib import Path

import joblib
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import structlog

logger = structlog.get_logger()

# ═══════════════════════════════════════════════════════════════════════════
# Schemas de entrada/salida
# ═══════════════════════════════════════════════════════════════════════════

class PredictRequest(BaseModel):
    """Schema de entrada validado."""
    CreditScore: int = Field(..., ge=300, le=850)
    Age: int = Field(..., ge=18, le=100)
    Balance: float = Field(..., ge=0)
    NumOfProducts: int = Field(..., ge=1, le=4)

class PredictResponse(BaseModel):
    """Schema de salida."""
    prediction: int
    probability: float
    model_version: str

# ═══════════════════════════════════════════════════════════════════════════
# Lifecycle: cargar modelo al iniciar
# ═══════════════════════════════════════════════════════════════════════════

MODEL_PATH = Path(os.getenv("MODEL_PATH", "artifacts/model.joblib"))
model = None
model_version = "unknown"

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Carga modelo al iniciar, libera al cerrar."""
    global model, model_version
    
    if not MODEL_PATH.exists():
        raise RuntimeError(f"Model not found: {MODEL_PATH}")
    
    logger.info("loading_model", path=str(MODEL_PATH))
    model = joblib.load(MODEL_PATH)
    model_version = os.getenv("MODEL_VERSION", "1.0.0")
    
    yield
    
    logger.info("shutting_down")

app = FastAPI(
    title="BankChurn Predictor",
    version="1.0.0",
    lifespan=lifespan,
)

# ═══════════════════════════════════════════════════════════════════════════
# Endpoints
# ═══════════════════════════════════════════════════════════════════════════

@app.post("/v1/predict", response_model=PredictResponse)
async def predict(request: PredictRequest):
    """Predice probabilidad de churn."""
    try:
        import pandas as pd
        df = pd.DataFrame([request.model_dump()])
        
        prediction = int(model.predict(df)[0])
        probability = float(model.predict_proba(df)[0, 1])
        
        logger.info("prediction_made", prediction=prediction)
        
        return PredictResponse(
            prediction=prediction,
            probability=probability,
            model_version=model_version,
        )
    
    except Exception as e:
        logger.error("prediction_failed", error=str(e))
        raise HTTPException(status_code=500, detail="Prediction failed")

@app.get("/health")
async def health():
    """Health check para Kubernetes."""
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "model_version": model_version,
    }
```

</details>

---

## Ejercicio 3: Kubernetes Manifest (25 puntos)

### Código a Revisar

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bankchurn-api
spec:
  replicas: 1
  selector:
    matchLabels:
      app: bankchurn
  template:
    spec:
      containers:
      - name: api
        image: bankchurn:latest
        ports:
        - containerPort: 8000
```

### Tu Respuesta

¿Qué falta para producción?

---

<details>
<summary>📝 Ver Solución</summary>

| # | Faltante | Impacto |
|---|----------|---------|
| 1 | Sin `metadata.labels` en template | Selector no funciona |
| 2 | Sin resources (limits/requests) | Pod puede consumir todo |
| 3 | Sin probes (liveness/readiness) | K8s no sabe si está sano |
| 4 | `image: latest` es antipatrón | No reproducible |
| 5 | Sin imagePullPolicy | Puede usar cache viejo |
| 6 | Sin securityContext | Corre como root |
| 7 | Sin env vars | Config hardcodeada |

### Manifest Corregido

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bankchurn-api
  labels:
    app: bankchurn
    version: v1
spec:
  replicas: 3
  selector:
    matchLabels:
      app: bankchurn
  template:
    metadata:
      labels:
        app: bankchurn
        version: v1
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
      
      containers:
      - name: api
        image: ghcr.io/user/bankchurn:1.0.0  # Tag específico
        imagePullPolicy: IfNotPresent
        
        ports:
        - containerPort: 8000
          name: http
        
        env:
        - name: MODEL_PATH
          value: "/app/models/model.joblib"
        - name: MODEL_VERSION
          value: "1.0.0"
        
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 30
        
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 10
        
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true

---
apiVersion: v1
kind: Service
metadata:
  name: bankchurn-api
spec:
  selector:
    app: bankchurn
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
```

</details>

---

## Ejercicio 4: Terraform (20 puntos)

### Código a Revisar

```hcl
# main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ml_server" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
```

### Tu Respuesta

¿Qué problemas tiene para producción?

---

<details>
<summary>📝 Ver Solución</summary>

| # | Problema | Corrección |
|---|----------|------------|
| 1 | AMI hardcodeada | Usar data source o variable |
| 2 | Sin backend para state | Añadir S3 backend |
| 3 | Sin variables | Parametrizar |
| 4 | Sin outputs | Exportar IP, DNS |
| 5 | Sin tags | Añadir tags para billing |
| 6 | Sin security groups | Definir reglas de red |

### Terraform Corregido

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "bankchurn/terraform.tfstate"
    region = "us-east-1"
  }
}

# variables.tf
variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

# main.tf
provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Project     = "BankChurn"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_security_group" "ml_server" {
  name = "bankchurn-${var.environment}"
  
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ml_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.ml_server.id]
  
  tags = {
    Name = "bankchurn-${var.environment}"
  }
}

# outputs.tf
output "instance_ip" {
  value = aws_instance.ml_server.public_ip
}
```

</details>

---

## Rúbrica

| Ejercicio | Puntos |
|-----------|:------:|
| Dockerfile | 30 |
| FastAPI | 25 |
| Kubernetes | 25 |
| Terraform | 20 |
| **TOTAL** | **100** |
