# 14. FastAPI para Producción
 
<a id="00-prerrequisitos"></a>
 
## 0.0 Prerrequisitos
 
- Tener un proyecto con FastAPI ejecutable (local o en contenedor).
- Conocer validación con Pydantic (modelos request/response).
- Haber completado el módulo 13 (Docker) para empaquetar y ejecutar la API.
 
---
 
<a id="01-protocolo-e-como-estudiar-este-modulo"></a>
 
## 0.1 🧠 Protocolo E: Cómo estudiar este módulo
 
- **Antes de empezar**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define el output mínimo: un servicio que levanta y responde en `/health` y `/predict`.
- **Durante el debugging**: si te atoras >15 min (schema, serialización, modelo no carga, 4xx/5xx), registra el caso en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
- **Al cierre de semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para auditar documentación (OpenAPI), manejo de errores y compatibilidad training-serving.
 
---
 
<a id="02-entregables-verificables-minimo-viable"></a>
 
## 0.2 ✅ Entregables verificables (mínimo viable)
 
- [ ] Endpoint `/health` estable (sin depender de cómputo pesado).
- [ ] Endpoint `/predict` con request/response validados (Pydantic).
- [ ] Documentación accesible en `/docs` (Swagger) y `/openapi.json`.
- [ ] Manejo de errores consistente (`HTTPException` + códigos).
- [ ] Conversión explícita a tipos nativos (`float`, `int`) para evitar problemas de serialización.
 
---
 
<a id="03-puente-teoria-codigo-portafolio"></a>
 
## 0.3 🧩 Puente teoría ↔ código (Portafolio)
 
- **Concepto**: contrato API (schemas) + loading de modelo (startup) + observabilidad básica
- **Archivo**: `app/fastapi_app.py`, `app/schemas.py`
- **Prueba**: `uvicorn app.fastapi_app:app --reload` y `curl http://localhost:8000/health`
 
---
 
## 🎯 Objetivo del Módulo
 
Construir APIs de ML robustas, documentadas y production-ready como las del portafolio.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  FastAPI = El framework ideal para ML APIs                                   ║
║                                                                              ║
║  ✅ Type hints nativos (Pydantic)                                            ║
║  ✅ Documentación automática (Swagger/OpenAPI)                               ║
║  ✅ Async support (alto throughput)                                          ║
║  ✅ Validación automática de requests                                        ║
║  ✅ Dependency Injection built-in                                            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Contenido
 
- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
- **14.1** [Estructura de una API ML](#141-estructura-de-una-api-ml)
- **14.2** [Schemas con Pydantic](#142-schemas-con-pydantic)
- **14.3** [Endpoints de Predicción](#143-endpoints-de-prediccion)
- **14.4** [Error Handling](#144-error-handling)
- **14.5** [Código Real del Portafolio](#145-codigo-real-del-portafolio)
- [Errores habituales](#errores-habituales)
- [✅ Checkpoint](#checkpoint)
- [✅ Ejercicio](#ejercicio)
 
---

<a id="141-estructura-de-una-api-ml"></a>

## 14.1 Estructura de una API ML

### Anatomía Típica

```python
# app/fastapi_app.py - Estructura profesional

from contextlib import asynccontextmanager
from pathlib import Path

import joblib
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .schemas import PredictionRequest, PredictionResponse, HealthResponse


# ═══════════════════════════════════════════════════════════════════════════
# LIFECYCLE: Cargar modelo al iniciar
# ═══════════════════════════════════════════════════════════════════════════

model = None  # Global para acceso en endpoints

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifecycle: carga modelo al iniciar, limpia al cerrar."""
    global model
    
    # Startup: cargar modelo
    model_path = Path("artifacts/model.joblib")
    if model_path.exists():
        model = joblib.load(model_path)
        print(f"✅ Modelo cargado: {model_path}")
    else:
        print(f"⚠️ Modelo no encontrado: {model_path}")
    
    yield  # App corriendo
    
    # Shutdown: limpiar recursos
    model = None
    print("🛑 App cerrada")


# ═══════════════════════════════════════════════════════════════════════════
# APP SETUP
# ═══════════════════════════════════════════════════════════════════════════

app = FastAPI(
    title="BankChurn Predictor API",
    description="API para predicción de churn de clientes bancarios",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS para permitir requests desde frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En prod: especificar dominios
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ═══════════════════════════════════════════════════════════════════════════
# ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════════

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint para load balancers/k8s."""
    return HealthResponse(
        status="healthy" if model is not None else "degraded",
        model_loaded=model is not None,
        version="1.0.0"
    )


@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """Predice probabilidad de churn para un cliente."""
    if model is None:
        raise HTTPException(status_code=503, detail="Modelo no disponible")
    
    # Convertir request a DataFrame
    import pandas as pd
    df = pd.DataFrame([request.dict()])
    
    # Predecir
    proba = model.predict_proba(df)[0, 1]
    prediction = int(proba >= 0.5)
    
    return PredictionResponse(
        prediction=prediction,
        probability=round(proba, 4),
        risk_level="high" if proba >= 0.7 else "medium" if proba >= 0.3 else "low"
    )
```

---

<a id="142-schemas-con-pydantic"></a>

## 14.2 Schemas con Pydantic

### Request/Response Models

```python
# app/schemas.py

from typing import Literal, Optional
from pydantic import BaseModel, Field, validator


class PredictionRequest(BaseModel):
    """Schema para request de predicción.
    
    Pydantic valida automáticamente:
    - Tipos correctos
    - Rangos válidos
    - Valores permitidos
    """
    
    CreditScore: int = Field(..., ge=300, le=850, description="Credit score del cliente")
    Geography: Literal["France", "Germany", "Spain"] = Field(..., description="País")
    Gender: Literal["Male", "Female"] = Field(..., description="Género")
    Age: int = Field(..., ge=18, le=100, description="Edad")
    Tenure: int = Field(..., ge=0, le=10, description="Años como cliente")
    Balance: float = Field(..., ge=0, description="Balance en cuenta")
    NumOfProducts: int = Field(..., ge=1, le=4, description="Número de productos")
    HasCrCard: Literal[0, 1] = Field(..., description="Tiene tarjeta de crédito")
    IsActiveMember: Literal[0, 1] = Field(..., description="Es miembro activo")
    EstimatedSalary: float = Field(..., ge=0, description="Salario estimado")
    
    class Config:
        json_schema_extra = {
            "example": {
                "CreditScore": 650,
                "Geography": "France",
                "Gender": "Female",
                "Age": 40,
                "Tenure": 3,
                "Balance": 60000.0,
                "NumOfProducts": 2,
                "HasCrCard": 1,
                "IsActiveMember": 1,
                "EstimatedSalary": 50000.0
            }
        }


class PredictionResponse(BaseModel):
    """Schema para response de predicción."""
    
    prediction: Literal[0, 1] = Field(..., description="0=No churn, 1=Churn")
    probability: float = Field(..., ge=0, le=1, description="Probabilidad de churn")
    risk_level: Literal["low", "medium", "high"] = Field(..., description="Nivel de riesgo")


class HealthResponse(BaseModel):
    """Schema para health check."""
    
    status: Literal["healthy", "degraded", "unhealthy"]
    model_loaded: bool
    version: str


class BatchPredictionRequest(BaseModel):
    """Schema para predicción en batch."""
    
    customers: list[PredictionRequest] = Field(
        ..., 
        min_items=1, 
        max_items=1000,
        description="Lista de clientes (máx 1000)"
    )


class BatchPredictionResponse(BaseModel):
    """Schema para response de batch."""
    
    predictions: list[PredictionResponse]
    processed: int
    errors: int = 0
```

---

<a id="143-endpoints-de-prediccion"></a>

## 14.3 Endpoints de Predicción

### Single Prediction

```python
@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    """
    Predice probabilidad de churn para UN cliente.
    
    - **CreditScore**: Score crediticio (300-850)
    - **Geography**: País (France, Germany, Spain)
    - **Gender**: Género
    - **Age**: Edad (18-100)
    - ... etc
    
    Returns:
    - **prediction**: 0 (no churn) o 1 (churn)
    - **probability**: Probabilidad [0, 1]
    - **risk_level**: low/medium/high
    """
    if model is None:
        raise HTTPException(
            status_code=503, 
            detail="Modelo no disponible. Reinicie el servicio."
        )
    
    try:
        import pandas as pd
        df = pd.DataFrame([request.model_dump()])
        
        proba = model.predict_proba(df)[0, 1]
        prediction = int(proba >= 0.5)
        
        if proba >= 0.7:
            risk = "high"
        elif proba >= 0.3:
            risk = "medium"
        else:
            risk = "low"
        
        return PredictionResponse(
            prediction=prediction,
            probability=round(float(proba), 4),
            risk_level=risk
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en predicción: {str(e)}")
```

### Batch Prediction

```python
@app.post("/predict/batch", response_model=BatchPredictionResponse)
async def predict_batch(request: BatchPredictionRequest):
    """
    Predice churn para múltiples clientes (máx 1000).
    
    Útil para scoring masivo de cartera.
    """
    if model is None:
        raise HTTPException(status_code=503, detail="Modelo no disponible")
    
    import pandas as pd
    
    results = []
    errors = 0
    
    # Convertir todos los requests a DataFrame (más eficiente)
    data = [c.model_dump() for c in request.customers]
    df = pd.DataFrame(data)
    
    try:
        probas = model.predict_proba(df)[:, 1]
        
        for proba in probas:
            prediction = int(proba >= 0.5)
            risk = "high" if proba >= 0.7 else "medium" if proba >= 0.3 else "low"
            
            results.append(PredictionResponse(
                prediction=prediction,
                probability=round(float(proba), 4),
                risk_level=risk
            ))
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en batch: {str(e)}")
    
    return BatchPredictionResponse(
        predictions=results,
        processed=len(results),
        errors=errors
    )
```

---

<a id="144-error-handling"></a>

## 14.4 Error Handling

### Custom Exception Handlers

```python
from fastapi import Request
from fastapi.responses import JSONResponse

class ModelNotLoadedError(Exception):
    """Modelo no cargado."""
    pass

class InvalidInputError(Exception):
    """Input inválido."""
    pass


@app.exception_handler(ModelNotLoadedError)
async def model_not_loaded_handler(request: Request, exc: ModelNotLoadedError):
    return JSONResponse(
        status_code=503,
        content={
            "error": "service_unavailable",
            "message": "El modelo no está cargado. Intente más tarde.",
            "retry_after": 30
        }
    )


@app.exception_handler(InvalidInputError)
async def invalid_input_handler(request: Request, exc: InvalidInputError):
    return JSONResponse(
        status_code=400,
        content={
            "error": "invalid_input",
            "message": str(exc),
            "hint": "Verifique que todos los campos tengan valores válidos"
        }
    )


# Catch-all para errores no manejados
@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "error": "internal_error",
            "message": "Error interno del servidor",
            "detail": str(exc) if app.debug else None
        }
    )
```

---

<a id="145-codigo-real-del-portafolio"></a>

## 14.5 Código Real del Portafolio

### app/fastapi_app.py (BankChurn - Simplificado)

```python
"""FastAPI application for BankChurn prediction service."""

from __future__ import annotations

import logging
import os
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Literal

import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)

# ═══════════════════════════════════════════════════════════════════════════
# SCHEMAS
# ═══════════════════════════════════════════════════════════════════════════

class CustomerInput(BaseModel):
    CreditScore: int = Field(..., ge=300, le=850)
    Geography: str
    Gender: str
    Age: int = Field(..., ge=18, le=100)
    Tenure: int = Field(..., ge=0, le=10)
    Balance: float = Field(..., ge=0)
    NumOfProducts: int = Field(..., ge=1, le=4)
    HasCrCard: int = Field(..., ge=0, le=1)
    IsActiveMember: int = Field(..., ge=0, le=1)
    EstimatedSalary: float = Field(..., ge=0)


class PredictionOutput(BaseModel):
    prediction: int
    probability: float
    risk_level: str


class HealthOutput(BaseModel):
    status: str
    model_loaded: bool


# ═══════════════════════════════════════════════════════════════════════════
# APP
# ═══════════════════════════════════════════════════════════════════════════

model = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global model
    
    # Buscar modelo en varias ubicaciones
    paths = [
        Path("models/model_v1.0.0.pkl"),
        Path("artifacts/model.joblib"),
        Path(os.getenv("MODEL_PATH", "model.joblib")),
    ]
    
    for path in paths:
        if path.exists():
            model = joblib.load(path)
            logger.info(f"Modelo cargado: {path}")
            break
    
    if model is None:
        logger.warning("⚠️ Ningún modelo encontrado")
    
    yield
    model = None


app = FastAPI(
    title="BankChurn Predictor",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", response_model=HealthOutput)
async def health():
    return HealthOutput(
        status="healthy" if model else "degraded",
        model_loaded=model is not None
    )


@app.post("/predict", response_model=PredictionOutput)
async def predict(customer: CustomerInput):
    if model is None:
        raise HTTPException(503, "Modelo no disponible")
    
    df = pd.DataFrame([customer.model_dump()])
    proba = model.predict_proba(df)[0, 1]
    
    return PredictionOutput(
        prediction=int(proba >= 0.5),
        probability=round(proba, 4),
        risk_level="high" if proba >= 0.7 else "medium" if proba >= 0.3 else "low"
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

---

<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en FastAPI para ML

FastAPI te da mucho “gratis”, pero en APIs de ML los fallos suelen venir de modelos no cargados, esquemas desalineados o problemas de tipos/serialización.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) El modelo no se carga (503 constantes)

**Síntomas típicos**

- El endpoint `/predict` responde `503 Modelo no disponible`.
- Logs con mensajes tipo `Modelo no encontrado` o `Ningún modelo encontrado`.

**Cómo identificarlo**

- Revisa la función `lifespan` o código de startup: ¿la ruta del modelo (`models/`, `artifacts/`) existe dentro del contenedor?
- Comprueba variables de entorno como `MODEL_PATH`.

**Cómo corregirlo**

- Asegura rutas consistentes entre entrenamiento, Dockerfile y FastAPI.
- En local, imprime (`logger.info`) la ruta exacta desde la que intentas cargar y verifica que el archivo esté ahí.

---

### 2) Esquema Pydantic desalineado con el pipeline

**Síntomas típicos**

- Errores `KeyError` o `Column not found` al predecir.
- El modelo espera columnas con ciertos nombres pero el `PredictionRequest` usa otros.

**Cómo identificarlo**

- Compara los campos del schema (`CreditScore`, `Geography`, etc.) con las columnas que el pipeline de sklearn espera.

**Cómo corregirlo**

- Usa los **mismos nombres de features** que en el training pipeline.
- Si renombraste columnas en feature engineering, refleja esos cambios en el schema y en la transformación de entrada antes de llamar al modelo.

---

### 3) Problemas de tipos y serialización

**Síntomas típicos**

- Errores `TypeError: Object of type ... is not JSON serializable`.
- Respuestas con valores `NaN` o `Infinity` que rompen el cliente.

**Cómo identificarlo**

- Revisa el tipo real de lo que devuelves en `PredictionResponse` (por ejemplo, `numpy.float32` en vez de `float`).

**Cómo corregirlo**

- Convierte explícitamente a tipos nativos de Python (`float`, `int`, `str`).
- Asegúrate de que no devuelves `NaN` o `inf` (redondea o reemplaza por valores válidos).

---

### 4) CORS o healthcheck mal configurados

**Síntomas típicos**

- El frontend no puede llamar al API por errores de CORS.
- Kubernetes/Compose marcan el servicio como unhealthy.

**Cómo identificarlo**

- Revisa configuración de `CORSMiddleware` y el endpoint `/health`.

**Cómo corregirlo**

- En desarrollo puedes usar `allow_origins=["*"]`, pero en producción limita a tus dominios.
- Verifica que `/health` no dependa de modelos pesados para responder rápido y con 200.

---

### 5) Patrón general de debugging en APIs de ML

1. Llama al endpoint con `curl` o `httpie` usando el `example` del schema.
2. Mira los logs del servidor (uvicorn) para ver tracebacks completos.
3. Verifica rutas de modelo y variables de entorno que afectan al loading.
4. Asegúrate de que lo que entra/sale del API coincide con lo que tu modelo entrenado espera.

Con esta disciplina, tu API FastAPI pasará de “funciona solo en local” a estar lista para producción.

---

<a id="ejercicio"></a>

## ✅ Ejercicio

1. Implementa `/predict/batch` para procesar múltiples clientes
2. Añade endpoint `/model/info` que retorne metadata del modelo
3. Implementa rate limiting básico

---

## 📦 Cómo se Usó en el Portafolio

Cada proyecto tiene una API FastAPI en `app/fastapi_app.py`:

### API de BankChurn

```python
# BankChurn-Predictor/app/fastapi_app.py (estructura)
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="BankChurn Predictor API")

class PredictionRequest(BaseModel):
    CreditScore: int
    Geography: str
    Gender: str
    Age: int
    Balance: float
    # ... más features

class PredictionResponse(BaseModel):
    prediction: int
    probability: float
    risk_level: str

@app.get("/health")
async def health():
    return {"status": "healthy", "model_loaded": model is not None}

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    features = request.dict()
    df = pd.DataFrame([features])
    prediction = pipeline.predict(df)[0]
    probability = pipeline.predict_proba(df)[0, 1]
    return PredictionResponse(
        prediction=int(prediction),
        probability=float(probability),
        risk_level="high" if probability > 0.7 else "low"
    )
```

### APIs por Proyecto

| Proyecto | Endpoint Principal | Tipo |
|----------|-------------------|------|
| BankChurn | `/predict` | Clasificación binaria |
| CarVision | `/predict` | Regresión |
| TelecomAI | `/predict` | Clasificación multiclase |

### 🔧 Ejercicio: Prueba las APIs Reales

```bash
# 1. Inicia API de BankChurn
cd BankChurn-Predictor
uvicorn app.fastapi_app:app --reload

# 2. Prueba con curl
curl http://localhost:8000/health

curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"CreditScore": 650, "Geography": "France", ...}'

# 3. Ve docs interactivos
# http://localhost:8000/docs
```

---

<a id="checkpoint"></a>

## ✅ Checkpoint

- [ ] `/health` responde rápido (no hace inferencia ni carga pesada)
- [ ] `/predict` valida request/response con Pydantic
- [ ] Devuelves tipos nativos (sin `numpy.float32`, sin `NaN/inf`)
- [ ] Errores esperables se manejan con `HTTPException` y códigos correctos
- [ ] `/docs` y `/openapi.json` son accesibles

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **Pydantic + FastAPI**: Explica cómo la validación automática reduce código.

2. **Async vs Sync**: Cuándo usar cada uno (IO-bound vs CPU-bound).

3. **OpenAPI/Swagger**: Documentación automática como feature de FastAPI.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| ML Serving | Carga modelo en startup, no en cada request |
| Validación | Usa Pydantic para input/output schemas |
| Errores | HTTPException con códigos y mensajes claros |
| Producción | Gunicorn + Uvicorn workers |

### Endpoints Esenciales para ML

```python
/health          → Liveness check
/ready           → Readiness check (modelo cargado)
/predict         → Inferencia principal
/predict/batch   → Inferencia batch
/model/info      → Versión, métricas, metadata
```


---

## 📺 Recursos Externos Recomendados

> Ver [RECURSOS_POR_MODULO.md](RECURSOS_POR_MODULO.md) para la lista completa.

| 🏷️ | Recurso | Tipo |
|:--:|:--------|:-----|
| 🔴 | [FastAPI Tutorial - Sebastián Ramírez](https://www.youtube.com/watch?v=0sOvCWFmrtA) | Video |
| 🟡 | [ML APIs with FastAPI](https://www.youtube.com/watch?v=kBIX3_cMHzE) | Video |

**Documentación oficial:**
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic v2](https://docs.pydantic.dev/latest/)

---

## 🔗 Referencias del Glosario

Ver [21_GLOSARIO.md](21_GLOSARIO.md) para definiciones de:
- **FastAPI**: Framework web async para APIs
- **Pydantic**: Validación de datos con type hints
- **OpenAPI**: Especificación de APIs (Swagger)

---

## ✅ Ejercicios

Ver [EJERCICIOS.md](EJERCICIOS.md) - Módulo 14:
- **14.1**: Schemas Pydantic para request/response
- **14.2**: Endpoint de predicción completo

---

<div align="center">

[← Docker Avanzado](13_DOCKER.md) | [Siguiente: Streamlit Dashboards →](15_STREAMLIT.md)

</div>
