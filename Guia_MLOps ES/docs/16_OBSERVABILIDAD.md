# 16. Observabilidad para ML
 
<a id="00-prerrequisitos"></a>
 
## 0.0 Prerrequisitos
 
- Haber completado el módulo 14 (FastAPI) y entender endpoints `/health` y `/predict`.
- Haber completado el módulo 13 (Docker) para poder levantar servicios en contenedores.
- Conocer logging básico en Python.
 
---
 
<a id="01-protocolo-e-como-estudiar-este-modulo"></a>
 
## 0.1 🧠 Protocolo E: Cómo estudiar este módulo
 
- **Antes de empezar**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define el output mínimo: métricas visibles en Prometheus + logs JSON + un reporte de drift.
- **Durante el debugging**: si te atoras >15 min (scrape, paneles vacíos, labels, parseo de logs, drift CI), registra el caso en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
- **Al cierre de semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para auditar alertas accionables y señal útil (no solo dashboards bonitos).
 
---
 
<a id="02-entregables-verificables-minimo-viable"></a>
 
## 0.2 ✅ Entregables verificables (mínimo viable)
 
- [ ] Endpoint `/metrics` expuesto y scrapeado por Prometheus.
- [ ] Dashboard (Grafana o equivalente) con latencia, throughput y error rate.
- [ ] Logs estructurados en JSON con campos de negocio (por ejemplo, `model`, `request_id`, `prediction`).
- [ ] Drift detection ejecutable (local o CI) con artefacto de salida (HTML/JSON).
- [ ] Al menos 1 alerta accionable (por ejemplo, error rate o latencia P99).
 
---
 
<a id="03-puente-teoria-codigo-portafolio"></a>
 
## 0.3 🧩 Puente teoría ↔ código (Portafolio)
 
- **Concepto**: señales de oro + instrumentación + ML monitoring
- **Archivo**: `app/metrics.py`, `src/logging_config.py`, `monitoring/check_drift.py`
- **Prueba**: `curl http://localhost:8000/metrics` y revisión de reportes/artefactos
 
---
 
## 🎯 Objetivo del Módulo
 
Implementar monitoreo completo: logs, métricas, y drift detection como en el portafolio.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  "Si no puedo verlo en un dashboard, no sé si está funcionando."             ║
║                                        — Mentalidad Senior                   ║
║                                                                              ║
║  OBSERVABILIDAD = LOGS + METRICS + TRACES + ML MONITORING                    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
 
```

---

## 📋 Contenido

- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
- **16.1** [Las 4 Señales de Oro](#161-las-4-senales-de-oro)
- **16.2** [Prometheus + Grafana](#162-prometheus-grafana)
- **16.3** [Logging Estructurado](#163-logging-estructurado)
- **16.4** [Model Monitoring](#164-model-monitoring)
- [Errores habituales](#errores-habituales)
- [✅ Checkpoint](#checkpoint)
- [✅ Ejercicio](#ejercicio)

---

<a id="161-las-4-senales-de-oro"></a>
 
## 16.1 Las 4 Señales de Oro

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     📊 LAS 4 SEÑALES DE ORO (+ ML)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. LATENCIA          ¿Cuánto tarda una predicción?                         │
│     ───────────       Target: P99 < 100ms                                   │
│                       Alerta: P99 > 200ms                                   │
│                                                                             │
│  2. TRÁFICO           ¿Cuántas requests por segundo?                        │
│     ────────          Monitorear: picos, tendencias, anomalías              │
│                                                                             │
│  3. ERRORES           ¿Qué porcentaje de requests falla?                    │
│     ───────           Target: Error rate < 0.1%                             │
│                       Alerta: Error rate > 1%                               │
│                                                                             │
│  4. SATURACIÓN        ¿Cuánto recurso queda?                                │
│     ──────────        Alerta: CPU > 80%, Memory > 85%                       │
│                                                                             │
│  + ML-ESPECÍFICO:                                                           │
│  ────────────────                                                           │
│  5. DATA DRIFT        ¿Los datos de entrada cambiaron?                      │
│  6. PREDICTION DRIFT  ¿Las predicciones cambiaron distribución?             │
│  7. MODEL DECAY       ¿El accuracy está degradando?                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

<a id="162-prometheus-grafana"></a>
 
## 16.2 Prometheus + Grafana

### Configuración del Portafolio

```yaml
# infra/prometheus-config.yaml

global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'bankchurn-api'
    static_configs:
      - targets: ['bankchurn:8000']
    metrics_path: /metrics
  
  - job_name: 'carvision-api'
    static_configs:
      - targets: ['carvision:8000']
    metrics_path: /metrics
  
  - job_name: 'telecom-api'
    static_configs:
      - targets: ['telecom:8000']
    metrics_path: /metrics
```

### Métricas en FastAPI

```python
# app/metrics.py

from prometheus_client import Counter, Histogram, Gauge, generate_latest  # Tipos de métricas Prometheus.
from fastapi import Response              # Response para retornar texto plano.

# Métricas - Se definen a nivel módulo (globales)
PREDICTIONS_TOTAL = Counter(              # Counter: solo incrementa (total acumulado).
    'predictions_total',                  # Nombre de la métrica (snake_case).
    'Total de predicciones realizadas',   # Descripción (aparece en /metrics).
    ['model', 'result']                   # Labels: permiten filtrar por modelo/resultado.
)

PREDICTION_LATENCY = Histogram(           # Histogram: distribución de valores (latencias).
    'prediction_latency_seconds',         # Convención: unidad en el nombre (_seconds).
    'Latencia de predicciones',
    ['model'],                            # Label para filtrar por modelo.
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0]  # Rangos para calcular percentiles.
)

MODEL_LOADED = Gauge(                     # Gauge: valor que sube/baja (estado actual).
    'model_loaded',                       # 1 si cargado, 0 si no.
    'Indica si el modelo está cargado',
    ['model']
)

PREDICTION_PROBABILITY = Histogram(       # Histogram para monitorear distribución de predicciones.
    'prediction_probability',             # Útil para detectar drift en predicciones.
    'Distribución de probabilidades predichas',
    ['model'],
    buckets=[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]  # Buckets cada 10%.
)


# Endpoint de métricas
@app.get("/metrics")                      # Prometheus hace scrape a este endpoint.
async def metrics():
    return Response(
        content=generate_latest(),        # generate_latest(): serializa todas las métricas.
        media_type="text/plain"           # Prometheus espera text/plain.
    )


# Uso en predicción
import time                               # Para medir latencia.

@app.post("/predict")
async def predict(request: PredictionRequest):
    start = time.time()                   # Timestamp antes de predecir.
    
    # ... predicción ...
    proba = model.predict_proba(df)[0, 1]
    prediction = int(proba >= 0.5)
    
    # Registrar métricas
    latency = time.time() - start         # Calcula latencia en segundos.
    PREDICTION_LATENCY.labels(model="bankchurn").observe(latency)  # observe(): registra en histogram.
    PREDICTIONS_TOTAL.labels(model="bankchurn", result=str(prediction)).inc()  # inc(): incrementa counter.
    PREDICTION_PROBABILITY.labels(model="bankchurn").observe(proba)  # Registra prob para detectar drift.
    
    return {"prediction": prediction, "probability": proba}
```

### 16.2.1 Prometheus Alerting Rules

> **Referencia del portafolio**: `infra/prometheus-rules.yaml`

```yaml
# prometheus-rules.yaml
groups:
  - name: ml-service-alerts
    rules:
      # Latencia alta
      - alert: HighPredictionLatency
        expr: histogram_quantile(0.99, rate(prediction_latency_seconds_bucket[5m])) > 0.2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Latencia P99 alta en {{ $labels.model }}"
          description: "P99 latencia es {{ $value }}s (umbral: 200ms)"
          runbook_url: "https://docs.example.com/runbooks/high-latency"

      # Error rate alto
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Error rate alto en {{ $labels.service }}"
          description: "Error rate es {{ $value | humanizePercentage }}"
          runbook_url: "https://docs.example.com/runbooks/high-error-rate"

      # Drift detectado
      - alert: DataDriftDetected
        expr: ml_drift_score > 0.15
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Data drift detectado en {{ $labels.model }}"
          description: "Drift score es {{ $value }} (umbral: 0.15)"
          runbook_url: "https://docs.example.com/runbooks/data-drift"

      # Servicio caído
      - alert: ServiceDown
        expr: up{job=~"bankchurn|carvision|telecomai"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Servicio {{ $labels.job }} está caído"
```

### Buenas prácticas para alertas

| Práctica | Descripción |
|----------|-------------|
| **Accionable** | Cada alerta debe tener un runbook con pasos concretos |
| **Umbral realista** | Basar umbrales en datos históricos, no en intuición |
| **Severidad apropiada** | `critical` solo para lo que requiere acción inmediata |
| **Evitar ruido** | Usar `for:` para evitar alertas por spikes temporales |

---

<a id="163-logging-estructurado"></a>
 
## 16.3 Logging Estructurado

### Configuración Profesional

```python
# src/logging_config.py

import logging
import json
import sys
from datetime import datetime


class JSONFormatter(logging.Formatter):
    """Formatter que produce logs en JSON para fácil parsing."""
    
    def format(self, record):
        log_obj = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        
        # Añadir extras si existen
        if hasattr(record, "request_id"):
            log_obj["request_id"] = record.request_id
        if hasattr(record, "user_id"):
            log_obj["user_id"] = record.user_id
        if hasattr(record, "prediction"):
            log_obj["prediction"] = record.prediction
        
        # Añadir exception si existe
        if record.exc_info:
            log_obj["exception"] = self.formatException(record.exc_info)
        
        return json.dumps(log_obj)


def setup_logging(level: str = "INFO", json_format: bool = True):
    """Configura logging para producción."""
    
    root = logging.getLogger()
    root.setLevel(getattr(logging, level.upper()))
    
    handler = logging.StreamHandler(sys.stdout)
    
    if json_format:
        handler.setFormatter(JSONFormatter())
    else:
        handler.setFormatter(logging.Formatter(
            "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
        ))
    
    root.addHandler(handler)
    
    # Silenciar loggers ruidosos
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
```

### Logs con Contexto

```python
import logging
import uuid

logger = logging.getLogger(__name__)

@app.post("/predict")
async def predict(request: PredictionRequest):
    request_id = str(uuid.uuid4())[:8]
    
    # Log con contexto
    logger.info(
        "Prediction request received",
        extra={
            "request_id": request_id,
            "credit_score": request.CreditScore,
            "geography": request.Geography,
        }
    )
    
    try:
        prediction = model.predict(...)
        
        logger.info(
            "Prediction completed",
            extra={
                "request_id": request_id,
                "prediction": prediction,
                "latency_ms": latency * 1000,
            }
        )
        
        return {"prediction": prediction}
    
    except Exception as e:
        logger.error(
            f"Prediction failed: {str(e)}",
            extra={"request_id": request_id},
            exc_info=True
        )
        raise
```

---

<a id="164-model-monitoring"></a>
 
## 16.4 Model Monitoring (Drift Detection)

### Script de Drift Detection

```python
# monitoring/check_drift.py - Código REAL del portafolio

"""
Detecta drift en datos usando Evidently AI.

Compara datos de referencia (training) con datos actuales (producción).
Genera reporte HTML y métricas JSON.

Uso:
    python monitoring/check_drift.py --reference data/train.csv --current data/recent.csv
"""

import argparse
import json
from pathlib import Path
from datetime import datetime

import pandas as pd

try:
    from evidently import ColumnMapping
    from evidently.report import Report
    from evidently.metric_preset import DataDriftPreset, DataQualityPreset
    EVIDENTLY_AVAILABLE = True
except ImportError:
    EVIDENTLY_AVAILABLE = False


def check_drift(
    reference_data: pd.DataFrame,
    current_data: pd.DataFrame,
    output_dir: Path,
    numerical_features: list = None,
    categorical_features: list = None,
) -> dict:
    """
    Ejecuta análisis de drift entre datos de referencia y actuales.
    
    Returns
    -------
    dict
        Métricas de drift incluyendo:
        - dataset_drift: bool (True si hay drift significativo)
        - drift_share: float (% de features con drift)
        - drifted_features: list (features con drift detectado)
    """
    
    if not EVIDENTLY_AVAILABLE:
        return {"error": "Evidently no instalado", "dataset_drift": None}
    
    # Column mapping
    column_mapping = ColumnMapping()
    if numerical_features:
        column_mapping.numerical_features = numerical_features
    if categorical_features:
        column_mapping.categorical_features = categorical_features
    
    # Crear reporte
    report = Report(metrics=[
        DataDriftPreset(),
        DataQualityPreset(),
    ])
    
    report.run(
        reference_data=reference_data,
        current_data=current_data,
        column_mapping=column_mapping
    )
    
    # Guardar HTML
    output_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    html_path = output_dir / f"drift_report_{timestamp}.html"
    report.save_html(str(html_path))
    
    # Extraer métricas
    results = report.as_dict()
    
    drift_metrics = {
        "timestamp": timestamp,
        "reference_rows": len(reference_data),
        "current_rows": len(current_data),
        "dataset_drift": False,
        "drift_share": 0.0,
        "drifted_features": [],
        "report_path": str(html_path),
    }
    
    # Parsear resultados de Evidently
    for metric in results.get("metrics", []):
        if "DataDriftTable" in str(metric.get("metric", "")):
            result = metric.get("result", {})
            drift_metrics["dataset_drift"] = result.get("dataset_drift", False)
            drift_metrics["drift_share"] = result.get("drift_share", 0.0)
            
            # Features con drift
            drift_by_columns = result.get("drift_by_columns", {})
            for col, col_data in drift_by_columns.items():
                if col_data.get("drift_detected", False):
                    drift_metrics["drifted_features"].append(col)
    
    # Guardar métricas JSON
    json_path = output_dir / f"drift_metrics_{timestamp}.json"
    with open(json_path, "w") as f:
        json.dump(drift_metrics, f, indent=2)
    
    return drift_metrics


def main():
    parser = argparse.ArgumentParser(description="Check data drift")
    parser.add_argument("--reference", required=True, help="Path to reference data CSV")
    parser.add_argument("--current", required=True, help="Path to current data CSV")
    parser.add_argument("--output", default="artifacts", help="Output directory")
    args = parser.parse_args()
    
    reference = pd.read_csv(args.reference)
    current = pd.read_csv(args.current)
    
    metrics = check_drift(reference, current, Path(args.output))
    
    print(json.dumps(metrics, indent=2))
    
    # Exit code basado en drift
    if metrics.get("dataset_drift"):
        print("⚠️ DRIFT DETECTADO")
        exit(1)
    else:
        print("✅ No hay drift significativo")
        exit(0)


if __name__ == "__main__":
    main()
```

### GitHub Action para Drift Scheduled

```yaml
# .github/workflows/drift-detection.yml

name: Drift Detection

on:
  schedule:
    - cron: '0 2 * * *'  # Diario a las 2am UTC
  workflow_dispatch:

jobs:
  check-drift:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install pandas evidently
      
      - name: Run drift check
        run: |
          python monitoring/check_drift.py \
            --reference data/reference/train.csv \
            --current data/recent/latest.csv \
            --output artifacts/drift
      
      - name: Upload report
        uses: actions/upload-artifact@v4
        with:
          name: drift-report
          path: artifacts/drift/
      
      - name: Create issue if drift detected
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '⚠️ Data Drift Detected',
              body: 'Drift detection workflow failed. Check the artifacts.',
              labels: ['drift', 'monitoring']
            })
```

---

<a id="165-runbooks-de-alertas"></a>

## 16.5 Runbooks de Alertas ⭐ NUEVO

Un **runbook** documenta los pasos exactos para responder a una alerta. Sin runbooks, las alertas son ruido; con runbooks, son acción.

### 16.5.1 Estructura de un Runbook

```markdown
# 🚨 Runbook: HighPredictionLatency

## Resumen
| Campo | Valor |
|-------|-------|
| Alerta | `HighPredictionLatency` |
| Severidad | Warning → Critical si persiste >15m |
| Impacto | UX degradada, timeouts en clientes |
| On-call | @ml-platform-team |

## Diagnóstico Rápido (< 2 min)

1. **Verificar si es puntual o sostenido**
   ```bash
   # Ver P99 de últimos 15 min
   curl -s "http://prometheus:9090/api/v1/query?query=histogram_quantile(0.99,rate(prediction_latency_seconds_bucket[15m]))" | jq
   ```

2. **Verificar recursos del servicio**
   ```bash
   docker stats bankchurn-api --no-stream
   # CPU > 80%? Memory > 85%?
   ```

3. **Verificar logs recientes**
   ```bash
   docker logs bankchurn-api --tail 100 --since 5m | grep -i error
   ```

## Causas Comunes y Soluciones

### Causa 1: Modelo demasiado grande en memoria
**Síntomas**: Memory alta, swap activo
**Solución**:
```bash
# Escalar horizontalmente
kubectl scale deployment bankchurn --replicas=3

# O reiniciar para liberar memoria
docker restart bankchurn-api
```

### Causa 2: Spike de tráfico
**Síntomas**: Request rate 3x+ del baseline
**Solución**:
```bash
# Verificar rate actual
curl -s "http://prometheus:9090/api/v1/query?query=rate(http_requests_total[5m])"

# Escalar si es necesario
kubectl autoscale deployment bankchurn --min=2 --max=10 --cpu-percent=70
```

### Causa 3: Datos de entrada anómalos
**Síntomas**: Latencia solo en algunos requests
**Solución**:
```bash
# Revisar payloads problemáticos en logs
docker logs bankchurn-api | grep "latency_ms.*[0-9]{4}" | tail 20

# Añadir validación de input más estricta
```

## Escalación
- Si no se resuelve en **15 min** → Escalar a @senior-ml-engineer
- Si impacto en revenue → Escalar a @on-call-manager
- Si es recurrente (3+ veces/semana) → Crear ticket para investigación root cause

## Post-mortem
Después de resolver, documentar:
- [ ] Timeline del incidente
- [ ] Root cause
- [ ] Acciones para prevenir recurrencia
```

### 16.5.2 Runbook: Data Drift Detectado

```markdown
# 🚨 Runbook: DataDriftDetected

## Resumen
| Campo | Valor |
|-------|-------|
| Alerta | `DataDriftDetected` |
| Severidad | Warning |
| Impacto | Predicciones potencialmente degradadas |
| Urgencia | 24-48h para investigar |

## Diagnóstico

1. **Revisar reporte de drift**
   ```bash
   # Ver último reporte
   ls -la artifacts/drift/
   # Abrir HTML en browser para análisis visual
   open artifacts/drift/drift_report_*.html
   ```

2. **Identificar features con drift**
   ```bash
   cat artifacts/drift/drift_metrics_*.json | jq '.drifted_features'
   ```

3. **Verificar si hay cambio en fuente de datos**
   - ¿Cambió el proveedor de datos?
   - ¿Hay un nuevo segmento de usuarios?
   - ¿Hay un bug en el pipeline de datos?

## Árbol de Decisión

```
¿Drift > 30% de features?
├── SÍ → Probable cambio en fuente de datos
│        → Investigar pipeline de ingesta
│        → Considerar retrain urgente
│
└── NO → Drift localizado
         ├── ¿Features críticas?
         │   ├── SÍ → Retrain en 1-2 días
         │   └── NO → Monitorear 1 semana
         │
         └── ¿Drift estacional esperado?
             ├── SÍ → Documentar, no acción
             └── NO → Investigar causa
```

## Acciones según severidad

| Drift Share | Acción |
|-------------|--------|
| < 10% | Monitorear, no acción inmediata |
| 10-30% | Investigar en 48h, considerar retrain |
| > 30% | Retrain urgente, posible rollback a modelo anterior |

## Comandos de Retrain

```bash
# 1. Verificar datos disponibles
ls -la data/recent/

# 2. Disparar retrain
python main.py --mode train --experiment-name "retrain-$(date +%Y%m%d)"

# 3. Comparar métricas
python scripts/compare_models.py --baseline production --candidate new

# 4. Si mejora, promover
python scripts/promote_model.py --model-name bankchurn --stage Production
```
```

### 16.5.3 Runbook: Service Down

```markdown
# 🚨 Runbook: ServiceDown

## Resumen
| Campo | Valor |
|-------|-------|
| Alerta | `ServiceDown` |
| Severidad | CRITICAL |
| Impacto | Servicio completamente inaccesible |
| SLA | Responder < 5 min |

## Diagnóstico Inmediato (< 1 min)

```bash
# 1. Verificar estado de contenedores
docker ps -a | grep -E "(bankchurn|carvision|telecom)"

# 2. Ver último log
docker logs --tail 50 <container_name>

# 3. Health check manual
curl -v http://localhost:8001/health
```

## Recuperación Rápida

### Opción A: Reiniciar servicio
```bash
docker restart bankchurn-api
# Esperar 30s y verificar
curl http://localhost:8001/health
```

### Opción B: Recrear contenedor
```bash
docker compose -f docker-compose.demo.yml up -d bankchurn
```

### Opción C: Rollback a versión anterior
```bash
# Si el problema es por deploy reciente
docker pull ghcr.io/duqueom/bankchurn:previous-tag
docker compose up -d
```

## Causas Comunes

| Causa | Diagnóstico | Solución |
|-------|-------------|----------|
| OOM Kill | `docker logs` muestra `Killed` | Aumentar memory limit |
| Puerto ocupado | `netstat -tlnp | grep 8001` | Matar proceso conflictivo |
| Modelo no encontrado | Log: `FileNotFoundError` | Verificar volumen montado |
| Crash en startup | Exit code 1 | Ver logs completos |

## Comunicación
- Notificar en #incidents-ml dentro de 5 min
- Si > 15 min: Actualizar status page
- Si > 30 min: Escalar a management
```

### 16.5.4 Template de Runbook

```markdown
# 🚨 Runbook: [NOMBRE_ALERTA]

## Resumen
| Campo | Valor |
|-------|-------|
| Alerta | `[nombre]` |
| Severidad | [Warning/Critical] |
| Impacto | [Descripción del impacto en usuarios/negocio] |
| SLA | [Tiempo máximo de respuesta] |
| Owner | [@team o @persona] |

## Diagnóstico
1. [Paso 1 con comando]
2. [Paso 2 con comando]
3. [Paso 3]

## Causas Comunes
| Causa | Síntomas | Solución |
|-------|----------|----------|
| [Causa 1] | [Cómo identificarla] | [Comandos/pasos] |
| [Causa 2] | [Cómo identificarla] | [Comandos/pasos] |

## Escalación
- [Cuándo escalar]
- [A quién escalar]

## Referencias
- [Links a dashboards relevantes]
- [Links a documentación]
```

### 16.5.5 Organización de Runbooks en el Repo

```
docs/runbooks/
├── README.md                    # Índice de runbooks
├── high-latency.md             # Latencia alta
├── high-error-rate.md          # Tasa de error
├── service-down.md             # Servicio caído
├── data-drift.md               # Drift detectado
├── model-degradation.md        # Degradación de métricas
└── disk-full.md                # Disco lleno (artifacts/logs)
```

---

<a id="errores-habituales"></a>
 
## 🧨 Errores habituales y cómo depurarlos en Observabilidad ML

En observabilidad ML es habitual tener dashboards bonitos pero poca señal útil, o scripts de drift que fallan en silencio.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) Métricas que no aparecen en Prometheus/Grafana

**Síntomas típicos**

- En Grafana, los paneles muestran `No data`.
- En Prometheus, la métrica `predictions_total` no existe o tiene solo ceros.

**Cómo identificarlo**

- Verifica que el endpoint `/metrics` responde localmente (`curl http://localhost:8000/metrics`).
- Revisa `prometheus-config.yaml`:
  - ¿El `job_name` y `targets` apuntan al host/puerto correctos?
  - ¿`metrics_path` es `/metrics`?

**Cómo corregirlo**

- Asegura que el API exponga `/metrics` y que el contenedor esté accesible desde Prometheus (mismo docker network).
- Usa nombres de servicio (`bankchurn:8000`) coherentes con `docker-compose`.

---

### 2) Alertas demasiado ruidosas (alert fatigue)

**Síntomas típicos**

- Canal de Slack/Email lleno de alertas constantes que el equipo ignora.

**Cómo identificarlo**

- Revisa las reglas de alerta: thresholds demasiado agresivos (por ejemplo, alertar por cualquier spike puntual).

**Cómo corregirlo**

- Usa ventanas de tiempo y reglas de severidad (warning vs critical).
- Define claramente métricas **críticas** (latencia P99, error rate, dataset_drift) y otras solo informativas.

---

### 3) Logs JSON imposibles de parsear

**Síntomas típicos**

- La herramienta de logs (ELK, Loki, etc.) no reconoce campos como `request_id` o `prediction`.
- Aparecen líneas mezcladas de formatos distintos.

**Cómo identificarlo**

- Revisa `setup_logging`: ¿todos los handlers usan `JSONFormatter` en producción?
- Busca logs que usen `print` en vez de `logger.info`.

**Cómo corregirlo**

- Centraliza la configuración de logging y evita crear loggers adicionales con otros formatos.
- Usa siempre `extra={...}` en los logs de negocio en vez de concatenar strings.

---

### 4) Script de drift que falla en CI o nunca encuentra drift

**Síntomas típicos**

- El workflow `drift-detection.yml` falla por `ImportError: evidently` o rutas incorrectas.
- El script siempre devuelve "✅ No hay drift" aunque sabes que los datos cambiaron.

**Cómo identificarlo**

- Revisa los paths `--reference` y `--current` usados en el workflow.
- Comprueba que `EVIDENTLY_AVAILABLE` es `True` y que las columnas de referencia/actual coinciden.

**Cómo corregirlo**

- Alinea las rutas de datos de referencia y actuales con la estructura de tu repo.
- Asegúrate de instalar `evidently` en el job de CI (`pip install evidently`).
- Revisa el JSON de métricas generado para validar que `drift_share` y `drifted_features` tienen sentido.

---

### 5) Patrón general de debugging en observabilidad ML

1. Empieza por el **flujo de datos**: API → `/metrics` → Prometheus → Grafana.
2. Verifica que logs y métricas contengan campos de negocio (no solo técnica básica).
3. Revisa periódicamente los umbrales de alerta según el comportamiento real del sistema.
4. Usa los reports de drift como insumo para decisiones, no como verdad absoluta: combínalos con métricas de negocio.

Con esta mentalidad, la observabilidad deja de ser un "extra" y se convierte en tu principal herramienta para operar modelos en producción.

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **Observability vs Monitoring**: Monitoring = métricas predefinidas, Observability = entender comportamiento inesperado.

2. **Three Pillars**: Logs, Metrics, Traces. Explica cada uno.

3. **ML Monitoring**: Model drift, data drift, concept drift.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Alertas | Evita alert fatigue: alerta solo lo accionable |
| Dashboards | Un dashboard por audiencia (ops, ML, negocio) |
| On-call | Documenta runbooks para cada alerta |
| Drift detection | Monitorea distribuciones de features y predictions |

### Métricas Clave para ML

- **Serving**: Latency p50/p95/p99, error rate, throughput
- **Model**: Prediction distribution, confidence scores
- **Data**: Missing values, schema changes, drift
- **Business**: Conversion, revenue impact


---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **Prometheus + Grafana Tutorial** | TechWorld with Nana | 50 min | [YouTube](https://www.youtube.com/watch?v=7gW5pSM6dlU) |
| 🟡 | **ML Model Monitoring with Evidently** | Evidently AI | 30 min | [YouTube](https://www.youtube.com/watch?v=L4Pv6ExBQPM) |
| 🟢 | **Drift Detection Explained** | NannyML | 25 min | [YouTube](https://www.youtube.com/watch?v=82Sb8n3wN24) |

### 📚 Cursos

| 🏷️ | Título | Plataforma | Duración | Link |
|:--:|:-------|:-----------|:--------:|:-----|
| 🟡 | ML Monitoring | Made With ML | 3h | [MadeWithML](https://madewithml.com/courses/mlops/monitoring/) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [Evidently Docs](https://docs.evidentlyai.com/) | Documentación oficial |
| 🟡 | [Prometheus Docs](https://prometheus.io/docs/) | Documentación de Prometheus |
| 🟢 | [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/) | Creación de dashboards |

---

## ⚖️ Decisión Técnica: ADR-011 Prometheus + Grafana

**Contexto**: Necesitamos monitorear modelos en producción y detectar drift.

**Decisión**: Usar Prometheus para métricas y Grafana para dashboards.

**Alternativas Consideradas**:
- **Datadog**: Excelente pero costoso
- **New Relic**: Similar a Datadog
- **CloudWatch/Stackdriver**: Vendor lock-in

**Consecuencias**:
- ✅ Open source, sin costo
- ✅ Estándar de la industria
- ✅ Alertas configurables
- ✅ Integración con K8s nativa
- ❌ Más setup que SaaS

---

## 🔧 Ejercicios del Módulo

### Ejercicio 16.1: Logging Estructurado
**Objetivo**: Implementar logging profesional en JSON.
**Dificultad**: ⭐⭐

```python
# TU TAREA: Configurar logging estructurado

import logging
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    """Formatter que produce logs en JSON."""
    
    def format(self, record):
        log_data = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            # TODO: Añadir más campos útiles
        }
        return json.dumps(log_data)

# TODO: Configurar logger con este formatter
```

<details>
<summary>💡 Ver solución</summary>

```python
import logging
import json
import sys
from datetime import datetime
from typing import Any

class JSONFormatter(logging.Formatter):
    """Formatter que produce logs en JSON estructurado."""
    
    def format(self, record: logging.LogRecord) -> str:
        log_data: dict[str, Any] = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        
        # Añadir campos extra si existen
        if hasattr(record, "customer_id"):
            log_data["customer_id"] = record.customer_id
        if hasattr(record, "prediction"):
            log_data["prediction"] = record.prediction
        if hasattr(record, "latency_ms"):
            log_data["latency_ms"] = record.latency_ms
            
        # Añadir exception si existe
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)
            
        return json.dumps(log_data)


def setup_logger(name: str = "ml_api") -> logging.Logger:
    """Configura logger con formato JSON."""
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    
    # Handler para stdout
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JSONFormatter())
    logger.addHandler(handler)
    
    return logger


# Uso:
logger = setup_logger()
logger.info("Prediction made", extra={"customer_id": 123, "prediction": 1, "latency_ms": 45})
# Output: {"timestamp": "2024-01-15T10:30:00Z", "level": "INFO", "message": "Prediction made", ...}
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **Data Drift** | Cambio en la distribución de features entre training y producción |
| **Concept Drift** | Cambio en la relación P(Y\|X) entre features y target |
| **PSI** | Population Stability Index - métrica para detectar drift |
| **Prometheus** | Sistema open source de monitoreo y alertas basado en métricas |
| **Grafana** | Plataforma de visualización para dashboards de métricas |

---

## 🏁 CHECKPOINT FASE 3: MLOps Core Completado

> 🎯 **¡Has completado los módulos 11-16!**
>
> Ahora dominas las prácticas que distinguen un proyecto ML profesional:
> - ✅ Testing para ML con 80%+ coverage
> - ✅ CI/CD con GitHub Actions
> - ✅ Docker multi-stage y docker-compose
> - ✅ APIs de producción con FastAPI
> - ✅ Dashboards interactivos con Streamlit
> - ✅ Observabilidad con Prometheus/Grafana y drift detection

---

### 📋 Exámenes de Hito: Testing y Deployment

#### Examen 3: Testing (Extracto)

**Código a Revisar:**
```python
# tests/test_model.py

def test_model():
    model = load_model()
    data = pd.read_csv("data/test.csv")
    predictions = model.predict(data)
    assert len(predictions) == len(data)
```

**Problemas a identificar:** ¿Qué falta en este test?

<details>
<summary>📝 Ver Solución</summary>

**Errores:**
1. No usa fixtures (hardcoded paths)
2. No verifica tipos de predicciones
3. No valida rangos válidos
4. No es reproducible (depende de archivo externo)

**Test Corregido:**
```python
import pytest
import numpy as np

@pytest.fixture
def sample_data():
    return pd.DataFrame({
        "feature1": [1.0, 2.0, 3.0],
        "feature2": [0.5, 1.5, 2.5],
    })

@pytest.fixture
def trained_model(sample_data):
    # Modelo entrenado en fixture
    return train_model(sample_data, labels=[0, 1, 0])

def test_predictions_shape(trained_model, sample_data):
    predictions = trained_model.predict(sample_data)
    assert len(predictions) == len(sample_data)
    
def test_predictions_valid_range(trained_model, sample_data):
    predictions = trained_model.predict(sample_data)
    assert all(p in [0, 1] for p in predictions)
    
def test_predictions_type(trained_model, sample_data):
    predictions = trained_model.predict(sample_data)
    assert isinstance(predictions, np.ndarray)
```
</details>

---

### 🎤 Simulacro de Entrevista: Nivel Mid

> **60 preguntas** para validar MLOps Core (Módulos 07-16)
> **Tiempo**: 90 minutos
> **Objetivo**: Preparación para posiciones Mid ML Engineer

#### Preguntas de Muestra

**Testing ML (10 preguntas)**
1. ¿Qué es la pirámide de testing y cómo aplica a ML?
2. ¿Cómo testeas que un modelo no tiene data leakage?
3. ¿Qué fixtures usarías en `conftest.py` para tests ML?

**CI/CD (10 preguntas)**
4. ¿Cómo configurarías matrix testing en GitHub Actions?
5. ¿Qué es un coverage gate y por qué es importante?
6. ¿Cómo integras security scanning en tu pipeline?

**Docker (10 preguntas)**
7. ¿Por qué usar multi-stage builds para ML?
8. ¿Cómo optimizas el tamaño de imagen Docker para ML?
9. ¿Qué es un usuario non-root y por qué usarlo?

**APIs (10 preguntas)**
10. ¿Cómo manejas errores en FastAPI para ML?
11. ¿Qué endpoints de health check implementarías?
12. ¿Cómo validas inputs con Pydantic en APIs ML?

**Observabilidad (10 preguntas)**
13. ¿Qué métricas capturarías para un modelo en producción?
14. ¿Cómo detectas data drift en producción?
15. ¿Diferencia entre logging estructurado y tradicional?

<details>
<summary>💡 Ver Respuestas de Muestra</summary>

**1. Pirámide de testing en ML:**
> Base: unit tests (funciones individuales), Medio: integration tests (pipeline completo), Top: E2E tests (API funcionando). En ML agregamos: tests de datos (schema, rangos), tests de modelo (reproducibilidad, métricas mínimas).

**7. Multi-stage builds:**
> Separamos build (instalar dependencias, compilar) de runtime (solo lo necesario para ejecutar). Reduce imagen de ~2GB a ~500MB. Stage 1: instala todo, Stage 2: copia solo wheels y código.

**14. Detectar data drift:**
> PSI (Population Stability Index) para features categóricas, KS-test para numéricas. Umbral típico: PSI > 0.2 = drift significativo. Herramientas: Evidently, Alibi Detect, Great Expectations.
</details>

---

[Ver simulacro completo →](simulacros/SIMULACRO_ENTREVISTA_MID.md)

---

## ✅ Checkpoint del Módulo

- [ ] Tienes endpoint `/metrics` en tu API
- [ ] Logs en formato JSON estructurado
- [ ] Script de drift detection funcional
- [ ] Alertas configuradas para métricas críticas

---

## 🔜 Siguiente Fase: Producción

Con MLOps Core completado, es hora de aprender **estrategias de despliegue e infraestructura**.

**[Comenzar Fase 4 → Módulo 17: Despliegue](17_DESPLIEGUE.md)**

---

<div align="center">

[← Streamlit Dashboards](15_STREAMLIT.md) | [Siguiente: Despliegue →](17_DESPLIEGUE.md)

</div>
