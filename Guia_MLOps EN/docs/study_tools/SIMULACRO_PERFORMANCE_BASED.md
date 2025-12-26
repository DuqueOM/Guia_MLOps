# 🧪 Simulacros Performance-Based (MLOps)

## 🎯 Objetivo

Simular tareas reales de un ML/MLOps Engineer con tiempo acotado y criterios claros.

---

## PB-1 — “El proyecto no corre en otra máquina” (Setup/Repro)

- **Tiempo**: 45 min
- **Input**: un compañero clona el repo y falla `make train` o `pytest`.
- **Output**:
  - instrucciones corregidas + fix mínimo (deps/env) + evidencia (log).
- **Criterios**:
  - reproducción del error
  - fix reproducible
  - documentación actualizada

---

## PB-2 — “Leakage silencioso” (Features)

- **Tiempo**: 60 min
- **Input**: métrica en test sube demasiado y luego cae en prod.
- **Output**:
  - hipótesis de leakage + test que lo detecte.

---

## PB-3 — “CI rojo” (CI/CD)

- **Tiempo**: 45 min
- **Input**: falla un job del workflow.
- **Output**:
  - diagnóstico + fix + prevención (mejor test, caching, pinning).

---

## PB-4 — “Docker build lento / inseguro” (Container)

- **Tiempo**: 60 min
- **Input**: imagen >1GB o corre como root.
- **Output**:
  - mejoras (multi-stage, non-root, cache) + explicación trade-offs.

---

## PB-5 — “Incidente en producción” (Observabilidad)

- **Tiempo**: 75 min
- **Input**: la latencia subió y la métrica cayó.
- **Output**:
  - plan de triage + instrumentación mínima (logs/métricas) + decisión.

---

## PB-6 — “System Design MLOps” (Arquitectura)

- **Tiempo**: 90 min
- **Input**: diseñar serving + retraining + monitoring para uno de los proyectos.
- **Output**:
  - diagrama (C4 o similar) + lista de trade-offs + ADR.

---

<div align="center">

[← Volver](index.md)

</div>
