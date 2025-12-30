# ════════════════════════════════════════════════════════════════════════════════
# DOCKERFILE - ML Model Serving
# Multi-stage build optimizado para modelos ML
# ════════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────────
# Stage 1: Builder - Solo para compilar dependencias
# ─────────────────────────────────────────────────────────────────────────────────
FROM python:3.10-slim as builder
# python:3.10-slim: imagen base ligera (~150MB vs ~900MB de python:3.10)
# "as builder": nombra este stage para referenciarlo después

WORKDIR /app
# WORKDIR: establece directorio de trabajo (crea si no existe)

# Instalar dependencias de sistema para compilación
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*
# gcc: compilador C (para numpy, pandas, etc.)
# python3-dev: headers de Python para compilación
# rm -rf /var/lib/apt/lists/*: limpia cache apt (reduce tamaño)

# Crear virtualenv para aislar dependencias
RUN python -m venv /opt/venv
# venv en /opt/venv: ubicación estándar para copiar al runtime stage
ENV PATH="/opt/venv/bin:$PATH"
# PATH: asegura que pip/python usen el venv

# Instalar dependencias Python
COPY requirements.txt .
# COPY: copia archivo local al contenedor
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
# --no-cache-dir: no guarda cache de pip (reduce tamaño)

# ─────────────────────────────────────────────────────────────────────────────────
# Stage 2: Runtime - Imagen final de producción (sin herramientas de compilación)
# ─────────────────────────────────────────────────────────────────────────────────
FROM python:3.10-slim as runtime
# Nueva imagen limpia: NO incluye gcc ni python3-dev del builder

WORKDIR /app

# Copiar virtualenv del builder (reduce tamaño significativamente)
COPY --from=builder /opt/venv /opt/venv
# --from=builder: copia SOLO el venv compilado, no gcc ni cache
ENV PATH="/opt/venv/bin:$PATH"

# Copiar código fuente
COPY src/ ./src/
# Copia directorio src/ local al contenedor
COPY models/ ./models/
# Copia modelos entrenados (.pkl, .joblib)
COPY configs/ ./configs/
# Copia archivos de configuración (.yaml)

# Crear usuario no-root por seguridad
RUN useradd --create-home --shell /bin/bash appuser && \
    chown -R appuser:appuser /app
# useradd: crea usuario 'appuser' (best practice: no ejecutar como root)
USER appuser
# USER: cambia al usuario no-root para todos los comandos siguientes

# Variables de entorno
ENV PYTHONPATH=/app \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    MODEL_PATH=/app/models/model.pkl \
    CONFIG_PATH=/app/configs/default.yaml
# PYTHONPATH: permite imports desde /app
# PYTHONUNBUFFERED=1: logs en tiempo real (sin buffer)
# PYTHONDONTWRITEBYTECODE=1: no crea .pyc (reduce tamaño)

# Puerto de la API
EXPOSE 8000
# EXPOSE: documenta el puerto (no lo abre, solo metadata)

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
# HEALTHCHECK: Docker/K8s verifica que el contenedor está vivo
# --interval=30s: verifica cada 30 segundos
# --retries=3: marca unhealthy después de 3 fallos consecutivos

# Comando de inicio
CMD ["uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
# CMD: comando por defecto al ejecutar el contenedor
# uvicorn: servidor ASGI de producción para FastAPI
# --host 0.0.0.0: escucha en todas las interfaces (necesario en Docker)

# ─────────────────────────────────────────────────────────────────────────────────
# Notas de uso:
# ─────────────────────────────────────────────────────────────────────────────────
# Build:
#   docker build -t ml-model:latest .
#
# Run:
#   docker run -p 8000:8000 ml-model:latest
#
# Run con volumen para modelos:
#   docker run -p 8000:8000 -v $(pwd)/models:/app/models ml-model:latest
#
# Run con variables de entorno:
#   docker run -p 8000:8000 -e MODEL_PATH=/app/models/v2.pkl ml-model:latest
#
# Verificar tamaño:
#   docker images ml-model:latest
#   # Target: < 500MB
# ─────────────────────────────────────────────────────────────────────────────────
