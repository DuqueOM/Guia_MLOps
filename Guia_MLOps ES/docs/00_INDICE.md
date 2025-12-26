# 📚 Guía MLOps — Portfolio Edition

> **De Python Básico a Senior/Staff en MLOps**
> 
> Ruta principal (recomendada): **24 semanas (6 meses)**.
> 
> Ruta acelerada: **8 semanas**.
>
> 🗺️ **Mapa 1:1 Portafolio → Guía**: [MAPA_PORTAFOLIO_1TO1.md](MAPA_PORTAFOLIO_1TO1.md)

---

## ⏱️ Rutas (24 semanas vs 8 semanas)

| Ruta | Dedicación sugerida | Para quién | Cómo seguirla |
|------|---------------------|------------|---------------|
| **24 semanas (principal)** | 8–10 h/sem | Si quieres profundidad, margen para debugging real y prácticas de infra/ops | Usa este índice (módulos 01–23) + el `README.md` del repo como roadmap 24 semanas. |
| **8 semanas (acelerada)** | 15–20 h/sem | Si ya tienes base fuerte o necesitas una versión rápida para demo/entrevista | Usa este índice + [PLAN_ESTUDIOS.md](PLAN_ESTUDIOS.md) como cronograma diario. |

## 🎯 ¿Qué Lograrás?

Al completar esta guía serás capaz de:

| Habilidad | Nivel | Evidencia en el Portafolio |
|-----------|-------|---------------------------|
| **Código Python profesional** | Senior | Type hints, Pydantic, SOLID en los 3 proyectos |
| **Pipelines ML reproducibles** | Senior | sklearn Pipeline unificado, sin data leakage |
| **Testing & CI/CD** | Senior | 80%+ coverage, GitHub Actions, matrix testing |
| **APIs de producción** | Senior | FastAPI con validación, Docker multi-stage |
| **Observabilidad** | Staff | Prometheus, logging estructurado, drift detection |
| **Pasar entrevistas técnicas** | Staff | Simulacros completos, speech de 5-7 min |

---

## 🧭 Cómo Usar Esta Guía

### Perfil de Entrada
- Python básico (funciones, clases, módulos)
- Git elemental (clone, commit, push)
- Comodidad con la terminal

### Método de Estudio

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         CICLO DE APRENDIZAJE                               │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│   1. LEER          2. REPLICAR         3. PRACTICAR      4. VALIDAR        │
│   ─────────        ──────────          ───────────       ──────────        │
│   El módulo        En uno de los       Ejercicios de     Comparar con      │
│   teórico          3 proyectos         EJERCICIOS.md     el portafolio     │
│                                                                            │
│   💡 Cada módulo tiene sección "📦 Cómo se usó en el Portafolio" que       │
│      referencia código real de BankChurn, CarVision o TelecomAI.           │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

### 🧠 Sistema de Estudio (Protocolo E)

- **[Study Tools](study_tools/index.md)**
- **[Protocolo E](study_tools/PROTOCOLO_E.md)**
- **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**
- **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)**
- **[Badges y Checkpoints](study_tools/BADGES_CHECKPOINTS.md)**
- **[Simulacros Performance-Based](study_tools/SIMULACRO_PERFORMANCE_BASED.md)**

### Rutas de Aprendizaje

| Si eres... | Ruta recomendada |
|------------|------------------|
| **Principiante** | Ruta principal **24 semanas** (recomendada). Si vas intensivo: ruta acelerada **8 semanas** |
| **DS con experiencia** | Ruta acelerada **8 semanas** (reforzando módulos 11–18 para “production mindset”) |
| **Preparando entrevista** | Ir directo a **MAPA 1:1** + módulos 20–23 + Simulacros |

---

## 📊 Roadmap Visual

### Ruta principal (24 semanas / 6 meses)

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║                         RUTA PRINCIPAL (24 SEMANAS / 6 MESES)                   ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║  MES 1 (Sem 1-4):   Fundamentos (01–05)                                          ║
║  MES 2 (Sem 5-8):   Datos + DVC + Pipelines (06–07)                              ║
║  MES 3 (Sem 9-12):  Features + Training + MLflow (08–10)                         ║
║  MES 4 (Sem 13-16): Testing + CI/CD (11–12)                                      ║
║  MES 5 (Sem 17-20): Docker + APIs + Dashboard + Observabilidad (13–16)           ║
║  MES 6 (Sem 21-24): Deploy + IaC + Docs + Integración (17–23)                    ║
╚══════════════════════════════════════════════════════════════════════════════════╝
```

### Ruta acelerada (8 semanas)

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║                             RUTA ACELERADA (8 SEMANAS)                           ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║                                                                                  ║
║  FASE 1: FUNDAMENTOS (Semanas 1-2)          FASE 2: ML ENGINEERING (Semanas 3-4) ║
║  ─────────────────────────────────          ──────────────────────────────────── ║
║  [01] Python Moderno ──────────────┐        [07] sklearn Pipelines ─────────┐    ║
║  [02] Diseño de Sistemas           │        [08] Feature Engineering        │    ║
║  [03] Estructura de Proyecto       ├──→     [09] Training Profesional  ─────┼──→ ║
║  [04] Entornos Reproducibles       │        [10] Experiment Tracking        │    ║
║  [05] Git Profesional              │                                        │    ║
║  [06] Versionado de Datos ─────────┘                                        │    ║
║                                                                             │    ║
║  FASE 3: MLOps CORE (Semanas 5-6)           FASE 4: PRODUCCIÓN (Semana 7)   │    ║
║  ────────────────────────────────           ──────────────────────────────  │    ║
║  [11] Testing para ML ◄────────────────────────────────────────────────────-┘    ║
║  [12] CI/CD con GitHub Actions                                                   ║
║  [13] Docker Avanzado                       [17] Estrategias de Despliegue       ║
║  [14] FastAPI para ML                       [18] Infraestructura como Código     ║
║  [15] Streamlit Dashboards                                                       ║
║  [16] Observabilidad                                                             ║
║                                                                                  ║
║  FASE 5: ESPECIALIZACIÓN (Semana 8)                                              ║
║  ──────────────────────────────────                                              ║
║  [19] Documentación (Model Cards)           ┌──────────────────────────────────┐ ║
║  [20] Proyecto Integrador ─────────────────→│  🎯 PORTAFOLIO COMPLETO          │ ║
║  [21] Glosario MLOps                        │     3 proyectos production-ready │ ║
║  [22] Checklist Profesional                 │     CI/CD ≥80% coverage          │ ║
║  [23] Recursos y Referencias                │     Listo para entrevistas       │ ║
║                                             └──────────────────────────────────┘ ║
║                                                                                  ║
╚══════════════════════════════════════════════════════════════════════════════════╝
```

---

## 📖 Índice de Módulos

### FASE 1: Fundamentos de Ingeniería (Semanas 1-2)

> **Objetivo**: Establecer las bases de código profesional que usarás en todo el portafolio.

| # | Módulo | Qué Aprenderás | Tiempo |
|:-:|--------|----------------|:------:|
| 01 | [Python Moderno](01_PYTHON_MODERNO.md) | Type hints, Pydantic, dataclasses, SOLID | 4h |
| 02 | [Diseño de Sistemas ML](02_DISENO_SISTEMAS.md) | ML Canvas, C4 Model, ADRs, arquitectura | 4h |
| 03 | [Estructura de Proyecto](03_ESTRUCTURA_PROYECTO.md) | src/ layout, pyproject.toml, Makefile | 3h |
| 04 | [Entornos Reproducibles](04_ENTORNOS.md) | venv, Poetry, requirements, lockfiles | 4h |
| 05 | [Git Profesional](05_GIT_PROFESIONAL.md) | Conventional Commits, pre-commit, branching | 4h |
| 06 | [Versionado de Datos](06_VERSIONADO_DATOS.md) | DVC, pipelines de datos, remote storage | 4h |

**📦 Aplicación en el Portafolio**: Todo el código de `common_utils/`, `pyproject.toml` y `.pre-commit-config.yaml`.

> 🎤 **Checkpoint Junior**: Al completar esta fase, practica con [SIMULACRO_ENTREVISTA_JUNIOR.md](SIMULACRO_ENTREVISTA_JUNIOR.md)

---

### FASE 2: ML Engineering (Semanas 3-4)

> **Objetivo**: Dominar el core de Machine Learning profesional: pipelines reproducibles y experimentos rastreables.

| # | Módulo | Qué Aprenderás | Tiempo |
|:-:|--------|----------------|:------:|
| 07 | [sklearn Pipelines](07_SKLEARN_PIPELINES.md) | Pipeline, ColumnTransformer, Custom Transformers | 5h |
| 08 | [Ingeniería de Features](08_INGENIERIA_FEATURES.md) | Data leakage, FeatureEngineer class, validación | 4h |
| 09 | [Training Profesional](09_TRAINING_PROFESIONAL.md) | Clase Trainer, cross-validation, métricas | 5h |
| 10 | [Experiment Tracking](10_EXPERIMENT_TRACKING.md) | MLflow tracking, Model Registry, signatures | 4h |

**📦 Aplicación en el Portafolio**:
- `BankChurn-Predictor/src/bankchurn/pipeline.py` → Pipeline unificado
- `CarVision-Market-Intelligence/src/carvision/features.py` → FeatureEngineer class
- `mlruns/` en cada proyecto → Experimentos MLflow

---

### FASE 3: MLOps Core (Semanas 5-6)

> **Objetivo**: Implementar las prácticas que distinguen un proyecto ML profesional: testing, CI/CD, APIs y observabilidad.

| # | Módulo | Qué Aprenderás | Tiempo |
|:-:|--------|----------------|:------:|
| 11 | [Testing para ML](11_TESTING_ML.md) | Pirámide de testing, fixtures, 80%+ coverage | 6h |
| 12 | [CI/CD con GitHub Actions](12_CI_CD.md) | Matrix testing, coverage gates, security scanning | 5h |
| 13 | [Docker Avanzado](13_DOCKER.md) | Multi-stage builds, non-root, docker-compose | 4h |
| 14 | [FastAPI para ML](14_FASTAPI.md) | Schemas Pydantic, /predict, /health, error handling | 4h |
| 15 | [Streamlit Dashboards](15_STREAMLIT.md) | Caching, tabs, visualizaciones, consumo de API | 3h |
| 16 | [Observabilidad](16_OBSERVABILIDAD.md) | Logging estructurado, Prometheus, drift detection | 4h |

**📦 Aplicación en el Portafolio**:
- `tests/` en cada proyecto → 80%+ coverage
- `.github/workflows/ci-mlops.yml` → Pipeline CI/CD real
- `app/fastapi_app.py` → API de predicción
- `app/streamlit_app.py` → Dashboard interactivo

> 🎤 **Checkpoint Mid**: Al completar esta fase, practica con [SIMULACRO_ENTREVISTA_MID.md](SIMULACRO_ENTREVISTA_MID.md)

---

### FASE 4: Producción (Semana 7)

> **Objetivo**: Entender estrategias de despliegue, infraestructura como código y control de costos en cloud.

| # | Módulo | Qué Aprenderás | Tiempo |
|:-:|--------|----------------|:------:|
| 17 | [Estrategias de Despliegue](17_DESPLIEGUE.md) | Lambda vs ECS vs K8s, blue-green, canary, análisis de costos | 4h |
| 18 | [Infraestructura como Código](18_INFRAESTRUCTURA.md) | Terraform basics, Kubernetes intro, Cloud & FinOps (costos en AWS/GCP) | 3h |

**📦 Aplicación en el Portafolio**:
- `infra/terraform/` → Templates Terraform
- `k8s/` → Manifests Kubernetes (incluyendo buenas prácticas de costos)
- `docker-compose.demo.yml` → Orquestación local

---

### FASE 5: Especialización y Maestría (Semana 8)

> **Objetivo**: Documentación profesional, validación del portafolio y preparación para entrevistas.

| # | Módulo | Qué Aprenderás | Tiempo |
|:-:|--------|----------------|:------:|
| 19 | [Documentación ML](19_DOCUMENTACION.md) | Model Cards, Dataset Cards, MkDocs | 3h |
| 20 | [Proyecto Integrador](20_PROYECTO_INTEGRADOR.md) | Rúbrica 100 puntos, checklist final | 4h |
| 21 | [Glosario MLOps](21_GLOSARIO.md) | 100+ términos esenciales | Referencia |
| 22 | [Checklist Profesional](22_CHECKLIST.md) | Verificación pre-deploy, auditoría | 2h |
| 23 | [Recursos y Referencias](23_RECURSOS.md) | Libros, cursos, papers, comunidades | Referencia |

**📦 Aplicación en el Portafolio**:
- `docs/` en cada proyecto → Model Cards y READMEs profesionales
- `RUNBOOK.md` → Guía de operaciones

> 🎤 **Checkpoint Senior**: Al completar toda la guía, practica con [SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md](SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md) + [PARTE2](SIMULACRO_ENTREVISTA_SENIOR_PARTE2.md)

---

## 📚 Material Complementario

### Práctica y Evaluación

| Recurso | Descripción | Cuándo Usarlo |
|---------|-------------|---------------|
| [Ejercicios](EJERCICIOS.md) | Problemas prácticos por módulo | Después de cada módulo |
| [Soluciones](EJERCICIOS_SOLUCIONES.md) | Respuestas detalladas | Para verificar o desbloquear |
| [Rúbrica de Evaluación](RUBRICA_EVALUACION.md) | Criterios 100 puntos | Al finalizar un proyecto |

### Preparación de Entrevistas

| Nivel | Recurso | Descripción | Cuándo Usarlo |
|:-----:|---------|-------------|---------------|
| 🟢 | [Simulacro Junior](SIMULACRO_ENTREVISTA_JUNIOR.md) | 50 preguntas fundamentales | Semana 4-5 |
| 🟡 | [Simulacro Mid](SIMULACRO_ENTREVISTA_MID.md) | 60 preguntas técnicas | Semana 6-7 |
| 🔴 | [Simulacro Senior Parte 1](SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md) | 50+ preguntas avanzadas | Semana 8 |
| 🔴 | [Simulacro Senior Parte 2](SIMULACRO_ENTREVISTA_SENIOR_PARTE2.md) | System design, casos prácticos | Semana 8 |

| Recurso Complementario | Descripción |
|------------------------|-------------|
| [Speech de Portafolio](APENDICE_A_SPEECH_PORTAFOLIO.md) | Guión completo 5-7 min |
| [Talking Points](APENDICE_B_TALKING_POINTS.md) | Puntos clave concisos |

### Recursos Adicionales

| Recurso | Descripción |
|---------|-------------|
| [SYLLABUS](SYLLABUS.md) | Programa detallado semana a semana |
| [Plan de Estudios](PLAN_ESTUDIOS.md) | Cronograma día a día |
| [Decisiones Técnicas](DECISIONES_TECH.md) | ADRs: por qué cada herramienta |
| [Plantillas](PLANTILLAS.md) | Templates reutilizables |
| [Guía Audiovisual](GUIA_AUDIOVISUAL.md) | Cómo crear demos y videos |
| [Guía de Mantenimiento](MAINTENANCE_GUIDE.md) | Operaciones y runbooks |
| 🔧 **[Guía de Scripts Operacionales](GUIA_SCRIPTS_OPERACIONALES.md)** | **Scripts de demo, testing, auditoría y Makefile del portafolio** ⭐ NUEVO |
| 📺 **[Recursos por Módulo](RECURSOS_POR_MODULO.md)** | **Videos YouTube, Coursera y documentación por módulo** |

---

## 🏗️ Los 3 Proyectos del Portafolio

Esta guía te prepara para construir estos 3 proyectos production-ready:

### 1. BankChurn-Predictor
```
📁 BankChurn-Predictor/
├── src/bankchurn/          # Código fuente
│   ├── config.py           # Configuración Pydantic
│   ├── pipeline.py         # Pipeline sklearn unificado
│   └── trainer.py          # Clase de entrenamiento
├── app/                    # APIs
│   ├── fastapi_app.py
│   └── streamlit_app.py
├── tests/                  # 79%+ coverage
└── Dockerfile              # Multi-stage, non-root
```
- **Problema**: Clasificación binaria (churn/no-churn)
- **Técnicas**: RandomForest, class weighting, SimpleImputer
- **Módulos clave**: 07, 09, 11, 14

### 2. CarVision-Market-Intelligence
```
📁 CarVision-Market-Intelligence/
├── src/carvision/
│   ├── features.py         # FeatureEngineer centralizado
│   ├── data.py             # clean_data parameterizado
│   └── pipeline.py
├── app/
│   └── streamlit_app.py    # Dashboard principal
├── tests/                  # 97% coverage
└── configs/config.yaml
```
- **Problema**: Regresión (predicción de precios de autos)
- **Técnicas**: Custom FeatureEngineer, RandomForest
- **Módulos clave**: 08, 15, 11

### 3. TelecomAI-Customer-Intelligence
```
📁 TelecomAI-Customer-Intelligence/
├── src/telecomai/
│   ├── data.py
│   └── training.py
├── app/
│   ├── fastapi_app.py
│   └── example_load.py
├── tests/                  # 97% coverage
└── docs/
```
- **Problema**: Clasificación multiclase (segmentación de clientes)
- **Técnicas**: LogisticRegression, GradientBoosting
- **Módulos clave**: 09, 10, 12

---

## ⚡ Quick Start

```bash
# 1. Clonar el portafolio
git clone https://github.com/DuqueOM/ML-MLOps-Portfolio.git
cd ML-MLOps-Portfolio

# 2. Empezar con BankChurn (proyecto base)
cd BankChurn-Predictor
pip install -e ".[dev]"

# 3. Ejecutar el flujo completo
make train          # Entrena el modelo
make test           # Ejecuta tests (79%+ coverage)
make serve          # Inicia API en localhost:8000

# 4. Verificar que todo funciona
curl http://localhost:8000/health
```

---

## 📈 Tiempo Estimado

| Fase | Módulos | Horas | Semanas |
|------|---------|:-----:|:-------:|
| Fundamentos | 01-06 | 23h | 2 |
| ML Engineering | 07-10 | 18h | 2 |
| MLOps Core | 11-16 | 26h | 2 |
| Producción | 17-18 | 7h | 1 |
| Especialización | 19-23 | 12h | 1 |
| **TOTAL** | 23 módulos | **~86h** | **8 semanas** |

**Dedicación sugerida**: 10-12 horas/semana

---

## ✅ Convenciones de la Guía

| Símbolo | Significado |
|:-------:|-------------|
| 💡 | Tip o consejo práctico |
| ⚠️ | Advertencia importante |
| ❌ | Anti-patrón o error común |
| ✅ | Buena práctica recomendada |
| 🔧 | Ejercicio práctico |
| 📝 | Nota o aclaración |
| 🎯 | Objetivo de aprendizaje |
| 📦 | Cómo se usó en el portafolio |

---

## 🚀 ¡Empieza Ahora!

<div align="center">

**Módulo 1** → [Python Moderno para MLOps](01_PYTHON_MODERNO.md)

---

*Tiempo estimado para completar la guía: 8 semanas a ritmo moderado*

*Última actualización: Diciembre 2024*

</div>
