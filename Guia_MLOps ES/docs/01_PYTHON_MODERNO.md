# 01. Python Moderno para MLOps

## 🎯 Objetivo del Módulo

Transformar tu código de "funciona en un notebook" a "pasa code review en una empresa FAANG".

En este portafolio aplicarás estos patrones sobre `common_utils/` y el código de los tres proyectos
(BankChurn-Predictor, CarVision-Market-Intelligence, TelecomAI-Customer-Intelligence), para que
tu Python sea consistente en todo el stack.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   ANTES (Data Scientist típico)          DESPUÉS (MLOps Engineer)            ║
║   ───────────────────────────            ─────────────────────────           ║
║   • Un archivo gigante                   • Paquete instalable                ║
║   • Sin tipos                            • Type hints en todo                ║
║   • Config hardcodeada                   • Pydantic validation               ║
║   • "Funciona en mi máquina"             • Funciona en cualquier máquina     ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

<a id="00-prerrequisitos"></a>

## 0.0 Prerrequisitos

- Python básico: funciones, clases, módulos.
- Terminal: ejecutar comandos y navegar carpetas.
- Entorno listo para ejecutar el portafolio (si todavía no lo tienes, usa el módulo **[04_ENTORNOS](04_ENTORNOS.md)**).
- Opcional (pero recomendado): entender qué significa instalar un paquete en modo editable (`pip install -e .`).

---

<a id="01-protocolo-e-como-estudiar-este-modulo"></a>

## 0.1 🧠 Protocolo E: Cómo estudiar este módulo

- **Antes de leer**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define tu *output mínimo* de la sesión.
- **Mientras implementas**: si te atoras >15 min, registra el bloqueo en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
- **Al cerrar la semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para decidir en qué mejorar (calidad, reproducibilidad, etc.).

---

<a id="02-entregables-verificables-minimo-viable"></a>

## 0.2 ✅ Entregables verificables (mínimo viable)

Al terminar este módulo, deberías poder mostrar (en al menos 1 proyecto del portafolio):

- [ ] **Type hints** en funciones públicas (carga de datos, features, train, predict)
- [ ] **`mypy` corriendo** sobre `src/` sin errores críticos
- [ ] **Config con Pydantic** (cargando YAML y validando rangos)
- [ ] **`src/` layout real** (paquete instalable)
- [ ] **Instalación editable**: `pip install -e ".[dev]"` y `pytest` corriendo desde raíz

---

<a id="03-puente-teoria-codigo-portafolio"></a>

## 0.3 🧩 Puente teoría ↔ código (Portafolio)

Para que esto cuente como progreso real, fuerza este mapeo:

- **Concepto**: typing / Pydantic / packaging
- **Archivo**: `src/<paquete>/config.py`, `src/<paquete>/training.py`, `pyproject.toml`
- **Prueba**: `mypy src/` + `pytest`
- **Evidencia**: checklist del módulo + 1 entrada en Diario si hubo bloqueo
## 📋 Contenido

- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
- **0.4** [Repaso: Fundamentos de Python para MLOps](#04-repaso-fundamentos-python) ⭐ NUEVO
1. [Type Hints: Tu Contrato con el Futuro](#11-type-hints-tu-contrato-con-el-futuro)
2. [Pydantic: Validación Automática](#12-pydantic-validation-automatica)
3. [src/ Layout: Estructura Profesional](#13-src-layout-estructura-profesional)
4. [Principios SOLID para ML](#14-principios-solid-para-ml)
5. [OOP para ML: Protocolos y ABC](#15-oop-para-ml) ⭐ NUEVO
6. [Pandera: Validación de DataFrames](#16-pandera-validacion-dataframes) ⭐ NUEVO
7. [Ejercicios Prácticos](#17-ejercicios-practicos)

---

<a id="04-repaso-fundamentos-python"></a>

## 0.4 Repaso: Fundamentos de Python para MLOps

> **Si vienes de Python básico**, esta sección te prepara para el salto a código profesional.
> Si ya dominas funciones, clases y módulos, puedes saltar a la sección 1.1.

### 🎯 De Notebook a Código Profesional: El Mindset

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║  EL PROBLEMA DEL DATA SCIENTIST TÍPICO:                                       ║
║                                                                               ║
║  En un notebook:                                                              ║
║  • Escribes código en celdas desordenadas                                     ║
║  • Variables globales por todos lados                                         ║
║  • "Funciona" = éxito                                                         ║
║  • Cuando algo falla, reinicias el kernel y vuelves a correr todo            ║
║                                                                               ║
║  En producción:                                                               ║
║  • El código debe ser MODULAR (dividido en piezas reutilizables)             ║
║  • Las dependencias deben ser EXPLÍCITAS (no variables mágicas)              ║
║  • "Funciona" = pasa tests + se entiende + se mantiene                       ║
║  • Cuando algo falla, necesitas DIAGNOSTICAR sin reiniciar                   ║
║                                                                               ║
║  Esta guía te lleva del primer mindset al segundo.                           ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### Funciones: La Unidad Básica de Código Reutilizable

```python
# ═══════════════════════════════════════════════════════════════════════════════
# NIVEL BÁSICO: Funciones simples
# ═══════════════════════════════════════════════════════════════════════════════

# ❌ Código de notebook (todo en celdas sueltas) - NO HAGAS ESTO
import pandas as pd                              # pandas: librería para manipular tablas (DataFrames). "pd" es la convención universal.
df = pd.read_csv("data.csv")                     # read_csv() lee un archivo CSV y lo convierte en DataFrame (tabla en memoria).
df = df.dropna()                                 # dropna() elimina TODAS las filas con algún valor faltante (NaN). Peligroso: puedes perder datos.
df["Age"] = df["Age"].fillna(df["Age"].mean())   # fillna() rellena NaN con un valor; mean() calcula el promedio. Problema: esto ya modificó df arriba.
# ... y así 200 líneas más                       # En notebooks, el código crece sin estructura → imposible de mantener/testear.

# ✅ Código profesional (encapsulado en funciones)
def load_and_clean_data(path: str) -> pd.DataFrame:  # def: define una función. "path: str" indica que espera un string. "-> pd.DataFrame" indica qué retorna.
    """Carga datos y aplica limpieza básica.         # Docstring: documentación de la función. SIEMPRE documenta funciones públicas.
    
    Args:                                            # Args: lista de parámetros que recibe la función.
        path: Ruta al archivo CSV.                   # Describe cada parámetro con tipo y propósito.
        
    Returns:                                         # Returns: describe qué devuelve la función.
        DataFrame limpio listo para feature engineering.
        
    Example:                                         # Example: muestra cómo usar la función (doctests ejecutables con pytest).
        >>> df = load_and_clean_data("data/raw/churn.csv")
        >>> df.shape
        (10000, 14)
    """
    df = pd.read_csv(path)                           # Lee el CSV. La ruta viene como parámetro → la función es REUTILIZABLE.
    df = df.dropna(subset=["target"])                # subset=["target"]: solo elimina filas donde "target" es NaN, no todas las filas.
    df["Age"] = df["Age"].fillna(df["Age"].median()) # median() es más robusto que mean() frente a outliers.
    return df                                        # return: devuelve el resultado. Sin return, la función devuelve None.

# Ahora puedo REUTILIZAR esta función en cualquier parte
df_train = load_and_clean_data("data/train.csv")     # Llamo la función con datos de entrenamiento → obtienen misma limpieza.
df_test = load_and_clean_data("data/test.csv")       # Llamo con datos de test → GARANTIZA consistencia entre train y test.
```

### Clases: Agrupando Datos y Comportamiento

```python
# ═══════════════════════════════════════════════════════════════════════════════
# ¿POR QUÉ CLASES? La Analogía del Formulario
# ═══════════════════════════════════════════════════════════════════════════════

# Imagina que tienes que procesar solicitudes de crédito:
#
# SIN CLASES (diccionarios sueltos):
# solicitud1 = {"nombre": "Juan", "edad": 30, "salario": 50000}
# solicitud2 = {"nombre": "Ana", "edad": None, "salario": -1000}  # ¿Válido?
#
# ¿Cómo validas que la edad no sea None?
# ¿Cómo evitas salarios negativos?
# ¿Dónde pones la lógica de calcular el score crediticio?
#
# CON CLASES (estructura + validación + comportamiento):

from dataclasses import dataclass      # dataclass: decorador que genera automáticamente __init__, __repr__, __eq__ para tu clase.
from typing import Optional            # Optional[X] significa "puede ser X o None". Equivale a Union[X, None].

@dataclass                             # @dataclass: convierte la clase en una "data class" → menos código boilerplate.
class SolicitudCredito:                # class: define un nuevo tipo de objeto. PascalCase por convención (primera letra mayúscula).
    """Una solicitud de crédito con validación básica."""  # Docstring de la clase: explica su propósito.
    nombre: str                        # Atributo: nombre de tipo str (texto). dataclass lo convierte en parámetro del __init__.
    edad: int                          # Atributo: edad de tipo int (entero). Será obligatorio al crear la instancia.
    salario: float                     # Atributo: salario de tipo float (decimal). También obligatorio.
    historial_crediticio: Optional[float] = None  # Atributo OPCIONAL: tiene valor por defecto None. Puede o no proporcionarse.
    
    def __post_init__(self):           # __post_init__: método especial que se ejecuta DESPUÉS de que dataclass crea el objeto.
        """Validación al crear la instancia."""  # Aquí ponemos validaciones que deben ocurrir al instanciar.
        if self.edad < 18:             # self: referencia al objeto actual. self.edad accede al atributo edad de ESTA instancia.
            raise ValueError("Debe ser mayor de edad")  # raise: lanza una excepción. ValueError: error por valor inválido.
        if self.salario <= 0:          # Validación de negocio: salario debe ser positivo.
            raise ValueError("Salario debe ser positivo")
    
    def calcular_score(self) -> float: # Método: función que pertenece a la clase. self siempre es el primer parámetro.
        """Calcula score crediticio básico."""
        base = min(self.salario / 1000, 100)      # min(a, b): retorna el menor. Limita el score base a 100 máximo.
        edad_bonus = min(self.edad - 18, 30) * 0.5  # Bonus por edad, máximo 15 puntos (30 * 0.5).
        return base + edad_bonus       # return: devuelve el resultado del cálculo.

# Ahora es IMPOSIBLE crear una solicitud inválida
solicitud = SolicitudCredito(nombre="Juan", edad=30, salario=50000)  # Crea instancia: dataclass genera __init__ con estos parámetros.
print(f"Score: {solicitud.calcular_score()}")  # f-string: f"..." permite insertar {expresiones} dentro del string. Score: 56.0

# Esto FALLA inmediatamente con un error claro
# solicitud_mala = SolicitudCredito(nombre="Ana", edad=15, salario=-1000)
# ValueError: Debe ser mayor de edad  # El error es CLARO y ocurre EN LA CREACIÓN, no después cuando ya es tarde.
```

### Módulos: Organizando Código en Archivos

```python
# ═══════════════════════════════════════════════════════════════════════════════
# ¿POR QUÉ MÓDULOS? La Analogía de la Biblioteca
# ═══════════════════════════════════════════════════════════════════════════════

# Una biblioteca tiene SECCIONES (módulos):
# - Sección de novelas (data.py)
# - Sección de ciencia (features.py)
# - Sección de historia (training.py)
#
# Cada sección tiene su PROPÓSITO y no mezclas libros de cocina con novelas.

# Estructura típica de un proyecto ML:
#
# src/bankchurn/
# ├── __init__.py      # "Esta carpeta es un paquete Python"
# ├── config.py        # Configuración (Pydantic)
# ├── data.py          # Carga y limpieza de datos
# ├── features.py      # Feature engineering
# ├── training.py      # Entrenamiento del modelo
# ├── evaluation.py    # Métricas y evaluación
# └── prediction.py    # Inferencia en producción

# Importar desde módulos:
from bankchurn.config import BankChurnConfig
from bankchurn.data import load_and_clean_data
from bankchurn.training import ChurnTrainer

# Esto es MUCHO más claro que tener todo en un archivo de 2000 líneas
```

### Decoradores: Funciones que Modifican Funciones

```python
# ═══════════════════════════════════════════════════════════════════════════════
# DECORADORES: Muy usados en MLOps (logging, timing, caching, validación)
# ═══════════════════════════════════════════════════════════════════════════════

import time                            # time: módulo estándar de Python para medir tiempo. time.time() da segundos desde 1970.
from functools import wraps            # wraps: preserva metadatos de la función original (nombre, docstring) al decorarla.

def medir_tiempo(func):                # Un decorador es una función que RECIBE otra función como parámetro.
    """Decorador que mide el tiempo de ejecución de una función."""
    @wraps(func)                       # @wraps(func): copia __name__, __doc__ de func a wrapper. Sin esto, se pierde el nombre original.
    def wrapper(*args, **kwargs):      # wrapper: función interna que "envuelve" a la original. *args/**kwargs capturan cualquier argumento.
        inicio = time.time()           # Guarda el tiempo ANTES de ejecutar la función.
        resultado = func(*args, **kwargs)  # Ejecuta la función original con sus argumentos. func es la función decorada.
        fin = time.time()              # Guarda el tiempo DESPUÉS de ejecutar.
        print(f"⏱️ {func.__name__} tardó {fin - inicio:.2f}s")  # __name__: nombre de la función. :.2f formatea a 2 decimales.
        return resultado               # Retorna lo que retornó la función original (no "comerse" el resultado).
    return wrapper                     # El decorador retorna la función wrapper, que reemplaza a la original.

# Uso:
@medir_tiempo                          # @decorador es equivalente a: entrenar_modelo = medir_tiempo(entrenar_modelo)
def entrenar_modelo(X, y):             # Esta función ahora está "envuelta" por wrapper. Al llamarla, ejecuta wrapper.
    """Entrena un modelo (simulado)."""
    time.sleep(2)                      # sleep(2): pausa 2 segundos. Simula un proceso que tarda (como entrenar un modelo).
    return "modelo_entrenado"          # Retorna un string (en la realidad sería el modelo entrenado).

modelo = entrenar_modelo(None, None)   # Llamar entrenar_modelo() realmente llama a wrapper(), que mide tiempo y llama a la original.
# Output: ⏱️ entrenar_modelo tardó 2.00s  # El decorador añadió comportamiento (medir tiempo) SIN modificar la función original.

# En el portafolio verás decoradores para:
# - Logging automático de funciones    # Registrar cada llamada a función con sus parámetros.
# - Caching de resultados costosos     # @lru_cache: guarda resultados para no recalcular.
# - Validación de inputs/outputs       # Verificar tipos o rangos antes/después de ejecutar.
# - Retry de operaciones que pueden fallar  # Reintentar N veces si hay error (útil para APIs, BD).
```

### Context Managers: Recursos que se Limpian Solos

```python
# ═══════════════════════════════════════════════════════════════════════════════
# CONTEXT MANAGERS: Cruciales para archivos, conexiones, MLflow runs
# ═══════════════════════════════════════════════════════════════════════════════

# ❌ PROBLEMA: Si hay un error, el archivo queda abierto
f = open("data.csv", "r")              # open(): abre un archivo. "r" = modo lectura. Retorna un objeto file.
data = f.read()                        # read(): lee TODO el contenido del archivo a memoria (cuidado con archivos grandes).
# ... si algo falla aquí, f nunca se cierra  # Si ocurre una excepción, el código salta y f.close() nunca se ejecuta.
f.close()                              # close(): libera el recurso. Sin cerrar, puedes agotar file descriptors del sistema.

# ✅ SOLUCIÓN: with garantiza que el archivo se cierre
with open("data.csv", "r") as f:       # with: inicia un "context manager". "as f" asigna el archivo a la variable f.
    data = f.read()                    # El código dentro del with tiene acceso a f.
# f se cierra automáticamente, incluso si hay error  # Al salir del with (normal o por excepción), Python llama f.__exit__() que cierra el archivo.

# En MLflow (que usarás en el módulo 10):
import mlflow                          # mlflow: librería para tracking de experimentos ML. Verás más en módulo 10.

with mlflow.start_run(run_name="experimento_1"):  # start_run(): inicia un "run" de MLflow. Es un context manager.
    mlflow.log_param("n_estimators", 100)         # log_param(): registra un hiperparámetro. Se guarda asociado al run.
    mlflow.log_metric("f1_score", 0.85)           # log_metric(): registra una métrica. Puedes ver esto en la UI de MLflow.
    # El run se cierra automáticamente al salir del with  # MLflow guarda todo y marca el run como finalizado.
```

### Comprehensions: Código Conciso y Pythónico

```python
# ═══════════════════════════════════════════════════════════════════════════════
# COMPREHENSIONS: Transformaciones elegantes de datos
# ═══════════════════════════════════════════════════════════════════════════════

# List comprehension (muy común en ML)
columnas = ["CreditScore", "Age", "Balance", "Exited"]  # Lista de strings con nombres de columnas.
columnas_numericas = [col for col in columnas if col != "Exited"]  # [expresión for variable in iterable if condición]
# ['CreditScore', 'Age', 'Balance']  # Resultado: lista con todos los elementos EXCEPTO "Exited".
# Equivale a:                        # Es equivalente a un for loop, pero en UNA línea:
# columnas_numericas = []            # result = []
# for col in columnas:               # for col in columnas:
#     if col != "Exited":            #     if col != "Exited":
#         columnas_numericas.append(col)  #         result.append(col)

# Dict comprehension (útil para métricas)
metricas = {"accuracy": 0.85, "precision": 0.78, "recall": 0.72}  # Diccionario: {clave: valor}.
metricas_redondeadas = {k: round(v, 2) for k, v in metricas.items()}  # {clave: valor for clave, valor in dict.items()}
# items(): retorna pares (clave, valor). round(v, 2): redondea v a 2 decimales.

# Filtrar columnas por tipo (patrón común en feature engineering)
import pandas as pd                  # pandas ya se explicó arriba; aquí se re-importa por claridad del ejemplo.
df = pd.DataFrame({"A": [1, 2], "B": ["x", "y"], "C": [1.5, 2.5]})  # DataFrame: tabla con 3 columnas.
columnas_numericas = [col for col in df.columns if df[col].dtype in ["int64", "float64"]]
# df.columns: lista de nombres de columnas. df[col].dtype: tipo de datos de esa columna.
# "int64", "float64": tipos numéricos de pandas/numpy. Este patrón filtra SOLO columnas numéricas.

# Crear diccionario de features categóricas a codificar
cat_cols = ["Geography", "Gender"]   # Lista de columnas categóricas que queremos codificar.
encoding_map = {col: df[col].unique().tolist() for col in cat_cols}
# unique(): valores únicos de la columna. tolist(): convierte array a lista Python.
# Resultado: {"Geography": ["France", "Spain", ...], "Gender": ["Male", "Female"]}
```

### Manejo de Excepciones: Código que No se Rompe

```python
# ═══════════════════════════════════════════════════════════════════════════════
# EXCEPCIONES: Anticipar y manejar errores profesionalmente
# ═══════════════════════════════════════════════════════════════════════════════

from pathlib import Path                # Path: clase para manejar rutas de archivos de forma segura y multiplataforma.
import logging                          # logging: módulo estándar para registrar mensajes (mejor que print en producción).

logger = logging.getLogger(__name__)    # getLogger(__name__): crea un logger con el nombre del módulo actual.
                                        # __name__ es una variable especial que contiene el nombre del módulo.

def cargar_modelo(path: Path):          # Función que recibe un Path (no string) → más seguro y con autocompletado.
    """Carga un modelo serializado con manejo de errores.
    
    Args:
        path: Ruta al archivo .joblib del modelo.
        
    Returns:
        Modelo cargado.
        
    Raises:                              # Raises: documenta qué excepciones puede lanzar esta función.
        FileNotFoundError: Si el archivo no existe.
        ValueError: Si el archivo no contiene un modelo válido.
    """
    if not path.exists():                # exists(): método de Path que verifica si el archivo/carpeta existe.
        raise FileNotFoundError(f"Modelo no encontrado: {path}")  # raise: lanza una excepción. El programa se detiene aquí.
    
    try:                                 # try: intenta ejecutar el código. Si falla, salta al except.
        import joblib                    # joblib: librería para serializar objetos Python (modelos sklearn).
        modelo = joblib.load(path)       # load(): deserializa el archivo y retorna el objeto Python guardado.
    except Exception as e:               # except: captura la excepción si algo falló en el try. "as e" guarda el error.
        logger.error(f"Error cargando modelo: {e}")  # error(): registra un mensaje de nivel ERROR en el log.
        raise ValueError(f"Archivo inválido: {path}") from e  # from e: encadena excepciones (muestra la causa original).
    
    # Validar que sea un modelo sklearn
    if not hasattr(modelo, "predict"):   # hasattr(): verifica si el objeto tiene un atributo/método. Todos los modelos sklearn tienen predict().
        raise ValueError(f"El archivo no contiene un modelo válido: {path}")
    
    logger.info(f"Modelo cargado exitosamente: {path}")  # info(): mensaje informativo (menos grave que error).
    return modelo                        # Si llegamos aquí, todo salió bien. Retornamos el modelo cargado.

# Uso con manejo de error
try:                                     # try/except: patrón para manejar errores sin que el programa crashee.
    modelo = cargar_modelo(Path("models/pipeline.joblib"))  # Path(): convierte string a objeto Path.
except FileNotFoundError:                # Captura SOLO FileNotFoundError. Otros errores no se capturan aquí.
    print("⚠️ Modelo no encontrado. Ejecuta 'make train' primero.")  # Mensaje amigable al usuario.
except ValueError as e:                  # Captura ValueError. "as e" permite acceder al mensaje de error.
    print(f"❌ Error de validación: {e}")  # f-string con el error específico.
```

### 🎯 Ejercicio de Auto-evaluación: ¿Estás Listo?

Antes de continuar, verifica que puedes responder estas preguntas:

```python
# 1. ¿Qué hace este código?
def process(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items if item}

# 2. ¿Por qué esto es mejor que usar un diccionario?
@dataclass
class Config:
    batch_size: int = 32
    learning_rate: float = 0.001

# 3. ¿Qué problema evita el "with"?
with open("file.txt") as f:
    data = f.read()

# 4. ¿Qué imprime este código?
def decorator(func):
    def wrapper():
        print("antes")
        func()
        print("después")
    return wrapper

@decorator
def hello():
    print("hola")

hello()
```

<details>
<summary>🔍 Ver respuestas</summary>

1. **Crea un diccionario** donde las keys son strings no vacíos y los values son sus longitudes.

2. **Validación y documentación automática**: `@dataclass` genera `__init__`, `__repr__`, y permite type hints. Un diccionario no valida tipos ni tiene autocompletado en el IDE.

3. **Evita dejar archivos abiertos**: Si hay un error dentro del `with`, el archivo se cierra automáticamente.

4. **Imprime**:
   ```
   antes
   hola
   después
   ```
   El decorador "envuelve" la función original.

</details>

---

<a id="11-type-hints-tu-contrato-con-el-futuro"></a>

## 1.1 Type Hints: Tu Contrato con el Futuro

### La Analogía del Restaurante

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  🍽️ IMAGINA UN RESTAURANTE:                                               ║
║                                                                           ║
║  SIN MENÚ (código sin tipos):                                             ║
║  - "Tráeme algo de comer"                                                 ║
║  - El chef improvisa                                                      ║
║  - El cliente no sabe qué esperar                                         ║
║  - Resultado: sorpresas (bugs)                                            ║
║                                                                           ║
║  CON MENÚ (código con tipos):                                             ║
║  - "Quiero el plato #5: Pasta Carbonara"                                  ║
║  - El chef sabe exactamente qué preparar                                  ║
║  - El cliente sabe qué recibirá                                           ║
║  - Resultado: consistencia                                                ║
║                                                                           ║
║  TYPE HINTS = El menú de tu código                                        ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Código Real del Portafolio: Sin Tipos vs Con Tipos

```python
# ❌ ANTES: ¿Qué recibe? ¿Qué retorna? 
# (Esto es lo que encontrarías en un notebook)

def prepare_features(df, num_cols, cat_cols, target):  # Define una función sin type hints: no sabemos tipos esperados ni retornos.
    X = df.drop(columns=[target])  # Separa features (X) eliminando la columna objetivo del DataFrame.
    y = df[target]  # Extrae el target (y) como una Serie; asume que `target` existe y está bien escrito.
    
    preprocessor = ColumnTransformer([  # Crea un transformador por columnas: aplica pipelines distintos a columnas numéricas vs categóricas.
        ('num', StandardScaler(), num_cols),  # (nombre, transformer, columnas): escala numéricas a media=0, var=1 (ayuda a muchos modelos).
        ('cat', OneHotEncoder(), cat_cols)  # One-hot a categóricas; por defecto puede fallar si aparece una categoría nueva en inferencia.
    ])  # Termina la definición del ColumnTransformer (aún no se ha entrenado/ajustado).
    
    X_transformed = preprocessor.fit_transform(X)  # Ajusta (fit) el preprocesador usando X y luego transforma X; devuelve una matriz (a menudo sparse).
    return X_transformed, y, preprocessor  # Retorna features transformadas, el target y el preprocesador ya ajustado (para usar igual en valid/test/inferencia).
```

```python
# ✅ DESPUÉS: Código real de BankChurn-Predictor/src/bankchurn/training.py

from __future__ import annotations  # Posponer evaluación de anotaciones: permite forward refs y reduce problemas de import/ciclos.

from pathlib import Path  # Paths tipados/seguros (mejor que strings) para rutas de archivos/directorios.
from typing import List, Tuple  # Tipos genéricos para anotar colecciones y retornos compuestos.

import numpy as np  # NumPy: arrays y tipos numéricos; útil para tipar dtypes concretos.
import pandas as pd  # Pandas: DataFrame/Series, estructuras típicas para datos tabulares.
from numpy.typing import NDArray  # Tipo estático para arrays NumPy: ayuda a mypy a entender shapes/dtypes (hasta cierto punto).
from sklearn.compose import ColumnTransformer  # Enrutador de transformaciones por grupo de columnas (numéricas/categóricas/etc.).
from sklearn.preprocessing import OneHotEncoder, StandardScaler  # Transformadores estándar de scikit-learn.

def prepare_features(
    df: pd.DataFrame,  # Input tabular: se asume que contiene features + columna objetivo.
    num_cols: List[str],  # Lista de nombres de columnas numéricas: se usará para escalar.
    cat_cols: List[str],  # Lista de nombres de columnas categóricas: se usará para one-hot.
    target: str  # Nombre de la columna objetivo (label) que se va a separar en y.
) -> Tuple[NDArray[np.float64], pd.Series, ColumnTransformer]:
    """Prepara features para entrenamiento.
    
    Parameters
    ----------
    df : pd.DataFrame
        DataFrame con datos crudos.
    num_cols : List[str]
        Nombres de columnas numéricas.
    cat_cols : List[str]
        Nombres de columnas categóricas.
    target : str
        Nombre de la columna objetivo.
    
    Returns
    -------
    Tuple[NDArray, pd.Series, ColumnTransformer]
        Features transformadas, target, y preprocessor fitted.
    """
    X = df.drop(columns=[target])  # Construye X eliminando la columna objetivo: evita leakage obvio (target dentro de features).
    y = df[target]  # Construye y como Serie: etiqueta que el modelo intentará predecir.
    
    preprocessor = ColumnTransformer([  # Define el pipeline de preprocesamiento: se “fija” aquí para ser reproducible.
        ('num', StandardScaler(), num_cols),  # Escalado numérico: útil para modelos lineales/NN; inofensivo para muchos casos.
        ('cat', OneHotEncoder(handle_unknown='ignore'), cat_cols)  # ignore evita crash en inferencia si llega una categoría nueva.
    ])  # Nota MLOps: guardar este objeto es clave para que producción use la misma transformación que entrenamiento.
    
    X_transformed = preprocessor.fit_transform(X)  # Ajusta el preprocesador (learn stats/categorías) y transforma X al espacio numérico.
    return X_transformed, y, preprocessor  # Retorna tuple explícita y tipada: mypy/IDE verifican contratos y ayudan en refactors.
```

### Los Tipos Esenciales para ML

```python
# ═══════════════════════════════════════════════════════════════════════════
# TIPOS BÁSICOS - Los usarás constantemente
# ═══════════════════════════════════════════════════════════════════════════

from typing import (                   # typing: módulo estándar de Python para anotaciones de tipos.
    List,       # Lista de elementos: List[str] = ["a", "b"]  # Lista donde TODOS los elementos son strings.
    Dict,       # Diccionario: Dict[str, float] = {"acc": 0.95}  # Dict con claves str y valores float.
    Tuple,      # Tupla fija: Tuple[int, int] = (100, 10)  # Tupla de exactamente 2 enteros.
    Optional,   # Puede ser None: Optional[Path] = None  # Equivale a Union[Path, None].
    Union,      # Múltiples tipos: Union[str, List[str]]  # Puede ser string O lista de strings.
    Any,        # Cualquier tipo (evitar si posible)  # Desactiva type checking - úsalo solo si es inevitable.
    Literal,    # Valores específicos: Literal["train", "eval"]  # SOLO puede ser "train" o "eval", nada más.
)
from pathlib import Path               # Path: ya explicado en excepciones. Mejor que strings para rutas.

# Ejemplos del portafolio real:

# BankChurn: features son listas de strings
features: List[str] = ["CreditScore", "Age", "Balance"]  # ": List[str]" indica el tipo. mypy verifica que sea correcto.

# CarVision: métricas son diccionario string->float
metrics: Dict[str, float] = {"rmse": 4794.27, "r2": 0.77}  # Claves son strings (nombres), valores son floats (números).

# TelecomAI: puede recibir path o None
model_path: Optional[Path] = None      # Optional[X] = puede ser X o None. Útil para parámetros opcionales.

# ═══════════════════════════════════════════════════════════════════════════
# TIPOS PARA ML - Específicos de Machine Learning
# ═══════════════════════════════════════════════════════════════════════════

import pandas as pd                    # pandas: la librería estándar para datos tabulares. Ya la vimos antes.
import numpy as np                     # numpy: librería para arrays numéricos de alto rendimiento. Base de sklearn/pandas.
from numpy.typing import NDArray       # NDArray: tipo para arrays numpy. NDArray[np.float64] = array de floats de 64 bits.
from sklearn.base import BaseEstimator # BaseEstimator: clase base de TODOS los modelos sklearn. Garantiza fit/predict.
from sklearn.pipeline import Pipeline  # Pipeline: encadena transformadores + modelo. Lo verás en módulo 07.

# DataFrame de pandas
def load_data(path: Path) -> pd.DataFrame:  # Retorna pd.DataFrame: indica que devuelve una tabla de pandas.
    return pd.read_csv(path)           # read_csv lee el archivo y retorna un DataFrame.

# Array NumPy tipado
def predict_proba(X: NDArray[np.float64]) -> NDArray[np.float64]:  # NDArray[np.float64]: array de floats 64-bit.
    return model.predict_proba(X)[:, 1]  # predict_proba retorna probabilidades. [:, 1] selecciona columna 1 (clase positiva).

# Modelo sklearn
def train_model(X: NDArray, y: NDArray) -> BaseEstimator:  # Retorna BaseEstimator: cualquier modelo sklearn.
    model = RandomForestClassifier()   # Crea instancia del modelo. RandomForest: ensemble de árboles de decisión.
    model.fit(X, y)                    # fit(): entrena el modelo con datos X (features) e y (target).
    return model                       # Retorna el modelo entrenado (listo para predict).

# ═══════════════════════════════════════════════════════════════════════════
# TIPOS AVANZADOS - Para código más robusto
# ═══════════════════════════════════════════════════════════════════════════

from typing import TypedDict, Literal  # TypedDict: dict con estructura fija. Literal: valores específicos.

# TypedDict: diccionarios con estructura conocida
class MetricsDict(TypedDict):          # TypedDict: define un diccionario donde cada clave tiene tipo específico.
    accuracy: float                    # La clave "accuracy" DEBE ser float. mypy lo verifica.
    precision: float                   # Todas las métricas de clasificación son floats.
    recall: float                      # recall: proporción de positivos reales detectados.
    f1: float                          # f1: media armónica de precision y recall.
    roc_auc: float                     # roc_auc: área bajo la curva ROC. 1.0 = perfecto.

# Literal: solo valores específicos permitidos
ModelType = Literal["random_forest", "logistic", "gradient_boosting"]  # Crea un "tipo alias" que solo acepta estos 3 strings.

def build_model(model_type: ModelType, seed: int) -> BaseEstimator:  # model_type SOLO puede ser uno de los 3 valores.
    """
    mypy SABE que model_type solo puede ser estos 3 valores.
    Si escribes build_model("xgboost", 42), mypy dará error.
    """
    if model_type == "random_forest":  # Compara string. Python permite esto aunque model_type sea Literal.
        return RandomForestClassifier(random_state=seed)  # random_state: semilla para reproducibilidad.
    elif model_type == "logistic":     # elif: "else if" - solo se evalúa si el if anterior fue False.
        return LogisticRegression(random_state=seed)      # LogisticRegression: modelo lineal para clasificación.
    else:  # gradient_boosting         # else: se ejecuta si ningún if/elif fue True.
        return GradientBoostingClassifier(random_state=seed)  # GradientBoosting: ensemble de árboles secuenciales.
```

### Configurar mypy

Añade esto a tu `pyproject.toml`:

```toml
# pyproject.toml - Configuración de mypy
[tool.mypy]
python_version = "3.11"
warn_return_any = true
warn_unused_ignores = true
disallow_untyped_defs = true      # ← Fuerza tipos en todas las funciones
ignore_missing_imports = true     # ← Para librerías sin stubs

# Ignorar librerías de ML que no tienen stubs completos
[[tool.mypy.overrides]]
module = [
    "sklearn.*",
    "pandas.*", 
    "numpy.*",
    "mlflow.*",
    "joblib.*",
]
ignore_missing_imports = true
```

Ejecutar:
```bash
mypy src/  # Verifica tipos en todo el código
```

---

<a id="12-pydantic-validation-automatica"></a>

## 1.2 Pydantic: Validación Automática

### La Analogía del Guardia de Seguridad

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  🛡️ IMAGINA UN EDIFICIO DE OFICINAS:                                      ║
║                                                                           ║
║  SIN GUARDIA (código sin Pydantic):                                       ║
║  - Cualquiera entra con cualquier cosa                                    ║
║  - Descubres problemas CUANDO YA PASARON                                  ║
║  - "¿Por qué hay un test_size de 1.5?" → Error en producción              ║
║                                                                           ║
║  CON GUARDIA (código con Pydantic):                                       ║
║  - Verifica credenciales EN LA ENTRADA                                    ║
║  - Problemas detectados ANTES de causar daño                              ║
║  - "test_size debe ser entre 0 y 1" → Error inmediato y claro             ║
║                                                                           ║
║  PYDANTIC = El guardia de tu configuración                                ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Código Real: BankChurn Config (Nivel Staff)

Este es el archivo `src/bankchurn/config.py` del portafolio:

```python
"""Configuration management for BankChurn predictor.

Este módulo demuestra Pydantic a nivel profesional:
- Validación de rangos con Field
- Configuraciones anidadas
- Valores por defecto sensatos
- Carga desde YAML
"""

from __future__ import annotations

from pathlib import Path
from typing import Any, List

import yaml
from pydantic import BaseModel, Field


# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURACIONES ANIDADAS - Cada componente tiene su propia config
# ═══════════════════════════════════════════════════════════════════════════

class LogisticRegressionConfig(BaseModel):
    """Hiperparámetros de Logistic Regression."""
    C: float = 0.1
    class_weight: str = "balanced"
    solver: str = "liblinear"
    max_iter: int = 1000


class RandomForestConfig(BaseModel):
    """Hiperparámetros de Random Forest."""
    n_estimators: int = 100
    max_depth: int = 10
    min_samples_split: int = 10
    min_samples_leaf: int = 5
    class_weight: str = "balanced_subsample"
    n_jobs: int = -1


class EnsembleConfig(BaseModel):
    """Configuración del ensemble."""
    voting: str = Field("soft", pattern="^(hard|soft)$")  # ← Solo permite "hard" o "soft"
    weights: List[float] = [0.4, 0.6]


# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURACIÓN PRINCIPAL - Agrupa todo con validación
# ═══════════════════════════════════════════════════════════════════════════

class ModelConfig(BaseModel):
    """Configuración de entrenamiento del modelo."""
    type: str = "ensemble"
    test_size: float = Field(0.2, ge=0.0, le=1.0)   # ← VALIDACIÓN: entre 0 y 1
    random_state: int = 42
    cv_folds: int = Field(5, ge=2)                   # ← VALIDACIÓN: mínimo 2
    resampling_strategy: str = "none"
    
    # Configuraciones de modelos específicos (anidadas)
    ensemble: EnsembleConfig = EnsembleConfig()
    logistic_regression: LogisticRegressionConfig = LogisticRegressionConfig()
    random_forest: RandomForestConfig = RandomForestConfig()


class DataConfig(BaseModel):
    """Configuración de datos."""
    target_column: str = "Exited"
    categorical_features: List[str] = []
    numerical_features: List[str] = []
    drop_columns: List[str] = []


class MLflowConfig(BaseModel):
    """Configuración de MLflow tracking."""
    tracking_uri: str = "file:./mlruns"
    experiment_name: str = "bankchurn"
    enabled: bool = True


# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURACIÓN RAÍZ - El punto de entrada
# ═══════════════════════════════════════════════════════════════════════════

class BankChurnConfig(BaseModel):
    """Configuración completa de BankChurn.
    
    Uso:
        config = BankChurnConfig.from_yaml("configs/config.yaml")
        print(config.model.test_size)  # 0.2
    """
    model: ModelConfig
    data: DataConfig
    mlflow: MLflowConfig

    @classmethod
    def from_yaml(cls, config_path: str | Path) -> BankChurnConfig:
        """Carga configuración desde archivo YAML.
        
        Parameters
        ----------
        config_path : str or Path
            Ruta al archivo YAML.
            
        Returns
        -------
        BankChurnConfig
            Configuración validada.
            
        Raises
        ------
        FileNotFoundError
            Si el archivo no existe.
        ValidationError
            Si la configuración es inválida.
        """
        config_path = Path(config_path)
        
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")
        
        with open(config_path, "r") as f:
            config_dict = yaml.safe_load(f) or {}
        
        # Valores por defecto para secciones faltantes
        if "model" not in config_dict:
            config_dict["model"] = ModelConfig().dict()
        if "data" not in config_dict:
            config_dict["data"] = DataConfig().dict()
        if "mlflow" not in config_dict:
            config_dict["mlflow"] = MLflowConfig().dict()
        
        return cls(**config_dict)  # ← Pydantic valida automáticamente
```

### El YAML Correspondiente

```yaml
# configs/config.yaml
model:
  type: ensemble
  test_size: 0.2         # Si pones 1.5, Pydantic dará error
  random_state: 42
  cv_folds: 5            # Si pones 1, Pydantic dará error
  resampling_strategy: none
  
  ensemble:
    voting: soft         # Si pones "maybe", Pydantic dará error
    weights: [0.4, 0.6]
    
  random_forest:
    n_estimators: 200
    max_depth: 10

data:
  target_column: Exited
  categorical_features:
    - Geography
    - Gender
  numerical_features:
    - CreditScore
    - Age
    - Balance
  drop_columns:
    - RowNumber
    - CustomerId
    - Surname

mlflow:
  tracking_uri: "file:./mlruns"
  experiment_name: bankchurn
  enabled: true
```

### Ejemplo de Error de Validación

```python
# ❌ Esto FALLA inmediatamente con un error claro

config_dict = {
    "model": {
        "test_size": 1.5,  # ← Error: debe ser <= 1.0
        "cv_folds": 1,     # ← Error: debe ser >= 2
    },
    "data": {},
    "mlflow": {}
}

try:
    config = BankChurnConfig(**config_dict)
except ValidationError as e:
    print(e)
    # Output:
    # 2 validation errors for BankChurnConfig
    # model -> test_size
    #   ensure this value is less than or equal to 1.0 (type=value_error.number.not_le)
    # model -> cv_folds
    #   ensure this value is greater than or equal to 2 (type=value_error.number.not_ge)
```

---

<a id="13-src-layout-estructura-profesional"></a>

## 1.3 src/ Layout: Estructura Profesional

### La Analogía de la Casa

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  🏠 IMAGINA ORGANIZAR UNA CASA:                                           ║
║                                                                           ║
║  CASA DESORDENADA (código en raíz):                                       ║
║  - Todo en el living: ropa, comida, herramientas                          ║
║  - Imposible encontrar algo                                               ║
║  - Invitas a alguien: "perdón por el desorden"                            ║
║                                                                           ║
║  CASA ORGANIZADA (src/ layout):                                           ║
║  - Cocina para cocinar, baño para baño, closet para ropa                  ║
║  - Cada cosa en su lugar                                                  ║
║  - Invitas a alguien: "bienvenido, siéntate"                              ║
║                                                                           ║
║  src/ layout = Organización profesional de código                         ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Estructura del Portafolio

```
BankChurn-Predictor/
├── src/                          # ← TODO el código fuente aquí
│   ├── __init__.py               # Hace src/ un paquete
│   └── bankchurn/                # ← El paquete principal
│       ├── __init__.py           # Exporta la API pública
│       ├── config.py             # Configuración Pydantic
│       ├── training.py           # Pipeline de entrenamiento
│       ├── evaluation.py         # Métricas y evaluación
│       ├── prediction.py         # Inferencia
│       ├── models.py             # Custom classifiers
│       └── cli.py                # Interfaz de línea de comandos
│
├── app/                          # ← Aplicaciones (no es un paquete)
│   └── fastapi_app.py            # API REST
│
├── tests/                        # ← Tests (espejo de src/)
│   ├── __init__.py
│   ├── conftest.py               # Fixtures compartidas
│   ├── test_config.py            # Tests para config.py
│   ├── test_training.py          # Tests para training.py
│   └── ...
│
├── configs/                      # ← Configuración externa
│   └── config.yaml
│
├── data/                         # ← Datos (gitignored)
│   └── raw/
│       └── Churn_Modelling.csv
│
├── artifacts/                    # ← Artefactos generados (gitignored)
│   ├── model.joblib
│   └── training_results.json
│
├── pyproject.toml                # ← Metadata del proyecto
├── Makefile                      # ← Comandos comunes
├── Dockerfile                    # ← Containerización
└── README.md                     # ← Documentación
```

### ¿Por qué src/ y no código en la raíz?

```python
# ❌ PROBLEMA: Sin src/, Python puede importar código no instalado
# Esto causa el famoso "funciona en mi máquina pero no en CI"

# Estructura plana (problemática):
# myproject/
# ├── mymodule.py
# └── tests/
#     └── test_mymodule.py

# En test_mymodule.py:
import mymodule  # ← ¿De dónde viene? ¿Del directorio actual? ¿De pip?

# ✅ SOLUCIÓN: Con src/, el código DEBE estar instalado para importar
# myproject/
# ├── src/
# │   └── mymodule/
# │       └── __init__.py
# └── tests/
#     └── test_mymodule.py

# En test_mymodule.py:
from mymodule import something  # ← Solo funciona si `pip install -e .`
```

### pyproject.toml: El Corazón del Proyecto

```toml
# pyproject.toml - Configuración completa del proyecto
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "bankchurn"
version = "1.0.0"
description = "Bank Customer Churn Prediction System"
authors = [
    {name = "Daniel Duque", email = "duque@example.com"}
]
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}

dependencies = [
    "pandas>=2.0.0",
    "scikit-learn>=1.3.0",
    "pydantic>=2.0.0",
    "pyyaml>=6.0",
    "mlflow>=2.9.0",
    "fastapi>=0.104.0",
    "uvicorn>=0.24.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
    "black>=23.0.0",
    "mypy>=1.7.0",
    "ruff>=0.1.0",
]

[project.scripts]
bankchurn = "bankchurn.cli:main"  # ← Comando CLI

# ═══════════════════════════════════════════════════════════════════════════
# HERRAMIENTAS
# ═══════════════════════════════════════════════════════════════════════════

[tool.setuptools.packages.find]
where = ["src"]  # ← Busca paquetes en src/

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = "-v --cov=src/bankchurn --cov-report=term-missing"

[tool.coverage.run]
source = ["src"]
omit = ["tests/*"]

[tool.coverage.report]
fail_under = 79  # ← Coverage mínimo para pasar CI

[tool.black]
line-length = 100
target-version = ["py311"]

[tool.mypy]
python_version = "3.11"
warn_return_any = true
disallow_untyped_defs = true
ignore_missing_imports = true
```

### Instalación en Modo Editable

```bash
# Instalar el paquete en modo editable (para desarrollo)
pip install -e .

# Ahora puedes importar desde cualquier lugar
python -c "from bankchurn.config import BankChurnConfig; print('✅ Funciona!')"

# Y los tests también funcionan
pytest tests/
```

---

<a id="14-principios-solid-para-ml"></a>

## 1.4 Principios SOLID para ML

### Single Responsibility: Un Módulo, Una Tarea

```python
# ❌ ANTES: Un archivo hace TODO
# training.py (500 líneas)
def train_model(data_path, config_path, output_path):
    # Carga datos (líneas 1-50)
    # Limpia datos (líneas 51-100)
    # Feature engineering (líneas 101-200)
    # Entrena modelo (líneas 201-300)
    # Evalúa modelo (líneas 301-400)
    # Guarda artefactos (líneas 401-450)
    # Loguea a MLflow (líneas 451-500)
    pass

# ✅ DESPUÉS: Cada archivo tiene UNA responsabilidad
# src/bankchurn/
# ├── data.py         → Solo carga y valida datos
# ├── features.py     → Solo feature engineering
# ├── training.py     → Solo entrenamiento
# ├── evaluation.py   → Solo métricas
# └── prediction.py   → Solo inferencia
```

### Código Real del Portafolio

```python
# src/bankchurn/training.py - SOLO se encarga de entrenar
class ChurnTrainer:
    """Training pipeline - Single Responsibility."""
    
    def __init__(self, config: BankChurnConfig):
        self.config = config
    
    def load_data(self, path: Path) -> pd.DataFrame:
        """Delega a módulo de datos."""
        pass
    
    def prepare_features(self, df: pd.DataFrame) -> Tuple[pd.DataFrame, pd.Series]:
        """Prepara X e y."""
        pass
    
    def build_pipeline(self) -> Pipeline:
        """Construye el pipeline sklearn."""
        pass
    
    def fit(self, X: pd.DataFrame, y: pd.Series) -> None:
        """Entrena el modelo."""
        pass
    
    def cross_validate(self, X: pd.DataFrame, y: pd.Series) -> Dict[str, float]:
        """Valida con CV."""
        pass

# src/bankchurn/evaluation.py - SOLO se encarga de evaluar
def evaluate_model(
    model: Pipeline,
    X_test: pd.DataFrame,
    y_test: pd.Series
) -> Dict[str, float]:
    """Calcula métricas - Single Responsibility."""
    y_pred = model.predict(X_test)
    y_proba = model.predict_proba(X_test)[:, 1]
    
    return {
        "accuracy": accuracy_score(y_test, y_pred),
        "precision": precision_score(y_test, y_pred),
        "recall": recall_score(y_test, y_pred),
        "f1": f1_score(y_test, y_pred),
        "roc_auc": roc_auc_score(y_test, y_proba),
    }
```

---

<a id="15-oop-para-ml"></a>

## 1.5 OOP para ML: Protocolos y Clases Abstractas

> **CRÍTICO**: Sin entender OOP profesional, NO podrás leer el código del Portafolio.

### El Problema: Código No Intercambiable

```python
# ❌ CÓDIGO JUNIOR: Cada trainer tiene API diferente
class TrainerA:
    def entrenar(self, X, y): ...  # español
    def predecir(self, X): ...

class TrainerB:
    def fit_model(self, features, labels): ...  # nombres diferentes
    def get_predictions(self, features): ...

# ¿Cómo escribo código genérico que funcione con ambos?
# Imposible sin reescribir todo.
```

### La Solución: Protocol y ABC

```python
# ═══════════════════════════════════════════════════════════════════════════
# PROTOCOL: Duck Typing verificable por mypy (para sklearn y librerías externas)
# ═══════════════════════════════════════════════════════════════════════════
from typing import Protocol, runtime_checkable
from numpy.typing import ArrayLike

@runtime_checkable
class Predictor(Protocol):
    """Si tiene fit() y predict() con estas firmas, ES un Predictor."""
    
    def fit(self, X: ArrayLike, y: ArrayLike) -> "Predictor": ...
    def predict(self, X: ArrayLike) -> ArrayLike: ...

# sklearn cumple automáticamente sin modificar nada:
from sklearn.ensemble import RandomForestClassifier
assert isinstance(RandomForestClassifier(), Predictor)  # True!


# ═══════════════════════════════════════════════════════════════════════════
# ABC: Contrato que OBLIGA implementación (para TUS clases)
# ═══════════════════════════════════════════════════════════════════════════
from abc import ABC, abstractmethod
import pandas as pd

class BaseTrainer(ABC):
    """Clase base para todos los trainers del portafolio.
    
    BankChurn, CarVision y TelecomAI DEBEN implementar estos métodos.
    Si no lo hacen, Python da error al instanciar.
    """
    
    @abstractmethod
    def fit(self, X: pd.DataFrame, y: pd.Series) -> "BaseTrainer":
        """Entrena el modelo."""
        pass
    
    @abstractmethod
    def predict(self, X: pd.DataFrame) -> pd.Series:
        """Genera predicciones."""
        pass
    
    @abstractmethod
    def evaluate(self, X: pd.DataFrame, y: pd.Series) -> dict[str, float]:
        """Evalúa el modelo."""
        pass
    
    # Método concreto que usa los abstractos
    def fit_and_evaluate(
        self, 
        X_train: pd.DataFrame, y_train: pd.Series,
        X_test: pd.DataFrame, y_test: pd.Series
    ) -> dict[str, float]:
        """Entrena y evalúa en un paso."""
        self.fit(X_train, y_train)
        return self.evaluate(X_test, y_test)


# Implementación concreta:
class ChurnTrainer(BaseTrainer):
    """Trainer de BankChurn - DEBE implementar fit, predict, evaluate."""
    
    def fit(self, X: pd.DataFrame, y: pd.Series) -> "ChurnTrainer":
        self._pipeline = self._build_pipeline()
        self._pipeline.fit(X, y)
        return self
    
    def predict(self, X: pd.DataFrame) -> pd.Series:
        return pd.Series(self._pipeline.predict(X))
    
    def evaluate(self, X: pd.DataFrame, y: pd.Series) -> dict[str, float]:
        y_pred = self.predict(X)
        return {"accuracy": accuracy_score(y, y_pred)}
```

### Puente al Portafolio

Crear `common_utils/base.py` con `BaseTrainer` para que los 3 proyectos compartan la misma interfaz.

---

<a id="16-pandera-validacion-dataframes"></a>

## 1.6 Pandera: Validación de DataFrames

> **CRÍTICO**: Sin Pandera, los errores de datos aparecen en sklearn, no donde ocurrieron.

### El Problema: DataFrames que Mienten

```python
# ❌ CÓDIGO JUNIOR: Asume que el DataFrame es correcto
def train_model(df: pd.DataFrame) -> Pipeline:
    X = df.drop("Exited", axis=1)  # ¿Y si "Exited" no existe?
    y = df["Exited"]               # ¿Y si tiene valores como 2, -1, None?
    
    pipeline.fit(X, y)
    return pipeline

# Todo parece funcionar... hasta que llegan datos corruptos:
bad_data = pd.DataFrame({
    "Age": [-5, 25, 200],        # Edad negativa y 200 años
    "Balance": [1000, -500, 0],  # Balance negativo
    "Exited": [0, 2, None],      # Valor 2 y None (no binario)
})
model = train_model(bad_data)  # NO DA ERROR, pero modelo es basura
```

### La Solución: Pandera Schema

```python
import pandera as pa
from pandera.typing import DataFrame, Series

class BankChurnSchema(pa.DataFrameModel):
    """Schema para datos de Bank Churn - producción."""
    
    CreditScore: Series[int] = pa.Field(ge=300, le=850, description="FICO score")
    Age: Series[int] = pa.Field(ge=18, le=100, description="Edad del cliente")
    Balance: Series[float] = pa.Field(ge=0, description="Balance en cuenta")
    NumOfProducts: Series[int] = pa.Field(ge=1, le=4)
    Exited: Series[int] = pa.Field(isin=[0, 1], description="Target binario")
    
    class Config:
        strict = True   # Rechaza columnas extra
        coerce = True   # Convierte tipos automáticamente


@pa.check_types  # Decorador que valida entrada automáticamente
def train_model(df: DataFrame[BankChurnSchema]) -> Pipeline:
    """DataFrame GARANTIZADO válido por Pandera."""
    X = df.drop("Exited", axis=1)
    y = df["Exited"]
    # Ahora podemos confiar en que los datos son correctos
    ...


# Error CLARO si datos son inválidos:
# SchemaError: Column 'Age' failed check: greater_than_or_equal_to(18)
```

### Schemas del Portafolio

```python
# src/bankchurn/schemas.py

class RawDataSchema(pa.DataFrameModel):
    """Schema permisivo para datos crudos (permite nulos)."""
    CreditScore: Series[float] = pa.Field(nullable=True)
    Age: Series[float] = pa.Field(nullable=True, ge=0)
    class Config:
        strict = False  # Permite columnas extra (RowNumber, etc.)


class ProcessedDataSchema(pa.DataFrameModel):
    """Schema estricto para datos listos para entrenar."""
    CreditScore: Series[int] = pa.Field(ge=300, le=850)
    Age: Series[int] = pa.Field(ge=18, le=100)
    Exited: Series[int] = pa.Field(isin=[0, 1])
    class Config:
        strict = True  # No permite columnas extra


@pa.check_types
def preprocess(raw: DataFrame[RawDataSchema]) -> DataFrame[ProcessedDataSchema]:
    """Pipeline validado: entrada permisiva, salida estricta."""
    df = raw.dropna()
    df = df.drop(columns=["RowNumber", "CustomerId", "Surname"])
    return df
```

---

<a id="17-ejercicios-practicos"></a>

## 1.7 Ejercicios Prácticos

### Ejercicio 1: Añadir Type Hints

```python
# ❌ Código sin tipos (típico de notebook)
# Tu tarea: Añade type hints completos

def process_training_data(df, config):
    target = config["target"]
    features = config["features"]
    
    X = df[features]
    y = df[target]
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=config.get("test_size", 0.2)
    )
    
    return X_train, X_test, y_train, y_test


def calculate_metrics(y_true, y_pred):
    return {
        "accuracy": accuracy_score(y_true, y_pred),
        "f1": f1_score(y_true, y_pred)
    }
```

<details>
<summary>📝 Ver Solución</summary>

```python
from typing import Dict, List, Tuple, Any
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, f1_score


def process_training_data(
    df: pd.DataFrame,
    config: Dict[str, Any]
) -> Tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series]:
    """Procesa datos para entrenamiento.
    
    Parameters
    ----------
    df : pd.DataFrame
        DataFrame con datos crudos.
    config : Dict[str, Any]
        Configuración con keys: "target", "features", "test_size" (opcional).
    
    Returns
    -------
    Tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series]
        X_train, X_test, y_train, y_test
    """
    target: str = config["target"]
    features: List[str] = config["features"]
    
    X: pd.DataFrame = df[features]
    y: pd.Series = df[target]
    
    test_size: float = config.get("test_size", 0.2)
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=42
    )
    
    return X_train, X_test, y_train, y_test


def calculate_metrics(
    y_true: pd.Series,
    y_pred: pd.Series
) -> Dict[str, float]:
    """Calcula métricas de clasificación.
    
    Parameters
    ----------
    y_true : pd.Series
        Labels verdaderos.
    y_pred : pd.Series
        Predicciones del modelo.
    
    Returns
    -------
    Dict[str, float]
        Diccionario con accuracy y f1.
    """
    return {
        "accuracy": float(accuracy_score(y_true, y_pred)),
        "f1": float(f1_score(y_true, y_pred))
    }
```

</details>

---

### Ejercicio 2: Crear Config con Pydantic

```python
# Tu tarea: Crea una configuración Pydantic para TelecomAI
# Requisitos:
# - project_name: str
# - random_seed: int (entre 0 y 1000)
# - test_size: float (entre 0.1 y 0.5)
# - model_type: solo puede ser "logreg", "random_forest", o "gradient_boosting"
# - features: lista de strings
# - target: str

# Escribe tu código aquí:
from pydantic import BaseModel, Field
from typing import List, Literal

class TelecomConfig(BaseModel):
    # ... tu código
    pass
```

<details>
<summary>📝 Ver Solución</summary>

```python
from pydantic import BaseModel, Field
from typing import List, Literal, Optional, Dict, Any
from pathlib import Path
import yaml


class TelecomConfig(BaseModel):
    """Configuración para TelecomAI Customer Intelligence."""
    
    project_name: str = Field(..., min_length=1)
    random_seed: int = Field(42, ge=0, le=1000)
    test_size: float = Field(0.2, ge=0.1, le=0.5)
    model_type: Literal["logreg", "random_forest", "gradient_boosting"] = "logreg"
    features: List[str] = Field(..., min_items=1)
    target: str
    
    # Opcionales
    threshold: float = Field(0.5, ge=0.0, le=1.0)
    mlflow_enabled: bool = True
    
    @classmethod
    def from_yaml(cls, path: str | Path) -> "TelecomConfig":
        with open(path) as f:
            data = yaml.safe_load(f)
        return cls(**data)
    
    class Config:
        extra = "forbid"  # No permite campos extra en el YAML


# Uso:
config = TelecomConfig(
    project_name="TelecomAI",
    features=["calls", "minutes", "messages", "mb_used"],
    target="is_ultra"
)

# Esto FALLA:
# config = TelecomConfig(
#     project_name="",  # Error: min_length=1
#     test_size=0.8,    # Error: le=0.5
#     model_type="xgboost",  # Error: not in Literal
#     features=[],      # Error: min_items=1
# )
```

</details>

---

### Ejercicio 3: Convertir a src/ Layout

```
Tu tarea: Reorganiza esta estructura plana a src/ layout

ANTES:
myproject/
├── train.py
├── predict.py
├── utils.py
├── config.yaml
├── data.csv
└── test_train.py

DESPUÉS:
myproject/
├── src/
│   └── ???
├── tests/
│   └── ???
├── configs/
│   └── ???
├── data/
│   └── ???
└── pyproject.toml
```

<details>
<summary>📝 Ver Solución</summary>

```
myproject/
├── src/
│   ├── __init__.py
│   └── myproject/
│       ├── __init__.py
│       ├── training.py      # Antes: train.py
│       ├── prediction.py    # Antes: predict.py
│       └── utils.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py          # Fixtures compartidas
│   └── test_training.py     # Antes: test_train.py
├── configs/
│   └── config.yaml
├── data/
│   └── raw/
│       └── data.csv
├── artifacts/               # Para modelos generados
│   └── .gitkeep
├── pyproject.toml
├── Makefile
└── README.md
```

 </details>

---

## 🧨 Errores habituales y cómo depurarlos

En este módulo suelen aparecer siempre los mismos problemas. La idea no es solo evitarlos, sino **saber reconocerlos rápido** en tus propios proyectos.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) Type hints + mypy: errores ruidosos en pandas/sklearn

**Síntomas típicos**

- `Function is missing a type annotation for parameter 'df'`
- `Incompatible return value type (got "DataFrame", expected "Series")`
- Cientos de warnings en librerías externas (`pandas.*`, `sklearn.*`).
**Proceso para identificarlos**

- Ejecuta siempre:
  ```bash
  mypy src/  # o mypy src/bankchurn src/carvision src/telecomai
  ```
- Localiza primero los errores **en tu código** (archivos dentro de `src/`), ignora de momento los de librerías.
- Si ves muchos errores en `site-packages` o módulos externos, revisa tu sección `[tool.mypy]` del `pyproject.toml` (ver ejemplo en este mismo módulo).

**Cómo solucionarlos (patrón general)**

- Añade tipos a **todas las firmas públicas** (funciones/clases usadas fuera de su archivo).
- Usa tipos específicos para ML:
  - `pd.DataFrame`, `pd.Series`
  - `NDArray[np.float64]`
  - `BaseEstimator`, `Pipeline`
- Aísla tipos muy complejos usando `TypedDict` o `Alias`:
  ```python
  class MetricsDict(TypedDict):
      accuracy: float
      f1: float
      roc_auc: float
  ```
- Para **reducir ruido de mypy** con librerías ML:
  - Configura `ignore_missing_imports = true` y los overrides mostrados en este módulo.
  - Re-lanza `mypy` y verifica que solo quedan errores en tu código.

> 💡 **Regla práctica**: si mypy empieza a gritar en medio de un refactor, reduce el problema a una función pequeña, tipa bien esa función, y después propaga los tipos al resto.

---

### 2) Pydantic: `ValidationError` por config mal definida

**Síntomas típicos**

- Al cargar la configuración:
  ```text
  pydantic.error_wrappers.ValidationError: 2 validation errors for ModelConfig
  model -> test_size
    ensure this value is less than or equal to 1.0 (type=value_error.number.not_le)
  model -> cv_folds
    ensure this value is greater than or equal to 2 (type=value_error.number.not_ge)
  ```
- Tu servicio/API no arranca porque falla la lectura de `config.yaml`.

**Proceso para identificarlos**

- Localiza **qué modelo Pydantic** está fallando (`ModelConfig`, `BankChurnConfig`, `TelecomConfig`, etc.).
- Revisa el `traceback`: casi siempre indica **la ruta completa del campo** (`model -> test_size`, `data -> categorical_features`, etc.).
- Abre el YAML correspondiente (`configs/config.yaml`) y compara **valor real** vs **restricción en `Field(...)`**.

**Cómo solucionarlos (patrón general)**

- Ajusta el YAML para respetar los rangos:
  - `test_size` entre `0.0` y `1.0`.
  - `cv_folds` ≥ 2.
  - Literales válidos (`voting: "hard" | "soft"`, `model_type: "logreg" | "random_forest" | ...`).
- Si el error te parece injustificado, revisa la declaración del modelo:
  ```python
  test_size: float = Field(0.2, ge=0.0, le=1.0)
  ```
  Quizá necesitas permitir un rango distinto en tu contexto.
- En desarrollo, **falla rápido**: no atrapes el `ValidationError` salvo para mostrar un mensaje más amigable; deja que la app se caiga antes que usar una config corrupta.

> 🔧 **Ejercicio mental**: rompe a propósito tu `configs/config.yaml` (pon `test_size: 1.5`) y observa el error. Luego arréglalo. Hazlo una vez y nunca más te asustará un `ValidationError` en producción.

---

### 3) src/ layout e imports: `ModuleNotFoundError` en CI pero no en tu máquina

**Síntomas típicos**

- En local “todo funciona”, pero en GitHub Actions o en otra máquina obtienes:
  ```text
  ModuleNotFoundError: No module named 'bankchurn'
  ```
- Los tests solo pasan si ejecutas `pytest` desde la raíz exacta del proyecto.

**Proceso para identificarlos**

- Revisa la **estructura** de tu proyecto (debería parecerse al diagrama de este módulo):
  - Código dentro de `src/<paquete>/`.
  - Tests bajo `tests/` usando imports del paquete, no rutas relativas raras.
- Verifica tu `pyproject.toml`:
  - `[project.name]` coincide con el paquete (`bankchurn`, `carvision`, `telecomai`).
  - `[tool.setuptools.packages.find] where = ["src"]`.
- Comprueba si instalaste en modo editable:
  ```bash
  pip install -e .
  python -c "import bankchurn; print(bankchurn.__file__)"
  ```

**Cómo solucionarlos (patrón general)**

- Mueve el código de raíz a `src/` siguiendo el ejemplo de este módulo.
- Cambia imports tipo:
  ```python
  # ❌ from .training import train_model  (desde scripts sueltos)
  # ✅ from bankchurn.training import train_model
  ```
- Asegúrate de que los comandos de CI usan instalación editable:
  ```yaml
  - name: Install
    run: pip install -e ".[dev]"
  ```

> ⚠️ **Bandera roja**: si tus tests solo funcionan cuando haces `cd src` o ajustas manualmente `PYTHONPATH`, tu layout todavía no está bien resuelto.

---

### 4) Patrón general de debugging para este módulo

1. **Reproduce el error** con un comando simple y determinista:
   - `mypy src/`
   - `python -m src.proyecto.training`
   - `pytest -k nombre_test`.
2. **Lee literalmente** el mensaje de error (campo, valor, restricción).
3. **Conecta el error con el concepto del módulo**:
   - Type hints → firma de función o tipo de retorno.
   - Pydantic → `Field(...)` y YAML.
   - src/ layout → estructura de carpetas + `pyproject.toml` + instalación editable.
4. **Aplica el patrón de solución** que viste arriba.

Si automatizas este ciclo en tus tres proyectos del portafolio, tu tiempo de debugging se reduce drásticamente y es justo lo que se espera de un perfil Senior/Staff.

---

## ✅ Checkpoint: ¿Completaste el Módulo?

Antes de continuar, verifica:

- [ ] Tu código tiene type hints en todas las funciones
- [ ] Puedes ejecutar `mypy src/` sin errores críticos
- [ ] Tienes al menos una clase Pydantic para configuración
- [ ] Tu proyecto tiene estructura src/ layout
- [ ] Puedes instalar tu paquete con `pip install -e .`

---

## 🔗 ADR: ¿Por Qué Estas Decisiones?

### ADR-001: Type Hints Obligatorios

**Contexto**: El código de ML suele ser difícil de mantener porque las funciones aceptan "cualquier cosa".

**Decisión**: Requerimos type hints en todas las funciones públicas.

**Consecuencias**:
- ✅ El IDE autocompleta correctamente
- ✅ Errores detectados antes de ejecutar
- ✅ Documentación implícita
- ❌ Más código que escribir inicialmente
- ❌ Curva de aprendizaje para tipos complejos

### ADR-002: Pydantic para Configuración

**Contexto**: Configuraciones en diccionarios son propensas a errores.

**Decisión**: Toda configuración pasa por Pydantic.

**Consecuencias**:
- ✅ Validación automática
- ✅ Errores claros
- ✅ Documentación de la config
- ❌ Dependencia adicional
- ❌ Más verboso que un dict simple

### ADR-003: src/ Layout

**Contexto**: Código en raíz causa problemas de importación.

**Decisión**: Todo código en `src/<paquete>/`.

**Consecuencias**:
- ✅ Importaciones consistentes
- ✅ Funciona igual en desarrollo y CI
- ✅ Estándar de la industria
- ❌ Requiere `pip install -e .`
- ❌ Path más largo para imports

---

## 📦 Cómo se Usó en el Portafolio

Este módulo se aplica **directamente** en los 3 proyectos del portafolio. Aquí están los archivos reales que implementan cada concepto:

### Type Hints en el Portafolio

```python
# BankChurn-Predictor/src/bankchurn/config.py (líneas 89-109)
@classmethod
def from_yaml(cls, config_path: str | Path) -> BankChurnConfig:
    """Load configuration from YAML file.
    
    Parameters
    ----------
    config_path : str or Path
        Path to YAML configuration file.
    
    Returns
    -------
    config : BankChurnConfig
        Validated configuration object.
    """
```

### Pydantic en el Portafolio

Cada proyecto tiene su configuración Pydantic:

| Proyecto | Archivo | Clases principales |
|----------|---------|-------------------|
| BankChurn | `src/bankchurn/config.py` | `BankChurnConfig`, `ModelConfig`, `DataConfig` |
| CarVision | `src/carvision/config.py` | `CarVisionConfig`, `FiltersConfig` |
| TelecomAI | `src/telecomai/config.py` | `TelecomConfig` |

```python
# Ejemplo real: BankChurn-Predictor/src/bankchurn/config.py
class ModelConfig(BaseModel):
    """Model training configuration."""
    type: str = "ensemble"
    test_size: float = Field(0.2, ge=0.0, le=1.0)  # ← Validación automática
    random_state: int = 42
    cv_folds: int = Field(5, ge=2)  # ← Mínimo 2 folds
```

### src/ Layout en el Portafolio

Los 3 proyectos siguen exactamente la estructura descrita:

```
BankChurn-Predictor/
├── src/bankchurn/       ← Paquete instalable
│   ├── __init__.py
│   ├── config.py        ← Pydantic configs
│   ├── pipeline.py      ← sklearn Pipeline
│   └── trainer.py       ← Clase de entrenamiento
├── pyproject.toml       ← Metadata y dependencias
└── setup.py             ← Fallback para pip install -e .
```

### 🔧 Ejercicio: Verifica en el Repo Real

```bash
# 1. Ve al proyecto BankChurn
cd BankChurn-Predictor

# 2. Instala en modo editable
pip install -e ".[dev]"

# 3. Verifica tipos con mypy
mypy src/bankchurn/config.py

# 4. Prueba que Pydantic valida correctamente
python -c "from bankchurn.config import BankChurnConfig; print(BankChurnConfig.from_yaml('configs/config.yaml'))"
```

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **Domina Type Hints**: Los entrevistadores valoran código tipado. Practica explicar por qué `def process(data: pd.DataFrame) -> Dict[str, float]` es mejor que `def process(data)`.

2. **Conoce Pydantic vs Dataclasses**: Pregunta común: "¿Cuándo usarías uno u otro?" Respuesta: Pydantic para validación de datos externos (APIs, configs), dataclasses para estructuras internas simples.

3. **Demuestra comprensión de `__init__.py`**: Explica cómo controla la API pública de un paquete y por qué `from package import *` es peligroso.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Código legacy sin tipos | Añade tipos gradualmente, empezando por funciones públicas |
| Validación de configs | Usa Pydantic con `model_validator` para validaciones cruzadas |
| Logs en producción | Usa `structlog` o `loguru` en lugar de `print()` |
| Errores en producción | Implementa excepciones personalizadas con contexto útil |

### Anti-patrones a Evitar

- ❌ `from typing import *` — importa solo lo que necesitas
- ❌ `except Exception:` sin logging — siempre registra el error
- ❌ Funciones de más de 50 líneas — refactoriza en funciones más pequeñas
- ❌ Nombres como `data`, `info`, `result` — usa nombres descriptivos


---

## 📺 Recursos Externos Recomendados

> Ver [RECURSOS_POR_MODULO.md](RECURSOS_POR_MODULO.md) para la lista completa.

| 🏷️ | Recurso | Tipo |
|:--:|:--------|:-----|
| 🔴 | [Type Hints - ArjanCodes](https://www.youtube.com/watch?v=dgBCEB2jVU0) | Video |
| 🔴 | [Pydantic V2 Tutorial](https://www.youtube.com/watch?v=502XOB0u8OY) | Video |
| 🟡 | [Python Type Checking - Real Python](https://realpython.com/python-type-checking/) | Tutorial |

**Documentación oficial:**
- [PEP 484 – Type Hints](https://peps.python.org/pep-0484/)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [Python Packaging Guide](https://packaging.python.org/)

---

## 🔗 Referencias del Glosario

Ver [21_GLOSARIO.md](21_GLOSARIO.md) para definiciones de:
- **Type Hints**: Anotaciones de tipos en Python
- **Pydantic**: Validación de datos con type hints
- **src/ Layout**: Estructura de proyecto profesional

---

## ✅ Ejercicios

Ver [EJERCICIOS.md](EJERCICIOS.md) - Módulo 01:
- **1.1**: Añadir type hints a funciones
- **1.2**: Crear config con Pydantic
- **1.3**: Estructurar proyecto con src/ layout

---

<div align="center">

[← Volver al Índice](00_INDICE.md) | [Siguiente: Diseño de Sistemas ML →](02_DISENO_SISTEMAS.md)

</div>
