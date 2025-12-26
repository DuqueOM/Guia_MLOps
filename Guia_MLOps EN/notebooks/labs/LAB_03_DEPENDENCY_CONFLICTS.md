# 🔬 Lab 3: Conflicto de Dependencias sklearn/Pickle

> **Escenario**: Modelo no carga en producción por incompatibilidad de versiones  
> **Duración**: 30 minutos  
> **Habilidad**: Gestión de dependencias y serialización

---

## El Escenario

Tu equipo reporta:

> "El modelo entrena bien en desarrollo pero no carga en el servidor de producción. Da error de numpy o pickle."

---

## Paso 1: Reproduce el Error

### Entorno de Desarrollo

```bash
# Tu máquina (donde entrenas)
pip freeze | grep -E "numpy|scikit"
# numpy==1.24.3
# scikit-learn==1.3.0
```

```python
# train.py
from sklearn.ensemble import RandomForestClassifier
import joblib

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)
joblib.dump(model, "model.joblib")
print("✅ Modelo guardado")
```

### Entorno de Producción

```bash
# Servidor (donde cargas)
pip freeze | grep -E "numpy|scikit"
# numpy==1.26.0  # ← DIFERENTE
# scikit-learn==1.4.0  # ← DIFERENTE
```

```python
# predict.py
import joblib

model = joblib.load("model.joblib")
# 💥 ERROR!
```

### El Error

```
Traceback (most recent call last):
  File "predict.py", line 3, in <module>
    model = joblib.load("model.joblib")
  ...
ModuleNotFoundError: No module named 'sklearn.ensemble._forest'

# O este otro error común:
ValueError: numpy.ndarray size changed, may indicate binary incompatibility. 
Expected 88 from C header, got 80 from PyObject
```

---

## Paso 2: Diagnóstico

### ¿Por qué ocurre?

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EL PROBLEMA DE PICKLE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   joblib/pickle guarda:                                                     │
│   ├── Los pesos del modelo (números)                                        │
│   ├── La estructura de clases (sklearn.ensemble._forest.RandomForest...)   │
│   └── Referencias a numpy arrays (con formato binario específico)          │
│                                                                             │
│   Si las versiones cambian:                                                 │
│   ├── sklearn puede renombrar módulos internos                             │
│   ├── numpy puede cambiar el formato binario de arrays                     │
│   └── El pickle no encuentra las clases originales                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Verificar Incompatibilidad

```python
# Inspeccionar metadata del modelo
import joblib
import pickle

# Ver qué versión se usó para guardar
with open("model.joblib", "rb") as f:
    # joblib no guarda metadata de versión por defecto
    pass

# En sklearn >= 1.3, puedes verificar:
try:
    model = joblib.load("model.joblib")
    print(f"sklearn version: {model.__sklearn_version__}")
except Exception as e:
    print(f"Error: {e}")
```

---

## Paso 3: Soluciones

### Solución 1: Pinear Versiones Exactas (Rápida)

```text
# requirements.txt
numpy==1.24.3
scikit-learn==1.3.0
joblib==1.3.2
```

```bash
# En producción
pip install -r requirements.txt
```

**Pros**: Fácil, rápido  
**Cons**: No resuelve el problema a largo plazo, dependencias pueden conflictuar

---

### Solución 2: Guardar con Metadata (Recomendada)

```python
# train.py
import joblib
import sklearn
import numpy as np
from pathlib import Path

def save_model_with_metadata(model, path: str):
    """Guarda modelo con metadata de versiones."""
    artifact = {
        "model": model,
        "metadata": {
            "sklearn_version": sklearn.__version__,
            "numpy_version": np.__version__,
            "python_version": "3.11",
            "created_at": "2024-01-15",
        }
    }
    joblib.dump(artifact, path)
    print(f"✅ Guardado con sklearn={sklearn.__version__}, numpy={np.__version__}")

def load_model_with_check(path: str):
    """Carga modelo verificando versiones."""
    artifact = joblib.load(path)
    
    meta = artifact["metadata"]
    
    # Verificar compatibilidad
    if sklearn.__version__ != meta["sklearn_version"]:
        print(f"⚠️ WARNING: Modelo entrenado con sklearn {meta['sklearn_version']}, "
              f"pero tienes {sklearn.__version__}")
    
    if np.__version__.split(".")[:2] != meta["numpy_version"].split(".")[:2]:
        print(f"⚠️ WARNING: Modelo entrenado con numpy {meta['numpy_version']}, "
              f"pero tienes {np.__version__}")
    
    return artifact["model"]

# Uso
save_model_with_metadata(model, "model_v1.joblib")
model = load_model_with_check("model_v1.joblib")
```

---

### Solución 3: Usar MLflow (Profesional)

```python
# train.py
import mlflow
import mlflow.sklearn

mlflow.set_experiment("bankchurn")

with mlflow.start_run():
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    # MLflow guarda automáticamente:
    # - El modelo
    # - requirements.txt con versiones exactas
    # - conda.yaml con entorno completo
    mlflow.sklearn.log_model(
        model,
        artifact_path="model",
        registered_model_name="bankchurn-classifier"
    )

# En producción:
model_uri = "models:/bankchurn-classifier/Production"
model = mlflow.sklearn.load_model(model_uri)
# MLflow verifica compatibilidad automáticamente
```

**Estructura que MLflow crea**:

```
mlruns/
└── <run_id>/
    └── artifacts/
        └── model/
            ├── MLmodel           # Metadata del modelo
            ├── model.pkl         # El modelo serializado
            ├── conda.yaml        # Entorno conda completo
            ├── requirements.txt  # Versiones pip exactas
            └── python_env.yaml   # Versión de Python
```

---

### Solución 4: ONNX (Máxima Portabilidad)

```python
# train.py
from skl2onnx import convert_sklearn
from skl2onnx.common.data_types import FloatTensorType

# Entrenar modelo sklearn
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Convertir a ONNX
initial_type = [("float_input", FloatTensorType([None, X_train.shape[1]]))]
onnx_model = convert_sklearn(model, initial_types=initial_type)

# Guardar
with open("model.onnx", "wb") as f:
    f.write(onnx_model.SerializeToString())
```

```python
# predict.py (producción)
import onnxruntime as rt
import numpy as np

# Cargar (NO depende de sklearn!)
sess = rt.InferenceSession("model.onnx")

# Predecir
input_name = sess.get_inputs()[0].name
predictions = sess.run(None, {input_name: X_test.astype(np.float32)})[0]
```

**Pros**: Máxima portabilidad, no depende de sklearn en producción  
**Cons**: No todos los modelos son convertibles, pierde algunos métodos

---

## Paso 4: Prevención

### En pyproject.toml

```toml
[project]
dependencies = [
    "numpy>=1.24.0,<1.25.0",      # Rango estrecho
    "scikit-learn>=1.3.0,<1.4.0", # Rango estrecho
    "joblib>=1.3.0,<1.4.0",
]
```

### En CI/CD

```yaml
# .github/workflows/ci.yml
- name: Check model compatibility
  run: |
    python -c "
    import joblib
    model = joblib.load('models/model.joblib')
    print(f'Model loaded successfully')
    print(f'sklearn version: {model.__sklearn_version__}')
    "
```

### En Dockerfile

```dockerfile
# Fijar versiones exactas
COPY requirements.lock .
RUN pip install --no-cache-dir -r requirements.lock

# requirements.lock generado con:
# pip freeze > requirements.lock
```

---

## Checklist de Debugging

```
□ Verificar versiones en desarrollo vs producción
□ Comparar numpy major.minor (1.24 vs 1.26 = incompatible)
□ Comparar sklearn major.minor (1.3 vs 1.4 = posiblemente incompatible)
□ Verificar que requirements.txt tiene versiones exactas
□ Considerar MLflow para tracking automático
□ Considerar ONNX para máxima portabilidad
```

---

## Ejercicio Final

Tienes este error:

```
AttributeError: module 'numpy' has no attribute 'bool'.
`np.bool` was a deprecated alias for the builtin `bool`.
```

**¿Cuál es la causa y cómo lo arreglas?**

<details>
<summary>💡 Respuesta</summary>

**Causa**: 
- El modelo fue entrenado con numpy < 1.24 que tenía `np.bool`
- Producción tiene numpy >= 1.24 donde `np.bool` fue eliminado

**Solución inmediata**:
```bash
pip install "numpy<1.24"
```

**Solución correcta**:
1. Reentrenar el modelo con numpy >= 1.24
2. O actualizar el código que usa `np.bool` a `bool`

**En sklearn**: Esto pasaba en versiones antiguas. Actualizar sklearn >= 1.3 resuelve el problema.

</details>
