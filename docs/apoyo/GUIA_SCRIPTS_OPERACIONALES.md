# 🔧 Guía de Scripts Operacionales del Portafolio

> **Referencia completa de los scripts de operación, demo, auditoría y automatización del portafolio ML-MLOps-Portfolio.**

Esta guía te enseña a entender, usar y crear scripts operacionales profesionales como los del portafolio.

---

## 📋 Índice

- [Visión General](#vision-general)
- [Scripts del Portafolio](#scripts-del-portafolio)
- [1. Scripts de Demo](#1-scripts-de-demo)
- [2. Scripts de Testing](#2-scripts-de-testing)
- [3. Scripts de Datos](#3-scripts-de-datos)
- [4. Scripts de Modelos](#4-scripts-de-modelos)
- [5. Scripts de Auditoría](#5-scripts-de-auditoria)
- [6. Makefile: Orquestador Principal](#6-makefile-orquestador-principal)
- [7. 🔬 Ingeniería Inversa: Automatización](#ingenieria-inversa-automatizacion) ⭐ NUEVO
- [Patrones y Buenas Prácticas](#patrones-y-buenas-practicas)
- [Ejercicios](#ejercicios)

---

<a id="vision-general"></a>

## Visión General

### ¿Por Qué Scripts Operacionales?

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║  SCRIPTS OPERACIONALES = Automatización profesional de tareas repetitivas     ║
║                                                                               ║
║  SIN SCRIPTS:                          CON SCRIPTS:                           ║
║  ───────────                           ───────────                            ║
║  • "¿Cómo levanto el demo?"            • `make docker-demo`                   ║
║  • "¿Qué comandos corro para tests?"   • `make test`                          ║
║  • "¿Cómo verifico que todo está OK?"  • `bash scripts/health_check.py`       ║
║  • "¿Cómo preparo datos para CI?"      • `bash scripts/setup_demo_models.sh`  ║
║                                                                               ║
║  BENEFICIOS:                                                                  ║
║  • Onboarding rápido (nuevos devs corren `make install && make test`)        ║
║  • Reproducibilidad (mismos comandos en local y CI)                          ║
║  • Documentación ejecutable (el script ES la documentación)                  ║
║  • Menos errores humanos (no hay que recordar flags y paths)                 ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### Estructura de Scripts en el Portafolio

```
ML-MLOps-Portfolio/
├── scripts/                          # Scripts globales (root)
│   ├── demo.sh                       # Levanta stack completo
│   ├── setup_demo_models.sh          # Genera modelos para demo/CI
│   ├── run_demo_tests.sh             # Smoke tests de APIs
│   ├── run_e2e.sh                    # Tests end-to-end
│   ├── run_audit.sh                  # Auditoría completa (lint/type/sec)
│   ├── run_tests_top3.sh             # Tests de los 3 proyectos principales
│   ├── fetch_data.py                 # Descarga y valida datos
│   ├── health_check.py               # Verificación de servicios
│   ├── promote_model.py              # Promoción de modelos en registry
│   └── run_experiments.py            # Ejecuta experimentos MLflow
│
├── Makefile                          # Orquestador principal
│
├── BankChurn-Predictor/
│   ├── Makefile                      # Makefile del proyecto
│   └── scripts/                      # Scripts específicos del proyecto
│       └── run_mlflow.py
│
├── CarVision-Market-Intelligence/
│   └── Makefile
│
└── TelecomAI-Customer-Intelligence/
    └── Makefile
```

---

<a id="scripts-del-portafolio"></a>

## Scripts del Portafolio

### Mapa de Scripts → Módulos de la Guía

| Script | Propósito | Módulo(s) Relacionado(s) |
|--------|-----------|-------------------------|
| `demo.sh` | Levanta stack demo | 13_DOCKER, 17_DESPLIEGUE |
| `setup_demo_models.sh` | Genera modelos | 09_TRAINING, 13_DOCKER |
| `run_demo_tests.sh` | Smoke tests | 11_TESTING, 12_CI_CD |
| `run_audit.sh` | Auditoría | 05_GIT, 11_TESTING, 12_CI_CD |
| `fetch_data.py` | Datos | 06_VERSIONADO_DATOS |
| `health_check.py` | Verificación | 14_FASTAPI, 16_OBSERVABILIDAD |
| `promote_model.py` | Registry | 10_EXPERIMENT_TRACKING |
| `run_experiments.py` | MLflow | 10_EXPERIMENT_TRACKING |

---

<a id="1-scripts-de-demo"></a>

## 1. Scripts de Demo

### demo.sh — Levanta el Stack Completo

```bash
#!/bin/bash
# scripts/demo.sh — Demo end-to-end del portafolio
# Uso: bash scripts/demo.sh

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting ML-MLOps Portfolio Demo...${NC}"

# 1. Verificar requisitos
echo -e "${YELLOW}[1/5] Checking requirements...${NC}"
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker is required but not installed.${NC}"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || command -v "docker compose" >/dev/null 2>&1 || { echo -e "${RED}Docker Compose is required.${NC}"; exit 1; }

# 2. Generar modelos si no existen
echo -e "${YELLOW}[2/5] Ensuring demo models exist...${NC}"
if [ ! -f "BankChurn-Predictor/models/pipeline.joblib" ]; then
    echo "Generating demo models..."
    bash scripts/setup_demo_models.sh
fi

# 3. Build de imágenes
echo -e "${YELLOW}[3/5] Building Docker images...${NC}"
docker compose -f docker-compose.demo.yml build --quiet

# 4. Levantar servicios
echo -e "${YELLOW}[4/5] Starting services...${NC}"
docker compose -f docker-compose.demo.yml up -d

# 5. Esperar y verificar
echo -e "${YELLOW}[5/5] Waiting for services to be healthy...${NC}"
sleep 30

# Health checks
SERVICES=("localhost:5000" "localhost:8001" "localhost:8002" "localhost:8003")
NAMES=("MLflow" "BankChurn" "CarVision" "TelecomAI")

ALL_HEALTHY=true
for i in "${!SERVICES[@]}"; do
    if curl -sf "http://${SERVICES[$i]}/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ ${NAMES[$i]} is healthy${NC}"
    else
        echo -e "${RED}✗ ${NAMES[$i]} is NOT healthy${NC}"
        ALL_HEALTHY=false
    fi
done

if [ "$ALL_HEALTHY" = true ]; then
    echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Demo is ready!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════${NC}"
    echo -e "
    🏦 BankChurn API:    http://localhost:8001/docs
    🚗 CarVision API:    http://localhost:8002/docs
    🚗 CarVision UI:     http://localhost:8501
    📱 TelecomAI API:    http://localhost:8003/docs
    📊 MLflow:           http://localhost:5000
    "
else
    echo -e "\n${RED}⚠️ Some services are not healthy. Check logs:${NC}"
    echo "docker compose -f docker-compose.demo.yml logs"
    exit 1
fi
```

### setup_demo_models.sh — Genera Modelos para Demo/CI

```bash
#!/bin/bash
# scripts/setup_demo_models.sh — Genera modelos mínimos para demo y CI
# Estos modelos son rápidos de crear y suficientes para probar las APIs

set -e

echo "🔧 Setting up demo models..."

# BankChurn
echo "[1/3] BankChurn model..."
cd BankChurn-Predictor
python -c "
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import make_classification
import joblib
import os

# Crear modelo simple
X, y = make_classification(n_samples=1000, n_features=10, random_state=42)
model = RandomForestClassifier(n_estimators=10, random_state=42)
model.fit(X, y)

# Guardar
os.makedirs('models', exist_ok=True)
joblib.dump(model, 'models/pipeline.joblib')
print('  ✓ BankChurn model saved')
"
cd ..

# CarVision
echo "[2/3] CarVision model..."
cd CarVision-Market-Intelligence
python -c "
from sklearn.ensemble import RandomForestRegressor
from sklearn.datasets import make_regression
import joblib
import os

X, y = make_regression(n_samples=1000, n_features=10, random_state=42)
model = RandomForestRegressor(n_estimators=10, random_state=42)
model.fit(X, y)

os.makedirs('artifacts', exist_ok=True)
joblib.dump(model, 'artifacts/model.joblib')
print('  ✓ CarVision model saved')
"
cd ..

# TelecomAI
echo "[3/3] TelecomAI model..."
cd TelecomAI-Customer-Intelligence
python -c "
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.datasets import make_classification
import joblib
import os

X, y = make_classification(n_samples=1000, n_features=4, n_classes=3, n_informative=3, random_state=42)
model = GradientBoostingClassifier(n_estimators=10, random_state=42)
model.fit(X, y)

os.makedirs('artifacts', exist_ok=True)
joblib.dump(model, 'artifacts/model.joblib')
print('  ✓ TelecomAI model saved')
"
cd ..

echo "✅ All demo models created successfully!"
```

---

<a id="2-scripts-de-testing"></a>

## 2. Scripts de Testing

### run_demo_tests.sh — Smoke Tests de APIs

```bash
#!/bin/bash
# scripts/run_demo_tests.sh — Verifica que las APIs respondan correctamente

set -e

echo "🧪 Running demo tests..."

# Función para test de API
test_api() {
    local name=$1
    local url=$2
    local payload=$3
    
    echo -n "Testing $name... "
    
    response=$(curl -sf -X POST "$url" \
        -H "Content-Type: application/json" \
        -d "$payload" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "✓ OK"
        return 0
    else
        echo "✗ FAILED"
        return 1
    fi
}

# Test BankChurn
test_api "BankChurn /predict" \
    "http://localhost:8001/predict" \
    '{"CreditScore":650,"Geography":"France","Gender":"Female","Age":40,"Tenure":3,"Balance":60000,"NumOfProducts":2,"HasCrCard":1,"IsActiveMember":1,"EstimatedSalary":50000}'

# Test CarVision
test_api "CarVision /predict" \
    "http://localhost:8002/predict" \
    '{"model_year":2018,"model":"ford f-150","condition":"good","cylinders":6,"fuel":"gas","odometer":50000,"transmission":"automatic","drive":"4wd","type":"truck","paint_color":"white"}'

# Test TelecomAI
test_api "TelecomAI /predict" \
    "http://localhost:8003/predict" \
    '{"calls":40,"minutes":311.9,"messages":83,"mb_used":19915.42}'

# Health checks
echo ""
echo "Health endpoints:"
for port in 8001 8002 8003; do
    status=$(curl -sf "http://localhost:$port/health" | jq -r '.status' 2>/dev/null || echo "error")
    echo "  localhost:$port/health -> $status"
done

echo ""
echo "✅ All demo tests passed!"
```

### run_e2e.sh — Tests End-to-End

```bash
#!/bin/bash
# scripts/run_e2e.sh — Pipeline end-to-end completo

set -e

PROJECT=${1:-BankChurn-Predictor}
echo "🔄 Running E2E pipeline for $PROJECT..."

cd "$PROJECT"

# 1. Verificar datos
echo "[1/5] Checking data..."
if [ ! -f "data/raw/Churn_Modelling.csv" ] && [ ! -f "data/Churn_Modelling.csv" ]; then
    echo "⚠️ Data not found, attempting to fetch..."
    python scripts/fetch_data.py 2>/dev/null || echo "Skipping data fetch"
fi

# 2. Train
echo "[2/5] Training model..."
python main.py --mode train 2>/dev/null || python -m bankchurn.training

# 3. Test
echo "[3/5] Running tests..."
pytest tests/ -q --tb=short

# 4. Coverage
echo "[4/5] Checking coverage..."
pytest tests/ --cov=src/ --cov-fail-under=70 -q

# 5. API test
echo "[5/5] Testing API (if running)..."
if curl -sf http://localhost:8001/health >/dev/null 2>&1; then
    curl -sf http://localhost:8001/predict \
        -H "Content-Type: application/json" \
        -d '{"CreditScore":650,"Age":40}' || true
fi

echo ""
echo "✅ E2E pipeline completed for $PROJECT!"
```

---

<a id="3-scripts-de-datos"></a>

## 3. Scripts de Datos

### fetch_data.py — Descarga y Valida Datos

```python
#!/usr/bin/env python3
"""scripts/fetch_data.py — Descarga datasets con validación de integridad.

Uso:
    python scripts/fetch_data.py
    python scripts/fetch_data.py --project BankChurn-Predictor
    python scripts/fetch_data.py --verify-only
"""

import argparse
import hashlib
import json
import urllib.request
from pathlib import Path


# Registro de datasets con checksums para validación
DATASETS = {
    "BankChurn-Predictor": {
        "url": "https://raw.githubusercontent.com/example/data/churn.csv",
        "path": "data/raw/Churn_Modelling.csv",
        "checksum": "abc123...",  # SHA256
        "description": "Bank customer churn data"
    },
    "CarVision-Market-Intelligence": {
        "url": "https://example.com/vehicles.csv",
        "path": "data/vehicles_cleaned.csv",
        "checksum": "def456...",
        "description": "Vehicle listings for price prediction"
    }
}


def calculate_checksum(filepath: Path) -> str:
    """Calcula SHA256 de un archivo."""
    sha256 = hashlib.sha256()
    with open(filepath, "rb") as f:
        for block in iter(lambda: f.read(65536), b""):
            sha256.update(block)
    return sha256.hexdigest()


def download_dataset(project: str, force: bool = False) -> bool:
    """Descarga dataset para un proyecto."""
    if project not in DATASETS:
        print(f"❌ Unknown project: {project}")
        return False
    
    config = DATASETS[project]
    filepath = Path(project) / config["path"]
    
    # Verificar si ya existe y es válido
    if filepath.exists() and not force:
        actual_checksum = calculate_checksum(filepath)
        if actual_checksum == config["checksum"]:
            print(f"✓ {project}: Data already exists and is valid")
            return True
        else:
            print(f"⚠️ {project}: Checksum mismatch, re-downloading...")
    
    # Crear directorio
    filepath.parent.mkdir(parents=True, exist_ok=True)
    
    # Descargar
    print(f"📥 Downloading {config['description']}...")
    try:
        urllib.request.urlretrieve(config["url"], filepath)
        
        # Verificar checksum
        actual_checksum = calculate_checksum(filepath)
        if actual_checksum != config["checksum"]:
            print(f"❌ Checksum verification failed for {project}")
            return False
        
        print(f"✓ {project}: Downloaded and verified")
        return True
    except Exception as e:
        print(f"❌ Failed to download {project}: {e}")
        return False


def verify_all() -> dict:
    """Verifica integridad de todos los datasets."""
    results = {}
    for project, config in DATASETS.items():
        filepath = Path(project) / config["path"]
        if filepath.exists():
            actual = calculate_checksum(filepath)
            results[project] = {
                "exists": True,
                "valid": actual == config["checksum"],
                "path": str(filepath)
            }
        else:
            results[project] = {
                "exists": False,
                "valid": False,
                "path": str(filepath)
            }
    return results


def main():
    parser = argparse.ArgumentParser(description="Fetch and validate datasets")
    parser.add_argument("--project", help="Specific project to fetch")
    parser.add_argument("--verify-only", action="store_true", help="Only verify, don't download")
    parser.add_argument("--force", action="store_true", help="Force re-download")
    args = parser.parse_args()
    
    if args.verify_only:
        results = verify_all()
        print(json.dumps(results, indent=2))
        return
    
    if args.project:
        download_dataset(args.project, args.force)
    else:
        for project in DATASETS:
            download_dataset(project, args.force)


if __name__ == "__main__":
    main()
```

---

<a id="4-scripts-de-modelos"></a>

## 4. Scripts de Modelos

### promote_model.py — Promoción de Modelos en Registry

```python
#!/usr/bin/env python3
"""scripts/promote_model.py — Promueve modelos en MLflow Model Registry.

Uso:
    python scripts/promote_model.py --model-name bankchurn --stage Production
    python scripts/promote_model.py --run-id abc123 --stage Staging
    python scripts/promote_model.py --model-name bankchurn --stage Production --min-f1 0.6
"""

import argparse
import sys
from typing import Optional

import mlflow
from mlflow.tracking import MlflowClient


def get_best_run(experiment_name: str, metric: str = "f1_score") -> Optional[dict]:
    """Obtiene el mejor run de un experimento por métrica."""
    client = MlflowClient()
    experiment = client.get_experiment_by_name(experiment_name)
    
    if not experiment:
        print(f"❌ Experiment '{experiment_name}' not found")
        return None
    
    runs = client.search_runs(
        experiment_ids=[experiment.experiment_id],
        order_by=[f"metrics.{metric} DESC"],
        max_results=1
    )
    
    if not runs:
        print(f"❌ No runs found in experiment '{experiment_name}'")
        return None
    
    return runs[0]


def promote_model(
    model_name: str,
    stage: str,
    run_id: Optional[str] = None,
    min_metric: Optional[float] = None,
    metric_name: str = "f1_score"
) -> bool:
    """Promueve un modelo a un stage específico."""
    client = MlflowClient()
    
    # Si no se especifica run_id, buscar el mejor
    if not run_id:
        best_run = get_best_run(model_name, metric_name)
        if not best_run:
            return False
        run_id = best_run.info.run_id
        metric_value = best_run.data.metrics.get(metric_name, 0)
        
        print(f"📊 Best run: {run_id}")
        print(f"   {metric_name}: {metric_value:.4f}")
        
        # Verificar umbral mínimo
        if min_metric and metric_value < min_metric:
            print(f"❌ Metric {metric_value:.4f} is below threshold {min_metric}")
            return False
    
    # Registrar modelo si no existe
    try:
        model_uri = f"runs:/{run_id}/model"
        mv = mlflow.register_model(model_uri, model_name)
        version = mv.version
        print(f"✓ Registered model version {version}")
    except Exception as e:
        # Modelo ya registrado, obtener última versión
        versions = client.get_latest_versions(model_name)
        if versions:
            version = versions[0].version
        else:
            print(f"❌ Failed to register model: {e}")
            return False
    
    # Transicionar a nuevo stage
    client.transition_model_version_stage(
        name=model_name,
        version=version,
        stage=stage,
        archive_existing_versions=True  # Archiva versiones anteriores en ese stage
    )
    
    print(f"✅ Model '{model_name}' v{version} promoted to {stage}")
    return True


def main():
    parser = argparse.ArgumentParser(description="Promote models in MLflow Registry")
    parser.add_argument("--model-name", required=True, help="Name of the model")
    parser.add_argument("--stage", required=True, choices=["Staging", "Production", "Archived"])
    parser.add_argument("--run-id", help="Specific run ID to promote")
    parser.add_argument("--min-f1", type=float, help="Minimum F1 score required")
    parser.add_argument("--tracking-uri", default="http://localhost:5000")
    args = parser.parse_args()
    
    mlflow.set_tracking_uri(args.tracking_uri)
    
    success = promote_model(
        model_name=args.model_name,
        stage=args.stage,
        run_id=args.run_id,
        min_metric=args.min_f1,
        metric_name="f1_score"
    )
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
```

### health_check.py — Verificación de Servicios

```python
#!/usr/bin/env python3
"""scripts/health_check.py — Verifica estado de servicios ML.

Uso:
    python scripts/health_check.py
    python scripts/health_check.py --services bankchurn,carvision
    python scripts/health_check.py --json
"""

import argparse
import json
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from typing import Optional
import urllib.request
import urllib.error


@dataclass
class ServiceStatus:
    name: str
    url: str
    healthy: bool
    latency_ms: Optional[float] = None
    error: Optional[str] = None


# Servicios del portafolio
SERVICES = {
    "mlflow": "http://localhost:5000/health",
    "bankchurn": "http://localhost:8001/health",
    "carvision": "http://localhost:8002/health",
    "telecomai": "http://localhost:8003/health",
    "streamlit": "http://localhost:8501/_stcore/health",
    "prometheus": "http://localhost:9090/-/healthy",
    "grafana": "http://localhost:3000/api/health",
}


def check_service(name: str, url: str, timeout: float = 5.0) -> ServiceStatus:
    """Verifica un servicio individual."""
    import time
    
    start = time.time()
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=timeout) as response:
            latency = (time.time() - start) * 1000
            return ServiceStatus(
                name=name,
                url=url,
                healthy=response.status == 200,
                latency_ms=round(latency, 2)
            )
    except urllib.error.URLError as e:
        return ServiceStatus(
            name=name,
            url=url,
            healthy=False,
            error=str(e.reason)
        )
    except Exception as e:
        return ServiceStatus(
            name=name,
            url=url,
            healthy=False,
            error=str(e)
        )


def check_all_services(services: dict, parallel: bool = True) -> list[ServiceStatus]:
    """Verifica todos los servicios."""
    results = []
    
    if parallel:
        with ThreadPoolExecutor(max_workers=len(services)) as executor:
            futures = {
                executor.submit(check_service, name, url): name
                for name, url in services.items()
            }
            for future in as_completed(futures):
                results.append(future.result())
    else:
        for name, url in services.items():
            results.append(check_service(name, url))
    
    return sorted(results, key=lambda x: x.name)


def print_status(results: list[ServiceStatus], as_json: bool = False):
    """Imprime resultados."""
    if as_json:
        data = [
            {
                "name": r.name,
                "url": r.url,
                "healthy": r.healthy,
                "latency_ms": r.latency_ms,
                "error": r.error
            }
            for r in results
        ]
        print(json.dumps(data, indent=2))
        return
    
    print("\n" + "=" * 60)
    print("SERVICE HEALTH CHECK")
    print("=" * 60)
    
    for r in results:
        status = "✅" if r.healthy else "❌"
        latency = f"({r.latency_ms}ms)" if r.latency_ms else ""
        error = f" - {r.error}" if r.error else ""
        print(f"{status} {r.name:15} {latency:12} {error}")
    
    healthy_count = sum(1 for r in results if r.healthy)
    print("=" * 60)
    print(f"Total: {healthy_count}/{len(results)} services healthy")
    print("=" * 60 + "\n")


def main():
    parser = argparse.ArgumentParser(description="Check ML services health")
    parser.add_argument("--services", help="Comma-separated list of services to check")
    parser.add_argument("--json", action="store_true", help="Output as JSON")
    parser.add_argument("--timeout", type=float, default=5.0, help="Timeout in seconds")
    args = parser.parse_args()
    
    # Filtrar servicios si se especifica
    services = SERVICES
    if args.services:
        requested = set(args.services.lower().split(","))
        services = {k: v for k, v in SERVICES.items() if k in requested}
    
    results = check_all_services(services)
    print_status(results, as_json=args.json)
    
    # Exit code basado en salud
    all_healthy = all(r.healthy for r in results)
    sys.exit(0 if all_healthy else 1)


if __name__ == "__main__":
    main()
```

---

<a id="5-scripts-de-auditoria"></a>

## 5. Scripts de Auditoría

### run_audit.sh — Auditoría Completa

```bash
#!/bin/bash
# scripts/run_audit.sh — Auditoría completa de código, tipos y seguridad

set -e

REPORT_DIR="reports/audit"
mkdir -p "$REPORT_DIR"

echo "🔍 Starting full audit..."
echo "Reports will be saved to: $REPORT_DIR"
echo ""

# 1. Linting con ruff/flake8
echo "═══════════════════════════════════════════"
echo "[1/5] Code Style (flake8/ruff)"
echo "═══════════════════════════════════════════"

for project in BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence; do
    echo "Checking $project..."
    flake8 "$project/src" --output-file="$REPORT_DIR/flake8-$project.txt" \
        --count --statistics 2>/dev/null || true
    
    # Mostrar resumen
    if [ -f "$REPORT_DIR/flake8-$project.txt" ]; then
        errors=$(wc -l < "$REPORT_DIR/flake8-$project.txt")
        echo "  → $errors issues found"
    fi
done
echo ""

# 2. Formateo con black
echo "═══════════════════════════════════════════"
echo "[2/5] Formatting (black)"
echo "═══════════════════════════════════════════"

for project in BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence; do
    echo "Checking $project..."
    black --check "$project/src" "$project/app" 2>/dev/null || echo "  → Formatting issues found"
done
echo ""

# 3. Type checking con mypy
echo "═══════════════════════════════════════════"
echo "[3/5] Type Checking (mypy)"
echo "═══════════════════════════════════════════"

for project in BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence; do
    echo "Checking $project..."
    mypy "$project/src" --ignore-missing-imports \
        --html-report "$REPORT_DIR/mypy-$project" 2>/dev/null || echo "  → Type issues found"
done
echo ""

# 4. Security con bandit
echo "═══════════════════════════════════════════"
echo "[4/5] Security (bandit)"
echo "═══════════════════════════════════════════"

for project in BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence; do
    echo "Scanning $project..."
    bandit -r "$project/src" -f json -o "$REPORT_DIR/bandit-$project.json" 2>/dev/null || true
    
    # Mostrar resumen
    if [ -f "$REPORT_DIR/bandit-$project.json" ]; then
        high=$(jq '.metrics._totals."SEVERITY.HIGH"' "$REPORT_DIR/bandit-$project.json" 2>/dev/null || echo 0)
        medium=$(jq '.metrics._totals."SEVERITY.MEDIUM"' "$REPORT_DIR/bandit-$project.json" 2>/dev/null || echo 0)
        echo "  → High: $high, Medium: $medium"
    fi
done
echo ""

# 5. Secrets con gitleaks
echo "═══════════════════════════════════════════"
echo "[5/5] Secret Detection (gitleaks)"
echo "═══════════════════════════════════════════"

if command -v gitleaks &> /dev/null; then
    gitleaks detect --source . --report-path "$REPORT_DIR/gitleaks.json" --report-format json 2>/dev/null || true
    echo "  → Report saved to $REPORT_DIR/gitleaks.json"
else
    echo "  → gitleaks not installed, skipping"
fi
echo ""

# Resumen final
echo "═══════════════════════════════════════════"
echo "AUDIT COMPLETE"
echo "═══════════════════════════════════════════"
echo "Reports saved to: $REPORT_DIR/"
ls -la "$REPORT_DIR/"
```

---

<a id="6-makefile-orquestador-principal"></a>

## 6. Makefile: Orquestador Principal

El Makefile es el punto de entrada principal para todas las operaciones:

```makefile
# Makefile — ML-MLOps Portfolio
# Comandos unificados para desarrollo, testing y operaciones

.PHONY: help install test lint format docker-build docker-demo clean

# Variables
PROJECTS := BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence
PYTHON := python3

# Colores
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

# ═══════════════════════════════════════════════════════════════════════════
# HELP
# ═══════════════════════════════════════════════════════════════════════════

help: ## Muestra esta ayuda
	@echo "$(GREEN)ML-MLOps Portfolio - Comandos disponibles:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

# ═══════════════════════════════════════════════════════════════════════════
# DESARROLLO
# ═══════════════════════════════════════════════════════════════════════════

install: ## Instala dependencias de todos los proyectos
	@for project in $(PROJECTS); do \
		echo "$(GREEN)Installing $$project...$(NC)"; \
		cd $$project && pip install -e ".[dev]" && cd ..; \
	done

install-dev: ## Instala herramientas de desarrollo
	pip install pre-commit black flake8 mypy pytest pytest-cov bandit

# ═══════════════════════════════════════════════════════════════════════════
# TESTING
# ═══════════════════════════════════════════════════════════════════════════

test: ## Ejecuta tests de todos los proyectos
	@for project in $(PROJECTS); do \
		echo "$(GREEN)Testing $$project...$(NC)"; \
		cd $$project && pytest tests/ -q && cd ..; \
	done

test-coverage: ## Tests con reporte de coverage
	@for project in $(PROJECTS); do \
		echo "$(GREEN)Coverage for $$project...$(NC)"; \
		cd $$project && pytest --cov=src/ --cov-report=term-missing && cd ..; \
	done

# ═══════════════════════════════════════════════════════════════════════════
# CALIDAD DE CÓDIGO
# ═══════════════════════════════════════════════════════════════════════════

lint: ## Ejecuta linting
	@pre-commit run --all-files || true

format: ## Formatea código con black
	@black . --exclude '/(\.venv|data|artifacts|mlruns)/'
	@isort . --skip-gitignore

typecheck: ## Type checking con mypy
	@for project in $(PROJECTS); do \
		mypy $$project/src/ --ignore-missing-imports || true; \
	done

audit: ## Auditoría completa (lint + types + security)
	bash scripts/run_audit.sh

# ═══════════════════════════════════════════════════════════════════════════
# DOCKER
# ═══════════════════════════════════════════════════════════════════════════

docker-build: ## Construye imágenes Docker
	@for project in $(PROJECTS); do \
		echo "$(GREEN)Building $$project...$(NC)"; \
		docker build -t $$(echo $$project | tr '[:upper:]' '[:lower:]'):latest $$project; \
	done

docker-demo: ## Inicia stack demo completo
	bash scripts/demo.sh

docker-demo-up: ## Inicia servicios (sin build)
	docker compose -f docker-compose.demo.yml up -d

docker-demo-down: ## Detiene servicios
	docker compose -f docker-compose.demo.yml down

docker-logs: ## Ver logs de servicios
	docker compose -f docker-compose.demo.yml logs -f

# ═══════════════════════════════════════════════════════════════════════════
# MLFLOW Y EXPERIMENTOS
# ═══════════════════════════════════════════════════════════════════════════

mlflow-ui: ## Inicia MLflow UI local
	mlflow ui --port 5000 --backend-store-uri ./mlruns

experiments: ## Ejecuta experimentos de todos los proyectos
	$(PYTHON) scripts/run_experiments.py

# ═══════════════════════════════════════════════════════════════════════════
# HEALTH Y VERIFICACIÓN
# ═══════════════════════════════════════════════════════════════════════════

health-check: ## Verifica salud de servicios
	$(PYTHON) scripts/health_check.py

smoke-test: ## Smoke tests de APIs
	bash scripts/run_demo_tests.sh

# ═══════════════════════════════════════════════════════════════════════════
# LIMPIEZA
# ═══════════════════════════════════════════════════════════════════════════

clean: ## Limpia archivos temporales
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name .pytest_cache -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name htmlcov -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete
	find . -name ".coverage" -delete

clean-docker: ## Limpia contenedores e imágenes
	docker compose -f docker-compose.demo.yml down -v --remove-orphans
	@for project in $(PROJECTS); do \
		docker rmi $$(echo $$project | tr '[:upper:]' '[:lower:]'):latest 2>/dev/null || true; \
	done

# Default
.DEFAULT_GOAL := help
```

---

<a id="ingenieria-inversa-automatizacion"></a>

## 7. 🔬 Ingeniería Inversa Pedagógica: La Automatización Invisible

> **Objetivo**: Entender cómo se orquestan 3 proyectos y múltiples servicios con un solo comando.

Esta sección analiza el "pegamento" que mantiene unido el portafolio: el `Makefile` raíz y el script `demo.sh`.

### 7.1 El Patrón "Recursive Make" (Makefile)

En un monorepo, no queremos duplicar comandos. El `Makefile` raíz actúa como un **director de orquesta** que delega en los `Makefiles` de cada músico (proyecto).

**Archivo**: `Makefile` (raíz)

```makefile
# BLOQUE: Iteración sobre proyectos
# ─────────────────────────────────
PROJECTS := BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence

install:
	@for project in $(PROJECTS); do \              # 1. Itera por cada carpeta
		echo "Installing $$project..."; \
		cd $$project && $(MAKE) install && cd ..; \ # 2. Entra, ejecuta make local, y sale
	done
```

**¿Por qué hacerlo así?**
- **Encapsulamiento**: Cada proyecto sabe cómo instalarse a sí mismo. El raíz no necesita saber qué librerías usa `BankChurn`.
- **Escalabilidad**: Si añades un 4º proyecto, solo lo agregas a la lista `PROJECTS`.

### 7.2 Anatomía de `scripts/demo.sh`

Este script no es solo una lista de comandos; es un **flujo de orquestación robusto**.

**Archivo**: `scripts/demo.sh`

```bash
# BLOQUE: Espera Activa (Polling)
# ───────────────────────────────
# Problema: docker-compose up retorna inmediatamente, pero los servicios tardan en arrancar.
# Solución: No usar sleep fijos (flaky), usar polling de health endpoints.

echo "Waiting for services..."
SERVICES=("localhost:5000" "localhost:8001" ...)

for i in "${!SERVICES[@]}"; do
    # curl -f: Falla si el código HTTP no es 200 (ej. 500, 404)
    # Reintenta implícitamente o el usuario debe implementar el loop
    if curl -sf "http://${SERVICES[$i]}/health" >/dev/null; then
        echo "✓ Healthy"
    fi
done
```

### 7.3 Troubleshooting de Automatización

| Error Común | Causa | Solución |
|-------------|-------|----------|
| `make: *** [BankChurn-Predictor] Error 2` | Falló el make del subproyecto | Ve al directorio del proyecto y corre `make` allí para ver el error real. |
| `curl: (7) Failed to connect` en demo | El servicio no ha arrancado aún | Aumenta el tiempo de espera o revisa `docker logs` para ver si crasheó al inicio. |
| `Permission denied` en scripts | Falta bit de ejecución | `chmod +x scripts/*.sh` |

---

<a id="patrones-y-buenas-practicas"></a>

## Patrones y Buenas Prácticas

### 1. Siempre Usa `set -e` en Bash

```bash
#!/bin/bash
set -e  # Salir inmediatamente si hay error
set -u  # Error si se usa variable no definida
set -o pipefail  # Propagar errores en pipes
```

### 2. Proporciona Colores y Feedback

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}✓ Success${NC}"
echo -e "${RED}✗ Error${NC}"
echo -e "${YELLOW}⚠ Warning${NC}"
```

### 3. Verifica Requisitos al Inicio

```bash
# Verificar que Docker esté instalado
command -v docker >/dev/null 2>&1 || { echo "Docker required"; exit 1; }

# Verificar que un archivo exista
[ -f "config.yaml" ] || { echo "config.yaml not found"; exit 1; }
```

### 4. Usa Funciones para Reutilización

```bash
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

check_service() {
    local url=$1
    curl -sf "$url" >/dev/null 2>&1
}
```

### 5. Documenta el Uso

```bash
#!/bin/bash
# Script: my_script.sh
# Descripción: Hace algo importante
# Uso: bash my_script.sh [opciones]
# Opciones:
#   --force    Forzar operación
#   --dry-run  Solo mostrar qué haría
```

---

<a id="ejercicios"></a>

## 🔧 Ejercicios

### Ejercicio 1: Crear Script de Setup

Crea un script `setup.sh` que:
1. Verifique Python 3.10+
2. Cree un venv
3. Instale dependencias
4. Corra tests

### Ejercicio 2: Script de Backup de Modelos

Crea `backup_models.sh` que:
1. Liste todos los modelos en `models/` y `artifacts/`
2. Los comprima con fecha
3. Los suba a un directorio de backup

### Ejercicio 3: Health Check con Alertas

Modifica `health_check.py` para:
1. Enviar alerta si un servicio está caído
2. Guardar historial de checks
3. Calcular uptime

---

## 📚 Referencias

- **[MAPA_PORTAFOLIO_1TO1.md](../MAPA_PORTAFOLIO_1TO1.md)** — Mapeo de scripts a módulos
- **[12_CI_CD.md](../12_CI_CD.md)** — Cómo se usan estos scripts en CI
- **[13_DOCKER.md](../13_DOCKER.md)** — Docker Compose y orquestación
- **[16_OBSERVABILIDAD.md](../16_OBSERVABILIDAD.md)** — Health checks y monitoreo

---

<div align="center">

[← Volver al Índice](../00_INDICE.md)

</div>
