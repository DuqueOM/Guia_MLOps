# 🎯 Simulacro de Entrevista Junior ML Engineer
## Portafolio MLOps — 50 Preguntas Fundamentales

**Autor del Portafolio**: Daniel Duque (DuqueOM)  
**Versión**: 1.0  
**Fecha**: Diciembre 2025  
**Nivel**: Junior (0-2 años de experiencia)

---

## 📋 Índice

1. [Python Básico](#1-python-básico-preguntas-1-10)
2. [Machine Learning Fundamentos](#2-machine-learning-fundamentos-preguntas-11-20)
3. [Datos y Preprocesamiento](#3-datos-y-preprocesamiento-preguntas-21-30)
4. [Git y Herramientas](#4-git-y-herramientas-preguntas-31-40)
5. [Práctica con el Portafolio](#5-práctica-con-el-portafolio-preguntas-41-50)

---

## 🎯 Antes de Empezar

### ¿Qué se espera de un Junior?

| Lo que SÍ se espera | Lo que NO se espera |
|---------------------|---------------------|
| Fundamentos sólidos de Python | Diseño de arquitecturas complejas |
| Entender train/test split | Optimización de hiperparámetros avanzada |
| Saber qué es overfitting | Implementar MLOps completo |
| Usar Git básico | CI/CD avanzado |
| Leer y modificar código existente | Escribir código de producción desde cero |
| Hacer preguntas inteligentes | Tener todas las respuestas |

### Consejos para la Entrevista

1. **Sé honesto**: "No lo sé, pero lo investigaría así..." es mejor que inventar
2. **Muestra curiosidad**: Haz preguntas sobre el código que ves
3. **Relaciona con el portafolio**: "En BankChurn aprendí que..."
4. **Piensa en voz alta**: El proceso importa más que la respuesta perfecta

---

# 1. Python Básico (Preguntas 1-10) {#1-python-básico-preguntas-1-10}

## Pregunta 1: Tipos de Datos
**¿Cuál es la diferencia entre lista, tupla y diccionario?**

### Respuesta:
```python
# Lista: mutable, ordenada
features = ["age", "salary", "tenure"]  # Crea lista con 3 strings.
features.append("score")                 # append(): añade elemento al final. Listas son mutables.

# Tupla: inmutable, ordenada
coordinates = (40.7, -74.0)              # Tupla de coordenadas. Paréntesis indican tupla.
# coordinates[0] = 41.0  # ERROR         # TypeError: las tuplas NO se pueden modificar.

# Diccionario: mutable, key-value
customer = {"id": 123, "name": "John", "churn": False}  # Dict: pares clave:valor.
customer["score"] = 0.85                 # Añade nueva clave. Dicts son mutables.
```

**Cuándo usar cada uno**:
- **Lista**: Colección que cambiará (features a seleccionar)
- **Tupla**: Datos que no deben cambiar (coordenadas, constantes)
- **Diccionario**: Acceso por clave (configuración, datos de cliente)

---

## Pregunta 2: List Comprehension
**Reescribe este código con list comprehension:**
```python
result = []                              # Lista vacía para acumular resultados.
for x in range(10):                      # range(10): genera 0,1,2,...,9.
    if x % 2 == 0:                       # %: módulo. x%2==0 significa "x es par".
        result.append(x**2)              # **: exponente. Añade el cuadrado de x.
```

### Respuesta:
```python
result = [x**2 for x in range(10) if x % 2 == 0]  # List comprehension: [expresión for item in iterable if condición]
# [0, 4, 16, 36, 64]                              # Resultado: cuadrados de números pares del 0 al 9.
```

**Ventajas**:
- Más conciso
- Más rápido (optimizado internamente)
- Más "pythónico"

---

## Pregunta 3: Funciones y Argumentos
**¿Qué hace `*args` y `**kwargs`?**

### Respuesta:
```python
def log_experiment(*args, **kwargs):    # *args: captura argumentos posicionales como tupla.
    # args: tupla de argumentos posicionales   # **kwargs: captura argumentos con nombre como dict.
    # kwargs: diccionario de argumentos con nombre
    print(f"Metrics: {args}")            # f-string: permite insertar variables con {}.
    print(f"Config: {kwargs}")           # Imprime el diccionario de kwargs.

log_experiment(0.85, 0.82, model="rf", n_estimators=100)  # 2 posicionales + 2 con nombre.
# Metrics: (0.85, 0.82)                  # args captura los valores sin nombre.
# Config: {'model': 'rf', 'n_estimators': 100}  # kwargs captura los pares key=value.
```

**En el portafolio** (`BankChurn/trainer.py`):
```python
def __init__(self, config: BankChurnConfig, **kwargs):
    self.config = config
    self.extra_params = kwargs  # Flexibilidad para params adicionales
```

---

## Pregunta 4: Manejo de Errores
**¿Por qué usamos try/except?**

### Respuesta:
```python
def load_data(path: str) -> pd.DataFrame:  # Type hints: espera str, retorna DataFrame.
    try:                                    # try: intenta ejecutar código que puede fallar.
        df = pd.read_csv(path)              # Operación que puede lanzar excepciones.
        return df
    except FileNotFoundError:               # Captura error específico: archivo no existe.
        print(f"Error: {path} no existe")
        raise                               # raise: re-lanza la excepción para que el caller la maneje.
    except pd.errors.EmptyDataError:        # Captura otro error específico.
        print("Error: archivo vacío")
        raise                               # Siempre re-lanzar si no puedes recuperarte.
```

**Buenas prácticas**:
- Capturar excepciones específicas, no genéricas
- Hacer logging del error
- Re-lanzar si no puedes manejarlo

---

## Pregunta 5: Import y Módulos
**¿Cuál es la diferencia entre estas formas de import?**

### Respuesta:
```python
# Importar módulo completo
import pandas as pd                      # Importa todo el módulo con alias "pd".
df = pd.read_csv("data.csv")             # Acceso via pd.función().

# Importar función específica
from sklearn.model_selection import train_test_split  # Solo importa esta función.
X_train, X_test = train_test_split(X)    # Uso directo sin prefijo.

# Importar todo (⚠️ evitar en producción)
from math import *                       # * importa TODO: contamina namespace, difícil saber origen.
```

**Best practice**: Importar lo que necesitas, usar alias estándar (`pd`, `np`, `plt`).

---

## Pregunta 6: Type Hints
**¿Qué significan los type hints y por qué usarlos?**

### Respuesta:
```python
def predict_churn(
    credit_score: int,                    # : int indica que espera un entero.
    age: int,
    is_active: bool                       # : bool indica booleano (True/False).
) -> float:                               # -> float indica que RETORNA un decimal.
    """Retorna probabilidad de churn."""
    ...                                   # ... es placeholder (Ellipsis), indica "implementar".
```

**Beneficios**:
1. **Documentación**: Claro qué espera y retorna
2. **IDE support**: Autocompletado, detección de errores
3. **Tooling**: `mypy` puede verificar tipos

**En el portafolio**: Todos los archivos usan type hints (`config.py`, `training.py`).

---

## Pregunta 7: Clases Básicas
**¿Qué es `__init__` y `self`?**

### Respuesta:
```python
class BankChurnTrainer:                   # class: define un nuevo tipo de objeto.
    def __init__(self, config):           # __init__: constructor, se ejecuta al crear instancia.
        # Constructor: se ejecuta al crear instancia
        self.config = config              # self: referencia a ESTA instancia. Guarda config.
        self.model_ = None                # Atributo inicializado en None (convención: _ para fitted).
    
    def train(self, X, y):                # Método: función que pertenece a la clase.
        # self permite acceder a atributos de la instancia
        if self.config.model_type == "rf":  # Accede a config guardada en __init__.
            self.model_ = RandomForestClassifier()
        self.model_.fit(X, y)             # Entrena y guarda modelo en self.

# Uso
trainer = BankChurnTrainer(config)        # Crea instancia: __init__ se ejecuta automáticamente.
trainer.train(X, y)                       # Llama método train en esta instancia.
```

---

## Pregunta 8: Lectura de Archivos
**¿Cómo lees un archivo CSV con pandas?**

### Respuesta:
```python
import pandas as pd

# Básico
df = pd.read_csv("data/raw/Churn.csv")    # Lee CSV y crea DataFrame.

# Con opciones
df = pd.read_csv(
    "data/raw/Churn.csv",
    sep=",",                              # Separador de columnas (coma por defecto).
    encoding="utf-8",                     # Codificación del archivo.
    na_values=["", "NA", "null"],         # Valores que pandas tratará como NaN.
    dtype={"customer_id": str}            # Fuerza tipo de columna específica.
)

# Verificar
print(df.shape)                           # (filas, columnas): (10000, 14).
print(df.info())                          # Muestra tipos de datos y valores nulos por columna.
print(df.head())                          # Primeras 5 filas del DataFrame.
```

---

## Pregunta 9: Entornos Virtuales
**¿Por qué usamos entornos virtuales?**

### Respuesta:
```bash
# Crear entorno
python -m venv .venv          # -m venv: ejecuta módulo venv. .venv: nombre de la carpeta.

# Activar
source .venv/bin/activate     # Linux/Mac: source ejecuta el script de activación.
.venv\Scripts\activate        # Windows: script diferente por el sistema.

# Instalar dependencias
pip install -r requirements.txt  # -r: lee archivo y instala todas las dependencias listadas.
```

**Razones**:
1. **Aislamiento**: Cada proyecto tiene sus propias versiones
2. **Reproducibilidad**: Mismo entorno en cualquier máquina
3. **Evita conflictos**: sklearn 1.3 en proyecto A, sklearn 1.2 en proyecto B

---

## Pregunta 10: Debugging Básico
**¿Cómo depuras código en Python?**

### Respuesta:
```python
# 1. Print statements (básico pero útil)
print(f"X shape: {X.shape}, y shape: {y.shape}")  # f-string para inspeccionar variables.

# 2. Usar assert
assert X.shape[0] == y.shape[0], "Mismatch en filas"  # assert: falla si condición es False.

# 3. Breakpoints en IDE (recomendado)
# Poner breakpoint y usar F5 para debugear   # Pausa ejecución y permite inspeccionar.

# 4. pdb (en terminal)
import pdb; pdb.set_trace()                   # pdb: debugger interactivo de Python.

# 5. Logging (producción)
import logging
logging.debug(f"Loaded {len(df)} rows")       # Mejor que print: niveles, archivos, formato.
```

---

# 2. Machine Learning Fundamentos (Preguntas 11-20) {#2-machine-learning-fundamentos-preguntas-11-20}

## Pregunta 11: Train/Test Split
**¿Por qué separamos datos en train y test?**

### Respuesta:
```python
from sklearn.model_selection import train_test_split  # Función para dividir datos.

X_train, X_test, y_train, y_test = train_test_split(  # Retorna 4 arrays.
    X, y, 
    test_size=0.2,      # 80/20 split: 20% para test.
    random_state=42,    # Semilla: mismos datos cada ejecución.
    stratify=y          # Mantiene proporción de clases en ambos sets.
)
```

**Razón**: Evaluar cómo el modelo generaliza a datos **nunca vistos**.
- **Train**: Aprende patrones
- **Test**: Simula producción, mide rendimiento real

**Error común**: Usar test para ajustar modelo → overfitting al test.

---

## Pregunta 12: Overfitting vs Underfitting
**Explica overfitting y underfitting.**

### Respuesta:

| Concepto | Síntomas | Causa | Solución |
|----------|----------|-------|----------|
| **Overfitting** | Train acc: 99%, Test acc: 70% | Modelo muy complejo | Regularización, más datos, simplificar |
| **Underfitting** | Train acc: 60%, Test acc: 58% | Modelo muy simple | Más features, modelo más complejo |

```python
# Detectar en el portafolio
print(f"Train accuracy: {model.score(X_train, y_train):.2%}")  # .score(): accuracy del modelo.
print(f"Test accuracy: {model.score(X_test, y_test):.2%}")    # :.2%: formatea como porcentaje.

# Si diferencia > 10%, posible overfitting  # Train >> Test = modelo memoriza, no generaliza.
```

---

## Pregunta 13: Clasificación vs Regresión
**¿Cuándo usar clasificación y cuándo regresión?**

### Respuesta:

| Problema | Tipo | Target | Métrica |
|----------|------|--------|---------|
| ¿Cliente hará churn? | Clasificación | Sí/No (0/1) | Accuracy, F1, AUC |
| ¿Cuánto cuesta el auto? | Regresión | Precio ($) | RMSE, MAE, R² |
| ¿Qué plan elegirá? | Clasificación multiclase | A/B/C | Accuracy, F1 macro |

**En el portafolio**:
- **BankChurn**: Clasificación binaria (churn: 0/1)
- **CarVision**: Regresión (precio continuo)
- **TelecomAI**: Clasificación multiclase (tipo de plan)

---

## Pregunta 14: Cross-Validation
**¿Qué es cross-validation y por qué usarla?**

### Respuesta:
```python
from sklearn.model_selection import cross_val_score  # CV automático con scoring.

scores = cross_val_score(model, X, y, cv=5)          # cv=5: 5-fold cross-validation.
print(f"Accuracy: {scores.mean():.3f} (+/- {scores.std()*2:.3f})")  # Media ± 2*std (95% confianza).
```

**Proceso K-Fold (K=5)**:
1. Divide datos en 5 partes iguales
2. Entrena en 4, valida en 1
3. Repite 5 veces (cada parte es validación una vez)
4. Promedia resultados

**Ventajas**:
- Usa todos los datos para entrenar y validar
- Estimación más robusta del rendimiento
- Detecta variabilidad del modelo

---

## Pregunta 15: Feature Scaling
**¿Por qué normalizamos features?**

### Respuesta:
```python
from sklearn.preprocessing import StandardScaler   # Estandariza: (x - media) / std.

scaler = StandardScaler()                          # Crea instancia del transformador.
X_scaled = scaler.fit_transform(X_train)           # fit: calcula media/std. transform: aplica.

# Antes: age=[18-92], salary=[20000-200000]        # Escalas muy diferentes.
# Después: ambas con media=0, std=1               # Escalas comparables.
```

**Razones**:
1. **Algoritmos sensibles a escala**: SVM, KNN, redes neuronales
2. **Gradiente descent**: Converge más rápido
3. **Interpretación**: Coeficientes comparables

**Algoritmos que NO necesitan scaling**: Random Forest, Decision Tree, XGBoost.

---

## Pregunta 16: One-Hot Encoding
**¿Cómo manejas variables categóricas?**

### Respuesta:
```python
from sklearn.preprocessing import OneHotEncoder    # Convierte categorías a columnas binarias.

encoder = OneHotEncoder(sparse_output=False, handle_unknown='ignore')  # ignore: no falla con categorías nuevas.
X_encoded = encoder.fit_transform(df[['Geography', 'Gender']])  # fit: aprende categorías. transform: aplica.

# Geography: France, Germany, Spain
# → Geography_France, Geography_Germany, Geography_Spain  # 1 columna por categoría, valores 0/1.
```

**Alternativas**:
- **Label Encoding**: Para ordinales (Bajo < Medio < Alto)
- **Target Encoding**: Codifica con la media del target (⚠️ riesgo de leakage)

---

## Pregunta 17: Missing Values
**¿Cómo manejas valores faltantes?**

### Respuesta:
```python
from sklearn.impute import SimpleImputer            # Rellena valores faltantes (NaN).

# Numéricos: media o mediana
imputer_num = SimpleImputer(strategy='median')     # median: robusto a outliers.

# Categóricos: moda o valor constante
imputer_cat = SimpleImputer(strategy='constant', fill_value='Unknown')  # Rellena con 'Unknown'.
```

**Estrategias**:
| Caso | Estrategia |
|------|------------|
| Pocos missing (<5%) | Imputar con media/moda |
| Muchos missing | Considerar eliminar columna |
| Missing tiene significado | Crear feature `is_missing` |

---

## Pregunta 18: Random Forest
**Explica cómo funciona Random Forest.**

### Respuesta:
```python
from sklearn.ensemble import RandomForestClassifier  # Ensemble de árboles de decisión.

rf = RandomForestClassifier(
    n_estimators=100,  # 100 árboles: más árboles = más robusto pero más lento.
    max_depth=10,      # Profundidad máxima: limita complejidad, evita overfitting.
    random_state=42    # Semilla para reproducibilidad.
)
```

**Concepto simple**:
1. Crea N árboles de decisión
2. Cada árbol usa subset aleatorio de datos y features
3. Predicción final = voto mayoritario (clasificación) o promedio (regresión)

**Ventajas**: Robusto, pocas configuraciones, maneja bien missing values.

---

## Pregunta 19: Métricas de Clasificación
**¿Qué es accuracy, precision, recall y F1?**

### Respuesta:
```python
from sklearn.metrics import classification_report  # Reporte completo de métricas.

print(classification_report(y_test, y_pred))       # Muestra precision, recall, f1 por clase.
```

| Métrica | Fórmula | Cuándo priorizar |
|---------|---------|------------------|
| **Accuracy** | Correctos / Total | Clases balanceadas |
| **Precision** | TP / (TP + FP) | Costo alto de falsos positivos |
| **Recall** | TP / (TP + FN) | Costo alto de falsos negativos |
| **F1** | 2 × (P × R) / (P + R) | Balance entre P y R |

**En BankChurn**: Priorizo **Recall** (no queremos perder clientes que harán churn).

---

## Pregunta 20: Curva ROC y AUC
**¿Qué es AUC-ROC?**

### Respuesta:
```python
from sklearn.metrics import roc_auc_score, roc_curve  # Métricas para clasificación binaria.

# AUC: Área bajo la curva ROC
auc = roc_auc_score(y_test, y_pred_proba[:, 1])       # [:, 1]: probabilidad de clase positiva.
print(f"AUC: {auc:.3f}")                              # :.3f: 3 decimales.
```

**Interpretación**:
- **AUC = 1.0**: Clasificador perfecto
- **AUC = 0.5**: Clasificador aleatorio
- **AUC > 0.8**: Generalmente bueno

**Ventaja**: Funciona bien con clases desbalanceadas.

---

# 3. Datos y Preprocesamiento (Preguntas 21-30) {#3-datos-y-preprocesamiento-preguntas-21-30}

## Pregunta 21: Exploración de Datos
**¿Qué haces primero cuando recibes un dataset?**

### Respuesta:
```python
import pandas as pd

df = pd.read_csv("data.csv")                          # Carga el dataset.

# 1. Dimensiones
print(f"Shape: {df.shape}")                           # (filas, columnas): tamaño del dataset.

# 2. Tipos de datos
print(df.dtypes)                                      # Tipo de cada columna (int, float, object).

# 3. Missing values
print(df.isnull().sum())                              # Cuenta NaN por columna.

# 4. Estadísticas básicas
print(df.describe())                                  # Media, std, min, max, cuartiles.

# 5. Primeras filas
print(df.head())                                      # Visualiza primeras 5 filas.

# 6. Target distribution
print(df['target'].value_counts(normalize=True))      # normalize=True: proporciones en vez de conteos.
```

---

## Pregunta 22: Detección de Outliers
**¿Cómo detectas outliers?**

### Respuesta:
```python
import numpy as np

# Método IQR (Interquartile Range)
Q1 = df['Balance'].quantile(0.25)                     # Percentil 25.
Q3 = df['Balance'].quantile(0.75)                     # Percentil 75.
IQR = Q3 - Q1                                         # Rango intercuartílico.

lower = Q1 - 1.5 * IQR                                # Límite inferior.
upper = Q3 + 1.5 * IQR                                # Límite superior.

outliers = df[(df['Balance'] < lower) | (df['Balance'] > upper)]  # Filtra outliers.
print(f"Outliers: {len(outliers)}")                   # Cuenta cuántos hay.
```

**Qué hacer con outliers**:
1. Verificar si son errores de datos → corregir
2. Si son legítimos → considerar winsorization o mantener
3. Para modelos sensibles → eliminar o transformar

---

## Pregunta 23: Correlación
**¿Cómo identificas features correlacionadas?**

### Respuesta:
```python
import seaborn as sns
import matplotlib.pyplot as plt

# Matriz de correlación
corr = df.corr()                                      # Calcula correlación entre todas las columnas numéricas.

# Heatmap
plt.figure(figsize=(10, 8))                           # Tamaño del gráfico.
sns.heatmap(corr, annot=True, cmap='coolwarm')        # annot: muestra valores. cmap: colores.
plt.show()

# Features altamente correlacionadas (>0.9)
high_corr = (corr.abs() > 0.9) & (corr != 1.0)        # abs(): valor absoluto. Excluye diagonal.
```

**¿Por qué importa?** Features muy correlacionadas son redundantes → considerar eliminar una.

---

## Pregunta 24: Desbalance de Clases
**¿Qué haces cuando tienes 95% clase A y 5% clase B?**

### Respuesta:
```python
# 1. Cambiar métrica (no usar accuracy)
from sklearn.metrics import f1_score, recall_score  # Métricas que consideran desbalance.

# 2. Class weights
from sklearn.linear_model import LogisticRegression
model = LogisticRegression(class_weight='balanced')  # Penaliza más errores en clase minoritaria.

# 3. Oversampling (SMOTE)
from imblearn.over_sampling import SMOTE             # Genera ejemplos sintéticos de clase minoritaria.
X_res, y_res = SMOTE().fit_resample(X, y)            # Balancea el dataset.

# 4. Undersampling
from imblearn.under_sampling import RandomUnderSampler  # Reduce clase mayoritaria.
```

**En BankChurn**: 80/20 balance → usamos `class_weight='balanced'` y F1.

---

## Pregunta 25: Feature Selection
**¿Cómo seleccionas features importantes?**

### Respuesta:
```python
from sklearn.ensemble import RandomForestClassifier

# 1. Feature importance de RF
rf = RandomForestClassifier().fit(X, y)              # Entrena RF.
importances = pd.DataFrame({
    'feature': X.columns,
    'importance': rf.feature_importances_            # Importancia calculada por RF.
}).sort_values('importance', ascending=False)        # Ordena de mayor a menor.

# 2. Correlación con target
correlations = df.corr()['target'].abs().sort_values(ascending=False)  # Correlación absoluta.

# 3. SelectKBest
from sklearn.feature_selection import SelectKBest, f_classif  # Selección estadística.
selector = SelectKBest(f_classif, k=10)              # k=10: selecciona las 10 mejores.
X_selected = selector.fit_transform(X, y)            # Retorna solo las k features.
```

---

## Pregunta 26: Data Leakage
**¿Qué es data leakage y cómo evitarlo?**

### Respuesta:
Data leakage = cuando información del futuro o del target filtra al entrenamiento.

```python
# ❌ MAL: fit scaler en TODO antes de split
scaler.fit(X)                                        # Ve datos de test → LEAKAGE.
X_train, X_test = train_test_split(X)

# ✅ BIEN: fit solo en train
X_train, X_test = train_test_split(X)                # Primero split.
scaler.fit(X_train)                                  # fit SOLO en train.
X_train = scaler.transform(X_train)                  # transform train.
X_test = scaler.transform(X_test)                    # transform test (sin fit).
```

**En el portafolio**: Usamos Pipeline de sklearn que maneja esto automáticamente.

---

## Pregunta 27: Pipelines de sklearn
**¿Por qué usar Pipeline?**

### Respuesta:
```python
from sklearn.pipeline import Pipeline               # Encadena pasos de ML.
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier

pipe = Pipeline([                                   # Lista de tuplas (nombre, transformador).
    ('scaler', StandardScaler()),                   # Paso 1: escalar.
    ('model', RandomForestClassifier())             # Paso 2: modelo.
])

# Un solo fit/predict
pipe.fit(X_train, y_train)                          # fit propaga por todos los pasos.
y_pred = pipe.predict(X_test)                       # predict: transforma y predice.
```

**Beneficios**:
1. **Evita leakage**: fit solo en train automáticamente
2. **Código limpio**: Todo en un objeto
3. **Fácil deploy**: `joblib.dump(pipe, 'model.joblib')`
4. **Reproducibilidad**: Mismo proceso siempre

---

## Pregunta 28: Guardado de Modelos
**¿Cómo guardas y cargas un modelo entrenado?**

### Respuesta:
```python
import joblib                                       # Serialización eficiente para objetos Python.

# Guardar
joblib.dump(model, 'artifacts/model.joblib')        # Serializa modelo a archivo.

# Cargar
model = joblib.load('artifacts/model.joblib')       # Deserializa de archivo.

# Usar
prediction = model.predict(new_data)                # Modelo listo para predecir.
```

**En producción** (FastAPI):
```python
@lru_cache()                                        # Cache: carga modelo UNA vez, reutiliza.
def load_model():
    return joblib.load("artifacts/pipeline.joblib") # Evita cargar en cada request.
```

---

## Pregunta 29: Validación de Datos
**¿Cómo validas que los datos de entrada son correctos?**

### Respuesta:
```python
from pydantic import BaseModel, Field, validator  # Pydantic: validación de datos.

class CustomerInput(BaseModel):                   # Hereda de BaseModel para validación automática.
    credit_score: int = Field(ge=300, le=850)     # ge: >=300, le: <=850. Validación de rango.
    age: int = Field(ge=18, le=100)               # Edad entre 18 y 100.
    geography: str
    
    @validator('geography')                       # Validador custom para geography.
    def geography_valid(cls, v):                  # cls: clase, v: valor a validar.
        valid = ['France', 'Germany', 'Spain']
        if v not in valid:
            raise ValueError(f'Must be one of {valid}')  # Error descriptivo.
        return v                                  # Retorna valor validado.
```

**Beneficios**: Errores claros antes de llegar al modelo.

---

## Pregunta 30: Reproducibilidad
**¿Cómo garantizas que tu experimento sea reproducible?**

### Respuesta:
```python
import random
import numpy as np

# 1. Fijar seeds
SEED = 42                                         # Constante para todas las semillas.
random.seed(SEED)                                 # Seed para módulo random de Python.
np.random.seed(SEED)                              # Seed para numpy.

# 2. En modelos
model = RandomForestClassifier(random_state=SEED) # random_state: semilla interna del modelo.

# 3. En split
train_test_split(X, y, random_state=SEED)         # Misma semilla = mismo split siempre.

# 4. Documentar versiones
# requirements.txt o pyproject.toml con versiones fijas  # sklearn==1.3.0, no sklearn.
```

---

# 4. Git y Herramientas (Preguntas 31-40) {#4-git-y-herramientas-preguntas-31-40}

## Pregunta 31: Git Básico
**¿Cuál es el flujo básico de Git?**

### Respuesta:
```bash
# 1. Ver estado
git status                    # Muestra archivos modificados/nuevos/staged.

# 2. Añadir cambios
git add .                     # Añade TODO al staging area.
git add archivo.py            # Añade archivo específico.

# 3. Commit
git commit -m "feat: add preprocessing step"  # Guarda cambios con mensaje descriptivo.

# 4. Push
git push origin main          # Sube commits locales al remoto (origin/main).

# 5. Pull (obtener cambios)
git pull origin main          # Descarga y fusiona cambios del remoto.
```

---

## Pregunta 32: Branches
**¿Por qué usar branches?**

### Respuesta:
```bash
# Crear branch
git checkout -b feature/add-validation  # -b: crea branch y cambia a ella.

# Trabajar...
git add .
git commit -m "feat: add pydantic validation"  # Conventional commit: tipo(scope): mensaje.

# Push branch
git push origin feature/add-validation  # Sube branch al remoto.

# Crear Pull Request en GitHub
# Después de aprobar, merge a main       # PR permite code review antes de merge.
```

**Razones**:
- Aislar cambios
- Revisar código antes de merge
- Mantener main siempre funcional

---

## Pregunta 33: .gitignore
**¿Qué debe ir en .gitignore?**

### Respuesta:
```gitignore
# Datos (grandes, sensibles)
data/
*.csv
*.parquet

# Artefactos
artifacts/
*.joblib
*.pkl

# Entornos
.venv/
__pycache__/

# IDEs
.vscode/
.idea/

# Logs
*.log
mlruns/
```

**Regla**: No subir datos grandes, artefactos binarios, ni secretos.

---

## Pregunta 34: Requirements
**¿Cómo manejas dependencias?**

### Respuesta:
```bash
# Crear requirements.txt
pip freeze > requirements.txt           # Exporta TODAS las dependencias instaladas.

# Mejor: usar pip-tools
pip-compile requirements.in > requirements.txt  # Genera lockfile desde requirements.in.

# Instalar
pip install -r requirements.txt         # Instala exactamente las versiones especificadas.

# Moderno: pyproject.toml
pip install -e ".[dev]"                 # -e: editable. [dev]: grupo de deps opcionales.
```

---

## Pregunta 35: Makefile
**¿Para qué sirve un Makefile?**

### Respuesta:
```makefile
.PHONY: install test train              # Declara targets que no son archivos.

install:                                # Target: make install
	pip install -e ".[dev]"             # Comando a ejecutar (TAB obligatorio).

test:                                   # Target: make test
	pytest tests/ -v --cov=src          # Ejecuta tests con coverage.

train:                                  # Target: make train
	python main.py --config configs/config.yaml

lint:                                   # Target: make lint
	ruff check src/                     # Verifica calidad de código.
```

**Uso**:
```bash
make install
make test
make train
```

**Beneficio**: Comandos estándar, documentados, fáciles de recordar.

---

## Pregunta 36: pytest Básico
**¿Cómo escribes un test básico?**

### Respuesta:
```python
# tests/test_data.py
import pytest                            # Framework de testing.
import pandas as pd

def test_load_data():                    # Función test: debe empezar con test_.
    df = pd.read_csv("data/raw/sample.csv")
    assert len(df) > 0                   # assert: falla si condición es False.
    assert "target" in df.columns        # Verifica que columna existe.

def test_no_nulls_in_target():           # Otro test independiente.
    df = pd.read_csv("data/raw/sample.csv")
    assert df["target"].isnull().sum() == 0  # No debe haber NaN en target.

# Ejecutar
# pytest tests/test_data.py -v           # -v: verbose, muestra detalles.
```

---

## Pregunta 37: Estructura de Proyecto
**¿Cómo organizas un proyecto ML?**

### Respuesta:
```
mi-proyecto/
├── src/miproyecto/     # Código fuente
│   ├── __init__.py
│   ├── config.py       # Configuración
│   ├── data.py         # Carga de datos
│   ├── features.py     # Feature engineering
│   └── training.py     # Entrenamiento
├── app/                # APIs
├── tests/              # Tests
├── configs/            # YAML configs
├── data/raw/           # Datos
├── artifacts/          # Modelos guardados
├── pyproject.toml      # Dependencias
├── Makefile           
└── README.md
```

---

## Pregunta 38: README
**¿Qué debe tener un buen README?**

### Respuesta:
```markdown
# Nombre del Proyecto

## Descripción
Qué hace el proyecto, problema que resuelve.

## Instalación
```bash
pip install -e .
```

## Uso Rápido
```python
from miproyecto import predict
result = predict(data)
```

## Estructura
Árbol de directorios.

## Tests
```bash
make test
```

## Autor
Nombre, contacto.
```

---

## Pregunta 39: Docker Básico
**¿Qué es Docker y por qué usarlo?**

### Respuesta:
Docker empaqueta tu aplicación con todas sus dependencias.

```dockerfile
FROM python:3.11-slim                    # Imagen base: Python 3.11 ligera.

WORKDIR /app                             # Directorio de trabajo dentro del contenedor.
COPY requirements.txt .                  # Copia solo requirements primero (cache de capas).
RUN pip install -r requirements.txt      # Instala dependencias.

COPY . .                                 # Copia el resto del código.
CMD ["python", "main.py"]               # Comando por defecto al ejecutar contenedor.
```

```bash
# Construir
docker build -t mi-app .                 # -t: tag/nombre. .: contexto actual.

# Ejecutar
docker run mi-app                        # Ejecuta contenedor con la imagen.
```

**Beneficio**: "Funciona en mi máquina" → Funciona en cualquier máquina.

---

## Pregunta 40: APIs Básicas
**¿Qué es una API REST?**

### Respuesta:
API = Interfaz para que otros programas usen tu código.

```python
from fastapi import FastAPI               # Framework web moderno para APIs.

app = FastAPI()                           # Crea instancia de la aplicación.

@app.get("/health")                       # Decorador: ruta GET /health.
def health():
    return {"status": "ok"}               # Retorna JSON automáticamente.

@app.post("/predict")                     # Decorador: ruta POST /predict.
def predict(data: dict):                 # data: body del request como dict.
    # Usar modelo
    return {"prediction": result}         # Respuesta JSON.
```

```bash
# Ejecutar
uvicorn app:app --reload                 # uvicorn: servidor ASGI. --reload: hot reload.

# Probar
curl http://localhost:8000/health        # curl: hace request HTTP desde terminal.
```

---

# 5. Práctica con el Portafolio (Preguntas 41-50) {#5-práctica-con-el-portafolio-preguntas-41-50}

## Pregunta 41: Describir el Portafolio
**Cuéntame sobre el portafolio.**

### Respuesta:
"Es un portafolio de MLOps con 3 proyectos production-ready:

1. **BankChurn-Predictor**: Clasificación binaria para predecir churn de clientes bancarios. Pipeline sklearn unificado, FastAPI, 79% coverage.

2. **CarVision-Market-Intelligence**: Regresión para predecir precios de autos usados. FeatureEngineer centralizado, Streamlit dashboard.

3. **TelecomAI**: Clasificación multiclase para segmentación de clientes de telecom.

Todos siguen las mismas prácticas: estructura src/, Pydantic para configs, pytest, GitHub Actions CI."

---

## Pregunta 42: Ejecutar el Proyecto
**¿Cómo ejecuto BankChurn?**

### Respuesta:
```bash
# 1. Clonar
git clone https://github.com/duqueom/ML-MLOps-Portfolio.git  # Descarga repositorio.
cd ML-MLOps-Portfolio/BankChurn-Predictor  # Entra al proyecto.

# 2. Crear entorno
python -m venv .venv                     # Crea entorno virtual.
source .venv/bin/activate                # Activa entorno (Linux/Mac).

# 3. Instalar
pip install -e ".[dev]"                  # Instala proyecto + deps de desarrollo.

# 4. Entrenar
python main.py --config configs/config.yaml  # Ejecuta entrenamiento con config.

# 5. API
uvicorn app.fastapi_app:app --reload     # Inicia servidor de desarrollo.

# 6. Tests
pytest tests/ -v                         # Ejecuta todos los tests.
```

---

## Pregunta 43: Entender el Pipeline
**¿Cómo funciona el pipeline de BankChurn?**

### Respuesta:
```python
# 1. Cargar config
config = BankChurnConfig.from_yaml("configs/config.yaml")  # Pydantic valida config.

# 2. Cargar datos
df = pd.read_csv(config.data.raw_path)   # Ruta viene de config.

# 3. Crear trainer
trainer = Trainer(config)                 # Trainer encapsula lógica de entrenamiento.

# 4. Entrenar (dentro crea Pipeline sklearn)
trainer.fit(X, y)                         # fit: entrena preprocesador + modelo.
# Pipeline = [preprocessor, model]        # Todo en un objeto.
# preprocessor = ColumnTransformer(numeric_pipe, categorical_pipe)

# 5. Evaluar
metrics = trainer.evaluate(X_test, y_test)  # Retorna dict de métricas.

# 6. Guardar
trainer.save("artifacts/")                # Serializa pipeline completo.
```

---

## Pregunta 44: Modificar el Código
**¿Cómo añadirías una nueva feature?**

### Respuesta:
```python
# 1. En config.yaml, añadir columna
features:
  numerical:
    - CreditScore
    - Age
    - NewFeature  # Nueva                # Solo agregar aquí si ya existe en datos.

# 2. Si requiere transformación, editar FeatureEngineer
class FeatureEngineer:                    # Transformer custom.
    def transform(self, X):
        X['NewFeature'] = X['Col1'] / X['Col2']  # Crea feature derivada.
        return X

# 3. Agregar test
def test_new_feature():                   # Test para la nueva feature.
    fe = FeatureEngineer()
    result = fe.transform(sample_df)
    assert 'NewFeature' in result.columns # Verifica que se creó.

# 4. Ejecutar tests
pytest tests/test_features.py -v          # Verifica que todo sigue funcionando.
```

---

## Pregunta 45: Leer un Error
**Este código falla. ¿Por qué?**
```python
X_train = scaler.fit_transform(X_train)
X_test = scaler.fit_transform(X_test)
```

### Respuesta:
**Problema**: `fit_transform` en test causa data leakage.

```python
# ✅ Correcto
X_train = scaler.fit_transform(X_train)  # fit + transform: aprende de train.
X_test = scaler.transform(X_test)        # solo transform: usa params de train.
```

El scaler debe aprender (fit) solo de training data.

---

## Pregunta 46: Interpretar Métricas
**El modelo tiene accuracy 95% pero el negocio no está contento. ¿Por qué?**

### Respuesta:
Posibles razones:

1. **Clases desbalanceadas**: Si 95% son clase 0, predecir siempre 0 da 95% accuracy pero es inútil.

2. **Métrica incorrecta**: El negocio necesita recall (no perder churners) pero optimizaste accuracy.

3. **Falsos negativos costosos**: Cada cliente que hace churn y no detectamos cuesta $X.

**Solución**: Usar F1, recall, o una métrica de negocio (costo).

---

## Pregunta 47: Configuración YAML
**¿Por qué usar archivos YAML para configuración?**

### Respuesta:
```yaml
# configs/config.yaml
model:
  type: "random_forest"          # Tipo de modelo a usar.
  n_estimators: 100               # Hiperparámetros del modelo.
  max_depth: 10

data:
  raw_path: "data/raw/Churn.csv"  # Rutas configurables.
  test_size: 0.2                  # Proporción de test.

training:
  random_state: 42                # Semilla para reproducibilidad.
```

**Ventajas**:
1. **Separación**: Cambiar parámetros sin tocar código
2. **Versionable**: Git puede trackear cambios
3. **Legible**: Fácil de entender
4. **Reproducibilidad**: Guardar config de cada experimento

---

## Pregunta 48: CI/CD Básico
**¿Qué hace el workflow de GitHub Actions?**

### Respuesta:
```yaml
# .github/workflows/ci.yml
name: CI                          # Nombre del workflow.
on: [push, pull_request]          # Triggers: se activa en push o PR.

jobs:
  test:
    runs-on: ubuntu-latest        # Ejecuta en Ubuntu.
    steps:
      - uses: actions/checkout@v4  # Clona el repo.
      - uses: actions/setup-python@v5  # Instala Python.
      - run: pip install -e ".[dev]"  # Instala dependencias.
      - run: pytest tests/ -v     # Ejecuta tests.
```

**Flujo**:
1. Push código → GitHub Actions se activa
2. Crea máquina virtual limpia
3. Instala dependencias
4. Ejecuta tests
5. Reporta pass/fail

---

## Pregunta 49: Debugging en Producción
**El API retorna error 500. ¿Cómo lo depuras?**

### Respuesta:
```python
# 1. Ver logs
uvicorn app:app --log-level debug # --log-level debug: muestra todos los logs.

# 2. Añadir logging
import logging
logging.basicConfig(level=logging.DEBUG)  # Configura nivel de logging.

@app.post("/predict")
def predict(data: Input):
    logging.debug(f"Input: {data}")        # Log de entrada para debugging.
    try:
        result = model.predict(...)        # Operación que puede fallar.
        logging.debug(f"Result: {result}") # Log de resultado.
        return result
    except Exception as e:
        logging.error(f"Error: {e}")       # Log de error con detalles.
        raise                              # Re-lanza para que FastAPI maneje.

# 3. Probar localmente
curl -X POST http://localhost:8000/predict \  # curl: cliente HTTP desde terminal.
  -H "Content-Type: application/json" \       # Header: indica formato JSON.
  -d '{"credit_score": 650, ...}'             # -d: data/body del request.
```

---

## Pregunta 50: Próximos Pasos
**¿Qué aprenderías después de este portafolio?**

### Respuesta:
"Con las bases del portafolio, me gustaría profundizar en:

1. **MLflow/Experiment Tracking**: Ya está configurado, pero quiero usarlo más para comparar experimentos sistemáticamente.

2. **Docker avanzado**: Optimizar imágenes, multi-stage builds.

3. **Testing más robusto**: Añadir tests de integración, property-based testing.

4. **Kubernetes básico**: Entender cómo escalar los servicios.

5. **Monitoreo en producción**: Detectar drift, alertas.

El portafolio me dio la base; ahora quiero profundizar en cada área."

---

# 📚 Recursos para Preparación

## Módulos de la Guía Relacionados

| Pregunta | Módulo |
|----------|--------|
| Python básico | [01_PYTHON_MODERNO.md](01_PYTHON_MODERNO.md) |
| ML fundamentos | [07_SKLEARN_PIPELINES.md](07_SKLEARN_PIPELINES.md), [08_INGENIERIA_FEATURES.md](08_INGENIERIA_FEATURES.md) |
| Git | [05_GIT_PROFESIONAL.md](05_GIT_PROFESIONAL.md) |
| Testing | [11_TESTING_ML.md](11_TESTING_ML.md) |
| APIs | [14_FASTAPI.md](14_FASTAPI.md) |

## Checklist Pre-Entrevista

- [ ] Puedo ejecutar `make install && make test` en BankChurn
- [ ] Entiendo qué hace cada archivo en `src/bankchurn/`
- [ ] Sé explicar train/test split y por qué importa
- [ ] Puedo leer y modificar el `config.yaml`
- [ ] Entiendo el flujo Git básico

---

<div align="center">

**¡Éxito en tu entrevista! 🚀**

*Recuerda: ser Junior significa estar aprendiendo. Muestra curiosidad y ganas de aprender.*

[← Índice](00_INDICE.md) | [Simulacro Mid →](SIMULACRO_ENTREVISTA_MID.md) | [Simulacro Senior →](SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md)

</div>
