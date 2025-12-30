# 03. Estructura de Proyecto ML Profesional

## 🎯 Objetivo del Módulo

Crear la estructura de proyecto que usarás en los 3 proyectos del portafolio.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  Una buena estructura de proyecto es como los cimientos de una casa:         ║
║  invisible cuando está bien hecha, DESASTROSA cuando está mal.               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

<a id="00-prerrequisitos"></a>

## 0.0 Prerrequisitos

- Haber completado **[01_PYTHON_MODERNO](01_PYTHON_MODERNO.md)** (type hints + `src/` layout).
- Tener claro qué proyecto del portafolio vas a usar como base (BankChurn, CarVision, TelecomAI).
- Poder ejecutar comandos básicos (instalar deps, correr tests).

---

<a id="01-protocolo-e-como-estudiar-este-modulo"></a>

## 0.1 🧠 Protocolo E: Cómo estudiar este módulo

- **Antes de tocar el repo**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define tu *output mínimo* (ej: “estructura + `pyproject.toml` + Makefile + tests corriendo”).
- **Mientras implementas**: si te atoras >15 min (imports, `pip install -e`, targets del Makefile), registra el bloqueo en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
- **Al cerrar la semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para decidir qué mejorar (DX, reproducibilidad, CI).

---

<a id="02-entregables-verificables-minimo-viable"></a>

## 0.2 ✅ Entregables verificables (mínimo viable)

Al terminar este módulo, deberías poder mostrar (en al menos 1 proyecto del portafolio):

- [ ] **Árbol de proyecto** consistente con `src/`, `tests/`, `configs/`, `data/` (gitignored) y `artifacts/` (gitignored).
- [ ] **Instalación editable** funcionando: `pip install -e ".[dev]"`.
- [ ] **Tests ejecutables** desde la raíz: `pytest`.
- [ ] **Makefile** con al menos: `install`, `test`, `lint` (y opcional `train`, `serve`).

---

<a id="03-puente-teoria-codigo-portafolio"></a>

## 0.3 🧩 Puente teoría ↔ código (Portafolio)

Para que esto cuente como progreso real, fuerza este mapeo:

- **Concepto**: estructura del repo / packaging / DX
- **Archivo**: `pyproject.toml`, `Makefile`, `.gitignore`, `src/<paquete>/`, `tests/`
- **Prueba**: `pip install -e ".[dev]"` + `pytest` + `ruff check` + `mypy src/`
- **Evidencia**: un repo que corre igual en tu máquina y en CI.

---

## 📋 Contenido

- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
- [La Estructura del Portafolio](#estructura-portafolio)
- [Cómo se aplica en este portafolio](#como-se-aplica)
- [pyproject.toml completo](#pyproject)
- [Makefile](#makefile)
- [.gitignore](#gitignore)
- [🔬 Ingeniería Inversa: Estructura Real](#36-ingenieria-inversa-estructura)
- [Errores habituales y cómo depurarlos](#errores-habituales)
- [📓 Refactoring: De Notebook a Producción](#37-refactoring) ⭐ INTEGRADO
- [📦 Librerías Compartidas (common_utils)](#38-common-utils) ⭐ INTEGRADO
- [🎓 Sección Pedagógica: Aprende Haciendo](#39-pedagogia) ⭐ NUEVO
- [Consejos Profesionales](#consejos-profesionales)
- [Recursos Externos Recomendados](#recursos-externos)
- [Referencias del Glosario](#referencias-glosario)
- [Plantillas Relacionadas](#plantillas-relacionadas)
- [Ejercicios](#ejercicios)

---

<a id="estructura-portafolio"></a>

## 📋 La Estructura del Portafolio

```
MiProyecto-ML/
│
├── src/                          # 📦 CÓDIGO FUENTE (instalable)
│   ├── __init__.py
│   └── miproyecto/
│       ├── __init__.py
│       ├── config.py             # Configuración Pydantic
│       ├── data.py               # Carga y validación de datos
│       ├── features.py           # Feature engineering
│       ├── training.py           # Pipeline de entrenamiento
│       ├── evaluation.py         # Métricas y evaluación
│       ├── prediction.py         # Inferencia
│       └── models.py             # Custom models/transformers
│
├── app/                          # 🌐 APLICACIONES
│   ├── fastapi_app.py            # API REST
│   └── streamlit_app.py          # Dashboard (opcional)
│
├── tests/                        # 🧪 TESTS (espejo de src/)
│   ├── __init__.py
│   ├── conftest.py               # Fixtures compartidas
│   ├── test_config.py
│   ├── test_data.py
│   ├── test_features.py
│   ├── test_training.py
│   └── test_api.py
│
├── configs/                      # ⚙️ CONFIGURACIÓN
│   └── config.yaml               # Hiperparámetros, paths, etc.
│
├── data/                         # 📊 DATOS (gitignored)
│   ├── raw/                      # Datos originales
│   └── processed/                # Datos procesados (opcional)
│
├── artifacts/                    # 📁 ARTEFACTOS (gitignored)
│   ├── model.joblib              # Modelo entrenado
│   └── metrics.json              # Métricas de entrenamiento
│
├── scripts/                      # 🔧 SCRIPTS AUXILIARES
│   └── run_mlflow.py             # Script de MLflow
│
├── docs/                         # 📖 DOCUMENTACIÓN
│   ├── model_card.md
│   └── data_card.md
│
├── infra/                        # 🏗️ INFRAESTRUCTURA (opcional)
│   └── terraform/
│
├── pyproject.toml                # 📋 METADATA DEL PROYECTO
├── requirements.txt              # 📋 DEPENDENCIAS (para CI)
├── Makefile                      # 🔨 COMANDOS COMUNES
├── Dockerfile                    # 🐳 CONTAINERIZACIÓN
├── .github/workflows/            # 🔄 CI/CD
│   └── ci.yml
├── .gitignore                    # 🚫 ARCHIVOS IGNORADOS
├── .pre-commit-config.yaml       # 🔍 HOOKS PRE-COMMIT
└── README.md                     # 📖 DOCUMENTACIÓN PRINCIPAL
```

### 🧠 Mapa Mental de Conceptos: Estructura de Proyecto

```
                        ╔═════════════════════════════════════════════╗
                        ║   ESTRUCTURA PROFESIONAL DE PROYECTO ML     ║
                        ╚═════════════════════════════════════════════╝
                                            │
        ┌───────────────────────────────────┼───────────────────────────────────┐
        ▼                                   ▼                                   ▼
┌───────────────────┐             ┌───────────────────┐             ┌───────────────────┐
│  📦 CÓDIGO        │             │  ⚙️ CONFIG       │             │  🔧 HERRAMIENTAS  │
└───────────────────┘             └───────────────────┘             └───────────────────┘
       │                                 │                                 │
├─ src/<paquete>/             ├─ pyproject.toml               ├─ Makefile
├─ app/                       ├─ configs/*.yaml               ├─ Dockerfile
├─ tests/                     ├─ .pre-commit                  ├─ .github/workflows/
└─ scripts/                   └─ .gitignore                   └─ README.md
                                         │
                                         ▼
                              ┌───────────────────┐
                              │  📊 DATOS         │
                              │  (gitignored)     │
                              └───────────────────┘
                                     │
                              ├─ data/raw/
                              ├─ data/processed/
                              ├─ artifacts/
                              └─ mlruns/
```

**Términos clave que debes dominar:**

| Directorio | Propósito | Gitignored? |
|------------|-----------|-------------|
| **src/** | Código fuente instalable | No |
| **tests/** | Tests (espejo de src) | No |
| **app/** | APIs y dashboards | No |
| **configs/** | Configuración YAML | No |
| **data/** | Datos raw/procesados | ✅ Sí |
| **artifacts/** | Modelos entrenados | ✅ Sí |
| **mlruns/** | Experimentos MLflow | ✅ Sí |

---

### 💻 Ejercicio Puente: Crear Estructura Mínima

> **Meta**: Antes de estructurar un proyecto ML completo, practica con una estructura mínima.

**Ejercicio 1: Estructura desde cero**
```bash
# TU TAREA: Crea esta estructura mínima para un proyecto "myproject"
# 
# myproject/
# ├── src/
# │   └── myproject/
# │       ├── __init__.py
# │       └── main.py
# ├── tests/
# │   └── test_main.py
# ├── pyproject.toml
# └── README.md
#
# PISTA: Usa mkdir -p y touch
```

**Ejercicio 2: Verificar instalación**
```bash
# Después de crear la estructura y pyproject.toml mínimo
cd myproject
pip install -e .
python -c "from myproject import main; print('✅ Funciona!')"
```

<details>
<summary>🔍 Ver Solución</summary>

```bash
# Crear estructura
mkdir -p myproject/src/myproject myproject/tests
touch myproject/src/myproject/__init__.py
touch myproject/src/myproject/main.py
touch myproject/tests/test_main.py
touch myproject/README.md

# Crear pyproject.toml mínimo
cat > myproject/pyproject.toml << 'EOF'
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "myproject"
version = "0.1.0"
requires-python = ">=3.10"

[tool.setuptools.packages.find]
where = ["src"]
EOF

# Verificar
cd myproject
pip install -e .
python -c "from myproject import main; print('✅ Funciona!')"
```
</details>

---

### 🛠️ Práctica del Portafolio: Verificar Estructura de BankChurn

> **Tarea**: Verificar que BankChurn-Predictor sigue la estructura profesional.

**Paso 1: Explora la estructura real**
```bash
cd BankChurn-Predictor
tree -L 2 --dirsfirst
# O sin tree: find . -maxdepth 2 -type d | head -20
```

**Paso 2: Checklist de verificación**
```
[ ] ¿Existe src/bankchurn/__init__.py?
[ ] ¿Existe tests/conftest.py?
[ ] ¿Existe pyproject.toml con [tool.setuptools.packages.find] where=["src"]?
[ ] ¿Existe Makefile con targets: install, test, lint?
[ ] ¿.gitignore excluye data/, artifacts/, mlruns/?
```

**Paso 3: Ejecuta los comandos del Makefile**
```bash
make install      # Debe funcionar sin errores
make test         # Debe ejecutar pytest
make lint         # Debe ejecutar ruff/mypy
```

**Paso 4: Si algo falla, documenta**
```
¿Qué falló? ___________________
¿Por qué? ___________________
¿Cómo lo arreglaste? ___________________
```

---

### ✅ Checkpoint de Conocimiento: Estructura de Proyecto

**Pregunta 1**: ¿Por qué ponemos el código en `src/` en vez de en la raíz?

A) Es más rápido  
B) Fuerza que el código esté INSTALADO para importarlo (evita bugs de imports)  
C) GitHub lo requiere  
D) Ocupa menos espacio  

**Pregunta 2**: ¿Por qué `data/` y `artifacts/` deben estar en .gitignore?

A) Son archivos temporales  
B) Son archivos binarios grandes que no deben versionarse en Git  
C) Git no soporta esos formatos  
D) Hace el repo más rápido  

**Pregunta 3**: ¿Cuál es el propósito del archivo `__init__.py`?

A) Almacenar configuración  
B) Marcar un directorio como paquete Python importable  
C) Ejecutar tests  
D) Documentar el proyecto  

**�� Escenario de Debugging:**

```
Situación: Ejecutas pytest en CI y obtienes:
  ModuleNotFoundError: No module named 'bankchurn'

Pero en tu máquina local funciona perfectamente.

El workflow de CI tiene:
  - run: pip install -r requirements.txt
  - run: pytest
```

**¿Cuál es el problema y cómo lo solucionarías?**

<details>
<summary>🔍 Ver Respuestas</summary>

**Pregunta 1**: B) Fuerza que el código esté INSTALADO para importarlo. Esto evita el problema "funciona en mi máquina".

**Pregunta 2**: B) Son archivos binarios grandes. Git no está diseñado para archivos grandes; usa DVC o storage externo.

**Pregunta 3**: B) Marcar un directorio como paquete Python importable.

**Escenario de Debugging**: 
- **Problema**: El CI solo instala dependencias, pero NO instala tu paquete.
- **Solución**: Cambiar el workflow:
```yaml
- run: pip install -e ".[dev]"  # Instala TU paquete + deps
- run: pytest
```
</details>

---

<a id="como-se-aplica"></a>

## 🧩 Cómo se aplica en este portafolio

Esta estructura no es teórica: los **3 proyectos** del portafolio la siguen con ligeras
variaciones. Esto conecta directamente con los macro-módulos **00** y **01** de la
**Ruta 0 → Senior/Staff** descrita en el [SYLLABUS](SYLLABUS.md).

| Proyecto | Carpeta raíz | Paquete principal | Archivos clave |
|----------|--------------|-------------------|----------------|
| BankChurn Predictor | `BankChurn-Predictor/` | `src/bankchurn/` | `pyproject.toml`, `main.py`, `Makefile`, `tests/` |
| CarVision Market Intelligence | `CarVision-Market-Intelligence/` | `src/carvision/` | `pyproject.toml`, `main.py`, `Makefile`, `tests/` |
| TelecomAI Customer Intelligence | `TelecomAI-Customer-Intelligence/` | `src/telecom/` | `pyproject.toml`, `main.py`, `Makefile`, `tests/` |

Para aprovechar este módulo al máximo en el repositorio real:

- **Compara** el árbol genérico de `MiProyecto-ML/` con, por ejemplo,
  `BankChurn-Predictor/` (fíjate especialmente en `src/`, `configs/`, `tests/`,
  `Makefile` y `pyproject.toml`).
- **Verifica** que los comandos que defines aquí (`make install`, `make test`,
  `make train`, `make serve`) tienen su equivalente funcional en los Makefiles de
  cada proyecto.
- **Usa** esta plantilla como referencia si creas un **cuarto proyecto** durante el
  [23_PROYECTO_INTEGRADOR](23_PROYECTO_INTEGRADOR.md).

---

<a id="pyproject"></a>

## 📄 pyproject.toml Completo

```toml
# pyproject.toml - El corazón del proyecto

[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "bankchurn"
version = "1.0.0"
description = "Bank Customer Churn Prediction System"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}
authors = [
    {name = "Tu Nombre", email = "tu@email.com"}
]
keywords = ["machine-learning", "churn", "prediction"]

dependencies = [
    "pandas>=2.0.0",
    "numpy>=1.24.0",
    "scikit-learn>=1.3.0",
    "pydantic>=2.0.0",
    "pyyaml>=6.0",
    "joblib>=1.3.0",
]

[project.optional-dependencies]
api = [
    "fastapi>=0.104.0",
    "uvicorn>=0.24.0",
]
mlflow = [
    "mlflow>=2.9.0",
]
dev = [
    "pytest>=7.4.0",
    "pytest-cov>=4.1.0",
    "black>=23.0.0",
    "ruff>=0.1.0",
    "mypy>=1.7.0",
    "pre-commit>=3.5.0",
]
all = [
    "bankchurn[api,mlflow,dev]",
]

[project.scripts]
bankchurn = "bankchurn.cli:main"

[tool.setuptools.packages.find]
where = ["src"]

# ═══════════════════════════════════════════════════════════════════════════
# HERRAMIENTAS
# ═══════════════════════════════════════════════════════════════════════════

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = "-v --cov=src/bankchurn --cov-report=term-missing"

[tool.coverage.run]
source = ["src"]
omit = ["tests/*"]

[tool.coverage.report]
fail_under = 79

[tool.black]
line-length = 100
target-version = ["py311"]

[tool.ruff]
line-length = 100
select = ["E", "F", "I", "W"]
ignore = ["E501"]

[tool.mypy]
python_version = "3.11"
ignore_missing_imports = true
```

---

<a id="makefile"></a>

## 🔨 Makefile

```makefile
# Makefile - Comandos comunes del proyecto

.PHONY: install test lint format train serve clean  # .PHONY: declara targets que no son archivos.

# Instalación
install:                              # Target por defecto para desarrollo.
	pip install -e ".[all]"           # -e: editable (cambios se reflejan sin reinstalar). [all]: incluye todas las deps.

install-prod:                         # Target para producción (sin deps de desarrollo).
	pip install -e ".[api]"           # Solo instala deps de API, no dev/mlflow.

# Testing
test:                                 # Ejecuta tests con coverage.
	pytest --cov=src/ --cov-fail-under=80  # Falla si coverage < 80%.

test-fast:                            # Tests rápidos para desarrollo.
	pytest -m "not slow" -x           # -m "not slow": excluye tests lentos. -x: falla al primer error.

# Linting y formato
lint:                                 # Verifica calidad de código.
	ruff check src/ tests/            # Ruff: linter rápido.
	mypy src/                         # mypy: verificación de tipos.

format:                               # Auto-formatea código.
	black src/ tests/ app/            # Black: formatter estándar de Python.
	ruff check --fix src/ tests/      # --fix: auto-corrige problemas que puede.

# Entrenamiento
train:                                # Entrena el modelo.
	python main.py --seed 42 train --config configs/config.yaml --input data/raw/Churn.csv

serve:                                # Inicia servidor de desarrollo.
	uvicorn app.fastapi_app:app --host 0.0.0.0 --port 8000 --reload  # --reload: reinicia con cambios.

serve-prod:                           # Servidor de producción (sin reload).
	uvicorn app.fastapi_app:app --host 0.0.0.0 --port 8000

# Docker
docker-build:                         # Construye imagen Docker.
	docker build -t bankchurn:latest .  # -t: tag. .: contexto actual.

docker-run:                           # Ejecuta contenedor.
	docker run -p 8000:8000 bankchurn:latest  # -p host:container: mapea puertos.

# MLflow
mlflow-ui:                            # Inicia UI de MLflow para ver experimentos.
	mlflow ui --host 0.0.0.0 --port 5000

# Limpieza
clean:                                # Elimina archivos generados.
	rm -rf __pycache__ .pytest_cache .mypy_cache .ruff_cache  # Caches de Python/herramientas.
	rm -rf *.egg-info build dist      # Archivos de build.
	rm -rf htmlcov .coverage          # Archivos de coverage.
```

---

<a id="gitignore"></a>

## 🚫 .gitignore

```gitignore
# Python
__pycache__/
*.py[cod]
*.pyo
.pytest_cache/
.mypy_cache/
*.egg-info/
dist/
build/

# Entornos
.venv/
venv/
env/

# Datos y artefactos (muy grandes para Git)
data/
artifacts/
models/
*.joblib
*.pkl
*.h5

# MLflow
mlruns/

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Coverage
.coverage
htmlcov/

# Env vars
.env
.env.local
```

---

<a id="36-ingenieria-inversa-estructura"></a>

## 3.6 🔬 Ingeniería Inversa Pedagógica: Estructura Real del Portafolio

> **Objetivo**: Entender CADA decisión detrás de la estructura `src/` del portafolio.

### 3.6.1 🎯 El "Por Qué" Arquitectónico

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DECISIONES ARQUITECTÓNICAS DEL PORTAFOLIO                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│  PROBLEMA 1: ¿Cómo organizo código importable desde cualquier lugar?            │
│  RIESGO: Sin src/, los imports dependen del directorio actual                   │
│  DECISIÓN: src/<paquete>/ con __init__.py que exporta clases públicas           │
│  RESULTADO: `from bankchurn import ChurnTrainer` funciona siempre               │
│                                                                                 │
│  PROBLEMA 2: ¿Cómo separo responsabilidades sin crear 50 archivos?              │
│  DECISIÓN: Un archivo por dominio: training, prediction, evaluation, config     │
│  RESULTADO: 8 archivos manejables con responsabilidad clara                     │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 3.6.2 🔍 Anatomía de `__init__.py`

**Archivo**: `ML-MLOps-Portfolio/BankChurn-Predictor/src/bankchurn/__init__.py`

```python
"""Core BankChurn prediction modules."""
from __future__ import annotations

from .evaluation import ModelEvaluator
from .prediction import ChurnPredictor
from .training import ChurnTrainer

__all__ = ["ChurnPredictor", "ChurnTrainer", "ModelEvaluator"]
# __all__ documenta la API pública y controla "import *"
```

### 3.6.3 🚨 Troubleshooting Preventivo

| Síntoma | Causa | Solución |
|---------|-------|----------|
| **ModuleNotFoundError en tests** | pythonpath no configurado | `pythonpath = ["src"]` en pyproject.toml |
| **Import local OK, CI falla** | pip install -e . faltante | Añadir al workflow de CI |

---

<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en la estructura de proyecto

Aquí los problemas ya no son algoritmos, sino **cómo está organizado el repo**. Son los típicos errores que hacen que algo “funcione en mi máquina pero no en CI” o que el repo se vuelva inmanejable.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) `ModuleNotFoundError` y tests que solo funcionan desde ciertos directorios

**Síntomas típicos**

- En local, ejecutar `pytest` desde la raíz funciona, pero en CI falla con:
  ```text
  ModuleNotFoundError: No module named 'miproyecto'
  ```
- Tienes que hacer trucos como `cd src` o modificar `PYTHONPATH` para que los imports funcionen.

**Cómo identificarlo**

- Revisa tu estructura real:
  - ¿El código está en `src/miproyecto/` o repartido por la raíz?
  - ¿Los tests importan el paquete (`from miproyecto import ...`) o archivos sueltos (`import training`)?
- Mira tu `pyproject.toml`:
  - `[project.name]` → ¿coincide con el nombre del paquete (`miproyecto`, `bankchurn`, etc.)?
  - `[tool.setuptools.packages.find] where = ["src"]` → ¿está configurado?

**Cómo corregirlo**

- Mueve el código a `src/<nombre_paquete>/` siguiendo el árbol de este módulo.
- Asegúrate de que los tests importan siempre el paquete, no rutas relativas.
- Instala en modo editable durante desarrollo/CI:
  ```bash
  pip install -e ".[dev]"
  ```

---

### 2) Datos y modelos dentro de Git (repos gigantes e impracticables)

**Síntomas típicos**

- El repo pesa cientos de MB porque hay CSVs y modelos `.pkl`/`.joblib` versionados.
- `git pull` y `git clone` son lentos, y los PRs están llenos de cambios binarios.

**Cómo identificarlo**

- Ejecuta `git status` y revisa si aparecen archivos en `data/`, `artifacts/`, `models/`.
- Abre tu `.gitignore` y comprueba si tienes entradas como:
  - `data/`, `artifacts/`, `models/`, `*.joblib`, `*.pkl`, `mlruns/`.

**Cómo corregirlo**

- Añade las rutas correctas a `.gitignore` (usa el snippet de este módulo como base).
- Mantén en Git **solo**:
  - Código (`src/`, `app/`, `tests/`).
  - Config (`configs/`).
  - Infra y docs.
- Para datos/modelos usa DVC o un storage externo (se profundiza en `06_VERSIONADO_DATOS.md`).

---

### 3) Tests que no reflejan el árbol de `src/`

**Síntomas típicos**

- Cambias algo en `src/miproyecto/features.py` y ningún test falla, aunque has roto lógica.
- Hay tests sueltos sin relación clara con los módulos de producción.

**Cómo identificarlo**

- Compara árboles:
  - En `src/miproyecto/`: `config.py`, `data.py`, `features.py`, `training.py`, `evaluation.py`, `prediction.py`.
  - En `tests/`: ¿existen `test_config.py`, `test_data.py`, `test_features.py`, etc.?
- Revisa el `pyproject.toml` o `pytest.ini` para ver qué carpeta se usa como `testpaths`.

**Cómo corregirlo**

- Crea un **espejo sencillo**: por cada módulo importante en `src/`, un test correspondiente en `tests/`.
- Usa `conftest.py` para compartir fixtures (datasets pequeños, config de prueba, etc.).
- Integra `pytest --cov=src/` en tu CI para detectar huecos de cobertura.

---

### 4) Makefile y comandos que no se pueden ejecutar

**Síntomas típicos**

- El README dice `make train`, pero:
  - El target `train` no existe.
  - O llama a rutas que no existen (`data/raw/archivo_que_no_existe.csv`).

**Cómo identificarlo**

- Desde la raíz del proyecto, ejecuta:
  ```bash
  make help  # si tienes target de ayuda
  make train
  ```
- Observa los comandos reales que se ejecutan y compáralos con:
  - La estructura de carpetas (`data/raw`, `configs/config.yaml`).
  - El CLI real (como `src/bankchurn/cli.py` en BankChurn).

**Cómo corregirlo**

- Ajusta el `Makefile` para que:
  - Use rutas reales (`data/raw/Churn.csv`, etc.).
  - Delegue en el CLI real (`python main.py ...` o `python -m miproyecto.cli ...`).
- Mantén el `Makefile` como **fachada del developer experience**: pocos comandos (`install`, `test`, `train`, `serve`) pero sólidos.

---

### 5) Patrón general de debugging de estructura

1. **Revisa el árbol de directorios** contra la plantilla de este módulo.
2. **Comprueba imports** corriendo un `python -c` que importe tu paquete.
3. **Ejecuta los comandos principales** (`make install`, `make test`, `make train`, `make serve`).
4. **Asegura que datos/artefactos no están en Git** y que `.gitignore` los protege.

Este checklist de estructura es lo primero que un revisor Senior mira cuando abre un repo ML: si esto está bien, todo lo demás es mucho más fácil de mantener.

---

<a id="consejos-profesionales"></a>

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **Explica tu estructura**: Los entrevistadores valoran que puedas justificar cada carpeta y archivo de tu proyecto.

2. **Cookiecutter es tu amigo**: Menciona que usas plantillas estandarizadas para consistencia entre proyectos.

3. **Conoce la diferencia `src/` vs flat**: Explica por qué `src/` layout previene imports accidentales del código local.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Proyecto nuevo | Usa cookiecutter-data-science o similar como base |
| Equipo grande | Documenta convenciones en CONTRIBUTING.md |
| Monorepo vs Multirepo | Monorepo para proyectos relacionados, multirepo para independientes |
| Configs | Nunca hardcodees: usa archivos YAML + variables de entorno |

### Checklist de Proyecto Profesional

- [ ] README.md con badges, instalación, y uso rápido
- [ ] pyproject.toml con metadata completa
- [ ] Makefile con comandos estándar (install, test, lint)
- [ ] .pre-commit-config.yaml para calidad automática
- [ ] tests/ con estructura que refleja src/


---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **Python Project Structure** | ArjanCodes | 22 min | [YouTube](https://www.youtube.com/watch?v=e8IIYRMnxcE) |
| 🟡 | **Packaging Python Projects** | mCoding | 18 min | [YouTube](https://www.youtube.com/watch?v=v6tALyc4C10) |
| 🟢 | **Cookiecutter Data Science** | PyData | 35 min | [YouTube](https://www.youtube.com/watch?v=nExL0SgKsDY) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [src Layout vs Flat](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/) | Guía oficial de layouts |
| 🟡 | [pyproject.toml Spec](https://packaging.python.org/en/latest/specifications/pyproject-toml/) | Especificación oficial |

---

## ⚖️ Decisión Técnica: ADR-014 src/ Layout

**Contexto**: Necesitamos una estructura de proyecto profesional y mantenible.

**Decisión**: Usar `src/` layout en todos los proyectos.

**Alternativas Consideradas**:
- **Flat layout**: Más simple pero riesgo de imports accidentales
- **Namespace packages**: Más complejo, necesario solo para paquetes distribuidos

**Consecuencias**:
- ✅ Evita imports del código local no instalado
- ✅ Tests siempre importan el paquete instalado
- ✅ Estándar profesional reconocido
- ❌ Un nivel de directorio adicional

---

## 🔧 Ejercicios del Módulo

### Ejercicio 3.1: Crear Estructura de Proyecto
**Objetivo**: Crear estructura profesional desde cero.
**Dificultad**: ⭐⭐

```bash
# TU TAREA: Crear estructura completa para proyecto "mymlproject"
# Debe incluir: src/, tests/, configs/, data/, artifacts/, docs/
```

<details>
<summary>💡 Ver solución</summary>

```bash
# Crear estructura
mkdir -p mymlproject/{src/mymlproject,app,tests,configs,data/{raw,processed},artifacts,scripts,docs}

# Crear archivos Python
touch mymlproject/src/mymlproject/__init__.py
touch mymlproject/src/mymlproject/{config.py,data.py,training.py,prediction.py}
touch mymlproject/app/__init__.py
touch mymlproject/app/fastapi_app.py
touch mymlproject/tests/__init__.py
touch mymlproject/tests/conftest.py

# Crear archivos de proyecto
touch mymlproject/{README.md,pyproject.toml,Makefile,.gitignore}
touch mymlproject/.pre-commit-config.yaml

# Estructura resultante:
# mymlproject/
# ├── src/mymlproject/
# │   ├── __init__.py
# │   ├── config.py
# │   ├── data.py
# │   ├── training.py
# │   └── prediction.py
# ├── app/fastapi_app.py
# ├── tests/conftest.py
# ├── configs/
# ├── data/{raw,processed}/
# ├── artifacts/
# ├── scripts/
# ├── docs/
# ├── pyproject.toml
# ├── Makefile
# └── README.md
```
</details>

---

### Ejercicio 3.2: pyproject.toml Completo
**Objetivo**: Configurar pyproject.toml profesional.
**Dificultad**: ⭐⭐

```toml
# TU TAREA: Completar pyproject.toml para mymlproject
[build-system]
# ???

[project]
name = "mymlproject"
# ???

[project.optional-dependencies]
# ???
```

<details>
<summary>💡 Ver solución</summary>

```toml
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "mymlproject"
version = "0.1.0"
description = "ML project with professional structure"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}
authors = [{name = "Tu Nombre", email = "tu@email.com"}]

dependencies = [
    "pandas>=2.0",
    "scikit-learn>=1.3",
    "pydantic>=2.0",
    "pyyaml>=6.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-cov>=4.0",
    "ruff>=0.1",
    "pre-commit>=3.0",
]
api = [
    "fastapi>=0.100",
    "uvicorn>=0.23",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.ruff]
line-length = 100
select = ["E", "F", "I", "UP"]

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --cov=mymlproject"
```
</details>

---

<a id="37-refactoring"></a>

## 3.7 📓 Refactoring: De Notebook a Código de Producción

> **Objetivo**: Dominar la transición de código exploratorio en notebooks a módulos Python profesionales, mantenibles y testeables.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  "El notebook es donde nacen las ideas.                                      ║
║   El módulo Python es donde esas ideas se convierten en producto."           ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### 3.7.1 ¿Por qué Refactorizar Notebooks?

#### Problemas del Código en Notebooks

| Problema | Impacto | Solución |
|----------|---------|----------|
| **Estado global** | Celdas dependen de orden de ejecución | Funciones puras |
| **No testeable** | Bugs ocultos hasta producción | Módulos + pytest |
| **No versionable** | Diffs ilegibles en Git | .py separados |
| **No reutilizable** | Copy-paste entre proyectos | Paquetes Python |
| **Sin tipos** | Errores en runtime | Type hints |

#### Cuándo Refactorizar

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CICLO DE VIDA DEL CÓDIGO ML                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📓 NOTEBOOK (Exploración)                                                  │
│  ├── EDA rápida                                                             │
│  ├── Pruebas de hipótesis                                                   │
│  ├── Iteración de features                                                  │
│  └── Prototipos de modelos                                                  │
│       │                                                                     │
│       ▼ ¿El código será usado más de una vez?                               │
│       │                                                                     │
│  📦 MÓDULO (Producción)                                                    │
│  ├── Funciones reutilizables                                                │
│  ├── Clases con estado manejado                                             │
│  ├── Configuración externalizada                                            │
│  └── Tests automatizados                                                    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.7.2 Anatomía: Notebook vs Módulo

#### Ejemplo: Celda Típica de Notebook

```python
# ❌ Código típico de notebook (difícil de mantener)

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# Cargar datos
df = pd.read_csv("data/churn.csv")

# Preprocesar (hardcoded)
df = df.dropna()
df['TenureGroup'] = pd.cut(df['tenure'], bins=[0, 12, 24, 48, 72], labels=['0-1yr', '1-2yr', '2-4yr', '4-6yr'])

# Features y target (hardcoded)
X = df[['CreditScore', 'Age', 'Balance', 'NumOfProducts']]
y = df['Exited']

# Split (seed hardcoded)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Entrenar (sin logging)
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Evaluar (print en lugar de return)
print(f"Accuracy: {model.score(X_test, y_test)}")
```

#### Equivalente en Módulo Profesional

```python
# ✅ src/bankchurn/training.py (código de producción)
"""Módulo de entrenamiento para BankChurn."""

from pathlib import Path                             # Manejo de paths cross-platform.
from typing import Tuple, Dict, Any                  # Type hints.
import logging                                       # Logging estructurado.

import pandas as pd                                  # DataFrames.
import numpy as np                                   # Operaciones numéricas.
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, f1_score

from bankchurn.config import TrainingConfig          # Configuración externalizada.


logger = logging.getLogger(__name__)                 # Logger del módulo.


def load_data(path: Path) -> pd.DataFrame:
    """
    Carga datos desde archivo CSV.
    
    Args:
        path: Path al archivo CSV.
    
    Returns:
        DataFrame con los datos cargados.
    
    Raises:
        FileNotFoundError: Si el archivo no existe.
        pd.errors.EmptyDataError: Si el archivo está vacío.
    """
    logger.info(f"Loading data from {path}")
    
    if not path.exists():
        raise FileNotFoundError(f"Data file not found: {path}")
    
    df = pd.read_csv(path)
    logger.info(f"Loaded {len(df)} rows, {len(df.columns)} columns")
    
    return df


def preprocess(
    df: pd.DataFrame,
    config: TrainingConfig,
) -> pd.DataFrame:
    """
    Preprocesa datos según configuración.
    
    Args:
        df: DataFrame con datos crudos.
        config: Configuración de preprocesamiento.
    
    Returns:
        DataFrame preprocesado.
    """
    logger.info("Preprocessing data")
    
    # Eliminar NaN según estrategia en config.
    if config.drop_na:
        initial_rows = len(df)
        df = df.dropna()
        logger.info(f"Dropped {initial_rows - len(df)} rows with NaN")
    
    # Feature engineering configurable.
    if config.create_tenure_groups:
        df = df.copy()                               # Evitar SettingWithCopyWarning.
        df['TenureGroup'] = pd.cut(
            df['tenure'],
            bins=config.tenure_bins,
            labels=config.tenure_labels,
        )
    
    return df


def split_data(
    df: pd.DataFrame,
    config: TrainingConfig,
) -> Tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series]:
    """
    Divide datos en train/test.
    
    Args:
        df: DataFrame preprocesado.
        config: Configuración con features, target y split ratio.
    
    Returns:
        Tuple de (X_train, X_test, y_train, y_test).
    """
    X = df[config.feature_columns]
    y = df[config.target_column]
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y,
        test_size=config.test_size,
        random_state=config.seed,
        stratify=y if config.stratify else None,     # Estratificación opcional.
    )
    
    logger.info(f"Train: {len(X_train)}, Test: {len(X_test)}")
    
    return X_train, X_test, y_train, y_test


def train_model(
    X_train: pd.DataFrame,
    y_train: pd.Series,
    config: TrainingConfig,
) -> RandomForestClassifier:
    """
    Entrena modelo con configuración especificada.
    
    Args:
        X_train: Features de entrenamiento.
        y_train: Target de entrenamiento.
        config: Configuración de hiperparámetros.
    
    Returns:
        Modelo entrenado.
    """
    logger.info(f"Training RandomForest with {config.n_estimators} estimators")
    
    model = RandomForestClassifier(
        n_estimators=config.n_estimators,
        max_depth=config.max_depth,
        random_state=config.seed,
        n_jobs=-1,                                   # Usar todos los cores.
    )
    
    model.fit(X_train, y_train)
    logger.info("Training completed")
    
    return model


def evaluate_model(
    model: RandomForestClassifier,
    X_test: pd.DataFrame,
    y_test: pd.Series,
) -> Dict[str, float]:
    """
    Evalúa modelo y retorna métricas.
    
    Args:
        model: Modelo entrenado.
        X_test: Features de test.
        y_test: Target de test.
    
    Returns:
        Dict con métricas de evaluación.
    """
    y_pred = model.predict(X_test)
    
    metrics = {
        "accuracy": accuracy_score(y_test, y_pred),
        "f1_score": f1_score(y_test, y_pred),
    }
    
    logger.info(f"Evaluation metrics: {metrics}")
    
    return metrics


def run_training_pipeline(config: TrainingConfig) -> Dict[str, Any]:
    """
    Ejecuta pipeline completo de entrenamiento.
    
    Esta es la función principal que orquesta todo el proceso.
    
    Args:
        config: Configuración completa del entrenamiento.
    
    Returns:
        Dict con modelo y métricas.
    """
    # 1. Cargar datos.
    df = load_data(config.data_path)
    
    # 2. Preprocesar.
    df = preprocess(df, config)
    
    # 3. Split.
    X_train, X_test, y_train, y_test = split_data(df, config)
    
    # 4. Entrenar.
    model = train_model(X_train, y_train, config)
    
    # 5. Evaluar.
    metrics = evaluate_model(model, X_test, y_test)
    
    return {
        "model": model,
        "metrics": metrics,
        "config": config,
    }
```

### 3.7.3 Proceso de Refactoring Paso a Paso

#### Checklist de Refactoring

```python
# refactoring_checklist.py
"""Checklist automatizado para refactoring de notebooks."""

from dataclasses import dataclass
from typing import List


@dataclass
class RefactoringStep:
    """Paso de refactoring."""
    name: str
    description: str
    completed: bool = False


def get_refactoring_checklist() -> List[RefactoringStep]:
    """Retorna checklist de refactoring."""
    return [
        RefactoringStep(
            "identify_functions",
            "Identificar bloques de código que hacen UNA cosa"
        ),
        RefactoringStep(
            "extract_config",
            "Extraer valores hardcoded a configuración"
        ),
        RefactoringStep(
            "add_type_hints",
            "Añadir type hints a todas las funciones"
        ),
        RefactoringStep(
            "add_docstrings",
            "Documentar cada función con docstring"
        ),
        RefactoringStep(
            "add_logging",
            "Reemplazar print() con logging"
        ),
        RefactoringStep(
            "add_error_handling",
            "Añadir manejo de errores apropiado"
        ),
        RefactoringStep(
            "remove_global_state",
            "Eliminar variables globales"
        ),
        RefactoringStep(
            "create_tests",
            "Crear tests unitarios para cada función"
        ),
    ]
```

#### Mapeo: Celdas de Notebook → Módulos

```
┌─────────────────────────────────────────────────────────────────────────────┐
│              MAPEO: CELDAS DE NOTEBOOK → MÓDULOS                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Celda de imports           →  (se distribuyen en cada módulo)              │
│  Celda de carga de datos    →  data.py::load_data()                         │
│  Celda de limpieza          →  data.py::clean_data()                        │
│  Celda de feature eng.      →  features.py::create_features()               │
│  Celda de split             →  training.py::split_data()                    │
│  Celda de entrenamiento     →  training.py::train_model()                   │
│  Celda de evaluación        →  evaluation.py::evaluate_model()              │
│  Celda de predicción        →  prediction.py::predict()                     │
│  Celda de visualización     →  (queda en notebook o dashboards)             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.7.4 Patrones Comunes de Extracción

#### Configuración Externalizada

```python
# src/bankchurn/config.py
"""Configuración centralizada del proyecto."""

from pathlib import Path
from typing import List, Optional
from pydantic import BaseModel, Field              # Validación automática.
import yaml                                        # Lectura de archivos YAML.


class TrainingConfig(BaseModel):
    """Configuración de entrenamiento."""
    
    # Paths.
    data_path: Path = Field(..., description="Path al archivo de datos")
    model_output_path: Path = Field(default=Path("artifacts/model.joblib"))
    
    # Preprocesamiento.
    drop_na: bool = Field(default=True)
    create_tenure_groups: bool = Field(default=True)
    tenure_bins: List[int] = Field(default=[0, 12, 24, 48, 72])
    tenure_labels: List[str] = Field(default=['0-1yr', '1-2yr', '2-4yr', '4-6yr'])
    
    # Features.
    feature_columns: List[str] = Field(
        default=['CreditScore', 'Age', 'Balance', 'NumOfProducts']
    )
    target_column: str = Field(default='Exited')
    
    # Split.
    test_size: float = Field(default=0.2, ge=0.0, le=1.0)
    stratify: bool = Field(default=True)
    
    # Modelo.
    n_estimators: int = Field(default=100, ge=1)
    max_depth: Optional[int] = Field(default=None)
    
    # Reproducibilidad.
    seed: int = Field(default=42)
    
    class Config:
        extra = "forbid"  # Error si hay campos desconocidos.


def load_config(path: Path) -> TrainingConfig:
    """Carga configuración desde YAML."""
    with open(path) as f:
        data = yaml.safe_load(f)
    return TrainingConfig(**data)
```

```yaml
# configs/config.yaml
# Configuración de entrenamiento.

data_path: "data/raw/Churn.csv"
model_output_path: "artifacts/model.joblib"

# Preprocesamiento.
drop_na: true
create_tenure_groups: true

# Features.
feature_columns:
  - CreditScore
  - Age
  - Balance
  - NumOfProducts
  - IsActiveMember

target_column: Exited

# Split.
test_size: 0.2
stratify: true

# Modelo.
n_estimators: 200
max_depth: 10

# Reproducibilidad.
seed: 42
```

#### De Print a Logging

```python
# ❌ Antes (notebook)
print(f"Loaded {len(df)} rows")
print(f"Training with {n_estimators} trees")
print(f"Accuracy: {accuracy}")

# ✅ Después (módulo)
import logging

logger = logging.getLogger(__name__)

logger.info(f"Loaded {len(df)} rows")
logger.info(f"Training with {n_estimators} trees")
logger.info(f"Accuracy: {accuracy:.4f}")

# Configuración de logging (en __init__.py o main.py)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("training.log"),
    ]
)
```

#### De Variables Globales a Parámetros

```python
# ❌ Antes (variables globales)
SEED = 42
N_ESTIMATORS = 100
df = None  # Estado global mutable

def train():
    global df  # Dependencia oculta
    model = RandomForestClassifier(n_estimators=N_ESTIMATORS, random_state=SEED)
    model.fit(df[features], df[target])
    return model

# ✅ Después (parámetros explícitos)
def train(
    X: pd.DataFrame,
    y: pd.Series,
    n_estimators: int = 100,
    seed: int = 42,
) -> RandomForestClassifier:
    """Todas las dependencias son explícitas."""
    model = RandomForestClassifier(n_estimators=n_estimators, random_state=seed)
    model.fit(X, y)
    return model
```

---

<a id="38-common-utils"></a>

## 3.8 📦 Librerías Compartidas (common_utils)

> **Objetivo**: Aprender a crear y mantener librerías de utilidades compartidas entre proyectos ML, siguiendo el patrón `common_utils/` del Portfolio.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  "DRY (Don't Repeat Yourself) no es solo para código dentro de un proyecto:  ║
║   aplica a toda tu organización. common_utils es DRY a nivel de equipo."     ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### 3.8.1 ¿Por qué Librerías Compartidas?

#### Problemas que Resuelve

| Problema | Sin common_utils | Con common_utils |
|----------|------------------|------------------|
| **Logging** | Cada proyecto configura diferente | Formato consistente |
| **Seeds** | Olvidar setear todas las librerías | Una función para todo |
| **Config** | Duplicación de código | Validación centralizada |
| **Utils** | Copy-paste entre repos | Import compartido |

#### Análisis del Portfolio

```
ML-MLOps-Portfolio/
├── common_utils/              # ← Librería compartida
│   ├── __init__.py
│   ├── logger.py              # Logging consistente
│   └── seed.py                # Reproducibilidad
│
├── BankChurn-Predictor/
│   └── src/bankchurn/
│       └── training.py        # from common_utils import ...
│
├── CarVision-Market-Intelligence/
│   └── src/carvision/
│       └── training.py        # from common_utils import ...
│
└── TelecomAI-Customer-Intelligence/
    └── src/telecom/
        └── training.py        # from common_utils import ...
```

### 3.8.2 Estructura de common_utils

#### Organización Recomendada

```
common_utils/
├── __init__.py           # Exports públicos
├── logger.py             # Configuración de logging
├── seed.py               # Reproducibilidad
├── config.py             # Utilidades de configuración (opcional)
├── metrics.py            # Métricas compartidas (opcional)
├── validators.py         # Validadores comunes (opcional)
└── tests/
    ├── __init__.py
    ├── test_logger.py
    └── test_seed.py
```

#### __init__.py: API Pública

```python
# common_utils/__init__.py
"""
Utilidades compartidas para proyectos ML.

Este módulo proporciona funcionalidades comunes que se usan
en múltiples proyectos del portfolio:
- Configuración de logging consistente.
- Reproducibilidad con seeds.
"""

from common_utils.logger import setup_logging
from common_utils.seed import set_seed, DEFAULT_SEED

__version__ = "1.0.0"

__all__ = [
    "setup_logging",
    "set_seed",
    "DEFAULT_SEED",
]
```

### 3.8.3 Módulo de Logging

```python
# common_utils/logger.py
"""
Configuración centralizada de logging para todos los proyectos.

Este módulo proporciona una función para configurar logging de manera
consistente, evitando que cada proyecto implemente su propia versión.
"""

import logging                                       # Librería estándar de logging.
import sys                                           # Para stdout.
from typing import Optional                          # Type hints.


def setup_logging(
    name: str,                                       # Nombre del logger (usualmente __name__).
    level: int = logging.INFO,                       # Nivel mínimo de logging.
    log_format: Optional[str] = None,                # Formato personalizado (opcional).
) -> logging.Logger:
    """
    Configura logging consistente para todos los proyectos.
    
    Esta función centraliza la configuración de logging para evitar
    duplicación y garantizar formato consistente en logs.
    
    Args:
        name: Nombre del logger. Usar __name__ del módulo que llama.
        level: Nivel de logging (DEBUG, INFO, WARNING, ERROR, CRITICAL).
        log_format: Formato personalizado. Si None, usa formato estándar.
    
    Returns:
        Logger configurado y listo para usar.
    
    Example:
        >>> from common_utils import setup_logging
        >>> logger = setup_logging(__name__)
        >>> logger.info("Training started")
        2024-01-15 10:30:00 - mymodule - INFO - Training started
    """
    # Formato por defecto: timestamp - módulo - nivel - mensaje.
    if log_format is None:
        log_format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    
    # Crear handler para stdout.
    handler = logging.StreamHandler(sys.stdout)      # Output a stdout (no stderr).
    formatter = logging.Formatter(log_format)        # Aplicar formato.
    handler.setFormatter(formatter)
    
    # Obtener o crear logger.
    logger = logging.getLogger(name)
    logger.setLevel(level)
    
    # Prevenir handlers duplicados si se llama múltiples veces.
    # Esto es importante en notebooks donde se puede re-ejecutar celdas.
    if not logger.handlers:
        logger.addHandler(handler)
    
    return logger
```

### 3.8.4 Módulo de Reproducibilidad (Seed)

```python
# common_utils/seed.py
"""
Helper centralizado para reproducibilidad en experimentos ML.

Este módulo configura seeds para todas las librerías relevantes
(Python, NumPy, PyTorch, TensorFlow) en una sola llamada.
"""

from __future__ import annotations                   # Para type hints modernos.

import os                                            # Variables de entorno.
import random                                        # Random de Python.
from typing import Final                             # Constantes tipadas.

import numpy as np                                   # NumPy.


# Seed por defecto si no se especifica.
DEFAULT_SEED: Final[int] = 42


def set_seed(seed: int | None = None) -> int:
    """
    Configura seeds globales para reproducibilidad.
    
    Esta función setea el seed para:
    - Python's random module
    - NumPy
    - PyTorch (si está instalado)
    - TensorFlow (si está instalado)
    
    Orden de resolución del seed:
    1. Argumento `seed` si se proporciona.
    2. Variable de entorno `SEED` si está definida.
    3. DEFAULT_SEED (42) como fallback.
    
    Args:
        seed: Seed a usar. Si None, se resuelve según orden descrito.
    
    Returns:
        El seed que fue efectivamente usado.
    
    Example:
        >>> from common_utils import set_seed
        >>> set_seed(42)
        42
        >>> # Ahora todos los experimentos serán reproducibles
    
    Note:
        Para reproducibilidad completa en GPU, también necesitas:
        - torch.backends.cudnn.deterministic = True
        - torch.backends.cudnn.benchmark = False
        Esto se hace automáticamente en esta función.
    """
    # Resolver seed según orden de prioridad.
    if seed is None:
        env_seed = os.getenv("SEED")                 # Buscar en variable de entorno.
        seed = int(env_seed) if env_seed is not None else DEFAULT_SEED
    
    # ========== Core Python / NumPy ==========
    os.environ["PYTHONHASHSEED"] = str(seed)         # Hash determinístico.
    random.seed(seed)                                # Random de Python.
    np.random.seed(seed)                             # NumPy.
    
    # ========== PyTorch (opcional) ==========
    try:
        import torch
        
        torch.manual_seed(seed)                      # CPU seed.
        
        if torch.cuda.is_available():
            torch.cuda.manual_seed_all(seed)         # GPU seed (todas las GPUs).
        
        # Hacer operaciones CUDA determinísticas.
        if hasattr(torch.backends, "cudnn"):
            torch.backends.cudnn.deterministic = True
            torch.backends.cudnn.benchmark = False   # Desactivar autotuning.
    
    except ImportError:
        pass  # PyTorch no instalado, skip.
    except Exception:
        pass  # Otros errores (ej: CUDA no disponible).
    
    # ========== TensorFlow (opcional) ==========
    try:
        import tensorflow as tf
        
        tf.random.set_seed(seed)
    
    except ImportError:
        pass  # TensorFlow no instalado, skip.
    except Exception:
        pass
    
    return seed
```

### 3.8.5 Patrones de Uso

#### Importación desde Proyecto

```python
# Opción 1: Import directo (si common_utils está en PYTHONPATH)
from common_utils import setup_logging, set_seed

# Opción 2: Import relativo (si es submódulo)
from ..common_utils import setup_logging, set_seed

# Opción 3: Añadir al path en runtime
import sys
sys.path.insert(0, "/path/to/ML-MLOps-Portfolio")
from common_utils import setup_logging, set_seed
```

#### Configuración en pyproject.toml

```toml
# pyproject.toml del proyecto que usa common_utils

[project]
name = "bankchurn"
dependencies = [
    # ... otras deps ...
]

[project.optional-dependencies]
dev = [
    # ... deps de desarrollo ...
]

# Si common_utils es un paquete local
[tool.setuptools.package-dir]
"" = "src"
"common_utils" = "../common_utils"
```

#### Patrón de Inicialización

```python
# src/bankchurn/__init__.py
"""
BankChurn Predictor.

Este módulo inicializa logging y seed al importar.
"""

from common_utils import setup_logging, set_seed

# Configurar logging al importar el paquete.
_logger = setup_logging("bankchurn")

# Exportar para uso en submódulos.
__all__ = ["setup_logging", "set_seed"]
```

### 3.8.6 Versionado y Distribución

#### Estructura para Publicación

```
common_utils/
├── pyproject.toml        # Metadata del paquete
├── README.md
├── LICENSE
├── src/
│   └── common_utils/
│       ├── __init__.py
│       ├── logger.py
│       └── seed.py
└── tests/
    └── ...
```

#### pyproject.toml para Distribución

```toml
# common_utils/pyproject.toml

[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "mlops-common-utils"
version = "1.0.0"
description = "Shared utilities for MLOps projects"
readme = "README.md"
requires-python = ">=3.10"
license = {text = "MIT"}

dependencies = [
    "numpy>=1.24.0",
]

[project.optional-dependencies]
torch = ["torch>=2.0.0"]
tensorflow = ["tensorflow>=2.13.0"]
all = ["mlops-common-utils[torch,tensorflow]"]

[tool.setuptools.packages.find]
where = ["src"]
```

#### Instalación en Proyectos

```bash
# Desde Git (privado)
pip install git+https://github.com/tu-org/common-utils.git

# Desde path local (desarrollo)
pip install -e /path/to/common_utils

# Desde PyPI (si publicas)
pip install mlops-common-utils
```

---

<a id="39-pedagogia"></a>

## 3.9 🎓 Sección Pedagógica: Aprende Haciendo

> **Formato**: Constructivismo aplicado a MLOps  
> **Nivel**: Python básico → Ingeniero MLOps Junior  
> **Tiempo estimado**: 2-3 horas

### 3.9.1 🎓 Explicación Teórica con Analogías

#### La Estructura de Proyecto como los Planos de una Casa

Imagina que vas a construir una casa. **No empiezas poniendo ladrillos al azar** — primero necesitas:

```
🏠 CONSTRUCCIÓN DE CASA          📦 PROYECTO ML
─────────────────────────────    ─────────────────────────────
Planos arquitectónicos     →     pyproject.toml (metadata)
Cimientos                  →     src/ layout (base del código)
Sistema eléctrico          →     configs/ (configuración)
Sistema de plomería        →     data/ pipelines (flujo de datos)
Cuartos separados          →     Módulos: training.py, prediction.py
Inspección de calidad      →     tests/ (verificación)
Manual de la casa          →     README.md, docs/
```

**¿Por qué importa en la industria?**

| Sin estructura profesional | Con estructura profesional |
|---------------------------|---------------------------|
| "Funciona en mi máquina" 🤷 | Funciona en cualquier máquina ✅ |
| Onboarding de 2 semanas | Onboarding de 2 días |
| Bugs difíciles de rastrear | Bugs localizados rápidamente |
| Imposible de escalar | Listo para equipo de 10+ personas |

> � **Insight de industria**: Los equipos de ML pierden ~40% del tiempo en "plumbing" (configuración, imports rotos, dependencias). Una buena estructura reduce esto a <10%.

### 3.9.2 🧠 Mapa Mental de Conceptos

Antes de tocar código, domina estos términos:

```
                    ┌─────────────────┐
                    │ ESTRUCTURA ML   │
                    │   PROFESIONAL   │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐         ┌─────▼─────┐        ┌─────▼─────┐
   │ CÓDIGO  │         │  CONFIG   │        │  CALIDAD  │
   │  FUENTE │         │   & DATA  │        │           │
   └────┬────┘         └─────┬─────┘        └─────┬─────┘
        │                    │                    │
   ┌────┴────┐         ┌─────┴─────┐        ┌─────┴─────┐
   │ src/    │         │ configs/  │        │ tests/    │
   │ layout  │         │ data/     │        │ Makefile  │
   │ __init__│         │ artifacts/│        │ pre-commit│
   └─────────┘         └───────────┘        └───────────┘
```

**Conceptos clave para memorizar:**

| Concepto | Definición de 1 línea |
|----------|----------------------|
| **src/ layout** | Código en `src/paquete/` para imports limpios |
| **pyproject.toml** | UN archivo para toda la config del proyecto |
| **editable install** | `pip install -e .` = cambios sin reinstalar |
| **Makefile** | Comandos comunes en un solo lugar |
| **.gitignore** | Archivos que Git debe ignorar (datos, modelos) |
| **conftest.py** | Fixtures compartidas para tests |

### 3.9.3 💻 Ejercicio Puente (Scaffolding)

> **Objetivo**: Practicar la estructura ANTES de replicar el portafolio completo.

#### Mini-Proyecto: Calculadora ML

Crea un proyecto mínimo con estructura profesional que haga una operación simple.

```bash
# PASO 1: Crear estructura
mkdir -p calculadora-ml/src/calculadora
mkdir -p calculadora-ml/tests
mkdir -p calculadora-ml/configs

# PASO 2: Crear archivos base
touch calculadora-ml/src/calculadora/__init__.py
touch calculadora-ml/src/calculadora/operations.py
touch calculadora-ml/tests/__init__.py
touch calculadora-ml/tests/test_operations.py
touch calculadora-ml/pyproject.toml
touch calculadora-ml/Makefile
```

**Tu tarea**: Completa estos archivos:

```python
# src/calculadora/operations.py
"""Operaciones matemáticas simples."""

def add(a: float, b: float) -> float:
    """Suma dos números."""
    # TODO: Implementar
    pass

def multiply(a: float, b: float) -> float:
    """Multiplica dos números."""
    # TODO: Implementar
    pass
```

```python
# tests/test_operations.py
"""Tests para operaciones."""
import pytest
from calculadora.operations import add, multiply

def test_add_positive_numbers():
    """Test suma de positivos."""
    # TODO: Implementar - debe pasar
    pass

def test_multiply_by_zero():
    """Test multiplicar por cero."""
    # TODO: Implementar - debe retornar 0
    pass
```

```toml
# pyproject.toml
[build-system]
requires = ["setuptools>=61.0"]
build-backend = "setuptools.build_meta"

[project]
name = "calculadora"
version = "0.1.0"
# TODO: Completar dependencies y tool configs
```

**Criterio de éxito**: 
```bash
pip install -e .
pytest  # Debe pasar
```

### 3.9.4 🛠️ Práctica del Portafolio (Instrucciones de Réplica)

> **Objetivo**: Replicar la estructura de `BankChurn-Predictor` desde cero.

#### Tarea: Crear estructura para tu proyecto

**NO copies el código** — créalo paso a paso siguiendo estas pistas:

##### Paso 1: Estructura de directorios

```bash
# Pista: Usa el árbol de la sección 3.1 como referencia
# Crea TODOS los directorios y archivos vacíos primero
mkdir -p mi-proyecto-ml/{src/miproyecto,tests,configs,data/raw,artifacts,docs}
```

##### Paso 2: pyproject.toml

```toml
# Pista: Responde estas preguntas para completarlo
# 1. ¿Cuál es el nombre de tu paquete?
# 2. ¿Qué librerías necesitas? (pandas, sklearn, pydantic...)
# 3. ¿Dónde está el código fuente? (src/)

[project]
name = "???"
version = "0.1.0"
dependencies = [
    # ??? - lista tus deps
]

[tool.setuptools.packages.find]
where = ["???"]
```

##### Paso 3: __init__.py con exports

```python
# src/miproyecto/__init__.py
# Pista: ¿Qué clases/funciones quieres que sean públicas?
# Mira el __init__.py de bankchurn como referencia

from .??? import ???
__all__ = ["???"]
```

##### Paso 4: Makefile mínimo

```makefile
# Pista: ¿Cuáles son los 4 comandos que más usarás?
# install, test, lint, ???

.PHONY: install test

install:
	# ??? - comando para instalar en modo editable

test:
	# ??? - comando para correr tests con coverage
```

##### Paso 5: Verificación

```bash
# Tu proyecto debe pasar estas verificaciones:
pip install -e ".[dev]"     # ¿Instala sin errores?
python -c "import miproyecto"  # ¿Importa correctamente?
pytest                       # ¿Tests pasan?
make test                    # ¿Makefile funciona?
```

### 3.9.5 ✅ Checkpoint de Conocimiento

#### Preguntas Teóricas (Opción Múltiple)

**1. ¿Por qué usamos `src/` layout en lugar de poner código en la raíz?**

- A) Es más rápido de ejecutar
- B) Evita que Python importe accidentalmente código local no instalado
- C) GitHub lo requiere
- D) Es solo preferencia estética

<details>
<summary>Ver respuesta</summary>

**Respuesta: B**

Con `src/` layout, Python SIEMPRE importa el paquete instalado, no el código local. Esto previene el clásico "funciona en mi máquina pero no en CI".

</details>

---

**2. ¿Cuál es el propósito de `pip install -e .`?**

- A) Instalar en modo "enterprise"
- B) Instalar una versión específica
- C) Instalar en modo editable (cambios se reflejan sin reinstalar)
- D) Instalar con dependencias extra

<details>
<summary>Ver respuesta</summary>

**Respuesta: C**

El flag `-e` (editable) crea un symlink al código fuente. Cuando modificas tu código, no necesitas reinstalar — los cambios se reflejan inmediatamente.

</details>

---

**3. ¿Qué archivos NUNCA deben estar en Git para un proyecto ML?**

- A) `pyproject.toml` y `Makefile`
- B) `README.md` y `docs/`
- C) `data/`, `artifacts/`, `*.joblib`, `mlruns/`
- D) `tests/` y `configs/`

<details>
<summary>Ver respuesta</summary>

**Respuesta: C**

Datos, modelos entrenados y artifacts de MLflow son demasiado grandes y cambian frecuentemente. Deben estar en `.gitignore` y manejarse con DVC o storage externo.

</details>

---

#### Escenario de Debugging

**Situación**: Tu colega te pide ayuda. Su proyecto tiene esta estructura:

```
mi-proyecto/
├── training.py
├── prediction.py
├── config.py
├── test_training.py
├── requirements.txt
└── data/churn.csv
```

Reporta estos problemas:
1. `pytest` falla con `ModuleNotFoundError: No module named 'training'`
2. El repo de Git pesa 500MB
3. En CI, los tests fallan aunque en local funcionan

**Tu diagnóstico**: ¿Cuáles son las 3 causas raíz y cómo las solucionarías?

<details>
<summary>Ver diagnóstico completo</summary>

**Causa 1**: No hay estructura `src/` ni `pyproject.toml`
- **Síntoma**: `ModuleNotFoundError`
- **Solución**: Mover código a `src/miproyecto/`, crear `pyproject.toml`, usar `pip install -e .`

**Causa 2**: `data/` no está en `.gitignore`
- **Síntoma**: Repo de 500MB
- **Solución**: Añadir `data/` a `.gitignore`, usar DVC para datos, `git rm --cached data/`

**Causa 3**: Sin instalación editable en CI
- **Síntoma**: Tests fallan solo en CI
- **Solución**: Añadir `pip install -e .` al workflow de CI antes de `pytest`

**Estructura corregida**:
```
mi-proyecto/
├── src/miproyecto/
│   ├── __init__.py
│   ├── training.py
│   ├── prediction.py
│   └── config.py
├── tests/
│   └── test_training.py
├── data/           # En .gitignore
├── pyproject.toml
├── Makefile
└── .gitignore
```

</details>

---

## �� Glosario del Módulo

| Término | Definición |
|---------|------------|
| **src/ Layout** | Estructura donde código está en `src/nombre_paquete/` |
| **pyproject.toml** | Archivo unificado de configuración de proyecto Python |
| **Makefile** | Archivo para automatizar comandos comunes del proyecto |
| **editable install** | `pip install -e .` instala paquete en modo desarrollo |
| **Refactoring** | Proceso de reestructurar código sin cambiar funcionalidad |
| **common_utils** | Librería interna compartida entre proyectos |
| **Scaffolding** | Ejercicio puente que prepara para tareas complejas |
| **Constructivismo** | Aprender haciendo, no solo leyendo |

---

<div align="center">

**Siguiente módulo** → [04. Entornos](04_ENTORNOS.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
