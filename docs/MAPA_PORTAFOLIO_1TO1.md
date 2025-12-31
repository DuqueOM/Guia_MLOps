# 🗺️ Mapa 1:1 — ML-MLOps-Portfolio → Guía MLOps

> Objetivo: mapear **cada componente clave** del repo `ML-MLOps-Portfolio` a los **módulos, ejercicios y entregables** de esta guía.
>
> Uso recomendado:
>- Lee el portafolio y ubica el artefacto.
>- Ve al módulo indicado.
>- Ejecuta la tarea (ejercicio/lab/exam/portfolio task) y deja evidencia.

---

## 0) Convención rápida

- **Guía (módulos)**: `docs/NN_TITULO.md`
- **Evidencia**: archivo/PR/commit, captura, logs, reporte, dashboard, o workflow run.

---

## 1) Root del Portafolio (tooling + docs)

| Artefacto (Portfolio) | Qué demuestra | Guía (módulos) | Tarea mínima (Guía → Portafolio) | Evidencia |
|---|---|---|---|---|
| `README.md` | Storytelling técnico + arquitectura | `19_DOCUMENTACION`, `02_DISENO_SISTEMAS`, `22_CHECKLIST` | Redactar README “recruiter-ready” (demo, métricas, arquitectura, quick start) | README actualizado |
| `QUICK_START.md` | Onboarding 1 comando | `04_ENTORNOS`, `13_DOCKER`, `17_DESPLIEGUE` | Implementar “one-command demo” (Makefile + docker-compose) | `make docker-demo` funciona |
| `RUNBOOK.md` | Operación (SRE-style) | `19_DOCUMENTACION`, `16_OBSERVABILIDAD`, `17_DESPLIEGUE` | Crear runbook: start/stop, health-check, troubleshooting, rollback | Runbook + comandos probados |
| `CHECKLIST_RELEASE.md` | Release readiness | `22_CHECKLIST`, `12_CI_CD`, `19_DOCUMENTACION` | Checklist de release (CI, seguridad, artefactos, versión, GHCR) | Checklist rellenada |
| `Makefile` (root) | Automatización profesional | `04_ENTORNOS`, `12_CI_CD` | Unificar comandos (install/test/lint/docker-demo/health-check) | Targets funcionando |
| `.pre-commit-config.yaml` | Calidad (format/lint/type/security) | `05_GIT_PROFESIONAL`, `11_TESTING_ML`, `12_CI_CD` | Instalar y usar pre-commit; arreglar issues | `pre-commit run --all-files` |
| `.gitleaks.toml` | Seguridad (secrets) | `12_CI_CD`, `19_DOCUMENTACION` | Ejecutar gitleaks + política de secretos | Reporte/CI passing |
| `docker-compose.demo.yml` | Stack demo multi-servicio | `13_DOCKER`, `10_EXPERIMENT_TRACKING`, `17_DESPLIEGUE` | Levantar 3 APIs + MLflow + (opc) Prom/Grafana | Servicios healthy |
| `docker-compose.mlflow.yml` | MLflow con Postgres+MinIO | `10_EXPERIMENT_TRACKING`, `13_DOCKER` | Separar tracking server (backend + artifact store) | UI + artefactos |

---

## 2) CI/CD y Automatización (GitHub Actions)

| Artefacto (Portfolio) | Qué demuestra | Guía (módulos) | Tarea mínima | Evidencia |
|---|---|---|---|---|
| `.github/workflows/ci-mlops.yml` | CI unificado (tests/quality/security/docker) | `12_CI_CD`, `11_TESTING_ML`, `13_DOCKER` | Replicar workflow por proyecto + matriz + artefactos | Workflow verde |
| `.github/workflows/docs.yml` | Docs pipeline | `19_DOCUMENTACION`, `12_CI_CD` | Build/deploy docs (MkDocs) | Deployment ok |
| `.github/workflows/drift-detection.yml` | Drift automation | `16_OBSERVABILIDAD`, `12_CI_CD` | Correr drift job + artifacts + issue/comment | Artifact + summary |
| `.github/workflows/drift-bankchurn.yml` | Drift gate (manual) | `16_OBSERVABILIDAD` | Ejecutar drift check, exportar JSON/HTML | Reportes generados |
| `.github/workflows/retrain-bankchurn.yml` | Retrain + registry | `10_EXPERIMENT_TRACKING`, `12_CI_CD` | Retrain manual + promoción condicional | Modelo registrado |

---

## 3) Scripts (operación, auditoría, demo)

| Script (Portfolio) | Rol | Guía (módulos) | Tarea mínima | Evidencia |
|---|---|---|---|---|
| `scripts/demo.sh` | Demo end-to-end local | `13_DOCKER`, `17_DESPLIEGUE` | Automatizar start + smoke requests | Salida OK |
| `scripts/setup_demo_models.sh` | Bootstrap de modelos | `09_TRAINING_PROFESIONAL`, `13_DOCKER` | Generar artefactos reproducibles para demo/CI | Modelos creados |
| `scripts/run_demo_tests.sh` | Smoke tests bash | `11_TESTING_ML`, `12_CI_CD` | Convertir smoke tests a pytest (o validar ambos) | Tests pasan |
| `scripts/run_audit.sh` | Auditoría (lint/type/sec/tests) | `12_CI_CD` | Ejecutar auditoría y guardar reportes | `reports/audit/*` |
| `scripts/fetch_data.py` | Data fetch + checksum | `06_VERSIONADO_DATOS` | Registry de datasets + validación integridad | `checksums.json` |
| `scripts/promote_model.py` | Model registry promotion | `10_EXPERIMENT_TRACKING`, `16_OBSERVABILIDAD` | Promover modelo por umbral (métricas) | Registro/etapa |
| `scripts/health_check.py` | Verificación local de modelos | `11_TESTING_ML`, `04_ENTORNOS` | Health check reproducible post-clone | Script OK |

---

## 4) Observabilidad (Prometheus/Grafana) + Alertas

| Artefacto (Portfolio) | Rol | Guía (módulos) | Tarea mínima | Evidencia |
|---|---|---|---|---|
| `infra/prometheus-config.yaml` | Scraping (K8s + servicios) | `16_OBSERVABILIDAD`, `18_INFRAESTRUCTURA` | Añadir targets/labels + validar métricas | Prometheus targets |
| `infra/prometheus-rules.yaml` | Alerting rules | `16_OBSERVABILIDAD` | Definir alertas (latency, error rate, drift) | Alert rules cargadas |
| `k8s/*deployment.yaml` (annotations) | `prometheus.io/scrape` | `16_OBSERVABILIDAD`, `17_DESPLIEGUE` | Exponer `/metrics` en FastAPI y scrapear | Métricas visibles |

---

## 5) Infraestructura (Terraform + Kubernetes)

| Artefacto (Portfolio) | Rol | Guía (módulos) | Tarea mínima | Evidencia |
|---|---|---|---|---|
| `infra/terraform/README.md` | IaC overview | `18_INFRAESTRUCTURA` | Documentar despliegue IaC (AWS/GCP) | README claro |
| `infra/terraform/aws/main.tf` | EKS/VPC/S3/RDS/ECR | `18_INFRAESTRUCTURA`, `17_DESPLIEGUE` | Plan/apply en entorno sandbox + outputs | `terraform plan` |
| `k8s/namespace.yaml` | Namespaces | `17_DESPLIEGUE` | Namespace dedicado + RBAC mínimo | `kubectl get ns` |
| `k8s/ingress.yaml` | TLS/rate-limit | `17_DESPLIEGUE`, `18_INFRAESTRUCTURA` | Ingress con dominios, TLS y límites | Ingress funcionando |
| `k8s/*-deployment.yaml` + HPA | Rollout + autoscaling | `17_DESPLIEGUE` | Probes + requests/limits + HPA | `kubectl describe hpa` |

---

## 6) Testing (integración + carga)

| Artefacto (Portfolio) | Rol | Guía (módulos) | Tarea mínima | Evidencia |
|---|---|---|---|---|
| `tests/integration/test_demo.py` | Cross-service tests | `11_TESTING_ML`, `12_CI_CD` | Pytest de health + predict (schemas) | `pytest -q` |
| `tests/load/locustfile.py` | Load testing | `02_DISENO_SISTEMAS`, `16_OBSERVABILIDAD` | Prueba de carga + SLOs (p95, error rate) | Reporte Locust |

---

## 7) Utilidades comunes (reproducibilidad + logging)

| Artefacto (Portfolio) | Rol | Guía (módulos) | Tarea mínima | Evidencia |
|---|---|---|---|---|
| `common_utils/seed.py` | Reproducibilidad | `01_PYTHON_MODERNO`, `04_ENTORNOS` | Seed centralizado (Py/NumPy/TF/PT) | Tests deterministas |
| `common_utils/logger.py` | Logging consistente | `16_OBSERVABILIDAD` | Logging estructurado + correlación request-id | Logs uniformes |

---

## 8) Proyectos Top-3 (BankChurn / CarVision / TelecomAI)

**Regla general (aplica a los 3):**
- `src/<pkg>/` → `03_ESTRUCTURA_PROYECTO`, `07_SKLEARN_PIPELINES`, `08_INGENIERIA_FEATURES`, `09_TRAINING_PROFESIONAL`
- `app/fastapi_app.py` → `14_FASTAPI`
- `Dockerfile`/`docker-compose.yml` → `13_DOCKER`, `17_DESPLIEGUE`
- `tests/` → `11_TESTING_ML`
- `model_card.md` + `data_card.md` → `19_DOCUMENTACION`

**CarVision adicional:**
- `app/streamlit_app.py` → `15_STREAMLIT`

---

## 9) Brechas detectadas (para expandir módulos sin borrar contenido)

- **MLflow Model Registry + promoción real** (`scripts/promote_model.py`, workflows de retrain): reforzar en `10_EXPERIMENT_TRACKING`.
- **Alerting serio + runbooks por alerta** (`infra/prometheus-rules.yaml`): reforzar en `16_OBSERVABILIDAD`.
- **K8s Ingress (TLS, rate limiting, cert-manager)** (`k8s/ingress.yaml`): reforzar en `17_DESPLIEGUE`.
- **Terraform backend remoto + locking** (S3+Dynamo / GCS): reforzar en `18_INFRAESTRUCTURA`.
- **Load testing con Locust + SLOs** (`tests/load/*`): crear práctica dedicada.

---

## 10) Documentación del Portafolio (docs/)

| Artefacto (Portfolio) | Rol | Guía (módulos) | Tarea mínima | Evidencia |
|---|---|---|---|---|
| `docs/ARCHITECTURE_PORTFOLIO.md` | Arquitectura sistema | `02_DISENO_SISTEMAS`, `19_DOCUMENTACION` | Crear diagrama Mermaid + explicar flujo request | Diagrama + doc |
| `docs/OPERATIONS_PORTFOLIO.md` | Guías operacionales | `16_OBSERVABILIDAD`, `17_DESPLIEGUE` | Documentar setup, workflows, troubleshooting | Runbook operativo |
| `docs/RELEASE.md` | Release process | `12_CI_CD`, `19_DOCUMENTACION` | Proceso de release + checklist | Proceso documentado |
| `docs/API/` | API reference (OpenAPI) | `14_FASTAPI`, `19_DOCUMENTACION` | Documentar endpoints, schemas, ejemplos | OpenAPI spec |
| `mkdocs.yml` (portfolio) | Docs site config | `19_DOCUMENTACION` | Configurar MkDocs Material + nav | `mkdocs serve` funciona |

---

## 11) Definition of Done: "Portafolio 100% Replicado"

### Nivel 1: Mínimo Viable (Junior)
- [ ] Estructura de proyecto siguiendo el template
- [ ] Al menos 1 proyecto con API funcionando
- [ ] Tests unitarios con >70% coverage
- [ ] Dockerfile funcional
- [ ] README con Quick Start

### Nivel 2: Competente (Mid)
- [ ] Los 3 proyectos con APIs funcionando
- [ ] `make docker-demo` levanta stack completo
- [ ] CI/CD básico (tests + lint)
- [ ] MLflow tracking configurado
- [ ] Tests de integración pasando

### Nivel 3: Profesional (Senior)
- [ ] CI/CD con matriz, coverage gates, security
- [ ] `/metrics` expone métricas, Prometheus scrapea
- [ ] Drift detection configurado
- [ ] Documentación completa (MkDocs + Model Cards)
- [ ] Runbook con troubleshooting

### Nivel 4: Experto (Staff)
- [ ] IaC con Terraform (al menos plan funcional)
- [ ] Kubernetes manifests production-ready
- [ ] Alerting rules configuradas
- [ ] Load testing con SLOs definidos
- [ ] Proceso de release documentado

---

## 12) Comandos de Verificación

```bash
# Verificar stack demo
make docker-demo
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health

# Verificar tests
pytest tests/ -v --cov

# Verificar CI local
pre-commit run --all-files

# Verificar MLflow
curl http://localhost:5000/health

# Verificar métricas
curl http://localhost:8001/metrics

# Verificar drift
python scripts/drift_detection.py --output reports/

# Verificar docs
cd docs && mkdocs serve
```

---

## 13) Recursos de Referencia Cruzada

| Necesitas... | Ve a... |
|--------------|---------|
| Entender la arquitectura | [02_DISENO_SISTEMAS](02_DISENO_SISTEMAS.md) |
| Configurar entorno | [04_ENTORNOS](04_ENTORNOS.md) |
| Crear pipelines ML | [07_SKLEARN_PIPELINES](07_SKLEARN_PIPELINES.md) |
| Configurar MLflow | [10_EXPERIMENT_TRACKING](10_EXPERIMENT_TRACKING.md) |
| Escribir tests | [11_TESTING_ML](11_TESTING_ML.md) |
| Configurar CI/CD | [12_CI_CD](12_CI_CD.md) |
| Dockerizar | [13_DOCKER](13_DOCKER.md) |
| Crear API | [14_FASTAPI](14_FASTAPI.md) |
| Monitorear | [16_OBSERVABILIDAD](16_OBSERVABILIDAD.md) |
| Desplegar | [17_DESPLIEGUE](17_DESPLIEGUE.md) |
| Documentar | [19_DOCUMENTACION](19_DOCUMENTACION.md) |

---

---

## 14) Recursos Pedagógicos (Integrados en Módulos)

| Recurso | Qué ofrece | Ubicación |
|---------|-----------|-----------|
| **Quizzes** | 3 preguntas + 1 ejercicio por módulo | Sección "📝 Quiz del Módulo" al final de cada módulo |
| **La Trampa** | 50+ errores típicos con soluciones | Sección "🪤 La Trampa" al final de cada módulo |
| **Defensa del Portafolio** | Preguntas de entrevista técnica | [Módulo 23 - Sección Defensa](23_PROYECTO_INTEGRADOR.md#defensa-del-portafolio--guía-completa-de-entrevista) |

### Flujo de Aprendizaje por Semana

```
┌─────────────────────────────────────────────────────────────────────────┐
│  1. Leer módulo (teoría)                                                │
│  2. Replicar código en el portafolio (práctica)                         │
│  3. Revisar sección "🪤 La Trampa" del módulo (debugging)                │
│  4. Completar sección "📝 Quiz del Módulo" (evaluación)                │
│  5. Preparar entrevista con Módulo 23 - Defensa del Portafolio          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔗 Navegación

- [← Volver al Índice](00_INDICE.md)
- [→ Plan de Estudios](PLAN_ESTUDIOS.md)
- [→ Syllabus](SYLLABUS.md)
- [→ Defensa del Portafolio (Módulo 23)](23_PROYECTO_INTEGRADOR.md#defensa-del-portafolio--guía-completa-de-entrevista)
