# 20. Proyecto Integrador
 
 <a id="00-prerrequisitos"></a>
 
 ## 0.0 Prerrequisitos
 
 - Haber completado los módulos 01–19 (en particular: Testing, CI/CD, APIs, Observabilidad y Documentación).
 - Tener listo un repositorio “vacío pero bien estructurado” (o estar dispuesto a crearlo primero) antes de entrenar cualquier modelo.
 - Aceptar el enfoque de este módulo: *integración por capas* (estructura → pipeline → tests → API → Docker → CI/CD → docs).
 
 ---
 
 <a id="01-protocolo-e-como-estudiar-este-modulo"></a>
 
 ## 0.1 🧠 Protocolo E: Cómo estudiar este módulo
 
 - **Antes de empezar**: define un “alcance senior” realista (qué vas a construir y qué NO).
 - **Durante**: trabaja con commits pequeños, y valida cada capa (instalación, tests, API) antes de pasar a la siguiente.
 - **Si te atoras >15 min** (tests rotos, CI fallando, configs duplicadas), regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.
 
 ---
 
 <a id="02-entregables-verificables-minimo-viable"></a>
 
 ## 0.2 ✅ Entregables verificables (mínimo viable)
 
 - [ ] El repo instala con `pip install -e .` (sin pasos manuales ocultos).
 - [ ] `make test` pasa en local con coverage objetivo.
 - [ ] `make train` produce artefactos reproducibles (y el pipeline se puede re-ejecutar).
 - [ ] La API expone `/health` y `/predict` y tiene tests mínimos.
 - [ ] Hay documentación mínima (README + Model/Data card).
 
 ---
 
 <a id="03-puente-teoria-codigo-portafolio"></a>
 
 ## 0.3 🧩 Puente teoría ↔ código (Portafolio)
 
 - Este módulo es tu “**producto final**”: demostrar que puedes ensamblar un sistema ML completo, no solo un modelo.
 - Reutiliza patrones del portafolio (estructura `src/`, config, tests, CI) pero justificando adaptaciones.
 - Tu objetivo es que un revisor pueda clonar tu repo, ejecutar 2–3 comandos y ver el sistema funcionando.
 
 ---
 
 ## 📋 Contenido
 
 - **0.0** [Prerrequisitos](#00-prerrequisitos)
 - **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
 - **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
 - **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
 - **20.1** [Objetivo](#201-objetivo)
 - **20.2** [El Proyecto: Sistema de Recomendación de Planes](#202-el-proyecto-sistema-de-recomendacion-de-planes)
 - **20.3** [Checklist de Entrega (100 puntos)](#203-checklist-de-entrega-100-puntos)
 - **20.4** [Plantilla de README](#204-plantilla-de-readme)
 - **20.5** [Rúbrica de Evaluación](#205-rubrica-de-evaluacion)
 - [Errores habituales](#errores-habituales)
 - **20.6** [Tips para Éxito](#206-tips-para-exito)
 - **20.7** [Consejos Profesionales](#207-consejos-profesionales)
 - **20.8** [Recursos Externos Recomendados](#208-recursos-externos-recomendados)
 - **20.9** [Referencias del Glosario](#209-referencias-del-glosario)
- [✅ Ejercicio](#ejercicio)
- **20.10** [Entrega](#2010-entrega)
- **23.11** [🔬 Ingeniería Inversa: Arquitectura Monorepo](#2011-monorepo) ⭐ NUEVO
- [✅ Checkpoint](#checkpoint)
 
 ---
 
 <a id="201-objetivo"></a>
 
 ## 🎯 Objetivo
 
 Construir un proyecto ML completo desde cero, aplicando TODO lo aprendido.
 
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  🏆 EL RETO FINAL                                                            ║
║                                                                              ║
║  Has aprendido los conceptos. Has estudiado el código del portafolio.        ║
║  Ahora es momento de DEMOSTRAR que puedes construirlo desde cero.            ║
║                                                                              ║
║  TIEMPO: 1-2 semanas                                                         ║
║  RESULTADO: Un 4to proyecto digno del portafolio                             ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 <a id="202-el-proyecto-sistema-de-recomendacion-de-planes"></a> El Proyecto: Sistema de Recomendación de Planes

**Contexto**: Una empresa de telecomunicaciones quiere recomendar planes móviles basándose en el comportamiento del usuario.

**Dataset sugerido**: [Telecom Users Dataset](https://www.kaggle.com/datasets) o similar.

---

## ✅ <a id="203-checklist-de-entrega-100-puntos"></a> Checklist de Entrega (100 puntos)

### Fase 1: Estructura y Configuración (20 puntos)

| Requisito | Puntos | Archivo |
|-----------|:------:|---------|
| Estructura src/ layout | 3 | `src/planrec/` |
| pyproject.toml completo | 3 | `pyproject.toml` |
| Makefile con comandos básicos | 2 | `Makefile` |
| Config Pydantic con validación | 4 | `src/planrec/config.py` |
| Config YAML externo | 2 | `configs/config.yaml` |
| .gitignore apropiado | 2 | `.gitignore` |
| README profesional | 4 | `README.md` |

### Fase 2: Pipeline ML (25 puntos)

| Requisito | Puntos | Archivo |
|-----------|:------:|---------|
| Carga y validación de datos | 3 | `src/planrec/data.py` |
| Feature Engineering como Transformer | 5 | `src/planrec/features.py` |
| sklearn Pipeline unificado | 5 | `src/planrec/training.py` |
| Cross-validation estratificada | 3 | `src/planrec/training.py` |
| Métricas apropiadas (F1, AUC) | 3 | `src/planrec/evaluation.py` |
| Guardado de artefactos | 3 | `artifacts/` |
| Prevención de data leakage | 3 | `drop_columns` en config |

### Fase 3: Testing (20 puntos)

| Requisito | Puntos | Archivo |
|-----------|:------:|---------|
| conftest.py con fixtures | 4 | `tests/conftest.py` |
| Tests unitarios (features) | 4 | `tests/test_features.py` |
| Tests de datos | 3 | `tests/test_data.py` |
| Tests de modelo | 3 | `tests/test_model.py` |
| Tests de integración | 3 | `tests/test_training.py` |
| Coverage ≥ 80% | 3 | `pytest --cov` |

### Fase 4: API y Serving (15 puntos)

| Requisito | Puntos | Archivo |
|-----------|:------:|---------|
| FastAPI con Pydantic schemas | 4 | `app/fastapi_app.py` |
| Endpoint /health | 2 | |
| Endpoint /predict | 4 | |
| Dockerfile multi-stage | 3 | `Dockerfile` |
| Non-root user | 2 | |

### Fase 5: CI/CD y Calidad (15 puntos)

| Requisito | Puntos | Archivo |
|-----------|:------:|---------|
| GitHub Actions workflow | 5 | `.github/workflows/ci.yml` |
| Tests automáticos | 3 | |
| Coverage enforcement | 3 | |
| Linting (ruff/black) | 2 | |
| Pre-commit hooks | 2 | `.pre-commit-config.yaml` |

### Fase 6: Documentación (5 puntos)

| Requisito | Puntos | Archivo |
|-----------|:------:|---------|
| Model Card | 3 | `docs/model_card.md` |
| Data Card | 2 | `docs/data_card.md` |

---

## 📝 <a id="204-plantilla-de-readme"></a> Plantilla de README

```markdown
# 📱 PlanRec: Mobile Plan Recommender

[![CI](https://github.com/USER/planrec/actions/workflows/ci.yml/badge.svg)](...)
[![Coverage](https://img.shields.io/badge/Coverage-85%25-brightgreen)](...)
[![Python](https://img.shields.io/badge/Python-3.11-blue)](...)

> Sistema de recomendación de planes móviles basado en comportamiento de usuarios.

## 🎯 Resumen del Proyecto

| Métrica | Valor |
|---------|-------|
| **Accuracy** | 85% |
| **F1-Score** | 0.82 |
| **Coverage** | 85% |

## 🚀 Quick Start

\`\`\`bash
# Instalar
pip install -e ".[dev]"

# Entrenar
make train

# Servir API
make serve

# Tests
make test
\`\`\`

## 📁 Estructura

\`\`\`
planrec/
├── src/planrec/       # Código fuente
├── app/               # FastAPI
├── tests/             # Tests
├── configs/           # Configuración
└── artifacts/         # Modelos (gitignored)
\`\`\`

## 📊 Arquitectura

[Diagrama de arquitectura]

## 🛠️ Stack Tecnológico

- **ML**: scikit-learn, pandas, numpy
- **API**: FastAPI, uvicorn
- **Config**: Pydantic, PyYAML
- **Testing**: pytest, pytest-cov
- **CI/CD**: GitHub Actions
- **Container**: Docker

## 📖 Documentación

- [Model Card](docs/model_card.md)
- [Data Card](docs/data_card.md)
```

---

## 🎯 <a id="205-rubrica-de-evaluacion"></a> Rúbrica de Evaluación

### Nivel Junior (50-69 puntos)
- Funciona pero con estructura básica
- Tests mínimos
- Sin CI/CD

### Nivel Mid (70-84 puntos)
- Estructura correcta
- Tests con coverage > 70%
- CI básico

### Nivel Senior (85-94 puntos)
- Custom Transformer funcionando
- Coverage > 80%
- CI/CD completo
- Documentación profesional

### Nivel Staff (95-100 puntos)
- Todo lo anterior
- Drift detection
- MLflow integration
- Model Card completo
- Code review pasable en FAANG

---

## 🧨 <a id="errores-habituales"></a> Errores habituales y cómo depurarlos en el Proyecto Integrador

En el proyecto integrador el mayor reto no es una tecnología concreta, sino **coordinar todas las piezas** sin romper nada en el camino.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) Empezar por el modelo y olvidar la estructura

**Síntomas típicos**

- Tienes notebooks y scripts sueltos, pero no un paquete `src/planrec` ni `pyproject.toml` claros.
- Es difícil correr el proyecto en otra máquina o en CI.

**Cómo identificarlo**

- Pregúntate: ¿puedo ejecutar `pip install -e .` y luego `python -m planrec.cli` o similar?

**Cómo corregirlo**

- Copia la estructura de BankChurn/CarVision: `src/`, `configs/`, `app/`, `tests/`, `artifacts/`.
- Define desde el inicio `pyproject.toml`, `Makefile` y `.gitignore`.

---

### 2) Config dispersa o duplicada

**Síntomas típicos**

- Rutas de datos, thresholds o hiperparámetros hardcodeados en varios archivos.
- Cambias algo en un sitio y se rompe otra parte.

**Cómo identificarlo**

- Busca valores repetidos (por ejemplo, paths o columnas) en múltiples módulos.

**Cómo corregirlo**

- Centraliza configuración en `configs/config.yaml` y una clase Pydantic (`Config`) que valide todo.
- Haz que training, API y scripts lean SIEMPRE desde esa fuente de verdad.

---

### 3) Tests que no cubren el flujo completo

**Síntomas típicos**

- Coverage aceptable, pero sin tests de integración ni de API.
- El pipeline entero falla cuando intentas ejecutar `make train` o el endpoint `/predict`.

**Cómo identificarlo**

- Revisa si tienes al menos:
  - Tests de features (`test_features.py`).
  - Tests de datos (`test_data.py`).
  - Tests de entrenamiento/integración (`test_training.py`).

**Cómo corregirlo**

- Añade al menos un test que recorra el flujo E2E con datos pequeños, similar a los de CarVision.
- Usa fixtures y `tmp_path` para no depender de rutas reales.

---

### 4) CI/CD que solo corre en local

**Síntomas típicos**

- Tienes un archivo `.github/workflows/ci.yml` pero los jobs fallan siempre en GitHub.

**Cómo identificarlo**

- Compara el workflow con el del portafolio: ¿coinciden `working-directory`, versiones de Python y comandos?

**Cómo corregirlo**

- Simplifica primero: un job que haga `pip install -e .` y `pytest`.
- Añade coverage y linting cuando el flujo básico sea estable.

---

### 5) Patrón general de debugging del proyecto integrador

1. Valida la **base**: estructura, instalación (`pip install -e .`), `make test`.
2. Asegúrate de que el **pipeline de training** funciona de principio a fin con datos pequeños.
3. Solo entonces añade API, Docker y CI/CD, verificando cada capa con su propio conjunto de tests.

Con este enfoque, reduces la frustración y aumentas la probabilidad de tener un **4º proyecto sólido de portafolio**.

---

## 💡 <a id="206-tips-para-exito"></a> Tips para Éxito

1. **Empieza por la estructura** - No escribas código sin tener pyproject.toml y Makefile
2. **Tests primero** - TDD te ahorra tiempo a largo plazo
3. **Commits pequeños** - Un commit por feature, mensajes claros
4. **README actualizado** - Actualízalo mientras avanzas, no al final
5. **Copia patrones** - Usa el código de BankChurn/CarVision como referencia

---

## 💼 <a id="207-consejos-profesionales"></a> Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **Cuenta una historia**: Tu portafolio debe mostrar progresión y aprendizaje.

2. **Explica decisiones**: "¿Por qué elegiste X?" es la pregunta más común.

3. **Muestra métricas**: Impacto cuantificable impresiona más que features.

### Para tu Portafolio

| Elemento | Por qué Importa |
|----------|-----------------|
| README profesional | Primera impresión, 30 segundos para captar atención |
| Demo en vivo | Muestra que funciona, no solo que existe |
| Código limpio | Los revisores leen tu código |
| Documentación | Demuestra comunicación técnica |

### Checklist Final del Portafolio

- [ ] Cada proyecto tiene problema claro y solución
- [ ] Métricas de performance documentadas
- [ ] CI/CD funcionando con badges
- [ ] Docker para reproducibilidad
- [ ] README con GIFs o screenshots
- [ ] Deployed y accesible (demo link)


---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **End-to-End ML Project** | Krish Naik | 2h | [YouTube](https://www.youtube.com/watch?v=S_F_c9e2bz4) |
| 🟡 | **MLOps Best Practices** | Google Cloud | 45 min | [YouTube](https://www.youtube.com/watch?v=4W_NfOeQKEU) |

### 📚 Cursos Integrales

| 🏷️ | Título | Plataforma | Cubre | Link |
|:--:|:-------|:-----------|:------|:-----|
| 🔴 | **MLOps Zoomcamp** | DataTalksClub | Todo el stack | [GitHub](https://github.com/DataTalksClub/mlops-zoomcamp) |
| 🔴 | **Made With ML** | MadeWithML | ML + MLOps | [MadeWithML](https://madewithml.com/) |
| 🟡 | **Full Stack Deep Learning** | FSDL | Producción ML | [FSDL](https://fullstackdeeplearning.com/) |

---

## 🔧 Ejercicios del Módulo

### Ejercicio 23.1: Script E2E Completo
**Objetivo**: Crear script que ejecute pipeline completo.
**Dificultad**: ⭐⭐⭐

```python
# scripts/run_e2e.py
# TU TAREA: Script que ejecute todo el pipeline

def run_e2e_pipeline():
    """Ejecuta pipeline completo de ML."""
    # 1. Verificar datos existen
    # 2. Entrenar modelo
    # 3. Verificar artefactos
    # 4. Levantar API
    # 5. Test de integración
    # 6. Cleanup
    pass
```

<details>
<summary>💡 Ver solución</summary>

```python
#!/usr/bin/env python3
"""Script E2E para validar pipeline completo."""

import subprocess
import sys
import time
from pathlib import Path

import requests


def run_e2e_pipeline() -> bool:
    """Ejecuta pipeline completo de ML."""
    print("🚀 Iniciando pipeline E2E...")
    
    # 1. Verificar datos
    data_path = Path("data/raw/dataset.csv")
    if not data_path.exists():
        print(f"❌ Dataset no encontrado: {data_path}")
        return False
    print("✅ Dataset encontrado")
    
    # 2. Entrenar modelo
    print("🔄 Entrenando modelo...")
    result = subprocess.run(
        ["python", "-m", "bankchurn.training"],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        print(f"❌ Error en training: {result.stderr}")
        return False
    print("✅ Modelo entrenado")
    
    # 3. Verificar artefactos
    model_path = Path("artifacts/model.joblib")
    if not model_path.exists():
        print(f"❌ Modelo no encontrado: {model_path}")
        return False
    print("✅ Artefactos generados")
    
    # 4. Levantar API
    print("🔄 Iniciando API...")
    api_process = subprocess.Popen(
        ["uvicorn", "app.fastapi_app:app", "--port", "8000"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    time.sleep(5)  # Esperar startup
    
    try:
        # 5. Test de integración
        print("🔄 Ejecutando tests de integración...")
        
        # Health check
        response = requests.get("http://localhost:8000/health")
        assert response.status_code == 200
        print("✅ Health check OK")
        
        # Prediction
        test_data = {"feature1": 1.0, "feature2": 0.5}
        response = requests.post(
            "http://localhost:8000/predict",
            json=test_data
        )
        assert response.status_code == 200
        assert "prediction" in response.json()
        print("✅ Prediction endpoint OK")
        
        print("🎉 Pipeline E2E completado exitosamente!")
        return True
        
    finally:
        # 6. Cleanup
        api_process.terminate()
        api_process.wait()
        print("✅ Cleanup completado")


if __name__ == "__main__":
    success = run_e2e_pipeline()
    sys.exit(0 if success else 1)
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **E2E Pipeline** | Flujo completo desde datos raw hasta predicción en producción |
| **Integration Test** | Tests que verifican múltiples componentes trabajando juntos |
| **Smoke Test** | Test rápido que verifica funcionalidad básica está operativa |
| **Self-assessment** | Autoevaluación usando rúbrica de criterios |

---

## 🏁 Entrega Final
 
1. Repositorio público en GitHub
2. CI pasando (verde)
3. README con badges actualizados
4. Self-assessment del checklist completado

---

<a id="2011-monorepo"></a>

## 23.11 🔬 Ingeniería Inversa Pedagógica: Arquitectura Monorepo

> **Objetivo**: Entender cómo escalar de 1 proyecto a 3 proyectos compartiendo código.

### 23.11.1 🎯 El "Por Qué" Arquitectónico

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    EVOLUCIÓN DEL PORTAFOLIO: 1 → 3 PROYECTOS                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│  PROBLEMA 1: ¿Cómo comparto código entre BankChurn, CarVision y TelecomAI?      │
│  DECISIÓN: common_utils/ como librería interna instalable                       │
│  RESULTADO: DRY a nivel de portafolio, logger y seeds consistentes              │
│                                                                                 │
│  PROBLEMA 2: ¿Cómo mantengo CI/CD para 3 proyectos sin duplicar workflows?      │
│  DECISIÓN: Matriz de GitHub Actions con strategy.matrix.project                 │
│  RESULTADO: Un workflow, 3 proyectos testeados en paralelo                      │
│                                                                                 │
│  PROBLEMA 3: ¿Cómo evito que cambios en un proyecto rompan otros?               │
│  DECISIÓN: Cada proyecto tiene su propio pyproject.toml y tests aislados        │
│  RESULTADO: Independencia con código compartido opcional                        │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 23.11.2 🔍 Anatomía del Monorepo

**Estructura**: `ML-MLOps-Portfolio/`

```
ML-MLOps-Portfolio/
│
├── common_utils/                    # ← LIBRERÍA COMPARTIDA
│   ├── __init__.py                  # Exports: setup_logging, set_seed
│   ├── logger.py                    # Logging consistente para todos
│   └── seed.py                      # Reproducibilidad centralizada
│
├── BankChurn-Predictor/             # ← PROYECTO 1 (independiente)
│   ├── src/bankchurn/
│   │   └── training.py              # from common_utils import setup_logging
│   ├── tests/
│   ├── pyproject.toml               # Dependencias propias
│   └── Dockerfile
│
├── CarVision-Market-Intelligence/   # ← PROYECTO 2 (independiente)
│   ├── src/carvision/
│   │   └── training.py              # from common_utils import set_seed
│   ├── tests/
│   └── pyproject.toml
│
├── TelecomAI-Customer-Intelligence/ # ← PROYECTO 3 (independiente)
│   ├── src/telecom/
│   └── ...
│
├── .github/workflows/
│   └── ci-mlops.yml                 # ← UN workflow para los 3 proyectos
│
├── infra/                           # Docker Compose, Prometheus, etc.
└── Makefile                         # Comandos raíz delegando a sub-proyectos
```

### 23.11.3 📦 common_utils: Código Compartido

```python
# common_utils/__init__.py
"""
API pública de utilidades compartidas.

Todas las funciones aquí son usadas por BankChurn, CarVision y TelecomAI
para garantizar consistencia en logging y reproducibilidad.
"""

from common_utils.logger import setup_logging    # Logging consistente.
from common_utils.seed import set_seed           # Seeds para reproducibilidad.

__version__ = "1.0.0"                            # Versión de la librería.
__all__ = ["setup_logging", "set_seed"]          # Exports explícitos.
```

```python
# common_utils/seed.py
"""Reproducibilidad centralizada para todos los proyectos."""

import os                                        # Variables de entorno.
import random                                    # Random de Python.
import numpy as np                               # NumPy random.

DEFAULT_SEED = 42                                # Valor por defecto.


def set_seed(seed: int = DEFAULT_SEED) -> int:
    """
    Configura seeds globales para reproducibilidad.
    
    Esta función setea el seed para Python, NumPy, y opcionalmente
    PyTorch/TensorFlow si están instalados.
    """
    os.environ["PYTHONHASHSEED"] = str(seed)     # Hash determinístico.
    random.seed(seed)                            # Random de Python.
    np.random.seed(seed)                         # NumPy.
    
    # PyTorch (opcional, si está instalado).
    try:
        import torch
        torch.manual_seed(seed)                  # CPU.
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(seed)     # GPU.
    except ImportError:
        pass  # PyTorch no instalado.
    
    return seed
```

### 23.11.4 🔄 CI/CD con Matriz de Proyectos

```yaml
# .github/workflows/ci-mlops.yml
name: CI/CD MLOps Portfolio

on:
  push:
    branches: [main, develop]

jobs:
  tests:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false                           # No cancelar otros si uno falla.
      matrix:
        python-version: ['3.11', '3.12']         # Probar múltiples versiones.
        project:                                 # ← LOS 3 PROYECTOS
          - BankChurn-Predictor
          - CarVision-Market-Intelligence
          - TelecomAI-Customer-Intelligence
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install dependencies
        working-directory: ${{ matrix.project }} # ← Cambia a cada proyecto.
        run: pip install -e ".[dev]"
      
      - name: Run tests
        working-directory: ${{ matrix.project }}
        run: pytest --cov --cov-fail-under=80
```

### 23.11.5 🧪 Laboratorio de Replicación

```bash
# Paso 1: Crear estructura monorepo desde cero
mkdir mi-portfolio-ml && cd mi-portfolio-ml

# Paso 2: Crear common_utils
mkdir -p common_utils
cat > common_utils/__init__.py << 'EOF'
from common_utils.logger import setup_logging
from common_utils.seed import set_seed
__all__ = ["setup_logging", "set_seed"]
EOF

# Paso 3: Crear primer proyecto usando common_utils
mkdir -p proyecto1/src/proyecto1
cat > proyecto1/src/proyecto1/training.py << 'EOF'
import sys
sys.path.insert(0, "../..")  # Para desarrollo local.
from common_utils import setup_logging, set_seed

logger = setup_logging(__name__)
set_seed(42)

def train():
    logger.info("Training con seed reproducible")
EOF

# Paso 4: Verificar que funciona
cd proyecto1 && python -c "from src.proyecto1.training import train; train()"
```

### 23.11.6 🚨 Troubleshooting Monorepo

| Síntoma | Causa | Solución |
|---------|-------|----------|
| **"ModuleNotFoundError: common_utils"** | PYTHONPATH no incluye raíz | `pip install -e ../common_utils` o `sys.path.insert` |
| **CI falla solo en un proyecto** | Dependencias diferentes | Verificar `pyproject.toml` de ese proyecto |
| **Cambio en common_utils rompe proyecto** | Sin tests de integración | Añadir tests que importen desde common_utils |

---

## 🏆 CHECKPOINT FINAL: Guía Completa

> 🎯 **¡Felicidades! Has completado los módulos 01-23**
>
> Ahora tienes el conocimiento de un Senior/Staff MLOps Engineer:
> - ✅ Python profesional con type hints y Pydantic
> - ✅ Pipelines ML reproducibles con sklearn y DVC
> - ✅ Testing completo con 80%+ coverage
> - ✅ CI/CD profesional con GitHub Actions
> - ✅ Docker, APIs y dashboards de producción
> - ✅ Observabilidad con drift detection
> - ✅ Infraestructura como código
> - ✅ 3 proyectos production-ready en tu portafolio

---

### 📋 Examen Final de Integración

> **Formato**: Self-Correction System Design  
> **Duración**: 90-120 minutos  
> **Puntaje mínimo**: 70/100

#### Ejercicio: Diseña un Sistema ML

**Escenario**: Una empresa de e-commerce quiere predecir qué productos comprarán los usuarios. Tienes:
- 10M usuarios activos
- 1M productos
- 100M interacciones/mes
- Latencia requerida: <100ms
- Budget: Moderado (no FAANG)

**Tu tarea**: Diseña la arquitectura completa.

<details>
<summary>📝 Ver Solución</summary>

**Arquitectura Propuesta:**

```
┌─────────────────────────────────────────────────────────────┐
│                     DATA LAYER                               │
├─────────────────────────────────────────────────────────────┤
│  S3 (raw) → Spark (ETL) → Feature Store (Redis) → DVC      │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    TRAINING LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  MLflow Tracking → Kubernetes Jobs → Model Registry         │
│  - Batch training diario                                    │
│  - A/B testing de modelos                                   │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    SERVING LAYER                             │
├─────────────────────────────────────────────────────────────┤
│  Load Balancer → FastAPI (K8s HPA) → Redis Cache            │
│  - 3 replicas mínimo                                        │
│  - Auto-scale hasta 10                                      │
│  - Cache de predicciones frecuentes                         │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                  MONITORING LAYER                            │
├─────────────────────────────────────────────────────────────┤
│  Prometheus → Grafana → Alerting → Evidently (drift)        │
│  - Latency p99 < 100ms                                      │
│  - Error rate < 0.1%                                        │
│  - Drift check diario                                       │
└─────────────────────────────────────────────────────────────┘
```

**Decisiones clave:**
- **Feature Store (Redis)**: Pre-computa features para latencia <100ms
- **K8s HPA**: Auto-scaling para 10M usuarios
- **Cache**: Productos populares tienen predicciones cacheadas
- **Batch + Real-time**: Training batch, serving real-time
</details>

---

### 🎤 Simulacro de Entrevista: Nivel Senior/Staff

> **115+ preguntas** divididas en 2 partes
> **Tiempo**: 90 min cada parte
> **Objetivo**: Preparación para posiciones Senior/Staff ML Engineer

#### Parte 1: Técnico Avanzado (50+ preguntas)

**System Design (15 preguntas)**
1. ¿Cómo diseñarías un sistema de recomendaciones para 100M usuarios?
2. ¿Trade-offs entre batch y real-time serving?
3. ¿Cómo manejarías cold start en recomendaciones?

**Arquitectura ML (15 preguntas)**
4. ¿Cuándo usarías feature store vs computar on-the-fly?
5. ¿Cómo implementarías A/B testing para modelos?
6. ¿Estrategia de rollback si un modelo degrada?

**Infraestructura (10 preguntas)**
7. ¿Cómo optimizarías costos en un pipeline ML en AWS?
8. ¿Cuándo usar Spot vs On-Demand para training?
9. ¿Cómo escalarías a múltiples regiones?

<details>
<summary>💡 Ver Respuestas de Muestra</summary>

**1. Sistema de recomendaciones 100M usuarios:**
> Arquitectura en capas: (1) Candidate generation con ANN (approximate nearest neighbors), (2) Ranking con modelo más complejo, (3) Re-ranking con reglas de negocio. Feature store para latencia. Sharding por user_id. Cache para usuarios frecuentes.

**5. A/B testing de modelos:**
> Traffic splitting a nivel de load balancer. Métricas: latency, prediction distribution, business metrics (CTR, conversión). Duración mínima para significance estadística. Rollback automático si degradación >X%.

**7. Optimizar costos AWS:**
> (1) Spot instances para training (70% ahorro), (2) Right-sizing de instancias, (3) S3 lifecycle policies, (4) Reserved capacity para serving baseline, (5) Auto-scaling agresivo en off-peak.
</details>

---

#### Parte 2: Liderazgo y Trade-offs (65 preguntas)

**Liderazgo Técnico (20 preguntas)**
1. ¿Cómo priorizas deuda técnica vs nuevas features?
2. ¿Cómo convences a stakeholders de invertir en MLOps?
3. ¿Cómo mentorizas a juniors en ML?

**Trade-offs (20 preguntas)**
4. ¿Cuándo sacrificarías accuracy por latency?
5. ¿Build vs buy para herramientas MLOps?
6. ¿Monolito vs microservicios para ML?

**Casos Prácticos (25 preguntas)**
7. Tu modelo tiene bias racial. ¿Qué haces?
8. El CEO quiere ML en todo. ¿Cómo priorizas?
9. Producción falla a las 3am. ¿Tu proceso?

<details>
<summary>💡 Ver Respuestas de Muestra</summary>

**2. Convencer stakeholders de MLOps:**
> Mostrar métricas de impacto: "Sin CI/CD, bugs llegan a producción 3x más. Con testing, reducimos incidentes 60%." Hablar en términos de negocio: tiempo de desarrollo, confiabilidad, velocidad de iteración.

**5. Build vs buy:**
> Build si: core competency, requirements muy específicos, control total necesario. Buy si: commodity, time-to-market crítico, equipo pequeño. MLflow: open source gratuito. Datadog: costoso pero ahorra tiempo.

**7. Bias en modelo:**
> (1) No silenciar, escalar inmediatamente. (2) Cuantificar: ¿qué grupos afectados? (3) Rollback si impacto significativo. (4) Root cause: datos históricos, features proxy. (5) Mitigación: resampling, fairness constraints, auditoría continua.
</details>

---

[Ver simulacro completo Parte 1 →](simulacros/SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md)
[Ver simulacro completo Parte 2 →](simulacros/SIMULACRO_ENTREVISTA_SENIOR_PARTE2.md)

---

### 🎯 Preparación de Entrevistas

#### Speech de Portafolio (5-7 minutos)

**Estructura recomendada:**

```
1. INTRO (30 seg)
   "He construido un portafolio de 3 proyectos ML production-ready..."

2. PROYECTO DESTACADO (2-3 min)
   - Problema de negocio
   - Decisiones técnicas clave
   - Métricas de impacto

3. STACK TÉCNICO (1-2 min)
   - Por qué sklearn pipelines
   - Por qué FastAPI + Docker
   - Observabilidad con Prometheus

4. DIFERENCIADORES (1 min)
   - 80%+ coverage en todos los proyectos
   - CI/CD completo
   - Documentación profesional

5. CIERRE (30 seg)
   "Estoy buscando oportunidades donde pueda..."
```

#### Talking Points Clave

| Pregunta Común | Respuesta Concisa |
|----------------|-------------------|
| "¿Por qué sklearn?" | "Pipelines serializables, reproducibilidad, integración con MLflow" |
| "¿Por qué FastAPI?" | "Async, validación Pydantic, docs automáticas, rendimiento" |
| "¿Cómo garantizas calidad?" | "80%+ coverage, pre-commit hooks, CI gates" |
| "¿Tu mayor desafío?" | "Prevenir data leakage en pipelines complejos" |

---

[Ver Speech completo →](entrevistas/APENDICE_A_SPEECH_PORTAFOLIO.md)
[Ver Talking Points →](entrevistas/APENDICE_B_TALKING_POINTS.md)

---

## ✅ Checklist Final del Portafolio

- [ ] `pip install -e .` funciona en un entorno limpio
- [ ] `make test` pasa con coverage objetivo
- [ ] `make train` produce artefactos reproducibles
- [ ] API expone `/health` y `/predict`
- [ ] CI está en verde con badges en README
- [ ] 3 proyectos con diferentes problemas ML
- [ ] Model Cards y documentación completa
- [ ] Demo accesible (local o deployed)

---

<div align="center">

## 🎉 ¡Felicidades!

Has completado la **Guía MLOps — Portfolio Edition**

Ahora tienes las habilidades de un **Senior/Staff MLOps Engineer**

---

**[← IaC Empresarial](22_IAC_EMPRESARIAL.md)** | **[Volver al Índice →](00_INDICE.md)**

</div>

**¡Éxito en tu proyecto! 🚀**

[← Documentación](19_DOCUMENTACION.md) | [Siguiente: Glosario →](21_GLOSARIO.md)

</div>
