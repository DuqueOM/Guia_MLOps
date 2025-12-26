# 🧠 Protocolo E — Rescate Cognitivo + Metacognición (MLOps Edition)

## 🎯 Objetivo

Reducir fatiga cognitiva y aumentar transferencia **teoría → código → evidencia** durante la construcción del portafolio.

La idea central: **no estudiar más**, sino estudiar **con un sistema**.

---

## 🧱 La unidad de progreso

En esta guía, el progreso no es “leí el módulo”, sino:

1. **Entendí** el concepto
2. **Lo implementé** en código real (en uno de los proyectos)
3. **Lo validé** (tests, checks, endpoints, reproducibilidad)
4. **Lo documenté** (README/ADR/nota técnica)

---

## 📅 Distribución diaria típica (adaptación a MLOps)

| Bloque | Actividad | Duración | Output mínimo |
|--------|-----------|:--------:|---------------|
| Mañana | Lectura guiada (módulo) + notas | 60–120 min | 5-10 bullets + 1 pregunta abierta |
| Mediodía | Implementación en el repo | 90–180 min | PR local o commit con cambio concreto |
| Tarde | Ejercicios/validación | 45–90 min | tests / `make` / mini-demo |
| Cierre | Diario + plan siguiente sesión | 10–15 min | 1 entrada en Diario + 1 siguiente paso |

---

## 🌉 Puente teoría ↔ código (la parte crítica)

Para cada tema del módulo, fuerza este mapeo:

- **Concepto**: ¿qué afirmación técnica debe ser verdadera?
- **Lugar en el portafolio**: ¿dónde vive esto en BankChurn/CarVision/TelecomAI?
- **Artefacto**: ¿qué archivo cambia o se crea?
- **Prueba**: ¿qué test o verificación lo asegura?
- **Evidencia**: ¿qué screenshot/log/tabla lo demuestra?

---

## 🚑 Rescate cognitivo (cuando te bloqueas)

Aplica el siguiente protocolo (en orden):

1. **Reducir el problema**
   - ¿puedo reproducirlo en 5-15 líneas? ¿en un test?
2. **Nombrar la hipótesis**
   - escribe 1 hipótesis verificable en `DIARIO_ERRORES.md`
3. **Experimento mínimo**
   - 1 cambio, 1 ejecución, 1 resultado
4. **Decidir**
   - si funciona: fija el aprendizaje con un test o regla
   - si no funciona: cambia hipótesis, no repitas a ciegas
5. **Timebox**
   - 25-45 min por hipótesis

---

## 📌 Restricciones (para evitar autoengaño)

- **Local-first**: todo debe poder correr en tu máquina.
- **Reproducible**: si no puedes re-ejecutarlo, no cuenta como progreso.
- **No “copiar y pegar”** sin explicar el porqué.
- **Sin magia en notebooks**: el entregable final debe vivir en `src/`, `tests/`, `app/` y docs.
- **Cada cambio importante** debe dejar un rastro:
  - test, ADR, checklist o evidencia en README.

---

## ✅ Verificación de competencias (macro)

Usa esta tabla como brújula para detectar gaps (1–5):

```markdown
| Competencia | 1-5 | Evidencia | Gap | Acción |
|-------------|:---:|----------|:---:|--------|
| Python productivo (typing, config, diseño) |  |  |  |  |
| Pipelines ML reproducibles |  |  |  |  |
| Testing (ML + ingeniería) |  |  |  |  |
| CI/CD |  |  |  |  |
| Docker + despliegue |  |  |  |  |
| APIs (FastAPI) + contratos |  |  |  |  |
| Observabilidad + drift |  |  |  |  |
| Infra/IaC (conceptos + manifests) |  |  |  |  |
| Documentación (Model/Dataset cards + ADRs) |  |  |  |  |
```

---

## 🔗 Siguiente paso

- Completa tu primera entrada en **[DIARIO_ERRORES.md](DIARIO_ERRORES.md)**.
- Al final de tu primera semana, llena **[CIERRE_SEMANAL.md](CIERRE_SEMANAL.md)**.

<div align="center">

[← Volver](index.md)

</div>
