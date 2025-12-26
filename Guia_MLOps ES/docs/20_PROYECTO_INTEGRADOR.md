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

## 📺 <a id="208-recursos-externos-recomendados"></a> Recursos Externos Recomendados
 
 > Ver [RECURSOS_POR_MODULO.md](RECURSOS_POR_MODULO.md) para la lista completa.

| 🏷️ | Recurso | Tipo |
|:--:|:--------|:-----|
| 🔴 | [End-to-End ML Project - Krish Naik](https://www.youtube.com/watch?v=S_F_c9e2bz4) | Video |
| 🟡 | [MLOps Zoomcamp - DataTalks](https://github.com/DataTalksClub/mlops-zoomcamp) | Curso |

---

## 🔗 <a id="209-referencias-del-glosario"></a> Referencias del Glosario
 
 Ver [21_GLOSARIO.md](21_GLOSARIO.md) para definiciones de:
 - **E2E Pipeline**: Flujo completo de datos a predicción
 - **Integration Test**: Tests que verifican componentes juntos
 - **CI/CD**: Integración y despliegue continuo
 
 ---
 
## ✅ <a id="ejercicio"></a> Ejercicio
 
 Ver [EJERCICIOS.md](EJERCICIOS.md) - Módulo 20:
 - **20.1**: Script E2E completo
 - **20.2**: Health Check Script

---

## 🏁 <a id="2010-entrega"></a> Entrega
 
 1. Repositorio público en GitHub
 2. CI pasando (verde)
 3. README con badges actualizados
 4. Self-assessment del checklist completado

---

## 🎤 <a id="checkpoint"></a> Checkpoint: Simulacro Senior/Lead
 
 - [ ] `pip install -e .` funciona en un entorno limpio.
 - [ ] `make test` pasa y el coverage cumple el objetivo.
 - [ ] `make train` produce artefactos en `artifacts/` y es reproducible.
 - [ ] La API expone `/health` y `/predict` (y al menos un test de integración lo valida).
 - [ ] CI está en verde y el README tiene `Quick Start` sin pasos ocultos.
 
 > 🎯 **¡Has completado la guía completa!** (Módulos 01-20)
 > 
 > Si buscas posiciones **Senior/Lead ML Engineer**, es momento del simulacro completo:
> 
> **[→ SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md](SIMULACRO_ENTREVISTA_SENIOR_PARTE1.md)** — 70 preguntas técnicas avanzadas
> **[→ SIMULACRO_ENTREVISTA_SENIOR_PARTE2.md](SIMULACRO_ENTREVISTA_SENIOR_PARTE2.md)** — System design, liderazgo, trade-offs
> 
> Material complementario:
> - [APENDICE_A_SPEECH_PORTAFOLIO.md](APENDICE_A_SPEECH_PORTAFOLIO.md) — Guión de presentación 5-7 min
> - [APENDICE_B_TALKING_POINTS.md](APENDICE_B_TALKING_POINTS.md) — Puntos clave concisos

---

<div align="center">

**¡Éxito en tu proyecto! 🚀**

[← Documentación](19_DOCUMENTACION.md) | [Siguiente: Glosario →](21_GLOSARIO.md)

</div>
