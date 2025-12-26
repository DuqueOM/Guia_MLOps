# 🚀 MLOps Guide — Portfolio Edition (24 Weeks)

> **From Zero to Senior/Staff MLOps in 6 Months**
> 
> Complete roadmap to build the [ML-MLOps-Portfolio](https://github.com/DuqueOM/ML-MLOps-Portfolio) from scratch.

---

## 📋 Table of Contents

1. [What Will You Achieve?](#what-will-you-achieve)
2. [Program Structure (24 Weeks)](#program-structure-24-weeks)
3. [Mapping Table: Concept → Tool → Portfolio](#mapping-table-concept--tool--portfolio)
4. [Visual Roadmap](#visual-roadmap)
5. [Monthly Content](#monthly-content)
6. [Milestone Exams (6 Milestones)](#milestone-exams-6-milestones)
7. [Troubleshooting Guide](#troubleshooting-guide)
8. [Quick Start](#quick-start)
9. [Folder Structure](#folder-structure)

---

## 🎯 What Will You Achieve?

Upon completing this 24-week guide, you will be able to:

| Skill | Level | Portfolio Evidence |
|-------|-------|-------------------|
| **Professional Python code** | Senior | Type hints, Pydantic, SOLID across all 3 projects |
| **Reproducible ML pipelines** | Senior | Unified sklearn Pipeline, no data leakage |
| **Data and model versioning** | Senior | DVC pipelines, MLflow Model Registry |
| **Testing & CI/CD** | Senior | 80%+ coverage, GitHub Actions, matrix testing |
| **Production APIs** | Senior | FastAPI with validation, Docker multi-stage |
| **Observability** | Staff | Prometheus, structured logging, drift detection |
| **Infrastructure as Code** | Staff | Terraform, Kubernetes manifests |
| **Pass technical interviews** | Staff | Complete mock interviews, 5-7 min speech |

---

## 📅 Program Structure (24 Weeks)

```
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                        LEARNING PATH (24 WEEKS / 6 MONTHS)                           ║
╠══════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                      ║
║  MONTH 1: FUNDAMENTALS (Weeks 1-4)                                                   ║
║  ═════════════════════════════════                                                   ║
║  [W1] Modern Python + Type Hints                                                     ║
║  [W2] System Design + Architecture                                                   ║
║  [W3] Project Structure + Environments                                               ║
║  [W4] Professional Git + Pre-commit                                                  ║
║       📋 MILESTONE EXAM 1: Complete Setup                                            ║
║                                                                                      ║
║  MONTH 2: DATA & VERSIONING (Weeks 5-8)                                              ║
║  ══════════════════════════════════════                                              ║
║  [W5] DVC Fundamentals + Remote Storage                                              ║
║  [W6] DVC Pipelines + Reproducibility                                                ║
║  [W7] Basic sklearn Pipelines                                                        ║
║  [W8] ColumnTransformer + Custom Transformers                                        ║
║       📋 MILESTONE EXAM 2: Reproducible Pipeline                                     ║
║                                                                                      ║
║  MONTH 3: ML ENGINEERING (Weeks 9-12)                                                ║
║  ═════════════════════════════════════                                               ║
║  [W9]  Feature Engineering                                                           ║
║  [W10] Professional Training + Cross-Validation                                      ║
║  [W11] MLflow Tracking + UI                                                          ║
║  [W12] MLflow Model Registry + Signatures                                            ║
║       📋 MILESTONE EXAM 3: Complete Experiment                                       ║
║                                                                                      ║
║  MONTH 4: TESTING & CI/CD (Weeks 13-16)                                              ║
║  ══════════════════════════════════════                                              ║
║  [W13] Unit Testing for ML                                                           ║
║  [W14] Integration Testing + Fixtures                                                ║
║  [W15] GitHub Actions + Matrix Testing                                               ║
║  [W16] Coverage Gates + Security Scanning                                            ║
║       📋 MILESTONE EXAM 4: Complete CI/CD                                            ║
║                                                                                      ║
║  MONTH 5: DEPLOYMENT (Weeks 17-20)                                                   ║
║  ══════════════════════════════════                                                  ║
║  [W17] Docker Fundamentals + Multi-stage                                             ║
║  [W18] FastAPI for ML + Pydantic Schemas                                             ║
║  [W19] Streamlit Dashboards + Caching                                                ║
║  [W20] Observability + Structured Logging                                            ║
║       📋 MILESTONE EXAM 5: Deployed API                                              ║
║                                                                                      ║
║  MONTH 6: PRODUCTION & MASTERY (Weeks 21-24)                                         ║
║  ════════════════════════════════════════════                                        ║
║  [W21] Deployment Strategies + Cloud                                                 ║
║  [W22] Infrastructure as Code (Terraform)                                            ║
║  [W23] Professional Documentation + Model Cards                                      ║
║  [W24] Capstone Project + Interview Preparation                                      ║
║       📋 MILESTONE EXAM 6: Complete Portfolio                                        ║
║                                                                                      ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
```

**Suggested dedication**: 8-10 hours/week (total ~200 hours)

---

## 🗺️ Mapping Table: Concept → Tool → Portfolio

This table connects each theoretical concept with the practical tool and its exact location in the portfolio:

| Week | Theoretical Concept | Tool | Portfolio Location | Guide Module |
|:------:|------------------|-------------|-------------------------|-------------|
| **W1** | Static typing | `mypy`, `Pydantic` | `*/src/*/config.py` | [01_PYTHON_MODERNO](docs/01_PYTHON_MODERNO.md) |
| **W2** | ML Architecture | ML Canvas, C4 Model | `docs/architecture/` | [02_DISENO_SISTEMAS](docs/02_DISENO_SISTEMAS.md) |
| **W3** | Code structure | `src/` layout | `BankChurn-Predictor/src/` | [03_ESTRUCTURA_PROYECTO](docs/03_ESTRUCTURA_PROYECTO.md) |
| **W4** | Code quality | `pre-commit`, `ruff` | `.pre-commit-config.yaml` | [05_GIT_PROFESIONAL](docs/05_GIT_PROFESIONAL.md) |
| **W5** | Data versioning | **DVC** | `.dvc/`, `data/*.dvc` | [06_VERSIONADO_DATOS](docs/06_VERSIONADO_DATOS.md) |
| **W6** | Data pipelines | **DVC pipelines** | `dvc.yaml`, `dvc.lock` | [06_VERSIONADO_DATOS](docs/06_VERSIONADO_DATOS.md) |
| **W7** | Preprocessing | `sklearn.Pipeline` | `*/src/*/pipeline.py` | [07_SKLEARN_PIPELINES](docs/07_SKLEARN_PIPELINES.md) |
| **W8** | Transformations | `ColumnTransformer` | `*/src/*/pipeline.py` | [07_SKLEARN_PIPELINES](docs/07_SKLEARN_PIPELINES.md) |
| **W9** | Feature Engineering | Custom Transformers | `*/src/*/features.py` | [08_INGENIERIA_FEATURES](docs/08_INGENIERIA_FEATURES.md) |
| **W10** | Training | `Trainer` class, CV | `*/src/*/trainer.py` | [09_TRAINING_PROFESIONAL](docs/09_TRAINING_PROFESIONAL.md) |
| **W11** | Experiment Tracking | **MLflow** | `mlruns/`, `mlflow.log_*` | [10_EXPERIMENT_TRACKING](docs/10_EXPERIMENT_TRACKING.md) |
| **W12** | Model Registry | **MLflow Registry** | `models:/model_name/` | [10_EXPERIMENT_TRACKING](docs/10_EXPERIMENT_TRACKING.md) |
| **W13** | Unit testing | **pytest** | `tests/unit/` | [11_TESTING_ML](docs/11_TESTING_ML.md) |
| **W14** | Integration testing | `pytest-fixtures` | `tests/integration/` | [11_TESTING_ML](docs/11_TESTING_ML.md) |
| **W15** | CI/CD | **GitHub Actions** | `.github/workflows/ci.yml` | [12_CI_CD](docs/12_CI_CD.md) |
| **W16** | Security | `gitleaks`, `safety` | `.github/workflows/security.yml` | [12_CI_CD](docs/12_CI_CD.md) |
| **W17** | Containerization | **Docker** | `Dockerfile`, `docker-compose.yml` | [13_DOCKER](docs/13_DOCKER.md) |
| **W18** | ML APIs | **FastAPI** | `app/fastapi_app.py` | [14_FASTAPI](docs/14_FASTAPI.md) |
| **W19** | Dashboards | **Streamlit** | `app/streamlit_app.py` | [15_STREAMLIT](docs/15_STREAMLIT.md) |
| **W20** | Observability | `loguru`, Prometheus | `*/src/*/logging.py` | [16_OBSERVABILIDAD](docs/16_OBSERVABILIDAD.md) |
| **W21** | Deploy strategies | Blue-green, Canary | `k8s/`, deployment configs | [17_DESPLIEGUE](docs/17_DESPLIEGUE.md) |
| **W22** | IaC | **Terraform** | `infra/terraform/` | [18_INFRAESTRUCTURA](docs/18_INFRAESTRUCTURA.md) |
| **W23** | Documentation | Model Cards, MkDocs | `docs/model_card.md` | [19_DOCUMENTACION](docs/19_DOCUMENTACION.md) |
| **W24** | Integration | Full stack | Complete portfolio | [20_PROYECTO_INTEGRADOR](docs/20_PROYECTO_INTEGRADOR.md) |

---

## 🔧 Complete Stack Tools

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              COMPLETE MLOps STACK                                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  DEVELOPMENT         │  ML/DATA             │  MLOps              │  PRODUCTION     │
│  ───────────         │  ───────             │  ─────              │  ──────────     │
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

## 📚 Monthly Content

---

### 🗓️ MONTH 1: PROFESSIONAL PYTHON FUNDAMENTALS (Weeks 1-4)

> **Objective**: Master Python at Staff Engineer level — the Portfolio code CANNOT be understood without this.

---

#### 📖 Week 1: Type Hints + Pydantic

**🎯 Objective**: Code with explicit contracts and validated configuration.

##### 📐 Fundamental Theory

| Concept | Definition | Impact on MLOps |
|---------|------------|------------------|
| **Static Typing** | Declare types at write time | mypy detects errors BEFORE execution |
| **Boundary Validation** | Verify data when ENTERING the system | Clear errors vs cryptic crashes |
| **Fail Fast** | Fail immediately with descriptive error | Bug cost: $1 (code) vs $1000 (production) |

##### 🔧 Engineering Practice

```python
# ═══════════════════════════════════════════════════════════════════════════
# THE PROBLEM: Junior code without types
# ═══════════════════════════════════════════════════════════════════════════
def train(data, config):  # What types? What does it return?
    pass  # Error appears 3 layers later

# ═══════════════════════════════════════════════════════════════════════════
# THE SOLUTION: Staff code with contracts
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
    """Clear contract: mypy verifies, Pydantic validates."""
    ...
```

##### 💻 Exact Commands

```bash
pip install pydantic mypy ruff
mypy src/bankchurn/training.py --strict  # 0 errors = ready
```

**📦 Portfolio Bridge**: `BankChurn-Predictor/src/bankchurn/config.py`

**📝 Task**: Type ALL public functions in `training.py`

---

#### 📖 Week 2: OOP for ML — Protocols and ABC

**🎯 Objective**: Write interchangeable and extensible code with professional OOP.

##### 📐 Fundamental Theory

| Concept | Definition | Portfolio Usage |
|---------|------------|------------------|
| **Protocol** | Duck typing verifiable by mypy | sklearn compatibility without inheritance |
| **ABC (Abstract Base Class)** | Contract that ENFORCES implementation | BaseTrainer for all 3 projects |
| **Polymorphism** | Same method, different implementations | `trainer.fit()` works identically in BankChurn, CarVision, TelecomAI |

##### 🔧 Engineering Practice

```python
# ═══════════════════════════════════════════════════════════════════════════
# THE PROBLEM: 3 trainers with different APIs
# ═══════════════════════════════════════════════════════════════════════════
class TrainerA:
    def entrenar(self, X, y): ...  # Spanish naming
class TrainerB:
    def fit_model(self, data): ...  # different signature

# ═══════════════════════════════════════════════════════════════════════════
# THE SOLUTION: ABC defines the contract
# ═══════════════════════════════════════════════════════════════════════════
from abc import ABC, abstractmethod
import pandas as pd

class BaseTrainer(ABC):
    """All portfolio trainers inherit from here."""
    
    @abstractmethod
    def fit(self, X: pd.DataFrame, y: pd.Series) -> "BaseTrainer":
        """Train model."""
        pass
    
    @abstractmethod
    def predict(self, X: pd.DataFrame) -> pd.Series:
        """Predict."""
        pass

# Protocol for sklearn (without inheritance):
from typing import Protocol, runtime_checkable

@runtime_checkable
class Predictor(Protocol):
    def fit(self, X, y): ...
    def predict(self, X): ...

# sklearn complies automatically:
from sklearn.ensemble import RandomForestClassifier
assert isinstance(RandomForestClassifier(), Predictor)  # True
```

**📦 Portfolio Bridge**: Create `common_utils/base.py` with `BaseTrainer`

**📝 Task**: Make `ChurnTrainer` inherit from `BaseTrainer`

---

#### 📖 Week 3: Production Pandas + Pandera

**🎯 Objective**: Validate DataFrames BEFORE they cause errors in the pipeline.

##### 📐 Fundamental Theory

| Concept | Definition | Why It's Critical |
|---------|------------|-------------------|
| **Schema** | Data structure contract | Defines which columns, types, and ranges are valid |
| **Pandera** | DataFrame validation with decorators | Clear error: "Age must be >= 18" vs sklearn crash |
| **Data Contract** | Agreement between data producer and consumer | The feature pipeline EXPECTS a certain structure |

##### 🔧 Engineering Practice

```python
# ═══════════════════════════════════════════════════════════════════════════
# THE PROBLEM: Junior code assumes correct DataFrame
# ═══════════════════════════════════════════════════════════════════════════
def train(df):
    X = df.drop("Exited", axis=1)  # What if "Exited" doesn't exist?
    y = df["Exited"]  # What if it has invalid values like 2 or -1?

# ═══════════════════════════════════════════════════════════════════════════
# THE SOLUTION: Pandera validates at the boundary
# ═══════════════════════════════════════════════════════════════════════════
import pandera as pa
from pandera.typing import DataFrame, Series

class BankChurnSchema(pa.DataFrameModel):
    CreditScore: Series[int] = pa.Field(ge=300, le=850)
    Age: Series[int] = pa.Field(ge=18, le=100)
    Balance: Series[float] = pa.Field(ge=0)
    Exited: Series[int] = pa.Field(isin=[0, 1])
    
    class Config:
        strict = True  # Does not allow extra columns

@pa.check_types
def train(df: DataFrame[BankChurnSchema]) -> Pipeline:
    """DataFrame GUARANTEED valid by Pandera."""
    X = df.drop("Exited", axis=1)
    y = df["Exited"]
    ...
```

##### 💻 Exact Commands

```bash
pip install pandera
# Create src/bankchurn/schemas.py with the schemas
pytest tests/test_schemas.py -v
```

**📦 Portfolio Bridge**: `BankChurn-Predictor/src/bankchurn/schemas.py`

**📝 Task**: Create `RawDataSchema` (permissive) and `ProcessedDataSchema` (strict)

---

#### 📖 Week 4: Project Structure + Professional Git

**🎯 Objective**: Organize code as an installable package with automated quality.

##### 📐 Fundamental Theory

| Concept | Definition | Benefit |
|---------|------------|----------|
| **src/ Layout** | Code in `src/package/` | Forces `pip install -e .` — avoids "works on my machine" |
| **pyproject.toml** | Standard project metadata | One file for deps, tools, builds |
| **Pre-commit** | Hooks that run before commit | GUARANTEED quality in every commit |

##### 🔧 Engineering Practice

```
BankChurn-Predictor/
├── src/bankchurn/          # Source code
│   ├── __init__.py         # Exports public API
│   ├── config.py           # Pydantic
│   ├── schemas.py          # Pandera  
│   ├── training.py         # Trainer
│   └── cli.py              # CLI
├── tests/                  # Tests (mirror of src/)
├── configs/config.yaml     # External config
├── pyproject.toml          # Metadata
├── Makefile                # Commands
└── .pre-commit-config.yaml # Hooks
```

##### 💻 Exact Commands

```bash
# Install in editable mode
pip install -e ".[dev]"

# Verify import works
python -c "from bankchurn import ChurnTrainer; print('OK')"

# Configure pre-commit
pip install pre-commit
pre-commit install
pre-commit run --all-files

# Conventional commit
git commit -m "feat(training): add type hints to ChurnTrainer"
```

**📦 Portfolio Bridge**: `BankChurn-Predictor/pyproject.toml`

**📝 Task**: `pip install -e ".[dev]"` + `pytest` + `mypy` pass without errors

---

### 🗓️ MONTH 2: DATA & PIPELINES (Weeks 5-8)

> **Objective**: Master data versioning, reproducible pipelines, and professional preprocessing.

---

#### 📖 Week 5: DVC — Data Versioning

**🎯 Objective**: Version data like you version code.

##### 📐 Fundamental Theory

| Concept | Definition | Why It's Critical |
|---------|------------|-------------------|
| **Reproducibility** | Get EXACTLY the same result | "Give me the data from 3 months ago" |
| **Data Lineage** | Track origin and transformations of data | Debugging and compliance |
| **Content-addressable** | Files identified by hash, not by name | Detects changes automatically |

##### 🔧 Engineering Practice

```python
# ═══════════════════════════════════════════════════════════════════════════
# THE PROBLEM: Data in folders with dates
# ═══════════════════════════════════════════════════════════════════════════
# data/
# ├── customers_v1.csv
# ├── customers_v2_final.csv
# ├── customers_v2_final_REAL.csv  # ← Which one is correct?
# ├── customers_backup_juan.csv

# ═══════════════════════════════════════════════════════════════════════════
# THE SOLUTION: DVC tracks by content
# ═══════════════════════════════════════════════════════════════════════════
# data/
# └── customers.csv.dvc  # ← Git tracks this (pointer)
# The actual file is in remote storage, identified by MD5 hash
```

##### 💻 Exact Commands

```bash
# Initialize DVC
dvc init
dvc add data/raw/bank_customers.csv

# View the created pointer
cat data/raw/bank_customers.csv.dvc
# outs:
#   - md5: d41d8cd98f00b204e9800998ecf8427e
#     path: bank_customers.csv

# Commit pointer (not data)
git add data/raw/bank_customers.csv.dvc data/raw/.gitignore
git commit -m "data: add raw customer data v1"

# Configure remote and push
dvc remote add -d storage s3://my-bucket/dvc
dvc push
```

📦 Portfolio Bridge: `BankChurn-Predictor/data/*.dvc`, `.dvc/config`

📝 Task: `dvc pull` in a new folder should bring exactly the same data

---

#### 📖 Week 6: DVC Pipelines + Reproducibility

🎯 Objective: Create reproducible data pipelines with DAGs.

##### 📐 Fundamental Theory

| Concept | Definition | Why It's Critical |
|---------|------------|-------------------|
| **DAG** | Directed Acyclic Graph — ordered steps without cycles | Only re-executes what changed |
| **Determinism** | Same input → same output always | Scientific reproducibility |
| **Idempotence** | Execute N times = execute 1 time | Safe to retry |

##### 🔧 Engineering Practice

```yaml
# dvc.yaml — Defines the complete pipeline
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

##### 💻 Exact Commands

```bash
dvc repro           # Execute complete pipeline
dvc dag             # Visualize the DAG
dvc metrics show    # Show metrics
dvc metrics diff    # Compare between versions
```

📦 Portfolio Bridge: `BankChurn-Predictor/dvc.yaml`, `dvc.lock`

📝 Task: `dvc repro` executes without errors and generates `metrics.json`

---

#### 📖 Week 7: sklearn Pipelines — No Data Leakage

🎯 Objective: Create ML pipelines that prevent data leakage.

##### 📐 Fundamental Theory

| Concept | Definition | Why It's Critical |
|---------|------------|-------------------|
| **Data Leakage** | Test information contaminates training | Model looks good but fails in production |
| **fit vs transform** | fit learns statistics, transform applies them | fit ONLY on train, transform on train AND test |
| **Pipeline** | Chain of transformations as an object | Encapsulates preprocessing + model |

##### 🔧 Engineering Practice

```python
# ═══════════════════════════════════════════════════════════════════════════
# THE PROBLEM: Data Leakage (beginner mistake)
# ═══════════════════════════════════════════════════════════════════════════
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # ❌ fit on ALL X (includes test)
X_train, X_test = train_test_split(X_scaled)  # Leakage!

# ═══════════════════════════════════════════════════════════════════════════
# THE SOLUTION: Pipeline encapsulates everything
# ═══════════════════════════════════════════════════════════════════════════
from sklearn.pipeline import Pipeline

pipeline = Pipeline([
    ("imputer", SimpleImputer(strategy="median")),
    ("scaler", StandardScaler()),
    ("classifier", RandomForestClassifier())
])

# Split BEFORE any fit
X_train, X_test, y_train, y_test = train_test_split(X, y)

# fit_transform ONLY on train
pipeline.fit(X_train, y_train)  # ✅ Learns from train

# transform implicit in predict (uses train statistics)
predictions = pipeline.predict(X_test)  # ✅ No leakage
```

📦 Portfolio Bridge: `BankChurn-Predictor/src/bankchurn/pipeline.py`

📝 Task: Create `create_pipeline()` that returns complete Pipeline

---

#### 📖 Week 8: ColumnTransformer + Custom Transformers

🎯 Objective: Process different column types with custom transformers.

##### 📐 Fundamental Theory

| Concept | Definition | Why It's Critical |
|---------|------------|-------------------|
| **ColumnTransformer** | Applies different transformations per column group | Numerical: scale, Categorical: one-hot |
| **BaseEstimator + TransformerMixin** | Base classes for sklearn-compatible transformers | Your transformer works in Pipeline |
| **fit/transform API** | Standard sklearn contract | Guaranteed interoperability |

##### 🔧 Engineering Practice

```python
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.compose import ColumnTransformer
import numpy as np

class OutlierClipper(BaseEstimator, TransformerMixin):
    """Custom transformer that clips outliers using IQR."""
    
    def __init__(self, factor: float = 1.5):
        self.factor = factor
    
    def fit(self, X, y=None):
        Q1, Q3 = np.percentile(X, [25, 75], axis=0)
        IQR = Q3 - Q1
        self.lower_ = Q1 - self.factor * IQR
        self.upper_ = Q3 + self.factor * IQR
        return self  # ← Always returns self
    
    def transform(self, X):
        return np.clip(X, self.lower_, self.upper_)

# Usage in ColumnTransformer:
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

📦 Portfolio Bridge: `CarVision-Market-Intelligence/src/carvision/features.py`

📝 Task: Create `OutlierClipper` and `FeatureEngineer` as custom transformers

---

### 🗓️ MONTH 3: ML ENGINEERING (Weeks 9-12)

> **Objective**: Master professional training and experiment tracking.

---

#### 📖 Week 9: Feature Engineering

🎯 Objective: Create robust features without data leakage.

##### 📐 Fundamental Theory

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Feature Engineering** | Preparing ingredients before cooking | Good features = good model |
| **Target Encoding** | Replace category with target average | Powerful but dangerous (leakage) |
| **FeatureEngineer class** | Chef who knows all the recipes | Centralizes logic, avoids duplication |

##### 💻 Empirical Practice

```bash
cat > src/bankchurn/features.py << 'EOF'
from sklearn.base import BaseEstimator, TransformerMixin
import pandas as pd

class FeatureEngineer(BaseEstimator, TransformerMixin):
    """Creates derived features for churn prediction."""
    
    def fit(self, X: pd.DataFrame, y=None):
        return self
    
    def transform(self, X: pd.DataFrame) -> pd.DataFrame:
        X = X.copy()
        # Feature: Balance/salary ratio
        if "Balance" in X.columns and "EstimatedSalary" in X.columns:
            X["BalanceToSalary"] = X["Balance"] / (X["EstimatedSalary"] + 1)
        # Feature: Is new customer
        if "Tenure" in X.columns:
            X["IsNewCustomer"] = (X["Tenure"] < 2).astype(int)
        return X
EOF
```

**📦 Portfolio Location**: `CarVision-Market-Intelligence/src/carvision/features.py`

---

#### 📖 Week 10: Professional Training + Cross-Validation

**🎯 Objective**: Train models with robust validation.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Cross-Validation** | Multiple practice exams, not just one | More reliable estimation |
| **Stratified K-Fold** | Each exam has similar proportion | Imbalanced classes well represented |
| **Trainer class** | Personal trainer with structured program | Organized code, consistent metrics |

##### 💻 Empirical Practice

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

**📦 Portfolio Location**: `BankChurn-Predictor/src/bankchurn/trainer.py`

---

#### 📖 Week 11: MLflow Tracking + UI

**🎯 Objective**: Record experiments systematically.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **MLflow** | Digital lab notebook | Never lose an experiment |
| **Run** | Individual experiment | Each training is recorded |
| **Artifact** | Saved files (model, plots) | Reproduce exact results |

##### 💻 Empirical Practice

```bash
# 1. Install MLflow
pip install mlflow

# 2. Training script with tracking
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

# 3. Execute and start UI
python src/bankchurn/train_mlflow.py
mlflow ui --port 5000
```

**📦 Portfolio Location**: `mlruns/` in each project

---

#### 📖 Week 12: MLflow Model Registry + Signatures

**🎯 Objective**: Manage models in production with versioning.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Model Registry** | Product catalog with versions | You know which model is in production |
| **Stages** | States: Staging → Production → Archived | Control which model users access |
| **Signature** | Input/output contract | API knows what to expect from model |

##### 💻 Empirical Practice

```bash
cat > src/bankchurn/train_registry.py << 'EOF'
import mlflow
from mlflow.models import infer_signature
from sklearn.ensemble import RandomForestClassifier
import pandas as pd

mlflow.set_experiment("bankchurn-classifier")

# Data with names
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

**📦 Portfolio Location**: `models:/BankChurn/Production`

---

### 🗓️ MONTH 4: TESTING & CI/CD (Weeks 13-16)

> **Objective**: Implement professional testing and automation.

#### 📖 Week 13: Unit Testing for ML

**🎯 Objective**: Write tests that validate ML components.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Unit Test** | Test each piece before assembling | Detect errors early |
| **pytest** | Robot that executes all tests | Automation, clear reports |
| **Fixture** | Pre-prepared ingredients for tests | Reuse setup, cleaner tests |

##### 💻 Empirical Practice

```bash
# Create test structure
mkdir -p tests/unit

cat > tests/conftest.py << 'EOF'
import pytest
import pandas as pd
import numpy as np

@pytest.fixture
def sample_data():
    """Sample data for tests."""
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

# Run tests
pytest tests/ -v
```

**📦 Portfolio Location**: `tests/unit/`

---

#### 📖 Week 14: Integration Testing + Fixtures

**🎯 Objective**: Test components working together.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Integration Test** | Test the whole car, not just the engine | Detect connection problems |
| **Mocking** | Use test doubles (actors) | Fast tests, no external dependencies |
| **conftest.py** | Shared fixture cookbook | One place for all fixtures |

##### 💻 Empirical Practice

```bash
cat > tests/integration/test_training_flow.py << 'EOF'
import pytest
from pathlib import Path
import tempfile

def test_full_training_flow(sample_data, sample_labels):
    """Test the complete training flow."""
    from src.bankchurn.pipeline import create_pipeline
    from src.bankchurn.trainer import ChurnTrainer
    
    pipe = create_pipeline()
    trainer = ChurnTrainer(pipe, n_splits=2)
    
    result = trainer.train_with_cv(sample_data.values, sample_labels)
    
    assert result.mean_score >= 0.0
    assert result.mean_score <= 1.0
    assert len(result.cv_scores) == 2

def test_model_persistence(sample_data, sample_labels):
    """Test model saving and loading."""
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

**📦 Portfolio Location**: `tests/integration/`

---

#### 📖 Week 15: GitHub Actions + Matrix Testing

**🎯 Objective**: Automate tests on every push.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **GitHub Actions** | Robot that works for you 24/7 | Automatic tests on every change |
| **Workflow** | Instructions for the robot | Defines what to do and when |
| **Matrix** | Test on multiple versions | Guaranteed compatibility |

##### 💻 Empirical Practice

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

**📦 Portfolio Location**: `.github/workflows/ci.yml`

---

#### 📖 Week 16: Coverage Gates + Security Scanning

**🎯 Objective**: Guarantee quality and security automatically.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Coverage Gate** | Minimum coverage to pass | Guarantees sufficient tests |
| **gitleaks** | Leaked secrets detector | Avoids exposing passwords/API keys |
| **Dependabot** | Robot that updates dependencies | Automatic security patches |

##### 💻 Empirical Practice

```bash
# Add security scanning to workflow
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

# Create gitleaks configuration
cat > .gitleaks.toml << 'EOF'
[allowlist]
description = "Allowlist for secrets"
paths = [
    '''tests/.*''',
    '''docs/.*''',
]
EOF

# Verify coverage locally
pytest --cov=src --cov-fail-under=80
```

**📦 Portfolio Location**: `.github/workflows/security.yml`

---

### 🗓️ MONTH 5: DEPLOYMENT (Weeks 17-20)

> **Objective**: Deploy models as professional APIs.

#### 📖 Week 17: Docker Fundamentals + Multi-stage

**🎯 Objective**: Containerize ML applications.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Docker** | Moving box that includes everything | Works the same on any machine |
| **Image** | Photo/snapshot of your application | Immutable version to deploy |
| **Multi-stage** | Cook and serve on different plates | Small and secure final image |

##### 💻 Empirical Practice

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

# Create non-root user
RUN useradd --create-home appuser
USER appuser

# Install dependencies
COPY --from=builder /app/dist/*.whl .
RUN pip install --user *.whl

# Copy code
COPY --chown=appuser:appuser app/ ./app/
COPY --chown=appuser:appuser models/ ./models/

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "app.fastapi_app:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Build and run
docker build -t bankchurn:latest .
docker run -p 8000:8000 bankchurn:latest
```

**📦 Portfolio Location**: `Dockerfile`

---

#### 📖 Week 18: FastAPI for ML + Pydantic Schemas

**🎯 Objective**: Create robust prediction APIs.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **FastAPI** | Receptionist that validates and routes requests | Fast, automatic documentation |
| **Schema** | Form with required fields | Validates input/output automatically |
| **/health** | API health check | Know if the service is alive |

##### 💻 Empirical Practice

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

# Load model
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

# Run
pip install fastapi uvicorn
uvicorn app.fastapi_app:app --reload --port 8000

# Test
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"age": 35, "balance": 50000, "tenure": 5, "num_products": 2}'
```

**📦 Portfolio Location**: `app/fastapi_app.py`

---

#### 📖 Week 19: Streamlit Dashboards + Caching

**🎯 Objective**: Create interactive dashboards.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Streamlit** | Interactive PowerPoint with Python | Quick demos without JavaScript |
| **st.cache** | Memory to avoid repeating calculations | Faster app |
| **Tabs** | Browser tabs | Organizes content |

##### 💻 Empirical Practice

```bash
cat > app/streamlit_app.py << 'EOF'
import streamlit as st
import requests
import pandas as pd

st.set_page_config(page_title="BankChurn Predictor", page_icon="🏦")

st.title("🏦 BankChurn Predictor")

# Tabs
tab1, tab2 = st.tabs(["Prediction", "Information"])

with tab1:
    st.header("Predict Customer Churn")
    
    col1, col2 = st.columns(2)
    with col1:
        age = st.slider("Age", 18, 100, 35)
        balance = st.number_input("Balance", 0, 500000, 50000)
    with col2:
        tenure = st.slider("Years as customer", 0, 20, 5)
        num_products = st.selectbox("Products", [1, 2, 3, 4])
    
    if st.button("Predict", type="primary"):
        try:
            response = requests.post(
                "http://localhost:8000/predict",
                json={"age": age, "balance": balance, "tenure": tenure, "num_products": num_products}
            )
            result = response.json()
            
            if result["prediction"] == 1:
                st.error(f"⚠️ High churn risk ({result['probability']:.1%})")
            else:
                st.success(f"✅ Stable customer ({1-result['probability']:.1%})")
        except:
            st.error("Error connecting to the API")

with tab2:
    st.header("About the Model")
    st.markdown("""
    - **Algorithm**: Random Forest
    - **Accuracy**: 85%
    - **Features**: Age, Balance, Tenure, Products
    """)
EOF

# Run
pip install streamlit
streamlit run app/streamlit_app.py
```

**📦 Portfolio Location**: `app/streamlit_app.py`

---

#### 📖 Week 20: Observability + Structured Logging

**🎯 Objective**: Monitor applications in production.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Structured logging** | Logbook with fixed format | Easy to search and analyze |
| **Prometheus** | Application thermometer | Real-time metrics |
| **Drift detection** | Data change detector | Model remains valid |

##### 💻 Empirical Practice

```bash
pip install loguru prometheus-client

cat > src/bankchurn/logging.py << 'EOF'
from loguru import logger
import sys

def setup_logging(json_format: bool = True):
    """Configure structured logging."""
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

# Metrics
PREDICTIONS = Counter("predictions_total", "Total predictions", ["result"])
LATENCY = Histogram("prediction_latency_seconds", "Prediction latency")

def get_metrics():
    return Response(generate_latest(), media_type="text/plain")
EOF

# Add to FastAPI
# from app.metrics import PREDICTIONS, LATENCY, get_metrics
# app.get("/metrics")(get_metrics)
```

**📦 Portfolio Location**: `src/*/logging.py`

---

### 🗓️ MONTH 6: PRODUCTION & MASTERY (Weeks 21-24)

> **Objective**: Complete the portfolio and prepare for interviews.

#### 📖 Week 21: Deployment Strategies + Cloud

**🎯 Objective**: Understand deployment options.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Blue-Green** | Change lanes without braking | Zero downtime on updates |
| **Canary** | Taste food before serving | Detect problems with few users |
| **Serverless** | Taxi vs own car | Pay only for what you use |

##### 💻 Empirical Practice

```bash
# docker-compose for local development
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

**📦 Portfolio Location**: `docker-compose.yml`, `k8s/`

---

#### 📖 Week 22: Infrastructure as Code (Terraform)

**🎯 Objective**: Define infrastructure reproducibly.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Terraform** | Executable construction blueprint | Versioned infrastructure |
| **State** | Inventory of what's built | Knows what exists vs what's missing |
| **Plan** | Budget before building | See changes before applying |

##### 💻 Empirical Practice

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

# Terraform commands
# terraform init
# terraform plan
# terraform apply
```

**📦 Portfolio Location**: `infra/terraform/`

---

#### 📖 Week 23: Professional Documentation + Model Cards

**🎯 Objective**: Document models for production.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Model Card** | Appliance technical specification | Users know limitations |
| **Dataset Card** | Nutritional label for data | Transparency about source |
| **MkDocs** | Automatic professional wiki | Navigable documentation |

##### 💻 Empirical Practice

```bash
cat > docs/MODEL_CARD.md << 'EOF'
# Model Card: BankChurn Classifier

## Model Details
- **Developer**: Your Name
- **Model Date**: December 2024
- **Model Version**: 1.0.0
- **Model Type**: Random Forest Classifier

## Intended Use
- **Primary Use**: Predict probability of bank customer churn
- **Users**: Customer retention team
- **Out-of-scope**: Do not use for credit decisions

## Training Data
- **Source**: Synthetic bank customer dataset
- **Size**: 10,000 records
- **Features**: Age, Balance, Tenure, NumOfProducts

## Evaluation
| Metric | Value |
|--------|-------|
| Accuracy | 0.85 |
| F1-Score | 0.78 |
| AUC-ROC | 0.82 |

## Limitations
- Trained only with data from one bank
- Does not consider external factors (economy, competition)

## Ethical Considerations
- Avoid age discrimination
- Final decisions must be reviewed by humans
EOF
```

**📦 Portfolio Location**: `docs/model_card.md`

---

#### 📖 Week 24: Capstone Project + Interview Preparation

**🎯 Objective**: Validate complete portfolio and prepare presentation.

##### 🔰 For Beginners: Analogies

| Concept | Analogy | Why It Matters |
|---------|---------|----------------|
| **Rubric** | List of requirements to pass | Know if you're ready |
| **Speech** | Elevator pitch of your work | Impress in 5 minutes |
| **Live Demo** | Show the product working | Instant credibility |

##### 💻 Empirical Practice

```bash
# Final validation checklist
cat > CHECKLIST_FINAL.md << 'EOF'
# Complete Portfolio Checklist

## BankChurn-Predictor
- [ ] `make test` passes with 80%+ coverage
- [ ] `make serve` starts API on localhost:8000
- [ ] `curl localhost:8000/health` returns OK
- [ ] Dockerfile builds without errors
- [ ] CI/CD passes on GitHub Actions

## CarVision-Market-Intelligence  
- [ ] Feature pipeline works
- [ ] Streamlit dashboard works
- [ ] Tests pass

## TelecomAI-Customer-Intelligence
- [ ] Multiclass classification works
- [ ] MLflow tracking configured
- [ ] Documentation complete

## Documentation
- [ ] Model Cards for each project
- [ ] Professional README in each repo
- [ ] ADRs documenting decisions

## Interview Preparation
- [ ] 5-7 min speech practiced
- [ ] 3 min demo works
- [ ] Technical questions reviewed
EOF
```

**📦 Portfolio Location**: Complete portfolio

---

## 📋 Milestone Exams (6 Milestones)

Each month includes a practical exam that validates your progress. **You must complete each milestone before advancing to the next month.**

---

### 🏆 MILESTONE 1: Complete Setup (End of Month 1)

**Objective**: Demonstrate that you have a working professional development environment.

#### Evaluation Criteria

| Criterion | Points | How to Validate |
| Virtual environment working | 10 | `python --version` shows 3.10+ |
| Valid pyproject.toml | 15 | `pip install -e ".[dev]"` works |
| Pre-commit configured | 15 | `pre-commit run --all-files` passes |
| Correct src/ structure | 10 | `src/bankchurn/__init__.py` exists |
| Makefile with basic commands | 10 | `make lint` works |
| Git with conventional commits | 10 | `git log --oneline` shows correct format |
| Code typed with mypy | 15 | `mypy src/ --strict` without errors |
| Professional README.md | 15 | Includes installation, usage, structure |

**Minimum score**: 70/100

#### Validation Commands

```bash
# Run all Milestone 1 checks
make lint                          # Linting passes
mypy src/ --strict                 # No type errors
pre-commit run --all-files         # Hooks pass
pip install -e ".[dev]"            # Installation works
```

---

### 🏆 MILESTONE 2: Reproducible Pipeline (End of Month 2)

**Objective**: Demonstrate reproducible data and ML pipelines.

#### Evaluation Criteria

| Criterion | Points | How to Validate |
| DVC initialized | 15 | `.dvc/config` exists |
| Versioned data | 15 | `data/*.dvc` exists |
| Functional DVC pipeline | 20 | `dvc repro` executes without errors |
| sklearn Pipeline created | 20 | `create_pipeline()` returns Pipeline |
| Custom Transformer | 15 | Class inherits from BaseEstimator |
| No data leakage | 15 | fit only on train, transform on test |

**Minimum score**: 70/100

#### Validation Commands

```bash
# Run all Milestone 2 checks
dvc status                         # No pending changes
dvc repro                          # Pipeline executes completely
python -c "from src.bankchurn.pipeline import create_pipeline; print(create_pipeline())"
dvc dag                            # Shows pipeline DAG
```

---

### 🏆 MILESTONE 3: Complete Experiment (End of Month 3)

**Objective**: Demonstrate experiment tracking and model registry.

#### Evaluation Criteria

| Criterion | Points | How to Validate |
| MLflow experiment created | 15 | `mlflow experiments list` shows experiment |
| Logged metrics | 20 | accuracy, f1, precision in MLflow UI |
| Registered model | 20 | Model in Model Registry |
| Defined signature | 15 | Model has input/output signature |
| Cross-validation implemented | 15 | Trainer uses StratifiedKFold |
| Functional FeatureEngineer | 15 | Creates features without leakage |

**Minimum score**: 70/100

#### Validation Commands

```bash
# Run all Milestone 3 checks
mlflow experiments list            # Experiment exists
mlflow runs list --experiment-id 1 # Runs exist
python src/bankchurn/train_mlflow.py  # Complete training
mlflow ui                          # UI shows metrics
```

---

### 🏆 MILESTONE 4: Complete CI/CD (End of Month 4)

**Objective**: Demonstrate professional testing and automation.

#### Evaluation Criteria

| Criterion | Points | How to Validate |
| Unit tests | 20 | `pytest tests/unit/` passes |
| Integration tests | 15 | `pytest tests/integration/` passes |
| Coverage ≥ 80% | 20 | `pytest --cov --cov-fail-under=80` |
| GitHub Actions workflow | 20 | `.github/workflows/ci.yml` exists |
| Matrix testing (3.10, 3.11, 3.12) | 10 | CI runs on multiple versions |
| Security scanning | 15 | gitleaks configured |

**Minimum score**: 70/100

#### Validation Commands

```bash
# Run all Milestone 4 checks
pytest tests/ -v --cov=src --cov-report=term-missing --cov-fail-under=80
cat .github/workflows/ci.yml       # Workflow exists
pre-commit run gitleaks --all-files  # No exposed secrets
```

---

### 🏆 MILESTONE 5: Deployed API (End of Month 5)

**Objective**: Demonstrate model deployment as a service.

#### Evaluation Criteria

| Criterion | Points | How to Validate |
| Multi-stage Dockerfile | 15 | Image < 500MB |
| Functional FastAPI /predict | 20 | curl returns prediction |
| Functional FastAPI /health | 10 | curl returns status |
| Validated Pydantic schemas | 15 | Invalid request returns 422 |
| Streamlit dashboard | 15 | streamlit run works |
| Structured logging | 10 | Logs in JSON format |
| Prometheus metrics | 15 | /metrics endpoint exists |

**Minimum score**: 70/100

#### Validation Commands

```bash
# Run all Milestone 5 checks
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

### 🏆 MILESTONE 6: Complete Portfolio (End of Month 6)

**Objective**: Demonstrate production-ready portfolio ready for interviews.

#### Evaluation Criteria

| Criterion | Points | How to Validate |
| 3 projects working | 20 | make test passes in all 3 |
| Complete Model Cards | 15 | docs/MODEL_CARD.md in each project |
| CI/CD passing on GitHub | 15 | Green badge in README |
| Functional docker-compose | 10 | `docker-compose up` starts everything |
| Documented IaC | 10 | infra/terraform/ with README |
| 5-7 min speech prepared | 15 | Practice recording |
| 3 min demo works | 15 | Video or live demo |

**Minimum score**: 70/100

#### Validation Commands

```bash
# Complete final validation
for project in BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence; do
  echo "=== Testing $project ==="
  cd $project && make test && cd ..
done

# Verify documentation
ls */docs/MODEL_CARD.md

# Start complete stack
docker-compose up -d
curl http://localhost:8000/health
curl http://localhost:8501
```

---

## 🔧 Troubleshooting Guide

Common errors when configuring the local environment by operating system.

---

### 🪟 Windows

#### Error: `pip install` fails with permissions

```powershell
# Symptom
ERROR: Could not install packages due to an EnvironmentError: [WinError 5] Access is denied

# Solution 1: Use --user
pip install --user -r requirements.txt

# Solution 2: Run PowerShell as Administrator
# Right-click > "Run as administrator"

# Solution 3: Use virtual environment (recommended)
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

#### Error: `python` not recognized

```powershell
# Symptom
'python' is not recognized as an internal or external command

# Solution: Add Python to PATH
# 1. Search "Environment Variables" in Windows
# 2. Edit user PATH
# 3. Add: C:\Users\YOUR_USER\AppData\Local\Programs\Python\Python311\

# Or reinstall Python checking "Add to PATH"
```

#### Error: `make` not found

```powershell
# Symptom
'make' is not recognized

# Solution 1: Install chocolatey and make
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install make

# Solution 2: Use direct commands without make
pip install -e ".[dev]"   # instead of make install
pytest tests/ -v          # instead of make test
```

#### Error: Docker Desktop doesn't start

```powershell
# Symptom
Docker Desktop - WSL 2 installation is incomplete

# Solution
# 1. Open PowerShell as Admin
wsl --install
# 2. Restart PC
# 3. Open Docker Desktop
```

---

### 🐧 Linux (Ubuntu/Debian)

#### Error: `python3.10` not available

```bash
# Symptom
E: Unable to locate package python3.10

# Solution: Add deadsnakes PPA
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.10 python3.10-venv python3.10-dev
```

#### Error: `pip` not found

```bash
# Symptom
Command 'pip' not found

# Solution
sudo apt install python3-pip
# Or use pip3
pip3 install -r requirements.txt
```

#### Error: Docker permissions

```bash
# Symptom
Got permission denied while trying to connect to the Docker daemon socket

# Solution: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
# Or log out and log back in
```

#### Error: `libpq-dev` missing (for psycopg2)

```bash
# Symptom
Error: pg_config executable not found

# Solution
sudo apt install libpq-dev python3-dev
pip install psycopg2-binary  # pre-compiled version
```

---

### 🍎 macOS

#### Error: `Command Line Tools` missing

```bash
# Symptom
xcrun: error: invalid active developer path

# Solution
xcode-select --install
```

#### Error: Conflict with system Python

```bash
# Symptom
WARNING: pip is configured with locations that require TLS/SSL

# Solution: Use pyenv
brew install pyenv
pyenv install 3.11.0
pyenv global 3.11.0
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

#### Error: `libomp` missing (for scikit-learn)

```bash
# Symptom
Library not loaded: /usr/local/opt/libomp/lib/libomp.dylib

# Solution
brew install libomp
```

#### Error: Docker very slow on Mac M1/M2

```bash
# Symptom
Extremely slow Docker builds

# Solution 1: Use Rosetta
# In Docker Desktop > Settings > General > Use Rosetta

# Solution 2: Native ARM64 builds
docker buildx build --platform linux/arm64 -t myapp .
```

---

### 🐍 Common Dependency Errors

#### Error: numpy/pandas version conflict

```bash
# Symptom
ImportError: numpy.core.multiarray failed to import

# Solution: Reinstall in order
pip uninstall numpy pandas scikit-learn -y
pip install numpy==1.24.0
pip install pandas==2.0.0
pip install scikit-learn==1.3.0
```

#### Error: MLflow doesn't connect

```bash
# Symptom
ConnectionRefusedError: [Errno 111] Connection refused

# Solution: Verify MLflow server is running
mlflow server --host 0.0.0.0 --port 5000 &
# Or use local tracking
export MLFLOW_TRACKING_URI=file:./mlruns
```

#### Error: DVC remote not configured

```bash
# Symptom
ERROR: failed to push data to remote - config file error

# Solution
dvc remote add -d myremote /path/to/storage
dvc remote modify myremote url s3://my-bucket/dvc
dvc push
```

#### Error: pytest can't find modules

```bash
# Symptom
ModuleNotFoundError: No module named 'src'

# Solution: Install in editable mode
pip install -e ".[dev]"

# Or add to PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:$(pwd)"
```

---

## ⚡ Quick Start

```bash
# 1. Clone the portfolio
git clone https://github.com/DuqueOM/ML-MLOps-Portfolio.git
cd ML-MLOps-Portfolio

# 2. Configure environment
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate   # Windows

# 3. Start with BankChurn (base project)
cd BankChurn-Predictor
pip install -e ".[dev]"

# 4. Verify installation
make lint        # Verify code
make test        # Run tests
make train       # Train model
make serve       # Start API

# 5. Test API
curl http://localhost:8000/health
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"age": 35, "balance": 50000, "tenure": 5, "num_products": 2}'
```

---

## 📁 Folder Structure

```
Guia_MLOps/
├── README.md                    # 👈 This file (master index)
├── docs/
│   ├── 00_INDICE.md            # Index (24-week path + 8-week accelerated path)
│   ├── 01_PYTHON_MODERNO.md    # Module: Professional Python
│   ├── 02_DISENO_SISTEMAS.md   # Module: ML Architecture
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
│   └── study_tools/            # Study tools
├── templates/
│   ├── Dockerfile
│   ├── Makefile
│   ├── ci.yml
│   ├── model_card_template.md
│   └── dataset_card_template.md
├── notebooks/                  # Practice notebooks
└── scripts/                    # Auxiliary scripts
```

---

## 📚 Supplementary Resources

| Resource | Description | Link |
|----------|-------------|------|
| **SYLLABUS.md** | Detailed macro-module program | [docs/SYLLABUS.md](docs/SYLLABUS.md) |
| **MAPA_PORTAFOLIO_1TO1.md** | 1:1 Map (Portfolio → Guide → Tasks/Evidence) | [docs/MAPA_PORTAFOLIO_1TO1.md](docs/MAPA_PORTAFOLIO_1TO1.md) |
| **PLAN_ESTUDIOS.md** | Day-by-day schedule (8-week accelerated path) | [docs/PLAN_ESTUDIOS.md](docs/PLAN_ESTUDIOS.md) |
| **EJERCICIOS.md** | Practical problems | [docs/EJERCICIOS.md](docs/EJERCICIOS.md) |
| **GLOSARIO.md** | 100+ MLOps terms | [docs/21_GLOSARIO.md](docs/21_GLOSARIO.md) |
| **Portfolio Speech** | 5-7 min script | [docs/APENDICE_A_SPEECH_PORTAFOLIO.md](docs/APENDICE_A_SPEECH_PORTAFOLIO.md) |

---

## 🎯 The 3 Portfolio Projects

| Project | Problem | Main Stack | Coverage |
|---------|---------|------------|:--------:|
| **BankChurn-Predictor** | Binary classification (churn) | RandomForest, FastAPI, Docker | 79%+ |
| **CarVision-Market-Intelligence** | Regression (car prices) | FeatureEngineer, Streamlit | 97% |
| **TelecomAI-Customer-Intelligence** | Multiclass classification | MLflow, LogisticRegression | 97% |

---

<div align="center">

## 🚀 Start Now!

**Week 1** → [Modern Python](docs/01_PYTHON_MODERNO.md)

---

*Estimated time: 24 weeks (6 months) at moderate pace*

*Last update: December 2024*

**Author**: MLOps Guide Portfolio Edition

</div>
