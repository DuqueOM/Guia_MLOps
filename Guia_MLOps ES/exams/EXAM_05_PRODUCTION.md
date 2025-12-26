# 📋 Examen de Hito 5: Producción & Monitoreo

> **Formato**: Self-Correction Code Review  
> **Duración**: 45-60 minutos  
> **Puntaje mínimo**: 70/100

---

## Ejercicio 1: MLflow con Errores (25 puntos)

### Código a Revisar

```python
# train_mlflow.py
import mlflow
from sklearn.ensemble import RandomForestClassifier

mlflow.set_experiment("bankchurn")

model = RandomForestClassifier(n_estimators=100, max_depth=10)
model.fit(X_train, y_train)

accuracy = model.score(X_test, y_test)
print(f"Accuracy: {accuracy}")

mlflow.log_metric("accuracy", accuracy)
mlflow.sklearn.log_model(model, "model")
```

### Tu Respuesta

| # | Problema | Severidad | Corrección |
|---|----------|-----------|------------|

---

<details>
<summary>📝 Ver Solución</summary>

| # | Problema | Severidad | Corrección |
|---|----------|-----------|------------|
| 1 | Sin `with mlflow.start_run()` | 🔴 Crítico | Envolver en context manager |
| 2 | No loguea parámetros | 🟡 Medio | `mlflow.log_params()` |
| 3 | Sin run_name | 🟢 Menor | Añadir nombre descriptivo |
| 4 | Sin signature del modelo | 🟡 Medio | `infer_signature()` |
| 5 | Sin input_example | 🟢 Menor | Añadir ejemplo de entrada |
| 6 | Solo accuracy (pocas métricas) | 🟡 Medio | Loguear más métricas |
| 7 | Sin tags | 🟢 Menor | Añadir tags de contexto |

### Código Corregido

```python
import mlflow
from mlflow.models import infer_signature
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score
import pandas as pd

# Configuración
mlflow.set_tracking_uri("file:./mlruns")
mlflow.set_experiment("bankchurn-classifier")

# Parámetros
params = {
    "n_estimators": 100,
    "max_depth": 10,
    "min_samples_split": 5,
    "random_state": 42,
}

with mlflow.start_run(run_name="rf-baseline-v1") as run:
    # Tags de contexto
    mlflow.set_tags({
        "model_type": "random_forest",
        "dataset_version": "v1.0",
        "engineer": "daniel",
    })
    
    # Loguear parámetros
    mlflow.log_params(params)
    
    # Entrenar
    model = RandomForestClassifier(**params)
    model.fit(X_train, y_train)
    
    # Predecir
    y_pred = model.predict(X_test)
    y_proba = model.predict_proba(X_test)[:, 1]
    
    # Métricas completas
    metrics = {
        "accuracy": accuracy_score(y_test, y_pred),
        "f1": f1_score(y_test, y_pred),
        "precision": precision_score(y_test, y_pred),
        "recall": recall_score(y_test, y_pred),
    }
    mlflow.log_metrics(metrics)
    
    # Signature para validación en inferencia
    signature = infer_signature(X_train, model.predict(X_train))
    
    # Input example para documentación
    input_example = X_train.head(3)
    
    # Loguear modelo con metadata
    mlflow.sklearn.log_model(
        model,
        artifact_path="model",
        signature=signature,
        input_example=input_example,
        registered_model_name="bankchurn-classifier",
    )
    
    print(f"Run ID: {run.info.run_id}")
    print(f"Metrics: {metrics}")
```

</details>

---

## Ejercicio 2: Logging con Problemas (25 puntos)

### Código a Revisar

```python
# prediction.py
def predict(data):
    print(f"Received data: {data}")
    
    try:
        result = model.predict(data)
        print(f"Prediction: {result}")
        return result
    except Exception as e:
        print(f"Error: {e}")
        raise
```

### Tu Respuesta

| # | Problema | Corrección |
|---|----------|------------|

---

<details>
<summary>📝 Ver Solución</summary>

| # | Problema | Corrección |
|---|----------|------------|
| 1 | `print()` en vez de logger | Usar logging estructurado |
| 2 | Loguea datos sensibles | Sanitizar o no loguear |
| 3 | Sin niveles de log | DEBUG, INFO, ERROR |
| 4 | Sin contexto (request_id) | Añadir correlation ID |
| 5 | Sin timestamp | Logger lo añade automático |
| 6 | Except genérico sin detalles | Loguear traceback |

### Código Corregido

```python
# prediction.py
import structlog
from typing import Any
import uuid

logger = structlog.get_logger()

def predict(data: dict, request_id: str | None = None) -> dict:
    """Predice con logging estructurado."""
    
    # Generar request_id si no viene
    request_id = request_id or str(uuid.uuid4())[:8]
    
    # Bind context para todos los logs de esta request
    log = logger.bind(request_id=request_id)
    
    # Log de entrada (sin datos sensibles)
    log.info(
        "prediction_started",
        num_features=len(data),
        features=list(data.keys()),  # Solo nombres, no valores
    )
    
    try:
        result = model.predict(data)
        
        log.info(
            "prediction_completed",
            prediction=int(result),
            latency_ms=elapsed_ms,
        )
        
        return {
            "prediction": int(result),
            "request_id": request_id,
        }
    
    except ValueError as e:
        log.warning(
            "prediction_validation_error",
            error=str(e),
        )
        raise
    
    except Exception as e:
        log.error(
            "prediction_failed",
            error=str(e),
            exc_info=True,  # Incluye traceback
        )
        raise
```

### Configuración de structlog

```python
# logging_config.py
import structlog
import logging
import sys

def setup_logging(json_logs: bool = True):
    """Configura logging estructurado."""
    
    processors = [
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
    ]
    
    if json_logs:
        processors.append(structlog.processors.JSONRenderer())
    else:
        processors.append(structlog.dev.ConsoleRenderer())
    
    structlog.configure(
        processors=processors,
        wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(),
    )
```

</details>

---

## Ejercicio 3: Model Card Incompleto (25 puntos)

### Documento a Revisar

```markdown
# Model Card: BankChurn Predictor

## Model Details
- Random Forest classifier
- Trained on customer data

## Usage
```python
model.predict(data)
```
```

### Tu Respuesta

¿Qué secciones críticas faltan?

---

<details>
<summary>📝 Ver Solución</summary>

### Model Card Completo

```markdown
# Model Card: BankChurn Predictor

## Model Details
- **Model Type**: Ensemble (Random Forest + Logistic Regression)
- **Version**: 1.0.0
- **Framework**: scikit-learn 1.3.0
- **License**: MIT
- **Contact**: ml-team@company.com

## Intended Use
- **Primary Use**: Predecir probabilidad de churn de clientes bancarios
- **Primary Users**: Equipo de retención de clientes
- **Out-of-Scope**: No usar para decisiones de crédito o discriminación

## Training Data
- **Source**: Base de datos de clientes (10,000 registros)
- **Date Range**: 2020-01-01 a 2023-12-31
- **Features**: 10 (CreditScore, Age, Balance, etc.)
- **Target**: Exited (binario: 0=retained, 1=churned)
- **Class Distribution**: 20% churned, 80% retained

## Evaluation Data
- **Split**: 80% train, 20% test (stratified)
- **Test Size**: 2,000 registros

## Metrics
| Metric | Value |
|--------|-------|
| Accuracy | 0.847 |
| Precision | 0.823 |
| Recall | 0.761 |
| F1 Score | 0.791 |
| ROC-AUC | 0.892 |

## Ethical Considerations
- **Fairness**: Evaluado por Age y Gender - no se detectó sesgo significativo
- **Privacy**: No se usan datos PII en features
- **Bias Risks**: Posible sesgo geográfico (más datos de Francia)

## Limitations
- No funciona bien con clientes nuevos (<6 meses)
- Performance degrada si Balance > $200,000
- Requiere actualización trimestral

## Caveats and Recommendations
- Monitorear drift de features mensualmente
- Threshold 0.5 optimizado para recall; ajustar según caso de uso
- No usar como única fuente para decisiones de negocio
```

</details>

---

## Ejercicio 4: Prometheus Metrics (25 puntos)

### Código a Revisar

```python
# metrics.py
from prometheus_client import Counter

predictions_total = Counter("predictions", "Total predictions")

def predict(data):
    result = model.predict(data)
    predictions_total.inc()
    return result
```

### Tu Respuesta

¿Qué métricas faltan para monitoreo de ML en producción?

---

<details>
<summary>📝 Ver Solución</summary>

### Métricas Completas

```python
from prometheus_client import Counter, Histogram, Gauge, Summary
import time

# ═══════════════════════════════════════════════════════════════════════════
# Counters: Eventos totales
# ═══════════════════════════════════════════════════════════════════════════

prediction_total = Counter(
    "ml_predictions_total",
    "Total de predicciones",
    ["model_version", "prediction_class"]  # Labels
)

prediction_errors = Counter(
    "ml_prediction_errors_total",
    "Total de errores en predicción",
    ["error_type"]
)

# ═══════════════════════════════════════════════════════════════════════════
# Histograms: Distribuciones (latencia, probabilidades)
# ═══════════════════════════════════════════════════════════════════════════

prediction_latency = Histogram(
    "ml_prediction_latency_seconds",
    "Latencia de predicción",
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0]
)

prediction_probability = Histogram(
    "ml_prediction_probability",
    "Distribución de probabilidades predichas",
    buckets=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
)

# ═══════════════════════════════════════════════════════════════════════════
# Gauges: Valores actuales
# ═══════════════════════════════════════════════════════════════════════════

model_loaded = Gauge(
    "ml_model_loaded",
    "1 si el modelo está cargado, 0 si no"
)

feature_drift = Gauge(
    "ml_feature_drift_score",
    "Score de drift por feature",
    ["feature_name"]
)

# ═══════════════════════════════════════════════════════════════════════════
# Uso en predicción
# ═══════════════════════════════════════════════════════════════════════════

MODEL_VERSION = "1.0.0"

def predict_with_metrics(data: dict) -> dict:
    """Predicción con métricas de producción."""
    
    start_time = time.time()
    
    try:
        # Predicción
        result = model.predict(data)
        probability = model.predict_proba(data)[1]
        
        # Métricas
        prediction_class = "churn" if result == 1 else "no_churn"
        prediction_total.labels(
            model_version=MODEL_VERSION,
            prediction_class=prediction_class
        ).inc()
        
        prediction_probability.observe(probability)
        
        return {
            "prediction": int(result),
            "probability": float(probability),
        }
    
    except Exception as e:
        prediction_errors.labels(error_type=type(e).__name__).inc()
        raise
    
    finally:
        latency = time.time() - start_time
        prediction_latency.observe(latency)
```

### Alertas Recomendadas (Alertmanager)

```yaml
groups:
  - name: ml-alerts
    rules:
      - alert: HighPredictionLatency
        expr: histogram_quantile(0.95, ml_prediction_latency_seconds) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Alta latencia en predicciones"
      
      - alert: HighErrorRate
        expr: rate(ml_prediction_errors_total[5m]) > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Tasa de errores > 1%"
      
      - alert: PredictionDrift
        expr: ml_feature_drift_score > 0.3
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Posible drift en features"
```

</details>

---

## Rúbrica

| Ejercicio | Puntos |
|-----------|:------:|
| MLflow | 25 |
| Logging | 25 |
| Model Card | 25 |
| Prometheus | 25 |
| **TOTAL** | **100** |
