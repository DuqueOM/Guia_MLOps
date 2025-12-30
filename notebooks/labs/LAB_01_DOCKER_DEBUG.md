# 🔬 Lab 1: "Funciona en Local, Falla en Docker"

> **Escenario**: Tu modelo entrena perfecto localmente pero crashea en el contenedor  
> **Duración**: 30 minutos  
> **Habilidad**: Debugging de containerización

---

## El Escenario

Tu equipo reporta:

> "El pipeline de training funciona perfecto en mi laptop, pero cuando lo corro en Docker da error de import y luego el modelo predice diferente."

---

## Paso 1: Reproduce el Error

### Código Local (funciona)

```python
# train.py
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
import joblib

df = pd.read_csv("data/customers.csv")
X = df.drop("Exited", axis=1)
y = df["Exited"]

model = RandomForestClassifier(n_estimators=100)
model.fit(X, y)
joblib.dump(model, "model.pkl")
print("✅ Modelo guardado")
```

```bash
# Local
python train.py
# Output: ✅ Modelo guardado
```

### Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["python", "train.py"]
```

### Error en Docker

```bash
docker build -t mymodel .
docker run mymodel

# Output:
# Traceback (most recent call last):
#   File "/app/train.py", line 2, in <module>
#     from sklearn.ensemble import RandomForestClassifier
# ModuleNotFoundError: No module named 'sklearn'
```

---

## Paso 2: Diagnóstico

### 🔍 Revisa requirements.txt

```text
pandas
scikit-learn
joblib
```

**Pregunta**: ¿Ves el problema?

<details>
<summary>💡 Pista</summary>

El archivo tiene formato correcto, pero...
- ¿Las versiones están especificadas?
- ¿Hay alguna dependencia implícita?

</details>

---

## Paso 3: Error 1 - Dependencias sin Versión

### El Problema

```text
# requirements.txt MALO
pandas
scikit-learn
joblib
```

Sin versiones, `pip install` toma la última versión disponible.
- En tu laptop: instalaste hace 3 meses
- En Docker: instala la versión de HOY

### La Solución

```text
# requirements.txt BUENO
pandas==2.0.3
scikit-learn==1.3.0
joblib==1.3.2
```

### Cómo Obtener Versiones Exactas

```bash
pip freeze > requirements.txt
# O solo las principales:
pip freeze | grep -E "pandas|scikit|joblib"
```

---

## Paso 4: Error 2 - Path Hardcodeado

Después de arreglar dependencias, nuevo error:

```bash
docker run mymodel

# Output:
# FileNotFoundError: [Errno 2] No such file or directory: 'data/customers.csv'
```

### El Problema

```python
# ❌ Path relativo asume estructura local
df = pd.read_csv("data/customers.csv")
```

### La Solución

```python
# ✅ Path relativo al script, no al CWD
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent.resolve()
DATA_PATH = SCRIPT_DIR / "data" / "customers.csv"

df = pd.read_csv(DATA_PATH)
```

### O Mejor: Variable de Entorno

```python
import os
from pathlib import Path

DATA_PATH = Path(os.getenv("DATA_PATH", "data/customers.csv"))
df = pd.read_csv(DATA_PATH)
```

```dockerfile
ENV DATA_PATH=/app/data/customers.csv
```

---

## Paso 5: Error 3 - Modelo Predice Diferente

Ahora el training funciona, pero las predicciones son diferentes:

```bash
# Local
python predict.py
# Accuracy: 0.847

# Docker  
docker run mymodel python predict.py
# Accuracy: 0.823  # ← ¡Diferente!
```

### El Problema

```python
# ❌ Sin random_state
model = RandomForestClassifier(n_estimators=100)
```

RandomForest usa números aleatorios. Sin seed fijo:
- Cada ejecución da resultados diferentes
- Imposible reproducir

### La Solución

```python
# ✅ Seed fijo para reproducibilidad
model = RandomForestClassifier(
    n_estimators=100,
    random_state=42,  # ← Siempre el mismo resultado
    n_jobs=-1
)
```

---

## Paso 6: Error 4 - NumPy/Pickle Incompatible

```bash
# Error al cargar modelo en Docker:
# ValueError: numpy.ndarray size changed, may indicate binary incompatibility
```

### El Problema

- Modelo guardado con `numpy==1.24.0`
- Docker tiene `numpy==1.26.0`
- Pickle de sklearn es sensible a versiones

### La Solución

**Opción 1**: Pinear versiones exactas

```text
numpy==1.24.0
scikit-learn==1.3.0
```

**Opción 2**: Usar formato ONNX (portable)

```python
import skl2onnx
from skl2onnx import convert_sklearn

onnx_model = convert_sklearn(model, initial_types=[...])
with open("model.onnx", "wb") as f:
    f.write(onnx_model.SerializeToString())
```

**Opción 3**: MLflow (incluye metadata de versiones)

```python
import mlflow.sklearn

mlflow.sklearn.save_model(model, "model_mlflow")
# Guarda pip_requirements.txt automáticamente
```

---

## Dockerfile Final Corregido

```dockerfile
# ✅ Dockerfile de producción
FROM python:3.11-slim as base

# Evita .pyc y buffering
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Dependencias primero (cache de Docker)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Código después
COPY src/ ./src/
COPY configs/ ./configs/

# Usuario no-root
RUN useradd --create-home appuser
USER appuser

# Variables de entorno
ENV DATA_PATH=/app/data
ENV MODEL_PATH=/app/models

CMD ["python", "-m", "src.train"]
```

---

## Checklist de Debugging Docker

```
□ requirements.txt tiene versiones exactas
□ Paths usan Path() o variables de entorno  
□ random_state en todos los modelos
□ Versiones de numpy/sklearn coinciden
□ Dockerfile copia archivos en orden correcto
□ Usuario no-root para seguridad
□ Variables de entorno para configuración
```

---

## Ejercicio Final

Dado este error:

```
docker run mymodel
# RuntimeError: can't start new thread
```

**¿Cuál es la causa más probable?**

<details>
<summary>💡 Respuesta</summary>

`n_jobs=-1` en RandomForest intenta usar todos los cores.
En Docker con recursos limitados, puede fallar.

**Solución**:
```python
model = RandomForestClassifier(
    n_estimators=100,
    n_jobs=2,  # Limitar threads
    random_state=42
)
```

O en Docker:
```bash
docker run --cpus=2 mymodel
```

</details>
