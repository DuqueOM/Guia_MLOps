# 03B. Refactoring: De Notebook a Código de Producción

## 🎯 Objetivo

Dominar la transición de código exploratorio en notebooks a módulos Python profesionales, mantenibles y testeables.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  "El notebook es donde nacen las ideas.                                     ║
║   El módulo Python es donde esas ideas se convierten en producto."          ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Contenido

1. [¿Por qué Refactorizar?](#1-porque)
2. [Anatomía de un Notebook vs Módulo](#2-anatomia)
3. [Proceso de Refactoring Paso a Paso](#3-proceso)
4. [Patrones Comunes de Extracción](#4-patrones)
5. [Ejemplo Completo: BankChurn](#5-ejemplo)
6. [Testing del Código Refactorizado](#6-testing)
7. [Ejercicio Práctico](#7-ejercicio)

---

<a id="1-porque"></a>

## 1. ¿Por qué Refactorizar Notebooks?

### Problemas del Código en Notebooks

| Problema | Impacto | Solución |
|----------|---------|----------|
| **Estado global** | Celdas dependen de orden de ejecución | Funciones puras |
| **No testeable** | Bugs ocultos hasta producción | Módulos + pytest |
| **No versionable** | Diffs ilegibles en Git | .py separados |
| **No reutilizable** | Copy-paste entre proyectos | Paquetes Python |
| **Sin tipos** | Errores en runtime | Type hints |

### Cuándo Refactorizar

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CICLO DE VIDA DEL CÓDIGO ML                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📓 NOTEBOOK (Exploración)                                                  │
│  ├── EDA rápida                                                            │
│  ├── Pruebas de hipótesis                                                  │
│  ├── Iteración de features                                                 │
│  └── Prototipos de modelos                                                 │
│       │                                                                     │
│       ▼ ¿El código será usado más de una vez?                              │
│       │                                                                     │
│  📦 MÓDULO (Producción)                                                     │
│  ├── Funciones reutilizables                                               │
│  ├── Clases con estado manejado                                            │
│  ├── Configuración externalizada                                           │
│  └── Tests automatizados                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

<a id="2-anatomia"></a>

## 2. Anatomía: Notebook vs Módulo

### Ejemplo: Celda Típica de Notebook

```python
# ❌ Código típico de notebook (difícil de mantener)

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Cargar datos
df = pd.read_csv("data/churn.csv")

# Preprocesar (hardcoded)
df = df.dropna()
df['TenureGroup'] = pd.cut(df['tenure'], bins=[0, 12, 24, 48, 72], labels=['0-1yr', '1-2yr', '2-4yr', '4-6yr'])

# Features y target (hardcoded)
X = df[['CreditScore', 'Age', 'Balance', 'NumOfProducts']]
y = df['Exited']

# Split (seed hardcoded)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Entrenar (sin logging)
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Evaluar (print en lugar de return)
print(f"Accuracy: {model.score(X_test, y_test)}")
```

### Equivalente en Módulo Profesional

```python
# ✅ src/bankchurn/training.py (código de producción)
"""Módulo de entrenamiento para BankChurn."""

from pathlib import Path                             # Manejo de paths cross-platform.
from typing import Tuple, Dict, Any                  # Type hints.
import logging                                       # Logging estructurado.

import pandas as pd                                  # DataFrames.
import numpy as np                                   # Operaciones numéricas.
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score

from bankchurn.config import TrainingConfig          # Configuración externalizada.


logger = logging.getLogger(__name__)                 # Logger del módulo.


def load_data(path: Path) -> pd.DataFrame:
    """
    Carga datos desde archivo CSV.
    
    Args:
        path: Path al archivo CSV.
    
    Returns:
        DataFrame con los datos cargados.
    
    Raises:
        FileNotFoundError: Si el archivo no existe.
        pd.errors.EmptyDataError: Si el archivo está vacío.
    """
    logger.info(f"Loading data from {path}")
    
    if not path.exists():
        raise FileNotFoundError(f"Data file not found: {path}")
    
    df = pd.read_csv(path)
    logger.info(f"Loaded {len(df)} rows, {len(df.columns)} columns")
    
    return df


def preprocess(
    df: pd.DataFrame,
    config: TrainingConfig,
) -> pd.DataFrame:
    """
    Preprocesa datos según configuración.
    
    Args:
        df: DataFrame con datos crudos.
        config: Configuración de preprocesamiento.
    
    Returns:
        DataFrame preprocesado.
    """
    logger.info("Preprocessing data")
    
    # Eliminar NaN según estrategia en config.
    if config.drop_na:
        initial_rows = len(df)
        df = df.dropna()
        logger.info(f"Dropped {initial_rows - len(df)} rows with NaN")
    
    # Feature engineering configurable.
    if config.create_tenure_groups:
        df = df.copy()                               # Evitar SettingWithCopyWarning.
        df['TenureGroup'] = pd.cut(
            df['tenure'],
            bins=config.tenure_bins,
            labels=config.tenure_labels,
        )
    
    return df


def split_data(
    df: pd.DataFrame,
    config: TrainingConfig,
) -> Tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series]:
    """
    Divide datos en train/test.
    
    Args:
        df: DataFrame preprocesado.
        config: Configuración con features, target y split ratio.
    
    Returns:
        Tuple de (X_train, X_test, y_train, y_test).
    """
    X = df[config.feature_columns]
    y = df[config.target_column]
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y,
        test_size=config.test_size,
        random_state=config.seed,
        stratify=y if config.stratify else None,     # Estratificación opcional.
    )
    
    logger.info(f"Train: {len(X_train)}, Test: {len(X_test)}")
    
    return X_train, X_test, y_train, y_test


def train_model(
    X_train: pd.DataFrame,
    y_train: pd.Series,
    config: TrainingConfig,
) -> RandomForestClassifier:
    """
    Entrena modelo con configuración especificada.
    
    Args:
        X_train: Features de entrenamiento.
        y_train: Target de entrenamiento.
        config: Configuración de hiperparámetros.
    
    Returns:
        Modelo entrenado.
    """
    logger.info(f"Training RandomForest with {config.n_estimators} estimators")
    
    model = RandomForestClassifier(
        n_estimators=config.n_estimators,
        max_depth=config.max_depth,
        random_state=config.seed,
        n_jobs=-1,                                   # Usar todos los cores.
    )
    
    model.fit(X_train, y_train)
    logger.info("Training completed")
    
    return model


def evaluate_model(
    model: RandomForestClassifier,
    X_test: pd.DataFrame,
    y_test: pd.Series,
) -> Dict[str, float]:
    """
    Evalúa modelo y retorna métricas.
    
    Args:
        model: Modelo entrenado.
        X_test: Features de test.
        y_test: Target de test.
    
    Returns:
        Dict con métricas de evaluación.
    """
    y_pred = model.predict(X_test)
    
    metrics = {
        "accuracy": accuracy_score(y_test, y_pred),
        "f1_score": f1_score(y_test, y_pred),
    }
    
    logger.info(f"Evaluation metrics: {metrics}")
    
    return metrics


def run_training_pipeline(config: TrainingConfig) -> Dict[str, Any]:
    """
    Ejecuta pipeline completo de entrenamiento.
    
    Esta es la función principal que orquesta todo el proceso.
    
    Args:
        config: Configuración completa del entrenamiento.
    
    Returns:
        Dict con modelo y métricas.
    """
    # 1. Cargar datos.
    df = load_data(config.data_path)
    
    # 2. Preprocesar.
    df = preprocess(df, config)
    
    # 3. Split.
    X_train, X_test, y_train, y_test = split_data(df, config)
    
    # 4. Entrenar.
    model = train_model(X_train, y_train, config)
    
    # 5. Evaluar.
    metrics = evaluate_model(model, X_test, y_test)
    
    return {
        "model": model,
        "metrics": metrics,
        "config": config,
    }
```

---

<a id="3-proceso"></a>

## 3. Proceso de Refactoring Paso a Paso

### 3.1 Checklist de Refactoring

```python
# refactoring_checklist.py
"""Checklist automatizado para refactoring de notebooks."""

from dataclasses import dataclass
from typing import List
from pathlib import Path


@dataclass
class RefactoringStep:
    """Paso de refactoring."""
    name: str
    description: str
    completed: bool = False


def get_refactoring_checklist() -> List[RefactoringStep]:
    """Retorna checklist de refactoring."""
    return [
        RefactoringStep(
            "identify_functions",
            "Identificar bloques de código que hacen UNA cosa"
        ),
        RefactoringStep(
            "extract_config",
            "Extraer valores hardcoded a configuración"
        ),
        RefactoringStep(
            "add_type_hints",
            "Añadir type hints a todas las funciones"
        ),
        RefactoringStep(
            "add_docstrings",
            "Documentar cada función con docstring"
        ),
        RefactoringStep(
            "add_logging",
            "Reemplazar print() con logging"
        ),
        RefactoringStep(
            "add_error_handling",
            "Añadir manejo de errores apropiado"
        ),
        RefactoringStep(
            "remove_global_state",
            "Eliminar variables globales"
        ),
        RefactoringStep(
            "create_tests",
            "Crear tests unitarios para cada función"
        ),
    ]
```

### 3.2 Identificar Responsabilidades

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              MAPEO: CELDAS DE NOTEBOOK → MÓDULOS                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Celda de imports           →  (se distribuyen en cada módulo)              │
│  Celda de carga de datos    →  data.py::load_data()                        │
│  Celda de limpieza          →  data.py::clean_data()                       │
│  Celda de feature eng.      →  features.py::create_features()              │
│  Celda de split             →  training.py::split_data()                   │
│  Celda de entrenamiento     →  training.py::train_model()                  │
│  Celda de evaluación        →  evaluation.py::evaluate_model()             │
│  Celda de predicción        →  prediction.py::predict()                    │
│  Celda de visualización     →  (queda en notebook o dashboards)            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

<a id="4-patrones"></a>

## 4. Patrones Comunes de Extracción

### 4.1 Configuración Externalizada

```python
# src/bankchurn/config.py
"""Configuración centralizada del proyecto."""

from pathlib import Path
from typing import List, Optional
from pydantic import BaseModel, Field              # Validación automática.
import yaml                                        # Lectura de archivos YAML.


class TrainingConfig(BaseModel):
    """Configuración de entrenamiento."""
    
    # Paths.
    data_path: Path = Field(..., description="Path al archivo de datos")
    model_output_path: Path = Field(default=Path("artifacts/model.joblib"))
    
    # Preprocesamiento.
    drop_na: bool = Field(default=True)
    create_tenure_groups: bool = Field(default=True)
    tenure_bins: List[int] = Field(default=[0, 12, 24, 48, 72])
    tenure_labels: List[str] = Field(default=['0-1yr', '1-2yr', '2-4yr', '4-6yr'])
    
    # Features.
    feature_columns: List[str] = Field(
        default=['CreditScore', 'Age', 'Balance', 'NumOfProducts']
    )
    target_column: str = Field(default='Exited')
    
    # Split.
    test_size: float = Field(default=0.2, ge=0.0, le=1.0)
    stratify: bool = Field(default=True)
    
    # Modelo.
    n_estimators: int = Field(default=100, ge=1)
    max_depth: Optional[int] = Field(default=None)
    
    # Reproducibilidad.
    seed: int = Field(default=42)
    
    class Config:
        extra = "forbid"  # Error si hay campos desconocidos.


def load_config(path: Path) -> TrainingConfig:
    """Carga configuración desde YAML."""
    with open(path) as f:
        data = yaml.safe_load(f)
    return TrainingConfig(**data)
```

```yaml
# configs/config.yaml
# Configuración de entrenamiento.

data_path: "data/raw/Churn.csv"
model_output_path: "artifacts/model.joblib"

# Preprocesamiento.
drop_na: true
create_tenure_groups: true

# Features.
feature_columns:
  - CreditScore
  - Age
  - Balance
  - NumOfProducts
  - IsActiveMember

target_column: Exited

# Split.
test_size: 0.2
stratify: true

# Modelo.
n_estimators: 200
max_depth: 10

# Reproducibilidad.
seed: 42
```

### 4.2 De Print a Logging

```python
# ❌ Antes (notebook)
print(f"Loaded {len(df)} rows")
print(f"Training with {n_estimators} trees")
print(f"Accuracy: {accuracy}")

# ✅ Después (módulo)
import logging

logger = logging.getLogger(__name__)

logger.info(f"Loaded {len(df)} rows")
logger.info(f"Training with {n_estimators} trees")
logger.info(f"Accuracy: {accuracy:.4f}")

# Configuración de logging (en __init__.py o main.py)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("training.log"),
    ]
)
```

### 4.3 De Variables Globales a Parámetros

```python
# ❌ Antes (variables globales)
SEED = 42
N_ESTIMATORS = 100
df = None  # Estado global mutable

def train():
    global df  # Dependencia oculta
    model = RandomForestClassifier(n_estimators=N_ESTIMATORS, random_state=SEED)
    model.fit(df[features], df[target])
    return model

# ✅ Después (parámetros explícitos)
def train(
    X: pd.DataFrame,
    y: pd.Series,
    n_estimators: int = 100,
    seed: int = 42,
) -> RandomForestClassifier:
    """Todas las dependencias son explícitas."""
    model = RandomForestClassifier(n_estimators=n_estimators, random_state=seed)
    model.fit(X, y)
    return model
```

---

<a id="5-ejemplo"></a>

## 5. Ejemplo Completo: BankChurn

### Estructura Final

```
BankChurn-Predictor/
├── src/
│   └── bankchurn/
│       ├── __init__.py
│       ├── config.py        # Configuración Pydantic
│       ├── data.py          # Carga y validación
│       ├── features.py      # Feature engineering
│       ├── training.py      # Entrenamiento
│       ├── evaluation.py    # Métricas
│       ├── prediction.py    # Inferencia
│       └── cli.py           # Interfaz de línea de comandos
├── configs/
│   └── config.yaml
├── tests/
│   ├── conftest.py          # Fixtures compartidas
│   ├── test_config.py
│   ├── test_data.py
│   ├── test_training.py
│   └── test_prediction.py
├── notebooks/
│   └── 01_exploration.ipynb  # Notebook para EDA (no producción)
├── main.py                   # Punto de entrada
└── pyproject.toml
```

### main.py: Punto de Entrada

```python
# main.py
"""Punto de entrada principal para BankChurn."""

import argparse
import logging
from pathlib import Path

from bankchurn.config import load_config
from bankchurn.training import run_training_pipeline


def setup_logging(verbose: bool = False):
    """Configura logging."""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    )


def main():
    """Función principal."""
    parser = argparse.ArgumentParser(description="BankChurn Training")
    parser.add_argument(
        "--config",
        type=Path,
        default=Path("configs/config.yaml"),
        help="Path to config file",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose logging",
    )
    
    args = parser.parse_args()
    
    setup_logging(args.verbose)
    
    # Cargar configuración.
    config = load_config(args.config)
    
    # Ejecutar pipeline.
    result = run_training_pipeline(config)
    
    print(f"\n✅ Training completed!")
    print(f"   Accuracy: {result['metrics']['accuracy']:.4f}")
    print(f"   F1-Score: {result['metrics']['f1_score']:.4f}")


if __name__ == "__main__":
    main()
```

---

<a id="6-testing"></a>

## 6. Testing del Código Refactorizado

```python
# tests/test_training.py
"""Tests para módulo de entrenamiento."""

import pytest
import pandas as pd
import numpy as np
from pathlib import Path

from bankchurn.config import TrainingConfig
from bankchurn.training import (
    load_data,
    preprocess,
    split_data,
    train_model,
    evaluate_model,
)


@pytest.fixture
def sample_config():
    """Fixture: configuración de prueba."""
    return TrainingConfig(
        data_path=Path("tests/fixtures/sample_data.csv"),
        feature_columns=['CreditScore', 'Age', 'Balance'],
        target_column='Exited',
        test_size=0.3,
        n_estimators=10,  # Pocos para tests rápidos.
        seed=42,
    )


@pytest.fixture
def sample_df():
    """Fixture: DataFrame de prueba."""
    np.random.seed(42)
    n = 100
    return pd.DataFrame({
        'CreditScore': np.random.randint(300, 850, n),
        'Age': np.random.randint(18, 70, n),
        'Balance': np.random.uniform(0, 100000, n),
        'tenure': np.random.randint(0, 72, n),
        'Exited': np.random.choice([0, 1], n, p=[0.8, 0.2]),
    })


class TestPreprocess:
    """Tests para función preprocess."""
    
    def test_drops_na_when_configured(self, sample_df, sample_config):
        """Verifica que dropna funciona."""
        # Añadir NaN.
        df = sample_df.copy()
        df.loc[0, 'CreditScore'] = np.nan
        
        result = preprocess(df, sample_config)
        
        assert len(result) == len(df) - 1
        assert result['CreditScore'].isna().sum() == 0


class TestSplitData:
    """Tests para función split_data."""
    
    def test_correct_split_ratio(self, sample_df, sample_config):
        """Verifica ratio de split."""
        X_train, X_test, y_train, y_test = split_data(sample_df, sample_config)
        
        total = len(X_train) + len(X_test)
        actual_ratio = len(X_test) / total
        
        assert abs(actual_ratio - sample_config.test_size) < 0.05
    
    def test_reproducibility(self, sample_df, sample_config):
        """Verifica reproducibilidad con seed."""
        result1 = split_data(sample_df, sample_config)
        result2 = split_data(sample_df, sample_config)
        
        pd.testing.assert_frame_equal(result1[0], result2[0])


class TestTrainModel:
    """Tests para función train_model."""
    
    def test_model_trains_successfully(self, sample_df, sample_config):
        """Verifica que modelo se entrena."""
        X_train, _, y_train, _ = split_data(sample_df, sample_config)
        model = train_model(X_train, y_train, sample_config)
        
        assert hasattr(model, 'predict')
        assert model.n_estimators == sample_config.n_estimators
```

---

<a id="7-ejercicio"></a>

## 7. Ejercicio Práctico

### Objetivo

Refactoriza el siguiente código de notebook a módulos profesionales.

### Código Original (Notebook)

```python
# Notebook: exploration.ipynb

import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression

# Cargar
df = pd.read_csv("data.csv")

# Limpiar
df = df.dropna()
df = df[df['age'] > 0]

# Features
scaler = StandardScaler()
X = df[['age', 'income', 'score']]
X_scaled = scaler.fit_transform(X)
y = df['target']

# Train
model = LogisticRegression()
model.fit(X_scaled, y)

# Predict
predictions = model.predict(X_scaled)
print(f"Accuracy: {(predictions == y).mean()}")
```

### Tu Tarea

1. **Crear estructura de módulos**:
   - `src/myproject/config.py`
   - `src/myproject/data.py`
   - `src/myproject/training.py`

2. **Extraer configuración** a YAML.

3. **Añadir type hints y docstrings**.

4. **Reemplazar print con logging**.

5. **Crear al menos 2 tests**.

### Entregables

- [ ] Módulos en `src/myproject/`.
- [ ] `configs/config.yaml`.
- [ ] Tests en `tests/`.
- [ ] `main.py` funcional.

---

## 📚 Recursos

- [Notebook to Production (MLOps)](https://madewithml.com/courses/mlops/packaging/)
- [Python Packaging User Guide](https://packaging.python.org/)
- [Real Python: Refactoring](https://realpython.com/python-refactoring/)

---

**Siguiente**: [04_ENTORNOS.md](04_ENTORNOS.md)
