# 🚀 Guía MLOps — Portfolio Edition (24 Semanas)

> **De Cero a Senior/Staff MLOps en 6 Meses**
> 
> Mapa completo para construir el portafolio [ML-MLOps-Portfolio](https://github.com/DuqueOM/ML-MLOps-Portfolio) desde cero.

---

## 📋 Tabla de Contenidos

1. [¿Qué Lograrás?](#-qué-lograrás)
2. [Estructura del Programa (24 Semanas)](#-estructura-del-programa-24-semanas)
3. [Tabla de Mapeo: Concepto → Herramienta → Portafolio](#-tabla-de-mapeo-concepto--herramienta--portafolio)
4. [Roadmap Visual](#-roadmap-visual)
5. [Contenido por Mes](#-contenido-por-mes)
6. [Exámenes de Hito (6 Milestones)](#-exámenes-de-hito-6-milestones)
7. [Guía de Troubleshooting](#-guía-de-troubleshooting)
8. [Quick Start](#-quick-start)
9. [Estructura de Carpetas](#-estructura-de-carpetas)

---

## 🎯 ¿Qué Lograrás?

Al completar esta guía de 24 semanas serás capaz de:

| Habilidad | Nivel | Evidencia en el Portafolio |
|-----------|-------|---------------------------|
| **Código Python profesional** | Senior | Type hints, Pydantic, SOLID en los 3 proyectos |
| **Pipelines ML reproducibles** | Senior | sklearn Pipeline unificado, sin data leakage |
| **Versionado de datos y modelos** | Senior | DVC pipelines, MLflow Model Registry |
| **Testing & CI/CD** | Senior | 80%+ coverage, GitHub Actions, matrix testing |
| **APIs de producción** | Senior | FastAPI con validación, Docker multi-stage |
| **Observabilidad** | Staff | Prometheus, logging estructurado, drift detection |
| **Infraestructura como Código** | Staff | Terraform, Kubernetes manifests |
| **Pasar entrevistas técnicas** | Staff | Simulacros completos, speech de 5-7 min |

---

## 📅 Estructura del Programa (24 Semanas)

```
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                        RUTA DE APRENDIZAJE (24 SEMANAS / 6 MESES)                    ║
╠══════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                      ║
║  MES 1: FUNDAMENTOS (Semanas 1-4)                                                    ║
║  ════════════════════════════════                                                    ║
║  [S1] Python Moderno + Tipado                                                        ║
║  [S2] Diseño de Sistemas + Arquitectura                                              ║
║  [S3] Estructura de Proyecto + Entornos                                              ║
║  [S4] Git Profesional + Pre-commit                                                   ║
║       📋 EXAMEN HITO 1: Setup Completo                                               ║
║                                                                                      ║
║  MES 2: DATOS & VERSIONADO (Semanas 5-8)                                             ║
║  ════════════════════════════════════════                                            ║
║  [S5] DVC Fundamentos + Remote Storage                                               ║
║  [S6] Pipelines DVC + Reproducibilidad                                               ║
║  [S7] sklearn Pipelines Básicos                                                      ║
║  [S8] ColumnTransformer + Custom Transformers                                        ║
║       📋 EXAMEN HITO 2: Pipeline Reproducible                                        ║
║                                                                                      ║
║  MES 3: ML ENGINEERING (Semanas 9-12)                                                ║
║  ════════════════════════════════════                                                ║
║  [S9]  Ingeniería de Features                                                        ║
║  [S10] Training Profesional + Cross-Validation                                       ║
║  [S11] MLflow Tracking + UI                                                          ║
║  [S12] MLflow Model Registry + Signatures                                            ║
║       📋 EXAMEN HITO 3: Experimento Completo                                         ║
║                                                                                      ║
║  MES 4: TESTING & CI/CD (Semanas 13-16)                                              ║
║  ══════════════════════════════════════                                              ║
║  [S13] Testing Unitario para ML                                                      ║
║  [S14] Testing de Integración + Fixtures                                             ║
║  [S15] GitHub Actions + Matrix Testing                                               ║
║  [S16] Coverage Gates + Security Scanning                                            ║
║       📋 EXAMEN HITO 4: CI/CD Completo                                               ║
║                                                                                      ║
║  MES 5: DEPLOYMENT (Semanas 17-20)                                                   ║
║  ═════════════════════════════════                                                   ║
║  [S17] Docker Fundamentos + Multi-stage                                              ║
║  [S18] FastAPI para ML + Schemas Pydantic                                            ║
║  [S19] Streamlit Dashboards + Caching                                                ║
║  [S20] Observabilidad + Logging Estructurado                                         ║
║       📋 EXAMEN HITO 5: API Desplegada                                               ║
║                                                                                      ║
║  MES 6: PRODUCCIÓN & MAESTRÍA (Semanas 21-24)                                        ║
║  ═════════════════════════════════════════════                                       ║
║  [S21] Estrategias de Despliegue + Cloud                                             ║
║  [S22] Infraestructura como Código (Terraform)                                       ║
║  [S23] Documentación Profesional + Model Cards                                       ║
║  [S24] Proyecto Integrador + Preparación Entrevistas                                 ║
║       📋 EXAMEN HITO 6: Portafolio Completo                                          ║
║                                                                                      ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
```

**Dedicación sugerida**: 8-10 horas/semana (total ~200 horas)

---

## 🗺️ Tabla de Mapeo: Concepto → Herramienta → Portafolio

Esta tabla conecta cada concepto teórico con la herramienta práctica y su ubicación exacta en el portafolio:

| Semana | Concepto Teórico | Herramienta | Ubicación en Portafolio | Módulo Guía |
|:------:|------------------|-------------|-------------------------|-------------|
| **S1** | Tipado estático | `mypy`, `Pydantic` | `*/src/*/config.py` | [01_PYTHON_MODERNO](docs/01_PYTHON_MODERNO.md) |
| **S2** | Arquitectura ML | ML Canvas, C4 Model | `docs/architecture/` | [02_DISENO_SISTEMAS](docs/02_DISENO_SISTEMAS.md) |
| **S3** | Estructura código | `src/` layout | `BankChurn-Predictor/src/` | [03_ESTRUCTURA_PROYECTO](docs/03_ESTRUCTURA_PROYECTO.md) |
| **S4** | Calidad código | `pre-commit`, `ruff` | `.pre-commit-config.yaml` | [05_GIT_PROFESIONAL](docs/05_GIT_PROFESIONAL.md) |
| **S5** | Versionado datos | **DVC** | `.dvc/`, `data/*.dvc` | [06_VERSIONADO_DATOS](docs/06_VERSIONADO_DATOS.md) |
| **S6** | Pipelines datos | **DVC pipelines** | `dvc.yaml`, `dvc.lock` | [06_VERSIONADO_DATOS](docs/06_VERSIONADO_DATOS.md) |
| **S7** | Preprocesamiento | `sklearn.Pipeline` | `*/src/*/pipeline.py` | [07_SKLEARN_PIPELINES](docs/07_SKLEARN_PIPELINES.md) |
| **S8** | Transformaciones | `ColumnTransformer` | `*/src/*/pipeline.py` | [07_SKLEARN_PIPELINES](docs/07_SKLEARN_PIPELINES.md) |
| **S9** | Feature Engineering | Custom Transformers | `*/src/*/features.py` | [08_INGENIERIA_FEATURES](docs/08_INGENIERIA_FEATURES.md) |
| **S10** | Entrenamiento | `Trainer` class, CV | `*/src/*/trainer.py` | [09_TRAINING_PROFESIONAL](docs/09_TRAINING_PROFESIONAL.md) |
| **S11** | Experiment Tracking | **MLflow** | `mlruns/`, `mlflow.log_*` | [10_EXPERIMENT_TRACKING](docs/10_EXPERIMENT_TRACKING.md) |
| **S12** | Model Registry | **MLflow Registry** | `models:/model_name/` | [10_EXPERIMENT_TRACKING](docs/10_EXPERIMENT_TRACKING.md) |
| **S13** | Testing unitario | **pytest** | `tests/unit/` | [11_TESTING_ML](docs/11_TESTING_ML.md) |
| **S14** | Testing integración | `pytest-fixtures` | `tests/integration/` | [11_TESTING_ML](docs/11_TESTING_ML.md) |
| **S15** | CI/CD | **GitHub Actions** | `.github/workflows/ci.yml` | [12_CI_CD](docs/12_CI_CD.md) |
| **S16** | Security | `gitleaks`, `safety` | `.github/workflows/security.yml` | [12_CI_CD](docs/12_CI_CD.md) |
| **S17** | Containerización | **Docker** | `Dockerfile`, `docker-compose.yml` | [13_DOCKER](docs/13_DOCKER.md) |
| **S18** | APIs ML | **FastAPI** | `app/fastapi_app.py` | [14_FASTAPI](docs/14_FASTAPI.md) |
| **S19** | Dashboards | **Streamlit** | `app/streamlit_app.py` | [15_STREAMLIT](docs/15_STREAMLIT.md) |
| **S20** | Observabilidad | `loguru`, Prometheus | `*/src/*/logging.py` | [16_OBSERVABILIDAD](docs/16_OBSERVABILIDAD.md) |
| **S21** | Deploy strategies | Blue-green, Canary | `k8s/`, deployment configs | [17_DESPLIEGUE](docs/17_DESPLIEGUE.md) |
| **S22** | IaC | **Terraform** | `infra/terraform/` | [18_INFRAESTRUCTURA](docs/18_INFRAESTRUCTURA.md) |
| **S23** | Documentación | Model Cards, MkDocs | `docs/model_card.md` | [19_DOCUMENTACION](docs/19_DOCUMENTACION.md) |
| **S24** | Integración | Todo el stack | Portafolio completo | [20_PROYECTO_INTEGRADOR](docs/20_PROYECTO_INTEGRADOR.md) |

---

## 🔧 Herramientas del Stack Completo

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              STACK MLOps COMPLETO                                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  DESARROLLO          │  ML/DATA             │  MLOps              │  PRODUCCIÓN     │
│  ──────────          │  ───────             │  ─────              │  ──────────     │
│  • Python 3.10+      │  • pandas            │  • DVC              │  • Docker       │
│  • Pydantic          │  • numpy             │  • MLflow           │  • FastAPI      │
│  • mypy              │  • scikit-learn      │  • pytest           │  • Streamlit    │
│  • ruff              │  • joblib            │  • GitHub Actions   │  • Prometheus   │
│  • pre-commit        │                      │  • gitleaks         │  • Terraform    │
│  • Poetry/pip        │                      │                     │  • Kubernetes   │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📚 Contenido por Mes

---

### 🗓️ MES 1: FUNDAMENTOS PYTHON PROFESIONAL (Semanas 1-4)

> **Objetivo**: Dominar Python a nivel Staff Engineer — el código del Portafolio NO se puede entender sin esto.

---

#### 📖 Semana 1: Type Hints + Pydantic

**🎯 Objetivo**: Código con contratos explícitos y configuración validada.

##### 📐 Teoría Fundamental

| Concepto | Definición | Impacto en MLOps |
|----------|------------|------------------|
| **Tipado Estático** | Declarar tipos en tiempo de escritura | mypy detecta errores ANTES de ejecutar |
| **Validación en Frontera** | Verificar datos al ENTRAR al sistema | Errores claros vs crashes crípticos |
| **Fail Fast** | Fallar inmediatamente con error descriptivo | Costo de bug: $1 (código) vs $1000 (producción) |

##### 🔧 Práctica de Ingeniería

```python
# ═══════════════════════════════════════════════════════════════════════════
# EL PROBLEMA: Código Junior sin tipos
# ═══════════════════════════════════════════════════════════════════════════
def train(data, config):  # ¿Qué tipos? ¿Qué retorna?
    pass  # Error aparece 3 capas después

# ═══════════════════════════════════════════════════════════════════════════
# LA SOLUCIÓN: Código Staff con contratos
# ═══════════════════════════════════════════════════════════════════════════
from typing import Tuple
import pandas as pd
from pydantic import BaseModel, Field

class TrainConfig(BaseModel):
    test_size: float = Field(default=0.2, ge=0.01, le=0.5)
    n_estimators: int = Field(default=100, ge=10)

def train(
    data: pd.DataFrame,
    config: TrainConfig
) -> Tuple[Pipeline, dict[str, float]]:
    """Contrato claro: mypy verifica, Pydantic valida."""
    ...
```

##### 💻 Comandos Exactos

```bash
pip install pydantic mypy ruff
mypy src/bankchurn/training.py --strict  # 0 errores = listo
```

**📦 Puente al Portafolio**: `BankChurn-Predictor/src/bankchurn/config.py`

**📝 Tarea**: Tipar TODAS las funciones públicas de `training.py`

---

#### 📖 Semana 2: OOP para ML — Protocolos y ABC

**🎯 Objetivo**: Escribir código intercambiable y extensible con OOP profesional.

##### 📐 Teoría Fundamental

| Concepto | Definición | Uso en el Portafolio |
|----------|------------|---------------------|
| **Protocol** | Duck typing verificable por mypy | Compatibilidad con sklearn sin herencia |
| **ABC (Abstract Base Class)** | Contrato que OBLIGA implementación | BaseTrainer para los 3 proyectos |
| **Polimorfismo** | Mismo método, diferentes implementaciones | `trainer.fit()` funciona igual en BankChurn, CarVision, TelecomAI |

##### 🔧 Práctica de Ingeniería

```python
# ═══════════════════════════════════════════════════════════════════════════
# EL PROBLEMA: 3 trainers con APIs diferentes
# ═══════════════════════════════════════════════════════════════════════════
class TrainerA:
    def entrenar(self, X, y): ...  # español
class TrainerB:
    def fit_model(self, data): ...  # diferente firma

# ═══════════════════════════════════════════════════════════════════════════
# LA SOLUCIÓN: ABC define el contrato
# ═══════════════════════════════════════════════════════════════════════════
from abc import ABC, abstractmethod
import pandas as pd

class BaseTrainer(ABC):
    """Todos los trainers del portafolio heredan de aquí."""
    
    @abstractmethod
    def fit(self, X: pd.DataFrame, y: pd.Series) -> "BaseTrainer":
        """Entrenar modelo."""
        pass
    
    @abstractmethod
    def predict(self, X: pd.DataFrame) -> pd.Series:
        """Predecir."""
        pass

# Protocol para sklearn (sin herencia):
from typing import Protocol, runtime_checkable

@runtime_checkable
class Predictor(Protocol):
    def fit(self, X, y): ...
    def predict(self, X): ...

# sklearn cumple automáticamente:
from sklearn.ensemble import RandomForestClassifier
assert isinstance(RandomForestClassifier(), Predictor)  # True
```

**📦 Puente al Portafolio**: Crear `common_utils/base.py` con `BaseTrainer`

**📝 Tarea**: Hacer que `ChurnTrainer` herede de `BaseTrainer`

---

#### 📖 Semana 3: Pandas de Producción + Pandera

**🎯 Objetivo**: Validar DataFrames ANTES de que causen errores en el pipeline.

##### 📐 Teoría Fundamental

| Concepto | Definición | Por qué es crítico |
|----------|------------|-------------------|
| **Schema** | Contrato de estructura de datos | Define qué columnas, tipos y rangos son válidos |
| **Pandera** | Validación de DataFrames con decoradores | Error claro: "Age debe ser >= 18" vs crash en sklearn |
| **Data Contract** | Acuerdo entre productor y consumidor de datos | El pipeline de features ESPERA cierta estructura |

##### 🔧 Práctica de Ingeniería

```python
# ═══════════════════════════════════════════════════════════════════════════
# EL PROBLEMA: Código Junior asume DataFrame correcto
# ═══════════════════════════════════════════════════════════════════════════
def train(df):
    X = df.drop("Exited", axis=1)  # ¿Y si "Exited" no existe?
    y = df["Exited"]  # ¿Y si tiene valores inválidos como 2 o -1?

# ═══════════════════════════════════════════════════════════════════════════
# LA SOLUCIÓN: Pandera valida en la frontera
# ═══════════════════════════════════════════════════════════════════════════
import pandera as pa
from pandera.typing import DataFrame, Series

class BankChurnSchema(pa.DataFrameModel):
    CreditScore: Series[int] = pa.Field(ge=300, le=850)
    Age: Series[int] = pa.Field(ge=18, le=100)
    Balance: Series[float] = pa.Field(ge=0)
    Exited: Series[int] = pa.Field(isin=[0, 1])
    
    class Config:
        strict = True  # No permite columnas extra

@pa.check_types
def train(df: DataFrame[BankChurnSchema]) -> Pipeline:
    """DataFrame GARANTIZADO válido por Pandera."""
    X = df.drop("Exited", axis=1)
    y = df["Exited"]
    ...
```

##### 💻 Comandos Exactos

```bash
pip install pandera
# Crear src/bankchurn/schemas.py con los schemas
pytest tests/test_schemas.py -v
```

**📦 Puente al Portafolio**: `BankChurn-Predictor/src/bankchurn/schemas.py`

**📝 Tarea**: Crear `RawDataSchema` (permisivo) y `ProcessedDataSchema` (estricto)

---

#### 📖 Semana 4: Estructura de Proyecto + Git Profesional

**🎯 Objetivo**: Organizar código como paquete instalable con calidad automatizada.

##### 📐 Teoría Fundamental

| Concepto | Definición | Beneficio |
|----------|------------|-----------|
| **src/ Layout** | Código en `src/package/` | Fuerza `pip install -e .` — evita "funciona en mi máquina" |
| **pyproject.toml** | Metadata estándar del proyecto | Un archivo para deps, tools, builds |
| **Pre-commit** | Hooks que corren antes de commit | Calidad GARANTIZADA en cada commit |

##### 🔧 Práctica de Ingeniería

```
BankChurn-Predictor/
├── src/bankchurn/          # Código fuente
│   ├── __init__.py         # Exporta API pública
│   ├── config.py           # Pydantic
│   ├── schemas.py          # Pandera  
│   ├── training.py         # Trainer
│   └── cli.py              # CLI
├── tests/                  # Tests (espejo de src/)
├── configs/config.yaml     # Config externa
├── pyproject.toml          # Metadata
├── Makefile                # Comandos
└── .pre-commit-config.yaml # Hooks
```

##### 💻 Comandos Exactos

```bash
# Instalar en modo editable
pip install -e ".[dev]"

# Verificar import funciona
python -c "from bankchurn import ChurnTrainer; print('OK')"

# Configurar pre-commit
pip install pre-commit
pre-commit install
pre-commit run --all-files

# Commit convencional
git commit -m "feat(training): add type hints to ChurnTrainer"
```

**📦 Puente al Portafolio**: `BankChurn-Predictor/pyproject.toml`

**📝 Tarea**: `pip install -e ".[dev]"` + `pytest` + `mypy` pasan sin errores

---

### 🗓️ MES 2: DATOS & PIPELINES (Semanas 5-8)

> **Objetivo**: Dominar versionado de datos, pipelines reproducibles y preprocesamiento profesional.

---

#### 📖 Semana 5: DVC — Versionado de Datos

**🎯 Objetivo**: Versionar datos como se versiona código.

##### 📐 Teoría Fundamental

| Concepto | Definición | Por qué es crítico |
|----------|------------|-------------------|
| **Reproducibilidad** | Obtener EXACTAMENTE el mismo resultado | "Dame los datos de hace 3 meses" |
| **Data Lineage** | Rastrear origen y transformaciones de datos | Debugging y compliance |
| **Content-addressable** | Archivos identificados por hash, no por nombre | Detecta cambios automáticamente |

##### 🔧 Práctica de Ingeniería

```python
# ═══════════════════════════════════════════════════════════════════════════
# EL PROBLEMA: Datos en carpetas con fechas
# ═══════════════════════════════════════════════════════════════════════════
# data/
# ├── customers_v1.csv
# ├── customers_v2_final.csv
# ├── customers_v2_final_REAL.csv  # ← ¿Cuál es el bueno?
# ├── customers_backup_juan.csv

# ═══════════════════════════════════════════════════════════════════════════
# LA SOLUCIÓN: DVC trackea por contenido
# ═══════════════════════════════════════════════════════════════════════════
# data/
# └── customers.csv.dvc  # ← Git trackea esto (puntero)
# El archivo real está en remote storage, identificado por hash MD5
```

##### 💻 Comandos Exactos

```bash
# Inicializar DVC
dvc init
dvc add data/raw/bank_customers.csv

# Ver el puntero creado
cat data/raw/bank_customers.csv.dvc
# outs:
#   - md5: d41d8cd98f00b204e9800998ecf8427e
#     path: bank_customers.csv

# Commitear puntero (no datos)
git add data/raw/bank_customers.csv.dvc data/raw/.gitignore
git commit -m "data: add raw customer data v1"

# Configurar remote y push
dvc remote add -d storage s3://my-bucket/dvc
dvc push
```

**📦 Puente al Portafolio**: `BankChurn-Predictor/data/*.dvc`, `.dvc/config`

**📝 Tarea**: `dvc pull` en una carpeta nueva debe traer exactamente los mismos datos

---

#### � Semana 6: Pipelines DVC + Reproducibilidad

**🎯 Objetivo**: Crear pipelines de datos reproducibles con DAGs.

##### 📐 Teoría Fundamental

| Concepto | Definición | Por qué es crítico |
|----------|------------|-------------------|
| **DAG** | Directed Acyclic Graph — pasos ordenados sin ciclos | Solo re-ejecuta lo que cambió |
| **Determinismo** | Mismo input → mismo output siempre | Reproducibilidad científica |
| **Idempotencia** | Ejecutar N veces = ejecutar 1 vez | Safe to retry |

##### 🔧 Práctica de Ingeniería

```yaml
# dvc.yaml — Define el pipeline completo
stages:
  prepare:
    cmd: python src/bankchurn/prepare.py
    deps:
      - src/bankchurn/prepare.py
      - data/raw/bank_customers.csv
    outs:
      - data/processed/train.csv
      - data/processed/test.csv

  train:
    cmd: python src/bankchurn/train.py
    deps:
      - src/bankchurn/train.py
      - data/processed/train.csv
    outs:
      - models/model.pkl
    metrics:
      - metrics.json:
          cache: false
```

##### 💻 Comandos Exactos

```bash
dvc repro           # Ejecuta pipeline completo
dvc dag             # Visualiza el DAG
dvc metrics show    # Muestra métricas
dvc metrics diff    # Compara entre versiones
```

**📦 Puente al Portafolio**: `BankChurn-Predictor/dvc.yaml`, `dvc.lock`

**📝 Tarea**: `dvc repro` ejecuta sin errores y genera `metrics.json`

---

#### 📖 Semana 7: sklearn Pipelines — Sin Data Leakage

**🎯 Objetivo**: Crear pipelines ML que previenen data leakage.

##### � Teoría Fundamental

| Concepto | Definición | Por qué es crítico |
|----------|------------|-------------------|
| **Data Leakage** | Información del test contamina el train | Modelo parece bueno pero falla en producción |
| **fit vs transform** | fit aprende estadísticas, transform las aplica | fit SOLO en train, transform en train Y test |
| **Pipeline** | Cadena de transformaciones como un objeto | Encapsula preprocessing + modelo |

##### � Práctica de Ingeniería

```python
# ═══════════════════════════════════════════════════════════════════════════
# EL PROBLEMA: Data Leakage (error de principiante)
# ═══════════════════════════════════════════════════════════════════════════
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # ❌ fit en TODO X (incluye test)
X_train, X_test = train_test_split(X_scaled)  # Leakage!

# ═══════════════════════════════════════════════════════════════════════════
# LA SOLUCIÓN: Pipeline encapsula todo
# ═══════════════════════════════════════════════════════════════════════════
from sklearn.pipeline import Pipeline

pipeline = Pipeline([
    ("imputer", SimpleImputer(strategy="median")),
    ("scaler", StandardScaler()),
    ("classifier", RandomForestClassifier())
])

# Split ANTES de cualquier fit
X_train, X_test, y_train, y_test = train_test_split(X, y)

# fit_transform SOLO en train
pipeline.fit(X_train, y_train)  # ✅ Aprende de train

# transform implícito en predict (usa estadísticas de train)
predictions = pipeline.predict(X_test)  # ✅ Sin leakage
```

**📦 Puente al Portafolio**: `BankChurn-Predictor/src/bankchurn/pipeline.py`

**📝 Tarea**: Crear `create_pipeline()` que retorna Pipeline completo

---

#### 📖 Semana 8: ColumnTransformer + Custom Transformers

**🎯 Objetivo**: Procesar diferentes tipos de columnas con transformadores custom.

##### � Teoría Fundamental

| Concepto | Definición | Por qué es crítico |
|----------|------------|-------------------|
| **ColumnTransformer** | Aplica transformaciones diferentes por grupo de columnas | Numéricas: escalar, Categóricas: one-hot |
| **BaseEstimator + TransformerMixin** | Clases base para transformadores sklearn-compatible | Tu transformer funciona en Pipeline |
| **fit/transform API** | Contrato estándar de sklearn | Interoperabilidad garantizada |

##### � Práctica de Ingeniería

```python
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.compose import ColumnTransformer
import numpy as np

class OutlierClipper(BaseEstimator, TransformerMixin):
    """Custom transformer que recorta outliers usando IQR."""
    
    def __init__(self, factor: float = 1.5):
        self.factor = factor
    
    def fit(self, X, y=None):
        Q1, Q3 = np.percentile(X, [25, 75], axis=0)
        IQR = Q3 - Q1
        self.lower_ = Q1 - self.factor * IQR
        self.upper_ = Q3 + self.factor * IQR
        return self  # ← Siempre retorna self
    
    def transform(self, X):
        return np.clip(X, self.lower_, self.upper_)

# Uso en ColumnTransformer:
preprocessor = ColumnTransformer([
    ("num", Pipeline([
        ("imputer", SimpleImputer(strategy="median")),
        ("outlier", OutlierClipper()),
        ("scaler", StandardScaler())
    ]), numerical_columns),
    ("cat", Pipeline([
        ("imputer", SimpleImputer(strategy="most_frequent")),
        ("encoder", OneHotEncoder(handle_unknown="ignore"))
    ]), categorical_columns)
])
```

**📦 Puente al Portafolio**: `CarVision-Market-Intelligence/src/carvision/features.py`

**📝 Tarea**: Crear `OutlierClipper` y `FeatureEngineer` como transformers custom

---

### �️ MES 3: ML ENGINEERING (Semanas 9-12)

> **Objetivo**: Dominar entrenamiento profesional y tracking de experimentos.

---

#### 📖 Semana 9: Ingeniería de Features

**🎯 Objetivo**: Crear features robustos sin data leakage.

##### � Teoría Fundamental

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Feature Engineering** | Preparar ingredientes antes de cocinar | Features buenos = modelo bueno |
| **Target Encoding** | Reemplazar categoría por promedio del target | Poderoso pero peligroso (leakage) |
| **FeatureEngineer class** | Chef que sabe todas las recetas | Centraliza lógica, evita duplicación |

##### 💻 Práctica Empírica

```bash
cat > src/bankchurn/features.py << 'EOF'
from sklearn.base import BaseEstimator, TransformerMixin
import pandas as pd

class FeatureEngineer(BaseEstimator, TransformerMixin):
    """Crea features derivados para predicción de churn."""
    
    def fit(self, X: pd.DataFrame, y=None):
        return self
    
    def transform(self, X: pd.DataFrame) -> pd.DataFrame:
        X = X.copy()
        # Feature: Ratio balance/salario
        if "Balance" in X.columns and "EstimatedSalary" in X.columns:
            X["BalanceToSalary"] = X["Balance"] / (X["EstimatedSalary"] + 1)
        # Feature: Es cliente nuevo
        if "Tenure" in X.columns:
            X["IsNewCustomer"] = (X["Tenure"] < 2).astype(int)
        return X
EOF
```

**📦 Ubicación en Portafolio**: `CarVision-Market-Intelligence/src/carvision/features.py`

---

#### 📖 Semana 10: Training Profesional + Cross-Validation

**🎯 Objetivo**: Entrenar modelos con validación robusta.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Cross-Validation** | Varios exámenes de práctica, no solo uno | Estimación más confiable |
| **Stratified K-Fold** | Cada examen tiene proporción similar | Clases desbalanceadas bien representadas |
| **Trainer class** | Entrenador personal con programa estructurado | Código organizado, métricas consistentes |

##### 💻 Práctica Empírica

```bash
cat > src/bankchurn/trainer.py << 'EOF'
from sklearn.model_selection import cross_val_score, StratifiedKFold
from dataclasses import dataclass
import numpy as np

@dataclass
class TrainingResult:
    cv_scores: list[float]
    mean_score: float
    std_score: float

class ChurnTrainer:
    def __init__(self, pipeline, n_splits: int = 5):
        self.pipeline = pipeline
        self.cv = StratifiedKFold(n_splits=n_splits, shuffle=True, random_state=42)
    
    def train_with_cv(self, X, y, scoring: str = "f1") -> TrainingResult:
        scores = cross_val_score(self.pipeline, X, y, cv=self.cv, scoring=scoring)
        self.pipeline.fit(X, y)
        return TrainingResult(
            cv_scores=scores.tolist(),
            mean_score=float(np.mean(scores)),
            std_score=float(np.std(scores))
        )
EOF
```

**📦 Ubicación en Portafolio**: `BankChurn-Predictor/src/bankchurn/trainer.py`

---

#### 📖 Semana 11: MLflow Tracking + UI

**🎯 Objetivo**: Registrar experimentos de forma sistemática.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **MLflow** | Cuaderno de laboratorio digital | Nunca pierdes un experimento |
| **Run** | Experimento individual | Cada entrenamiento queda registrado |
| **Artifact** | Archivos guardados (modelo, gráficas) | Reproducir resultados exactos |

##### 💻 Práctica Empírica

```bash
# 1. Instalar MLflow
pip install mlflow

# 2. Script de entrenamiento con tracking
cat > src/bankchurn/train_mlflow.py << 'EOF'
import mlflow
import mlflow.sklearn
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score

mlflow.set_experiment("bankchurn-classifier")

X, y = make_classification(n_samples=1000, n_features=20, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

with mlflow.start_run(run_name="rf-baseline"):
    params = {"n_estimators": 100, "max_depth": 10}
    mlflow.log_params(params)
    
    model = RandomForestClassifier(**params, random_state=42)
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    mlflow.log_metrics({"accuracy": accuracy_score(y_test, y_pred), "f1": f1_score(y_test, y_pred)})
    mlflow.sklearn.log_model(model, "model")
EOF

# 3. Ejecutar e iniciar UI
python src/bankchurn/train_mlflow.py
mlflow ui --port 5000
```

**📦 Ubicación en Portafolio**: `mlruns/` en cada proyecto

---

#### 📖 Semana 12: MLflow Model Registry + Signatures

**🎯 Objetivo**: Gestionar modelos en producción con versionado.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Model Registry** | Catálogo de productos con versiones | Sabes qué modelo está en producción |
| **Stages** | Estados: Staging → Production → Archived | Control de qué modelo usan usuarios |
| **Signature** | Contrato de entrada/salida | API sabe qué esperar del modelo |

##### 💻 Práctica Empírica

```bash
cat > src/bankchurn/train_registry.py << 'EOF'
import mlflow
from mlflow.models import infer_signature
from sklearn.ensemble import RandomForestClassifier
import pandas as pd

mlflow.set_experiment("bankchurn-classifier")

# Datos con nombres
feature_names = ["age", "balance", "tenure", "products", "salary"]
X = pd.DataFrame([[30, 1000, 2, 1, 50000]], columns=feature_names)

with mlflow.start_run():
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X, [0])
    
    signature = infer_signature(X, model.predict(X))
    mlflow.sklearn.log_model(
        model, "model",
        signature=signature,
        registered_model_name="BankChurnClassifier"
    )
EOF

python src/bankchurn/train_registry.py
```

**📦 Ubicación en Portafolio**: `models:/BankChurn/Production`

---

### 🗓️ MES 4: TESTING & CI/CD (Semanas 13-16)

> **Objetivo**: Implementar testing profesional y automatización.

#### 📖 Semana 13: Testing Unitario para ML

**🎯 Objetivo**: Escribir tests que validen componentes ML.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Unit Test** | Probar cada pieza antes de ensamblar | Detectas errores temprano |
| **pytest** | Robot que ejecuta todas las pruebas | Automatización, reportes claros |
| **Fixture** | Ingredientes pre-preparados para tests | Reutilizas setup, tests más limpios |

##### 💻 Práctica Empírica

```bash
# Crear estructura de tests
mkdir -p tests/unit

cat > tests/conftest.py << 'EOF'
import pytest
import pandas as pd
import numpy as np

@pytest.fixture
def sample_data():
    """Datos de ejemplo para tests."""
    return pd.DataFrame({
        "Balance": [1000, 2000, 0, 5000],
        "Tenure": [1, 5, 3, 10],
        "Age": [30, 45, 25, 60]
    })

@pytest.fixture
def sample_labels():
    return np.array([0, 1, 0, 1])
EOF

cat > tests/unit/test_pipeline.py << 'EOF'
from src.bankchurn.pipeline import create_pipeline

def test_pipeline_creation():
    pipe = create_pipeline()
    assert len(pipe.steps) == 3

def test_pipeline_fit_predict(sample_data, sample_labels):
    pipe = create_pipeline()
    pipe.fit(sample_data.values, sample_labels)
    predictions = pipe.predict(sample_data.values)
    assert len(predictions) == len(sample_labels)
EOF

# Ejecutar tests
pytest tests/ -v
```

**📦 Ubicación en Portafolio**: `tests/unit/`

---

#### 📖 Semana 14: Testing de Integración + Fixtures

**🎯 Objetivo**: Probar componentes trabajando juntos.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Integration Test** | Probar el carro completo, no solo el motor | Detectas problemas de conexión |
| **Mocking** | Usar dobles de prueba (actores) | Tests rápidos, sin dependencias externas |
| **conftest.py** | Recetario compartido de fixtures | Un lugar para todos los fixtures |

##### 💻 Práctica Empírica

```bash
cat > tests/integration/test_training_flow.py << 'EOF'
import pytest
from pathlib import Path
import tempfile

def test_full_training_flow(sample_data, sample_labels):
    """Test del flujo completo de entrenamiento."""
    from src.bankchurn.pipeline import create_pipeline
    from src.bankchurn.trainer import ChurnTrainer
    
    pipe = create_pipeline()
    trainer = ChurnTrainer(pipe, n_splits=2)
    
    result = trainer.train_with_cv(sample_data.values, sample_labels)
    
    assert result.mean_score >= 0.0
    assert result.mean_score <= 1.0
    assert len(result.cv_scores) == 2

def test_model_persistence(sample_data, sample_labels):
    """Test de guardado y carga de modelo."""
    import joblib
    from src.bankchurn.pipeline import create_pipeline
    
    pipe = create_pipeline()
    pipe.fit(sample_data.values, sample_labels)
    
    with tempfile.TemporaryDirectory() as tmpdir:
        model_path = Path(tmpdir) / "model.pkl"
        joblib.dump(pipe, model_path)
        
        loaded = joblib.load(model_path)
        assert loaded.predict(sample_data.values).shape == sample_labels.shape
EOF

pytest tests/integration/ -v
```

**📦 Ubicación en Portafolio**: `tests/integration/`

---

#### 📖 Semana 15: GitHub Actions + Matrix Testing

**🎯 Objetivo**: Automatizar tests en cada push.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **GitHub Actions** | Robot que trabaja por ti 24/7 | Tests automáticos en cada cambio |
| **Workflow** | Instrucciones para el robot | Define qué hacer y cuándo |
| **Matrix** | Probar en múltiples versiones | Compatibilidad garantizada |

##### 💻 Práctica Empírica

```bash
mkdir -p .github/workflows

cat > .github/workflows/ci.yml << 'EOF'
name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install dependencies
        run: |
          pip install -e ".[dev]"
      
      - name: Run linting
        run: |
          ruff check src/ tests/
      
      - name: Run tests with coverage
        run: |
          pytest tests/ -v --cov=src --cov-report=xml --cov-fail-under=80
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
EOF
```

**📦 Ubicación en Portafolio**: `.github/workflows/ci.yml`

---

#### 📖 Semana 16: Coverage Gates + Security Scanning

**🎯 Objetivo**: Garantizar calidad y seguridad automáticamente.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Coverage Gate** | Mínimo de cobertura para aprobar | Garantiza tests suficientes |
| **gitleaks** | Detector de secretos filtrados | Evita exponer passwords/API keys |
| **Dependabot** | Robot que actualiza dependencias | Parches de seguridad automáticos |

##### 💻 Práctica Empírica

```bash
# Añadir security scanning al workflow
cat >> .github/workflows/ci.yml << 'EOF'

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Check dependencies
        run: |
          pip install safety
          safety check
EOF

# Crear configuración de gitleaks
cat > .gitleaks.toml << 'EOF'
[allowlist]
description = "Allowlist for secrets"
paths = [
    '''tests/.*''',
    '''docs/.*''',
]
EOF

# Verificar coverage localmente
pytest --cov=src --cov-fail-under=80
```

**📦 Ubicación en Portafolio**: `.github/workflows/security.yml`

---

### 🗓️ MES 5: DEPLOYMENT (Semanas 17-20)

> **Objetivo**: Desplegar modelos como APIs profesionales.

#### 📖 Semana 17: Docker Fundamentos + Multi-stage

**🎯 Objetivo**: Containerizar aplicaciones ML.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Docker** | Caja de mudanza que incluye todo | Funciona igual en cualquier máquina |
| **Image** | Foto/snapshot de tu aplicación | Versión inmutable para desplegar |
| **Multi-stage** | Cocinar y servir en platos diferentes | Imagen final pequeña y segura |

##### 💻 Práctica Empírica

```bash
cat > Dockerfile << 'EOF'
# Stage 1: Builder
FROM python:3.11-slim as builder
WORKDIR /app
COPY pyproject.toml .
RUN pip install build && python -m build --wheel

# Stage 2: Runtime
FROM python:3.11-slim as runtime
WORKDIR /app

# Crear usuario no-root
RUN useradd --create-home appuser
USER appuser

# Instalar dependencias
COPY --from=builder /app/dist/*.whl .
RUN pip install --user *.whl

# Copiar código
COPY --chown=appuser:appuser app/ ./app/
COPY --chown=appuser:appuser models/ ./models/

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Construir y ejecutar
docker build -t bankchurn:latest .
docker run -p 8000:8000 bankchurn:latest
```

**📦 Ubicación en Portafolio**: `Dockerfile`

---

#### 📖 Semana 18: FastAPI para ML + Schemas Pydantic

**🎯 Objetivo**: Crear APIs de predicción robustas.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **FastAPI** | Recepcionista que valida y dirige peticiones | Rápido, documentación automática |
| **Schema** | Formulario con campos requeridos | Valida entrada/salida automáticamente |
| **/health** | Chequeo médico de la API | Saber si el servicio está vivo |

##### 💻 Práctica Empírica

```bash
cat > app/fastapi_app.py << 'EOF'
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import joblib
from pathlib import Path

app = FastAPI(title="BankChurn API", version="1.0.0")

# Schemas
class PredictionRequest(BaseModel):
    age: int = Field(..., ge=18, le=100)
    balance: float = Field(..., ge=0)
    tenure: int = Field(..., ge=0)
    num_products: int = Field(..., ge=1, le=4)
    
class PredictionResponse(BaseModel):
    prediction: int
    probability: float
    model_version: str

# Cargar modelo
MODEL_PATH = Path("models/model.pkl")
model = joblib.load(MODEL_PATH) if MODEL_PATH.exists() else None

@app.get("/health")
def health_check():
    return {"status": "healthy", "model_loaded": model is not None}

@app.post("/predict", response_model=PredictionResponse)
def predict(request: PredictionRequest):
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    
    features = [[request.age, request.balance, request.tenure, request.num_products]]
    prediction = int(model.predict(features)[0])
    probability = float(model.predict_proba(features)[0][prediction])
    
    return PredictionResponse(
        prediction=prediction,
        probability=probability,
        model_version="1.0.0"
    )
EOF

# Ejecutar
pip install fastapi uvicorn
uvicorn app.fastapi_app:app --reload --port 8000

# Probar
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"age": 35, "balance": 50000, "tenure": 5, "num_products": 2}'
```

**📦 Ubicación en Portafolio**: `app/fastapi_app.py`

---

#### 📖 Semana 19: Streamlit Dashboards + Caching

**🎯 Objetivo**: Crear dashboards interactivos.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Streamlit** | PowerPoint interactivo con Python | Demos rápidos sin JavaScript |
| **st.cache** | Memoria para no repetir cálculos | App más rápida |
| **Tabs** | Pestañas de navegador | Organiza contenido |

##### 💻 Práctica Empírica

```bash
cat > app/streamlit_app.py << 'EOF'
import streamlit as st
import requests
import pandas as pd

st.set_page_config(page_title="BankChurn Predictor", page_icon="🏦")

st.title("🏦 BankChurn Predictor")

# Tabs
tab1, tab2 = st.tabs(["Predicción", "Información"])

with tab1:
    st.header("Predecir Churn de Cliente")
    
    col1, col2 = st.columns(2)
    with col1:
        age = st.slider("Edad", 18, 100, 35)
        balance = st.number_input("Balance", 0, 500000, 50000)
    with col2:
        tenure = st.slider("Años como cliente", 0, 20, 5)
        num_products = st.selectbox("Productos", [1, 2, 3, 4])
    
    if st.button("Predecir", type="primary"):
        try:
            response = requests.post(
                "http://localhost:8000/predict",
                json={"age": age, "balance": balance, "tenure": tenure, "num_products": num_products}
            )
            result = response.json()
            
            if result["prediction"] == 1:
                st.error(f"⚠️ Alto riesgo de churn ({result['probability']:.1%})")
            else:
                st.success(f"✅ Cliente estable ({1-result['probability']:.1%})")
        except:
            st.error("Error conectando con la API")

with tab2:
    st.header("Sobre el Modelo")
    st.markdown("""
    - **Algoritmo**: Random Forest
    - **Accuracy**: 85%
    - **Features**: Age, Balance, Tenure, Products
    """)
EOF

# Ejecutar
pip install streamlit
streamlit run app/streamlit_app.py
```

**📦 Ubicación en Portafolio**: `app/streamlit_app.py`

---

#### 📖 Semana 20: Observabilidad + Logging Estructurado

**🎯 Objetivo**: Monitorear aplicaciones en producción.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Logging estructurado** | Bitácora con formato fijo | Fácil de buscar y analizar |
| **Prometheus** | Termómetro de la aplicación | Métricas en tiempo real |
| **Drift detection** | Detector de cambios en datos | Modelo sigue siendo válido |

##### 💻 Práctica Empírica

```bash
pip install loguru prometheus-client

cat > src/bankchurn/logging.py << 'EOF'
from loguru import logger
import sys

def setup_logging(json_format: bool = True):
    """Configura logging estructurado."""
    logger.remove()
    
    if json_format:
        logger.add(
            sys.stdout,
            format="{time:YYYY-MM-DD HH:mm:ss} | {level} | {message}",
            serialize=True  # JSON format
        )
    else:
        logger.add(sys.stdout, colorize=True)
    
    return logger
EOF

cat > app/metrics.py << 'EOF'
from prometheus_client import Counter, Histogram, generate_latest
from fastapi import Response

# Métricas
PREDICTIONS = Counter("predictions_total", "Total predictions", ["result"])
LATENCY = Histogram("prediction_latency_seconds", "Prediction latency")

def get_metrics():
    return Response(generate_latest(), media_type="text/plain")
EOF

# Añadir a FastAPI
# from app.metrics import PREDICTIONS, LATENCY, get_metrics
# app.get("/metrics")(get_metrics)
```

**📦 Ubicación en Portafolio**: `src/*/logging.py`

---

### 🗓️ MES 6: PRODUCCIÓN & MAESTRÍA (Semanas 21-24)

> **Objetivo**: Completar el portafolio y preparar entrevistas.

#### 📖 Semana 21: Estrategias de Despliegue + Cloud

**🎯 Objetivo**: Entender opciones de deployment.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Blue-Green** | Cambiar de carril sin frenar | Zero downtime en updates |
| **Canary** | Probar comida antes de servir | Detectar problemas con pocos usuarios |
| **Serverless** | Taxi vs auto propio | Pagas solo lo que usas |

##### 💻 Práctica Empírica

```bash
# docker-compose para desarrollo local
cat > docker-compose.yml << 'EOF'
version: "3.8"
services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - MODEL_PATH=/app/models/model.pkl
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
  
  streamlit:
    build:
      context: .
      dockerfile: Dockerfile.streamlit
    ports:
      - "8501:8501"
    depends_on:
      - api
EOF

docker-compose up -d
```

**📦 Ubicación en Portafolio**: `docker-compose.yml`, `k8s/`

---

#### 📖 Semana 22: Infraestructura como Código (Terraform)

**🎯 Objetivo**: Definir infraestructura de forma reproducible.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Terraform** | Plano de construcción ejecutable | Infraestructura versionada |
| **State** | Inventario de lo construido | Sabe qué existe vs qué falta |
| **Plan** | Presupuesto antes de construir | Ves cambios antes de aplicar |

##### 💻 Práctica Empírica

```bash
mkdir -p infra/terraform

cat > infra/terraform/main.tf << 'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "bankchurn"
}

# ECR Repository
resource "aws_ecr_repository" "app" {
  name = "${var.project_name}-api"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}
EOF

# Comandos Terraform
# terraform init
# terraform plan
# terraform apply
```

**📦 Ubicación en Portafolio**: `infra/terraform/`

---

#### 📖 Semana 23: Documentación Profesional + Model Cards

**🎯 Objetivo**: Documentar modelos para producción.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Model Card** | Ficha técnica de un electrodoméstico | Usuarios saben limitaciones |
| **Dataset Card** | Etiqueta nutricional de datos | Transparencia sobre fuente |
| **MkDocs** | Wiki profesional automática | Documentación navegable |

##### 💻 Práctica Empírica

```bash
cat > docs/MODEL_CARD.md << 'EOF'
# Model Card: BankChurn Classifier

## Model Details
- **Developer**: Tu Nombre
- **Model Date**: Diciembre 2024
- **Model Version**: 1.0.0
- **Model Type**: Random Forest Classifier

## Intended Use
- **Primary Use**: Predecir probabilidad de abandono de clientes bancarios
- **Users**: Equipo de retención de clientes
- **Out-of-scope**: No usar para decisiones de crédito

## Training Data
- **Source**: Dataset sintético de clientes bancarios
- **Size**: 10,000 registros
- **Features**: Age, Balance, Tenure, NumOfProducts

## Evaluation
| Metric | Value |
|--------|-------|
| Accuracy | 0.85 |
| F1-Score | 0.78 |
| AUC-ROC | 0.82 |

## Limitations
- Entrenado solo con datos de un banco
- No considera factores externos (economía, competencia)

## Ethical Considerations
- Evitar discriminación por edad
- Decisiones finales deben ser revisadas por humanos
EOF
```

**📦 Ubicación en Portafolio**: `docs/model_card.md`

---

#### 📖 Semana 24: Proyecto Integrador + Preparación Entrevistas

**🎯 Objetivo**: Validar portafolio completo y preparar presentación.

##### 🔰 Para Principiantes: Analogías

| Concepto | Analogía | Por qué importa |
|----------|----------|-----------------|
| **Rúbrica** | Lista de requisitos para aprobar | Sabes si estás listo |
| **Speech** | Elevator pitch de tu trabajo | Impresiona en 5 minutos |
| **Live Demo** | Mostrar el producto funcionando | Credibilidad instantánea |

##### 💻 Práctica Empírica

```bash
# Checklist final de validación
cat > CHECKLIST_FINAL.md << 'EOF'
# Checklist de Portafolio Completo

## BankChurn-Predictor
- [ ] `make test` pasa con 80%+ coverage
- [ ] `make serve` inicia API en localhost:8000
- [ ] `curl localhost:8000/health` retorna OK
- [ ] Dockerfile construye sin errores
- [ ] CI/CD pasa en GitHub Actions

## CarVision-Market-Intelligence  
- [ ] Pipeline de features funciona
- [ ] Dashboard Streamlit funciona
- [ ] Tests pasan

## TelecomAI-Customer-Intelligence
- [ ] Multiclass classification funciona
- [ ] MLflow tracking configurado
- [ ] Documentación completa

## Documentación
- [ ] Model Cards para cada proyecto
- [ ] README profesional en cada repo
- [ ] ADRs documentando decisiones

## Preparación Entrevistas
- [ ] Speech de 5-7 min practicado
- [ ] Demo de 3 min funciona
- [ ] Preguntas técnicas revisadas
EOF
```

**📦 Ubicación en Portafolio**: Portafolio completo

---

## 📋 Exámenes de Hito (6 Milestones)

Cada mes incluye un examen práctico que valida tu progreso. **Debes completar cada hito antes de avanzar al siguiente mes.**

---

### 🏆 HITO 1: Setup Completo (Fin Mes 1)

**Objetivo**: Demostrar que tienes un entorno de desarrollo profesional funcionando.

#### Criterios de Evaluación

| Criterio | Puntos | Cómo Validar |
|----------|:------:|--------------|
| Entorno virtual funcionando | 10 | `python --version` muestra 3.10+ |
| pyproject.toml válido | 15 | `pip install -e ".[dev]"` funciona |
| Pre-commit configurado | 15 | `pre-commit run --all-files` pasa |
| Estructura src/ correcta | 10 | Existe `src/bankchurn/__init__.py` |
| Makefile con comandos básicos | 10 | `make lint` funciona |
| Git con commits convencionales | 10 | `git log --oneline` muestra formato correcto |
| Código tipado con mypy | 15 | `mypy src/ --strict` sin errores |
| README.md profesional | 15 | Incluye instalación, uso, estructura |

**Puntuación mínima**: 70/100

#### Comandos de Validación

```bash
# Ejecutar todos los checks del Hito 1
make lint                          # Linting pasa
mypy src/ --strict                 # Sin errores de tipos
pre-commit run --all-files         # Hooks pasan
pip install -e ".[dev]"            # Instalación funciona
```

---

### 🏆 HITO 2: Pipeline Reproducible (Fin Mes 2)

**Objetivo**: Demostrar pipelines de datos y ML reproducibles.

#### Criterios de Evaluación

| Criterio | Puntos | Cómo Validar |
|----------|:------:|--------------|
| DVC inicializado | 15 | Existe `.dvc/config` |
| Datos versionados | 15 | Existe `data/*.dvc` |
| Pipeline DVC funcional | 20 | `dvc repro` ejecuta sin errores |
| sklearn Pipeline creado | 20 | `create_pipeline()` retorna Pipeline |
| Custom Transformer | 15 | Clase hereda de BaseEstimator |
| Sin data leakage | 15 | fit solo en train, transform en test |

**Puntuación mínima**: 70/100

#### Comandos de Validación

```bash
# Ejecutar todos los checks del Hito 2
dvc status                         # Sin cambios pendientes
dvc repro                          # Pipeline ejecuta completamente
python -c "from src.bankchurn.pipeline import create_pipeline; print(create_pipeline())"
dvc dag                            # Muestra DAG del pipeline
```

---

### 🏆 HITO 3: Experimento Completo (Fin Mes 3)

**Objetivo**: Demostrar tracking de experimentos y model registry.

#### Criterios de Evaluación

| Criterio | Puntos | Cómo Validar |
|----------|:------:|--------------|
| MLflow experiment creado | 15 | `mlflow experiments list` muestra experimento |
| Métricas logueadas | 20 | accuracy, f1, precision en MLflow UI |
| Modelo registrado | 20 | Modelo en Model Registry |
| Signature definida | 15 | Modelo tiene input/output signature |
| Cross-validation implementada | 15 | Trainer usa StratifiedKFold |
| FeatureEngineer funcional | 15 | Crea features sin leakage |

**Puntuación mínima**: 70/100

#### Comandos de Validación

```bash
# Ejecutar todos los checks del Hito 3
mlflow experiments list            # Experimento existe
mlflow runs list --experiment-id 1 # Runs existen
python src/bankchurn/train_mlflow.py  # Entrenamiento completo
mlflow ui                          # UI muestra métricas
```

---

### 🏆 HITO 4: CI/CD Completo (Fin Mes 4)

**Objetivo**: Demostrar testing y automatización profesional.

#### Criterios de Evaluación

| Criterio | Puntos | Cómo Validar |
|----------|:------:|--------------|
| Tests unitarios | 20 | `pytest tests/unit/` pasa |
| Tests integración | 15 | `pytest tests/integration/` pasa |
| Coverage ≥ 80% | 20 | `pytest --cov --cov-fail-under=80` |
| GitHub Actions workflow | 20 | `.github/workflows/ci.yml` existe |
| Matrix testing (3.10, 3.11, 3.12) | 10 | CI corre en múltiples versiones |
| Security scanning | 15 | gitleaks configurado |

**Puntuación mínima**: 70/100

#### Comandos de Validación

```bash
# Ejecutar todos los checks del Hito 4
pytest tests/ -v --cov=src --cov-report=term-missing --cov-fail-under=80
cat .github/workflows/ci.yml       # Workflow existe
pre-commit run gitleaks --all-files  # Sin secretos expuestos
```

---

### 🏆 HITO 5: API Desplegada (Fin Mes 5)

**Objetivo**: Demostrar deployment de modelo como servicio.

#### Criterios de Evaluación

| Criterio | Puntos | Cómo Validar |
|----------|:------:|--------------|
| Dockerfile multi-stage | 15 | Imagen < 500MB |
| FastAPI /predict funcional | 20 | curl retorna predicción |
| FastAPI /health funcional | 10 | curl retorna status |
| Schemas Pydantic validados | 15 | Request inválido retorna 422 |
| Streamlit dashboard | 15 | streamlit run funciona |
| Logging estructurado | 10 | Logs en formato JSON |
| Métricas Prometheus | 15 | /metrics endpoint existe |

**Puntuación mínima**: 70/100

#### Comandos de Validación

```bash
# Ejecutar todos los checks del Hito 5
docker build -t bankchurn:latest .
docker run -d -p 8000:8000 bankchurn:latest
sleep 5
curl http://localhost:8000/health
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"age": 35, "balance": 50000, "tenure": 5, "num_products": 2}'
curl http://localhost:8000/metrics
```

---

### 🏆 HITO 6: Portafolio Completo (Fin Mes 6)

**Objetivo**: Demostrar portafolio production-ready listo para entrevistas.

#### Criterios de Evaluación

| Criterio | Puntos | Cómo Validar |
|----------|:------:|--------------|
| 3 proyectos funcionando | 20 | make test pasa en los 3 |
| Model Cards completos | 15 | docs/MODEL_CARD.md en cada proyecto |
| CI/CD pasando en GitHub | 15 | Badge verde en README |
| docker-compose funcional | 10 | `docker-compose up` levanta todo |
| IaC documentado | 10 | infra/terraform/ con README |
| Speech de 5-7 min preparado | 15 | Grabación de práctica |
| Demo de 3 min funciona | 15 | Video o live demo |

**Puntuación mínima**: 70/100

#### Comandos de Validación

```bash
# Validación final completa
for project in BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence; do
  echo "=== Testing $project ==="
  cd $project && make test && cd ..
done

# Verificar documentación
ls */docs/MODEL_CARD.md

# Levantar stack completo
docker-compose up -d
curl http://localhost:8000/health
curl http://localhost:8501
```

---

## 🔧 Guía de Troubleshooting

Errores comunes al configurar el entorno local por sistema operativo.

---

### 🪟 Windows

#### Error: `pip install` falla con permisos

```powershell
# Síntoma
ERROR: Could not install packages due to an EnvironmentError: [WinError 5] Access is denied

# Solución 1: Usar --user
pip install --user -r requirements.txt

# Solución 2: Ejecutar PowerShell como Administrador
# Click derecho > "Ejecutar como administrador"

# Solución 3: Usar entorno virtual (recomendado)
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

#### Error: `python` no reconocido

```powershell
# Síntoma
'python' is not recognized as an internal or external command

# Solución: Añadir Python al PATH
# 1. Buscar "Variables de entorno" en Windows
# 2. Editar PATH del usuario
# 3. Añadir: C:\Users\TU_USUARIO\AppData\Local\Programs\Python\Python311\

# O reinstalar Python marcando "Add to PATH"
```

#### Error: `make` no encontrado

```powershell
# Síntoma
'make' is not recognized

# Solución 1: Instalar chocolatey y make
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install make

# Solución 2: Usar comandos directos sin make
pip install -e ".[dev]"   # en vez de make install
pytest tests/ -v          # en vez de make test
```

#### Error: Docker Desktop no inicia

```powershell
# Síntoma
Docker Desktop - WSL 2 installation is incomplete

# Solución
# 1. Abrir PowerShell como Admin
wsl --install
# 2. Reiniciar PC
# 3. Abrir Docker Desktop
```

---

### 🐧 Linux (Ubuntu/Debian)

#### Error: `python3.10` no disponible

```bash
# Síntoma
E: Unable to locate package python3.10

# Solución: Añadir deadsnakes PPA
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.10 python3.10-venv python3.10-dev
```

#### Error: `pip` no encontrado

```bash
# Síntoma
Command 'pip' not found

# Solución
sudo apt install python3-pip
# O usar pip3
pip3 install -r requirements.txt
```

#### Error: Permisos en Docker

```bash
# Síntoma
Got permission denied while trying to connect to the Docker daemon socket

# Solución: Añadir usuario al grupo docker
sudo usermod -aG docker $USER
newgrp docker
# O cerrar sesión y volver a entrar
```

#### Error: `libpq-dev` faltante (para psycopg2)

```bash
# Síntoma
Error: pg_config executable not found

# Solución
sudo apt install libpq-dev python3-dev
pip install psycopg2-binary  # versión sin compilar
```

---

### 🍎 macOS

#### Error: `Command Line Tools` faltantes

```bash
# Síntoma
xcrun: error: invalid active developer path

# Solución
xcode-select --install
```

#### Error: Conflicto con Python del sistema

```bash
# Síntoma
WARNING: pip is configured with locations that require TLS/SSL

# Solución: Usar pyenv
brew install pyenv
pyenv install 3.11.0
pyenv global 3.11.0
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

#### Error: `libomp` faltante (para scikit-learn)

```bash
# Síntoma
Library not loaded: /usr/local/opt/libomp/lib/libomp.dylib

# Solución
brew install libomp
```

#### Error: Docker muy lento en Mac M1/M2

```bash
# Síntoma
Docker builds extremadamente lentos

# Solución 1: Usar Rosetta
# En Docker Desktop > Settings > General > Use Rosetta

# Solución 2: Builds nativos ARM64
docker buildx build --platform linux/arm64 -t myapp .
```

---

### 🐍 Errores Comunes de Dependencias

#### Error: Conflicto de versiones numpy/pandas

```bash
# Síntoma
ImportError: numpy.core.multiarray failed to import

# Solución: Reinstalar en orden
pip uninstall numpy pandas scikit-learn -y
pip install numpy==1.24.0
pip install pandas==2.0.0
pip install scikit-learn==1.3.0
```

#### Error: MLflow no conecta

```bash
# Síntoma
ConnectionRefusedError: [Errno 111] Connection refused

# Solución: Verificar que MLflow server está corriendo
mlflow server --host 0.0.0.0 --port 5000 &
# O usar tracking local
export MLFLOW_TRACKING_URI=file:./mlruns
```

#### Error: DVC remote no configurado

```bash
# Síntoma
ERROR: failed to push data to remote - config file error

# Solución
dvc remote add -d myremote /path/to/storage
dvc remote modify myremote url s3://my-bucket/dvc
dvc push
```

#### Error: pytest no encuentra módulos

```bash
# Síntoma
ModuleNotFoundError: No module named 'src'

# Solución: Instalar en modo editable
pip install -e ".[dev]"

# O añadir al PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
```

---

## ⚡ Quick Start

```bash
# 1. Clonar el portafolio
git clone https://github.com/DuqueOM/ML-MLOps-Portfolio.git
cd ML-MLOps-Portfolio

# 2. Configurar entorno
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

# 3. Empezar con BankChurn (proyecto base)
cd BankChurn-Predictor
pip install -e ".[dev]"

# 4. Verificar instalación
make lint        # Verificar código
make test        # Ejecutar tests
make train       # Entrenar modelo
make serve       # Iniciar API

# 5. Probar API
curl http://localhost:8000/health
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"age": 35, "balance": 50000, "tenure": 5, "num_products": 2}'
```

---

## 📁 Estructura de Carpetas

```
Guia_MLOps/
├── README.md                    # 👈 Este archivo (índice maestro)
├── docs/
│   ├── 00_INDICE.md            # Índice original (8 semanas)
│   ├── 01_PYTHON_MODERNO.md    # Módulo: Python profesional
│   ├── 02_DISENO_SISTEMAS.md   # Módulo: Arquitectura ML
│   ├── 03_ESTRUCTURA_PROYECTO.md
│   ├── 04_ENTORNOS.md
│   ├── 05_GIT_PROFESIONAL.md
│   ├── 06_VERSIONADO_DATOS.md  # DVC
│   ├── 07_SKLEARN_PIPELINES.md
│   ├── 08_INGENIERIA_FEATURES.md
│   ├── 09_TRAINING_PROFESIONAL.md
│   ├── 10_EXPERIMENT_TRACKING.md  # MLflow
│   ├── 11_TESTING_ML.md
│   ├── 12_CI_CD.md             # GitHub Actions
│   ├── 13_DOCKER.md
│   ├── 14_FASTAPI.md
│   ├── 15_STREAMLIT.md
│   ├── 16_OBSERVABILIDAD.md
│   ├── 17_DESPLIEGUE.md
│   ├── 18_INFRAESTRUCTURA.md   # Terraform
│   ├── 19_DOCUMENTACION.md     # Model Cards
│   ├── 20_PROYECTO_INTEGRADOR.md
│   ├── 21_GLOSARIO.md
│   ├── 22_CHECKLIST.md
│   ├── 23_RECURSOS.md
│   ├── EJERCICIOS.md
│   ├── EJERCICIOS_SOLUCIONES.md
│   ├── SIMULACRO_ENTREVISTA_JUNIOR.md
│   ├── SIMULACRO_ENTREVISTA_MID.md
│   ├── SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md
│   ├── SIMULACRO_ENTREVISTA_SENIOR_PARTE2.md
│   └── study_tools/            # Herramientas de estudio
├── templates/
│   ├── Dockerfile
│   ├── Makefile
│   ├── ci.yml
│   ├── model_card_template.md
│   └── dataset_card_template.md
├── notebooks/                  # Notebooks de práctica
└── scripts/                    # Scripts auxiliares
```

---

## 📚 Recursos Complementarios

| Recurso | Descripción | Link |
|---------|-------------|------|
| **SYLLABUS.md** | Programa detallado macro-módulos | [docs/SYLLABUS.md](docs/SYLLABUS.md) |
| **PLAN_ESTUDIOS.md** | Cronograma día a día (8 semanas) | [docs/PLAN_ESTUDIOS.md](docs/PLAN_ESTUDIOS.md) |
| **EJERCICIOS.md** | Problemas prácticos | [docs/EJERCICIOS.md](docs/EJERCICIOS.md) |
| **GLOSARIO.md** | 100+ términos MLOps | [docs/21_GLOSARIO.md](docs/21_GLOSARIO.md) |
| **Speech Portafolio** | Guión 5-7 min | [docs/APENDICE_A_SPEECH_PORTAFOLIO.md](docs/APENDICE_A_SPEECH_PORTAFOLIO.md) |

---

## 🎯 Los 3 Proyectos del Portafolio

| Proyecto | Problema | Stack Principal | Coverage |
|----------|----------|-----------------|:--------:|
| **BankChurn-Predictor** | Clasificación binaria (churn) | RandomForest, FastAPI, Docker | 79%+ |
| **CarVision-Market-Intelligence** | Regresión (precios autos) | FeatureEngineer, Streamlit | 97% |
| **TelecomAI-Customer-Intelligence** | Clasificación multiclase | MLflow, LogisticRegression | 97% |

---

<div align="center">

## 🚀 ¡Empieza Ahora!

**Semana 1** → [Python Moderno](docs/01_PYTHON_MODERNO.md)

---

*Tiempo estimado: 24 semanas (6 meses) a ritmo moderado*

*Última actualización: Diciembre 2024*

**Autor**: Guía MLOps Portfolio Edition

</div>
