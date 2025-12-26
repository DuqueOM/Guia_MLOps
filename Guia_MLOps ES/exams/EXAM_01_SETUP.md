# 📋 Examen de Hito 1: Setup Profesional

> **Formato**: Self-Correction Code Review  
> **Duración**: 45-60 minutos  
> **Puntaje mínimo**: 70/100

---

## Instrucciones

Actúa como un **Senior MLOps Engineer** haciendo code review. Tu tarea es:
1. Identificar TODOS los errores en el código
2. Clasificar cada error por severidad (🔴 Crítico, 🟡 Medio, 🟢 Menor)
3. Proponer la corrección

---

## Ejercicio 1: Type Hints (25 puntos)

### Código a Revisar

```python
# archivo: src/bankchurn/training.py

def load_data(path):
    """Carga datos desde CSV."""
    import pandas as pd
    return pd.read_csv(path)


def prepare_features(df, target_col, features):
    X = df[features]
    y = df[target_col]
    return X, y


def train_model(X, y, n_estimators=100, max_depth=None):
    from sklearn.ensemble import RandomForestClassifier
    model = RandomForestClassifier(n_estimators=n_estimators, max_depth=max_depth)
    model.fit(X, y)
    return model


def evaluate(model, X_test, y_test):
    from sklearn.metrics import accuracy_score, f1_score
    predictions = model.predict(X_test)
    return {
        "accuracy": accuracy_score(y_test, predictions),
        "f1": f1_score(y_test, predictions)
    }
```

### Tu Respuesta

¿Cuántos problemas encontraste? Clasifícalos:

| # | Línea | Problema | Severidad | Corrección |
|---|-------|----------|-----------|------------|
| 1 |       |          |           |            |
| 2 |       |          |           |            |
| 3 |       |          |           |            |

---

<details>
<summary>📝 Ver Solución (no abrir hasta terminar)</summary>

### Errores Encontrados

| # | Línea | Problema | Severidad | Corrección |
|---|-------|----------|-----------|------------|
| 1 | 3 | `load_data(path)` sin type hints | 🟡 Medio | `def load_data(path: str \| Path) -> pd.DataFrame:` |
| 2 | 4 | Import dentro de función | 🟢 Menor | Mover imports al inicio del archivo |
| 3 | 8 | `prepare_features` sin tipos | 🟡 Medio | Añadir `df: pd.DataFrame, target_col: str, features: list[str]` |
| 4 | 8 | Retorno sin tipar | 🟡 Medio | `-> Tuple[pd.DataFrame, pd.Series]` |
| 5 | 14 | `train_model` sin tipo de retorno | 🟡 Medio | `-> RandomForestClassifier` o `-> BaseEstimator` |
| 6 | 14 | `max_depth=None` sin `Optional[int]` | 🟢 Menor | `max_depth: Optional[int] = None` |
| 7 | 21 | `evaluate` retorna `dict` sin tipar | 🟡 Medio | `-> Dict[str, float]` o `TypedDict` |

### Código Corregido

```python
# archivo: src/bankchurn/training.py
from __future__ import annotations

from pathlib import Path
from typing import Dict, Optional, Tuple, Sequence

import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score
from sklearn.base import BaseEstimator


def load_data(path: str | Path) -> pd.DataFrame:
    """Carga datos desde CSV."""
    return pd.read_csv(path)


def prepare_features(
    df: pd.DataFrame,
    target_col: str,
    features: Sequence[str]
) -> Tuple[pd.DataFrame, pd.Series]:
    """Separa features y target."""
    X = df[list(features)]
    y = df[target_col]
    return X, y


def train_model(
    X: pd.DataFrame,
    y: pd.Series,
    n_estimators: int = 100,
    max_depth: Optional[int] = None
) -> RandomForestClassifier:
    """Entrena modelo Random Forest."""
    model = RandomForestClassifier(
        n_estimators=n_estimators,
        max_depth=max_depth,
        random_state=42  # Reproducibilidad
    )
    model.fit(X, y)
    return model


def evaluate(
    model: BaseEstimator,
    X_test: pd.DataFrame,
    y_test: pd.Series
) -> Dict[str, float]:
    """Evalúa modelo con métricas de clasificación."""
    predictions = model.predict(X_test)
    return {
        "accuracy": float(accuracy_score(y_test, predictions)),
        "f1": float(f1_score(y_test, predictions))
    }
```

**Puntuación**: 
- 7 errores × 3 puntos = 21 puntos base
- Correcciones correctas: +4 puntos
- **Total**: 25/25

</details>

---

## Ejercicio 2: Pydantic Config (25 puntos)

### Código a Revisar

```python
# archivo: src/bankchurn/config.py

from pydantic import BaseModel

class Config(BaseModel):
    test_size: float = 0.2
    n_estimators: int = 100
    max_depth: int = 10
    random_state: int = 42
    target: str = "Exited"
    features: list = []
    
    def load_from_yaml(self, path):
        import yaml
        with open(path) as f:
            data = yaml.safe_load(f)
        return Config(**data)
```

### Tu Respuesta

| # | Línea | Problema | Severidad | Corrección |
|---|-------|----------|-----------|------------|

---

<details>
<summary>📝 Ver Solución</summary>

### Errores Encontrados

| # | Línea | Problema | Severidad | Corrección |
|---|-------|----------|-----------|------------|
| 1 | 6 | `test_size` sin validación de rango | 🔴 Crítico | `Field(default=0.2, ge=0.01, le=0.5)` |
| 2 | 7 | `n_estimators` sin rango mínimo | 🟡 Medio | `Field(default=100, ge=10)` |
| 3 | 8 | `max_depth` debería ser `Optional[int]` | 🟡 Medio | `max_depth: int \| None = Field(default=10, ge=1)` |
| 4 | 11 | `features: list` sin tipo genérico | 🟡 Medio | `features: list[str] = Field(default_factory=list)` |
| 5 | 11 | `features: list = []` mutable default | 🔴 Crítico | Usar `Field(default_factory=list)` |
| 6 | 13 | `load_from_yaml` debería ser `@classmethod` | 🟡 Medio | Decorar con `@classmethod` |
| 7 | 13 | Sin type hints en método | 🟢 Menor | `def load_from_yaml(cls, path: Path) -> "Config":` |
| 8 | 14 | Import dentro de método | 🟢 Menor | Mover al inicio |

### Código Corregido

```python
from __future__ import annotations

from pathlib import Path

import yaml
from pydantic import BaseModel, Field


class Config(BaseModel):
    """Configuración del modelo con validación."""
    
    test_size: float = Field(
        default=0.2,
        ge=0.01,
        le=0.5,
        description="Proporción de datos para test"
    )
    n_estimators: int = Field(default=100, ge=10, le=1000)
    max_depth: int | None = Field(default=10, ge=1)
    random_state: int = 42
    target: str = "Exited"
    features: list[str] = Field(default_factory=list)
    
    @classmethod
    def load_from_yaml(cls, path: str | Path) -> "Config":
        """Carga configuración desde archivo YAML."""
        with open(path) as f:
            data = yaml.safe_load(f)
        return cls(**data)
```

</details>

---

## Ejercicio 3: Estructura de Proyecto (25 puntos)

### Estructura a Revisar

```
myproject/
├── train.py
├── predict.py
├── config.yaml
├── model.pkl
├── data/
│   ├── train.csv
│   └── test.csv
├── utils.py
├── requirements.txt
└── tests/
    └── test_train.py
```

### Tu Respuesta

Lista todos los problemas de estructura:

1. 
2. 
3. 

---

<details>
<summary>📝 Ver Solución</summary>

### Problemas de Estructura

| # | Problema | Severidad | Solución |
|---|----------|-----------|----------|
| 1 | Sin `src/` layout | 🔴 Crítico | Mover código a `src/myproject/` |
| 2 | Sin `pyproject.toml` | 🔴 Crítico | Crear archivo de metadata |
| 3 | `model.pkl` en raíz | 🟡 Medio | Mover a `artifacts/` o `models/` |
| 4 | Sin `__init__.py` | 🟡 Medio | Crear para hacer paquete |
| 5 | `requirements.txt` en vez de pyproject.toml | 🟢 Menor | Migrar a pyproject.toml |
| 6 | Sin `.gitignore` | 🟡 Medio | Crear con patrones comunes |
| 7 | Sin `conftest.py` en tests | 🟢 Menor | Crear para fixtures |
| 8 | `config.yaml` en raíz | 🟢 Menor | Mover a `configs/` |

### Estructura Correcta

```
myproject/
├── src/
│   └── myproject/
│       ├── __init__.py
│       ├── config.py
│       ├── training.py
│       ├── prediction.py
│       └── utils.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   └── test_training.py
├── configs/
│   └── config.yaml
├── data/
│   ├── raw/
│   └── processed/
├── artifacts/
│   └── .gitkeep
├── pyproject.toml
├── Makefile
├── .gitignore
└── README.md
```

</details>

---

## Ejercicio 4: Pre-commit (25 puntos)

### Archivo a Revisar

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.0.0
    hooks:
      - id: trailing-whitespace
      - id: check-yaml
```

### Tu Respuesta

¿Qué falta? Lista al menos 5 hooks importantes:

1. 
2. 
3. 
4. 
5. 

---

<details>
<summary>📝 Ver Solución</summary>

### Hooks Faltantes

| # | Hook | Propósito | Severidad |
|---|------|-----------|-----------|
| 1 | `end-of-file-fixer` | Asegura newline al final | 🟢 |
| 2 | `check-added-large-files` | Evita archivos >500KB | 🔴 |
| 3 | `ruff` (linting) | Errores de estilo y bugs | 🔴 |
| 4 | `ruff-format` | Formateo consistente | 🟡 |
| 5 | `mypy` | Verificación de tipos | 🔴 |
| 6 | `check-merge-conflict` | Evita commits con conflictos | 🟡 |

### Configuración Completa

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
        args: ['--maxkb=500']
      - id: check-merge-conflict
      - id: detect-private-key

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.9
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
        additional_dependencies: [pydantic, pandas-stubs]
```

</details>

---

## Rúbrica de Evaluación

| Ejercicio | Puntos | Tu Puntaje |
|-----------|:------:|:----------:|
| Type Hints | 25 | |
| Pydantic Config | 25 | |
| Estructura | 25 | |
| Pre-commit | 25 | |
| **TOTAL** | **100** | |

**Criterio de aprobación**: ≥ 70 puntos

---

## Reflexión Final

Responde estas preguntas:

1. ¿Cuál fue el error más difícil de detectar?
2. ¿Qué herramienta te habría ayudado a detectarlo automáticamente?
3. ¿Qué cambiarás en tu código después de este examen?
