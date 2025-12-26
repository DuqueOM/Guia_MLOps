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

## 📺 Recursos Externos Recomendados

> Ver [RECURSOS_POR_MODULO.md](RECURSOS_POR_MODULO.md) para la lista completa.

| 🏷️ | Recurso | Tipo |
|:--:|:--------|:-----|
| 🔴 | [Docker Tutorial - TechWorld Nana](https://www.youtube.com/watch?v=3c-iBn73dDE) | Video |
| 🟡 | [Multi-stage Builds](https://www.youtube.com/watch?v=zpkqNPwEzac) | Video |

**Documentación oficial:**
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

---

## 🔗 Referencias del Glosario

Ver [21_GLOSARIO.md](21_GLOSARIO.md) para definiciones de:
- **Multi-stage Build**: Separar build de runtime
- **Docker Compose**: Orquestar múltiples contenedores
- **Non-root user**: Seguridad en contenedores

---

## 📋 Plantillas Relacionadas

Ver [templates/](templates/index.md) para plantillas listas:
- [Dockerfile](templates/Dockerfile) — Multi-stage completo para ML APIs
- [Dockerfile_template](templates/Dockerfile_template) — Versión simplificada
- [docker-compose.yml](templates/docker-compose.yml) — Stack con servicios

---

<a id="ejercicio"></a>

## ✅ Ejercicios

Ver [EJERCICIOS.md](EJERCICIOS.md) - Módulo 13:
- **13.1**: Dockerfile multi-stage
- **13.2**: Docker Compose para stack ML

---

[← CI/CD GitHub Actions](12_CI_CD.md) | [Siguiente: FastAPI Producción →](14_FASTAPI.md)

</div>
