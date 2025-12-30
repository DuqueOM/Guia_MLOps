# 10. Experiment Tracking con MLflow
 
 <a id="00-prerrequisitos"></a>
 
 ## 0.0 Prerrequisitos
 
 - Tener al menos 1 proyecto del portafolio con:
   - `artifacts/training_results.json` (o equivalente)
   - Un modelo serializado (`model.pkl`, `model.joblib`, etc.)
 - Poder instalar MLflow en tu entorno del proyecto.
 
 ---
 
 <a id="01-protocolo-e-como-estudiar-este-modulo"></a>
 
 ## 0.1 🧠 Protocolo E: Cómo estudiar este módulo
 
 - **Antes de empezar**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define tu *output mínimo* (1 run visible y comparable).
 - **Durante el debugging**: si te atoras >15 min (tracking_uri, artifacts, registry), registra el caso en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
 - **Al cierre de semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para auditar trazabilidad (runs, params, métricas, artifacts).
 
 ---
 
 <a id="02-entregables-verificables-minimo-viable"></a>
 
 ## 0.2 ✅ Entregables verificables (mínimo viable)
 
 - [ ] Un experimento MLflow con:
   - params (ej. hiperparámetros o `run_type`)
   - métricas (ej. `test_f1`, `test_auc`)
   - artifacts (ej. `training_results.json`, `config.yaml`)
 - [ ] Evidencia (UI o `mlflow ui`) de poder comparar 2 runs.
 - [ ] 1 entrada en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** si hubo bloqueo real.
 
 ---
 
 <a id="03-puente-teoria-codigo-portafolio"></a>
 
 ## 0.3 🧩 Puente teoría ↔ código (Portafolio)
 
 - **Concepto**: experiment tracking (params/metrics/artifacts + comparación + registry)
 - **Archivo**: `scripts/run_mlflow.py`, `docker-compose.mlflow.yml`, `configs/config.yaml`
 - **Prueba**: entrenar → loguear → abrir UI → comparar runs
 
 ## 🎯 Objetivo del Módulo
 
 Implementar tracking de experimentos como lo hace el portafolio con `run_mlflow.py`.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  SIN MLFLOW:                           CON MLFLOW:                           ║
║  ───────────                           ────────────                          ║
║  "¿Qué hiperparámetros usé hace        "MLflow run abc123: RF con            ║
║   2 semanas cuando obtuve F1=0.85?"    n_estimators=200, F1=0.85"            ║
║                                                                              ║
║  "¿Dónde guardé ese modelo bueno?"     "Artifacts en run abc123/model.pkl"   ║
║                                                                              ║
║  "¿Por qué este modelo es peor?"       "Comparar runs en UI: diff params"    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### 🧩 Cómo se aplica en este portafolio

- En **BankChurn-Predictor** ya tienes:
  - `scripts/run_mlflow.py` como script de logging posterior al entrenamiento.
  - Configuración de MLflow en `configs/config.yaml` y `src/bankchurn/config.py`.
 - El archivo `docker-compose.mlflow.yml` en la raíz del repo levanta un servidor MLflow
   real que puedes usar para practicar este módulo.
 - El mismo patrón de logging puedes aplicarlo a **CarVision** y **TelecomAI**, usando
   sus `artifacts/` y modelos entrenados como fuente de métricas y artifacts.

---

## 📋 Contenido

- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
1. [Conceptos de MLflow](#101-conceptos-de-mlflow)
2. [Setup y Configuración](#102-setup-y-configuracion)
3. [Logging de Experimentos](#103-logging-de-experimentos)
4. [Model Registry](#104-model-registry)
5. [Código Real del Portafolio](#105-codigo-real-del-portafolio)
6. [🔬 Ingeniería Inversa Pedagógica: MLflow Producción](#106-ingenieria-inversa-mlflow) ⭐ NUEVO
- [Errores habituales](#errores-habituales)
- [✅ Ejercicio](#ejercicio)
- [✅ Checkpoint](#checkpoint)

---

<a id="101-conceptos-de-mlflow"></a>

## 10.1 Conceptos de MLflow

### Los 4 Componentes

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          MLFLOW COMPONENTS                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. TRACKING                    2. PROJECTS                                 │
│  ─────────────                  ────────────                                │
│  • Log params, metrics          • Empaquetar código                         │
│  • Guardar artifacts            • MLproject file                            │
│  • Comparar runs                • Reproducibilidad                          │
│                                                                             │
│  3. MODELS                      4. REGISTRY                                 │
│  ──────────                     ─────────────                               │
│  • Formato estándar             • Versionado de modelos                     │
│  • Flavors (sklearn, pytorch)   • Staging → Production                      │
│  • Serving                      • Aprobaciones                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

EN ESTE PORTAFOLIO USAMOS: Tracking + Registry
```

### Jerarquía de MLflow

```
MLflow Server
└── Experiment: "BankChurn"
    ├── Run: abc123 (2024-01-15)
    │   ├── Parameters: {n_estimators: 200, max_depth: 10}
    │   ├── Metrics: {f1: 0.65, auc: 0.88}
    │   └── Artifacts: [model.pkl, config.yaml]
    │
    ├── Run: def456 (2024-01-16)
    │   ├── Parameters: {n_estimators: 200, max_depth: 15}
    │   ├── Metrics: {f1: 0.62, auc: 0.86}
    │   └── Artifacts: [model.pkl, config.yaml]
    │
    └── Run: ghi789 (2024-01-17) ← MEJOR
        ├── Parameters: {n_estimators: 200, max_depth: 10}
        ├── Metrics: {f1: 0.65, auc: 0.88}
        └── Artifacts: [model.pkl, config.yaml]
```

---

<a id="102-setup-y-configuracion"></a>

## 10.2 Setup y Configuración

### Opción 1: Local (File Store)

```python
# Más simple, para desarrollo local
import mlflow

mlflow.set_tracking_uri("file:./mlruns")  # Guarda en carpeta local
mlflow.set_experiment("my-experiment")
```

### Opción 2: Servidor MLflow (Producción)

```yaml
# docker-compose.mlflow.yml del portafolio
services:
  mlflow:
    image: ghcr.io/mlflow/mlflow:v2.9.2
    ports:
      - "5000:5000"
    volumes:
      - mlflow-artifacts:/mlflow
    command: >
      mlflow server
      --backend-store-uri sqlite:///mlflow/mlflow.db
      --default-artifact-root /mlflow/artifacts
      --host 0.0.0.0
      --port 5000
```

```python
# Conectar al servidor
import mlflow

mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment("BankChurn")
```

### Configuración en el Portafolio

```yaml
# configs/config.yaml (BankChurn)
mlflow:
  tracking_uri: "file:./mlruns"      # Local para desarrollo
  experiment_name: "bankchurn"
  enabled: true
```

```python
# src/bankchurn/config.py
class MLflowConfig(BaseModel):
    """MLflow tracking configuration."""
    tracking_uri: str = "file:./mlruns"
    experiment_name: str = "bankchurn"
    enabled: bool = True
```

---

<a id="103-logging-de-experimentos"></a>

## 10.3 Logging de Experimentos

### API Básica

```python
import mlflow                            # Cliente de MLflow para tracking.

# Iniciar un run
with mlflow.start_run(run_name="experiment-1"):  # Context manager: auto-cierra el run al salir.
    
    # 1. LOG PARAMETERS (hiperparámetros, config)
    mlflow.log_param("n_estimators", 200)        # log_param: registra UN parámetro (key-value).
    mlflow.log_param("max_depth", 10)            # Los params son strings/números, no objetos.
    mlflow.log_params({                          # log_params: registra MÚLTIPLES a la vez.
        "learning_rate": 0.1,
        "model_type": "random_forest"
    })
    
    # 2. LOG METRICS (resultados)
    mlflow.log_metric("f1_score", 0.65)          # log_metric: registra UNA métrica numérica.
    mlflow.log_metric("auc_roc", 0.88)           # Las métricas se pueden comparar en la UI.
    mlflow.log_metrics({                         # log_metrics: múltiples a la vez.
        "precision": 0.70,
        "recall": 0.61
    })
    
    # 3. LOG ARTIFACTS (archivos)
    mlflow.log_artifact("configs/config.yaml")   # log_artifact: sube archivo al servidor MLflow.
    mlflow.log_artifact("artifacts/training_results.json")  # Útil para reproducir el experimento.
    
    # 4. LOG MODEL (modelo serializado con metadata)
    mlflow.sklearn.log_model(                    # sklearn: "flavor" específico para modelos sklearn.
        pipeline,                                # El objeto Pipeline fitted.
        artifact_path="model",                   # Subcarpeta dentro de artifacts del run.
        registered_model_name="BankChurnClassifier"  # Si existe, crea nueva versión; si no, lo crea.
    )
```

### Métricas por Época/Paso

```python
# Para modelos que entrenan por épocas
for epoch in range(100):
    train_loss = train_one_epoch()
    val_loss = validate()
    
    mlflow.log_metrics({
        "train_loss": train_loss,
        "val_loss": val_loss
    }, step=epoch)  # ← step permite graficar evolución
```

---

<a id="104-model-registry"></a>

## 10.4 Model Registry

### Registrar un Modelo

```python
# Durante el run
mlflow.sklearn.log_model(
    pipeline,
    artifact_path="model",
    registered_model_name="BankChurnClassifier"  # ← Registra automáticamente
)

# O después del run
mlflow.register_model(
    model_uri=f"runs:/{run_id}/model",
    name="BankChurnClassifier"
)
```

### Transiciones de Estado

```python
from mlflow.tracking import MlflowClient

client = MlflowClient()

# Promover a Staging
client.transition_model_version_stage(
    name="BankChurnClassifier",
    version=1,
    stage="Staging"
)

# Promover a Production (después de validación)
client.transition_model_version_stage(
    name="BankChurnClassifier",
    version=1,
    stage="Production"
)
```

### Cargar Modelo desde Registry

```python
# Cargar versión específica
model = mlflow.sklearn.load_model("models:/BankChurnClassifier/1")

# Cargar stage específico
model = mlflow.sklearn.load_model("models:/BankChurnClassifier/Production")

# Cargar último modelo (latest)
model = mlflow.sklearn.load_model("models:/BankChurnClassifier/latest")
```

---

<a id="105-codigo-real-del-portafolio"></a>

## 10.5 Código Real del Portafolio

### scripts/run_mlflow.py (BankChurn)

```python
#!/usr/bin/env python3
"""Log training results to MLflow.

Este script se ejecuta DESPUÉS del entrenamiento para:
1. Leer resultados de artifacts/training_results.json
2. Calcular métricas de negocio (revenue saved, etc.)
3. Loguear todo a MLflow
4. Opcionalmente registrar el modelo

Uso:
    python scripts/run_mlflow.py

Environment Variables:
    MLFLOW_TRACKING_URI: URI del servidor MLflow
    MLFLOW_EXPERIMENT_NAME: Nombre del experimento
"""

from __future__ import annotations

import json
import os
from pathlib import Path

import joblib

try:
    import mlflow
    import mlflow.sklearn
    from mlflow.tracking import MlflowClient
except ImportError:
    mlflow = None

from sklearn.pipeline import Pipeline


def main() -> None:
    # Configuración desde environment
    tracking_uri = os.getenv("MLFLOW_TRACKING_URI", "file:./mlruns")
    experiment = os.getenv("MLFLOW_EXPERIMENT_NAME", "BankChurn")
    
    # Cargar resultados del entrenamiento
    results_path = Path("artifacts/training_results.json")
    if not results_path.exists():
        print(f"No se encontró {results_path}. Ejecuta training primero.")
        return
    
    data = json.loads(results_path.read_text())
    
    # Extraer métricas
    cv = data.get("cv_results", {})
    test = data.get("test_results", {}).get("metrics", {})
    
    metrics = {}
    for k, v in cv.items():
        if isinstance(v, (int, float)):
            metrics[f"cv_{k}"] = float(v)
    for k, v in test.items():
        if isinstance(v, (int, float)):
            metrics[f"test_{k}"] = float(v)
    
    # Calcular métricas de negocio
    cm = data.get("test_results", {}).get("confusion_matrix")
    if cm and len(cm) == 2:
        tn, fp = cm[0]
        fn, tp = cm[1]
        
        # Parámetros de negocio (configurables)
        clv = float(os.getenv("BC_CLV_USD", "2300"))  # Customer Lifetime Value
        retention_rate = float(os.getenv("BC_RETENTION_RATE", "0.3"))
        
        saved_customers = tp * retention_rate
        saved_revenue = saved_customers * clv
        
        metrics.update({
            "biz_detected_churners": float(tp),
            "biz_saved_customers": saved_customers,
            "biz_saved_revenue_usd": saved_revenue,
            "biz_false_positives": float(fp),
            "biz_missed_churners": float(fn),
        })
    
    if mlflow is None:
        print("MLflow no instalado. Métricas:", metrics)
        return
    
    # Configurar MLflow
    mlflow.set_tracking_uri(tracking_uri)
    mlflow.set_experiment(experiment)
    
    # Crear run
    with mlflow.start_run(run_name="demo-logging"):
        # Log parámetros
        mlflow.log_params({
            "run_type": "demo",
            "source": "run_mlflow.py"
        })
        
        # Log métricas
        mlflow.log_metrics(metrics)
        
        # Log artifacts
        for artifact in [
            Path("artifacts/training_results.json"),
            Path("configs/config.yaml"),
        ]:
            if artifact.exists():
                try:
                    mlflow.log_artifact(str(artifact))
                except PermissionError:
                    print(f"Skipping {artifact}: permission denied")
        
        # Log modelo si existe
        model_path = Path("models/model_v1.0.0.pkl")
        if model_path.exists():
            try:
                obj = joblib.load(model_path)
                if isinstance(obj, dict) and "pipeline" in obj:
                    pipe = obj["pipeline"]
                elif isinstance(obj, Pipeline):
                    pipe = obj
                else:
                    pipe = None
                
                if pipe:
                    mlflow.sklearn.log_model(
                        pipe,
                        artifact_path="model",
                        registered_model_name="BankChurnClassifier"
                    )
            except Exception as e:
                print(f"Model logging skipped: {e}")
        
        print(f"✅ MLflow run logged to {tracking_uri}")
        print(f"   Experiment: {experiment}")
        print(f"   Metrics: {len(metrics)} logged")


if __name__ == "__main__":
    main()
```

### Makefile Integration

```makefile
# Makefile
.PHONY: mlflow-demo mlflow-ui

mlflow-demo:
@echo "Logging to MLflow..."
MLFLOW_TRACKING_URI=file:./mlruns python scripts/run_mlflow.py

mlflow-ui:
@echo "Starting MLflow UI at http://localhost:5000"
mlflow ui --host 0.0.0.0 --port 5000
```

---

<a id="106-ingenieria-inversa-mlflow"></a>

## 10.6 🔬 Ingeniería Inversa Pedagógica: MLflow en Producción Real

> **Objetivo**: Entender CADA decisión arquitectónica detrás del setup de MLflow del portafolio.

Esta sección aplica el método de "Shadow Coder Senior": diseccionamos la infraestructura MLflow real que soporta los 3 proyectos del portafolio.

### 10.6.1 🎯 El "Por Qué" Arquitectónico

¿Por qué el portafolio usa un `docker-compose.mlflow.yml` separado en lugar de un simple `mlflow ui`?

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DECISIONES ARQUITECTÓNICAS DEL PORTAFOLIO                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  PROBLEMA 1: `mlflow ui` guarda todo en archivos locales (SQLite + filesystem)  │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: Pérdida de datos, no escalable, no colaborativo                        │
│  DECISIÓN: PostgreSQL como backend store                                        │
│  RESULTADO: Persistencia robusta, queries SQL, backups fáciles                  │
│  REFERENCIA: docker-compose.mlflow.yml líneas 8-24                              │
│                                                                                 │
│  PROBLEMA 2: Artifacts grandes (modelos) saturan el disco del servidor          │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: Sin espacio, artifacts perdidos, no replicable a la nube               │
│  DECISIÓN: MinIO (S3-compatible) como artifact store                            │
│  RESULTADO: Storage ilimitado, compatible con AWS S3, UI para navegar           │
│  REFERENCIA: docker-compose.mlflow.yml líneas 27-46                             │
│                                                                                 │
│  PROBLEMA 3: Equipos necesitan compartir experimentos y modelos                 │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: "Funciona en mi máquina", modelos duplicados, sin trazabilidad         │
│  DECISIÓN: Servidor MLflow centralizado con Model Registry                      │
│  RESULTADO: Un solo punto de verdad, promoción Staging→Production               │
│  REFERENCIA: docker-compose.mlflow.yml líneas 66-97                             │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 10.6.2 🔍 Anatomía de `docker-compose.mlflow.yml`

**Archivo**: `ML-MLOps-Portfolio/docker-compose.mlflow.yml`

```yaml
version: '3.8'

# ═══════════════════════════════════════════════════════════════════════════════
# SERVICIO 1: PostgreSQL (Backend Store)
# ═══════════════════════════════════════════════════════════════════════════════
services:
  postgres:
    image: postgres:13-alpine                    # Alpine = imagen ligera (~50MB vs 300MB).
    container_name: mlflow-postgres
    environment:
      - POSTGRES_USER=${POSTGRES_USER:-mlflow}   # ${VAR:-default}: usa variable de entorno o default.
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-mlflow_password}
      - POSTGRES_DB=${POSTGRES_DB:-mlflow}
    volumes:
      - postgres_data:/var/lib/postgresql/data  # Volumen nombrado: persiste datos entre reinicios.
    healthcheck:                                 # Docker verifica que Postgres esté LISTO.
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-mlflow}"]
      interval: 10s                              # Chequea cada 10 segundos.
      timeout: 5s                                # Falla si no responde en 5s.
      retries: 5                                 # 5 intentos antes de declarar "unhealthy".
    networks:
      - mlflow-network                           # Red interna: aísla servicios del host.

# ═══════════════════════════════════════════════════════════════════════════════
# SERVICIO 2: MinIO (Artifact Store S3-Compatible)
# ═══════════════════════════════════════════════════════════════════════════════
  minio:
    image: minio/minio:latest
    container_name: mlflow-minio
    ports:
      - "9000:9000"                              # API: donde MLflow sube/descarga artifacts.
      - "9001:9001"                              # Console: UI web para navegar buckets.
    environment:
      - MINIO_ROOT_USER=${MINIO_ROOT_USER:-minioadmin}
      - MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD:-minioadmin}
    volumes:
      - minio_data:/data                         # Artifacts persisten aquí.
    command: server /data --console-address ":9001"  # Inicia servidor con UI en 9001.
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
# ¿Por qué curl y no un comando interno? MinIO expone health checks HTTP nativamente.

# ═══════════════════════════════════════════════════════════════════════════════
# SERVICIO 3: Bucket Creator (Init Container)
# ═══════════════════════════════════════════════════════════════════════════════
  minio-create-bucket:
    image: minio/mc:latest                       # mc = MinIO Client (CLI).
    container_name: mlflow-minio-setup
    depends_on:
      - minio                                    # Espera a que MinIO arranque.
    entrypoint: >                                # Script inline (patrón común en docker-compose).
      /bin/sh -c "
      sleep 10;                                  # Espera adicional (MinIO puede tardar).
      /usr/bin/mc alias set myminio http://minio:9000 minioadmin minioadmin;
      /usr/bin/mc mb myminio/mlflow-artifacts --ignore-existing;  # Crea bucket si no existe.
      /usr/bin/mc anonymous set download myminio/mlflow-artifacts;  # Permite descargas.
      exit 0;
      "
# ¿Por qué un contenedor separado? Patrón "init container": ejecuta una vez y termina.

# ═══════════════════════════════════════════════════════════════════════════════
# SERVICIO 4: MLflow Server
# ═══════════════════════════════════════════════════════════════════════════════
  mlflow:
    image: ghcr.io/mlflow/mlflow:latest
    container_name: mlflow-server
    ports:
      - "5000:5000"                              # UI y API en el mismo puerto.
    environment:
      # Backend store: dónde guardar metadata (runs, params, metrics).
      - MLFLOW_BACKEND_STORE_URI=postgresql://mlflow:mlflow_password@postgres:5432/mlflow
      # Artifact store: dónde guardar archivos grandes (modelos, plots).
      - MLFLOW_DEFAULT_ARTIFACT_ROOT=s3://mlflow-artifacts/
      # Credenciales para MinIO (simula AWS S3).
      - AWS_ACCESS_KEY_ID=minioadmin
      - AWS_SECRET_ACCESS_KEY=minioadmin
      - MLFLOW_S3_ENDPOINT_URL=http://minio:9000  # CRÍTICO: apunta a MinIO, no a AWS.
    depends_on:
      postgres:
        condition: service_healthy               # Espera a que Postgres esté healthy.
      minio:
        condition: service_healthy
      minio-create-bucket:
        condition: service_completed_successfully  # Espera a que el bucket exista.
    command: >
      mlflow server
      --backend-store-uri postgresql://mlflow:mlflow_password@postgres:5432/mlflow
      --default-artifact-root s3://mlflow-artifacts/
      --host 0.0.0.0                             # Escucha en todas las interfaces.
      --port 5000
```

### 10.6.3 🔍 Anatomía de `scripts/run_mlflow.py`

**Archivo**: `ML-MLOps-Portfolio/BankChurn-Predictor/scripts/run_mlflow.py`

Este script es el **puente** entre el entrenamiento local y el servidor MLflow centralizado.

```python
# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 1: Configuración Flexible vía Variables de Entorno
# ═══════════════════════════════════════════════════════════════════════════════
def main() -> None:
    tracking_uri = os.getenv("MLFLOW_TRACKING_URI", "file:./mlruns")
    # ¿Por qué os.getenv con default?
    # - En desarrollo: usa "file:./mlruns" (local, sin servidor).
    # - En CI/CD: setea MLFLOW_TRACKING_URI=http://mlflow:5000.
    # - En producción: apunta al servidor real.
    
    experiment = os.getenv("MLFLOW_EXPERIMENT_NAME") or "BankChurn"
    # Patrón "or": si la variable está vacía (""), usa el default.

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 2: Carga y Transformación de Métricas
# ═══════════════════════════════════════════════════════════════════════════════
    results_path = Path("artifacts/training_results.json")
    if results_path.exists():
        data = json.loads(results_path.read_text())
        
        # Extraer métricas de CV (cross-validation)
        cv = data.get("cv_results", {})
        for k, v in cv.items():
            if isinstance(v, (int, float)):      # Solo loguea valores numéricos.
                metrics[f"cv_{k}"] = float(v)    # Prefijo "cv_" para distinguir.
        
        # Extraer métricas de test
        test_metrics = data.get("test_results", {}).get("metrics", {})
        for k, v in test_metrics.items():
            metrics[f"test_{k}"] = float(v)      # Prefijo "test_" para distinguir.
# ¿Por qué prefijos? En MLflow UI puedes filtrar por "cv_*" vs "test_*".

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 3: Métricas de Negocio (Lo que distingue a un Senior)
# ═══════════════════════════════════════════════════════════════════════════════
        cm = test_results.get("confusion_matrix")  # [[TN, FP], [FN, TP]]
        if cm:
            tn, fp = cm[0]
            fn, tp = cm[1]
            
            clv = float(os.getenv("BC_CLV_USD", "2300"))  # Customer Lifetime Value.
            retention_rate = float(os.getenv("BC_RETENTION_RATE", "0.3"))
            
            saved_customers = float(tp) * retention_rate
            saved_revenue = saved_customers * clv
            
            business_metrics = {
                "biz_saved_customers_proxy": saved_customers,
                "biz_saved_revenue_proxy_usd": saved_revenue,
            }
# ¿Por qué métricas de negocio?
# - "F1=0.85" no significa nada para el negocio.
# - "$690,000 en revenue salvado" sí justifica el proyecto.

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 4: Logging con Manejo Robusto de Errores
# ═══════════════════════════════════════════════════════════════════════════════
    with mlflow.start_run(run_name="demo-logging"):
        mlflow.log_params({"run_type": "demo"})
        mlflow.log_metrics(metrics)
        mlflow.log_metrics(business_metrics)
        
        # Artifacts: best-effort (puede fallar si el store no es accesible)
        for p in [Path("artifacts/training_results.json"), Path("configs/config.yaml")]:
            if p.exists():
                try:
                    mlflow.log_artifact(str(p))
                except PermissionError:
                    print(f"Skipping artifact {p}: permission denied")
                    # NO crashea el script, solo advierte.
# ¿Por qué try/except en artifacts?
# - En CI/CD, el artifact store puede no ser accesible desde el runner.
# - Mejor loguear métricas (crítico) que fallar por artifacts (nice-to-have).
```

### 10.6.4 🔍 Anatomía de `scripts/promote_model.py`

**Archivo**: `ML-MLOps-Portfolio/scripts/promote_model.py`

Este script implementa el **flujo CD** para modelos: validación → registro → promoción.

```python
# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 1: Configuración Multi-Proyecto
# ═══════════════════════════════════════════════════════════════════════════════
PROJECT_CONFIGS = {
    "bankchurn": {
        "dir": "BankChurn-Predictor",
        "model_name": "BankChurn-Classifier",
        "model_path": "models/best_model.pkl",
        "metrics_path": "artifacts/metrics.json",
        "default_thresholds": {"f1": 0.50, "auc": 0.75},  # Umbrales mínimos.
    },
    "carvision": {...},
    "telecom": {...},
}
# ¿Por qué un dict de configs?
# - Un solo script maneja los 3 proyectos del portafolio.
# - Cada proyecto tiene sus propios umbrales (clasificación vs regresión).

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 2: Validación de Métricas (Quality Gate)
# ═══════════════════════════════════════════════════════════════════════════════
def validate_metrics(metrics: dict, thresholds: dict) -> tuple[bool, list[str]]:
    failures = []
    for threshold_name, threshold_value in thresholds.items():
        actual_value = metrics.get(threshold_name)
        if actual_value is not None:
            # RMSE: menor es mejor. Otros: mayor es mejor.
            if threshold_name == "rmse":
                if actual_value > threshold_value:
                    failures.append(f"{threshold_name}: {actual_value:.4f} > {threshold_value}")
            else:
                if actual_value < threshold_value:
                    failures.append(f"{threshold_name}: {actual_value:.4f} < {threshold_value}")
    return len(failures) == 0, failures
# ¿Por qué validar antes de promover?
# - Evita poner en producción un modelo que empeoró.
# - Es el "quality gate" del flujo CD para ML.

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 3: Promoción Condicional
# ═══════════════════════════════════════════════════════════════════════════════
if promote and passed:
    client = MlflowClient()
    versions = client.search_model_versions(f"name='{model_name}'")
    if versions:
        latest_version = max(versions, key=lambda v: int(v.version))
        client.transition_model_version_stage(
            name=model_name,
            version=latest_version.version,
            stage="Production",
            archive_existing_versions=True,  # Archiva la versión anterior.
        )
# ¿Por qué archive_existing_versions=True?
# - Solo una versión puede estar en "Production" a la vez.
# - Las versiones anteriores se mueven a "Archived" (no se borran).
```

### 10.6.5 🧪 Laboratorio de Replicación

**Tu misión**: Levantar el stack MLflow completo y registrar tu primer modelo.

1. **Levanta la infraestructura**:
   ```bash
   cd /ruta/a/ML-MLOps-Portfolio
   docker-compose -f docker-compose.mlflow.yml up -d
   
   # Verifica que todo esté healthy
   docker-compose -f docker-compose.mlflow.yml ps
   ```

2. **Accede a las UIs**:
   - MLflow: http://localhost:5000
   - MinIO Console: http://localhost:9001 (user: minioadmin, pass: minioadmin)

3. **Conecta desde Python**:
   ```python
   import mlflow
   mlflow.set_tracking_uri("http://localhost:5000")
   mlflow.set_experiment("mi-primer-experimento")
   
   with mlflow.start_run():
       mlflow.log_param("test", "valor")
       mlflow.log_metric("accuracy", 0.95)
       print(f"Run ID: {mlflow.active_run().info.run_id}")
   ```

4. **Verifica en la UI** que el run aparece con params y métricas.

### 10.6.6 🚨 Troubleshooting Preventivo

| Síntoma | Causa Probable | Solución |
|---------|----------------|----------|
| **"Connection refused" al conectar a MLflow** | Servidor no arrancó o puerto bloqueado | `docker-compose logs mlflow` para ver errores. Verifica que puerto 5000 esté libre. |
| **"Unable to upload artifact"** | MinIO no accesible o credenciales incorrectas | Verifica `MLFLOW_S3_ENDPOINT_URL` apunta a MinIO. Revisa user/pass. |
| **Artifacts visibles en UI pero no descargables** | Bucket sin permisos de lectura | Ejecuta `mc anonymous set download myminio/mlflow-artifacts`. |
| **Runs no aparecen en el experimento correcto** | `set_experiment()` no llamado antes de `start_run()` | Siempre llama `mlflow.set_experiment("nombre")` antes. |
| **"Model registry is not available"** | Backend store es file-based | El registry requiere una DB real (PostgreSQL/MySQL). No funciona con `file:./mlruns`. |

---

<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en MLflow

MLflow añade una capa extra (servidor, rutas, artefactos), así que muchos errores son de **configuración** más que de código puro.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) Runs que no aparecen en la UI (tracking_uri/experimento incorrectos)

**Síntomas típicos**

- Ejecutas training o `run_mlflow.py` y no ves nada nuevo en `http://localhost:5000`.

**Cómo identificarlo**

- Imprime `mlflow.get_tracking_uri()` y el experimento actual (`mlflow.get_experiment_by_name(...)`).
- Verifica si estás usando `file:./mlruns` mientras tienes un servidor en Docker (`http://localhost:5000`).

**Cómo corregirlo**

- Define claramente en config:
  - Desarrollo local → `tracking_uri: "file:./mlruns"`.
  - Demo/stack Docker → `tracking_uri: "http://mlflow:5000"` o `http://localhost:5000`.
- Asegúrate de que tanto `ChurnTrainer` como `scripts/run_mlflow.py` lean del mismo origen (YAML/env vars).

---

### 2) Errores al registrar modelos (`MlflowException`, permisos, backend)

**Síntomas típicos**

- Al llamar `mlflow.sklearn.log_model(..., registered_model_name=...)` obtienes errores sobre base de datos o registry no configurado.

**Cómo identificarlo**

- Si usas solo `file:./mlruns` sin servidor, el **registry completo** no está disponible.

**Cómo corregirlo**

- Para desarrollo ligero, limita el uso de registry (puedes usar solo tracking + artifacts).
- Para un registry completo, usa el `docker-compose.mlflow.yml` del portafolio con backend SQLite/postgres y apunta `MLFLOW_TRACKING_URI` al servidor.

---

### 3) Artifacts que no se encuentran o no se suben

**Síntomas típicos**

- Errores tipo `FileNotFoundError` al hacer `mlflow.log_artifact`.
- No ves `training_results.json` ni `config.yaml` en la pestaña de artifacts.

**Cómo identificarlo**

- Revisa rutas relativas en `run_mlflow.py` y asegúrate de que ejecutas el script desde la raíz del proyecto.

**Cómo corregirlo**

- Usa rutas consistentes (por ejemplo `artifacts/training_results.json`) y verifica que el archivo exista antes de loguearlo.
- Si corres dentro de Docker, revisa que el volumen monte correctamente `artifacts/` y `configs/`.

---

### 4) Problemas con MLflow en Docker (puertos, hostnames, permisos)

**Síntomas típicos**

- `ConnectionError` al intentar conectar a `http://localhost:5000` desde un contenedor.
- Logs que muestran errores de permisos en `/mlflow`.

**Cómo identificarlo**

- Examina `docker-compose.mlflow.yml` y las variables de entorno de tus servicios.

**Cómo corregirlo**

- Dentro de un contenedor, usa el hostname del servicio (`http://mlflow:5000`) en lugar de `localhost`.
- Asegúrate de que el volumen `mlflow-artifacts` tenga permisos de escritura correctos (usuario del contenedor).

---

### Patrón general de debugging en MLflow

1. **Comprueba tracking_uri y experimento** antes de iniciar el run.
2. **Valida artifacts y modelos**: que los paths existen y se cargan correctamente.
3. **Reproduce localmente con file store** (`file:./mlruns`) antes de ir a servidor Docker.
4. **Verifica desde la UI** que params, metrics y artifacts coincidan con lo que esperas de tu código.

Con este patrón, MLflow pasa de ser “caja negra” a una herramienta confiable para explicar, comparar y promover modelos.

---

<a id="ejercicio"></a>

## ✅ Ejercicio: Integrar MLflow en TelecomAI

1. Crea `scripts/run_mlflow.py` para TelecomAI
2. Log las métricas: accuracy, f1, precision, recall, roc_auc
3. Calcula métricas de negocio (customers retained, revenue saved)
4. Registra el modelo como "TelecomPlanClassifier"

---

<a id="checkpoint"></a>

## ✅ Checkpoint

- [ ] Puedo correr un run end-to-end y verlo en la UI (o en `mlflow ui`).
- [ ] Puedo explicar dónde quedan:
  - params
  - metrics
  - artifacts
- [ ] Puedo comparar 2 runs y justificar qué cambió (params → métricas).

---

## 📦 Cómo se Usó en el Portafolio

MLflow está integrado en los 3 proyectos del portafolio:

### Configuración MLflow en BankChurn

```python
# BankChurn-Predictor/src/bankchurn/config.py
class MLflowConfig(BaseModel):
    """MLflow tracking configuration."""
    tracking_uri: str = "file:./mlruns"  # Local por defecto
    experiment_name: str = "bankchurn"
    enabled: bool = True
```

### Integración en Trainer

```python
# BankChurn-Predictor/src/bankchurn/trainer.py (extracto)
def _log_to_mlflow(self):
    """Log experimento a MLflow."""
    if not self.config.mlflow.enabled:
        return
    
    mlflow.set_tracking_uri(self.config.mlflow.tracking_uri)
    mlflow.set_experiment(self.config.mlflow.experiment_name)
    
    with mlflow.start_run():
        # Parámetros
        mlflow.log_params({
            "model_type": self.config.model.type,
            "test_size": self.config.model.test_size,
            "cv_folds": self.config.model.cv_folds,
        })
        
        # Métricas
        mlflow.log_metrics(self.metrics_)
        
        # Modelo
        mlflow.sklearn.log_model(self.model_, "model")
```

### Estructura de mlruns/

```
BankChurn-Predictor/
└── mlruns/
    ├── 0/                    # Default experiment
    └── 123456789/            # bankchurn experiment
        └── abc123def456/     # Run ID
            ├── artifacts/
            │   └── model/
            ├── metrics/
            │   ├── accuracy
            │   ├── f1_score
            │   └── roc_auc
            ├── params/
            │   ├── model_type
            │   └── cv_folds
            └── meta.yaml
```

### MLflow por Proyecto

| Proyecto | Tracking URI | Experiment | Métricas Principales |
|----------|--------------|------------|---------------------|
| BankChurn | `file:./mlruns` | `bankchurn` | accuracy, f1, roc_auc |
| CarVision | `file:./mlruns` | `carvision` | mae, rmse, r2 |
| TelecomAI | `file:./mlruns` | `telecomai` | accuracy, f1_weighted |

### 🔧 Ejercicio: Explora MLflow Real

```bash
# 1. Ve a BankChurn
cd BankChurn-Predictor

# 2. Entrena con MLflow habilitado
python main.py --config configs/config.yaml

# 3. Inicia la UI de MLflow
mlflow ui --backend-store-uri file:./mlruns

# 4. Abre en navegador
# http://localhost:5000

# 5. Explora:
# - Compara runs
# - Ve artifacts
# - Registra modelo en Model Registry
```

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **MLflow vs W&B vs Neptune**: Conoce trade-offs (MLflow open-source, W&B mejor UI, Neptune escalabilidad).

2. **Model Registry**: Explica stages (Staging → Production → Archived).

3. **Reproducibilidad**: Cómo reconstruir cualquier experimento desde el tracking.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Equipo distribuido | Usa servidor MLflow centralizado |
| Muchos experimentos | Organiza con tags y naming conventions |
| Modelos grandes | Usa artifact storage externo (S3, GCS) |
| Comparación | Siempre registra baseline para comparar |

### Qué Trackear Siempre

- **Params**: Hiperparámetros, versiones de datos
- **Metrics**: Train/val/test, métricas de negocio
- **Artifacts**: Modelo, configs, plots, requirements.txt
- **Tags**: Git commit, autor, dataset version


---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **MLflow Tutorial** | Krish Naik | 40 min | [YouTube](https://www.youtube.com/watch?v=qdcHHrsXA48) |
| 🔴 | **MLflow Complete Course** | DataTalksClub | 1.5h | [YouTube](https://www.youtube.com/watch?v=MHcqGxA6JPs) |
| 🟡 | **Weights & Biases Quickstart** | W&B | 20 min | [YouTube](https://www.youtube.com/watch?v=BN2BT0SZSJw) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [MLflow Tracking](https://mlflow.org/docs/latest/tracking.html) | Guía oficial tracking |
| 🔴 | [MLflow Model Registry](https://mlflow.org/docs/latest/model-registry.html) | Registro de modelos |

---

## ⚖️ Decisión Técnica: ADR-010 MLflow

**Contexto**: Necesitamos trackear experimentos y versionar modelos.

**Decisión**: Usar MLflow para experiment tracking y model registry.

**Alternativas Consideradas**:
- **Weights & Biases**: Mejor UI pero SaaS (costo)
- **Neptune**: Escalable pero pago
- **TensorBoard**: Solo para deep learning

**Consecuencias**:
- ✅ Open source, self-hosted
- ✅ Model Registry integrado
- ✅ Integración con sklearn, PyTorch, etc.
- ❌ UI menos pulida que W&B

---

## 🔧 Ejercicios del Módulo

### Ejercicio 10.1: MLflow Básico
**Objetivo**: Trackear un experimento con MLflow.
**Dificultad**: ⭐⭐

```python
import mlflow

# TU TAREA: Completar el tracking
def train_with_mlflow(X_train, y_train, X_test, y_test, params):
    # 1. Iniciar run
    # 2. Log params
    # 3. Entrenar modelo
    # 4. Log metrics
    # 5. Log model
    pass
```

<details>
<summary>💡 Ver solución</summary>

```python
import mlflow
import mlflow.sklearn
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import f1_score, accuracy_score

def train_with_mlflow(X_train, y_train, X_test, y_test, params: dict):
    """Entrena modelo con tracking completo en MLflow."""
    
    # Configurar experimento
    mlflow.set_experiment("bankchurn-classifier")
    
    with mlflow.start_run():
        # 1. Log parámetros
        mlflow.log_params(params)
        
        # 2. Entrenar modelo
        model = RandomForestClassifier(
            n_estimators=params['n_estimators'],
            max_depth=params.get('max_depth'),
            random_state=42
        )
        model.fit(X_train, y_train)
        
        # 3. Evaluar
        y_pred = model.predict(X_test)
        metrics = {
            'f1': f1_score(y_test, y_pred),
            'accuracy': accuracy_score(y_test, y_pred)
        }
        
        # 4. Log métricas
        mlflow.log_metrics(metrics)
        
        # 5. Log modelo
        mlflow.sklearn.log_model(
            model,
            "model",
            registered_model_name="bankchurn-rf"
        )
        
        # 6. Log artifacts adicionales
        # mlflow.log_artifact("configs/config.yaml")
        
        print(f"Run ID: {mlflow.active_run().info.run_id}")
        return model, metrics

# Uso:
params = {'n_estimators': 100, 'max_depth': 10}
model, metrics = train_with_mlflow(X_train, y_train, X_test, y_test, params)
```
</details>

---

### Ejercicio 10.2: Comparar Experimentos
**Objetivo**: Ejecutar y comparar múltiples configuraciones.
**Dificultad**: ⭐⭐⭐

```python
# TU TAREA: Ejecutar grid de experimentos y encontrar el mejor

configs = [
    {'n_estimators': 50, 'max_depth': 5},
    {'n_estimators': 100, 'max_depth': 10},
    {'n_estimators': 200, 'max_depth': 15},
]

# ¿Cómo organizarías estos experimentos en MLflow?
# ¿Cómo encontrarías el mejor?
```

<details>
<summary>💡 Ver solución</summary>

```python
import mlflow
from mlflow.tracking import MlflowClient

def run_experiments(X_train, y_train, X_test, y_test, configs: list):
    """Ejecuta múltiples configuraciones y las compara."""
    
    mlflow.set_experiment("bankchurn-hyperparameter-search")
    
    results = []
    for config in configs:
        with mlflow.start_run():
            # Tag para identificar el experimento
            mlflow.set_tag("config_name", f"rf_{config['n_estimators']}_{config['max_depth']}")
            
            # Entrenar y evaluar
            model, metrics = train_model(X_train, y_train, X_test, y_test, config)
            
            results.append({
                'run_id': mlflow.active_run().info.run_id,
                'config': config,
                'f1': metrics['f1']
            })
    
    return results

def find_best_run(experiment_name: str, metric: str = "f1"):
    """Encuentra el mejor run de un experimento."""
    client = MlflowClient()
    experiment = client.get_experiment_by_name(experiment_name)
    
    runs = client.search_runs(
        experiment_ids=[experiment.experiment_id],
        order_by=[f"metrics.{metric} DESC"],
        max_results=1
    )
    
    if runs:
        best = runs[0]
        print(f"Best run: {best.info.run_id}")
        print(f"Best {metric}: {best.data.metrics[metric]}")
        print(f"Params: {best.data.params}")
        return best
    return None

# Ejecutar experimentos
results = run_experiments(X_train, y_train, X_test, y_test, configs)

# Encontrar el mejor
best_run = find_best_run("bankchurn-hyperparameter-search", "f1")

# Promover a producción
client = MlflowClient()
client.transition_model_version_stage(
    name="bankchurn-rf",
    version=1,
    stage="Production"
)
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **MLflow** | Plataforma open source para gestión del ciclo de vida ML |
| **Run** | Una ejecución de un experimento con parámetros específicos |
| **Model Registry** | Sistema para versionar y gestionar modelos en producción |
| **Artifact** | Archivo guardado junto con un run (modelo, plots, configs) |

---

## 🏁 FIN DE FASE 2: ML Engineering

> 🎯 **¡Has completado los módulos 07-10!**
>
> Ahora dominas las técnicas de ML Engineering profesional:
> - ✅ Pipelines sklearn reproducibles
> - ✅ Feature engineering sin data leakage
> - ✅ Training profesional con cross-validation
> - ✅ Experiment tracking con MLflow

**Siguiente**: Fase 3 - MLOps Core (Testing, CI/CD, Docker, APIs)

---

<div align="center">

**Siguiente módulo** → [11. Testing ML](11_TESTING_ML.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
