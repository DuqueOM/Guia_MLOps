# 🎯 Simulacro de Entrevista Mid-Level ML Engineer
## Portafolio MLOps — 60 Preguntas Técnicas

**Nivel**: Mid (2-4 años de experiencia)  
**Versión**: 1.0 | Diciembre 2025

---

## 📋 Índice

1. [Pipelines y Arquitectura](#1-pipelines-y-arquitectura-preguntas-1-15)
2. [MLOps Práctico](#2-mlops-práctico-preguntas-16-30)
3. [Testing y Calidad](#3-testing-y-calidad-preguntas-31-40)
4. [Deployment y APIs](#4-deployment-y-apis-preguntas-41-50)
5. [Escenarios Prácticos](#5-escenarios-prácticos-preguntas-51-60)

---

## 🎯 ¿Qué se espera de un Mid-Level?

| Sí se espera | No se espera (aún) |
|--------------|-------------------|
| Diseñar pipelines end-to-end | Arquitecturas distribuidas complejas |
| Implementar CI/CD funcional | Optimización de infraestructura a escala |
| Debugging autónomo | Mentoring de equipos |
| Code reviews | Decisiones de arquitectura críticas |
| Escribir tests comprehensivos | Diseño de sistemas desde cero |

---

# 1. Pipelines y Arquitectura (Preguntas 1-15) {#1-pipelines-y-arquitectura-preguntas-1-15}

## Pregunta 1: Pipeline Unificado
**¿Por qué usar un Pipeline unificado en lugar de artefactos separados?**

### Respuesta:
```python
# ❌ Antes: artefactos separados
preprocessor = joblib.load("preprocessor.pkl")  # Cargar preprocesador.
model = joblib.load("model.pkl")                # Cargar modelo por separado.
X = preprocessor.transform(X)                   # Transformar manualmente.
pred = model.predict(X)                         # Predecir.

# ✅ Después: pipeline unificado
pipe = joblib.load("pipeline.joblib")           # TODO en un archivo.
pred = pipe.predict(X)                          # Una llamada hace todo.
```

**Beneficios**:
1. Elimina training-serving skew
2. Single source of truth
3. Versionado simple
4. Deploy más limpio

---

## Pregunta 2: ColumnTransformer
**Explica el ColumnTransformer del portafolio.**

### Respuesta:
```python
preprocessor = ColumnTransformer([               # Aplica transformaciones por tipo de columna.
    ('num', Pipeline([                           # Pipeline para numéricas.
        ('imputer', SimpleImputer(strategy='median')),  # Imputa con mediana.
        ('scaler', StandardScaler())             # Estandariza.
    ]), numerical_cols),
    ('cat', Pipeline([                           # Pipeline para categóricas.
        ('imputer', SimpleImputer(strategy='constant', fill_value='Unknown')),
        ('encoder', OneHotEncoder(handle_unknown='ignore'))  # One-hot encoding.
    ]), categorical_cols),
], remainder='drop')                             # Elimina columnas no especificadas.
```

**Procesa columnas en paralelo**: numéricas y categóricas tienen transformaciones distintas.

---

## Pregunta 3: Custom Transformer
**¿Cuándo crear un transformer personalizado?**

### Respuesta:
```python
class FeatureEngineer(BaseEstimator, TransformerMixin):  # Hereda para compatibilidad con Pipeline.
    def fit(self, X, y=None):                    # fit: aprende de datos (aquí no hace nada).
        return self                              # Retorna self para encadenar.
    
    def transform(self, X):                      # transform: aplica transformación.
        X = X.copy()                             # Copia para no modificar original.
        X['vehicle_age'] = 2024 - X['model_year']  # Crea feature derivada.
        return X
```

**Cuándo usar**:
- Lógica de negocio específica
- Features derivadas
- Transformaciones no estándar

---

## Pregunta 4: Estratified Split
**¿Por qué stratify=y en train_test_split?**

### Respuesta:
```python
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42  # stratify: mantiene proporción de clases.
)
```

Con clases desbalanceadas (80/20 churn), `stratify=y` garantiza que train y test mantengan la misma proporción. Sin esto, un split aleatorio podría dar 85/15 en train y 70/30 en test.

---

## Pregunta 5: Hyperparameter Tuning
**¿Cómo optimizas hiperparámetros?**

### Respuesta:
```python
from sklearn.model_selection import RandomizedSearchCV  # Búsqueda aleatoria de hiperparámetros.

param_dist = {
    'model__n_estimators': [50, 100, 200],       # model__: accede a params del paso 'model'.
    'model__max_depth': [5, 10, 20, None]
}

search = RandomizedSearchCV(
    pipe, param_dist, n_iter=20, cv=5, scoring='f1'  # n_iter: 20 combinaciones aleatorias.
)
search.fit(X_train, y_train)                     # Prueba combinaciones con CV.
print(search.best_params_)                       # Mejores hiperparámetros encontrados.
```

**GridSearch vs RandomizedSearch**: Random es más eficiente con muchos parámetros.

---

## Pregunta 6: Métricas de Negocio
**¿Cómo traduces métricas ML a valor de negocio?**

### Respuesta:
```python
# Costo de falsos negativos (cliente que churns sin detectar)
cost_fn = 500                                    # Costo de adquirir cliente nuevo.

# Costo de falsos positivos (retención innecesaria)
cost_fp = 50                                     # Costo de campaña de retención.

# Costo total
total_cost = (FN * cost_fn) + (FP * cost_fp)     # Métrica de negocio: minimizar esto.
```

Optimizar para **minimizar costo total**, no solo accuracy.

---

## Pregunta 7: Ensemble Methods
**Explica VotingClassifier con soft voting.**

### Respuesta:
```python
ensemble = VotingClassifier([                    # Combina múltiples modelos.
    ('lr', LogisticRegression()),                # Modelo lineal.
    ('rf', RandomForestClassifier())             # Modelo no-lineal.
], voting='soft', weights=[0.4, 0.6])            # soft: promedia probabilidades. weights: RF pesa más.
```

- **Soft voting**: Promedia probabilidades (mejor que votos binarios)
- **Weights**: RF tiene más peso porque tiene mejor AUC individual
- **Complementariedad**: LR lineal + RF no-lineal = menor varianza

---

## Pregunta 8: Cross-Validation Avanzado
**¿Cuándo usar TimeSeriesSplit vs StratifiedKFold?**

### Respuesta:
| Tipo | Usar cuando |
|------|-------------|
| StratifiedKFold | Clasificación con clases desbalanceadas |
| TimeSeriesSplit | Datos temporales (evitar data leakage temporal) |
| GroupKFold | Datos con grupos (ej: múltiples muestras por paciente) |

```python
from sklearn.model_selection import TimeSeriesSplit  # CV para datos temporales.
tscv = TimeSeriesSplit(n_splits=5)               # 5 splits temporales.
# Train: [1,2,3], Test: [4]                      # Nunca usa datos futuros para entrenar.
# Train: [1,2,3,4], Test: [5]                    # El train crece, test siempre es "futuro".
```

---

## Pregunta 9: Feature Importance
**¿Cómo explicas qué features son importantes?**

### Respuesta:
```python
# 1. Importancia de RF
importances = model.feature_importances_         # Importancia basada en reducción de impureza.

# 2. Permutation importance (más robusto)
from sklearn.inspection import permutation_importance
perm = permutation_importance(model, X_test, y_test)  # Permuta features y mide impacto.

# 3. SHAP (más interpretable)
import shap
explainer = shap.TreeExplainer(model)            # Explainer para modelos de árboles.
shap_values = explainer.shap_values(X_test)      # Contribución de cada feature por predicción.
```

---

## Pregunta 10: Handling Categorical High Cardinality
**¿Cómo manejas categorías con muchos valores únicos?**

### Respuesta:
```python
# 1. Target encoding (con cuidado de leakage)
from category_encoders import TargetEncoder      # Codifica con media del target.
encoder = TargetEncoder()                        # ⚠️ Usar solo en train para evitar leakage.

# 2. Frequency encoding
X['brand_freq'] = X['brand'].map(X['brand'].value_counts(normalize=True))  # Frecuencia relativa.

# 3. Grouping rare categories
X['brand'] = X['brand'].apply(lambda x: x if freq[x] > 0.01 else 'Other')  # Agrupa raras en 'Other'.
```

---

## Pregunta 11: Reproducibilidad
**¿Cómo garantizas experimentos reproducibles?**

### Respuesta:
```python
# 1. Seeds
SEED = 42
np.random.seed(SEED)                             # Seed numpy.
random.seed(SEED)                                # Seed random.

# 2. Config versionada
config = BankChurnConfig.from_yaml("configs/config.yaml")  # Pydantic valida.

# 3. MLflow tracking
mlflow.log_params(config.model.dict())           # Guarda hiperparámetros.
mlflow.log_artifact("configs/config.yaml")       # Guarda archivo de config.

# 4. Dependencias fijas
# pyproject.toml con versiones específicas       # sklearn==1.3.0, no sklearn.
```

---

## Pregunta 12: Data Validation
**¿Cómo validas datos de entrada en producción?**

### Respuesta:
```python
from pydantic import BaseModel, Field, validator  # Pydantic para validación.

class PredictionInput(BaseModel):                # Schema de entrada.
    credit_score: int = Field(ge=300, le=850)    # ge/le: rangos válidos.
    age: int = Field(ge=18, le=100)
    geography: str
    
    @validator('geography')                      # Validador custom.
    def validate_geography(cls, v):              # v: valor a validar.
        valid = ['France', 'Germany', 'Spain']
        if v not in valid:
            raise ValueError(f'Must be one of {valid}')  # Error descriptivo.
        return v                                 # Retorna valor validado.
```

Pydantic valida antes de que llegue al modelo.

---

## Pregunta 13: Config Management
**¿Por qué Pydantic para configuración?**

### Respuesta:
```python
class ModelConfig(BaseModel):
    model_type: Literal["rf", "lr", "xgb"]        # Solo estos valores permitidos.
    n_estimators: int = Field(ge=10, le=1000)     # Rango válido.
    
    @validator('n_estimators')                    # Validación cross-field.
    def validate_estimators(cls, v, values):     # values: otros campos ya validados.
        if values.get('model_type') == 'lr' and v != 1:
            raise ValueError('LR no usa n_estimators')  # Lógica de negocio.
        return v
```

**Beneficios**: Validación automática, tipos claros, errores descriptivos, documentación implícita.

---

## Pregunta 14: Artifact Management
**¿Cómo organizas artefactos del modelo?**

### Respuesta:
```
artifacts/
├── pipeline.joblib       # Modelo + preprocessor
├── training_results.json # Métricas
├── config.yaml          # Config usada
└── feature_names.json   # Features esperadas
```

```python
# Guardar
joblib.dump(pipe, 'artifacts/pipeline.joblib')   # Serializa pipeline completo.
with open('artifacts/training_results.json', 'w') as f:
    json.dump(metrics, f)                        # Guarda métricas como JSON.
```

---

## Pregunta 15: Model Versioning
**¿Cómo versionas modelos?**

### Respuesta:
```python
# 1. MLflow Model Registry
mlflow.sklearn.log_model(pipe, "model")          # Guarda modelo en MLflow.
# Registrar como v1, v2, etc.                    # UI permite promover a staging/production.

# 2. Naming convention
model_name = f"bankchurn_v{version}_{timestamp}.joblib"  # Nombre descriptivo.

# 3. Git tags
git tag -a v1.0.0 -m "Model v1.0.0: AUC 0.85"   # Asocia versión de código con modelo.
```

---

# 2. MLOps Práctico (Preguntas 16-30) {#2-mlops-práctico-preguntas-16-30}

## Pregunta 16: MLflow Tracking
**¿Cómo usas MLflow para tracking?**

### Respuesta:
```python
import mlflow

with mlflow.start_run():                         # Context manager: crea y cierra run.
    mlflow.log_params({"n_estimators": 100, "max_depth": 10})  # Hiperparámetros.
    mlflow.log_metrics({"auc": 0.85, "f1": 0.78})  # Métricas de evaluación.
    mlflow.sklearn.log_model(pipe, "model")      # Guarda modelo serializado.
    mlflow.log_artifact("configs/config.yaml")   # Guarda archivos adicionales.
```

---

## Pregunta 17: DVC
**¿Para qué usas DVC?**

### Respuesta:
```bash
# Trackear datos
dvc add data/raw/Churn.csv                       # Crea .dvc file, añade datos a .gitignore.

# Push a remote
dvc push                                         # Sube datos a remote (S3, GCS, etc.).

# Pull datos
dvc pull                                         # Descarga datos del remote.
```

**Beneficio**: Versionar datos grandes sin subirlos a Git.

---

## Pregunta 18: GitHub Actions CI
**Explica el workflow CI del portafolio.**

### Respuesta:
```yaml
name: CI
on: [push, pull_request]                         # Triggers del workflow.

jobs:
  test:
    runs-on: ubuntu-latest                       # Runner de GitHub.
    steps:
      - uses: actions/checkout@v4                # Clona el repo.
      - run: pip install -e ".[dev]"             # Instala dependencias.
      - run: pytest tests/ --cov=src             # Ejecuta tests con coverage.
      - run: ruff check src/                     # Linting.
```

**Flujo**: Push → Install → Test → Lint → Pass/Fail badge.

---

## Pregunta 19: Pre-commit Hooks
**¿Qué hooks usas?**

### Respuesta:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit  # Linter rápido.
    hooks:
      - id: ruff                                 # Verifica estilo.
      - id: ruff-format                          # Auto-formatea.
  - repo: https://github.com/pre-commit/mirrors-mypy
    hooks:
      - id: mypy                                 # Verificación de tipos.
```

Ejecutan automáticamente antes de cada commit.

---

## Pregunta 20: Docker Multi-stage
**Explica el Dockerfile del portafolio.**

### Respuesta:
```dockerfile
# Build stage
FROM python:3.11-slim AS builder                # Stage de compilación.
COPY requirements.txt .
RUN pip wheel --no-cache-dir -w /wheels -r requirements.txt  # Genera wheels.

# Runtime stage
FROM python:3.11-slim                           # Imagen limpia, sin herramientas de build.
COPY --from=builder /wheels /wheels             # Copia solo wheels del builder.
RUN pip install --no-cache /wheels/*            # Instala sin compilar.
COPY . /app
USER nonroot                                    # Seguridad: no root.
CMD ["uvicorn", "app:app", "--host", "0.0.0.0"] # Comando de inicio.
```

**Multi-stage**: Build pesado en stage 1, runtime ligero en stage 2.

---

## Pregunta 21: Training-Serving Skew
**¿Qué es training-serving skew y cómo lo evitas?**

### Respuesta:
Training-serving skew ocurre cuando el modelo ve datos diferentes en producción vs entrenamiento.

**Causas comunes**:
```python
# ❌ MAL: Preprocesamiento diferente
# Training
X_train['age_normalized'] = (X_train['age'] - X_train['age'].mean()) / X_train['age'].std()  # Stats de train.

# Serving (usa stats de producción, no de training!)
X_prod['age_normalized'] = (X_prod['age'] - X_prod['age'].mean()) / X_prod['age'].std()  # Stats de prod → SKEW.
```

**Solución: Pipeline unificado**:
```python
# ✅ BIEN: Todo en un pipeline
pipe = Pipeline([
    ('scaler', StandardScaler()),                # Guarda mean/std de training internamente.
    ('model', RandomForestClassifier())
])
pipe.fit(X_train, y_train)                       # fit: aprende stats de train.
joblib.dump(pipe, 'model.joblib')                # Serializa TODO junto.

# En producción: mismo pipeline
pipe = joblib.load('model.joblib')               # Carga con stats de train.
pred = pipe.predict(X_new)                       # transform usa stats originales.
```

---

## Pregunta 22: Data Drift Detection
**¿Cómo detectas data drift en producción?**

### Respuesta:
```python
from evidently.metrics import DataDriftTable     # Evidently: librería de monitoreo ML.
from evidently.report import Report

# Comparar distribuciones
report = Report(metrics=[DataDriftTable()])      # Métrica de drift.
report.run(reference_data=X_train, current_data=X_prod)  # Compara train vs producción.
report.save_html("drift_report.html")            # Genera reporte visual.
```

**Métodos estadísticos**:
| Método | Uso | Umbral típico |
|--------|-----|---------------|
| **PSI** (Population Stability Index) | Categóricas | >0.2 = drift significativo |
| **KS-test** (Kolmogorov-Smirnov) | Numéricas | p-value < 0.05 |
| **JS Divergence** | Distribuciones | >0.1 = drift |

**En el portafolio**: Configurable en `16_OBSERVABILIDAD.md`.

---

## Pregunta 23: Métricas de Producción
**¿Qué métricas monitoreas en producción?**

### Respuesta:
```python
# Prometheus metrics en FastAPI
from prometheus_client import Counter, Histogram  # Cliente Prometheus para Python.

PREDICTIONS = Counter('predictions_total', 'Total predictions', ['model_version'])  # Contador.
LATENCY = Histogram('prediction_latency_seconds', 'Prediction latency')  # Histograma.

@app.post("/predict")
async def predict(data: Input):
    with LATENCY.time():                         # Mide tiempo automáticamente.
        result = model.predict(data)
    PREDICTIONS.labels(model_version="v1.2").inc()  # Incrementa contador con label.
    return result
```

**Métricas clave**:
| Categoría | Métricas |
|-----------|----------|
| **Rendimiento** | Latencia p50/p95/p99, throughput |
| **Disponibilidad** | Error rate, uptime |
| **ML específicas** | Prediction distribution, feature distributions |
| **Negocio** | Conversiones, costos evitados |

---

## Pregunta 24: Rollback de Modelos
**¿Cómo haces rollback si un modelo falla?**

### Respuesta:
```python
# 1. Versionado de modelos
models/
├── v1.0.0/pipeline.joblib  # ← Rollback aquí
├── v1.1.0/pipeline.joblib
└── v1.2.0/pipeline.joblib  # Actual (fallando)

# 2. Blue-Green deployment
# deployment.yaml
spec:
  replicas: 2
  selector:
    matchLabels:
      version: v1.1.0  # Cambiar a versión anterior

# 3. Con MLflow
client = MlflowClient()
client.transition_model_version_stage(
    name="bankchurn",
    version=3,
    stage="Production"  # Promover versión anterior
)
```

**Proceso de rollback**:
1. Detectar degradación (alertas de métricas)
2. Cambiar variable de entorno o config
3. Reiniciar pods / recargar modelo
4. Verificar métricas post-rollback

---

## Pregunta 25: A/B Testing en ML
**¿Cómo implementas A/B testing para modelos?**

### Respuesta:
```python
import random

@app.post("/predict")
async def predict(data: Input, user_id: str):
    # Asignar bucket consistente por usuario
    bucket = hash(user_id) % 100                 # Hash determinista: mismo user = mismo bucket.
    
    if bucket < 10:                              # 10% tráfico al challenger.
        model = model_v2                         # Challenger: modelo nuevo.
        version = "v2"
    else:
        model = model_v1                         # Champion: modelo actual.
        version = "v1"
    
    result = model.predict(data)
    
    # Logging para análisis
    log_prediction(user_id, version, result)     # Guarda para comparar métricas.
    
    return {"prediction": result, "model_version": version}
```

**Métricas a comparar**:
- Accuracy/F1 en cohortes
- Métricas de negocio (conversión, revenue)
- Latencia y error rate

---

## Pregunta 26: Manejo de Secrets
**¿Cómo manejas secrets y credenciales?**

### Respuesta:
```python
# ❌ MAL: Hardcoded
API_KEY = "TU_API_KEY_AQUI"                      # NUNCA hacer esto: queda en Git.

# ✅ BIEN: Variables de entorno
import os
API_KEY = os.getenv("API_KEY")                   # Lee de variable de entorno.

# ✅ MEJOR: python-dotenv
from dotenv import load_dotenv
load_dotenv()                                    # Carga variables de .env al entorno.
API_KEY = os.getenv("API_KEY")                   # Ahora disponible.
```

**.env (nunca en Git)**:
```bash
# .env (valores de ejemplo)
API_KEY=REEMPLAZAR_EN_ENTORNO_REAL
DB_PASSWORD=REEMPLAZAR_EN_ENTORNO_REAL
```

**.gitignore**:
```gitignore
.env
.env.*
!.env.example
```

**En CI/CD**: GitHub Secrets → `${{ secrets.API_KEY }}`

---

## Pregunta 27: Feature Store
**¿Qué es un feature store y cuándo usarlo?**

### Respuesta:
Feature store = repositorio centralizado de features reutilizables.

```python
# Sin feature store (problema)
# Equipo A: calcula age_bucket de una forma
# Equipo B: calcula age_bucket de otra forma
# → Inconsistencia                              # Cada equipo tiene su versión.

# Con feature store (solución)
from feast import FeatureStore                   # Feast: feature store open source.

store = FeatureStore(repo_path=".")              # Conecta al store.
features = store.get_online_features(            # Obtiene features en tiempo real.
    features=["customer:age_bucket", "customer:tenure_months"],  # Formato: tabla:feature.
    entity_rows=[{"customer_id": "C123"}]        # Entidad a buscar.
)
```

**Cuándo usar**:
| Situación | Feature Store |
|-----------|---------------|
| 1-2 modelos, equipo pequeño | No necesario |
| Múltiples modelos, features compartidas | Recomendado |
| Features en tiempo real | Muy recomendado |

---

## Pregunta 28: Escalado de Inferencia
**¿Cómo escalas inferencia para alto tráfico?**

### Respuesta:
```yaml
# Kubernetes HPA (Horizontal Pod Autoscaler)
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler               # Escala pods automáticamente.
metadata:
  name: bankchurn-api
spec:
  scaleTargetRef:                           # Deployment a escalar.
    apiVersion: apps/v1
    kind: Deployment
    name: bankchurn-api
  minReplicas: 2                            # Mínimo 2 pods siempre.
  maxReplicas: 10                           # Máximo 10 pods.
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70              # Escala cuando CPU > 70%.
```

**Estrategias**:
| Estrategia | Cuándo |
|------------|--------|
| **HPA** | Tráfico variable, latencia crítica |
| **Batch processing** | Alto volumen, latencia flexible |
| **Caching** | Inputs repetidos frecuentes |
| **Model optimization** | Latencia muy baja requerida |

---

## Pregunta 29: Logging en ML
**¿Qué información loggeas en producción?**

### Respuesta:
```python
import logging
import json

logger = logging.getLogger(__name__)             # Logger por módulo.

@app.post("/predict")
async def predict(data: Input):
    request_id = str(uuid.uuid4())               # ID único para trazar request.
    
    # Log de entrada
    logger.info(json.dumps({                     # JSON estructurado para análisis.
        "event": "prediction_request",
        "request_id": request_id,
        "features": data.dict(),                 # Features de entrada.
        "timestamp": datetime.utcnow().isoformat()
    }))
    
    start = time.time()                          # Medir latencia.
    result = model.predict(data)
    latency = time.time() - start
    
    # Log de salida
    logger.info(json.dumps({
        "event": "prediction_response",
        "request_id": request_id,                # Mismo ID para correlacionar.
        "prediction": result,
        "probability": float(proba),
        "latency_ms": latency * 1000,            # Latencia en ms.
        "model_version": "v1.2.0"                # Versión para debugging.
    }))
    
    return result
```

**Logs esenciales**: request_id, inputs, outputs, latencia, versión, errores.

---

## Pregunta 30: Retraining Automático
**¿Cómo automatizas el retraining?**

### Respuesta:
```yaml
# GitHub Actions scheduled workflow
name: Weekly Retrain
on:
  schedule:
    - cron: '0 2 * * 0'                         # Domingos 2am UTC.
  workflow_dispatch:                            # Permite trigger manual.

jobs:
  retrain:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pip install -e ".[dev]"
      - run: python main.py --config configs/config.yaml  # Entrena modelo.
      - run: python scripts/evaluate.py --threshold 0.80  # Valida métricas.
      - run: |                                  # Deploy condicional.
          if [ $? -eq 0 ]; then                 # Si evaluación pasó.
            echo "Model passed threshold, deploying..."
            # Deploy logic
          fi
```

**Triggers de retraining**:
| Trigger | Implementación |
|---------|----------------|
| **Scheduled** | Cron jobs, Airflow |
| **Data drift** | Alerta → trigger workflow |
| **Performance degradation** | Métricas bajo umbral |
| **New data volume** | X nuevos registros |

---

# 3. Testing y Calidad (Preguntas 31-40) {#3-testing-y-calidad-preguntas-31-40}

## Pregunta 31: Tipos de Tests
**¿Qué tipos de tests tiene el portafolio?**

### Respuesta:
```python
# Unit test - prueba una función aislada
def test_feature_engineer():
    fe = FeatureEngineer()
    result = fe.transform(sample_df)             # Prueba transform.
    assert 'vehicle_age' in result.columns       # Verifica output esperado.

# Integration test - prueba múltiples componentes juntos
def test_training_pipeline():
    trainer = Trainer(config)
    trainer.fit(X, y)                            # Prueba flujo completo.
    assert trainer.model_ is not None            # Verifica que modelo existe.

# API test - prueba endpoint HTTP
def test_predict_endpoint():
    response = client.post("/predict", json=sample_input)  # Request HTTP.
    assert response.status_code == 200           # Verifica respuesta exitosa.
```

---

## Pregunta 32: Fixtures
**¿Cómo usas fixtures en pytest?**

### Respuesta:
```python
@pytest.fixture                                  # Fixture: setup reutilizable.
def sample_data():
    return pd.DataFrame({                        # Datos de prueba.
        'CreditScore': [650, 700],
        'Age': [35, 45],
        'Exited': [0, 1]
    })

@pytest.fixture
def trained_model(sample_data):                  # Fixture puede usar otra fixture.
    trainer = Trainer(config)
    trainer.fit(sample_data)                     # Entrena con datos de prueba.
    return trainer

def test_predict(trained_model, sample_data):    # Test recibe fixtures como args.
    preds = trained_model.predict(sample_data)
    assert len(preds) == len(sample_data)        # Verifica cantidad de predicciones.
```

---

## Pregunta 33: Coverage
**¿Cuánto coverage es suficiente?**

### Respuesta:
```bash
pytest tests/ --cov=src --cov-report=html       # --cov: mide coverage de src/. --cov-report: genera HTML.
```

| Nivel | Coverage | Comentario |
|-------|----------|------------|
| Mínimo | 70% | Lo básico |
| Bueno | 80% | Estándar industria |
| Excelente | 90%+ | Código crítico |

**El portafolio tiene 79% en BankChurn.**

---

## Pregunta 34: Property-Based Testing
**¿Qué es property-based testing?**

### Respuesta:
En lugar de casos específicos, defines **propiedades** que siempre deben cumplirse.

```python
from hypothesis import given, strategies as st   # Hypothesis: property-based testing.

@given(                                          # @given genera casos de prueba automáticos.
    credit_score=st.integers(min_value=300, max_value=850),  # Estrategia: enteros en rango.
    age=st.integers(min_value=18, max_value=100)
)
def test_prediction_is_valid(credit_score, age):
    """Propiedad: la predicción siempre es 0 o 1."""  # Define invariante.
    input_data = {"credit_score": credit_score, "age": age}
    pred = model.predict(pd.DataFrame([input_data]))
    assert pred[0] in [0, 1]                     # Debe cumplirse para TODOS los inputs.

@given(df=st.data())                             # st.data(): permite draw dinámico.
def test_feature_engineer_preserves_rows(df):
    """Propiedad: FeatureEngineer no cambia número de filas."""
    sample = df.draw(st.dataframes(columns=[     # Genera DataFrame aleatorio.
        st.column("age", dtype=int),
        st.column("salary", dtype=float)
    ]))
    result = fe.transform(sample)
    assert len(result) == len(sample)            # Filas deben preservarse.
```

**Ventaja**: Encuentra edge cases que no pensaste.

---

## Pregunta 35: Testing de Modelos ML
**¿Cómo testeas que un modelo funciona correctamente?**

### Respuesta:
```python
# 1. Test de smoke: modelo carga y predice
def test_model_loads_and_predicts():
    model = joblib.load("artifacts/pipeline.joblib")  # Carga modelo.
    sample = pd.DataFrame([{"CreditScore": 650, "Age": 35}])
    pred = model.predict(sample)                 # Debe poder predecir.
    assert len(pred) == 1                        # Una predicción por fila.

# 2. Test de formato de salida
def test_prediction_format():
    pred = model.predict(X_test)
    assert pred.shape == (len(X_test),)          # Shape correcto.
    assert set(pred).issubset({0, 1})            # Solo valores válidos.

# 3. Test de rendimiento mínimo
def test_model_performance():
    y_pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, y_pred)
    assert accuracy >= 0.75, f"Accuracy {accuracy} below threshold"  # Umbral mínimo.

# 4. Test de invarianza
def test_prediction_deterministic():
    pred1 = model.predict(X_test)
    pred2 = model.predict(X_test)
    assert np.array_equal(pred1, pred2)          # Misma entrada = misma salida.
```

---

## Pregunta 36: Mocking
**¿Qué es mocking y cuándo usarlo?**

### Respuesta:
Mocking = reemplazar dependencias reales con objetos simulados.

```python
from unittest.mock import Mock, patch           # Mock: simula objetos. patch: reemplaza.

# Mockear llamada a API externa
@patch('myapp.external_api.get_customer_data')  # Reemplaza esta función.
def test_predict_with_external_data(mock_api):  # mock_api: objeto mock.
    # Configurar mock
    mock_api.return_value = {"credit_score": 700, "age": 45}  # Respuesta simulada.
    
    # Test usa el mock en lugar de API real
    result = predict_for_customer("C123")       # No llama API real.
    
    # Verificar que se llamó
    mock_api.assert_called_once_with("C123")    # Verifica argumentos.
    assert result is not None

# Mockear modelo para test de API
@patch('app.fastapi_app.model')                 # Reemplaza el modelo.
def test_predict_endpoint(mock_model):
    mock_model.predict.return_value = np.array([1])  # Simula predicción.
    mock_model.predict_proba.return_value = np.array([[0.2, 0.8]])
    
    response = client.post("/predict", json=sample_input)
    assert response.json()["prediction"] == 1   # Usa valor del mock.
```

**Cuándo usar**: APIs externas, base de datos, servicios lentos.

---

## Pregunta 37: Testing de APIs
**¿Cómo testeas endpoints de FastAPI?**

### Respuesta:
```python
from fastapi.testclient import TestClient       # Cliente para tests sin servidor.
from app.fastapi_app import app

client = TestClient(app)                        # Crea cliente de prueba.

def test_health_endpoint():
    response = client.get("/health")            # GET request.
    assert response.status_code == 200          # 200 OK.
    assert response.json()["status"] == "healthy"  # Verifica contenido.

def test_predict_valid_input():
    response = client.post("/predict", json={   # POST con JSON body.
        "credit_score": 650,
        "age": 35,
        "geography": "France"
    })
    assert response.status_code == 200
    assert "prediction" in response.json()      # Verifica campos de respuesta.
    assert "probability" in response.json()

def test_predict_invalid_input():
    response = client.post("/predict", json={
        "credit_score": 9999,                   # Fuera de rango: Pydantic rechaza.
        "age": 35
    })
    assert response.status_code == 422          # 422: Validation error.

def test_predict_missing_field():
    response = client.post("/predict", json={
        "credit_score": 650                     # Falta age: campo requerido.
    })
    assert response.status_code == 422
```

---

## Pregunta 38: Parametrized Tests
**¿Cómo evitas duplicación en tests?**

### Respuesta:
```python
import pytest

@pytest.mark.parametrize("credit_score,age,expected", [  # Lista de casos.
    (300, 18, 0),                               # Mínimos válidos.
    (850, 100, 1),                              # Máximos válidos.
    (650, 45, 0),                               # Caso típico.
])
def test_prediction_cases(credit_score, age, expected):  # Se ejecuta 3 veces.
    input_data = {"credit_score": credit_score, "age": age}
    pred = model.predict(pd.DataFrame([input_data]))
    assert pred[0] in [0, 1]                    # Verificamos formato, no valor exacto.

@pytest.mark.parametrize("invalid_input,expected_error", [  # Casos de error.
    ({"credit_score": -1}, "greater than or equal to 300"),
    ({"credit_score": 1000}, "less than or equal to 850"),
    ({"age": 5}, "greater than or equal to 18"),
])
def test_validation_errors(invalid_input, expected_error):
    response = client.post("/predict", json=invalid_input)
    assert response.status_code == 422          # Todos deben dar 422.
    assert expected_error in str(response.json())  # Mensaje de error esperado.
```

---

## Pregunta 39: Testing de Edge Cases
**¿Cómo testeas edge cases en ML?**

### Respuesta:
```python
# 1. Inputs vacíos
def test_empty_dataframe():
    df = pd.DataFrame()                          # DataFrame sin filas.
    with pytest.raises(ValueError):              # Debe lanzar error.
        model.predict(df)

# 2. Nulls
def test_missing_values():
    df = pd.DataFrame([{"CreditScore": None, "Age": 35}])  # NaN en feature.
    # Pipeline debe manejar o fallar graciosamente
    result = model.predict(df)                   # SimpleImputer debería manejar.

# 3. Outliers extremos
def test_extreme_values():
    df = pd.DataFrame([{
        "CreditScore": 850,
        "Age": 100,
        "Balance": 1_000_000_000                 # Outlier extremo.
    }])
    pred = model.predict(df)
    assert pred[0] in [0, 1]                     # Debe predecir sin fallar.

# 4. Tipos incorrectos
def test_wrong_types():
    with pytest.raises(Exception):               # Debe fallar con tipo incorrecto.
        model.predict("not a dataframe")         # String en vez de DataFrame.

# 5. Columnas faltantes
def test_missing_columns():
    df = pd.DataFrame([{"CreditScore": 650}])   # Falta Age.
    with pytest.raises(KeyError):                # Pipeline necesita todas las columnas.
        model.predict(df)
```

---

## Pregunta 40: Test-Driven Development (TDD)
**¿Cómo aplicas TDD en ML?**

### Respuesta:
TDD: Escribir test → Ver que falla → Implementar → Ver que pasa → Refactorizar.

```python
# 1. Escribir test primero
def test_feature_engineer_creates_age_bucket():
    df = pd.DataFrame({"age": [25, 45, 65]})     # Datos de prueba.
    fe = FeatureEngineer()
    result = fe.transform(df)
    
    assert "age_bucket" in result.columns        # Verifica que crea columna.
    assert list(result["age_bucket"]) == ["young", "middle", "senior"]  # Valores esperados.

# 2. Test falla (FeatureEngineer no existe aún)  # Red: test falla.
# 3. Implementar mínimo para pasar               # Green: código mínimo.
class FeatureEngineer(BaseEstimator, TransformerMixin):
    def transform(self, X):
        X = X.copy()
        X["age_bucket"] = pd.cut(                # pd.cut: binning.
            X["age"], 
            bins=[0, 30, 50, 100],               # Rangos de edad.
            labels=["young", "middle", "senior"] # Etiquetas.
        )
        return X

# 4. Test pasa ✓                                 # Verificar que pasa.
# 5. Refactorizar si es necesario               # Mejorar sin romper tests.
```

**En ML, TDD es útil para**:
- Feature engineering (definir comportamiento esperado)
- Validación de datos
- APIs

---

# 4. Deployment y APIs (Preguntas 41-50) {#4-deployment-y-apis-preguntas-41-50}

## Pregunta 41: FastAPI Basics
**Muestra un endpoint de predicción.**

### Respuesta:
```python
from fastapi import FastAPI                      # Framework web.
from pydantic import BaseModel                   # Validación de datos.

app = FastAPI()                                  # Crea aplicación.

class Input(BaseModel):                          # Schema de entrada.
    credit_score: int
    age: int

@app.post("/predict")                            # Endpoint POST.
def predict(data: Input):                        # FastAPI valida automáticamente.
    X = pd.DataFrame([data.dict()])              # Convierte a DataFrame.
    pred = model.predict(X)                      # Predice.
    return {"prediction": int(pred[0])}          # Retorna JSON.
```

---

## Pregunta 42: Health Checks
**¿Por qué tener /health endpoint?**

### Respuesta:
```python
@app.get("/health")                              # GET endpoint para health checks.
def health():
    return {
        "status": "healthy",                     # Estado general.
        "model_loaded": model is not None,       # Verifica que modelo cargó.
        "version": "1.0.0"                       # Versión para debugging.
    }
```

Kubernetes usa esto para saber si el pod está listo.

---

## Pregunta 43: Uvicorn y ASGI
**¿Qué es uvicorn y por qué usarlo?**

### Respuesta:
Uvicorn = servidor ASGI (Asynchronous Server Gateway Interface) de alto rendimiento.

```bash
# Desarrollo
uvicorn app.fastapi_app:app --reload --port 8000  # --reload: hot reload con cambios.

# Producción
uvicorn app.fastapi_app:app --host 0.0.0.0 --port 8000 --workers 4  # --workers: procesos paralelos.
```

**Configuración para producción**:
```python
# Con gunicorn + uvicorn workers
gunicorn app.fastapi_app:app \                   # gunicorn: gestor de procesos.
    --workers 4 \                                # 4 procesos worker.
    --worker-class uvicorn.workers.UvicornWorker \  # Workers ASGI.
    --bind 0.0.0.0:8000                          # Puerto y host.
```

**ASGI vs WSGI**:
| WSGI | ASGI |
|------|------|
| Sync only | Async + Sync |
| Flask, Django | FastAPI, Starlette |
| Una request a la vez por worker | Múltiples requests concurrentes |

---

## Pregunta 44: CORS Configuration
**¿Cómo manejas CORS en FastAPI?**

### Respuesta:
CORS = Cross-Origin Resource Sharing. Necesario cuando frontend y backend están en dominios distintos.

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware  # Middleware para CORS.

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=[                              # Orígenes permitidos.
        "http://localhost:3000",                 # React dev.
        "https://myapp.example.com",             # Producción.
    ],
    allow_credentials=True,                      # Permite cookies.
    allow_methods=["GET", "POST"],               # Métodos HTTP permitidos.
    allow_headers=["*"],                         # Headers permitidos.
)
```

**En producción**: Especificar orígenes exactos, no usar `"*"`.

---

## Pregunta 45: Async en FastAPI
**¿Cuándo usar async def vs def?**

### Respuesta:
```python
# Sync: operaciones CPU-bound o librerías sync
@app.post("/predict")
def predict(data: Input):                       # def: síncrono.
    result = model.predict(data)                 # sklearn es sync, no usar async.
    return {"prediction": result}

# Async: operaciones I/O-bound
@app.get("/external-data")
async def get_external():                        # async def: asíncrono.
    async with httpx.AsyncClient() as client:   # Cliente HTTP asíncrono.
        response = await client.get("https://api.example.com/data")  # await: espera sin bloquear.
    return response.json()
```

**Regla general**:
| Operación | Usar |
|-----------|------|
| sklearn, pandas, joblib | `def` (sync) |
| HTTP requests, DB async | `async def` |
| File I/O masivo | `async def` con aiofiles |

---

## Pregunta 46: Model Caching
**¿Cómo evitas cargar el modelo en cada request?**

### Respuesta:
```python
# FastAPI: lru_cache
from functools import lru_cache                  # Cache de funciones.

@lru_cache()                                     # Cachea resultado de la función.
def get_model():
    return joblib.load("artifacts/pipeline.joblib")  # Solo carga una vez.

@app.post("/predict")
def predict(data: Input):
    model = get_model()                          # Primera vez: carga. Resto: cache.
    return model.predict(data)

# Alternativa: cargar al inicio
model = None

@app.on_event("startup")                         # Se ejecuta al iniciar app.
async def load_model():
    global model                                 # Modifica variable global.
    model = joblib.load("artifacts/pipeline.joblib")
```

**Streamlit**:
```python
@st.cache_resource                               # Cache persistente entre reruns.
def load_model():
    return joblib.load("artifacts/pipeline.joblib")  # Solo carga una vez.

model = load_model()                             # Cacheado entre interacciones.
```

---

## Pregunta 47: Streamlit Dashboard
**¿Cómo creas un dashboard de predicción?**

### Respuesta:
```python
import streamlit as st
import pandas as pd

st.title("🏦 BankChurn Predictor")                # Título de la app.

# Sidebar para inputs
st.sidebar.header("Customer Data")               # Header en sidebar.
credit_score = st.sidebar.slider("Credit Score", 300, 850, 650)  # Slider con rango.
age = st.sidebar.slider("Age", 18, 100, 35)      # Valor default: 35.
geography = st.sidebar.selectbox("Geography", ["France", "Germany", "Spain"])  # Dropdown.

# Cargar modelo (cacheado)
@st.cache_resource                               # Cache para recursos pesados.
def load_model():
    return joblib.load("artifacts/pipeline.joblib")

model = load_model()                             # Carga una sola vez.

# Predicción
if st.sidebar.button("Predict"):                 # Botón que dispara predicción.
    input_df = pd.DataFrame([{                   # Crea DataFrame de entrada.
        "CreditScore": credit_score,
        "Age": age,
        "Geography": geography
    }])
    
    prediction = model.predict(input_df)[0]      # Predicción binaria.
    proba = model.predict_proba(input_df)[0, 1]  # Probabilidad de clase 1.
    
    col1, col2 = st.columns(2)                   # Layout en 2 columnas.
    col1.metric("Prediction", "Churn" if prediction else "Stay")  # Muestra resultado.
    col2.metric("Probability", f"{proba:.1%}")   # Probabilidad formateada.
```

---

## Pregunta 48: Docker Compose para ML
**¿Cómo orquestas múltiples servicios?**

### Respuesta:
```yaml
# docker-compose.yml
version: '3.8'

services:
  api:
    build: .                                     # Construye desde Dockerfile local.
    ports:
      - "8000:8000"                              # host:container.
    environment:
      - MODEL_PATH=/app/artifacts/pipeline.joblib  # Variable de entorno.
    volumes:
      - ./artifacts:/app/artifacts:ro            # ro: read-only.
    depends_on:
      - mlflow                                   # Espera a que mlflow inicie.
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]  # Health check.
      interval: 30s                              # Cada 30 segundos.
      timeout: 10s
      retries: 3

  mlflow:
    image: python:3.11-slim                      # Imagen base.
    command: mlflow server --host 0.0.0.0        # Comando de inicio.
    ports:
      - "5000:5000"
    volumes:
      - ./mlruns:/mlflow/mlruns                  # Persistencia de experimentos.

  prometheus:
    image: prom/prometheus                       # Imagen oficial.
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml  # Config.
```

```bash
docker-compose up -d                            # -d: detached (background).
docker-compose logs -f api                      # -f: follow logs en tiempo real.
```

---

## Pregunta 49: Kubernetes Deployment
**¿Cómo despliegas en Kubernetes?**

### Respuesta:
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment                                # Tipo de recurso K8s.
metadata:
  name: bankchurn-api
spec:
  replicas: 3                                   # 3 instancias del pod.
  selector:
    matchLabels:
      app: bankchurn-api                        # Selector para pods.
  template:
    metadata:
      labels:
        app: bankchurn-api
    spec:
      containers:
      - name: api
        image: bankchurn-api:v1.0.0             # Imagen Docker.
        ports:
        - containerPort: 8000                   # Puerto interno.
        resources:
          requests:                             # Mínimo garantizado.
            memory: "256Mi"
            cpu: "250m"                         # 0.25 CPU.
          limits:                               # Máximo permitido.
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:                          # Verifica si pod está vivo.
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30               # Espera antes de primer check.
          periodSeconds: 10                     # Cada 10 segundos.
        readinessProbe:                         # Verifica si puede recibir tráfico.
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service                                   # Expone pods como servicio.
metadata:
  name: bankchurn-api
spec:
  selector:
    app: bankchurn-api                          # Conecta con pods del Deployment.
  ports:
  - port: 80                                    # Puerto externo.
    targetPort: 8000                            # Puerto del contenedor.
  type: LoadBalancer                            # Expone externamente con LB.
```

```bash
kubectl apply -f deployment.yaml                # Aplica configuración.
kubectl get pods                                # Lista pods.
kubectl logs -f deployment/bankchurn-api        # Ver logs en tiempo real.
```

---

## Pregunta 50: Horizontal Pod Autoscaler
**¿Cómo escalas automáticamente?**

### Respuesta:
```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler                   # Autoescalador horizontal.
metadata:
  name: bankchurn-api-hpa
spec:
  scaleTargetRef:                               # Deployment a escalar.
    apiVersion: apps/v1
    kind: Deployment
    name: bankchurn-api
  minReplicas: 2                                # Mínimo 2 pods.
  maxReplicas: 10                               # Máximo 10 pods.
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70                  # Escala si CPU > 70%.
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80                  # Escala si memoria > 80%.
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300           # Espera 5 min antes de reducir.
    scaleUp:
      stabilizationWindowSeconds: 60            # Escala up más rápido (1 min).
```

```bash
kubectl apply -f hpa.yaml                       # Aplica HPA.
kubectl get hpa                                 # Ver estado del autoescalador.
# NAME                  REFERENCE              TARGETS   MINPODS   MAXPODS   REPLICAS
# bankchurn-api-hpa     Deployment/bankchurn   45%/70%   2         10        3  # 45% actual, 70% target.
```

---

# 5. Escenarios Prácticos (Preguntas 51-60) {#5-escenarios-prácticos-preguntas-51-60}

## Pregunta 51: Debug de Producción
**El modelo tiene accuracy 85% en dev pero 60% en prod. ¿Por qué?**

### Respuesta:
1. **Data drift**: Distribución de datos cambió
2. **Feature mismatch**: Features procesadas diferente
3. **Training-serving skew**: Preprocesamiento distinto
4. **Datos de prod con más ruido**: Edge cases no vistos

**Acciones**: Comparar distribuciones, revisar pipeline, logging de inputs.

---

## Pregunta 52: Code Review
**¿Qué buscas en un code review de ML?**

### Respuesta:
- [ ] Data leakage en split/preprocessing
- [ ] Tests para features y modelo
- [ ] Config externalizada (no hardcoded)
- [ ] Type hints y docstrings
- [ ] Reproducibilidad (seeds, versiones)
- [ ] Logging apropiado

---

## Pregunta 53: Explicabilidad del Modelo
**El cliente dice: "No puedo usar tu modelo si no me explicas por qué toma las decisiones".**

### Respuesta:
```python
import shap

# 1. SHAP para explicaciones individuales
explainer = shap.TreeExplainer(model)         # Explainer para modelos de árboles.
shap_values = explainer.shap_values(X_sample) # Calcula contribución de cada feature.

# Waterfall plot para una predicción
shap.waterfall_plot(shap.Explanation(         # Visualiza contribuciones.
    values=shap_values[0],                    # Valores SHAP de una predicción.
    base_values=explainer.expected_value,     # Valor base (promedio).
    data=X_sample.iloc[0]                     # Valores reales de features.
))

# 2. Feature importance global
shap.summary_plot(shap_values, X_sample)      # Resumen de todas las predicciones.

# 3. En producción: incluir en respuesta
@app.post("/predict")
def predict(data: Input):
    pred = model.predict(X)[0]
    
    # Top 3 razones
    shap_vals = explainer.shap_values(X)
    top_features = sorted(                    # Ordena por impacto.
        zip(feature_names, shap_vals[0]),
        key=lambda x: abs(x[1]),              # Valor absoluto del impacto.
        reverse=True
    )[:3]                                     # Solo top 3.
    
    return {
        "prediction": pred,
        "explanation": [                      # Explicación en respuesta.
            {"feature": f, "impact": v} 
            for f, v in top_features
        ]
    }
```

---

## Pregunta 54: Optimización de Latencia
**El modelo tarda 500ms por predicción. El negocio necesita <100ms.**

### Respuesta:
```python
# 1. Profiling: ¿dónde está el cuello de botella?
import cProfile
cProfile.run('model.predict(X_sample)')       # Identifica funciones lentas.

# 2. Opciones de optimización:

# a) Modelo más ligero
from sklearn.linear_model import LogisticRegression  # LR es 10x más rápido que RF.

# b) Reducir features
from sklearn.feature_selection import SelectKBest
selector = SelectKBest(k=10)                  # Solo top 10 features = menos cálculo.

# c) Batch predictions
@app.post("/predict/batch")
def predict_batch(items: List[Input]):
    X = pd.DataFrame([item.dict() for item in items])
    preds = model.predict(X)                  # Una llamada = menos overhead.
    return {"predictions": preds.tolist()}

# d) Caching de predicciones frecuentes
from functools import lru_cache

@lru_cache(maxsize=1000)                      # Cache últimas 1000 predicciones.
def predict_cached(credit_score: int, age: int):
    return model.predict([[credit_score, age]])[0]  # Cache hit = instantáneo.

# e) ONNX para inferencia rápida
from skl2onnx import convert_sklearn          # Convierte a formato optimizado.
onnx_model = convert_sklearn(model, initial_types=[...])  # Runtime más rápido.
```

**Métricas de latencia**:
| Optimización | Latencia típica |
|--------------|-----------------|
| RF sklearn | 50-200ms |
| LR sklearn | 1-5ms |
| ONNX | 1-10ms |
| Caching (hit) | <1ms |

---

## Pregunta 55: Manejo de PII
**El dataset contiene nombres, emails y teléfonos. ¿Cómo lo manejas?**

### Respuesta:
```python
# 1. Identificar columnas PII
pii_columns = ["name", "email", "phone", "ssn", "address"]  # Datos sensibles.

# 2. Anonimización
import hashlib

def anonymize_pii(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    for col in pii_columns:
        if col in df.columns:
            df[col] = df[col].apply(          # Hash irreversible.
                lambda x: hashlib.sha256(str(x).encode()).hexdigest()[:16]
            )                                 # No se puede revertir.
    return df

# 3. Drop antes de training (mejor opción)
X = df.drop(columns=pii_columns, errors='ignore')  # Elimina PII del modelo.

# 4. En logs: nunca loggear PII
logger.info(f"Prediction for customer {customer_id[:4]}***")  # Mascara ID.

# 5. En respuestas de API: mascarar
def mask_email(email: str) -> str:
    parts = email.split("@")
    return f"{parts[0][:2]}***@{parts[1]}"   # jo***@gmail.com.
```

**Compliance checklist**:
- [ ] PII no está en features del modelo
- [ ] PII no aparece en logs
- [ ] PII no se almacena en MLflow/tracking
- [ ] Acceso a datos restringido

---

## Pregunta 56: Fairness y Bias
**Producto detectó que el modelo rechaza más a clientes de cierta región.**

### Respuesta:
```python
from fairlearn.metrics import MetricFrame      # Fairlearn: librería de fairness.
from sklearn.metrics import accuracy_score, recall_score

# 1. Calcular métricas por grupo
metrics = MetricFrame(
    metrics={
        "accuracy": accuracy_score,
        "recall": recall_score
    },
    y_true=y_test,
    y_pred=y_pred,
    sensitive_features=df_test["geography"]   # Variable sensible.
)

print(metrics.by_group)                        # Métricas por grupo.
#              accuracy  recall
# geography
# France         0.85     0.80
# Germany        0.83     0.78
# Spain          0.70     0.55                 # ← Problema: peor para Spain.

# 2. Mitigación
from fairlearn.reductions import ExponentiatedGradient  # Algoritmo de mitigación.
from fairlearn.constraints import DemographicParity     # Restricción de fairness.

mitigator = ExponentiatedGradient(
    estimator=base_model,
    constraints=DemographicParity()            # Igualar tasas entre grupos.
)
mitigator.fit(X_train, y_train, sensitive_features=train_geography)

# 3. Monitoreo continuo
# Alertar si la diferencia entre grupos > 10%  # Dashboard de fairness.
```

---

## Pregunta 57: Tests Flaky en CI
**El CI pasa 80% de las veces y falla 20% sin cambios en código.**

### Respuesta:
```python
# 1. Problema común: Random sin seed
# ❌ Mal
model = RandomForestClassifier()              # Sin seed: resultados diferentes cada vez.

# ✅ Bien
model = RandomForestClassifier(random_state=42)  # Seed fija: resultados reproducibles.

# 2. Problema: Orden de ejecución
# ❌ Mal: test depende de otro
def test_predict():
    assert model.predict(X) == [1]            # model de test anterior: dependencia oculta.

# ✅ Bien: tests aislados
@pytest.fixture
def trained_model():                          # Fixture crea modelo fresco.
    m = Model()
    m.fit(X, y)
    return m

def test_predict(trained_model):              # Test recibe su propio modelo.
    assert trained_model.predict(X)

# 3. Problema: Timeouts en CI
# ❌ Mal
requests.get("https://external-api.com", timeout=5)  # API externa puede fallar.

# ✅ Bien
@pytest.fixture
def mock_api():                               # Mock evita llamadas externas.
    with patch("myapp.api.get") as mock:
        mock.return_value = {"data": "test"}
        yield mock

# 4. Debug: Correr múltiples veces
pytest tests/ --count=10                      # pytest-repeat: detecta tests flaky.
```

---

## Pregunta 58: Modelo Grande para Deploy
**El modelo pesa 2GB y tarda 30s en cargar. ¿Cómo optimizas?**

### Respuesta:
```python
# 1. Quantization (reducir precisión)
import onnxruntime as ort
from onnxruntime.quantization import quantize_dynamic

quantize_dynamic(
    "model.onnx",
    "model_quantized.onnx",
    weight_type=ort.QuantType.QInt8             # 8-bit en vez de 32-bit.
)
# 2GB → ~500MB                                  # 4x reducción de tamaño.

# 2. Model distillation (modelo más pequeño que imita al grande)
teacher = load_large_model()                    # Modelo grande y lento.
student = SmallModel()                          # Modelo pequeño y rápido.

# Entrenar student con outputs del teacher
student_preds = student(X)
teacher_preds = teacher(X)                      # Student aprende a imitar teacher.
loss = mse_loss(student_preds, teacher_preds)   # Minimiza diferencia.

# 3. Feature selection (menos features = modelo más pequeño)
from sklearn.feature_selection import SelectFromModel
selector = SelectFromModel(model, threshold="median")  # Selecciona features importantes.
X_reduced = selector.transform(X)               # Menos columnas = modelo más ligero.

# 4. Lazy loading en API
model = None

@app.on_event("startup")                        # Carga al iniciar, no en cada request.
async def load():
    global model
    model = joblib.load("model.joblib")         # Solo una vez, cacheado.
```

---

## Pregunta 59: Muchos Falsos Positivos
**El modelo predice churn para clientes que claramente no van a irse.**

### Respuesta:
```python
# 1. Ajustar threshold (default=0.5)
y_proba = model.predict_proba(X_test)[:, 1]     # Probabilidades de clase 1.

# Encontrar threshold óptimo
from sklearn.metrics import precision_recall_curve

precision, recall, thresholds = precision_recall_curve(y_test, y_proba)

# Threshold que maximiza F1
f1_scores = 2 * (precision * recall) / (precision + recall)  # Fórmula F1.
optimal_threshold = thresholds[np.argmax(f1_scores)]  # Mejor threshold.
print(f"Optimal threshold: {optimal_threshold}")  # Ej: 0.65 en vez de 0.5.

# Usar nuevo threshold
y_pred = (y_proba >= optimal_threshold).astype(int)  # Threshold más alto = menos FP.

# 2. Revisar balance de datos
print(y_train.value_counts(normalize=True))     # Ver proporciones de clases.
# Si muy desbalanceado: SMOTE, class_weight     # Técnicas de balanceo.

# 3. Verificar data leakage
# ¿Hay features que "predicen perfectamente"?
for col in X.columns:
    corr = X[col].corr(y)
    if abs(corr) > 0.9:                         # Correlación sospechosa.
        print(f"⚠️ {col} tiene correlación {corr}")  # Posible leakage.
```

---

## Pregunta 60: Comunicar a Stakeholders No Técnicos
**El VP de producto pregunta: "¿Funciona o no funciona tu modelo?"**

### Respuesta:
```python
# 1. Traducir métricas técnicas a impacto de negocio
"""
❌ Mal: "El modelo tiene AUC 0.85 y F1 0.78"  # Términos que no entienden.

✅ Bien:                                        # Lenguaje de negocio.
"Por cada 100 clientes que van a hacer churn:
- Detectamos 78 antes de que se vayan          # Recall en lenguaje simple.
- De los que marcamos como riesgo, 82% efectivamente se iban  # Precision.

Impacto: Si cada cliente perdido cuesta $500,
el modelo puede prevenir $31,200 en pérdidas mensuales  # $$$
(78 clientes × $500 × 80% tasa de retención con intervención)"
"""

# 2. Visualizaciones claras
import plotly.express as px                     # Plotly: gráficos interactivos.

# Confusion matrix visual
fig = px.imshow(
    [[TN, FP], [FN, TP]],                       # Matriz de confusión.
    labels=dict(x="Predicted", y="Actual"),
    x=["Stay", "Churn"],
    y=["Stay", "Churn"],
    text_auto=True                              # Muestra números en celdas.
)
fig.show()

# 3. Dashboard ejecutivo en Streamlit
st.metric("Clientes en Riesgo", "234", delta="-12 vs mes pasado")  # KPI con delta.
st.metric("Precision Retención", "82%", delta="+5%")  # Métrica clave.
st.metric("Ahorro Estimado", "$45,000/mes")     # Impacto en dinero.
```

**Regla de oro**: Siempre conectar con dinero o KPIs que el stakeholder ya conoce.

---

# 📚 Recursos

| Tema | Módulo |
|------|--------|
| Pipelines | [07_SKLEARN_PIPELINES.md](07_SKLEARN_PIPELINES.md) |
| Testing | [11_TESTING_ML.md](11_TESTING_ML.md) |
| CI/CD | [12_CI_CD.md](12_CI_CD.md) |
| Docker | [13_DOCKER.md](13_DOCKER.md) |
| FastAPI | [14_FASTAPI.md](14_FASTAPI.md) |
| MLflow | [10_EXPERIMENT_TRACKING.md](10_EXPERIMENT_TRACKING.md) |

---

<div align="center">

**¡Éxito en tu entrevista! 🚀**

[← Simulacro Junior](SIMULACRO_ENTREVISTA_JUNIOR.md) | [Simulacro Senior →](SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md)

</div>
