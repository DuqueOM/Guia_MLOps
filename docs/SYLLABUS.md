# 📅 SYLLABUS — Guía MLOps (Portfolio Edition)
 
 > Ruta principal (recomendada): **24 semanas (6 meses)**.
 >
 > Ruta acelerada: **8 semanas**.
 >
 > 🗺️ **Mapa 1:1 Portafolio → Guía**: [MAPA_PORTAFOLIO_1TO1.md](MAPA_PORTAFOLIO_1TO1.md)
 
 ---
 
 > 📌 **Navegación**: Este documento complementa el [Índice Principal (00_INDICE.md)](00_INDICE.md) con detalles de macro-módulos y progresión 0 → Senior/Staff. Para la estructura módulo por módulo, consulta el índice.

---

## 🎯 Objetivo del Programa

Al completar este programa serás capaz de:

- ✅ **Reproducir 100%** de los artefactos clave del portafolio (modelos, APIs, dashboards)
- ✅ Implementar **CI/CD profesional** con 80%+ coverage
- ✅ Diseñar **arquitecturas ML production-ready**
- ✅ **Pasar entrevistas técnicas** nivel Senior/Staff
- ✅ Crear **Model Cards y Dataset Cards** completos
- ✅ Implementar **observabilidad y monitoreo** básico

---

 ## 📊 Estructura del Programa (12 Módulos) — Ruta acelerada (8 semanas)
 
 | Módulo | Nombre | Duración | Mini-Proyecto |
 |:------:|:-------|:--------:|:--------------|
 | 00 | Introducción | 0.5 días | Setup inicial |
| 01 | Python Moderno | 2 días | Librería `utils/` |
| 02 | Ingeniería de Datos | 4 días | ETL reproducible |
| 03 | Feature Engineering | 3 días | Transformadores `.pkl` |
| 04 | Modelado | 6 días | Scripts de entrenamiento |
| 05 | MLflow & DVC | 3 días | Tracking local |
| 06 | Despliegue API | 3 días | FastAPI `/predict` |
| 07 | Dashboard | 2 días | Streamlit app |
| 08 | CI/CD & Testing | 3 días | GitHub Actions |
| 09 | Model & Dataset Cards | 1.5 días | Documentación ML |
| 10 | Observabilidad | 2 días | Logging + alertas |
| 11 | Mantenimiento & Auditoría | 2 días | Runbooks |

  **Tiempo total estimado (ruta acelerada)**: 32 días (~6-8 semanas a ritmo moderado)
 
 > Si sigues la **ruta principal (24 semanas)**, usa este mismo mapa pero con más práctica, debugging y entregables (ver `README.md` del repo y el `00_INDICE.md`).
 
  ---

 ## 🧭 Ruta 0 → Senior/Staff (macro-módulos)

 > Esta ruta agrupa los 23 módulos de la guía en **11 macro-módulos** que siguen el plan
 > "0 → Senior/Staff MLOps" que definiste. No reemplaza la numeración actual (01–23),
 > sino que ofrece una vista de alto nivel basada en madurez.

 | Macro-Módulo | Nombre | Objetivo principal | Módulos relacionados |
 |:------------:|--------|--------------------|----------------------|
 | 00 | Entorno, Herramientas y Flujo de Trabajo | Poder ejecutar los 3 proyectos del portafolio en tu máquina | 00_INDICE, 03_ESTRUCTURA_PROYECTO, 04_ENTORNOS, 05_GIT_PROFESIONAL, 17_DESPLIEGUE, PLAN_ESTUDIOS, QUICK_START del repo |
 | 01 | Python Fundamentos para Producción | Pasar de Python junior a escribir código pythonico y mantenible | 01_PYTHON_MODERNO, 03_ESTRUCTURA_PROYECTO, common_utils/* |
 | 02 | Fundamentos de Data Science y ML | Tener bases sólidas de DS/ML antes de entrar a MLOps | 07_SKLEARN_PIPELINES, 08_INGENIERIA_FEATURES, 09_TRAINING_PROFESIONAL, notebooks de los proyectos |
 | 03 | Ingeniería de Datos Aplicada a ML | Preparar datos como en una empresa, pensando en ML downstream | 06_VERSIONADO_DATOS, 08_INGENIERIA_FEATURES, partes de TelecomAI-Customer-Intelligence |
 | 04 | Fundamentos de MLOps | Entender reproducibilidad, versionado y artefactos | 06_VERSIONADO_DATOS, 10_EXPERIMENT_TRACKING, DECISIONES_TECH, 22_CHECKLIST |
 | 05 | Pipelines + CI/CD | Construir pipelines reales con tests y gates de calidad | 07_SKLEARN_PIPELINES, 11_TESTING_ML, 12_CI_CD, workflows de .github/workflows/ |
 | 06 | Model Deployment | Desplegar modelos con nivel Senior (APIs, Docker, serverless) | 13_DOCKER, 14_FASTAPI, 17_DESPLIEGUE, docker-compose.demo.yml |
 | 07 | Monitoring, Observabilidad y Alertas | Diferenciarte como Senior mediante observabilidad real | 16_OBSERVABILIDAD, 22_CHECKLIST, dashboards de Grafana |
 | 08 | Infraestructura y Nube | Operar como engineer: IaC, redes y cloud basics | 17_DESPLIEGUE, 18_INFRAESTRUCTURA, infra/terraform/*, k8s/* |
 | 09 | Escalado y Sistemas Distribuidos | Pensar en batch/streaming y K8s para ML a gran escala | 18_INFRAESTRUCTURA, partes avanzadas de 17_DESPLIEGUE, tests/load/* |
 | 10 | Seguridad, Gobernanza y Cumplimiento | Tratar el portafolio como un sistema empresarial | 19_DOCUMENTACION, 12_CI_CD (gitleaks, security), .gitleaks.toml, RUNBOOK.md |
 | 11 | Arquitectura MLOps Senior/Staff | Ver el sistema completo: multi-model, observabilidad y gobierno | 23_PROYECTO_INTEGRADOR, apoyo/GLOSARIO, apoyo/RECURSOS, DECISIONES_TECH, RUNBOOK.md |

 **Guion resumido por macro-módulo**

 **MÓDULO 00 — Entorno, Herramientas y Flujo de Trabajo**  
 Objetivo: garantizar que puedas ejecutar los 3 proyectos (BankChurn, CarVision, TelecomAI).  
 Incluye: Conda/pipx/uv, Docker + Docker Compose, Git + branching, VS Code + DevContainers, Makefiles, estructura estándar ML/MLOps.  
 Práctica en este repo: seguir `00_INDICE.md`, `PLAN_ESTUDIOS.md` y el QUICK_START de la raíz hasta ejecutar BankChurn end-to-end.

 **MÓDULO 01 — Python Fundamentos para Producción**  
 Objetivo: llevar de Python junior a código pythonico y mantenible.  
 Incluye: POO aplicada a ML, tipado estático (mypy), logging profesional, manejo de errores, estructura de paquetes.  
 Práctica en este repo: trabajar `01_PYTHON_MODERNO.md` y refactorizar utilidades en `common_utils/` y el código de BankChurn.

 **MÓDULO 02 — Fundamentos de Data Science y ML**  
 Objetivo: construir bases sólidas de DS/ML antes de MLOps.  
 Incluye: exploración, limpieza, feature engineering, validación cruzada, overfitting/underfitting.  
 Práctica en este repo: rehacer el pipeline de features y validación de BankChurn apoyándote en `07_SKLEARN_PIPELINES.md`, `08_INGENIERIA_FEATURES.md` y `09_TRAINING_PROFESIONAL.md`.

 **MÓDULO 03 — Ingeniería de Datos Aplicada a ML**  
 Objetivo: preparar datos como en una empresa, pensando en su uso en modelos.  
 Incluye: ETL/ELT, orquestación ligera, data quality, feature stores.  
 Práctica en este repo: usar `06_VERSIONADO_DATOS.md` y `08_INGENIERIA_FEATURES.md` para montar un mini feature store inspirado en TelecomAI.

 **MÓDULO 04 — Fundamentos de MLOps**  
 Objetivo: introducir el mindset MLOps (reproducibilidad, versionado, artefactos).  
 Incluye: versionado de datos y modelos, ML metadata, experiment tracking, artefactos.  
 Práctica en este repo: integrar MLflow y DVC a BankChurn siguiendo `06_VERSIONADO_DATOS.md`, `10_EXPERIMENT_TRACKING.md` y `DECISIONES_TECH.md`.

 **MÓDULO 05 — Pipelines + CI/CD**  
 Objetivo: crear pipelines reales con CI/CD enterprise-like.  
 Incluye: GitHub Actions, testing, coverage, code-quality gates.  
 Práctica en este repo: combinar `07_SKLEARN_PIPELINES.md`, `11_TESTING_ML.md` y `12_CI_CD.md` para obtener un pipeline completo para los 3 proyectos usando los workflows reales del repositorio.

 **MÓDULO 06 — Model Deployment**  
 Objetivo: desplegar con nivel Senior.  
 Incluye: APIs con FastAPI, dockerización, serverless, patrones de model serving.  
 Práctica en este repo: usar `13_DOCKER.md`, `14_FASTAPI.md` y `17_DESPLIEGUE.md` para desplegar CarVision en contenedor + endpoint (local y/o cloud).

 **MÓDULO 07 — Monitoring, Observabilidad y Alertas**  
 Objetivo: incorporar observabilidad que diferencie un junior de un senior.  
 Incluye: concept vs data drift, monitoreo de features/predicciones, logging estructurado, Prometheus + Grafana.  
 Práctica en este repo: seguir `16_OBSERVABILIDAD.md` para instrumentar BankChurn con métricas y paneles, apoyándote en los manifiestos de `k8s/` y las reglas de `infra/`.

 **MÓDULO 08 — Infraestructura y Nube**  
 Objetivo: operar como un engineer en cloud.  
 Incluye: IaC (Terraform), fundamentos AWS/GCP, redes, seguridad básica y control de costos (FinOps) para evitar sorpresas en la factura.  
 Práctica en este repo: partir de `17_DESPLIEGUE.md` y `18_INFRAESTRUCTURA.md` (especialmente la sección *Cloud y Control de Costos*) para desplegar un stack MLOps básico en cloud (o simularlo localmente con los manifests y Terraform). 

 **MÓDULO 09 — Escalado y Sistemas Distribuidos**  
 Objetivo: pensar en batch/streaming y K8s para producción masiva.  
 Incluye: batch vs streaming, Kubernetes, automatización avanzada.  
 Práctica en este repo: usar las secciones avanzadas de `18_INFRAESTRUCTURA.md`, los manifests en `k8s/` y los tests de carga en `tests/load/` como base para diseñar un despliegue escalable de CarVision.

 **MÓDULO 10 — Seguridad, Gobernanza y Cumplimiento**  
 Objetivo: llevar la senioridad al plano empresarial.  
 Incluye: políticas, roles, seguridad de repos (secrets, escaneo), Model Cards y ética.  
 Práctica en este repo: combinar `19_DOCUMENTACION.md`, la configuración de `12_CI_CD.md` (gitleaks, security scanning) y `.gitleaks.toml` para definir políticas mínimas y completar Model Cards para los 3 proyectos.

 **MÓDULO 11 — Arquitectura MLOps Senior/Staff**  
 Objetivo: tener visión completa de sistemas reales (multi-model, gobierno, observabilidad a gran escala).  
 Incluye: arquitecturas event-driven, multi-model governance, patrones de observabilidad.  
 Práctica en este repo: usar `23_PROYECTO_INTEGRADOR.md`, `DECISIONES_TECH.md` y `RUNBOOK.md` para diseñar y documentar una arquitectura MLOps completa que integre los 3 proyectos.

 Puedes usar:

 - Esta sección para entender el **mapa mental 0 → Senior/Staff**.
 - El índice de 23 módulos (`00_INDICE.md`) y el plan por semanas para avanzar **paso a paso**.

 ---

 ## 📚 Detalle por Módulo

### Módulo 00 — Introducción (0.5 días)

| Contenido | Entregable |
|:----------|:-----------|
| Objetivos del curso | ✅ Entender el roadmap |
| Cómo leer la guía | ✅ Setup de herramientas |
| Requerimientos mínimos | ✅ Entorno listo |
| Mapa guía → repo | ✅ Comprensión de estructura |

**Output**: Entorno de desarrollo listo, comprensión clara del objetivo final.

---

### Módulo 01 — Python Moderno (2 días)

| Contenido | Entregable |
|:----------|:-----------|
| Type hints y tipado estático | Código tipado |
| Dataclasses y Pydantic | Config validado |
| OOP y SOLID básico | Clases bien diseñadas |
| Estructura de paquete | `utils/` funcional |

**Mini-Proyecto**: Crear librería `utils/` con `config.py` (Pydantic) y `mathops.py` (funciones tipadas).

**Validar**: `make check-01`


---

### Módulo 02 — Ingeniería de Datos (4 días)

| Contenido | Entregable |
|:----------|:-----------|
| Lectura/escritura de datos | Loaders reutilizables |
| Validación con schemas | Contratos de datos |
| Transformaciones básicas | ETL reproducible |
| Tests de integridad | Datos validados |

**Mini-Proyecto**: ETL que produce CSV/Parquet reproducible + tests de integridad.

**Validar**: `make check-02`

---

### Módulo 03 — Feature Engineering (3 días)

| Contenido | Entregable |
|:----------|:-----------|
| Pipelines serializables | Pipeline persistido |
| Custom encoders | Transformadores `.pkl` |
| Prevención de data leakage | Código seguro |
| Persistencia de artefactos | Artefactos reutilizables |

**Mini-Proyecto**: `FeatureEngineer` class con transformadores serializados.

**Validar**: `make check-03`


---

### Módulo 04 — Modelado (6 días)

| Contenido | Entregable |
|:----------|:-----------|
| Pipelines sklearn completos | Pipeline unificado |
| Validación temporal/cruzada | CV implementado |
| Hyperparameter tuning | Búsqueda de hiperparámetros |
| Experimentación reproducible | Scripts de entrenamiento |

**Mini-Proyecto**: Scripts que generan modelos y reportes en `outputs/`.

**Validar**: `make check-04`

---

### Módulo 05 — MLflow & DVC (3 días)

| Contenido | Entregable |
|:----------|:-----------|
| MLflow server local | `mlflow ui` funcionando |
| Tracking de experimentos | Métricas registradas |
| DVC init y pipelines | `dvc.yaml` configurado |
| Versionado de artefactos | Datos versionados |

**Mini-Proyecto**: `mlruns/` y `dvc/` que emulan el flujo del repo.

**Validar**: `make check-05`

---

### Módulo 06 — Despliegue API (3 días)

| Contenido | Entregable |
|:----------|:-----------|
| FastAPI básico | API funcional |
| Schemas Pydantic | Request/Response tipados |
| Tests de integración | Tests pasando |
| Dockerfile | Contenedor listo |

**Mini-Proyecto**: API local con endpoint `/predict` funcional.

**Validar**: `make check-06`

---

### Módulo 07 — Dashboard (2 días)

| Contenido | Entregable |
|:----------|:-----------|
| Streamlit básico | App funcionando |
| Consumo de API | Integración con backend |
| Caching y optimización | Performance aceptable |
| Ejemplo desplegable | Ready to deploy |

**Mini-Proyecto**: Dashboard Streamlit que consume la API local.

**Validar**: `make check-07`

---

### Módulo 08 — CI/CD & Testing (3 días)

| Contenido | Entregable |
|:----------|:-----------|
| GitHub Actions | Workflow configurado |
| Matrix testing | Tests multi-versión |
| Coverage reports | 80%+ coverage |
| Security scanning | gitleaks local |

**Mini-Proyecto**: `ci_template.yml` funcional, simulación local con `act`.

**Validar**: `make check-08`

---

### Módulo 09 — Model & Dataset Cards (1.5 días)

| Contenido | Entregable |
|:----------|:-----------|
| Plantilla Model Card | Template relleno |
| Plantilla Dataset Card | Template relleno |
| Buenas prácticas de documentación | Docs completos |
| Ejemplos del portafolio | Cards reales |

**Mini-Proyecto**: Model Card y Dataset Card completados para un mini-proyecto.

**Validar**: `make check-09`

---

### Módulo 10 — Observabilidad & Monitoring (2 días)

| Contenido | Entregable |
|:----------|:-----------|
| Logging estructurado | Logs configurados |
| Métricas básicas | Latencia, error rate |
| Simulación de alertas | Scripts de alerta |
| Drift detection básico | Checks implementados |

**Mini-Proyecto**: Sistema con logging estructurado y scripts de alerta.

**Validar**: `make check-10`

---

### Módulo 11 — Mantenimiento & Auditoría (2 días)

| Contenido | Entregable |
|:----------|:-----------|
| Playbooks de mantenimiento | Runbooks documentados |
| Tests de regresión | Regression tests |
| Actualización de dependencias | Proceso documentado |
| Calendario de revisiones | Plan de mantenimiento |

**Mini-Proyecto**: MAINTENANCE_GUIDE.md y scripts de validación.

**Validar**: `make check-11`

---

## 🚀 Módulos Avanzados (Senior/Staff)

Estos módulos cubren temas avanzados para nivel Senior/Staff:

### Módulo 20 — Observabilidad Avanzada y Drift (3 días)

| Contenido | Entregable |
|:----------|:-----------|
| Detección estadística de drift (KS-test, PSI) | Detector funcionando |
| EvidentlyAI / Alibi Detect | Reportes automatizados |
| Alertas multi-nivel | Sistema de alertas |
| Métricas ML → KPIs de negocio | Dashboard de impacto |

**Mini-Proyecto**: Sistema que detecta datos corruptos antes de retrain.

**Documento**: [20_OBSERVABILIDAD_AVANZADA_DRIFT.md](20_OBSERVABILIDAD_AVANZADA_DRIFT.md)

**Examen relacionado**: [EXAM_05_PRODUCTION](../exams/EXAM_05_PRODUCTION.md)

---

### Módulo 21 — Cloud FinOps y Estrategia (2 días)

| Contenido | Entregable |
|:----------|:-----------|
| Costos ML: Training vs Inference | Calculadora de costos |
| Spot vs On-Demand vs Reserved | Estrategia documentada |
| Auto-scaling inteligente | HPA configurado |
| Cálculo de TCO | Análisis completo |

**Mini-Proyecto**: Reducir TCO del Portfolio en 30%.

**Documento**: [21_CLOUD_FINOPS.md](21_CLOUD_FINOPS.md)

**Recursos**: [Material de Apoyo](apoyo/index.md)

---

### Módulo 22 — Infrastructure as Code Empresarial (3 días)

| Contenido | Entregable |
|:----------|:-----------|
| Gestión de estado Terraform | State locking configurado |
| Arquitectura multi-ambiente | Dev/Staging/Prod |
| Módulos reutilizables | Terraform modules |
| CI/CD para infraestructura | Pipeline de infra |

**Mini-Proyecto**: Refactorizar infra/ para soportar Staging.

**Documento**: [22_IAC_EMPRESARIAL.md](22_IAC_EMPRESARIAL.md)

**Examen Final**: [EXAM_06_INTEGRATION](../exams/EXAM_06_INTEGRATION.md)

---

## 📊 Rúbrica de Evaluación (100 puntos por módulo)

| Criterio | Puntos | Descripción |
|:---------|:------:|:------------|
| **Funcionalidad** | 40 | Pasa tests mínimos, produce outputs esperados |
| **Calidad del código** | 20 | Linters, type hints, modularidad |
| **Documentación** | 15 | README, Model/Dataset Cards |
| **Reproducibilidad** | 15 | Instrucciones make, lockfile, ejecución local |
| **Tests y cobertura** | 10 | Pruebas unitarias/integración mínimas |

**Nota mínima aprobatoria**: 70/100 por módulo

---

## 📈 Progreso Sugerido

### Ruta Acelerada (8 semanas)
```
Semana 1:   Módulos 00-01 (Fundamentos Python)
Semana 2:   Módulos 02-03 + 03B/03C (Datos, Features, Refactoring)
Semana 3:   Módulo 04 (Modelado completo)
Semana 4:   Módulos 05-06 (Tracking + API)
Semana 5:   Módulos 07-08 (Dashboard + CI/CD)
Semana 6:   Módulos 09-11 (Docs + Mantenimiento)
Semana 7:   Módulos 20-21 (Observabilidad + FinOps)
Semana 8:   Módulo 22 + Proyecto Integrador (IaC + Consolidación)
```

### Ruta Principal (24 semanas)
```
Mes 1:      Módulos 00-03 + Ejercicios Puente
Mes 2:      Módulos 04-06 (Modelado + Tracking + API)
Mes 3:      Módulos 07-11 (Dashboard + CI/CD + Docs)
Mes 4:      Módulos 20-22 (Avanzados)
Mes 5:      Proyecto Integrador + Práctica
Mes 6:      Preparación Entrevistas + Pulido Portfolio
```

---

## 🎤 Preparación para Entrevistas

La guía incluye simulacros de entrevista adaptados a cada nivel de experiencia:

| Nivel | Simulacro | Preguntas | Cuándo Usar |
|:-----:|-----------|:---------:|-------------|
| 🟢 Junior | [Simulacro Junior](SIMULACRO_ENTREVISTA_JUNIOR.md) | 50 | Semanas 1-4 |
| 🟡 Mid | [Simulacro Mid](SIMULACRO_ENTREVISTA_MID.md) | 60 | Semanas 5-6 |
| 🔴 Senior | [Simulacro Senior P1](SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md) + [P2](SIMULACRO_ENTREVISTA_SENIOR_PARTE2.md) | 115 | Semanas 7-8 |

### 🆕 Defensa del Portafolio

| Recurso | Descripción |
|---------|-------------|
| [DEFENSA_PORTAFOLIO.md](DEFENSA_PORTAFOLIO.md) | Preguntas técnicas sobre decisiones de arquitectura del portafolio |

Incluye:
- **Speech de 5-7 minutos**: Guión estructurado para presentar tu trabajo
- **50+ preguntas por categoría**: Arquitectura, Python, Pipelines, DVC/MLflow, Testing, Docker, CI/CD, Observabilidad, Infraestructura
- **Escenarios de System Design**: Escalado 10x, multi-modelo
- **Preguntas trampa**: Cómo responder sin caer en errores comunes
- **Rúbrica de autoevaluación**: Mide tu preparación

**Progresión recomendada**:
1. **Junior**: Python básico, ML fundamentos, Git, estructura de proyecto
2. **Mid**: Pipelines, testing, CI/CD, Docker, APIs
3. **Senior**: System design, arquitectura, liderazgo, trade-offs

---

## 🏛️ Los 4 Pilares Pedagógicos

Cada semana está estructurada en 4 pilares, **ahora integrados directamente en cada módulo**:

| Pilar | Ubicación | Contenido |
|:-----:|-----------|-----------|
| **1. Teoría** | Módulos (`01_` a `23_`) | Conceptos con analogías del mundo real |
| **2. Práctica** | README.md + módulos | Código paso a paso, puentes al portafolio |
| **3. La Trampa** | Sección "🪤 La Trampa" al final de cada módulo | 50+ errores típicos integrados por tema |
| **4. Evaluación** | Sección "📝 Quiz del Módulo" al final de cada módulo | Quizzes integrados (3 preguntas + 1 ejercicio) |

### 🪤 La Trampa — Errores Comunes (Integrados)

Al final de cada módulo encontrarás errores que **todos** cometen:
- **Síntoma**: Qué ves cuando caes en la trampa
- **Causa raíz**: Por qué sucede
- **Solución**: Cómo arreglarlo paso a paso
- **Prevención**: Cómo evitarlo en el futuro

### 📝 Quizzes (Integrados en Módulos)

Al final de cada módulo:
- 3 preguntas conceptuales (25 pts c/u)
- 1 ejercicio práctico de código (25 pts)
- Total: 100 pts/módulo, mínimo aprobatorio: 70 pts


---

## ✅ Prerrequisitos

- **Python 3.10+** instalado
- **Git** básico (clone, commit, push)
- **Línea de comandos** básica (bash/zsh)
- **Cuenta GitHub** activa
- **Editor/IDE** (VS Code recomendado)
- **8GB RAM** mínimo, 16GB recomendado

---

## 🛠️ Cómo usar la guía

1. **Clonar** el repositorio guía
2. **Ejecutar** `make setup` para preparar el entorno
3. **Seguir** cada módulo en orden
4. **Completar** el mini-proyecto de cada módulo
5. **Validar** con `make check-XX` correspondiente
6. **Revisar** soluciones en `solutions/` si necesitas ayuda

---

## 📦 Entregables Finales

Al completar la guía tendrás:

- [ ] Portafolio ML reproducido localmente
- [ ] 3 proyectos con CI/CD funcionando
- [ ] Model Cards y Dataset Cards completos
- [ ] APIs y dashboards desplegables
- [ ] Sistema de observabilidad básico
- [ ] Runbooks de mantenimiento

---

<div align="center">

**¡Empieza ahora!** → [00_INDICE.md](00_INDICE.md)

</div>
