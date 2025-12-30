# 📋 Examen de Hito 2: Pipeline Reproducible

> **Formato**: Self-Correction Code Review  
> **Duración**: 45-60 minutos  
> **Puntaje mínimo**: 70/100

---

## Ejercicio 1: Data Leakage Detection (30 puntos)

### Código a Revisar

```python
# archivo: train.py
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

# Cargar datos
df = pd.read_csv("data/customers.csv")
X = df.drop("Exited", axis=1)
y = df["Exited"]

# Preprocesamiento
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # Línea A

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X_scaled, y, test_size=0.2, random_state=42
)

# Entrenar
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Evaluar
y_pred = model.predict(X_test)
print(f"Accuracy: {accuracy_score(y_test, y_pred):.3f}")
```

### Tu Respuesta

1. ¿Hay data leakage en este código? (Sí/No)
2. Si sí, ¿en qué línea?
3. ¿Por qué es un problema?
4. ¿Cómo lo corregirías?

---

<details>
<summary>📝 Ver Solución</summary>

### Análisis

1. **¿Hay data leakage?** ✅ SÍ

2. **Línea problemática**: Línea A - `X_scaled = scaler.fit_transform(X)`

3. **Por qué es un problema**:
   - `fit_transform(X)` calcula media y std de TODO el dataset
   - Esto incluye datos que luego serán el test set
   - El scaler "sabe" información del futuro (test data)
   - En producción, el modelo verá datos que NO conocía durante entrenamiento
   - El accuracy reportado es **optimista** (el modelo parece mejor de lo que es)

4. **Corrección**:

```python
# CORRECTO: Split PRIMERO, fit en train SOLAMENTE
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.pipeline import Pipeline

# Cargar datos
df = pd.read_csv("data/customers.csv")
X = df.drop("Exited", axis=1)
y = df["Exited"]

# Split PRIMERO (antes de cualquier transformación)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Opción 1: Pipeline (RECOMENDADO)
pipeline = Pipeline([
    ("scaler", StandardScaler()),
    ("classifier", RandomForestClassifier(n_estimators=100, random_state=42))
])

pipeline.fit(X_train, y_train)  # fit solo en train
y_pred = pipeline.predict(X_test)  # transform implícito usa stats de train

# Opción 2: Manual (si no usas Pipeline)
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)  # fit + transform en train
X_test_scaled = scaler.transform(X_test)        # SOLO transform en test

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train_scaled, y_train)
y_pred = model.predict(X_test_scaled)
```

**Puntuación**:
- Identificar leakage: 10 pts
- Línea correcta: 5 pts
- Explicación clara: 10 pts
- Corrección válida: 5 pts

</details>

---

## Ejercicio 2: DVC Pipeline (25 puntos)

### Código a Revisar

```yaml
# dvc.yaml
stages:
  prepare:
    cmd: python prepare.py
    outs:
      - data/processed/train.csv

  train:
    cmd: python train.py
    deps:
      - data/processed/train.csv
    outs:
      - models/model.pkl

  evaluate:
    cmd: python evaluate.py
    deps:
      - models/model.pkl
```

### Tu Respuesta

Encuentra al menos 5 problemas:

| # | Problema | Impacto | Corrección |
|---|----------|---------|------------|
| 1 |          |         |            |

---

<details>
<summary>📝 Ver Solución</summary>

| # | Problema | Impacto | Corrección |
|---|----------|---------|------------|
| 1 | `prepare` no tiene `deps` | No re-ejecuta si cambia el script o datos raw | Añadir `deps: [prepare.py, data/raw/data.csv]` |
| 2 | `train` no depende de `train.py` | Cambios en código no disparan re-entrenamiento | Añadir `deps: [train.py]` |
| 3 | `evaluate` no tiene `outs` | No versiona métricas | Añadir `metrics: [metrics.json]` |
| 4 | `evaluate` no depende de test data | No re-evalúa si cambian datos de test | Añadir `deps: [data/processed/test.csv]` |
| 5 | Sin `plots` para visualizaciones | Pierde trazabilidad de gráficas | Añadir `plots: [plots/]` |
| 6 | `prepare` no genera test.csv | Split no versionado | Añadir `data/processed/test.csv` a outs |

### DVC Pipeline Corregido

```yaml
stages:
  prepare:
    cmd: python src/prepare.py
    deps:
      - src/prepare.py
      - data/raw/customers.csv
    params:
      - prepare.test_size
      - prepare.random_state
    outs:
      - data/processed/train.csv
      - data/processed/test.csv

  train:
    cmd: python src/train.py
    deps:
      - src/train.py
      - data/processed/train.csv
    params:
      - model.n_estimators
      - model.max_depth
    outs:
      - models/model.pkl

  evaluate:
    cmd: python src/evaluate.py
    deps:
      - src/evaluate.py
      - models/model.pkl
      - data/processed/test.csv
    metrics:
      - metrics.json:
          cache: false
    plots:
      - plots/confusion_matrix.png
      - plots/roc_curve.png
```

</details>

---

## Ejercicio 3: Custom Transformer (25 puntos)

### Código a Revisar

```python
# archivo: transformers.py
from sklearn.base import BaseEstimator

class FeatureSelector:
    def __init__(self, columns):
        self.columns = columns
    
    def fit(self, X, y):
        return self
    
    def transform(self, X):
        return X[self.columns]


class OutlierRemover(BaseEstimator):
    def __init__(self, threshold=3):
        self.threshold = threshold
    
    def fit(self, X, y=None):
        self.mean = X.mean()
        self.std = X.std()
    
    def transform(self, X):
        z_scores = (X - self.mean) / self.std
        return X[abs(z_scores) < self.threshold]
```

### Tu Respuesta

| # | Clase | Problema | Corrección |
|---|-------|----------|------------|

---

<details>
<summary>📝 Ver Solución</summary>

| # | Clase | Problema | Corrección |
|---|-------|----------|------------|
| 1 | FeatureSelector | No hereda de BaseEstimator | `class FeatureSelector(BaseEstimator):` |
| 2 | FeatureSelector | No hereda de TransformerMixin | Añadir `TransformerMixin` |
| 3 | FeatureSelector | fit no retorna self tipado | `def fit(self, X, y=None) -> "FeatureSelector":` |
| 4 | OutlierRemover | fit no retorna self | Añadir `return self` |
| 5 | OutlierRemover | No hereda de TransformerMixin | Añadir herencia |
| 6 | OutlierRemover | transform cambia número de filas | En producción esto rompe el pipeline |
| 7 | OutlierRemover | Usar `self.mean_` (convención sklearn) | Atributos learned terminan en `_` |

### Código Corregido

```python
from sklearn.base import BaseEstimator, TransformerMixin
import numpy as np
import pandas as pd

class FeatureSelector(BaseEstimator, TransformerMixin):
    """Selecciona columnas específicas."""
    
    def __init__(self, columns: list[str]):
        self.columns = columns
    
    def fit(self, X: pd.DataFrame, y=None) -> "FeatureSelector":
        # Validar que columnas existen
        missing = set(self.columns) - set(X.columns)
        if missing:
            raise ValueError(f"Columns not found: {missing}")
        return self
    
    def transform(self, X: pd.DataFrame) -> pd.DataFrame:
        return X[self.columns].copy()


class OutlierClipper(BaseEstimator, TransformerMixin):
    """Recorta outliers (no elimina filas)."""
    
    def __init__(self, factor: float = 1.5):
        self.factor = factor
    
    def fit(self, X, y=None) -> "OutlierClipper":
        Q1 = np.percentile(X, 25, axis=0)
        Q3 = np.percentile(X, 75, axis=0)
        IQR = Q3 - Q1
        self.lower_ = Q1 - self.factor * IQR  # Convención: atributo learned
        self.upper_ = Q3 + self.factor * IQR
        return self  # SIEMPRE retornar self
    
    def transform(self, X):
        # Clip en vez de eliminar (mantiene número de filas)
        return np.clip(X, self.lower_, self.upper_)
```

</details>

---

## Ejercicio 4: Pandera Schema (20 puntos)

### Código a Revisar

```python
# archivo: schemas.py
import pandera as pa

class CustomerSchema(pa.SchemaModel):
    age: int
    balance: float
    exited: int
```

### Tu Respuesta

¿Qué validaciones faltan para datos de producción?

---

<details>
<summary>📝 Ver Solución</summary>

```python
import pandera as pa
from pandera.typing import Series

class CustomerSchema(pa.DataFrameModel):
    """Schema para datos de clientes - producción."""
    
    # Tipos + validaciones de rango
    CreditScore: Series[int] = pa.Field(
        ge=300, le=850,
        description="FICO score"
    )
    Age: Series[int] = pa.Field(
        ge=18, le=100,
        description="Edad del cliente"
    )
    Balance: Series[float] = pa.Field(
        ge=0,
        description="Balance en cuenta"
    )
    NumOfProducts: Series[int] = pa.Field(
        ge=1, le=4,
        description="Número de productos"
    )
    Exited: Series[int] = pa.Field(
        isin=[0, 1],
        description="Target: 1=churned"
    )
    
    class Config:
        strict = True       # No permite columnas extra
        coerce = True       # Convierte tipos automáticamente
        name = "CustomerSchema"
    
    @pa.check("Balance")
    def balance_not_negative(cls, series: Series[float]) -> Series[bool]:
        return series >= 0
    
    @pa.dataframe_check
    def no_duplicate_customers(cls, df) -> bool:
        """No debe haber IDs duplicados."""
        return df.index.is_unique
```

**Validaciones añadidas**:
1. Rangos realistas (age 18-100, credit 300-850)
2. Valores permitidos (Exited solo 0 o 1)
3. `strict=True` para rechazar columnas inesperadas
4. Custom checks para lógica de negocio

</details>

---

## Rúbrica

| Ejercicio | Puntos |
|-----------|:------:|
| Data Leakage | 30 |
| DVC Pipeline | 25 |
| Custom Transformer | 25 |
| Pandera Schema | 20 |
| **TOTAL** | **100** |
