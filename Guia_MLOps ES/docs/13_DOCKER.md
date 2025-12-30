# 13. Docker Avanzado para ML
 
 <a id="00-prerrequisitos"></a>
 
 ## 0.0 Prerrequisitos
 
 - Tener Docker instalado y funcionando (`docker --version`).
 - Poder construir y correr contenedores (`docker build`, `docker run`).
 - Conocer la estructura `src/`, `app/` y `configs/` usada en los proyectos del portafolio.
 
 ---
 
 <a id="01-protocolo-e-como-estudiar-este-modulo"></a>
 
 ## 0.1 🧠 Protocolo E: Cómo estudiar este módulo
 
 - **Antes de empezar**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define el output mínimo (una imagen `slim` que levanta la API).
 - **Durante el debugging**: si te atoras >15 min (permisos, build lento, rutas/artefactos), registra el caso en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
 - **Al cierre de semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para auditar si tu Dockerfile es reproducible y seguro.
 
 ---
 
 <a id="02-entregables-verificables-minimo-viable"></a>
 
 ## 0.2 ✅ Entregables verificables (mínimo viable)
 
 - [ ] Un Dockerfile optimizado (base `slim`, orden de layers, `.dockerignore`).
 - [ ] Multi-stage build (builder + runtime) o justificación si no aplica.
 - [ ] Contenedor corriendo como non-root.
 - [ ] Imagen con tamaño razonable (objetivo: < 500MB).
 - [ ] `docker run` levanta el servicio y responde en `/health`.
 
 ---
 
 <a id="03-puente-teoria-codigo-portafolio"></a>
 
 ## 0.3 🧩 Puente teoría ↔ código (Portafolio)
 
 - **Concepto**: imágenes pequeñas + reproducibles + seguras (no-root) + healthchecks
 - **Archivo**: `Dockerfile`, `.dockerignore`, `docker-compose*.yml`
 - **Prueba**: `docker build -t <img> .` y `docker run -p 8000:8000 <img>`
 
 ## 🎯 Objetivo del Módulo
 
 Construir imágenes Docker optimizadas, seguras y pequeñas como las del portafolio.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  NIVEL 1: Funcional       NIVEL 2: Optimizado      NIVEL 3: Production       ║
║  ─────────────────        ──────────────────       ──────────────────        ║
║  FROM python:3.11         Multi-stage build        Distroless/Alpine         ║
║  COPY . .                 Slim base                Non-root user             ║
║  pip install              Layer caching            CVE scanning              ║
║                                                                              ║
║  ~1.2GB                   ~400MB                   ~150MB                    ║
║  ⚠️ Básica                 ✅ Mejor                  🛡️ Hardened            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Contenido

- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
- **13.1** [Dockerfile Básico vs Optimizado](#131-dockerfile-basico-vs-optimizado)
- **13.2** [Multi-Stage Builds](#132-multi-stage-builds)
- **13.3** [Mejores Prácticas](#133-mejores-practicas)
- **13.4** [Dockerfile Real del Portafolio](#134-dockerfile-real-del-portafolio)
- **13.5** [Docker Compose para ML](#135-docker-compose-para-ml)
- **13.6** [Docker Compose Avanzado para MLOps](#136-docker-compose-avanzado)
- **13.7** [🔬 Ingeniería Inversa Pedagógica: Dockerfile del Portafolio](#137-ingenieria-inversa-pedagogica) ⭐ NUEVO
  - **13.7.1** [El "Por Qué" Arquitectónico](#1371-el-por-que-arquitectonico)
  - **13.7.2** [Anatomía Línea por Línea](#1372-anatomia-linea-por-linea)
  - **13.7.3** [Laboratorio de Replicación](#1373-laboratorio-de-replicacion)
  - **13.7.4** [Troubleshooting Preventivo](#1374-troubleshooting-preventivo)
  - **13.7.5** [Checklist de Replicación](#1375-checklist-de-replicacion)
  - **13.7.6** [Anatomía del .dockerignore](#1376-anatomia-del-dockerignore)
  - **13.7.7** [Conexión Docker → Kubernetes](#1377-conexion-docker-kubernetes)
  - **13.7.8** [Métricas de Éxito](#1378-metricas-de-exito)
- [Errores habituales](#errores-habituales)
- [✅ Checkpoint](#checkpoint)
- [✅ Ejercicio](#ejercicio)

---

<a id="131-dockerfile-basico-vs-optimizado"></a>
 
## 13.1 Dockerfile Básico vs Optimizado

### ❌ Nivel 1: Básico (No usar en producción)

```dockerfile
# Dockerfile MALO - Solo para demos rápidas
FROM python:3.11

WORKDIR /app
COPY . .

RUN pip install -r requirements.txt

CMD ["python", "main.py"]

# Problemas:
# - Imagen de ~1.2GB
# - Incluye herramientas de desarrollo innecesarias
# - Cache de pip no aprovechado
# - Corre como root (inseguro)
# - Copia archivos innecesarios (.git, tests, etc.)
```

### ✅ Nivel 2: Optimizado

```dockerfile
# Dockerfile MEJOR - Para staging/desarrollo

# 1. Usar slim para reducir tamaño
FROM python:3.11-slim

# 2. Establecer directorio de trabajo
WORKDIR /app

# 3. Copiar SOLO requirements primero (aprovecha cache)
COPY requirements.txt .

# 4. Instalar dependencias (capa cacheada si requirements no cambia)
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copiar código fuente
COPY src/ ./src/
COPY app/ ./app/
COPY configs/ ./configs/

# 6. Usuario no-root
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# 7. Puerto y comando
EXPOSE 8000
CMD ["uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000"]

# Mejoras:
# - ~400MB (slim base)
# - Cache de layers optimizado
# - No corre como root
# - Solo archivos necesarios
```

---

## 13.2 Multi-Stage Builds

<a id="132-multi-stage-builds"></a>

### El Concepto

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MULTI-STAGE BUILD                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  STAGE 1: Builder                    STAGE 2: Runtime                       │
│  ────────────────                    ────────────────                       │
│  • Imagen completa                   • Imagen mínima                        │
│  • Compila código                    • Solo runtime                         │
│  • Instala dependencias              • Copia solo binarios                  │
│  • Genera wheels                     • Sin compiladores                     │
│                                                                             │
│  ┌─────────────────┐                 ┌──────────────────┐                   │
│  │ python:3.11     │                 │ python:3.11-slim │                   │
│  │ + gcc, make     │                 │                  │                   │
│  │ + pip wheel     │   ──COPY──►     │ + wheels only    │                   │
│  │ = 1.2GB         │                 │ = 150-400MB      │                   │
│  └─────────────────┘                 └──────────────────┘                   │
│                                                                             │
│  Se DESCARTA                         Se USA en producción                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Implementación

```dockerfile
# Dockerfile Multi-Stage - Nivel 3 (Producción)

# ══════════════════════════════════════════════════════════════════════════
# STAGE 1: Builder - Compila dependencias
# ══════════════════════════════════════════════════════════════════════════
FROM python:3.11-slim AS builder          # AS builder: nombra este stage para referenciarlo después.

WORKDIR /build                            # Directorio de trabajo para compilación.

# Instalar herramientas de compilación (temporales)
RUN apt-get update && apt-get install -y --no-install-recommends \  # --no-install-recommends: solo deps esenciales.
    gcc \                                 # Compilador C (para paquetes con código nativo).
    python3-dev \                         # Headers de Python (para compilar extensiones).
    && rm -rf /var/lib/apt/lists/*        # Limpia cache apt → reduce tamaño.

# Copiar requirements
COPY requirements.txt .                   # Solo requirements para aprovechar cache.

# Crear wheels (binarios precompilados)
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt  # Genera .whl en /wheels.

# ══════════════════════════════════════════════════════════════════════════
# STAGE 2: Runtime - Imagen final mínima
# ══════════════════════════════════════════════════════════════════════════
FROM python:3.11-slim AS runtime          # Nueva imagen limpia, sin gcc ni herramientas de build.

WORKDIR /app                              # Directorio de la aplicación.

# Copiar SOLO los wheels del builder
COPY --from=builder /wheels /wheels       # --from=builder: copia desde el stage anterior.

# Instalar desde wheels (sin compilación)
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels  # Instala y limpia wheels.

# Copiar código
COPY src/ ./src/                          # Código fuente.
COPY app/ ./app/                          # Aplicación FastAPI/Streamlit.
COPY configs/ ./configs/                  # Archivos de configuración.

# Copiar modelo pre-entrenado si existe
COPY artifacts/model.joblib ./artifacts/model.joblib 2>/dev/null || true  # || true: no falla si no existe.

# Crear usuario no-root
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app  # Seguridad: nunca correr como root.
USER appuser                              # Cambia a usuario sin privilegios.

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \  # Docker verifica salud automáticamente.
    CMD curl -f http://localhost:8000/health || exit 1  # Falla si /health no responde 200.

# Exponer puerto
EXPOSE 8000                               # Documenta el puerto (no lo publica).

# Comando de inicio
CMD ["uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000"]  # Ejecuta la API.
```

---

## 13.3 Mejores Prácticas

<a id="133-mejores-practicas"></a>

### .dockerignore

```dockerignore
# .dockerignore - Excluir archivos innecesarios

# Git
.git
.gitignore

# Python
__pycache__
*.py[cod]
*.pyo
.pytest_cache
.mypy_cache
.coverage
htmlcov/
.venv/
venv/
*.egg-info/

# IDE
.vscode/
.idea/
*.swp

# Tests (no necesarios en producción)
tests/
*_test.py
test_*.py
conftest.py

# Documentación
docs/
*.md
!README.md

# Datos (montar como volumen, no copiar)
data/
*.csv
*.parquet

# Notebooks
*.ipynb
notebooks/

# Logs y temporales
*.log
logs/
tmp/
```

### Layer Caching

```dockerfile
# ❌ MALO: Cualquier cambio en código invalida cache de pip
COPY . .
RUN pip install -r requirements.txt

# ✅ BUENO: requirements separado para aprovechar cache
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY src/ ./src/  # Cambios aquí NO invalidan pip install
```

### Security: Non-Root User

```dockerfile
# Crear usuario con UID específico (evita conflictos de permisos)
RUN useradd -m -u 1000 appuser

# Dar permisos al directorio de trabajo
RUN chown -R appuser:appuser /app

# Cambiar a usuario no-root ANTES de CMD
USER appuser

# Ahora el proceso corre como appuser, no como root
```

---

<a id="134-dockerfile-real-del-portafolio"></a>

## 13.4 Dockerfile Real del Portafolio

### BankChurn-Predictor/Dockerfile

```dockerfile
# BankChurn-Predictor Production Dockerfile
# Multi-stage build optimizado para ML

# ══════════════════════════════════════════════════════════════════════════
# Stage 1: Builder
# ══════════════════════════════════════════════════════════════════════════
FROM python:3.11-slim AS builder

WORKDIR /build

# Dependencias de sistema para compilación
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .

# Crear wheels
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# ══════════════════════════════════════════════════════════════════════════
# Stage 2: Runtime
# ══════════════════════════════════════════════════════════════════════════
FROM python:3.11-slim

# Labels para metadata
LABEL maintainer="duqueom@example.com"
LABEL version="1.0.0"
LABEL description="BankChurn Predictor API"

WORKDIR /app

# Instalar curl para healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias desde wheels
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels

# Copiar código fuente
COPY src/ ./src/
COPY app/ ./app/
COPY configs/ ./configs/

# Copiar modelo (si existe)
COPY models/ ./models/ 2>/dev/null || mkdir -p ./models

# Crear usuario no-root
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Variables de entorno
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PORT=8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=45s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

EXPOSE ${PORT}

CMD ["uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

<a id="135-docker-compose-para-ml"></a>

## 13.5 Docker Compose para ML

### docker-compose.demo.yml (Portafolio)

```yaml
# Docker Compose para demo completa del portafolio
version: "3.8"

services:
  # MLflow Server (central)
  mlflow:
    image: ghcr.io/mlflow/mlflow:v2.9.2
    container_name: mlflow-server
    ports:
      - "5000:5000"
    volumes:
      - mlflow-data:/mlflow
    command: >
      mlflow server
      --backend-store-uri sqlite:///mlflow/mlflow.db
      --default-artifact-root /mlflow/artifacts
      --host 0.0.0.0
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - ml-network

  # BankChurn API
  bankchurn:
    build:
      context: ./BankChurn-Predictor
      dockerfile: Dockerfile
    container_name: bankchurn-api
    ports:
      - "8001:8000"
    volumes:
      - ./BankChurn-Predictor/models:/app/models:ro
    environment:
      - MLFLOW_TRACKING_URI=http://mlflow:5000
    depends_on:
      mlflow:
        condition: service_healthy
    networks:
      - ml-network

  # CarVision API
  carvision:
    build:
      context: ./CarVision-Market-Intelligence
      dockerfile: Dockerfile
    container_name: carvision-api
    ports:
      - "8002:8000"
    volumes:
      - ./CarVision-Market-Intelligence/artifacts:/app/artifacts:ro
    environment:
      - MLFLOW_TRACKING_URI=http://mlflow:5000
    depends_on:
      mlflow:
        condition: service_healthy
    networks:
      - ml-network

  # TelecomAI API
  telecom:
    build:
      context: ./TelecomAI-Customer-Intelligence
      dockerfile: Dockerfile
    container_name: telecom-api
    ports:
      - "8003:8000"
    environment:
      - MLFLOW_TRACKING_URI=http://mlflow:5000
    depends_on:
      mlflow:
        condition: service_healthy
    networks:
      - ml-network

volumes:
  mlflow-data:

networks:
  ml-network:
    driver: bridge
```

### Comandos Útiles

```bash
# Construir todas las imágenes
docker compose -f docker-compose.demo.yml build

# Iniciar todos los servicios
docker compose -f docker-compose.demo.yml up -d

# Ver logs
docker compose -f docker-compose.demo.yml logs -f bankchurn

# Parar todo
docker compose -f docker-compose.demo.yml down

# Limpiar volúmenes también
docker compose -f docker-compose.demo.yml down -v
```

---

<a id="136-docker-compose-avanzado"></a>

## 13.6 Docker Compose Avanzado para MLOps ⭐ NUEVO

El portafolio usa patrones avanzados de Docker Compose que debes conocer para orquestar stacks ML complejos.

### 13.6.1 Profiles: Servicios Opcionales

Los **profiles** permiten tener servicios que solo se inician cuando los necesitas (ej: monitoreo):

```yaml
# docker-compose.demo.yml del portafolio (extracto)
services:
  # Servicios principales (sin profile = siempre se inician)
  mlflow:
    image: ghcr.io/mlflow/mlflow:v2.9.2
    ports:
      - "5000:5000"
    # ...

  bankchurn:
    build: ./BankChurn-Predictor
    ports:
      - "8001:8000"
    # ...

  # Servicios de monitoreo (profile = monitoring)
  prometheus:
    image: prom/prometheus:v2.48.0
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./infra/prometheus-config.yaml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    networks:
      - ml-network
    profiles:
      - monitoring  # ← Solo se inicia con --profile monitoring

  grafana:
    image: grafana/grafana:10.2.2
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    profiles:
      - monitoring  # ← Solo se inicia con --profile monitoring
```

**Uso de profiles:**

```bash
# Solo servicios principales (sin monitoreo)
docker compose -f docker-compose.demo.yml up -d

# Con monitoreo (Prometheus + Grafana)
docker compose -f docker-compose.demo.yml --profile monitoring up -d

# Ver qué está corriendo
docker compose -f docker-compose.demo.yml ps
```

### 13.6.2 Healthchecks Avanzados y Dependencies

```yaml
services:
  mlflow:
    image: ghcr.io/mlflow/mlflow:v2.9.2
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s  # ← Da tiempo para que el servicio arranque

  bankchurn:
    build: ./BankChurn-Predictor
    depends_on:
      mlflow:
        condition: service_healthy  # ← Espera a que MLflow esté healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 45s  # ← El modelo tarda en cargar

  carvision-dashboard:
    image: ml-portfolio-carvision:latest
    command: ["streamlit", "run", "app/streamlit_app.py", "--server.port", "8501"]
    depends_on:
      - carvision  # ← Espera a que la API esté disponible (no healthy)
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8501/_stcore/health"]
      interval: 30s
      timeout: 10s
      start_period: 60s  # ← Streamlit tarda más
```

### 13.6.3 Networking para Microservicios ML

```yaml
services:
  # Servicios internos se comunican por nombre
  bankchurn:
    networks:
      - ml-network
    environment:
      - MLFLOW_TRACKING_URI=http://mlflow:5000  # ← Usa nombre del servicio

  carvision:
    networks:
      - ml-network
    environment:
      - MLFLOW_TRACKING_URI=http://mlflow:5000

networks:
  ml-network:
    driver: bridge
    name: ml-mlops-network  # ← Nombre explícito para debugging
```

**Debugging de networking:**

```bash
# Ver la red y sus contenedores
docker network inspect ml-mlops-network

# Probar conectividad desde un contenedor
docker exec -it bankchurn-api curl http://mlflow:5000/health

# Ver logs de un servicio específico
docker compose logs -f bankchurn
```

### 13.6.4 Volumes para Persistencia y Desarrollo

```yaml
services:
  mlflow:
    volumes:
      # Named volume para persistencia (sobrevive a `down`)
      - mlflow-artifacts:/mlflow
      # Bind mount para acceder a runs locales
      - ./mlruns:/mlruns

  bankchurn:
    volumes:
      # Read-only para datos (evita modificaciones accidentales)
      - ./BankChurn-Predictor/data:/app/data:ro
      # Read-only para modelos
      - ./BankChurn-Predictor/models:/app/models:ro

  # Para DESARROLLO: hot-reload del código
  bankchurn-dev:
    build: ./BankChurn-Predictor
    volumes:
      # Monta código fuente para hot-reload
      - ./BankChurn-Predictor/src:/app/src
      - ./BankChurn-Predictor/app:/app/app
    command: ["uvicorn", "app.fastapi_app:app", "--reload", "--host", "0.0.0.0"]
    profiles:
      - dev

volumes:
  mlflow-artifacts:
    driver: local
  prometheus-data:
    driver: local
  grafana-data:
    driver: local
```

### 13.6.5 Variables de Entorno y Secrets

```yaml
services:
  bankchurn:
    environment:
      # Variables inline
      - PYTHONUNBUFFERED=1
      - LOG_LEVEL=INFO
      # Variables desde archivo .env
      - MLFLOW_TRACKING_URI=${MLFLOW_TRACKING_URI:-http://mlflow:5000}
    env_file:
      - .env  # ← Carga todas las variables de .env

# .env (NO commitear a Git)
# MLFLOW_TRACKING_URI=http://mlflow:5000
# DB_PASSWORD=supersecret
```

### 13.6.6 El Stack Completo del Portafolio

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    STACK DOCKER COMPOSE DEL PORTAFOLIO                          │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  SERVICIOS PRINCIPALES (siempre activos):                                       │
│  ─────────────────────────────────────────                                      │
│                                                                                 │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐                     │
│  │ MLflow       │     │ BankChurn    │     │ CarVision    │                     │
│  │ :5000        │◄────│ API :8001    │     │ API :8002    │                     │
│  │              │     │              │     │              │                     │
│  │ Tracking +   │     │ /predict     │     │ /predict     │                     │
│  │ Artifacts    │◄────┤ /health      │     │ /health      │                     │
│  └──────────────┘     └──────────────┘     └──────┬───────┘                     │
│         ▲                                         │                             │
│         │                                         ▼                             │
│         │             ┌──────────────┐     ┌──────────────┐                     │
│         │             │ TelecomAI    │     │ CarVision    │                     │
│         └─────────────│ API :8003    │     │ Dashboard    │                     │
│                       │              │     │ :8501        │                     │
│                       │ /predict     │     │              │                     │
│                       │ /health      │     │ Streamlit    │                     │
│                       └──────────────┘     └──────────────┘                     │
│                                                                                 │
│  SERVICIOS DE MONITOREO (--profile monitoring):                                 │
│  ──────────────────────────────────────────────                                 │
│                                                                                 │
│  ┌──────────────┐     ┌──────────────┐                                          │
│  │ Prometheus   │────►│ Grafana      │                                          │
│  │ :9090        │     │ :3000        │                                          │
│  │              │     │              │                                          │
│  │ Scrape       │     │ Dashboards   │                                          │
│  │ /metrics     │     │ + Alertas    │                                          │
│  └──────────────┘     └──────────────┘                                          │
│                                                                                 │
│  RED: ml-mlops-network (bridge)                                                 │
│  VOLUMES: mlflow-artifacts, prometheus-data, grafana-data                       │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 🔧 Ejercicio: Crear Tu Stack Docker Compose

```bash
# 1. Crear estructura básica
mkdir -p my-ml-stack/{api,data,models}

# 2. Crear docker-compose.yml
cat > my-ml-stack/docker-compose.yml << 'EOF'
services:
  api:
    build: ./api
    ports:
      - "8000:8000"
    volumes:
      - ./models:/app/models:ro
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      start_period: 30s
    environment:
      - MODEL_PATH=/app/models/model.joblib

  mlflow:
    image: ghcr.io/mlflow/mlflow:v2.9.2
    ports:
      - "5000:5000"
    volumes:
      - mlflow-data:/mlflow
    command: mlflow server --host 0.0.0.0 --port 5000

volumes:
  mlflow-data:
EOF

# 3. Probar el stack
docker compose up -d
docker compose ps
docker compose logs -f api
```

---

<a id="137-ingenieria-inversa-pedagogica"></a>

## 13.7 🔬 Ingeniería Inversa Pedagógica: Dockerfile del Portafolio

> **Objetivo**: Entender EXACTAMENTE por qué cada línea existe en el Dockerfile real de `BankChurn-Predictor/Dockerfile` del portafolio.

Esta sección aplica el método de "Shadow Coder Senior": no solo vemos la herramienta, sino las **decisiones arquitectónicas** tomadas en producción.

---

### 13.7.1 🎯 El "Por Qué" Arquitectónico

Antes de escribir una sola línea de Docker, pregúntate: **¿qué problema estoy resolviendo?**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DECISIONES ARQUITECTÓNICAS DEL PORTAFOLIO                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  PROBLEMA 1: Imágenes de 1.5GB que tardan 10min en desplegar                    │
│  ─────────────────────────────────────────────────────────────                  │
│  DECISIÓN: Multi-stage build con python:3.11-slim                               │
│  RESULTADO: Imagen final de ~350MB (77% más pequeña)                            │
│  REFERENCIA: BankChurn-Predictor/Dockerfile líneas 1-40                         │
│                                                                                 │
│  PROBLEMA 2: Contenedores comprometidos = acceso root al host                   │
│  ─────────────────────────────────────────────────────────────                  │
│  DECISIÓN: Usuario non-root con UID 1000 (appuser)                              │
│  RESULTADO: Atacante limitado a permisos de usuario sin privilegios             │
│  REFERENCIA: BankChurn-Predictor/Dockerfile líneas 55-74                        │
│                                                                                 │
│  PROBLEMA 3: Orquestadores no saben si la API está lista                        │
│  ─────────────────────────────────────────────────────────────                  │
│  DECISIÓN: HEALTHCHECK que valida /health cada 30s                              │
│  RESULTADO: K8s/Docker Compose esperan a que el modelo cargue                   │
│  REFERENCIA: BankChurn-Predictor/Dockerfile líneas 79-81                        │
│                                                                                 │
│  PROBLEMA 4: Cache de Docker invalidado en cada cambio de código                │
│  ─────────────────────────────────────────────────────────────                  │
│  DECISIÓN: COPY requirements.txt ANTES de COPY código fuente                    │
│  RESULTADO: pip install cacheado si solo cambias código                         │
│  REFERENCIA: BankChurn-Predictor/Dockerfile líneas 25-37                        │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**🤔 Pregunta para reflexionar**: ¿Por qué NO usamos `python:3.11-alpine` en el portafolio?

<details>
<summary>💡 Ver respuesta</summary>

Alpine usa `musl` en lugar de `glibc`. Muchas librerías de ML (NumPy, pandas, scikit-learn) tienen binarios precompilados para `glibc` pero NO para `musl`. Esto significa:
- Compilación desde source → builds de 20+ minutos
- Posibles errores de compatibilidad con extensiones C
- `slim` es solo ~50MB más grande pero 100% compatible

**Decisión del portafolio**: Preferimos `slim` por compatibilidad garantizada.
</details>

---

### 13.7.2 🔍 Anatomía Línea por Línea: `BankChurn-Predictor/Dockerfile`

A continuación, el Dockerfile REAL del portafolio con explicación de CADA línea crítica y qué pasa si la omites.

```dockerfile
# ══════════════════════════════════════════════════════════════════════════════
# STAGE 1: BUILDER - Compila dependencias en entorno temporal
# ══════════════════════════════════════════════════════════════════════════════

# Línea 1-3: Imagen base para compilación
# ────────────────────────────────────────
# FROM python:3.11-slim AS builder
#   ├─ python:3.11-slim  → Imagen Debian mínima (~150MB vs ~1GB de python:3.11)
#   ├─ AS builder        → Nombra este stage para referenciarlo después
#   └─ ¿Qué pasa sin AS? → No podrías hacer COPY --from=builder más adelante
FROM python:3.11-slim AS builder

# Líneas 5-8: Metadatos de la imagen (LABEL)
# ──────────────────────────────────────────
# LABEL maintainer="..."
#   ├─ Documenta quién mantiene la imagen
#   ├─ Visible con: docker inspect <imagen>
#   └─ ¿Qué pasa sin esto? → Funciona, pero pierdes trazabilidad en producción
LABEL maintainer="Daniel Duque <daniel.duque@example.com>"
LABEL version="1.0.0"
LABEL description="BankChurn Predictor - Sistema de predicción de abandono bancario"

# Líneas 10-14: Variables de entorno de build
# ───────────────────────────────────────────
# ENV PYTHONUNBUFFERED=1
#   ├─ PYTHONUNBUFFERED=1  → Logs se muestran inmediatamente (sin buffering)
#   ├─ PYTHONDONTWRITEBYTECODE=1 → No genera __pycache__/*.pyc (imagen más limpia)
#   ├─ PIP_NO_CACHE_DIR=1  → pip no guarda cache (reduce tamaño de imagen)
#   └─ PIP_DISABLE_PIP_VERSION_CHECK=1 → No verifica actualizaciones (build más rápido)
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# Línea 16: Directorio de trabajo para compilación
# ─────────────────────────────────────────────────
# WORKDIR /build
#   ├─ Crea /build si no existe y lo establece como CWD
#   ├─ Separado de /app para claridad (build vs runtime)
#   └─ ¿Qué pasa sin esto? → Archivos van a / (raíz), muy desordenado
WORKDIR /build

# Líneas 18-23: Instalar dependencias de compilación (TEMPORALES)
# ────────────────────────────────────────────────────────────────
# RUN apt-get update && apt-get install -y ...
#   ├─ gcc, g++, build-essential → Compiladores para paquetes con código C/C++
#   ├─ --no-install-recommends   → Solo deps esenciales (reduce 200MB+)
#   ├─ rm -rf /var/lib/apt/lists/* → Elimina cache de apt (reduce ~30MB)
#   └─ ¿Qué pasa sin gcc? → Paquetes como numpy, pandas fallan al instalar
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Líneas 25-26: Copiar requirements (ANTES del código)
# ─────────────────────────────────────────────────────
# COPY requirements.txt requirements.in* ./
#   ├─ requirements.txt  → Archivo principal de dependencias
#   ├─ requirements.in*  → Asterisco = copia si existe, no falla si no
#   ├─ Orden crítico: requirements ANTES de código fuente
#   └─ ¿Por qué? → Si solo cambias código, esta capa está cacheada → build 10x más rápido
COPY requirements.txt requirements.in* ./

# Líneas 28-37: Crear virtualenv e instalar dependencias
# ───────────────────────────────────────────────────────
# RUN python -m venv /opt/venv && ...
#   ├─ /opt/venv → Virtualenv aislado en ubicación estándar
#   ├─ . /opt/venv/bin/activate → Activa el venv para pip install
#   ├─ sed ... requirements_clean.txt → Limpia hashes y líneas vacías
#   ├─ pip install --no-cache-dir → Instala sin guardar cache
#   └─ ¿Por qué virtualenv? → Fácil de copiar a runtime stage con COPY --from
RUN python -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --upgrade pip setuptools wheel && \
    if [ -f requirements.in ]; then \
        sed -e '/--hash=/d' -e 's/ \\$//' -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' requirements.in > requirements_clean.txt; \
    else \
        sed -e '/--hash=/d' -e 's/ \\$//' -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' requirements.txt > requirements_clean.txt; \
    fi && \
    pip install --no-cache-dir -r requirements_clean.txt

# ══════════════════════════════════════════════════════════════════════════════
# STAGE 2: RUNTIME - Imagen final ligera sin compiladores
# ══════════════════════════════════════════════════════════════════════════════

# Línea 40: Nueva imagen limpia para runtime
# ──────────────────────────────────────────
# FROM python:3.11-slim AS runtime
#   ├─ Nueva imagen desde cero (SIN gcc, g++, build-essential)
#   ├─ Solo contiene lo que explícitamente copiamos
#   └─ ¿Qué pasa sin multi-stage? → Imagen final de 1.2GB con compiladores innecesarios
FROM python:3.11-slim AS runtime

# Líneas 42-46: Variables de entorno de runtime
# ─────────────────────────────────────────────
# ENV PYTHONPATH=/app
#   ├─ PYTHONPATH=/app → Python puede importar desde /app (import src.bankchurn)
#   ├─ PATH="/opt/venv/bin:$PATH" → Comandos del venv disponibles sin activar
#   └─ ¿Qué pasa sin PYTHONPATH? → ImportError: No module named 'src'
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONPATH=/app
ENV PATH="/opt/venv/bin:$PATH"

# Líneas 48-53: Dependencias mínimas de runtime
# ─────────────────────────────────────────────
# RUN apt-get update && apt-get install -y --no-install-recommends curl ...
#   ├─ curl → Necesario para HEALTHCHECK (CMD curl -f http://...)
#   ├─ ca-certificates → Para conexiones HTTPS (MLflow, APIs externas)
#   ├─ apt-get clean → Limpia cache adicional
#   └─ ¿Qué pasa sin curl? → HEALTHCHECK falla → contenedor marcado "unhealthy"
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Líneas 55-57: SEGURIDAD - Crear usuario non-root
# ─────────────────────────────────────────────────
# RUN groupadd -r appuser --gid=1000 && useradd ...
#   ├─ groupadd -r → Crea grupo "system" (sin home dir por defecto)
#   ├─ --gid=1000 → GID específico para consistencia con volúmenes del host
#   ├─ useradd -r -g appuser → Usuario del grupo appuser
#   ├─ --uid=1000 → UID específico (match típico con usuario host)
#   ├─ --home-dir=/app → Home directory del usuario
#   └─ ¿Qué pasa sin esto? → Contenedor corre como root → vulnerabilidad crítica
RUN groupadd -r appuser --gid=1000 && \
    useradd -r -g appuser --uid=1000 --home-dir=/app appuser

# Línea 59: Directorio de trabajo de la aplicación
# ─────────────────────────────────────────────────
WORKDIR /app

# Línea 62: COPIAR virtualenv desde builder
# ─────────────────────────────────────────
# COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv
#   ├─ --from=builder → Copia desde el stage anterior (no de contexto local)
#   ├─ --chown=appuser:appuser → Asigna propiedad al usuario non-root
#   ├─ /opt/venv → Todo el virtualenv con paquetes instalados
#   └─ ¿Qué pasa sin --chown? → appuser no puede leer paquetes → PermissionError
COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv

# Línea 64: Instalar uvicorn (servidor ASGI)
# ──────────────────────────────────────────
# RUN . /opt/venv/bin/activate && pip install "uvicorn>=0.18.0"
#   ├─ uvicorn → Servidor ASGI de alta performance para FastAPI
#   ├─ >=0.18.0 → Versión mínima con features necesarios
#   └─ ¿Por qué aquí y no en requirements? → Separar deps de app vs runtime
RUN . /opt/venv/bin/activate && pip install --no-cache-dir "uvicorn>=0.18.0"

# Línea 67: Copiar código fuente completo
# ───────────────────────────────────────
# COPY --chown=appuser:appuser . .
#   ├─ Copia TODO el contexto (respetando .dockerignore)
#   ├─ --chown → appuser es dueño de todos los archivos
#   ├─ Esta línea va AL FINAL → cambios de código no invalidan cache de pip
#   └─ ¿Qué pasa sin .dockerignore? → Copia .git, tests, data (imagen 2x más grande)
COPY --chown=appuser:appuser . .

# Líneas 69-71: Crear directorios con permisos correctos
# ───────────────────────────────────────────────────────
# RUN mkdir -p logs data/raw data/processed models results ...
#   ├─ mkdir -p → Crea directorios y padres si no existen
#   ├─ logs, data/*, models, results → Directorios que la app espera
#   ├─ chown -R → Asegura que appuser pueda escribir en ellos
#   └─ ¿Qué pasa sin esto? → FileNotFoundError al escribir logs o guardar modelos
RUN mkdir -p logs data/raw data/processed models results && \
    chown -R appuser:appuser /app

# Línea 74: CAMBIAR a usuario non-root (CRÍTICO)
# ───────────────────────────────────────────────
# USER appuser
#   ├─ A partir de aquí, TODO corre como appuser (no root)
#   ├─ CMD, ENTRYPOINT, docker exec → todos como appuser
#   ├─ IMPORTANTE: Esta línea DESPUÉS de mkdir/chown
#   └─ ¿Qué pasa sin esto? → Contenedor corre como root → CIS Benchmark falla
USER appuser

# Línea 77: Exponer puerto (documentación)
# ────────────────────────────────────────
# EXPOSE 8000
#   ├─ Documenta que la app escucha en puerto 8000
#   ├─ NO publica el puerto (eso es -p en docker run)
#   ├─ Útil para: docker inspect, docker-compose, K8s
#   └─ ¿Qué pasa sin esto? → Funciona, pero pierdes documentación
EXPOSE 8000

# Líneas 79-81: HEALTHCHECK para orquestadores
# ─────────────────────────────────────────────
# HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 ...
#   ├─ --interval=30s → Cada 30s ejecuta el check
#   ├─ --timeout=10s → Si no responde en 10s, falla
#   ├─ --start-period=15s → Espera 15s antes del primer check (carga de modelo)
#   ├─ --retries=3 → 3 fallos consecutivos → "unhealthy"
#   ├─ CMD curl -f http://localhost:8000/health → Verifica endpoint /health
#   ├─ -f → curl falla con exit 22 si HTTP != 2xx/3xx
#   └─ ¿Qué pasa sin HEALTHCHECK? → K8s/Compose no saben si la API está lista
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Líneas 83-84: Comando por defecto (API)
# ───────────────────────────────────────
# CMD ["uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
#   ├─ uvicorn → Servidor ASGI
#   ├─ app.fastapi_app:app → Ruta al objeto FastAPI (app/fastapi_app.py)
#   ├─ --host 0.0.0.0 → Escucha en todas las interfaces (necesario en contenedor)
#   ├─ --port 8000 → Puerto que matchea con EXPOSE
#   ├─ --workers 1 → Un solo worker (escalar con réplicas, no workers)
#   └─ ¿Qué pasa con --host 127.0.0.1? → Solo accesible desde dentro del contenedor
CMD ["uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
```

---

### 13.7.3 🧪 Laboratorio de Replicación: Escribe el Dockerfile Tú Mismo

> **Instrucciones**: NO copies y pegues. Escribe cada sección a mano para interiorizar los conceptos.

#### Paso 1: Estructura Base del Builder Stage

Abre tu editor y crea un archivo `Dockerfile`:

```bash
# Paso 1.1: Crear el archivo vacío
touch BankChurn-Predictor/Dockerfile

# Paso 1.2: Abrirlo en tu editor preferido
code BankChurn-Predictor/Dockerfile  # o vim, nano, etc.
```

**Escribe el Stage 1 (Builder)**:

```dockerfile
# Paso 1.3: Escribe el encabezado y la imagen base
# ─────────────────────────────────────────────────
# Pregunta: ¿Por qué usamos python:3.11-slim y no python:3.11?
# Respuesta: ______________________ (escríbela antes de continuar)

FROM python:3.11-slim AS builder
# ↑ AS builder: nombra este stage para poder hacer COPY --from=builder después
```

#### Paso 2: Variables de Entorno y Dependencias de Build

```dockerfile
# Paso 2.1: Añade las variables de entorno
# ─────────────────────────────────────────
# Pregunta: ¿Qué hace PYTHONUNBUFFERED=1?
# Respuesta: ______________________ (logs sin buffering = visibles inmediatamente)

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PIP_NO_CACHE_DIR=1

# Paso 2.2: Establece el directorio de trabajo
WORKDIR /build

# Paso 2.3: Instala compiladores (SOLO para build)
# Pregunta: ¿Por qué hacemos rm -rf /var/lib/apt/lists/*?
# Respuesta: ______________________ (elimina cache de apt = imagen más pequeña)

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*
```

#### Paso 3: Copiar e Instalar Dependencias

```dockerfile
# Paso 3.1: Copia SOLO requirements (aprovecha cache de Docker)
# ─────────────────────────────────────────────────────────────
# Pregunta: ¿Por qué copiamos requirements.txt ANTES del código fuente?
# Respuesta: ______________________ (si solo cambias código, pip install está cacheado)

COPY requirements.txt .

# Paso 3.2: Crea virtualenv e instala dependencias
RUN python -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
```

#### Paso 4: Stage 2 - Runtime

```dockerfile
# Paso 4.1: Inicia una imagen NUEVA y limpia
# ──────────────────────────────────────────
# Nota: Esta imagen NO tiene gcc, build-essential, ni nada del stage anterior

FROM python:3.11-slim AS runtime

# Paso 4.2: Variables de entorno de runtime
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app
ENV PATH="/opt/venv/bin:$PATH"
# ↑ PATH: permite usar python, pip, uvicorn del venv sin activarlo explícitamente

# Paso 4.3: Dependencias mínimas de runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*
# ↑ curl: necesario para HEALTHCHECK
```

#### Paso 5: Seguridad - Usuario Non-Root

```dockerfile
# Paso 5.1: Crear usuario y grupo sin privilegios
# ────────────────────────────────────────────────
# Pregunta: ¿Por qué usamos UID 1000?
# Respuesta: ______________________ (match típico con usuarios del host = menos problemas de permisos)

RUN groupadd -r appuser --gid=1000 && \
    useradd -r -g appuser --uid=1000 --home-dir=/app appuser

WORKDIR /app

# Paso 5.2: Copiar virtualenv DESDE el builder
# ─────────────────────────────────────────────
# Nota: --chown asigna propiedad a appuser (sin esto, root es el dueño)

COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv
```

#### Paso 6: Código Fuente y Directorios

```dockerfile
# Paso 6.1: Copiar código fuente
# ───────────────────────────────
# Nota: Esta línea va AL FINAL para maximizar cache

COPY --chown=appuser:appuser . .

# Paso 6.2: Crear directorios que la aplicación necesita
RUN mkdir -p logs models data && \
    chown -R appuser:appuser /app

# Paso 6.3: CAMBIAR a usuario non-root (CRÍTICO)
# ───────────────────────────────────────────────
# Pregunta: ¿Por qué USER va DESPUÉS de mkdir/chown?
# Respuesta: ______________________ (appuser no tiene permisos para crear dirs)

USER appuser
```

#### Paso 7: Healthcheck y Comando

```dockerfile
# Paso 7.1: Documentar puerto
EXPOSE 8000

# Paso 7.2: Configurar healthcheck
# ─────────────────────────────────
# Pregunta: ¿Qué hace --start-period?
# Respuesta: ______________________ (tiempo de gracia para que cargue el modelo)

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Paso 7.3: Comando de inicio
CMD ["uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Verificación del Laboratorio

```bash
# Construir la imagen
docker build -t bankchurn:lab .

# Verificar tamaño (objetivo: < 500MB)
docker images bankchurn:lab

# Ejecutar y probar
docker run -d -p 8000:8000 --name bankchurn-test bankchurn:lab

# Esperar 20 segundos y verificar health
sleep 20
docker inspect --format='{{.State.Health.Status}}' bankchurn-test
# Esperado: healthy

# Verificar que corre como non-root
docker exec bankchurn-test whoami
# Esperado: appuser

# Cleanup
docker stop bankchurn-test && docker rm bankchurn-test
```

---

### 13.7.4 🚨 Troubleshooting Preventivo: Los 5 Errores Más Comunes

Estos son los errores que encontrarás al intentar replicar el Dockerfile del portafolio. **Léelos ANTES de empezar** para ahorrar horas de debugging.

#### Error 1: `ModuleNotFoundError: No module named 'src'`

**Cuándo ocurre**: Al ejecutar `docker run` o `uvicorn`.

**Causa raíz**: Falta `ENV PYTHONPATH=/app` o el código no está en `/app`.

**Diagnóstico**:
```bash
# Verificar estructura dentro del contenedor
docker exec -it <container> ls -la /app
# ¿Existe /app/src/? ¿/app/app/?

# Verificar PYTHONPATH
docker exec -it <container> printenv PYTHONPATH
# Esperado: /app
```

**Solución**:
```dockerfile
# Añadir en el runtime stage
ENV PYTHONPATH=/app

# O cambiar el CMD para especificar la ruta
CMD ["python", "-m", "uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0"]
```

---

#### Error 2: `PermissionError: [Errno 13] Permission denied: '/app/logs/app.log'`

**Cuándo ocurre**: La API intenta escribir logs pero falla.

**Causa raíz**: El directorio `/app/logs` pertenece a `root`, pero el proceso corre como `appuser`.

**Diagnóstico**:
```bash
# Verificar permisos
docker exec -it <container> ls -la /app
# ¿El owner es appuser o root?

# Verificar usuario actual
docker exec -it <container> whoami
# Esperado: appuser
```

**Solución**:
```dockerfile
# ANTES de USER appuser, crear directorios y asignar permisos
RUN mkdir -p logs data models && \
    chown -R appuser:appuser /app

USER appuser  # ← DESPUÉS de chown
```

---

#### Error 3: Container `unhealthy` pero la API funciona

**Cuándo ocurre**: `docker ps` muestra "(unhealthy)" pero `curl localhost:8000/health` funciona.

**Causa raíz**: El HEALTHCHECK usa `curl` pero `curl` no está instalado en la imagen.

**Diagnóstico**:
```bash
# Verificar si curl existe
docker exec -it <container> which curl
# Si no hay output, curl no está instalado

# Verificar logs del healthcheck
docker inspect <container> --format='{{json .State.Health}}'
```

**Solución**:
```dockerfile
# Instalar curl en el runtime stage
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*
```

---

#### Error 4: Build tarda 15+ minutos (cache no funciona)

**Cuándo ocurre**: Cada cambio de código dispara reinstalación de pip.

**Causa raíz**: `COPY . .` está ANTES de `pip install`.

**Diagnóstico**:
```bash
# Observar output del build
docker build -t test .
# ¿Ves "CACHED" en el step de pip install?
# Si no, el cache está roto
```

**Solución**:
```dockerfile
# ❌ MALO: Cualquier cambio invalida todo
COPY . .
RUN pip install -r requirements.txt

# ✅ BUENO: requirements primero, código después
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .  # ← Cambios aquí NO invalidan pip
```

---

#### Error 5: Imagen de 1.5GB después del multi-stage

**Cuándo ocurre**: Usaste multi-stage pero la imagen sigue enorme.

**Causa raíz**: El `.dockerignore` no excluye datos, notebooks, o `.git`.

**Diagnóstico**:
```bash
# Ver historial de layers
docker history bankchurn:latest --format "{{.Size}}\t{{.CreatedBy}}" | head -20
# ¿Hay layers de 500MB+? ¿Qué comando las creó?

# Verificar qué está copiando
docker build -t test . 2>&1 | grep "COPY"
```

**Solución**: Crear/actualizar `.dockerignore`:
```dockerignore
# .dockerignore - CRÍTICO para imágenes pequeñas
.git
.gitignore
data/
notebooks/
tests/
*.md
*.ipynb
__pycache__
.venv/
mlruns/
.dvc/
```

---

### 13.7.5 📋 Checklist de Replicación Completa

Usa esta lista para verificar que tu Dockerfile replica correctamente el del portafolio:

```markdown
# Checklist: Dockerfile BankChurn-Predictor

## Arquitectura
- [ ] Multi-stage build (builder + runtime)
- [ ] Base image: python:3.11-slim (NO alpine, NO full)
- [ ] Builder: instala gcc, build-essential
- [ ] Runtime: NO tiene compiladores

## Optimización
- [ ] .dockerignore excluye: .git, data/, tests/, notebooks/, __pycache__
- [ ] COPY requirements.txt ANTES de COPY código
- [ ] pip install --no-cache-dir
- [ ] rm -rf /var/lib/apt/lists/* después de apt-get
- [ ] Imagen final < 500MB (verificar con docker images)

## Seguridad
- [ ] Usuario non-root creado (appuser con UID 1000)
- [ ] USER appuser DESPUÉS de crear directorios
- [ ] --chown=appuser:appuser en COPY
- [ ] Directorios logs/, data/, models/ con permisos correctos

## Observabilidad
- [ ] HEALTHCHECK configurado (interval, timeout, start-period, retries)
- [ ] curl instalado en runtime (para HEALTHCHECK)
- [ ] EXPOSE 8000 documentado

## Verificación Final
- [ ] docker build completa sin errores
- [ ] docker run levanta el contenedor
- [ ] curl localhost:8000/health retorna 200
- [ ] docker exec <container> whoami retorna "appuser"
- [ ] container aparece como "healthy" en docker ps
```

---

### 13.7.6 📁 Anatomía del `.dockerignore` Real del Portafolio

El archivo `.dockerignore` es TAN importante como el `Dockerfile`. Sin él, tu imagen puede pasar de 350MB a 2GB.

**Archivo**: `BankChurn-Predictor/.dockerignore`

```dockerignore
# ══════════════════════════════════════════════════════════════════════════════
# .dockerignore del Portafolio - Comentado línea por línea
# ══════════════════════════════════════════════════════════════════════════════

# Sección 1: Control de Versiones
# ────────────────────────────────
# .git
#   ├─ Excluye el directorio .git completo (~50-500MB en proyectos grandes)
#   ├─ El historial de commits NO es necesario en el contenedor
#   └─ ¿Qué pasa sin esto? → Imagen 500MB más grande sin beneficio
.git
.gitignore
.dvc
.dvcignore
# ↑ DVC también tiene su propio directorio pesado con cache de datos

# Sección 2: Python - Archivos Generados
# ───────────────────────────────────────
# __pycache__
#   ├─ Bytecode compilado de Python (*.pyc)
#   ├─ Se regenera automáticamente cuando Python importa el módulo
#   └─ ¿Qué pasa sin esto? → Archivos innecesarios + posibles conflictos de versión
__pycache__
*.pyc
*.pyo
*.pyd
.Python

# Sección 3: Entornos Virtuales
# ─────────────────────────────
# env/, venv/, .venv/
#   ├─ El virtualenv del HOST no debe ir al contenedor
#   ├─ El contenedor tiene su PROPIO venv en /opt/venv
#   ├─ Tamaño típico: 200MB-1GB dependiendo de las dependencias
#   └─ ¿Qué pasa sin esto? → Conflictos de rutas + imagen enorme
env/
venv/
.venv/
pip-log.txt
pip-delete-this-directory.txt

# Sección 4: Testing y Calidad de Código
# ───────────────────────────────────────
# tests/
#   ├─ Los tests NO se ejecutan en producción
#   ├─ pytest, coverage, etc. solo para desarrollo/CI
#   └─ ¿Qué pasa sin esto? → Código innecesario en producción (attack surface mayor)
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.log
.pytest_cache/
.mypy_cache/
.flake8
tests/
# ↑ IMPORTANTE: Excluir tests/ reduce imagen Y attack surface

# Sección 5: Datos y Artefactos Pesados
# ─────────────────────────────────────
# data/, models/, results/, mlruns/
#   ├─ Datos se montan como VOLÚMENES, no se copian a la imagen
#   ├─ models/ se monta en runtime: -v ./models:/app/models:ro
#   ├─ mlruns/ es el directorio de MLflow (puede ser GB de experimentos)
#   └─ ¿Qué pasa sin esto? → Imagen de 5GB+ con datos de entrenamiento
data/
models/
results/
mlruns/

# Sección 6: Notebooks y Documentación
# ────────────────────────────────────
# notebooks/, *.ipynb
#   ├─ Notebooks son para exploración, no para producción
#   ├─ Pueden contener outputs pesados (imágenes, tablas)
#   └─ ¿Qué pasa sin esto? → Notebooks de 50MB+ innecesarios en imagen
notebooks/
docs/
*.md
# ↑ Excluimos .md EXCEPTO README.md si lo necesitas (ver patrón negativo abajo)
# Para incluir README.md: añadir línea "!README.md" DESPUÉS de "*.md"
```

**Patrones Avanzados de `.dockerignore`**:

```dockerignore
# Patrón 1: Excluir TODO excepto algo específico
*.md
!README.md
# ↑ Excluye todos los .md EXCEPTO README.md

# Patrón 2: Excluir subdirectorios pero no el directorio mismo
data/*
!data/.gitkeep
# ↑ Excluye contenido de data/ pero mantiene el directorio

# Patrón 3: Excluir por profundidad
**/__pycache__
# ↑ Excluye __pycache__ en CUALQUIER nivel de profundidad

# Patrón 4: Excluir archivos temporales
*.tmp
*.temp
*~
.DS_Store
# ↑ Archivos del sistema operativo que no deben ir al contenedor
```

---

### 13.7.7 🔗 Conexión Docker → Kubernetes: De Imagen a Producción

El Dockerfile que construyes es solo el primer paso. En producción, esa imagen se despliega en Kubernetes. Veamos cómo se conectan:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    FLUJO: DOCKERFILE → KUBERNETES                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  1. BUILD                          2. PUSH                        3. DEPLOY     │
│  ─────────                         ─────                          ───────       │
│  ┌──────────────┐                 ┌──────────────┐              ┌────────────┐ │
│  │ Dockerfile   │  docker build   │ Image        │  docker push │ K8s        │ │
│  │              │ ───────────────►│ bankchurn    │ ────────────►│ Deployment │ │
│  │ Multi-stage  │                 │ :v2.0.0      │              │            │ │
│  │ ~350MB       │                 │              │              │ 3 replicas │ │
│  └──────────────┘                 └──────────────┘              └────────────┘ │
│                                           │                            │        │
│  BankChurn-Predictor/                     │                            │        │
│  Dockerfile                        Registry                   k8s/bankchurn-   │
│                                   (DockerHub/                 deployment.yaml  │
│                                    GitHub)                                      │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

**Extracto de `k8s/bankchurn-deployment.yaml` del Portafolio**:

```yaml
# k8s/bankchurn-deployment.yaml - Cómo Kubernetes usa tu imagen Docker
# ═══════════════════════════════════════════════════════════════════

apiVersion: apps/v1
kind: Deployment
metadata:
  name: bankchurn-predictor
  namespace: ml-portfolio
  # ↑ namespace: aísla recursos del resto del cluster
spec:
  replicas: 3
  # ↑ replicas: 3 instancias del contenedor para alta disponibilidad
  #   ¿Por qué 3? → Tolerancia a fallos: si 1 cae, quedan 2
  
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1       # ← Máximo 1 pod extra durante update
      maxUnavailable: 1 # ← Máximo 1 pod no disponible durante update
    # ↑ RollingUpdate: depliegue sin downtime (pods se actualizan uno a uno)
  
  template:
    spec:
      containers:
      - name: bankchurn-api
        image: duqueom/bankchurn-predictor:v2.0.0
        # ↑ ESTA es la imagen que construiste con tu Dockerfile
        #   El tag :v2.0.0 permite rollback a versiones anteriores
        
        imagePullPolicy: Always
        # ↑ Always: siempre descarga la imagen (útil para latest o CI/CD)
        #   IfNotPresent: solo si no existe localmente (más rápido)
        
        ports:
        - containerPort: 8000
          # ↑ Mismo puerto que EXPOSE 8000 en Dockerfile
        
        env:
        - name: MODEL_PATH
          value: "/app/models/model.pkl"
          # ↑ Variables de entorno inyectadas en runtime (no hardcodeadas en imagen)
        
        resources:
          requests:
            memory: "512Mi"  # ← Mínimo garantizado de RAM
            cpu: "250m"      # ← Mínimo garantizado de CPU (250 millicores = 0.25 cores)
          limits:
            memory: "1Gi"    # ← Máximo permitido de RAM
            cpu: "1000m"     # ← Máximo permitido de CPU (1 core)
          # ↑ resources: K8s usa esto para scheduling y evitar que un pod "mate" al nodo
        
        livenessProbe:
          httpGet:
            path: /health    # ← Mismo endpoint que HEALTHCHECK en Dockerfile
            port: 8000
          initialDelaySeconds: 30  # ← Espera 30s antes del primer check
          periodSeconds: 10        # ← Cada 10s
          failureThreshold: 3      # ← 3 fallos = reinicia el pod
          # ↑ livenessProbe: K8s reinicia el pod si /health no responde
        
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10  # ← Menos tiempo que liveness
          periodSeconds: 5
          # ↑ readinessProbe: K8s no envía tráfico hasta que el pod esté ready
        
        volumeMounts:
        - name: model-storage
          mountPath: /app/models  # ← Misma ruta que MODEL_PATH
          readOnly: true          # ← Solo lectura (seguridad)
          # ↑ volumeMounts: modelos NO van en la imagen, se montan en runtime
      
      volumes:
      - name: model-storage
        persistentVolumeClaim:
          claimName: ml-models-pvc
          # ↑ PVC: almacenamiento persistente para modelos (sobrevive a reinicios)
```

**Conexiones clave Dockerfile ↔ K8s**:

| Dockerfile | Kubernetes Deployment |
|------------|----------------------|
| `EXPOSE 8000` | `containerPort: 8000` |
| `HEALTHCHECK` | `livenessProbe` + `readinessProbe` |
| `USER appuser` | `securityContext.runAsUser: 1000` |
| `ENV MODEL_PATH` | `env: - name: MODEL_PATH` |
| `CMD ["uvicorn"...]` | (hereda del Dockerfile) |
| `mkdir -p models` | `volumeMounts.mountPath: /app/models` |

---

### 13.7.8 📊 Métricas de Éxito: ¿Cómo Saber que lo Hiciste Bien?

Después de completar el laboratorio, verifica estas métricas:

```bash
# ══════════════════════════════════════════════════════════════════════════════
# Script de verificación: check_docker_quality.sh
# Ejecuta después de construir tu imagen
# ══════════════════════════════════════════════════════════════════════════════

#!/bin/bash
# Script para verificar la calidad de tu imagen Docker
# Uso: bash check_docker_quality.sh bankchurn:latest

IMAGE_NAME=${1:-"bankchurn:latest"}

echo "🔍 Verificando imagen: $IMAGE_NAME"
echo "═══════════════════════════════════════════════════════════════"

# 1. Verificar tamaño de imagen
# ─────────────────────────────
SIZE=$(docker images $IMAGE_NAME --format "{{.Size}}")
echo "📦 Tamaño de imagen: $SIZE"
# Objetivo: < 500MB para imágenes de ML

# 2. Verificar que NO tiene compiladores
# ──────────────────────────────────────
echo ""
echo "🔧 Verificando ausencia de compiladores..."
docker run --rm $IMAGE_NAME which gcc 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ❌ PROBLEMA: gcc encontrado en imagen runtime"
else
    echo "   ✅ OK: gcc no presente (multi-stage funcionó)"
fi

# 3. Verificar usuario non-root
# ─────────────────────────────
echo ""
echo "👤 Verificando usuario..."
USER=$(docker run --rm $IMAGE_NAME whoami)
echo "   Usuario actual: $USER"
if [ "$USER" == "appuser" ]; then
    echo "   ✅ OK: Corre como non-root"
else
    echo "   ❌ PROBLEMA: Corre como $USER (debería ser appuser)"
fi

# 4. Verificar PYTHONPATH
# ───────────────────────
echo ""
echo "🐍 Verificando PYTHONPATH..."
PYPATH=$(docker run --rm $IMAGE_NAME printenv PYTHONPATH)
echo "   PYTHONPATH: $PYPATH"
if [ "$PYPATH" == "/app" ]; then
    echo "   ✅ OK: PYTHONPATH configurado"
else
    echo "   ❌ PROBLEMA: PYTHONPATH incorrecto o no configurado"
fi

# 5. Verificar estructura de directorios
# ──────────────────────────────────────
echo ""
echo "📁 Verificando estructura..."
docker run --rm $IMAGE_NAME ls -la /app | head -10

# 6. Verificar healthcheck
# ────────────────────────
echo ""
echo "💓 Verificando HEALTHCHECK configurado..."
HEALTH=$(docker inspect $IMAGE_NAME --format='{{.Config.Healthcheck}}')
if [ "$HEALTH" != "<nil>" ]; then
    echo "   ✅ OK: HEALTHCHECK presente"
    echo "   Configuración: $HEALTH"
else
    echo "   ❌ PROBLEMA: Sin HEALTHCHECK configurado"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ Verificación completada"
```

**Tabla de Métricas Objetivo**:

| Métrica | ❌ Malo | ⚠️ Aceptable | ✅ Excelente |
|---------|--------|--------------|-------------|
| **Tamaño de imagen** | > 1GB | 500MB-1GB | < 500MB |
| **Tiempo de build (con cache)** | > 5min | 1-5min | < 1min |
| **Tiempo de build (sin cache)** | > 15min | 5-15min | < 5min |
| **Usuario en runtime** | root | - | appuser (non-root) |
| **HEALTHCHECK** | ausente | presente sin start-period | completo |
| **Layers de imagen** | > 20 | 10-20 | < 10 |

---

<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en Docker para ML

En ML es muy común tener imágenes gigantes, problemas de permisos o contenedores que “funcionan en mi máquina pero no en producción”.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) Imágenes demasiado grandes

**Síntomas típicos**

- `docker images` muestra tamaños > 1GB.
- Push/pull al registry tarda mucho o falla por timeout.

**Cómo identificarlo**

- Compara tu Dockerfile con los ejemplos `python:3.11` vs `python:3.11-slim` del módulo.
- Revisa si estás copiando todo el repo (`COPY . .`) sin `.dockerignore`.

**Cómo corregirlo**

- Usa bases `slim` y **multi-stage builds**.
- Añade un `.dockerignore` que excluya datos, notebooks, tests y `.venv`.

---

### 2) Errores de permisos al correr como non-root

**Síntomas típicos**

- El contenedor arranca pero falla al leer modelos, logs o escribir en directorios.
- Mensajes tipo `Permission denied: '/app/models/model.joblib'`.

**Cómo identificarlo**

- Verifica que después de copiar archivos hagas `chown` al usuario de la app.
- Revisa que `USER appuser` aparezca **después** de ajustar permisos.

**Cómo corregirlo**

- Asegúrate de:
  ```dockerfile
  RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
  USER appuser
  ```
- Monta volúmenes con permisos compatibles (por ejemplo, propiedad UID 1000 en host).

---

### 3) Modelo o artefactos no encontrados dentro del contenedor

**Síntomas típicos**

- La API levanta pero responde 500 porque no encuentra el modelo (`FileNotFoundError`).

**Cómo identificarlo**

- Revisa las rutas de `COPY` en el Dockerfile y las rutas que tu código usa (`./models`, `./artifacts`).

**Cómo corregirlo**

- Copia los artefactos a la ruta esperada o monta un volumen de solo lectura:
  ```yaml
  volumes:
    - ./BankChurn-Predictor/models:/app/models:ro
  ```

---

### 4) Contenedores que arrancan pero el healthcheck falla

**Síntomas típicos**

- El servicio aparece como "unhealthy" en `docker ps`.

**Cómo identificarlo**

- Examina el `HEALTHCHECK` y verifica que la URL y puerto sean correctos.

**Cómo corregirlo**

- Asegúrate de que el endpoint `/health` exista y escuche en el mismo puerto que expones.
- Ajusta tiempos de `start-period` si el modelo tarda más en cargar.

---

### 5) Patrón general de debugging con Docker

1. Inspecciona el contenedor en ejecución con `docker exec -it <container> /bin/bash`.
2. Navega por `/app` para verificar que el código, modelos y configs estén donde esperas.
3. Comprueba permisos (`ls -l`) y usuario actual (`whoami`).
4. Si la imagen es muy grande, revisa el historial de capas con `docker history`.

Con este enfoque, tus imágenes Docker serán reproducibles, ligeras y listas para producción.

---

<a id="checkpoint"></a>

## ✅ Checkpoint

- [ ] Tu Dockerfile usa base `slim` (o alternativa justificada) y evita `COPY . .` sin `.dockerignore`
- [ ] Tienes `.dockerignore` que excluye `data/`, `notebooks/`, `tests/`, `.venv/`
- [ ] El contenedor corre como usuario no-root
- [ ] Puedes construir y correr la imagen (`docker build` + `docker run`)
- [ ] La API responde a `/health` (o endpoint equivalente)

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **Multi-stage builds**: Explica cómo reducen tamaño de imagen.

2. **Layer caching**: Por qué el orden de instrucciones importa.

3. **Security**: No correr como root, no incluir secrets en imagen.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Imágenes grandes | Multi-stage + slim base images |
| Secrets | Usa build args o secrets mounting |
| Debugging | Usa `docker exec -it container bash` |
| Producción | Healthchecks obligatorios |

### Dockerfile Optimizado

```dockerfile
# Stage 1: Build
FROM python:3.11-slim AS builder
COPY requirements.txt .
RUN pip wheel --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim
COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/*
COPY src/ /app/src/
USER nobody
HEALTHCHECK CMD curl -f http://localhost:8000/health
```


---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **Docker Tutorial for Beginners** | TechWorld Nana | 2.5h | [YouTube](https://www.youtube.com/watch?v=3c-iBn73dDE) |
| 🔴 | **Multi-stage Docker Builds** | Docker | 15 min | [YouTube](https://www.youtube.com/watch?v=zpkqNPwEzac) |
| 🟡 | **Docker Compose Tutorial** | TechWorld Nana | 1h | [YouTube](https://www.youtube.com/watch?v=HG6yIjZapSA) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) | Guía oficial |
| 🟡 | [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/) | Optimización de imágenes |

---

## ⚖️ Decisión Técnica: ADR-006 Docker Multi-stage

**Contexto**: Necesitamos imágenes Docker pequeñas y seguras para producción.

**Decisión**: Usar multi-stage builds con bases slim.

**Alternativas Consideradas**:
- **Single-stage**: Más simple pero imágenes ~2GB
- **Distroless**: Más seguro pero difícil de debuggear
- **Alpine**: Más pequeño pero problemas con algunas libs Python

**Consecuencias**:
- ✅ Imágenes de ~500MB vs ~2GB
- ✅ Sin herramientas de build en runtime
- ✅ Más rápido de desplegar
- ❌ Dockerfiles más complejos

---

## 🔧 Ejercicios del Módulo

### Ejercicio 13.1: Dockerfile Multi-stage
**Objetivo**: Crear Dockerfile optimizado para ML API.
**Dificultad**: ⭐⭐⭐

```dockerfile
# TU TAREA: Crear Dockerfile que:
# 1. Use multi-stage build
# 2. Instale dependencias en stage 1
# 3. Copie solo lo necesario a stage 2
# 4. Use usuario non-root
# 5. Incluya healthcheck
```

<details>
<summary>💡 Ver solución</summary>

```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /build

# Instalar dependencias de build
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copiar solo requirements primero (mejor cache)
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

WORKDIR /app

# Instalar wheels pre-compilados
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels

# Crear usuario non-root
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

# Copiar código
COPY --chown=appuser:appuser src/ ./src/
COPY --chown=appuser:appuser app/ ./app/
COPY --chown=appuser:appuser artifacts/ ./artifacts/

# Cambiar a non-root
USER appuser

# Variables de entorno
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Puerto
EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Comando
CMD ["uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000"]
```
</details>

---

### Ejercicio 13.2: Docker Compose Stack
**Objetivo**: Orquestar servicios ML con docker-compose.
**Dificultad**: ⭐⭐⭐

```yaml
# docker-compose.yml
# TU TAREA: Crear stack con:
# - API ML
# - MLflow server
# - Prometheus
# - Volúmenes persistentes
```

<details>
<summary>💡 Ver solución</summary>

```yaml
version: '3.8'

services:
  api:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - ./artifacts:/app/artifacts:ro
    environment:
      - MLFLOW_TRACKING_URI=http://mlflow:5000
    depends_on:
      - mlflow
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  mlflow:
    image: ghcr.io/mlflow/mlflow:v2.9.0
    ports:
      - "5000:5000"
    volumes:
      - mlflow_data:/mlflow
    command: >
      mlflow server
      --host 0.0.0.0
      --port 5000
      --backend-store-uri sqlite:///mlflow/mlflow.db
      --default-artifact-root /mlflow/artifacts

  prometheus:
    image: prom/prometheus:v2.47.0
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus

volumes:
  mlflow_data:
  prometheus_data:
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **Multi-stage Build** | Dockerfile con múltiples FROM para separar build y runtime |
| **Docker Compose** | Herramienta para definir y ejecutar multi-container apps |
| **Non-root User** | Usuario sin privilegios para mayor seguridad |
| **Healthcheck** | Comando que verifica que el contenedor está healthy |

---

<div align="center">

**Siguiente módulo** → [14. FastAPI](14_FASTAPI.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
