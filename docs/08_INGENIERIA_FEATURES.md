# 08. Ingeniería de Features para ML

## 🎯 Objetivo del Módulo

Dominar la creación de features sin introducir **data leakage**, el error más peligroso y difícil de detectar en ML.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  🚨 DATA LEAKAGE: El Asesino Silencioso de Modelos                           ║
║                                                                              ║
║  Tu modelo tiene 99% accuracy en validación...                               ║
║  ...pero 50% en producción.                                                  ║
║                                                                              ║
║  ¿Por qué? Porque durante el entrenamiento, el modelo "vio" información      ║
║  que NO tendrá disponible cuando haga predicciones reales.                   ║
║                                                                              ║
║  Es como estudiar para un examen con las respuestas en la mano.              ║
║  Sacas 100 en el examen de práctica, pero 0 en el real.                      ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

<a id="00-prerrequisitos"></a>

## 0.0 Prerrequisitos

- Haber completado **[07_SKLEARN_PIPELINES](07_SKLEARN_PIPELINES.md)** (pipelines unificados, serialización).
- Entender que un score alto en validación puede ser **engañoso** si hay leakage.
- Tener claro cuál es tu *target* por proyecto (BankChurn: churn, CarVision: price, Telecom: churn/upsell).

---

<a id="01-protocolo-e-como-estudiar-este-modulo"></a>

## 0.1 🧠 Protocolo E: Cómo estudiar este módulo

- **Antes de crear features**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define tu *output mínimo* (ej: lista de features seguras + reglas anti-leakage).
- **Mientras depuras leakage**: si te atoras >15 min (métricas irreales, features sospechosas, splits temporales), registra el caso en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
- **Al cerrar la semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para auditar tu dataset y tu pipeline de features.

---

<a id="02-entregables-verificables-minimo-viable"></a>

## 0.2 ✅ Entregables verificables (mínimo viable)

Al terminar este módulo, deberías poder mostrar (en al menos 1 proyecto del portafolio):

- [ ] **Checklist anti-leakage** aplicada (qué se permite / qué se prohíbe).
- [ ] **Features seguras** integradas dentro del pipeline (no código suelto).
- [ ] **Evidencia**: explicación breve de por qué tus features no usan información del target/futuro.

---

<a id="03-puente-teoria-codigo-portafolio"></a>

## 0.3 🧩 Puente teoría ↔ código (Portafolio)

Para que esto cuente como progreso real, fuerza este mapeo:

- **Concepto**: leakage (target/temporal/contaminación)
- **Archivo**: `src/<paquete>/features.py`, `src/<paquete>/training.py`, `configs/*.yaml`
- **Prueba**: comparar métricas con/ sin feature sospechosa y justificar la decisión.

---

## 📋 Contenido

 - **0.0** [Prerrequisitos](#00-prerrequisitos)
 - **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
 - **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
 - **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
 1. [¿Qué es Data Leakage?](#81-que-es-data-leakage)
 2. [Tipos de Leakage en ML](#82-tipos-de-leakage)
 3. [Caso Real: CarVision](#83-caso-real-carvision)
 4. [Prevención con Pipelines](#84-prevencion-con-pipelines)
 5. [Feature Engineering Seguro](#85-feature-engineering-seguro)
 6. [✅ Checkpoint](#checkpoint)

---

<a id="81-que-es-data-leakage"></a>

## 8.1 ¿Qué es Data Leakage?

### La Analogía del Detective

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  🔍 IMAGINA UN DETECTIVE RESOLVIENDO UN CASO:                             ║
║                                                                           ║
║  SIN LEAKAGE (correcto):                                                  ║
║  • El detective solo tiene las pistas disponibles AL MOMENTO del crimen   ║
║  • Debe deducir quién es el culpable con información limitada             ║
║  • Es difícil, pero es la realidad                                        ║
║                                                                           ║
║  CON LEAKAGE (trampa):                                                    ║
║  • El detective tiene acceso al informe FINAL del caso                    ║
║  • Ya sabe quién es el culpable antes de investigar                       ║
║  • "Resuelve" el caso fácilmente, pero no aprendió nada                   ║
║                                                                           ║
║  EN ML:                                                                   ║
║  • El modelo debe predecir usando SOLO información disponible             ║
║    en el momento de la predicción                                         ║
║  • Si usas información del futuro o del target, es TRAMPA                 ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Ejemplo Clásico: Predecir Precio con precio_per_mile

```python
# ❌ LEAKAGE: Usando feature derivada del target

# Datos originales
df = pd.DataFrame({
    'price': [15000, 25000, 35000],      # Target a predecir (lo que queremos estimar).
    'odometer': [80000, 50000, 20000],   # Feature legítima (disponible en producción).
})

# Feature engineering INCORRECTO
df['price_per_mile'] = df['price'] / df['odometer']  # ← LEAKAGE! Usa el target.

# ¿Por qué es leakage?
# price_per_mile = price / odometer       # La feature CONTIENE información del target.
# Por lo tanto: price = price_per_mile * odometer  # El modelo solo aprende a despejar.
# El modelo "aprende" a multiplicar, no a predecir precios reales.

# En producción:
# - No tienes el price (es lo que quieres predecir)  # No puedes usar lo que no conoces.
# - No puedes calcular price_per_mile               # Feature imposible de crear.
# - El modelo no sabe qué hacer                     # Crash o predicción sin sentido.
```

---

<a id="82-tipos-de-leakage"></a>

## 8.2 Tipos de Leakage

### 1. Target Leakage (Feature contiene información del target)

```python
# ❌ MALO: Feature calculada con el target
df['price_category'] = pd.cut(df['price'], bins=[0, 10000, 50000, inf])  # pd.cut: discretiza valores continuos.

# El modelo aprende: "si price_category es 'alto', predice price alto"  # Correlación perfecta = trampa.
# Pero en producción NO tienes price_category porque no tienes price    # Feature inexistente en inferencia.
```

### 2. Train-Test Contamination (Datos de test "filtrados" a train)

```python
# ❌ MALO: Normalizar ANTES de split
scaler = StandardScaler()             # Crea el scaler.
X_scaled = scaler.fit_transform(X)    # fit_transform en TODO X: aprende mean/std de train+test.
X_train, X_test = train_test_split(X_scaled)  # Split DESPUÉS de transformar.
# El scaler "vio" datos de test durante fit   # Contaminación: test influye en transformación.

# ✅ CORRECTO: Normalizar DESPUÉS de split
X_train, X_test = train_test_split(X)         # Split PRIMERO.
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)  # fit solo en train: aprende mean/std de train.
X_test_scaled = scaler.transform(X_test)        # transform (no fit): usa params de train.
```

### 3. Temporal Leakage (Usar información del futuro)

```python
# ❌ MALO: Predecir churn de enero usando datos de febrero
df['avg_purchases_next_month'] = ...  # Información del futuro: imposible conocerla al predecir.

# ✅ CORRECTO: Solo usar información disponible al momento de predicción
df['avg_purchases_last_3_months'] = ...  # Información del pasado: siempre disponible.
```

---

<a id="83-caso-real-carvision"></a>

## 8.3 Caso Real: CarVision

### El Problema Original

En CarVision, teníamos features que causaban leakage:

```python
# src/carvision/features.py - ANTES (con leakage potencial)

class FeatureEngineer:
    def transform(self, X):
        X = X.copy()
        
        # ✅ OK: vehicle_age no depende del target
        X['vehicle_age'] = 2024 - X['model_year']
        
        # ✅ OK: brand no depende del target
        X['brand'] = X['model'].str.split().str[0]
        
        # ⚠️ PELIGRO: price_per_mile DEPENDE de price (target)
        X['price_per_mile'] = X['price'] / (X['odometer'] + 1)
        
        # ⚠️ PELIGRO: price_category DEPENDE de price (target)
        X['price_category'] = pd.cut(X['price'], ...)
        
        return X
```

### La Solución: drop_columns en Config

```yaml
# configs/config.yaml

preprocessing:
  numeric_features:
    - odometer
    - vehicle_age
  categorical_features:
    - fuel
    - transmission
    - brand
  drop_columns:           # ← Features que causan leakage
    - price_per_mile      # Depende de price
    - price_category      # Depende de price
```

```python
# src/carvision/data.py

def infer_feature_types(df, target, drop_columns=None, ...):
    """Infiere tipos de features, excluyendo las que causan leakage."""
    
    # Columnas a excluir
    exclude = {target}  # Siempre excluir el target
    if drop_columns:
        exclude.update(drop_columns)  # Excluir features con leakage
    
    # Inferir tipos solo de columnas seguras
    for col in df.columns:
        if col in exclude:
            continue  # Saltar columnas peligrosas
        # ... resto de la lógica
```

### ¿Por qué NO eliminamos price_per_mile del FeatureEngineer?

```python
# La feature EXISTE en el transformer, pero se ELIMINA antes del modelo

# Motivo: price_per_mile es útil para ANÁLISIS (no para predicción)
# En el dashboard de Streamlit, usamos price_per_mile para visualizaciones
# Pero en el modelo de predicción, la eliminamos

# Flujo:
# 1. FeatureEngineer crea price_per_mile (para análisis)
# 2. Config especifica drop_columns = [price_per_mile]
# 3. ColumnTransformer NO incluye price_per_mile en sus transformers
# 4. Modelo entrena sin price_per_mile
```

---

<a id="84-prevencion-con-pipelines"></a>

## 8.4 Prevención con Pipelines

### El Pipeline como Barrera Anti-Leakage

```python
# ✅ CORRECTO: Pipeline garantiza orden correcto

from sklearn.pipeline import Pipeline       # Pipeline: encadena pasos de forma segura.
from sklearn.compose import ColumnTransformer  # ColumnTransformer: transforma por grupos de columnas.

# Definir QUÉ columnas usar (excluyendo las peligrosas)
num_cols = ['odometer', 'vehicle_age']      # Features numéricas SEGURAS (sin leakage).
cat_cols = ['fuel', 'transmission', 'brand']  # Features categóricas SEGURAS.

# Pipeline aplica transformaciones EN ORDEN
pipeline = Pipeline([                        # Lista de tuplas (nombre, transformador).
    ('features', FeatureEngineer()),         # Paso 1: crea vehicle_age, brand, etc.
    ('pre', ColumnTransformer([              # Paso 2: transforma solo columnas SEGURAS.
        ('num', StandardScaler(), num_cols), # Escala numéricas (aprende mean/std de train).
        ('cat', OneHotEncoder(), cat_cols)   # One-hot encodes categóricas.
    ])),
    ('model', RandomForestRegressor())       # Paso 3: el modelo.
])

# fit() entrena todo con datos de TRAIN solamente
pipeline.fit(X_train, y_train)               # fit propaga por todos los pasos secuencialmente.

# predict() aplica las MISMAS transformaciones
# usando parámetros aprendidos de TRAIN
predictions = pipeline.predict(X_test)       # predict: transforma X_test con params de train, luego predice.
```

### Diagrama del Flujo Seguro

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     FLUJO ANTI-LEAKAGE CON PIPELINE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ENTRENAMIENTO:                                                             │
│  ┌──────────┐    ┌────────────────┐    ┌────────────┐    ┌──────────┐       │
│  │ X_train  │───►│FeatureEng      │───►│DropDanger  │───►│ Scaler   │       │
│  │          │    │ (crea features)│    │ (elimina   │    │ fit()    │       │
│  └──────────┘    └────────────────┘    │  leakage)  │    └────┬─────┘       │
│                                        └────────────┘         │             │
│                                                               ▼             │
│                                                        ┌──────────┐         │
│                                                        │  Model   │         │
│                                                        │  fit()   │         │
│                                                        └──────────┘         │
│                                                                             │
│  PREDICCIÓN:                                                                │
│  ┌──────────┐    ┌──────────────┐    ┌────────────┐    ┌──────────┐         │
│  │ X_new    │───►│FeatureEng    │───►│DropDanger  │───►│ Scaler   │         │
│  │          │    │ (mismas feat)│    │ (mismas    │    │transform │         │
│  └──────────┘    └──────────────┘    │  columnas) │    │ (NO fit) │         │
│                                      └────────────┘    └────┬─────┘         │
│                                                             │               │
│                                                             ▼               │
│                                                      ┌──────────┐           │
│                                                      │  Model   │           │
│                                                      │ predict()│           │
│                                                      └──────────┘           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

<a id="85-feature-engineering-seguro"></a>

## 8.5 Feature Engineering Seguro

### Checklist Anti-Leakage

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  ✅ CHECKLIST ANTES DE CREAR UNA FEATURE                                  ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  1. ¿Esta feature estará disponible en producción?                        ║
║     □ SÍ → OK                                                             ║
║     □ NO → ❌ NO USAR para predicción                                     ║
║                                                                           ║
║  2. ¿Esta feature usa información del target (directa o indirectamente)?  ║
║     □ NO → OK                                                             ║
║     □ SÍ → ❌ LEAKAGE - eliminar o recalcular sin target                  ║
║                                                                           ║
║  3. ¿Esta feature usa información del futuro?                             ║
║     □ NO → OK                                                             ║
║     □ SÍ → ❌ TEMPORAL LEAKAGE - usar solo datos pasados                  ║
║                                                                           ║
║  4. ¿Las estadísticas de esta feature se calcularon con datos de test?    ║
║     □ NO → OK                                                             ║
║     □ SÍ → ❌ TRAIN-TEST CONTAMINATION - recalcular solo con train        ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Features Seguras vs Peligrosas

| Feature | Segura | Motivo |
|---------|:------:|--------|
| `vehicle_age = 2024 - model_year` | ✅ | No depende del target |
| `brand = model.split()[0]` | ✅ | No depende del target |
| `is_luxury = brand in ['bmw', 'mercedes']` | ✅ | No depende del target |
| `price_per_mile = price / odometer` | ❌ | Usa el target (price) |
| `price_category = cut(price)` | ❌ | Usa el target (price) |
| `avg_price_by_brand` (calculado con todo el dataset) | ❌ | Contamina train/test |

### Código: Feature Engineering Seguro

```python
# src/carvision/features.py - Versión SEGURA

class FeatureEngineer(BaseEstimator, TransformerMixin):
    """Feature engineering sin leakage."""
    
    def __init__(self, current_year: int = None):
        self.current_year = current_year
    
    def fit(self, X, y=None):
        # Stateless: no aprende nada que pueda causar leakage
        return self
    
    def transform(self, X):
        X = X.copy()
        year = self.current_year or pd.Timestamp.now().year
        
        # ✅ SEGURO: Solo usa columnas de entrada (no target)
        if 'model_year' in X.columns:
            X['vehicle_age'] = year - X['model_year']
        
        if 'model' in X.columns:
            X['brand'] = X['model'].astype(str).str.split().str[0]
        
        # ⚠️ CONDICIONAL: Solo crear si price existe (para análisis)
        # El modelo NO usará estas features (drop_columns en config)
        if 'price' in X.columns and 'odometer' in X.columns:
            X['price_per_mile'] = X['price'] / (X['odometer'] + 1)
        
        return X
```

---

<a id="checkpoint"></a>

## ✅ Checkpoint

Si algún punto de esta lista te tomó **>15 minutos** (o te dio un falso positivo de métricas), regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

- [ ] Entiendes qué es data leakage y por qué es peligroso
- [ ] Puedes identificar los 3 tipos de leakage
- [ ] Sabes cómo usar `drop_columns` para eliminar features peligrosas
- [ ] Entiendes por qué el Pipeline previene leakage
- [ ] Puedes aplicar el checklist anti-leakage a nuevas features

---

## 📦 Cómo se Usó en el Portafolio

El proyecto **CarVision** es el ejemplo principal de feature engineering seguro:

### FeatureEngineer Centralizado

```python
# CarVision-Market-Intelligence/src/carvision/features.py
class FeatureEngineer(BaseEstimator, TransformerMixin):
    """Centraliza TODO el feature engineering.
    
    Usado en: training, FastAPI, Streamlit - siempre igual.
    """
    
    def __init__(self, current_year: int = None):
        self.current_year = current_year
    
    def transform(self, X):
        X = X.copy()
        year = self.current_year or pd.Timestamp.now().year
        
        # ✅ Features SEGURAS (no usan target)
        X['vehicle_age'] = year - X['model_year']
        X['brand'] = X['model'].str.split().str[0]
        X['mileage_category'] = pd.cut(X['odometer'], bins=[0, 50000, 100000, float('inf')])
        
        return X
```

### Prevención de Leakage en Config

```yaml
# CarVision-Market-Intelligence/configs/config.yaml
data:
  target_column: price
  drop_columns:
    - price_per_mile    # ❌ Usa target
    - price_category    # ❌ Usa target
    - id                # No predictivo
```

### Caso Real: Bug Corregido

El portafolio tuvo un bug de leakage que fue corregido:

```python
# ❌ ANTES (con leakage)
X['price_per_mile'] = X['price'] / X['odometer']  # Usaba el target!

# ✅ DESPUÉS (sin leakage)
# price_per_mile se elimina en drop_columns
# Solo se calcula para análisis exploratorio, NO para el modelo
```

### Archivos Clave

| Proyecto | Feature Engineering | Anti-Leakage |
|----------|--------------------|--------------| 
| CarVision | `src/carvision/features.py` | `drop_columns` en config |
| BankChurn | En `ColumnTransformer` | Sin features derivadas del target |
| TelecomAI | En pipeline | Sin features peligrosas |

### 🔧 Ejercicio: Audita CarVision

```bash
# 1. Revisa el FeatureEngineer
cat CarVision-Market-Intelligence/src/carvision/features.py

# 2. Verifica drop_columns en config
cat CarVision-Market-Intelligence/configs/config.yaml | grep -A5 "drop_columns"

# 3. Ejecuta tests para verificar que no hay leakage
cd CarVision-Market-Intelligence
pytest tests/test_features.py -v
```

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **Feature Store**: Explica por qué centralizar features mejora consistencia training/serving.

2. **Data Leakage**: Da ejemplos concretos (usar target en features, información del futuro).

3. **Feature Selection**: Conoce métodos (mutual information, RFE, importancia de modelo).

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Features temporales | Cuidado con leakage: no uses info futura |
| Categorías nuevas | Usa `handle_unknown='ignore'` en encoders |
| Features de texto | TF-IDF para baseline, embeddings para avanzado |
| Interacciones | PolynomialFeatures con grado 2 máximo |

### Checklist de Feature Engineering

- [ ] Sin data leakage verificado
- [ ] Transformaciones aplicadas consistentemente train/serve
- [ ] Features documentadas (significado, fuente, transformación)
- [ ] Outliers manejados (clip, winsorize, o flag)
- [ ] Missing values con estrategia clara


---

## 📺 Recursos Externos Recomendados

> Ver [RECURSOS_POR_MODULO.md](RECURSOS_POR_MODULO.md) para la lista completa.

| 🏷️ | Recurso | Tipo |
|:--:|:--------|:-----|
| 🔴 | [Feature Engineering for ML - Krish Naik](https://www.youtube.com/watch?v=6WDFfaYtN6s) | Video |
| 🟡 | [Avoiding Data Leakage](https://www.youtube.com/watch?v=NfOYWZnPK3I) | Video |

---

## 🔗 Referencias del Glosario

Ver [21_GLOSARIO.md](21_GLOSARIO.md) para definiciones de:
- **Data Leakage**: Filtración de información del target
- **Feature Engineering**: Creación de variables predictivas
- **ColumnTransformer**: Procesamiento paralelo de columnas

---

## ✅ Ejercicios

Ver [EJERCICIOS.md](EJERCICIOS.md) - Módulo 08:
- **8.1**: Detectar data leakage
- **8.2**: Pipeline sin leakage

---

<div align="center">

[← sklearn Pipelines](07_SKLEARN_PIPELINES.md) | [Siguiente: Training Profesional →](09_TRAINING_PROFESIONAL.md)

</div>
