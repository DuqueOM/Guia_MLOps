# 07. sklearn Pipelines: El Corazón de MLOps

## 🎯 Objetivo del Módulo

Dominar el patrón más importante de ML profesional: **pipelines unificados** que garantizan reproducibilidad desde entrenamiento hasta producción.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  🚨 EL ERROR #1 EN PRODUCCIÓN ML:                                            ║
║                                                                              ║
║  Entrenar con una transformación, servir con otra.                           ║
║                                                                              ║
║  Ejemplo real:                                                               ║
║  • Training: StandardScaler fitted en train set (mean=45000, std=20000)      ║
║  • Production: StandardScaler fitted en cada request (mean=???, std=???)     ║
║  • Resultado: Predicciones COMPLETAMENTE diferentes                          ║
║                                                                              ║
║  🛡️ LA SOLUCIÓN: Pipeline unificado que guarda TODO junto                    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

<a id="00-prerrequisitos"></a>

## 0.0 Prerrequisitos

- Haber completado **[01_PYTHON_MODERNO](01_PYTHON_MODERNO.md)** y entender el motivo del `src/` layout.
- Tener un proyecto del portafolio a mano (ideal: BankChurn) para ubicar el `pipeline.pkl` real.
- Entender el problema de *training-serving skew* (al menos a nivel conceptual).

---

<a id="01-protocolo-e-como-estudiar-este-modulo"></a>

## 0.1 🧠 Protocolo E: Cómo estudiar este módulo

- **Antes de codificar**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define tu *output mínimo* (ej: “pipeline serializable + tests básicos”).
- **Mientras debuggeas**: si te atoras >15 min (ColumnTransformer, columnas, dtypes, `fit/transform`), registra el bloqueo en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
- **Al cerrar la semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para decidir qué mejorar (reproducibilidad, tests, DX).

---

<a id="02-entregables-verificables-minimo-viable"></a>

## 0.2 ✅ Entregables verificables (mínimo viable)

Al terminar este módulo, deberías poder mostrar (en al menos 1 proyecto del portafolio):

- [ ] **1 pipeline unificado** serializado (`pipeline.pkl`) que incluya preprocesamiento + modelo.
- [ ] **Inferencia consistente**: `pipeline.predict(X_new)` sin re-fit de transformadores.
- [ ] **Checklist de verificación** pasando (sección “Checkpoint”).

---

<a id="03-puente-teoria-codigo-portafolio"></a>

## 0.3 🧩 Puente teoría ↔ código (Portafolio)

Para que esto cuente como progreso real, fuerza este mapeo:

- **Concepto**: Pipeline/ColumnTransformer/custom transformers
- **Archivo**: `src/<paquete>/training.py`, `src/<paquete>/features.py`, `models/pipeline.pkl`
- **Prueba**: entrenar una vez, guardar `pipeline.pkl`, cargarlo y predecir con datos nuevos.

---

## 📋 Contenido

- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
1. [¿Por Qué Pipelines?](#71-por-que-pipelines)
2. [ColumnTransformer: Transformaciones Paralelas](#72-columntransformer-transformaciones-paralelas)
3. [Custom Transformers](#73-custom-transformers-tu-superpoder)
4. [Pipeline Completo: Código Real](#74-pipeline-completo-codigo-real)
5. [Ejercicios Prácticos](#75-ejercicios-practicos)
- [Errores habituales](#errores-habituales)
- [✅ Checkpoint](#checkpoint)

---

<a id="71-por-que-pipelines"></a>

## 7.1 ¿Por Qué Pipelines?

### La Analogía de la Línea de Ensamblaje

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  🏭 IMAGINA UNA FÁBRICA DE AUTOS:                                         ║
║                                                                           ║
║  SIN LÍNEA DE ENSAMBLAJE (código suelto):                                 ║
║  • Trabajador 1 pone ruedas, pero a veces se le olvida                    ║
║  • Trabajador 2 pinta, pero usa colores diferentes cada día               ║
║  • Trabajador 3 instala motor, pero a veces del modelo equivocado         ║
║  • Resultado: Cada auto es diferente, imposible de mantener               ║
║                                                                           ║
║  CON LÍNEA DE ENSAMBLAJE (Pipeline):                                      ║
║  • Paso 1: Chasis → Paso 2: Motor → Paso 3: Pintura → Paso 4: Ruedas      ║
║  • Cada paso está definido y es SIEMPRE igual                             ║
║  • El proceso completo es una sola unidad                                 ║
║  • Resultado: Todos los autos son consistentes                            ║
║                                                                           ║
║  sklearn Pipeline = Línea de ensamblaje para ML                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### El Problema Real: Training-Serving Skew

```python
# ❌ CÓDIGO PROBLEMÁTICO (muy común en notebooks convertidos a producción)

# === ENTRENAMIENTO ===
from sklearn.preprocessing import StandardScaler, OneHotEncoder  # Importa transformadores de sklearn.

# Ajustar scaler en datos de entrenamiento
scaler = StandardScaler()                                  # Crea instancia: aún no tiene parámetros learned.
X_train_scaled = scaler.fit_transform(X_train[num_cols])   # fit_transform: calcula mean/std Y transforma.

encoder = OneHotEncoder()                                  # Crea encoder para convertir categorías a binario.
X_train_encoded = encoder.fit_transform(X_train[cat_cols]) # fit: aprende categorías únicas; transform: aplica.

# Entrenar modelo
model = RandomForestClassifier()                           # Crea el modelo de clasificación.
model.fit(X_train_processed, y_train)                      # Entrena con datos ya transformados.

# Guardar modelo... pero ¿y el scaler? ¿y el encoder?
joblib.dump(model, "model.pkl")  # ← ¡ERROR! Solo guarda el modelo, NO los transformadores.

# === PRODUCCIÓN (meses después, otro desarrollador) ===
model = joblib.load("model.pkl")                           # Carga solo el modelo.

# ¿Cómo transformo los datos nuevos?
# 🤷 No tengo el scaler ni el encoder fitted             # Los transformadores se perdieron.
# 🤷 Incluso si los tuviera, ¿cómo sé qué columnas usar? # No hay documentación de las columnas.
# 🤷 ¿Era StandardScaler o MinMaxScaler?                 # Imposible saber qué se usó.

# "Solución" del desarrollador desesperado:
scaler = StandardScaler()                                  # Crea NUEVO scaler (sin los parámetros originales).
X_new_scaled = scaler.fit_transform(X_new[num_cols])       # fit en datos NUEVOS: mean/std DIFERENTES.
# ⚠️ Ahora mean y std son DIFERENTES a los de entrenamiento → training-serving skew.
# ⚠️ Las predicciones son BASURA porque la escala es inconsistente.

# ============================================================================
# ✅ SOLUCIÓN: Pipeline Unificado
# ============================================================================

# === ENTRENAMIENTO ===
from sklearn.pipeline import Pipeline              # Pipeline: encadena pasos secuenciales.
from sklearn.compose import ColumnTransformer      # ColumnTransformer: aplica transformaciones por grupo de columnas.

# Definir pipeline completo
pipeline = Pipeline([                              # Lista de tuplas (nombre, objeto).
    ('preprocessor', ColumnTransformer([           # Primer paso: preprocesamiento por columnas.
        ('num', StandardScaler(), num_cols),       # Escala numéricas (aprende mean/std de train).
        ('cat', OneHotEncoder(handle_unknown='ignore'), cat_cols)  # One-hot categorícas; ignore evita crash.
    ])),
    ('model', RandomForestClassifier())            # Segundo paso: el modelo.
])

# Un solo fit entrena TODO
pipeline.fit(X_train, y_train)                     # fit() propaga por todos los pasos: transforma Y entrena.

# Guardar TODO junto
joblib.dump(pipeline, "pipeline.pkl")              # Serializa Scaler + Encoder + Model en UN archivo.

# === PRODUCCIÓN ===
pipeline = joblib.load("pipeline.pkl")             # Carga todo: transformadores YA fitted + modelo.

# Una sola llamada hace TODO (con los parámetros de entrenamiento)
predictions = pipeline.predict(X_new)              # predict() internamente transforma X_new y luego predice.

# ✅ El scaler usa mean/std del entrenamiento      → Consistencia garantizada.
# ✅ El encoder conoce las categorías del entrenamiento → No crash por categorías nuevas.
# ✅ Las predicciones son consistentes             → Sin training-serving skew.
```

---

<a id="72-columntransformer-transformaciones-paralelas"></a>

## 7.2 ColumnTransformer: Transformaciones Paralelas

### El Problema: Diferentes Columnas, Diferentes Tratamientos

```
Datos de un banco:
┌─────────────┬───────────┬─────────┬─────────┬────────┐
│ CreditScore │ Geography │ Gender  │   Age   │ Balance│
├─────────────┼───────────┼─────────┼─────────┼────────┤
│     619     │  France   │  Female │    42   │  10000 │
│     608     │   Spain   │  Female │    41   │  83808 │
│     502     │  France   │  Female │    42   │      0 │
└─────────────┴───────────┴─────────┴─────────┴────────┘

Columnas numéricas (CreditScore, Age, Balance):
→ StandardScaler: normalizar a mean=0, std=1

Columnas categóricas (Geography, Gender):
→ OneHotEncoder: convertir a columnas binarias
```

### ColumnTransformer: La Solución Elegante

```python
from sklearn.compose import ColumnTransformer        # Enruta transformaciones por grupos de columnas.
from sklearn.preprocessing import StandardScaler, OneHotEncoder  # Transformadores estándar.
from sklearn.impute import SimpleImputer             # Imputa valores faltantes (NaN).
from sklearn.pipeline import Pipeline                # Encadena pasos secuenciales.

# Definir qué columnas son de cada tipo
num_cols = ["CreditScore", "Age", "Tenure", "Balance", "NumOfProducts", "EstimatedSalary"]  # Numéricas.
cat_cols = ["Geography", "Gender"]                   # Categóricas: valores discretos/textuales.

# Pipeline para numéricas: Imputar NaN → Escalar
num_pipeline = Pipeline([                            # Pipeline DENTRO de ColumnTransformer.
    ('imputer', SimpleImputer(strategy='median')),   # Rellena NaN con mediana (robusto a outliers).
    ('scaler', StandardScaler())                     # Normaliza a mean=0, std=1.
])

# Pipeline para categóricas: Imputar NaN → One-Hot
cat_pipeline = Pipeline([
    ('imputer', SimpleImputer(strategy='constant', fill_value='Unknown')),  # NaN → string "Unknown".
    ('encoder', OneHotEncoder(handle_unknown='ignore'))  # ignore: categorías nuevas → vector de ceros.
])

# ColumnTransformer: Aplica cada pipeline a sus columnas
preprocessor = ColumnTransformer(
    transformers=[                                   # Lista de transformadores.
        ('num', num_pipeline, num_cols),             # (nombre, transformer, columnas_a_transformar).
        ('cat', cat_pipeline, cat_cols)              # Cada grupo se procesa independientemente.
    ],
    remainder='drop'                                 # 'drop': elimina columnas no listadas. 'passthrough': las deja.
)

# Resultado: Un solo objeto que sabe transformar todo
X_processed = preprocessor.fit_transform(X_train)   # fit: aprende parámetros; transform: aplica.
```

### Visualización del Flujo

```
                        ColumnTransformer
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
        num_pipeline    cat_pipeline    remainder
              │               │               │
              │               │               │
    ┌─────────┴─────────┐     │               │
    │                   │     │               │
    ▼                   ▼     ▼               ▼
┌─────────┐       ┌─────────┐ ┌─────────┐   drop
│Imputer  │       │ Scaler  │ │ Imputer │
│(median) │       │         │ │(Unknown)│
└─────────┘       └─────────┘ └────┬────┘
                                   │
                                   ▼
                              ┌─────────┐
                              │ OneHot  │
                              │ Encoder │
                              └─────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
              ▼                    ▼                    ▼
    [6 columnas numéricas]  [3 Geography cols]  [2 Gender cols]
         escaladas            (France, Spain,     (Female, Male)
                               Germany)

    Output: 11 columnas totales (6 + 3 + 2)
```

---

<a id="73-custom-transformers-tu-superpoder"></a>

## 7.3 Custom Transformers: Tu Superpoder

### ¿Cuándo Crear un Custom Transformer?

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  Crea un Custom Transformer cuando:                                       ║
║                                                                           ║
║  ✅ Necesitas feature engineering específico del dominio                  ║
║  ✅ La transformación debe aplicarse igual en train y producción          ║
║  ✅ sklearn no tiene un transformer que haga lo que necesitas             ║
║                                                                           ║
║  Ejemplos del portafolio:                                                 ║
║  • CarVision: Calcular vehicle_age desde model_year                       ║
║  • CarVision: Extraer brand desde model                                   ║
║  • BankChurn: Resampling para clases desbalanceadas                       ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Ejemplo 1: FeatureEngineer (CarVision)

```python
# src/carvision/features.py - Código REAL del portafolio

from __future__ import annotations

from typing import Optional

import pandas as pd
from sklearn.base import BaseEstimator, TransformerMixin


class FeatureEngineer(BaseEstimator, TransformerMixin):
    """
    Centralized feature engineering to ensure consistency across
    Training, Inference, and Analysis.
    
    Este transformer garantiza que las mismas transformaciones
    se apliquen en:
    1. Entrenamiento (training.py)
    2. Inferencia API (fastapi_app.py)
    3. Dashboard (streamlit_app.py)
    
    Attributes
    ----------
    current_year : int, optional
        Año para calcular vehicle_age. Si None, usa año actual.
    
    Examples
    --------
    >>> fe = FeatureEngineer(current_year=2024)
    >>> df_transformed = fe.fit_transform(df)
    >>> print(df_transformed.columns)
    # Incluye: vehicle_age, brand (derivadas de model_year y model)
    """

    def __init__(self, current_year: Optional[int] = None):
        self.current_year = current_year

    def fit(self, X: pd.DataFrame, y: pd.DataFrame = None) -> "FeatureEngineer":
        """Fit no hace nada (stateless transformer)."""
        # Este transformer es stateless: no aprende nada de los datos
        # Solo necesita fit() para ser compatible con Pipeline
        return self

    def transform(self, X: pd.DataFrame) -> pd.DataFrame:
        """Aplica feature engineering.
        
        Features creadas:
        - vehicle_age: current_year - model_year
        - brand: primera palabra de model
        - price_per_mile: price / odometer (solo si price existe)
        """
        X = X.copy()  # ← Nunca modificar el input original

        # Usar año configurado o año actual
        year = self.current_year or pd.Timestamp.now().year

        # Feature: Edad del vehículo
        if "model_year" in X.columns:
            X["vehicle_age"] = year - X["model_year"]

        # Feature: Marca (primera palabra del modelo)
        if "model" in X.columns:
            X["brand"] = X["model"].astype(str).str.split().str[0]

        # Features derivadas (solo en training, no en inferencia)
        # Porque price no está disponible en inferencia
        if "odometer" in X.columns and "price" in X.columns:
            X["price_per_mile"] = X["price"] / (X["odometer"] + 1)

        return X
    
    # Métodos opcionales para mejor introspección
    def get_feature_names_out(self, input_features=None):
        """Retorna nombres de features de salida."""
        base = list(input_features) if input_features else []
        return base + ["vehicle_age", "brand"]
```

### Ejemplo 2: ResampleClassifier (BankChurn)

```python
# src/bankchurn/models.py - Código REAL del portafolio

from __future__ import annotations

import numpy as np
import pandas as pd
from sklearn.base import BaseEstimator, ClassifierMixin
from sklearn.utils.validation import check_is_fitted


class ResampleClassifier(BaseEstimator, ClassifierMixin):
    """Custom classifier with resampling for imbalanced datasets.
    
    Implementa oversampling (SMOTE), undersampling, y class weighting
    para mejorar performance en clasificación desbalanceada.
    
    Este wrapper permite:
    1. Probar diferentes estrategias de resampling fácilmente
    2. Mantener la interfaz sklearn estándar (fit/predict)
    3. Ser parte de un Pipeline (incluyendo GridSearchCV)
    
    Parameters
    ----------
    estimator : estimator object, optional
        Clasificador base. Si None, usa LogisticRegression.
    strategy : {"none", "oversample", "undersample", "class_weight"}
        Estrategia de resampling:
        - "none": Sin resampling
        - "oversample": SMOTE oversampling de clase minoritaria
        - "undersample": Undersampling de clase mayoritaria
        - "class_weight": Balanceo automático de pesos
    random_state : int, default=42
        Semilla para reproducibilidad.
    
    Examples
    --------
    >>> clf = ResampleClassifier(
    ...     estimator=RandomForestClassifier(),
    ...     strategy="oversample",
    ...     random_state=42
    ... )
    >>> clf.fit(X_train, y_train)
    >>> predictions = clf.predict(X_test)
    """

    def __init__(
        self,
        estimator: BaseEstimator | None = None,
        strategy: str = "none",
        random_state: int = 42,
    ) -> None:
        self.estimator = estimator
        self.strategy = strategy
        self.random_state = random_state

    def fit(self, X: np.ndarray, y: np.ndarray) -> "ResampleClassifier":
        """Entrena el clasificador con resampling opcional."""
        from sklearn.linear_model import LogisticRegression

        # Inicializar estimador si no se proporcionó
        if self.estimator is None:
            self.estimator_ = LogisticRegression(random_state=self.random_state)
        else:
            # Clonar para no modificar el original
            from sklearn.base import clone
            self.estimator_ = clone(self.estimator)

        # Guardar clases (requerido por sklearn)
        self.classes_ = np.unique(y)

        # Aplicar estrategia de resampling
        X_resampled, y_resampled = self._apply_resampling(X, y)

        # Entrenar estimador base
        self.estimator_.fit(X_resampled, y_resampled)

        return self

    def _apply_resampling(
        self, X: np.ndarray, y: np.ndarray
    ) -> tuple[np.ndarray, np.ndarray]:
        """Aplica la estrategia de resampling."""
        if self.strategy == "none":
            return X, y
        
        elif self.strategy == "oversample":
            try:
                from imblearn.over_sampling import SMOTE
                smote = SMOTE(random_state=self.random_state)
                return smote.fit_resample(X, y)
            except ImportError:
                # Si imblearn no está instalado, ignorar
                return X, y
        
        elif self.strategy == "undersample":
            try:
                from imblearn.under_sampling import RandomUnderSampler
                rus = RandomUnderSampler(random_state=self.random_state)
                return rus.fit_resample(X, y)
            except ImportError:
                return X, y
        
        elif self.strategy == "class_weight":
            # No modifica datos, el estimador maneja los pesos
            if hasattr(self.estimator_, 'class_weight'):
                self.estimator_.set_params(class_weight='balanced')
            return X, y
        
        else:
            raise ValueError(f"Unknown strategy: {self.strategy}")

    def predict(self, X: np.ndarray) -> np.ndarray:
        """Predice clases."""
        check_is_fitted(self, ['estimator_', 'classes_'])
        return self.estimator_.predict(X)

    def predict_proba(self, X: np.ndarray) -> np.ndarray:
        """Predice probabilidades."""
        check_is_fitted(self, ['estimator_', 'classes_'])
        return self.estimator_.predict_proba(X)
```

### La Plantilla: Crea Tu Propio Transformer

```python
from sklearn.base import BaseEstimator, TransformerMixin

class MiTransformer(BaseEstimator, TransformerMixin):
    """
    Plantilla para crear transformers custom.
    
    REGLAS IMPORTANTES:
    1. __init__ solo guarda parámetros (no computa nada)
    2. fit() aprende de los datos (puede ser no-op)
    3. transform() aplica la transformación
    4. Nunca modificar input, siempre X.copy()
    """
    
    def __init__(self, param1: str = "default", param2: int = 10):
        # Solo guardar parámetros, NO computar nada
        self.param1 = param1
        self.param2 = param2
    
    def fit(self, X, y=None):
        """Aprende de los datos (opcional).
        
        Ejemplos de qué aprender:
        - Media/std para normalización
        - Vocabulario para encoding
        - Umbrales para binning
        """
        # Si el transformer es stateless, solo retorna self
        # Si aprende algo:
        # self.learned_param_ = compute_something(X)
        return self
    
    def transform(self, X):
        """Aplica la transformación."""
        X = X.copy()  # ← Siempre copiar
        # ... tu lógica de transformación ...
        return X
```

---

<a id="74-pipeline-completo-codigo-real"></a>

## 7.4 Pipeline Completo: Código Real

### CarVision: El Pipeline de 3 Etapas

```python
# src/carvision/training.py - Pipeline REAL del portafolio

from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.ensemble import RandomForestRegressor

from src.carvision.features import FeatureEngineer

def build_pipeline(cfg: dict) -> Pipeline:
    """Construye el pipeline completo de CarVision.
    
    Estructura: Features → Preprocessing → Model
    
    Esta arquitectura de 3 etapas garantiza:
    1. Feature engineering consistente (FeatureEngineer)
    2. Preprocesamiento apropiado por tipo de columna (ColumnTransformer)
    3. Modelo entrenado con datos correctamente transformados
    """
    # Parámetros de configuración
    num_cols = cfg["preprocessing"]["numeric_features"]
    cat_cols = cfg["preprocessing"]["categorical_features"]
    dataset_year = cfg.get("dataset_year", 2024)
    rf_params = cfg["training"].get("random_forest_params", {})
    
    # Etapa 1: Feature Engineering
    feature_engineer = FeatureEngineer(current_year=dataset_year)
    
    # Etapa 2: Preprocessing (después de feature engineering)
    # Nota: Las columnas aquí son las que EXISTEN después del FeatureEngineer
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', Pipeline([
                ('imputer', SimpleImputer(strategy='median')),
                ('scaler', StandardScaler())
            ]), num_cols),
            ('cat', Pipeline([
                ('imputer', SimpleImputer(strategy='most_frequent')),
                ('encoder', OneHotEncoder(handle_unknown='ignore', sparse_output=False))
            ]), cat_cols)
        ],
        remainder='drop'
    )
    
    # Etapa 3: Modelo
    model = RandomForestRegressor(**rf_params)
    
    # Pipeline completo: Una sola unidad entrenable/guardable
    pipeline = Pipeline([
        ('features', feature_engineer),    # Crea vehicle_age, brand
        ('pre', preprocessor),              # Escala y encoda
        ('model', model)                    # Predice
    ])
    
    return pipeline


# === USO ===
# Entrenamiento
pipeline = build_pipeline(config)
pipeline.fit(X_train, y_train)

# Guardar TODO junto
joblib.dump(pipeline, "artifacts/model.joblib")

# Producción
pipeline = joblib.load("artifacts/model.joblib")
price = pipeline.predict(X_new)  # Una llamada hace TODO
```

### BankChurn: Pipeline con Ensemble

```python
# src/bankchurn/training.py - Pipeline REAL del portafolio

def build_pipeline(self) -> Pipeline:
    """Construye el pipeline de BankChurn.
    
    Estructura:
    - Preprocessing: ColumnTransformer (num + cat)
    - Model: VotingClassifier o ResampleClassifier
    """
    # Columnas desde config
    num_cols = self.config.data.numerical_features
    cat_cols = self.config.data.categorical_features
    
    # Preprocessing
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', Pipeline([
                ('imputer', SimpleImputer(strategy='median')),
                ('scaler', StandardScaler())
            ]), num_cols),
            ('cat', Pipeline([
                ('imputer', SimpleImputer(strategy='constant', fill_value='Unknown')),
                ('encoder', OneHotEncoder(handle_unknown='ignore'))
            ]), cat_cols)
        ]
    )
    
    # Modelo: Ensemble o single model
    if self.config.model.type == "ensemble":
        model = VotingClassifier(
            estimators=[
                ('lr', LogisticRegression(
                    **self.config.model.logistic_regression.dict()
                )),
                ('rf', RandomForestClassifier(
                    **self.config.model.random_forest.dict()
                ))
            ],
            voting=self.config.model.ensemble.voting,
            weights=self.config.model.ensemble.weights
        )
    else:
        # Con wrapper de resampling
        model = ResampleClassifier(
            estimator=RandomForestClassifier(
                **self.config.model.random_forest.dict()
            ),
            strategy=self.config.model.resampling_strategy,
            random_state=self.random_state
        )
    
    # Pipeline final
    return Pipeline([
        ('preprocessor', preprocessor),
        ('model', model)
    ])
```

---

<a id="75-ejercicios-practicos"></a>

## 7.5 Ejercicios Prácticos

### Ejercicio 1: Construir un ColumnTransformer

```python
# Datos de telecom:
# - calls: float (numérico)
# - minutes: float (numérico)
# - messages: int (numérico)
# - mb_used: float (numérico)
# - plan_type: str (categórico) - "basic", "premium"
# - region: str (categórico) - "north", "south", "east", "west"

# Tu tarea: Crea un ColumnTransformer que:
# 1. Escale las columnas numéricas con StandardScaler
# 2. Encode las columnas categóricas con OneHotEncoder
# 3. Maneje valores faltantes apropiadamente

num_cols = ["calls", "minutes", "messages", "mb_used"]
cat_cols = ["plan_type", "region"]

# Escribe tu código aquí:
preprocessor = ColumnTransformer(
    # ...
)
```

<details>
<summary>📝 Ver Solución</summary>

```python
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer

num_cols = ["calls", "minutes", "messages", "mb_used"]
cat_cols = ["plan_type", "region"]

preprocessor = ColumnTransformer(
    transformers=[
        ('num', Pipeline([
            ('imputer', SimpleImputer(strategy='median')),
            ('scaler', StandardScaler())
        ]), num_cols),
        ('cat', Pipeline([
            ('imputer', SimpleImputer(strategy='most_frequent')),
            ('encoder', OneHotEncoder(handle_unknown='ignore', sparse_output=False))
        ]), cat_cols)
    ],
    remainder='drop'
)

# Verificar
print(f"Transformers: {[t[0] for t in preprocessor.transformers]}")
# Output: ['num', 'cat']
```

</details>

---

### Ejercicio 2: Crear un Custom Transformer

```python
# Tu tarea: Crea un transformer que calcule ratios de uso de telecom
# 
# Features a crear:
# - minutes_per_call = minutes / (calls + 1)
# - mb_per_message = mb_used / (messages + 1)
# - total_usage = calls + messages + (mb_used / 1000)
#
# Requisitos:
# - Debe heredar de BaseEstimator y TransformerMixin
# - fit() debe retornar self
# - transform() debe retornar DataFrame con nuevas columnas

from sklearn.base import BaseEstimator, TransformerMixin

class TelecomFeatureEngineer(BaseEstimator, TransformerMixin):
    # Tu código aquí
    pass
```

<details>
<summary>📝 Ver Solución</summary>

```python
from sklearn.base import BaseEstimator, TransformerMixin
import pandas as pd


class TelecomFeatureEngineer(BaseEstimator, TransformerMixin):
    """Feature engineering para datos de telecom."""
    
    def __init__(self):
        pass
    
    def fit(self, X: pd.DataFrame, y=None):
        """No aprende nada (stateless)."""
        return self
    
    def transform(self, X: pd.DataFrame) -> pd.DataFrame:
        """Crea features derivadas."""
        X = X.copy()
        
        # Minutos por llamada
        if "minutes" in X.columns and "calls" in X.columns:
            X["minutes_per_call"] = X["minutes"] / (X["calls"] + 1)
        
        # MB por mensaje
        if "mb_used" in X.columns and "messages" in X.columns:
            X["mb_per_message"] = X["mb_used"] / (X["messages"] + 1)
        
        # Uso total normalizado
        if all(col in X.columns for col in ["calls", "messages", "mb_used"]):
            X["total_usage"] = X["calls"] + X["messages"] + (X["mb_used"] / 1000)
        
        return X
    
    def get_feature_names_out(self, input_features=None):
        """Retorna nombres de features creadas."""
        return ["minutes_per_call", "mb_per_message", "total_usage"]


# Verificar
import pandas as pd

df = pd.DataFrame({
    "calls": [50, 100],
    "minutes": [200, 500],
    "messages": [100, 50],
    "mb_used": [5000, 10000]
})

fe = TelecomFeatureEngineer()
df_transformed = fe.fit_transform(df)
print(df_transformed.columns.tolist())
# Output incluye: minutes_per_call, mb_per_message, total_usage
```

</details>

---

### Ejercicio 3: Pipeline Completo para TelecomAI

```python
# Tu tarea: Construye un pipeline completo para TelecomAI
# 
# Estructura:
# 1. TelecomFeatureEngineer (del ejercicio anterior)
# 2. ColumnTransformer para preprocessing
# 3. LogisticRegression como modelo
#
# El pipeline debe ser guardable con joblib

# Tu código aquí:
def build_telecom_pipeline():
    pass
```

<details>
<summary>📝 Ver Solución</summary>

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
import joblib


def build_telecom_pipeline(config: dict = None) -> Pipeline:
    """Construye pipeline completo para TelecomAI."""
    
    # Configuración por defecto
    if config is None:
        config = {
            "num_cols": ["calls", "minutes", "messages", "mb_used", 
                        "minutes_per_call", "mb_per_message", "total_usage"],
            "cat_cols": [],
            "random_state": 42
        }
    
    num_cols = config["num_cols"]
    cat_cols = config.get("cat_cols", [])
    
    # Etapa 1: Feature Engineering
    feature_engineer = TelecomFeatureEngineer()
    
    # Etapa 2: Preprocessing
    transformers = [
        ('num', Pipeline([
            ('imputer', SimpleImputer(strategy='median')),
            ('scaler', StandardScaler())
        ]), num_cols)
    ]
    
    if cat_cols:
        transformers.append(
            ('cat', Pipeline([
                ('imputer', SimpleImputer(strategy='most_frequent')),
                ('encoder', OneHotEncoder(handle_unknown='ignore'))
            ]), cat_cols)
        )
    
    preprocessor = ColumnTransformer(
        transformers=transformers,
        remainder='drop'
    )
    
    # Etapa 3: Modelo
    model = LogisticRegression(
        random_state=config.get("random_state", 42),
        max_iter=1000
    )
    
    # Pipeline completo
    pipeline = Pipeline([
        ('features', feature_engineer),
        ('preprocessor', preprocessor),
        ('model', model)
    ])
    
    return pipeline


# Uso
pipeline = build_telecom_pipeline()
# pipeline.fit(X_train, y_train)
# joblib.dump(pipeline, "artifacts/model.joblib")
```

</details>

---

<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en sklearn Pipelines

Los errores en este módulo rara vez son “fallos exóticos” del algoritmo; casi siempre son **desalineaciones** entre datos, columnas, transformers y cómo guardas/cargas el pipeline.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) `ValueError: number of features does not match` (mismatch entre train e inference)

**Síntomas típicos**

- En entrenamiento todo bien, pero al predecir obtienes:
  ```text
  ValueError: X has 15 features, but StandardScaler is expecting 12 features as input.
  ```
- O bien errores de índice similares en `OneHotEncoder`.

**Cómo identificarlo**

- Verifica que usas **el mismo pipeline serializado** en training e inference:
  - ¿Guardas y cargas `pipeline.pkl`/`model.joblib`, o solo el modelo suelto?
- Comprueba que las columnas de entrada en producción tienen el mismo orden y nombres que en entrenamiento.

**Cómo corregirlo**

- En el portafolio, **siempre** serializa el pipeline completo:
  ```python
  joblib.dump(pipeline, "artifacts/model.joblib")
  pipeline = joblib.load("artifacts/model.joblib")
  ```
- Asegúrate de que el orden y nombres de columnas que construyes en la API/Streamlit coincidan con las listas `num_cols` y `cat_cols` del pipeline.

---

### 2) Data leakage por features que usan el target (especialmente en CarVision)

**Síntomas típicos**

- Métricas en training/validation son **sospechosamente altas**, pero en producción caen.
- Features como `price_per_mile` o `price_category` dependen de la variable objetivo (`price`).

**Cómo identificarlo**

- Examina tu `FeatureEngineer` y lista de columnas que entran al modelo:
  - ¿Estás incluyendo columnas derivadas del target en el `ColumnTransformer`?
- Revisa tu config (`cfg["preprocessing"]["numeric_features"]`, etc.) y confirma que solo incluyes features válidos.

**Cómo corregirlo**

- Asegúrate de que features que dependen del target **no** se usen como input del modelo.
- En CarVision, por ejemplo, `price_per_mile` y `price_category` se calculan solo para análisis, pero se excluyen de `num_cols` para el pipeline.

---

### 3) Custom transformers que modifican el input in-place o no respetan la API sklearn

**Síntomas típicos**

- Errores del tipo:
  ```text
  TypeError: __init__() takes 1 positional argument but 2 were given
  ```
  o
  ```text
  AttributeError: 'MiTransformer' object has no attribute 'fit'
  ```
- Comportamientos raros donde un transformer “ensucia” los datos para otros steps.

**Cómo identificarlo**

- Revisa que tu transformer:
  - Herede de `BaseEstimator` y `TransformerMixin`.
  - Tenga `__init__`, `fit`, `transform` con las firmas estándar.
  - Use `X = X.copy()` dentro de `transform`.

**Cómo corregirlo**

- Usa la plantilla de este módulo (`MiTransformer`) como referencia.
- Evita lógica pesada en `__init__`; ahí solo se guardan parámetros.
- Añade tests unitarios simples (`fit_transform` sobre un `DataFrame` pequeño) para validar que mantiene columnas esperadas.

---

### 4) Pipelines diferentes en training y en la API

**Síntomas típicos**

- El pipeline usado en `training.py` no coincide con el que se monta en `fastapi_app.py` o `streamlit_app.py`.
- Bugs donde la API aplica transformaciones manuales **además** del pipeline.

**Cómo identificarlo**

- Busca en el proyecto si estás construyendo pipelines duplicados:
  - En CarVision, la única fuente de verdad debe ser `build_pipeline` en `src/carvision/training.py`.
  - La API y Streamlit solo deberían **cargar** el pipeline serializado, no recrearlo a mano.

**Cómo corregirlo**

- Centraliza la construcción del pipeline en una función (`build_pipeline` / `build_telecom_pipeline`).
- En la API/Streamlit, no replicar lógicas de preprocesado; limitarse a cargar y usar el pipeline.

---

### 5) Patrón general de debugging para pipelines

1. **Reproduce el error** con un input mínimo (1–2 filas de `DataFrame`).
2. **Inspecciona shapes y columnas** tras cada etapa:
   - Usa `pipeline.named_steps["pre"].transform(X_sample)` o similares.
3. **Verifica la serialización**: guarda, vuelve a cargar, y compara predicciones en un mismo batch.
4. **Conecta el problema** con el concepto del módulo:
   - Training-serving skew → pipeline parcial o mal serializado.
   - Mismatch de columnas → listas `num_cols`/`cat_cols` desincronizadas.
   - Transformers rotos → no respetan `fit`/`transform`.

Con este enfoque, los pipelines dejan de ser una “caja negra mágica” y se convierten en una línea de ensamblaje transparente y depurable.

----

<a id="checkpoint"></a>

## ✅ Checkpoint: ¿Completaste el Módulo?

### Checklist
- [ ] Sabes usar ColumnTransformer para diferentes tipos de columnas
- [ ] Puedes crear un Custom Transformer con fit/transform
- [ ] Has construido un pipeline de 3 etapas (features → preprocessing → model)
- [ ] Puedes guardar y cargar un pipeline completo con joblib

---

## 🔗 ADR: Decisiones de Arquitectura

### ADR-007: Pipeline Unificado Obligatorio

**Contexto**: Transformaciones separadas causan inconsistencias en producción.

**Decisión**: Todo el flujo (features → preprocessing → model) debe estar en un solo Pipeline.

**Consecuencias**:
- ✅ Una sola serialización guarda todo
- ✅ Imposible olvidar una transformación
- ✅ Reproducibilidad garantizada
- ❌ Más complejo de debuggear (caja negra)
- ❌ Requiere entender sklearn profundamente

### ADR-008: Custom Transformers para Feature Engineering

**Contexto**: sklearn no tiene transformers para lógica de negocio específica.

**Decisión**: Crear FeatureEngineer como TransformerMixin.

**Consecuencias**:
- ✅ Reutilizable en train, API, y dashboard
- ✅ Testeable unitariamente
- ✅ Documentación clara de features derivadas
- ❌ Más código que escribir
- ❌ Requiere entender BaseEstimator/TransformerMixin

---

## 📦 Cómo se Usó en el Portafolio

Los pipelines sklearn son el corazón de los 3 proyectos del portafolio:

### Pipeline Unificado de BankChurn

```python
# BankChurn-Predictor/src/bankchurn/pipeline.py (estructura real)
def build_pipeline(config: BankChurnConfig) -> Pipeline:
    """Pipeline completo de 3 etapas."""
    return Pipeline([
        ('preprocessor', ColumnTransformer([
            ('num', Pipeline([
                ('imputer', SimpleImputer(strategy='median')),
                ('scaler', StandardScaler())
            ]), config.data.numerical_features),
            ('cat', Pipeline([
                ('imputer', SimpleImputer(strategy='constant', fill_value='missing')),
                ('encoder', OneHotEncoder(handle_unknown='ignore'))
            ]), config.data.categorical_features)
        ])),
        ('model', get_model(config))
    ])
```

### FeatureEngineer de CarVision

```python
# CarVision-Market-Intelligence/src/carvision/features.py
class FeatureEngineer(BaseEstimator, TransformerMixin):
    """Custom transformer para features de autos."""
    
    def __init__(self, current_year: int = None):
        self.current_year = current_year
    
    def fit(self, X, y=None):
        return self
    
    def transform(self, X):
        X = X.copy()
        # vehicle_age, brand, mileage_category, etc.
        return X
```

### Archivos Clave por Proyecto

| Proyecto | Pipeline | Features | Artefacto |
|----------|----------|----------|-----------|
| BankChurn | `src/bankchurn/pipeline.py` | En preprocessor | `artifacts/pipeline.joblib` |
| CarVision | `src/carvision/pipeline.py` | `src/carvision/features.py` | `artifacts/pipeline.joblib` |
| TelecomAI | `src/telecomai/training.py` | En pipeline | `artifacts/model.joblib` |

### 🔧 Ejercicio: Explora los Pipelines Reales

```bash
# 1. Ve a BankChurn y carga el pipeline
cd BankChurn-Predictor
python -c "
import joblib
pipe = joblib.load('artifacts/pipeline.joblib')
print('Steps:', [name for name, _ in pipe.steps])
print('Preprocessor:', pipe.named_steps['preprocessor'])
"

# 2. Inspecciona el FeatureEngineer de CarVision
cat CarVision-Market-Intelligence/src/carvision/features.py
```

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **¿Por qué Pipelines?**: Evitan data leakage, garantizan reproducibilidad, simplifican deployment.

2. **Custom Transformers**: Demuestra que puedes crear transformadores con `fit()` y `transform()`.

3. **ColumnTransformer**: Explica cómo aplicar diferentes transformaciones a diferentes columnas.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Features nuevas | Añade transformadores al pipeline, no código suelto |
| Debugging | Usa `pipeline.named_steps` para inspeccionar etapas |
| Producción | Serializa el pipeline completo, no solo el modelo |
| Testing | Testea cada transformador individualmente |

### Patrones Avanzados

- **FeatureUnion**: Combinar features de diferentes fuentes
- **Pipeline dentro de Pipeline**: Para transformaciones complejas
- **make_pipeline**: Sintaxis simplificada sin nombres
- **clone**: Para cross-validation sin modificar original


---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **Sklearn Pipeline Tutorial** | Data School | 28 min | [YouTube](https://www.youtube.com/watch?v=irHhDMbw3xo) |
| 🔴 | **ColumnTransformer Explained** | Data School | 35 min | [YouTube](https://www.youtube.com/watch?v=NGq8wnH5VSo) |
| 🟡 | **Custom Transformers in Sklearn** | PyData | 32 min | [YouTube](https://www.youtube.com/watch?v=BFaadIqWlAg) |
| 🟢 | **Sklearn Pipeline Best Practices** | PyData Berlin | 45 min | [YouTube](https://www.youtube.com/watch?v=0UWXCAYn8rk) |

### 📚 Cursos

| 🏷️ | Título | Plataforma | Duración | Link |
|:--:|:-------|:-----------|:--------:|:-----|
| 🔴 | ML Pipelines with scikit-learn | DataCamp | 4h | [DataCamp](https://www.datacamp.com/courses/machine-learning-with-scikit-learn) |
| 🟡 | Feature Engineering for ML | Coursera (Google) | 5 weeks | [Coursera](https://www.coursera.org/learn/feature-engineering) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [sklearn Pipeline User Guide](https://scikit-learn.org/stable/modules/compose.html) | Guía oficial de pipelines |
| 🟡 | [Custom Transformers](https://scikit-learn.org/stable/developers/develop.html) | Cómo crear transformers custom |

---

## ⚖️ Decisión Técnica: ADR-002 scikit-learn

**Contexto**: Necesitamos un framework ML para clasificación/regresión tabular.

**Decisión**: Usar scikit-learn como framework principal.

**Alternativas Consideradas**:
- **XGBoost/LightGBM**: Más performance, menos integración con pipelines
- **PyTorch**: Overkill para datos tabulares

**Consecuencias**:
- ✅ Pipelines unificados con `Pipeline` y `ColumnTransformer`
- ✅ Fácil de testear y serializar
- ✅ Documentación excelente
- ❌ Menos performance que gradient boosting dedicado

---

## 🔧 Ejercicios del Módulo

### Ejercicio 7.1: Pipeline Básico
**Objetivo**: Crear un pipeline con preprocesamiento.
**Dificultad**: ⭐⭐

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier

# TU TAREA: Crear pipeline con:
# 1. StandardScaler para features numéricas
# 2. RandomForestClassifier

pipe = Pipeline([
    # TU CÓDIGO
])
```

<details>
<summary>💡 Ver solución</summary>

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier

pipe = Pipeline([
    ('scaler', StandardScaler()),
    ('classifier', RandomForestClassifier(
        n_estimators=100,
        random_state=42
    ))
])

# Uso:
pipe.fit(X_train, y_train)
predictions = pipe.predict(X_test)

# Serialización:
import joblib
joblib.dump(pipe, 'artifacts/pipeline.joblib')
```
</details>

---

### Ejercicio 7.2: ColumnTransformer
**Objetivo**: Procesar columnas numéricas y categóricas por separado.
**Dificultad**: ⭐⭐⭐

```python
# Dado un DataFrame con:
# - numeric_cols = ['age', 'balance', 'salary']
# - categorical_cols = ['geography', 'gender']

# TU TAREA: Crear ColumnTransformer que:
# - Aplique StandardScaler a numéricas
# - Aplique OneHotEncoder a categóricas

from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder

preprocessor = ColumnTransformer([
    # TU CÓDIGO
])
```

<details>
<summary>💡 Ver solución</summary>

```python
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer

numeric_cols = ['age', 'balance', 'salary']
categorical_cols = ['geography', 'gender']

# Pipelines individuales para cada tipo
numeric_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='median')),
    ('scaler', StandardScaler())
])

categorical_transformer = Pipeline([
    ('imputer', SimpleImputer(strategy='constant', fill_value='missing')),
    ('encoder', OneHotEncoder(handle_unknown='ignore'))
])

# ColumnTransformer combina ambos
preprocessor = ColumnTransformer([
    ('num', numeric_transformer, numeric_cols),
    ('cat', categorical_transformer, categorical_cols)
])

# Pipeline completo con modelo
full_pipeline = Pipeline([
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier(random_state=42))
])
```
</details>

---

### Ejercicio 7.3: Custom Transformer
**Objetivo**: Crear un transformer personalizado.
**Dificultad**: ⭐⭐⭐

```python
from sklearn.base import BaseEstimator, TransformerMixin

# TU TAREA: Crear AgeGroupTransformer que:
# - Añada columna 'age_group' basada en rangos de edad
# - 0-30: 'young', 31-50: 'middle', 51+: 'senior'

class AgeGroupTransformer(BaseEstimator, TransformerMixin):
    def fit(self, X, y=None):
        # TU CÓDIGO
        return self
    
    def transform(self, X):
        # TU CÓDIGO
        pass
```

<details>
<summary>💡 Ver solución</summary>

```python
import pandas as pd
import numpy as np
from sklearn.base import BaseEstimator, TransformerMixin

class AgeGroupTransformer(BaseEstimator, TransformerMixin):
    """Transformer que añade categoría de edad."""
    
    def __init__(self, age_column: str = 'age'):
        self.age_column = age_column
    
    def fit(self, X, y=None):
        # No hay nada que aprender
        return self
    
    def transform(self, X):
        X = X.copy()
        
        # Crear bins de edad
        bins = [0, 30, 50, np.inf]
        labels = ['young', 'middle', 'senior']
        
        X['age_group'] = pd.cut(
            X[self.age_column],
            bins=bins,
            labels=labels
        )
        return X
    
    def get_feature_names_out(self, input_features=None):
        """Para compatibilidad con sklearn >= 1.0"""
        return list(input_features) + ['age_group']


# Uso en pipeline:
pipeline = Pipeline([
    ('age_groups', AgeGroupTransformer(age_column='age')),
    ('preprocessor', preprocessor),
    ('classifier', RandomForestClassifier())
])
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **Pipeline** | Cadena de transformaciones + modelo que se serializa como unidad |
| **ColumnTransformer** | Aplica diferentes transformaciones a diferentes columnas en paralelo |
| **Data Leakage** | Filtración de información del target al training, causando métricas infladas |
| **fit_transform** | Método que aprende parámetros y transforma en un solo paso |

---

<div align="center">

**Siguiente módulo** → [08. Ingeniería de Features](08_INGENIERIA_FEATURES.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
