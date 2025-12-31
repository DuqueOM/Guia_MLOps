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
- **14.6** [🔬 Ingeniería Inversa: API Producción Real](#146-ingenieria-inversa-fastapi) ⭐ NUEVO
- [Errores habituales](#errores-habituales)
- [✅ Checkpoint](#checkpoint)
- [✅ Ejercicio](#ejercicio)
 
---

<a id="141-estructura-de-una-api-ml"></a>

### 🧠 Mapa Mental de Conceptos: FastAPI para ML

```
                          ╔══════════════════════════════════════╗
                          ║      FASTAPI PARA ML PRODUCTION      ║
                          ╚══════════════════════════════════════╝
                                            │
         ┌──────────────────────────────────┼──────────────────────────────────┐
         ▼                                  ▼                                  ▼
┌──────────────────┐              ┌──────────────────┐              ┌──────────────────┐
│    ENDPOINTS     │              │    SCHEMAS       │              │   LIFECYCLE      │
└──────────────────┘              └──────────────────┘              └──────────────────┘
       │                                 │                                 │
├─ /health                        ├─ PredictionRequest          ├─ Startup: load model
├─ /predict                       ├─ PredictionResponse         ├─ Shutdown: cleanup
├─ /batch                         ├─ Validación Pydantic        └─ Global state
└─ /docs (auto)                   └─ OpenAPI spec
```

**Términos clave:**

| Término | Significado | Ejemplo |
|---------|-------------|---------|
| **Schema** | Modelo Pydantic para validar I/O | `PredictionRequest` |
| **Lifespan** | Startup/shutdown hooks | Cargar modelo una vez |
| **HTTPException** | Error HTTP estructurado | `HTTPException(404, "Not found")` |
| **Dependency** | Inyección de dependencias | Conexión DB, auth |

---

### 💻 Ejercicio Puente: API Mínima

```python
from fastapi import FastAPI

app = FastAPI()  # Crea la aplicación FastAPI.

@app.get("/health")  # Endpoint GET para health check.
def health():
    return {"status": "healthy"}  # Respuesta JSON indicando que el servicio está activo.

@app.post("/predict")  # Endpoint POST para predicciones.
def predict(data: dict):
    # TU TAREA: Cargar modelo y predecir
    return {"prediction": 0.85}  # Respuesta con la predicción del modelo.
```

**Ejecutar:** `uvicorn app:app --reload`
**Ver docs:** `http://localhost:8000/docs`

---


### 💻 Ejercicio Puente: APIs ML

> **Meta**: Practica el concepto antes de aplicarlo al portafolio.

**Ejercicio básico:**
1. Lee la sección teórica siguiente
2. Identifica los patrones clave del código de ejemplo
3. Replica el patrón en un proyecto de prueba

---

### 🛠️ Práctica del Portafolio: FastAPI en BankChurn

> **Tarea**: Aplicar este módulo en BankChurn-Predictor.

```bash
cd BankChurn-Predictor
# Explora el código relacionado con APIs ML
```

**Checklist:**
- [ ] Localicé el código relevante
- [ ] Entendí la implementación actual
- [ ] Identifiqué posibles mejoras

---

### ✅ Checkpoint de Conocimiento

**Pregunta 1**: ¿Cuál es el objetivo principal de FastAPI?

**Pregunta 2**: ¿Cómo se implementa en el portafolio?

**🔧 Escenario Debugging**: Si algo falla en APIs ML, ¿cuál sería tu primer paso de diagnóstico?


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

model = None                             # Variable global: accesible desde todos los endpoints.

@asynccontextmanager                     # Decorador para crear context manager async.
async def lifespan(app: FastAPI):        # Función que gestiona startup/shutdown de la app.
    """Lifecycle: carga modelo al iniciar, limpia al cerrar."""
    global model                         # global: permite modificar la variable global desde aquí.
    
    # Startup: cargar modelo
    model_path = Path("artifacts/model.joblib")  # Ruta al modelo serializado.
    if model_path.exists():              # Verifica que el archivo existe antes de cargar.
        model = joblib.load(model_path)  # Deserializa el pipeline completo.
        print(f"✅ Modelo cargado: {model_path}")
    else:
        print(f"⚠️ Modelo no encontrado: {model_path}")  # Warning, no crash.
    
    yield                                # yield: aquí la app está corriendo y recibiendo requests.
    
    # Shutdown: limpiar recursos
    model = None                         # Libera memoria al cerrar.
    print("🛑 App cerrada")


# ═══════════════════════════════════════════════════════════════════════════
# APP SETUP
# ═══════════════════════════════════════════════════════════════════════════

app = FastAPI(                           # Crea instancia de la aplicación FastAPI.
    title="BankChurn Predictor API",     # Título en Swagger UI (/docs).
    description="API para predicción de churn de clientes bancarios",
    version="1.0.0",                     # Versión de la API (semver).
    lifespan=lifespan,                   # Asocia el lifecycle manager definido arriba.
)

# CORS para permitir requests desde frontend
app.add_middleware(                      # Middleware: procesa requests antes/después de endpoints.
    CORSMiddleware,                      # Cross-Origin Resource Sharing: permite requests desde otros dominios.
    allow_origins=["*"],                 # "*" permite todo. En prod: ["https://midominio.com"].
    allow_credentials=True,              # Permite enviar cookies/auth headers.
    allow_methods=["*"],                 # Permite todos los métodos HTTP (GET, POST, etc.).
    allow_headers=["*"],                 # Permite todos los headers.
)


# ═══════════════════════════════════════════════════════════════════════════
# ENDPOINTS
# ═══════════════════════════════════════════════════════════════════════════

@app.get("/health", response_model=HealthResponse)  # GET /health → devuelve HealthResponse.
async def health_check():                # async: permite I/O no bloqueante (mejor concurrencia).
    """Health check endpoint para load balancers/k8s."""
    return HealthResponse(               # Pydantic valida que el response cumpla el schema.
        status="healthy" if model is not None else "degraded",  # Ternario: condición ? si : no.
        model_loaded=model is not None,
        version="1.0.0"
    )


@app.post("/predict", response_model=PredictionResponse)  # POST /predict con body JSON.
async def predict(request: PredictionRequest):  # request: Pydantic valida el body automáticamente.
    """Predice probabilidad de churn para un cliente."""
    if model is None:                    # Verificación defensiva.
        raise HTTPException(status_code=503, detail="Modelo no disponible")  # 503: Service Unavailable.
    
    # Convertir request a DataFrame
    import pandas as pd                  # Import dentro de función (lazy load, ok en endpoints).
    df = pd.DataFrame([request.dict()])  # dict(): convierte Pydantic model a diccionario.
    
    # Predecir
    proba = model.predict_proba(df)[0, 1]  # [0, 1]: fila 0, columna 1 (prob clase positiva).
    prediction = int(proba >= 0.5)       # Umbral 0.5: convierte probabilidad a 0/1.
    
    return PredictionResponse(           # Response tipado y validado.
        prediction=prediction,
        probability=round(proba, 4),     # round: 4 decimales de precisión.
        risk_level="high" if proba >= 0.7 else "medium" if proba >= 0.3 else "low"  # Ternario encadenado.
    )
```

---

<a id="142-schemas-con-pydantic"></a>

## 14.2 Schemas con Pydantic

### Request/Response Models

```python
# app/schemas.py

from typing import Literal, Optional       # Literal: valores específicos; Optional: puede ser None.
from pydantic import BaseModel, Field, validator  # BaseModel: clase base para schemas.


class PredictionRequest(BaseModel):        # Hereda de BaseModel: obtiene validación automática.
    """Schema para request de predicción.
    
    Pydantic valida automáticamente:
    - Tipos correctos
    - Rangos válidos
    - Valores permitidos
    """
    
    CreditScore: int = Field(..., ge=300, le=850, description="Credit score del cliente")
    # Field(...): ... significa REQUERIDO. ge=300: mayor o igual. le=850: menor o igual.
    Geography: Literal["France", "Germany", "Spain"] = Field(..., description="País")
    # Literal: SOLO acepta estos 3 valores exactos. Otros → ValidationError.
    Gender: Literal["Male", "Female"] = Field(..., description="Género")
    Age: int = Field(..., ge=18, le=100, description="Edad")
    Tenure: int = Field(..., ge=0, le=10, description="Años como cliente")
    Balance: float = Field(..., ge=0, description="Balance en cuenta")  # ge=0: no negativo.
    NumOfProducts: int = Field(..., ge=1, le=4, description="Número de productos")
    HasCrCard: Literal[0, 1] = Field(..., description="Tiene tarjeta de crédito")  # Binario.
    IsActiveMember: Literal[0, 1] = Field(..., description="Es miembro activo")
    EstimatedSalary: float = Field(..., ge=0, description="Salario estimado")
    
    class Config:                          # Config: configuración del modelo Pydantic.
        json_schema_extra = {              # Ejemplo para Swagger UI (/docs).
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

<a id="146-ingenieria-inversa-fastapi"></a>

## 14.6 🔬 Ingeniería Inversa Pedagógica: API de Producción Real

> **Objetivo**: Entender CADA decisión detrás de la API FastAPI del portafolio.

Esta sección disecciona `app/fastapi_app.py` de BankChurn-Predictor, una API ML de producción real.

### 14.6.1 🎯 El "Por Qué" Arquitectónico

¿Por qué la API del portafolio está diseñada así?

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DECISIONES ARQUITECTÓNICAS DEL PORTAFOLIO                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  PROBLEMA 1: ¿Cómo cargo el modelo una sola vez sin bloquearlo en cada request? │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: Cargar modelo (~500MB) en cada request = 2-5s de latencia              │
│  DECISIÓN: Cargar en `lifespan` (startup), guardar en variable global           │
│  RESULTADO: Primera carga ~3s, requests subsecuentes ~50ms                      │
│  REFERENCIA: fastapi_app.py líneas 100-107                                      │
│                                                                                 │
│  PROBLEMA 2: ¿Cómo valido inputs complejos (10+ features) sin código manual?    │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: Validación manual = bugs, inconsistencias, código repetido             │
│  DECISIÓN: Pydantic con Field validators para cada feature                      │
│  RESULTADO: Validación automática, errores descriptivos, docs auto-generadas    │
│  REFERENCIA: fastapi_app.py líneas 128-155 (CustomerData)                       │
│                                                                                 │
│  PROBLEMA 3: ¿Cómo expongo métricas para Prometheus sin acoplar el código?      │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: Sin métricas = volar ciego en producción                               │
│  DECISIÓN: prometheus_client con try/except (graceful degradation)              │
│  RESULTADO: Métricas si está disponible, fallback a JSON si no                  │
│  REFERENCIA: fastapi_app.py líneas 25-46, 284-297                               │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 14.6.2 🔍 Anatomía de `app/fastapi_app.py`

**Archivo**: `ML-MLOps-Portfolio/BankChurn-Predictor/app/fastapi_app.py`

```python
# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 1: Importaciones con Graceful Degradation
# ═══════════════════════════════════════════════════════════════════════════════
try:
    from prometheus_client import Counter, Histogram, generate_latest
    PROMETHEUS_AVAILABLE = True
    
    REQUEST_COUNT = Counter(
        "bankchurn_requests_total",        # Nombre de la métrica.
        "Total HTTP requests",             # Descripción.
        ["method", "endpoint", "status"],  # Labels para filtrar.
    )
    REQUEST_LATENCY = Histogram(
        "bankchurn_request_duration_seconds",
        "Request latency in seconds",
        ["endpoint"],
        buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0],  # Buckets para percentiles.
    )
except ImportError:
    PROMETHEUS_AVAILABLE = False
# ¿Por qué try/except para métricas?
# - prometheus_client es opcional (puede no estar instalado en dev).
# - La API sigue funcionando sin métricas, pero las tiene si están disponibles.
# - Patrón "graceful degradation": funcionalidad reducida pero sin crash.

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 2: Lifecycle Management (Carga de Modelo)
# ═══════════════════════════════════════════════════════════════════════════════
predictor: Optional[ChurnPredictor] = None   # Variable global para el modelo.

@contextlib.asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifecycle."""
    global predictor
    success = load_model_logic()            # Carga modelo al iniciar.
    if not success:
        logger.warning("Application started without model loaded.")
        # NO crashea la app. Endpoint /predict devolverá 503.
    yield                                    # App corriendo.
    # Cleanup al cerrar (opcional).
# ¿Por qué lifespan y no @app.on_event("startup")?
# - on_event está deprecated en FastAPI >= 0.93.
# - lifespan es el patrón moderno recomendado.
# - Permite cleanup al cerrar (conexiones DB, etc.).

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 3: Schemas Pydantic con Validación Estricta
# ═══════════════════════════════════════════════════════════════════════════════
class CustomerData(BaseModel):
    """Schema para datos de cliente."""
    
    CreditScore: int = Field(..., ge=300, le=850)  # ...: required. ge/le: rangos.
    Geography: str = Field(...)
    Gender: str = Field(...)
    Age: int = Field(..., ge=18, le=100)
    Balance: float = Field(..., ge=0)
    # ... más campos ...
    
    @validator("Geography")
    def validate_geography(cls, v):
        valid = ["France", "Spain", "Germany"]
        if v not in valid:
            raise ValueError(f"Geography must be one of: {valid}")
        return v
# ¿Por qué validators personalizados?
# - Field solo valida tipos y rangos numéricos.
# - @validator permite validación de dominio (países válidos, formatos, etc.).
# - Error messages claros para el consumidor de la API.

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 4: Endpoint /health (Liveness + Readiness)
# ═══════════════════════════════════════════════════════════════════════════════
@app.get("/health", response_model=HealthResponse)
async def health_check():
    uptime = time.time() - start_time
    return HealthResponse(
        status="healthy" if predictor is not None else "degraded",
        model_loaded=predictor is not None,  # Kubernetes readiness check usa esto.
        uptime_seconds=uptime,
        version="1.0.0",
    )
# ¿Por qué "degraded" en lugar de "unhealthy"?
# - "unhealthy" haría que K8s mate el pod (liveness fail).
# - "degraded" indica que funciona pero con capacidad reducida.
# - El pod sigue vivo, el equipo puede investigar.

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 5: Endpoint /predict con Métricas
# ═══════════════════════════════════════════════════════════════════════════════
@app.post("/predict", response_model=PredictionResponse)
async def predict_churn(customer: CustomerData):
    if predictor is None:
        if PROMETHEUS_AVAILABLE:
            REQUEST_COUNT.labels(method="POST", endpoint="/predict", status="503").inc()
        raise HTTPException(status_code=503, detail="Model not available")
    
    start_pred = time.time()
    try:
        customer_dict = customer.dict()      # Pydantic model → dict.
        df = pd.DataFrame([customer_dict])   # dict → DataFrame (1 fila).
        
        results = predictor.predict(df, include_proba=True)
        
        prob = float(results.iloc[0]["probability"])  # float() evita numpy.float64.
        pred = int(results.iloc[0]["prediction"])     # int() evita numpy.int64.
        
        pred_time = time.time() - start_pred
        
        # Track metrics
        if PROMETHEUS_AVAILABLE:
            REQUEST_COUNT.labels(method="POST", endpoint="/predict", status="200").inc()
            REQUEST_LATENCY.labels(endpoint="/predict").observe(pred_time)
        
        return PredictionResponse(...)
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
# ¿Por qué float() y int() explícitos?
# - numpy.float64 no es JSON-serializable directamente.
# - FastAPI/Pydantic pueden fallar al serializar tipos numpy.
# - Convertir a tipos nativos de Python evita "Object of type float64 is not JSON serializable".

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 6: Endpoint /predict_batch (Optimización para Volumen)
# ═══════════════════════════════════════════════════════════════════════════════
@app.post("/predict_batch", response_model=BatchPredictionResponse)
async def predict_batch(batch_data: BatchCustomerData):
    # Vectoriza predicciones para eficiencia.
    df = pd.DataFrame([c.dict() for c in batch_data.customers])
    results = predictor.predict(df, include_proba=True)  # 1 llamada, N resultados.
    # ...
# ¿Por qué endpoint separado para batch?
# - 1 request con 1000 clientes es más eficiente que 1000 requests de 1.
# - El modelo puede vectorizar (GPU/CPU SIMD) las predicciones.
# - Menor overhead de red y serialización.
```

### 14.6.3 🧪 Laboratorio de Replicación

**Tu misión**: Implementar tu propia API de predicción con métricas.

1. **Crea el schema de request**:
   ```python
   # schemas.py
   from pydantic import BaseModel, Field, validator
   
   class CustomerRequest(BaseModel):
       credit_score: int = Field(..., ge=300, le=850)
       age: int = Field(..., ge=18, le=100)
       # Añade más campos según tu modelo
       
       @validator("credit_score")
       def score_must_be_realistic(cls, v):
           if v < 300:
               raise ValueError("Credit score too low")
           return v
   ```

2. **Implementa el lifecycle**:
   ```python
   # app.py
   from contextlib import asynccontextmanager
   
   @asynccontextmanager
   async def lifespan(app: FastAPI):
       global model
       model = joblib.load("models/best_model.pkl")
       yield
       model = None  # Cleanup
   
   app = FastAPI(lifespan=lifespan)
   ```

3. **Añade métricas Prometheus**:
   ```python
   from prometheus_client import Counter, generate_latest
   
   PREDICTIONS = Counter("predictions_total", "Total predictions", ["result"])
   
   @app.post("/predict")  # Endpoint POST para predicciones.
   async def predict(request: CustomerRequest):
       # ... predicción ...
       PREDICTIONS.labels(result="churn" if pred == 1 else "no_churn").inc()
       return {"prediction": pred}
   ```

### 14.6.4 🚨 Troubleshooting Preventivo

| Síntoma | Causa Probable | Solución |
|---------|----------------|----------|
| **"Object of type float64 is not JSON serializable"** | Retornas tipos numpy sin convertir | Usa `float(value)`, `int(value)` antes de retornar. |
| **503 "Model not available"** | Modelo no se cargó en startup | Verifica path del modelo y logs de startup. |
| **422 Unprocessable Entity** | Request no cumple schema Pydantic | Revisa el error detallado en response body. |
| **Latencia alta en /predict** | Modelo se carga en cada request | Mueve carga a `lifespan`, guarda en variable global. |
| **Métricas no aparecen en /metrics** | prometheus_client no instalado | `pip install prometheus_client` o verifica try/except. |

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

@app.get("/health")  # Endpoint GET para health check.
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

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **FastAPI Full Course** | Sebastián Ramírez | 1h | [YouTube](https://www.youtube.com/watch?v=0sOvCWFmrtA) |
| 🔴 | **ML APIs with FastAPI** | ArjanCodes | 30 min | [YouTube](https://www.youtube.com/watch?v=kBIX3_cMHzE) |
| 🟡 | **Pydantic V2 Tutorial** | ArjanCodes | 25 min | [YouTube](https://www.youtube.com/watch?v=502XOB0u8OY) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [FastAPI Docs](https://fastapi.tiangolo.com/) | Documentación oficial |
| 🟡 | [Pydantic v2](https://docs.pydantic.dev/latest/) | Validación de datos |

---

## ⚖️ Decisión Técnica: ADR-004 FastAPI

**Contexto**: Necesitamos framework para APIs de inferencia ML.

**Decisión**: Usar FastAPI como framework para todas las APIs.

**Alternativas Consideradas**:
- **Flask**: Simple pero sync, validación manual
- **Django REST**: Overkill para microservicios ML
- **gRPC**: Más rápido pero más complejo

**Consecuencias**:
- ✅ Validación automática con Pydantic
- ✅ Docs OpenAPI auto-generadas
- ✅ Async nativo para alto throughput
- ❌ Framework relativamente nuevo

---

## 🔧 Ejercicios del Módulo

### Ejercicio 14.1: Schemas Pydantic
**Objetivo**: Definir schemas de request/response.
**Dificultad**: ⭐⭐

```python
from pydantic import BaseModel, Field

# TU TAREA: Crear schemas para endpoint /predict
# Request: customer features
# Response: prediction + probability + model_version
```

<details>
<summary>💡 Ver solución</summary>

```python
from pydantic import BaseModel, Field
from typing import Optional

class PredictRequest(BaseModel):
    """Schema de entrada para predicción."""
    credit_score: int = Field(..., ge=300, le=850, description="Credit score")
    age: int = Field(..., ge=18, le=100, description="Customer age")
    tenure: int = Field(..., ge=0, le=50, description="Years as customer")
    balance: float = Field(..., ge=0, description="Account balance")
    num_products: int = Field(..., ge=1, le=4, description="Number of products")
    has_credit_card: bool = Field(default=True)
    is_active_member: bool = Field(default=True)
    
    model_config = {
        "json_schema_extra": {
            "examples": [{
                "credit_score": 650,
                "age": 35,
                "tenure": 5,
                "balance": 50000.0,
                "num_products": 2,
                "has_credit_card": True,
                "is_active_member": True
            }]
        }
    }

class PredictResponse(BaseModel):
    """Schema de salida para predicción."""
    prediction: int = Field(..., description="0=No churn, 1=Churn")
    probability: float = Field(..., ge=0, le=1, description="Churn probability")
    risk_level: str = Field(..., description="low/medium/high")
    model_version: str = Field(..., description="Model version used")
    
    model_config = {
        "json_schema_extra": {
            "examples": [{
                "prediction": 1,
                "probability": 0.73,
                "risk_level": "high",
                "model_version": "1.2.0"
            }]
        }
    }
```
</details>

---

### Ejercicio 14.2: Endpoint Completo
**Objetivo**: Implementar endpoint /predict con manejo de errores.
**Dificultad**: ⭐⭐⭐

```python
# TU TAREA: Implementar endpoint que:
# 1. Reciba PredictRequest validado
# 2. Cargue modelo (cached)
# 3. Haga predicción
# 4. Devuelva PredictResponse
# 5. Maneje errores apropiadamente
```

<details>
<summary>💡 Ver solución</summary>

```python
from fastapi import FastAPI, HTTPException
from functools import lru_cache
import joblib

app = FastAPI(title="Churn Prediction API")

@lru_cache()
def load_model():
    """Carga modelo una sola vez."""
    try:
        return joblib.load("artifacts/model.joblib")
    except FileNotFoundError:
        raise RuntimeError("Model not found")

@app.get("/health")  # Endpoint GET para health check.
async def health():
    return {"status": "healthy"}  # Respuesta JSON indicando que el servicio está activo.

@app.post("/predict", response_model=PredictResponse)
async def predict(request: PredictRequest):
    """Predice probabilidad de churn."""
    try:
        model = load_model()
    except RuntimeError as e:
        raise HTTPException(status_code=503, detail=str(e))
    
    # Preparar features
    features = [[
        request.credit_score,
        request.age,
        request.tenure,
        request.balance,
        request.num_products,
        int(request.has_credit_card),
        int(request.is_active_member)
    ]]
    
    try:
        prediction = int(model.predict(features)[0])
        probability = float(model.predict_proba(features)[0][1])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {e}")
    
    # Determinar nivel de riesgo
    risk_level = "high" if probability > 0.7 else "medium" if probability > 0.3 else "low"
    
    return PredictResponse(
        prediction=prediction,
        probability=probability,
        risk_level=risk_level,
        model_version="1.0.0"
    )
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **FastAPI** | Framework web async para APIs Python con validación automática |
| **Pydantic** | Librería de validación de datos usando type hints |
| **OpenAPI** | Especificación estándar para documentar APIs (antes Swagger) |
| **@lru_cache** | Decorator para cachear resultados de funciones |

---

## 🪤 La Trampa — Errores Comunes de Este Módulo

### Trampa 1: API sin validación de entrada

**Síntoma**:
```python
@app.post("/predict")
def predict(data: dict):  # ❌ Acepta cualquier cosa
    return model.predict(data["features"])
```

**Solución**:
```python
from pydantic import BaseModel, Field

class PredictRequest(BaseModel):
    features: list[float] = Field(..., min_items=4, max_items=4)

@app.post("/predict")
def predict(request: PredictRequest):  # ✅ Validado
    return model.predict([request.features])
```

---

### Trampa 2: Modelo cargado en cada request

**Síntoma**: API lenta porque carga el modelo en cada request.

**Solución**:
```python
@app.on_event("startup")
async def load_model():
    global model
    model = joblib.load("model.pkl")

# O con dependency injection
from functools import lru_cache

@lru_cache
def get_model():
    return joblib.load("model.pkl")

@app.post("/predict")
def predict(request: PredictRequest, model = Depends(get_model)):
    return model.predict(...)
```

---

### Trampa 3: Logs sin contexto de request

**Síntoma**: Logs sin forma de correlacionar qué request falló.

**Solución**: Añadir request_id con middleware:
```python
class RequestIDMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        request_id = str(uuid.uuid4())[:8]
        with logger.contextualize(request_id=request_id):
            response = await call_next(request)
            response.headers["X-Request-ID"] = request_id
        return response
```

---

## 📝 Quiz del Módulo — Semanas 19-20

### Quiz Semana 19: FastAPI

#### Pregunta 1 (25 pts)
¿Por qué usar Pydantic schemas en lugar de `dict` para requests?

<details>
<summary>✅ Respuesta</summary>

1. **Validación automática**: Tipos, rangos, formatos
2. **Documentación**: OpenAPI generada automáticamente
3. **Seguridad**: Rechaza payloads malformados antes de llegar al código
4. **Autocompletado**: IDE sabe qué campos existen
</details>

#### Pregunta 2 (25 pts)
¿Cómo evitas cargar el modelo en cada request?

<details>
<summary>✅ Respuesta</summary>

Usar `@app.on_event("startup")` o `@lru_cache`:
```python
@lru_cache
def get_model():
    return joblib.load("model.pkl")

@app.post("/predict")
def predict(model = Depends(get_model)):
    ...
```
</details>

#### Pregunta 3 (25 pts)
¿Por qué es importante el endpoint `/health`?

<details>
<summary>✅ Respuesta</summary>

1. **Load balancers**: Verifican si el servicio está vivo
2. **Kubernetes**: Probes de readiness/liveness
3. **Monitoring**: Alertas si el servicio no responde
4. **Debugging**: Verificar conectividad básica
</details>

#### 🔧 Ejercicio Práctico (25 pts)

Crea un endpoint `/predict` con schema de entrada validado (age 18-100, balance ≥0) y respuesta estructurada (prediction, probability, risk_level).

<details>
<summary>✅ Solución</summary>

```python
from pydantic import BaseModel, Field
from fastapi import FastAPI

class PredictRequest(BaseModel):
    age: int = Field(..., ge=18, le=100)
    balance: float = Field(..., ge=0)

class PredictResponse(BaseModel):
    prediction: int
    probability: float
    risk_level: str

@app.post("/predict", response_model=PredictResponse)
def predict(request: PredictRequest):
    features = [[request.age, request.balance]]
    pred = model.predict(features)[0]
    prob = model.predict_proba(features)[0][1]
    risk = "high" if prob > 0.7 else "medium" if prob > 0.3 else "low"
    return PredictResponse(prediction=pred, probability=prob, risk_level=risk)
```
</details>

---

<div align="center">

**Siguiente módulo** → [15. Streamlit](15_STREAMLIT.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
