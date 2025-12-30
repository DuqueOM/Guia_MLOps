# 20. Observabilidad Avanzada y Detección de Drift

## 🎯 Objetivo

Dominar detección de drift, alertas inteligentes y mapeo de métricas ML a KPIs de negocio.

---

## 📋 Contenido

1. [Fundamentos de Drift](#1-fundamentos)
2. [Detección Estadística](#2-estadistica)
3. [EvidentlyAI](#3-evidently)
4. [Alertas](#4-alertas)
5. [Métricas → KPIs](#5-kpis)
5.5. [🔬 Ingeniería Inversa: Drift en CI/CD](#55-ingenieria-inversa-drift) ⭐ NUEVO
6. [Ejercicio](#6-ejercicio)
7. [Entrevista Senior](#7-entrevista)

---

<a id="1-fundamentos"></a>


### 🧠 Mapa Mental de Conceptos

**Términos clave para este módulo:**
- Revisa los conceptos principales en las secciones siguientes
- Practica con los ejercicios del portafolio BankChurn
- Aplica los checkpoints para verificar tu comprensión

---



### 💻 Ejercicio Puente: Model Monitoring

> **Meta**: Practica el concepto antes de aplicarlo al portafolio.

**Ejercicio básico:**
1. Lee la sección teórica siguiente
2. Identifica los patrones clave del código de ejemplo
3. Replica el patrón en un proyecto de prueba

---

### 🛠️ Práctica del Portafolio: Drift Detection en BankChurn

> **Tarea**: Aplicar este módulo en BankChurn-Predictor.

```bash
cd BankChurn-Predictor
# Explora el código relacionado con Model Monitoring
```

**Checklist:**
- [ ] Localicé el código relevante
- [ ] Entendí la implementación actual
- [ ] Identifiqué posibles mejoras

---

### ✅ Checkpoint de Conocimiento

**Pregunta 1**: ¿Cuál es el objetivo principal de Drift Detection?

**Pregunta 2**: ¿Cómo se implementa en el portafolio?

**🔧 Escenario Debugging**: Si algo falla en Model Monitoring, ¿cuál sería tu primer paso de diagnóstico?


## 1. Fundamentos de Drift

### Tipos de Drift

| Tipo | Fórmula | Ejemplo |
|------|---------|---------|
| **Data Drift** | P(X_train) ≠ P(X_prod) | Edad promedio sube 35→45 |
| **Concept Drift** | P(Y\|X) cambia | Relación features→target cambia |
| **Label Drift** | P(Y) cambia | Churn rate 15%→30% |
| **Prediction Drift** | Distribución de ŷ cambia | Síntoma de otros drifts |

### Impacto de No Detectar

```python
# drift_impact.py
"""Calcula impacto monetario de drift no detectado."""

def calculate_impact(
    delay_days: int,                    # Días sin detectar.
    daily_preds: int = 10_000,          # Predicciones/día.
    extra_errors_pct: float = 0.05,     # 5% más errores.
    cost_per_error: float = 100.0,      # $100 por error.
) -> float:
    """Retorna costo total en USD."""
    extra_errors = daily_preds * extra_errors_pct
    return extra_errors * cost_per_error * delay_days

# Comparación de escenarios
print(f"Sin monitoreo (90d): ${calculate_impact(90):,.0f}")   # $4.5M
print(f"Semanal (7d): ${calculate_impact(7):,.0f}")           # $350K
print(f"Diario (1d): ${calculate_impact(1):,.0f}")            # $50K
```

---

<a id="2-estadistica"></a>

## 2. Detección Estadística

### 2.1 KS-Test

```python
# ks_detector.py
"""Detector de drift con Kolmogorov-Smirnov."""

import numpy as np                              # Operaciones numéricas y arrays.
from scipy import stats                         # Tests estadísticos.
from dataclasses import dataclass               # Contenedores de datos inmutables.


@dataclass
class KSResult:
    """Resultado del test KS para una feature."""
    feature: str                                # Nombre de la feature analizada.
    statistic: float                            # Estadístico KS: 0-1, mayor = más diferencia.
    p_value: float                              # P-value: < 0.05 indica drift significativo.
    is_drift: bool                              # True si se detectó drift.


def ks_test(
    ref: np.ndarray,                            # Datos de referencia (entrenamiento).
    cur: np.ndarray,                            # Datos actuales (producción).
    alpha: float = 0.05,                        # Nivel de significancia (umbral p-value).
) -> KSResult:
    """
    Ejecuta KS-test de dos muestras.
    
    Hipótesis:
    - H0: Ambas muestras provienen de la misma distribución.
    - H1: Las distribuciones son diferentes (hay drift).
    """
    stat, p = stats.ks_2samp(ref, cur)          # Ejecuta test Kolmogorov-Smirnov.
    is_drift = p < alpha                        # Rechaza H0 si p-value < alpha.
    return KSResult(
        feature="feature",                      # Nombre de la feature.
        statistic=round(stat, 4),               # Redondear para legibilidad.
        p_value=round(p, 6),                    # P-value redondeado.
        is_drift=is_drift,                      # Booleano de detección.
    )


# ========== EJEMPLO DE USO ==========
ref = np.random.normal(35, 10, 1000)            # Referencia: edad media=35, std=10.
cur = np.random.normal(45, 12, 500)             # Actual: edad media=45 (DRIFT detectado).
result = ks_test(ref, cur)                      # Ejecutar test.
print(f"KS={result.statistic}, drift={result.is_drift}")  # Output: drift=True
```

### 2.2 PSI (Population Stability Index)

```python
# psi_detector.py
"""Detector de drift con PSI (Population Stability Index)."""

import numpy as np                              # Operaciones numéricas.


def calculate_psi(
    ref: np.ndarray,                            # Datos de referencia (baseline).
    cur: np.ndarray,                            # Datos actuales a comparar.
    bins: int = 10,                             # Número de bins para discretizar.
) -> float:
    """
    Calcula PSI = Σ (P_i - Q_i) × ln(P_i / Q_i)
    
    Interpretación estándar:
    - PSI < 0.1:  Sin cambio significativo.
    - PSI 0.1-0.25: Cambio moderado, investigar.
    - PSI > 0.25: Drift significativo, acción requerida.
    
    Returns:
        Valor PSI (float). Mayor valor = mayor drift.
    """
    # Crear bins uniformes que cubran ambas distribuciones.
    min_val = min(ref.min(), cur.min())         # Mínimo global.
    max_val = max(ref.max(), cur.max())         # Máximo global.
    edges = np.linspace(min_val, max_val, bins + 1)  # Bordes de bins.
    
    # Calcular proporción en cada bin.
    ref_counts = np.histogram(ref, edges)[0]    # Conteos por bin (referencia).
    cur_counts = np.histogram(cur, edges)[0]    # Conteos por bin (actual).
    
    ref_pct = ref_counts / len(ref) + 1e-10     # Proporciones + epsilon (evita log(0)).
    cur_pct = cur_counts / len(cur) + 1e-10     # Proporciones + epsilon.
    
    # Fórmula PSI: suma de (diferencia × log del ratio).
    psi_values = (cur_pct - ref_pct) * np.log(cur_pct / ref_pct)
    return np.sum(psi_values)                   # PSI total.


# ========== EJEMPLO DE USO ==========
psi = calculate_psi(ref, cur)                   # Calcular PSI.
print(f"PSI={psi:.3f} → {'🚨 DRIFT' if psi > 0.25 else '✅ OK'}")
```

---

<a id="3-evidently"></a>

## 3. EvidentlyAI

### Instalación

```bash
pip install evidently
```

### Reporte de Drift

```python
# evidently_report.py
"""Genera reportes de drift con Evidently."""

import pandas as pd                             # DataFrames para datos tabulares.
from evidently.report import Report             # Clase principal de reportes.
from evidently.metric_preset import DataDriftPreset  # Preset con métricas de drift.


def generate_drift_report(
    ref_df: pd.DataFrame,                       # DataFrame de referencia (training).
    cur_df: pd.DataFrame,                       # DataFrame actual (producción).
    path: str,                                  # Path donde guardar el HTML.
) -> None:
    """
    Genera reporte HTML interactivo de drift.
    
    El reporte incluye:
    - Drift por feature (KS-test, PSI).
    - Visualizaciones de distribuciones.
    - Score global de drift del dataset.
    """
    report = Report(metrics=[                   # Crear reporte con preset de drift.
        DataDriftPreset(),                      # Incluye todas las métricas de drift.
    ])
    
    report.run(                                 # Ejecutar análisis.
        reference_data=ref_df,                  # Datos baseline.
        current_data=cur_df,                    # Datos a comparar.
    )
    
    report.save_html(path)                      # Guardar como HTML interactivo.
    print(f"📊 Reporte guardado: {path}")


# ========== EJEMPLO DE USO ==========
# generate_drift_report(train_df, prod_df, "drift_report.html")
```

---

<a id="4-alertas"></a>

## 4. Sistema de Alertas

```python
# alerting.py
"""Sistema de alertas multi-nivel para drift."""

from enum import Enum                           # Enumeraciones para severidades.
from dataclasses import dataclass               # Contenedores de datos.
from typing import List                         # Type hints para listas.
import logging                                  # Sistema de logging estándar.


class Severity(Enum):
    """Niveles de severidad para alertas."""
    INFO = "info"                               # Informativo, no requiere acción.
    WARNING = "warning"                         # Advertencia, investigar.
    CRITICAL = "critical"                       # Crítico, acción inmediata.


@dataclass
class DriftAlert:
    """Representa una alerta de drift."""
    severity: Severity                          # Nivel de severidad.
    features: List[str]                         # Features afectadas.
    drift_score: float                          # Score de drift (0-1).
    message: str                                # Mensaje descriptivo.


class AlertSystem:
    """
    Sistema de alertas para detección de drift.
    
    Clasifica alertas por severidad y las envía
    a los canales configurados (logs, Slack, etc.).
    """
    
    def __init__(self, model_name: str):        # Constructor.
        self.model = model_name                 # Nombre del modelo monitoreado.
        self.logger = logging.getLogger(__name__)  # Logger del módulo.
    
    def trigger(
        self,
        features: List[str],                    # Lista de features con drift.
        score: float,                           # Score de drift promedio.
    ) -> DriftAlert:
        """Dispara alerta basada en score de drift."""
        # Clasificar severidad según umbrales.
        if score >= 0.5:                        # Score alto = crítico.
            sev = Severity.CRITICAL
        elif score >= 0.25:                     # Score medio = warning.
            sev = Severity.WARNING
        else:                                   # Score bajo = info.
            sev = Severity.INFO
        
        # Crear objeto de alerta.
        alert = DriftAlert(
            severity=sev,                       # Severidad calculada.
            features=features,                  # Features afectadas.
            drift_score=score,                  # Score numérico.
            message=f"Drift en {len(features)} features",  # Mensaje.
        )
        
        # Log de la alerta.
        self.logger.warning(f"[{sev.value.upper()}] {alert.message}")
        return alert                            # Retornar para procesamiento adicional.


# ========== EJEMPLO DE USO ==========
system = AlertSystem("BankChurn")               # Crear sistema para modelo BankChurn.
alert = system.trigger(["Age", "Balance"], 0.45)  # Disparar alerta con score 0.45.
```

---

<a id="5-kpis"></a>

## 5. Métricas ML → KPIs de Negocio

### Framework de Mapeo

| Métrica ML | KPI de Negocio | Fórmula |
|------------|----------------|---------|
| **Precision** | $ desperdiciado en retención | FP × costo_retención |
| **Recall** | $ perdido por churn no detectado | FN × valor_cliente |
| **F1-Score** | Balance costo/beneficio | Combinación |
| **Latency** | Experiencia de usuario | P95 < 200ms |

```python
# kpi_calculator.py
"""Mapeo de métricas ML a impacto de negocio."""


def precision_to_cost(
    precision: float,                           # Precision del modelo (0-1).
    preds: int,                                 # Número de predicciones positivas.
    cost_per_fp: float,                         # Costo por falso positivo ($).
) -> float:
    """
    Convierte Precision a costo monetario.
    
    Lógica: Menor precision = más falsos positivos = más costo.
    Ejemplo: Gastar en retención de clientes que no iban a irse.
    """
    fp = preds * (1 - precision)                # Falsos positivos = preds * (1 - precision).
    return fp * cost_per_fp                     # Costo total = FP * costo unitario.


def recall_to_revenue(
    recall: float,                              # Recall del modelo (0-1).
    actual_pos: int,                            # Número real de positivos.
    value_per_fn: float,                        # Valor perdido por falso negativo ($).
) -> float:
    """
    Convierte Recall a revenue perdido.
    
    Lógica: Menor recall = más falsos negativos = más revenue perdido.
    Ejemplo: Clientes que se fueron sin ser detectados.
    """
    fn = actual_pos * (1 - recall)              # Falsos negativos = positivos * (1 - recall).
    return fn * value_per_fn                    # Revenue perdido = FN * valor unitario.


# ========== EJEMPLO: BankChurn ==========
precision, recall = 0.85, 0.70                  # Métricas actuales del modelo.
monthly_preds = 10_000                          # Predicciones positivas al mes.
actual_churners = 2_000                         # Clientes que realmente se fueron.

# Calcular impacto monetario.
wasted = precision_to_cost(precision, monthly_preds, cost_per_fp=50)  # $50 por FP.
lost = recall_to_revenue(recall, actual_churners, value_per_fn=500)   # $500 por FN.

print(f"💰 Costo FP (retención desperdiciada): ${wasted:,.0f}/mes")
print(f"💸 Revenue perdido (churn no detectado): ${lost:,.0f}/mes")
```

---

<a id="55-ingenieria-inversa-drift"></a>

## 5.5 🔬 Ingeniería Inversa Pedagógica: Drift Detection en CI/CD

> **Objetivo**: Entender cómo el portafolio automatiza la detección de drift en GitHub Actions.

### 5.5.1 🎯 El "Por Qué" Arquitectónico

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DECISIONES ARQUITECTÓNICAS DEL PORTAFOLIO                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  PROBLEMA 1: ¿Cómo detecto drift automáticamente sin intervención manual?       │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: Sin automatización, el drift pasa desapercibido por semanas            │
│  DECISIÓN: Workflow de GitHub Actions con schedule diario (cron)                │
│  RESULTADO: Detección proactiva 24/7 sin esfuerzo manual                        │
│  REFERENCIA: drift-detection.yml líneas 4-6                                     │
│                                                                                 │
│  PROBLEMA 2: ¿Cómo notifico al equipo cuando hay drift significativo?           │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: Reportes que nadie lee = drift ignorado                                │
│  DECISIÓN: Crear GitHub Issue automático con labels y acción requerida          │
│  RESULTADO: Issue visible en backlog, asignable, con contexto completo          │
│  REFERENCIA: drift-detection.yml líneas 129-161                                 │
│                                                                                 │
│  PROBLEMA 3: ¿Cómo escalo drift detection a múltiples proyectos?                │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: Un workflow por proyecto = mantenimiento duplicado                     │
│  DECISIÓN: Matrix strategy con lista de proyectos                               │
│  RESULTADO: Un workflow, N proyectos monitoreados                               │
│  REFERENCIA: drift-detection.yml líneas 24-29                                   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 5.5.2 🔍 Anatomía de `drift-detection.yml`

**Archivo**: `ML-MLOps-Portfolio/.github/workflows/drift-detection.yml`

```yaml
# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 1: Triggers - Cuándo ejecutar drift detection
# ═══════════════════════════════════════════════════════════════════════════════
name: Data Drift Detection

on:
  schedule:
    - cron: '0 2 * * *'           # Diario a las 2 AM UTC.
  workflow_dispatch:               # Permite ejecutar manualmente desde UI.
  push:
    branches: [ main ]
    paths:
      - '**/monitoring/drift_detection.py'  # Solo si cambia el script.
# ¿Por qué cron a las 2 AM?
# - Ejecuta cuando hay menos carga en el sistema.
# - Detecta drift acumulado del día anterior.
# - Resultados disponibles al iniciar el día laboral.

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 2: Matrix Strategy para Múltiples Proyectos
# ═══════════════════════════════════════════════════════════════════════════════
jobs:
  drift-detection:
    strategy:
      matrix:
        project:
          - BankChurn-Predictor
          # - CarVision-Market-Intelligence   # Descomentar para añadir.
          # - TelecomAI-Customer-Intelligence
# ¿Por qué matrix?
# - Un workflow, múltiples proyectos.
# - Añadir proyecto = una línea en la lista.
# - Cada proyecto corre en paralelo.

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 3: Ejecución del Script de Drift
# ═══════════════════════════════════════════════════════════════════════════════
    steps:
      - name: Run drift detection
        id: drift
        working-directory: ${{ matrix.project }}
        continue-on-error: true           # NO falla el workflow si hay drift.
        run: |
          python monitoring/drift_detection.py \
            --reference data/raw/Churn.csv \
            --current data/raw/Churn.csv \
            --output-html reports/drift_report_${{ github.run_number }}.html \
            --output-json reports/drift_metrics_${{ github.run_number }}.json \
            --threshold 0.5 \
            --target Exited
# ¿Por qué continue-on-error: true?
# - Drift detectado NO debe bloquear el workflow.
# - Queremos los reportes aunque haya drift.
# - La acción es crear issue, no fallar CI.

# ═══════════════════════════════════════════════════════════════════════════════
# BLOQUE 4: Crear GitHub Issue Automático
# ═══════════════════════════════════════════════════════════════════════════════
      - name: Create GitHub Issue on drift alert
        if: steps.drift.outcome == 'failure'  # Solo si el script detectó drift.
        uses: actions/github-script@v7
        with:
          script: |
            const issue = await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `⚠️ Data Drift Alert: ${{ matrix.project }}`,
              body: `# Data Drift Detected
              
              **Project:** ${{ matrix.project }}
              **Date:** ${new Date().toISOString()}
              
              ## Action Required
              1. Review the drift report in the workflow artifacts
              2. Investigate the cause of drift
              3. Consider retraining the model if needed
              `,
              labels: ['drift-alert', 'monitoring', 'mlops']
            });
# ¿Por qué GitHub Issues y no Slack?
# - Issues son parte del backlog del equipo (visibilidad garantizada).
# - Labels permiten filtrar y priorizar.
# - Historial de incidentes queda documentado en el repo.
```

### 5.5.3 🧪 Laboratorio de Replicación

**Tu misión**: Implementar drift detection automatizado en tu repo.

1. **Crea el script de drift**:
   ```python
   # monitoring/drift_detection.py
   import argparse
   import json
   from pathlib import Path
   import pandas as pd
   from evidently.report import Report
   from evidently.metric_preset import DataDriftPreset
   
   def main():
       parser = argparse.ArgumentParser()
       parser.add_argument("--reference", required=True)
       parser.add_argument("--current", required=True)
       parser.add_argument("--output-json", required=True)
       parser.add_argument("--threshold", type=float, default=0.5)
       args = parser.parse_args()
       
       ref = pd.read_csv(args.reference)
       cur = pd.read_csv(args.current)
       
       report = Report(metrics=[DataDriftPreset()])
       report.run(reference_data=ref, current_data=cur)
       
       # Guardar métricas
       metrics = report.as_dict()
       Path(args.output_json).write_text(json.dumps(metrics))
       
       # Exit code indica si hay drift
       if metrics.get("dataset_drift", False):
           exit(1)  # Drift detectado
       exit(0)  # Sin drift
   
   if __name__ == "__main__":
       main()
   ```

2. **Crea el workflow**:
   ```yaml
   # .github/workflows/drift-detection.yml
   name: Drift Detection
   on:
     schedule:
       - cron: '0 6 * * 1'  # Lunes a las 6 AM
     workflow_dispatch:
   
   jobs:
     check-drift:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-python@v5
           with:
             python-version: '3.11'
         - run: pip install evidently pandas
         - run: python monitoring/drift_detection.py --reference data/train.csv --current data/prod.csv --output-json drift.json
   ```

### 5.5.4 🚨 Troubleshooting Preventivo

| Síntoma | Causa Probable | Solución |
|---------|----------------|----------|
| **Workflow falla antes de drift check** | Dependencias no instaladas | Añade `pip install evidently pandas` antes del script. |
| **Issue no se crea aunque hay drift** | Permisos insuficientes | Añade `permissions: issues: write` al job. |
| **Drift siempre detectado (falso positivo)** | Threshold muy bajo o datos mal alineados | Sube threshold a 0.3-0.5. Verifica que columnas coincidan. |
| **Reportes no se suben como artifact** | Path incorrecto | Usa `${{ matrix.project }}/reports/` no solo `reports/`. |

---

<a id="6-ejercicio"></a>

## 6. Ejercicio Integrador

### "Detectar datos corruptos antes de retrain"

**Escenario**: Pipeline de datos introduce error → Age * 10 (35→350).

**Objetivo**: Detectar drift ANTES de que el modelo se reentrene.

```python
# ejercicio_drift.py
"""Ejercicio: Detectar datos corruptos antes de retrain."""

import numpy as np                              # Operaciones numéricas.
from scipy import stats                         # Tests estadísticos.


# ========== 1. DATOS DE REFERENCIA ==========
np.random.seed(42)                              # Seed para reproducibilidad.
ref_age = np.random.normal(35, 10, 5000)        # Referencia: edad media=35, std=10, n=5000.

# ========== 2. DATOS CORRUPTOS (SIMULAR BUG) ==========
# Escenario: Pipeline de ETL tiene bug que multiplica Age por 10.
corrupt_age = np.random.normal(35, 10, 1000) * 10  # ⚠️ BUG: edades 350 en lugar de 35!

# ========== 3. DETECTAR CON KS-TEST ==========
stat, p = stats.ks_2samp(ref_age, corrupt_age)  # Comparar distribuciones.
print(f"KS-statistic: {stat:.4f}")              # Estadístico (0-1).
print(f"P-value: {p:.2e}")                      # P-value (notación científica).

# ========== 4. TOMAR DECISIÓN ==========
alpha = 0.05                                    # Nivel de significancia.
if p < alpha:                                   # Rechazar H0: distribuciones diferentes.
    print("🚨 ALERTA: Drift detectado - BLOQUEAR RETRAIN")
    # Aquí iría lógica para:
    # - Enviar alerta a Slack/PagerDuty.
    # - Detener pipeline de reentrenamiento.
    # - Crear ticket de investigación.
else:                                           # No rechazar H0: distribuciones similares.
    print("✅ OK para reentrenar")
```

**Entregables**:
- [ ] Script que detecta el drift.
- [ ] Alerta que bloquea pipeline de retrain.
- [ ] Reporte Evidently del incidente.

---

<a id="7-entrevista"></a>

## 7. Preguntas de Entrevista Senior

### Conceptuales

1. **¿Diferencia entre data drift y concept drift?**
2. **¿Cuándo usar KS-test vs PSI?**
3. **¿Cómo detectar concept drift si no tienes labels en producción?**

### Diseño de Sistema

4. **Diseña un sistema de monitoreo para 100 modelos en producción.**
5. **¿Cómo priorizas alertas cuando 10 features muestran drift?**
6. **Trade-off: alertas frecuentes vs missed drifts.**

### Código

7. **Implementa detector de drift con ventana deslizante.**
8. **¿Cómo manejas features categóricas en PSI?**

### Respuestas Clave

**P1**: Data drift = distribución de X cambia. Concept drift = relación X→Y cambia.

**P2**: KS-test para features continuas, PSI para categóricas o cuando necesitas interpretabilidad por bins.

**P3**: Proxy metrics: prediction drift, feature drift, downstream metrics (latency, error rate).

---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **Evidently AI Tutorial** | Evidently | 30 min | [YouTube](https://www.youtube.com/watch?v=L_yQGq3Vqqk) |
| 🟡 | **ML Monitoring in Production** | MLOps Community | 45 min | [YouTube](https://www.youtube.com/watch?v=9BgIDqAzfuA) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [Evidently AI Docs](https://docs.evidentlyai.com/) | Framework de drift detection |
| 🟡 | [Alibi Detect](https://docs.seldon.io/projects/alibi-detect/) | Detección de outliers y drift |

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **Data Drift** | Cambio en la distribución de features de entrada |
| **Concept Drift** | Cambio en la relación entre features y target |
| **KS-test** | Test estadístico para comparar distribuciones |
| **PSI** | Population Stability Index para detectar drift |

---

<div align="center">

**Siguiente módulo** → [21. Cloud FinOps](21_CLOUD_FINOPS.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
