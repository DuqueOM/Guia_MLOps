# 📋 Examen de Hito 6: Integración Final

> **Formato**: Self-Correction Code Review + Proyecto Integrador  
> **Duración**: 90 minutos  
> **Puntaje mínimo**: 70/100

---

## Ejercicio 1: Code Review Integral (40 puntos)

### Proyecto Completo a Revisar

Revisa este proyecto simplificado e identifica TODOS los problemas:

```
project/
├── train.py
├── predict.py
├── model.pkl
├── data.csv
└── requirements.txt
```

```python
# train.py
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import pickle

df = pd.read_csv("data.csv")
X = df.drop("target", axis=1)
y = df["target"]

model = RandomForestClassifier()
model.fit(X, y)

with open("model.pkl", "wb") as f:
    pickle.dump(model, f)

print(f"Trained! Accuracy: {model.score(X, y)}")
```

```python
# predict.py
import pickle
import pandas as pd

model = pickle.load(open("model.pkl", "rb"))

def predict(data):
    return model.predict(pd.DataFrame([data]))[0]
```

```text
# requirements.txt
pandas
scikit-learn
```

### Tu Respuesta

Clasifica los problemas por categoría:

| Categoría | # | Problema | Severidad |
|-----------|---|----------|-----------|
| **Setup** | 1 | | |
| **Pipeline** | 2 | | |
| **Testing** | 3 | | |
| **Deployment** | 4 | | |
| **Production** | 5 | | |

---

<details>
<summary>📝 Ver Solución Completa</summary>

### Problemas por Categoría

#### Setup (Módulo 1)
| # | Problema | Severidad |
|---|----------|-----------|
| 1 | Sin src/ layout | 🔴 |
| 2 | Sin pyproject.toml | 🔴 |
| 3 | Sin type hints | 🟡 |
| 4 | Sin Pydantic config | 🟡 |
| 5 | requirements.txt sin versiones | 🔴 |

#### Pipeline (Módulo 2)
| # | Problema | Severidad |
|---|----------|-----------|
| 6 | Sin DVC para datos | 🟡 |
| 7 | Evalúa en train (leakage) | 🔴 |
| 8 | Sin train_test_split | 🔴 |
| 9 | Sin sklearn Pipeline | 🟡 |
| 10 | Sin random_state | 🟡 |

#### Testing (Módulo 3)
| # | Problema | Severidad |
|---|----------|-----------|
| 11 | Sin tests | 🔴 |
| 12 | Sin CI/CD | 🔴 |
| 13 | Sin validación de datos (Pandera) | 🟡 |

#### Deployment (Módulo 4)
| # | Problema | Severidad |
|---|----------|-----------|
| 14 | Sin Dockerfile | 🟡 |
| 15 | Sin API (FastAPI) | 🟡 |
| 16 | Path hardcodeado "model.pkl" | 🔴 |
| 17 | Pickle inseguro | 🟡 |

#### Production (Módulo 5)
| # | Problema | Severidad |
|---|----------|-----------|
| 18 | Sin MLflow tracking | 🟡 |
| 19 | Sin logging | 🟡 |
| 20 | Sin métricas (Prometheus) | 🟢 |
| 21 | Sin Model Card | 🟢 |

### Proyecto Corregido

```
bankchurn/
├── src/bankchurn/
│   ├── __init__.py
│   ├── config.py          # Pydantic
│   ├── schemas.py         # Pandera
│   ├── training.py        # Pipeline + Trainer
│   ├── evaluation.py
│   └── prediction.py
├── app/
│   └── fastapi_app.py
├── tests/
│   ├── conftest.py
│   ├── test_training.py
│   └── test_api.py
├── configs/
│   └── config.yaml
├── data/
│   └── raw/.gitkeep
├── artifacts/
│   └── .gitkeep
├── .github/workflows/
│   └── ci.yml
├── pyproject.toml
├── Dockerfile
├── dvc.yaml
├── .pre-commit-config.yaml
└── MODEL_CARD.md
```

</details>

---

## Ejercicio 2: Debugging en Producción (30 puntos)

### Escenario

Tu API está en producción y recibes esta alerta:

```
ALERT: ml_prediction_latency_p95 > 2s for 10 minutes
ALERT: ml_prediction_errors_total increased 500% in last hour
```

Los logs muestran:

```json
{"level": "error", "msg": "prediction_failed", "error": "ValueError: Input contains NaN"}
{"level": "error", "msg": "prediction_failed", "error": "ValueError: Input contains NaN"}
{"level": "warning", "msg": "high_latency", "latency_ms": 3420}
```

### Tu Respuesta

1. ¿Cuál es la causa raíz más probable?
2. ¿Qué revisarías primero?
3. ¿Cómo prevendrías esto en el futuro?

---

<details>
<summary>📝 Ver Solución</summary>

### 1. Causa Raíz

**Datos de entrada con NaN** que el modelo no puede procesar:
- El preprocessing no maneja NaN
- O la validación de entrada es insuficiente
- O el upstream (productor de datos) cambió y ahora envía campos vacíos

### 2. Qué Revisar (en orden)

```bash
# 1. Ver ejemplos de requests fallidos
grep "prediction_failed" /var/log/app.log | tail -20

# 2. Verificar qué campos tienen NaN
# En el código, añadir logging temporal:
logger.info("input_debug", data=data, has_nan=pd.DataFrame([data]).isnull().any().to_dict())

# 3. Comparar con datos históricos
# ¿Cambió el schema del upstream?

# 4. Verificar versión del modelo
# ¿Se deployó nuevo modelo que espera features diferentes?
```

### 3. Prevención Futura

```python
# A) Validación estricta con Pydantic
class PredictRequest(BaseModel):
    CreditScore: int = Field(..., ge=300, le=850)  # No permite None
    Age: int = Field(..., ge=18)
    # ...

# B) Validación con Pandera en el pipeline
@pa.check_types
def preprocess(df: DataFrame[InputSchema]) -> DataFrame[ProcessedSchema]:
    # Pandera rechaza NaN si no está permitido
    pass

# C) Fallback graceful
def predict_safe(data: dict) -> dict:
    try:
        # Validar primero
        validated = PredictRequest(**data)
        return predict(validated)
    except ValidationError as e:
        logger.warning("invalid_input", errors=e.errors())
        return {"error": "invalid_input", "details": e.errors()}

# D) Monitoreo de data quality
feature_null_rate = Gauge(
    "ml_feature_null_rate",
    "Tasa de nulos por feature",
    ["feature"]
)

# E) Circuit breaker para upstream degradado
```

</details>

---

## Ejercicio 3: Diseño de Sistema (30 puntos)

### Requisito

Diseña la arquitectura para servir el modelo BankChurn con estos requisitos:
- 1000 requests/segundo
- Latencia p99 < 100ms
- 99.9% availability
- Reentrenamiento semanal automático

### Tu Respuesta

Dibuja (o describe) los componentes y flujos.

---

<details>
<summary>📝 Ver Solución</summary>

### Arquitectura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              INFERENCE PATH                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Client ──► Load Balancer ──► API Gateway ──► Model Service (K8s)         │
│                   │                               │                         │
│                   │                               ▼                         │
│                   │                          ┌─────────┐                    │
│                   │                          │ Redis   │ (cache)            │
│                   │                          └─────────┘                    │
│                   │                               │                         │
│                   ▼                               ▼                         │
│              ┌─────────┐                    ┌──────────┐                    │
│              │Prometheus│◄────metrics──────│Model Pod │ x 10 replicas      │
│              └─────────┘                    └──────────┘                    │
│                   │                               │                         │
│                   ▼                               │                         │
│              ┌─────────┐                         │                         │
│              │ Grafana │                         │                         │
│              └─────────┘                         │                         │
│                                                  ▼                         │
│                                          ┌─────────────┐                   │
│                                          │ MLflow      │ (model registry)  │
│                                          └─────────────┘                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              TRAINING PATH                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   Schedule (Weekly) ──► Airflow DAG ──► Training Job (K8s Job)             │
│                                              │                              │
│                                              ▼                              │
│                                       ┌─────────────┐                       │
│                                       │ DVC Remote  │ (S3)                  │
│                                       └─────────────┘                       │
│                                              │                              │
│                                              ▼                              │
│                                       ┌─────────────┐                       │
│                                       │ MLflow      │                       │
│                                       │ - log metrics                       │
│                                       │ - register model                    │
│                                       └─────────────┘                       │
│                                              │                              │
│                                              ▼                              │
│                                       ┌─────────────┐                       │
│                                       │ Model Tests │ (pytest)              │
│                                       └─────────────┘                       │
│                                              │                              │
│                                         if pass                             │
│                                              ▼                              │
│                                       ┌─────────────┐                       │
│                                       │ Promote to  │                       │
│                                       │ Production  │                       │
│                                       └─────────────┘                       │
│                                              │                              │
│                                              ▼                              │
│                                       ┌─────────────┐                       │
│                                       │ Rolling     │                       │
│                                       │ Deployment  │                       │
│                                       └─────────────┘                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Componentes Clave

| Componente | Tecnología | Por qué |
|------------|------------|---------|
| Load Balancer | AWS ALB / GCP LB | Distribuir tráfico |
| API Gateway | Kong / AWS API GW | Rate limiting, auth |
| Model Service | FastAPI + Uvicorn | Async, rápido |
| Container Orchestration | Kubernetes | Scaling, self-healing |
| Cache | Redis | Reducir latencia repetidas |
| Model Registry | MLflow | Versionado de modelos |
| Data Versioning | DVC + S3 | Reproducibilidad |
| Monitoring | Prometheus + Grafana | Métricas y alertas |
| Orchestration | Airflow | Scheduling de retraining |
| CI/CD | GitHub Actions | Automation |

### Cálculos de Capacidad

```
1000 req/s × 100ms/req = 100 concurrent requests

Con 10 replicas:
- 100 concurrent / 10 = 10 concurrent per pod
- Cada pod con 2 workers = 5 req/worker
- Margen de seguridad OK

Memory per pod: 512MB
Total: 5GB para el servicio

Redis cache hit rate esperado: 30%
- 700 req/s al modelo
- 300 req/s desde cache (< 5ms)
```

</details>

---

## Rúbrica Final

| Ejercicio | Puntos |
|-----------|:------:|
| Code Review Integral | 40 |
| Debugging Producción | 30 |
| Diseño de Sistema | 30 |
| **TOTAL** | **100** |

---

## Certificación

Si obtuviste **≥70 puntos** en los 6 exámenes:

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                    🎓 CERTIFICACIÓN MLOps COMPLETADA                         ║
║                                                                              ║
║   Has demostrado competencia en:                                             ║
║   ✅ Setup profesional (Python moderno, tipos, validación)                   ║
║   ✅ Pipelines reproducibles (DVC, sklearn, sin leakage)                     ║
║   ✅ Testing & CI/CD (pytest, GitHub Actions, coverage)                      ║
║   ✅ Deployment (Docker, FastAPI, Kubernetes)                                ║
║   ✅ Producción (MLflow, logging, monitoreo)                                 ║
║   ✅ Integración de sistemas ML end-to-end                                   ║
║                                                                              ║
║   Próximo paso: Replicar el portafolio ML-MLOps-Portfolio                   ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```
