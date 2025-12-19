# 09. Training Profesional

## 🎯 Objetivo del Módulo

Implementar un pipeline de entrenamiento robusto, reproducible y loggeable como `ChurnTrainer` de BankChurn.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  NOTEBOOK TÍPICO:                    CÓDIGO PROFESIONAL:                     ║ 
║  ─────────────────                   ────────────────────                    ║
║  • 500 líneas en un archivo          • Clases modulares                      ║
║  • Variables globales                • Configuración externa                 ║
║  • Sin logging                       • Logging estructurado                  ║
║  • "Funcionó... creo"                • Métricas rastreadas                   ║
║  • Imposible reproducir              • 100% reproducible                     ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### 🧩 Cómo se aplica en este portafolio

- Este módulo se apoya directamente en el código real de **BankChurn-Predictor**:
  - `src/bankchurn/training.py` (`ChurnTrainer`).
  - `configs/config.yaml` (config Pydantic usada en el trainer).
  - Carpeta `artifacts/` donde se guardan `model.joblib` y `training_results.json`.
- También establece el patrón que luego deberás replicar en **CarVision** y **TelecomAI**
  (por ejemplo, implementando tu propio `PriceTrainer` o `TelecomTrainer`) y que se conecta
  con los módulos de **Experiment Tracking** (MLflow) y **CI/CD**.

---

<a id="00-prerrequisitos"></a>

## 0.0 Prerrequisitos

- Haber completado **[07_SKLEARN_PIPELINES](07_SKLEARN_PIPELINES.md)** (pipeline unificado, serialización).
- Tener claro el *target* y el esquema de columnas del dataset.
- Entender el rol de **CV**, split, y seeds para reproducibilidad.

---

<a id="01-protocolo-e-como-estudiar-este-modulo"></a>

## 0.1 🧠 Protocolo E: Cómo estudiar este módulo

- **Antes de entrenar**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define tu *output mínimo* (ej: `Trainer.run()` que deja artefactos + métricas).
- **Durante el debugging**: si te atoras >15 min (splits, CV, métricas raras, MLflow), registra el caso en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
- **Al cerrar la semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para auditar reproducibilidad y trazabilidad (artefactos + logs).

---

<a id="02-entregables-verificables-minimo-viable"></a>

## 0.2 ✅ Entregables verificables (mínimo viable)

Al terminar este módulo, deberías poder mostrar (en al menos 1 proyecto del portafolio):

- [ ] Un `Trainer` con método `run()` que produce **artefactos** en un directorio (`model.joblib`, `training_results.json`).
- [ ] **Reproducibilidad**: misma semilla → métricas consistentes (dentro de ruido razonable).
- [ ] **Logging útil** (split sizes, métricas CV/test, paths de salida).

---

<a id="03-puente-teoria-codigo-portafolio"></a>

## 0.3 🧩 Puente teoría ↔ código (Portafolio)

Para que esto cuente como progreso real, fuerza este mapeo:

- **Concepto**: pipeline de entrenamiento auditable
- **Archivo**: `src/<paquete>/training.py`, `configs/config.yaml`, `artifacts/*`
- **Prueba**: correr `Trainer.run()` dos veces con misma config/seed y comparar outputs.

---

## 📋 Contenido

 - **0.0** [Prerrequisitos](#00-prerrequisitos)
 - **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
 - **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
 - **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
 1. [Arquitectura de una Clase Trainer](#91-arquitectura-de-una-clase-trainer)
 2. [Carga y Validación de Datos](#92-carga-y-validacion-de-datos)
 3. [Cross-Validation Profesional](#93-cross-validation-profesional)
 4. [Gestión de Artefactos](#94-gestion-de-artefactos)
 5. [Logging y Métricas](#95-logging-y-metricas)
 - [Errores habituales](#errores-habituales)
 - [✅ Ejercicio: Implementar tu Trainer](#ejercicio)

---

<a id="91-arquitectura-de-una-clase-trainer"></a>

## 9.1 Arquitectura de una Clase Trainer

### Código Real: ChurnTrainer (BankChurn)

```python
# src/bankchurn/training.py - Estructura REAL del portafolio

from __future__ import annotations

import logging
from pathlib import Path
from typing import Dict, Tuple

import joblib
import mlflow
import numpy as np
import pandas as pd
from sklearn.model_selection import StratifiedKFold, train_test_split
from sklearn.pipeline import Pipeline

from .config import BankChurnConfig

logger = logging.getLogger(__name__)


class ChurnTrainer:
    """Pipeline de entrenamiento para predicción de churn.
    
    Esta clase encapsula TODO el flujo de entrenamiento:
    1. Carga y validación de datos
    2. Preparación de features
    3. Construcción del pipeline
    4. Entrenamiento con cross-validation
    5. Evaluación final
    6. Guardado de artefactos
    
    Parameters
    ----------
    config : BankChurnConfig
        Configuración validada con Pydantic.
    random_state : int, optional
        Semilla para reproducibilidad.
    
    Attributes
    ----------
    model_ : Pipeline
        Pipeline entrenado (disponible después de fit).
    cv_results_ : dict
        Resultados de cross-validation.
    test_results_ : dict
        Resultados en test set.
    
    Examples
    --------
    >>> config = BankChurnConfig.from_yaml("configs/config.yaml")
    >>> trainer = ChurnTrainer(config)
    >>> trainer.run("data/raw/churn.csv", "artifacts/")
    """
    
    def __init__(self, config: BankChurnConfig, random_state: int = None):
        self.config = config
        self.random_state = random_state or config.model.random_state
        
        # Atributos que se llenan durante entrenamiento
        self.model_: Pipeline | None = None
        self.cv_results_: Dict[str, float] | None = None
        self.test_results_: Dict[str, float] | None = None
        
        # Configurar MLflow si está habilitado
        if self.config.mlflow.enabled:
            self._setup_mlflow()
    
    def _setup_mlflow(self) -> None:
        """Configura MLflow tracking."""
        try:
            mlflow.set_tracking_uri(self.config.mlflow.tracking_uri)
            mlflow.set_experiment(self.config.mlflow.experiment_name)
            logger.info(f"MLflow tracking: {self.config.mlflow.tracking_uri}")
        except Exception as e:
            logger.warning(f"MLflow setup failed: {e}")
    
    def run(self, input_path: str | Path, output_dir: str | Path) -> Dict:
        """Ejecuta el pipeline completo de entrenamiento.
        
        Parameters
        ----------
        input_path : str or Path
            Ruta al CSV de entrada.
        output_dir : str or Path
            Directorio para guardar artefactos.
        
        Returns
        -------
        dict
            Resultados de entrenamiento y evaluación.
        """
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info("=" * 60)
        logger.info("INICIANDO ENTRENAMIENTO")
        logger.info("=" * 60)
        
        # 1. Cargar datos
        data = self.load_data(input_path)
        
        # 2. Preparar features
        X, y = self.prepare_features(data)
        
        # 3. Split train/test
        X_train, X_test, y_train, y_test = train_test_split(
            X, y,
            test_size=self.config.model.test_size,
            random_state=self.random_state,
            stratify=y  # Mantener proporción de clases
        )
        logger.info(f"Train: {len(X_train)}, Test: {len(X_test)}")
        
        # 4. Construir pipeline
        self.model_ = self.build_pipeline()
        
        # 5. Cross-validation
        self.cv_results_ = self.cross_validate(X_train, y_train)
        
        # 6. Entrenar modelo final
        self.model_.fit(X_train, y_train)
        
        # 7. Evaluar en test
        self.test_results_ = self.evaluate(X_test, y_test)
        
        # 8. Guardar artefactos
        self.save_artifacts(output_dir)
        
        # 9. Log a MLflow
        if self.config.mlflow.enabled:
            self._log_to_mlflow()
        
        logger.info("=" * 60)
        logger.info("ENTRENAMIENTO COMPLETADO")
        logger.info("=" * 60)
        
        return {
            "cv_results": self.cv_results_,
            "test_results": self.test_results_,
        }
```

### Diagrama del Flujo

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        ChurnTrainer.run() Flow                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌──────────┐             │
│   │ Config  │───►│  Load   │───►│ Prepare │───►│  Split   │             │
│   │  YAML   │    │  Data   │    │Features │    │Train/Test│             │
│   └─────────┘    └─────────┘    └─────────┘    └────┬─────┘             │
│                                                     │                   │
│                                                     ▼                   │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│   │ MLflow  │◄───│  Save   │◄───│Evaluate │◄───│  Train  │              │
│   │  Log    │    │Artifacts│    │ (Test)  │    │ + CV    │              │
│   └─────────┘    └─────────┘    └─────────┘    └─────────┘              │
│                                                                         │
│   OUTPUT:                                                               │
│   • model.joblib (Pipeline completo)                                    │
│   • training_results.json (métricas)                                    │
│   • MLflow run (experimento rastreado)                                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

<a id="92-carga-y-validacion-de-datos"></a>

## 9.2 Carga y Validación de Datos

```python
# Continuación de ChurnTrainer

def load_data(self, input_path: str | Path) -> pd.DataFrame:
    """Carga y valida datos de entrada.
    
    Parameters
    ----------
    input_path : str or Path
        Ruta al archivo CSV.
    
    Returns
    -------
    pd.DataFrame
        Datos cargados y validados.
    
    Raises
    ------
    FileNotFoundError
        Si el archivo no existe.
    ValueError
        Si faltan columnas requeridas.
    """
    input_path = Path(input_path)
    
    if not input_path.exists():
        raise FileNotFoundError(f"Archivo no encontrado: {input_path}")
    
    # Cargar CSV
    data = pd.read_csv(input_path)
    logger.info(f"Datos cargados: {data.shape[0]} filas, {data.shape[1]} columnas")
    
    # Validar columnas requeridas
    required = {self.config.data.target_column}
    required.update(self.config.data.numerical_features)
    required.update(self.config.data.categorical_features)
    
    missing = required - set(data.columns)
    if missing:
        raise ValueError(f"Columnas faltantes: {missing}")
    
    # Log de estadísticas básicas
    target = self.config.data.target_column
    class_dist = data[target].value_counts(normalize=True)
    logger.info(f"Distribución de clases:\n{class_dist}")
    
    # Alertar si hay desbalance severo
    minority_pct = class_dist.min()
    if minority_pct < 0.1:
        logger.warning(f"⚠️ Desbalance severo: clase minoritaria = {minority_pct:.1%}")
    
    return data


def prepare_features(self, data: pd.DataFrame) -> Tuple[pd.DataFrame, pd.Series]:
    """Prepara features y target.
    
    Aplica:
    1. Eliminación de columnas innecesarias (drop_columns)
    2. Separación de X e y
    """
    # Columnas a eliminar
    drop_cols = self.config.data.drop_columns + [self.config.data.target_column]
    drop_cols = [c for c in drop_cols if c in data.columns]
    
    X = data.drop(columns=drop_cols)
    y = data[self.config.data.target_column]
    
    logger.info(f"Features: {X.shape[1]}, Target: {y.name}")
    
    return X, y
```

---

<a id="93-cross-validation-profesional"></a>

## 9.3 Cross-Validation Profesional

```python
def cross_validate(self, X: pd.DataFrame, y: pd.Series) -> Dict[str, float]:
    """Ejecuta cross-validation estratificada.
    
    Stratified K-Fold mantiene la proporción de clases en cada fold,
    crucial para datasets desbalanceados.
    """
    from sklearn.metrics import f1_score, roc_auc_score
    
    cv = StratifiedKFold(
        n_splits=self.config.model.cv_folds,
        shuffle=True,
        random_state=self.random_state
    )
    
    f1_scores = []
    auc_scores = []
    
    logger.info(f"Cross-validation con {self.config.model.cv_folds} folds...")
    
    for fold, (train_idx, val_idx) in enumerate(cv.split(X, y), 1):
        X_train_cv = X.iloc[train_idx]
        X_val_cv = X.iloc[val_idx]
        y_train_cv = y.iloc[train_idx]
        y_val_cv = y.iloc[val_idx]
        
        # Clonar pipeline para este fold
        from sklearn.base import clone
        fold_pipeline = clone(self.model_)
        
        # Entrenar en este fold
        fold_pipeline.fit(X_train_cv, y_train_cv)
        
        # Evaluar
        y_pred = fold_pipeline.predict(X_val_cv)
        y_proba = fold_pipeline.predict_proba(X_val_cv)[:, 1]
        
        f1 = f1_score(y_val_cv, y_pred)
        auc = roc_auc_score(y_val_cv, y_proba)
        
        f1_scores.append(f1)
        auc_scores.append(auc)
        
        logger.info(f"  Fold {fold}: F1={f1:.4f}, AUC={auc:.4f}")
    
    results = {
        "f1_mean": np.mean(f1_scores),
        "f1_std": np.std(f1_scores),
        "auc_mean": np.mean(auc_scores),
        "auc_std": np.std(auc_scores),
    }
    
    logger.info(f"CV Results: F1={results['f1_mean']:.4f} ± {results['f1_std']:.4f}")
    logger.info(f"CV Results: AUC={results['auc_mean']:.4f} ± {results['auc_std']:.4f}")
    
    return results
```

---

<a id="94-gestion-de-artefactos"></a>

## 9.4 Gestión de Artefactos

```python
def save_artifacts(self, output_dir: Path) -> None:
    """Guarda modelo y resultados."""
    import json
    
    # 1. Guardar modelo (pipeline completo)
    model_path = output_dir / "model.joblib"
    joblib.dump(self.model_, model_path)
    logger.info(f"Modelo guardado: {model_path}")
    
    # 2. Guardar resultados como JSON
    results = {
        "cv_results": self.cv_results_,
        "test_results": self.test_results_,
        "config": {
            "model_type": self.config.model.type,
            "test_size": self.config.model.test_size,
            "cv_folds": self.config.model.cv_folds,
            "random_state": self.random_state,
        }
    }
    
    results_path = output_dir / "training_results.json"
    with open(results_path, "w") as f:
        json.dump(results, f, indent=2, default=str)
    logger.info(f"Resultados guardados: {results_path}")


def evaluate(self, X_test: pd.DataFrame, y_test: pd.Series) -> Dict:
    """Evalúa en test set."""
    from sklearn.metrics import (
        accuracy_score, precision_score, recall_score,
        f1_score, roc_auc_score, confusion_matrix
    )
    
    y_pred = self.model_.predict(X_test)
    y_proba = self.model_.predict_proba(X_test)[:, 1]
    
    results = {
        "metrics": {
            "accuracy": accuracy_score(y_test, y_pred),
            "precision": precision_score(y_test, y_pred),
            "recall": recall_score(y_test, y_pred),
            "f1_score": f1_score(y_test, y_pred),
            "roc_auc": roc_auc_score(y_test, y_proba),
        },
        "confusion_matrix": confusion_matrix(y_test, y_pred).tolist(),
    }
    
    logger.info("Test Results:")
    for metric, value in results["metrics"].items():
        logger.info(f"  {metric}: {value:.4f}")
    
    return results
```

---

<a id="95-logging-y-metricas"></a>

## 9.5 Logging y Métricas

### Configurar Logging Profesional

```python
# src/bankchurn/__init__.py o en el módulo principal

import logging
import sys

def setup_logging(level: str = "INFO") -> None:
    """Configura logging estructurado."""
    
    # Formato profesional
    fmt = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
    datefmt = "%Y-%m-%d %H:%M:%S"
    
    logging.basicConfig(
        level=getattr(logging, level.upper()),
        format=fmt,
        datefmt=datefmt,
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler("training.log", mode="a"),
        ]
    )
    
    # Reducir verbosidad de librerías externas
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    logging.getLogger("mlflow").setLevel(logging.WARNING)


# Uso
setup_logging("INFO")
```

### Integración con MLflow

```python
def _log_to_mlflow(self) -> None:
    """Loguea métricas y artefactos a MLflow."""
    with mlflow.start_run(run_name="training"):
        # Parámetros
        mlflow.log_params({
            "model_type": self.config.model.type,
            "test_size": self.config.model.test_size,
            "cv_folds": self.config.model.cv_folds,
            "random_state": self.random_state,
        })
        
        # Métricas de CV
        if self.cv_results_:
            mlflow.log_metrics({
                f"cv_{k}": v for k, v in self.cv_results_.items()
            })
        
        # Métricas de test
        if self.test_results_:
            mlflow.log_metrics({
                f"test_{k}": v 
                for k, v in self.test_results_["metrics"].items()
            })
        
        # Artefactos
        mlflow.log_artifact("artifacts/training_results.json")
        
        logger.info(f"MLflow run logged: {mlflow.active_run().info.run_id}")
```

---

<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en training

En este módulo, casi todos los problemas vienen de **datos mal preparados**, **splits inconsistentes** o **logging incompleto**. Aquí están los patrones más frecuentes.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) `KeyError` o `ValueError` al cargar datos (columnas/config mal alineadas)

**Síntomas típicos**

- `ValueError: Columnas faltantes: {'CreditScore', 'Age', ...}`
- `KeyError: 'Exited'` al intentar acceder al target.

**Cómo identificarlo**

- Compara `self.config.data.*` con las columnas reales del CSV.
- Usa `load_data` como punto único de verdad y revisa sus logs (número de filas/columnas, distribución de clases).

**Cómo corregirlo**

- Ajusta `configs/config.yaml` para que `target_column`, `numerical_features`, `categorical_features` reflejen **exactamente** el dataset.
- Mantén `prepare_features` simple: usar solo `drop_columns` + separación de `X` e `y`.

---

### 2) Resultados no reproducibles (semilla mal gestionada)

**Síntomas típicos**

- Cada ejecución de `ChurnTrainer.run` produce métricas distintas sin razón aparente.

**Cómo identificarlo**

- Revisa la inicialización de `ChurnTrainer` y el uso de `random_state` en:
  - `train_test_split`.
  - `StratifiedKFold`.
  - Modelos base (`RandomForest`, etc.).

**Cómo corregirlo**

- Asegúrate de que la semilla venga de un solo lugar (config) y se pase a todos los componentes relevantes.
- Si usas utilidades como `common_utils.seed.set_seed`, llama a esa función al inicio de `run` o en el CLI.

---

### 3) Cross-validation engañosa (leakage entre folds o CV desalineado con test)

**Síntomas típicos**

- Métricas de CV muy buenas, pero test set mucho peor.
- Folds con distribución de clases muy desigual.

**Cómo identificarlo**

- Verifica que usas `StratifiedKFold` para clasificación desbalanceada.
- Asegúrate de clonar el pipeline (`clone(self.model_)`) en cada fold, no reutilizar el mismo objeto.

**Cómo corregirlo**

- Mantén el orden: definir pipeline completo **antes** de CV y clonar dentro del loop.
- No mezcles datos de test en CV; usa `train_test_split` una sola vez, luego CV solo en `X_train, y_train`.

---

### 4) Artefactos inconsistentes (modelo y métricas que no corresponden)

**Síntomas típicos**

- `training_results.json` y `model.joblib` provienen de ejecuciones distintas.
- MLflow muestra métricas que no coinciden con los artefactos locales.

**Cómo identificarlo**

- Revisa que `save_artifacts` se llama **después** de entrenar el modelo final y evaluar en test.
- Comprueba timestamps y contenido de `artifacts/model.joblib` y `artifacts/training_results.json`.

**Cómo corregirlo**

- Asegura el orden en `run`: CV → `fit` final → `evaluate` → `save_artifacts` → `_log_to_mlflow`.
- No reutilices artefactos viejos; limpia la carpeta `artifacts/` antes de grandes cambios.

---

### 5) MLflow no registra nada o registra en el lugar equivocado

**Síntomas típicos**

- Corres `ChurnTrainer.run` pero no ves runs nuevos en la UI de MLflow.
- Métricas aparecen en otro experimento o en otro tracking URI.

**Cómo identificarlo**

- Imprime/inspecciona `self.config.mlflow.tracking_uri` y `experiment_name`.
- Verifica variables de entorno (`MLFLOW_TRACKING_URI`) si las usas en scripts aparte (`run_mlflow.py`).

**Cómo corregirlo**

- Centraliza la configuración en `BankChurnConfig` y `_setup_mlflow`, evitando `mlflow.set_tracking_uri` dispersos en el código.
- En `run_mlflow.py`, asegúrate de usar el mismo `tracking_uri` y `experiment` que usaste durante el entrenamiento.

---

### Patrón general de debugging para training

1. **Empieza por los datos**: confirma que `load_data` y `prepare_features` producen `X, y` con las formas y columnas esperadas.
2. **Verifica el split**: revisa distribución de clases en `train/test` y en cada fold.
3. **Comprueba los artefactos**: que `model.joblib` y `training_results.json` se regeneren juntos.
4. **Sincroniza con MLflow**: compara métricas locales con lo que ves en la UI.

Con este enfoque, el entrenamiento deja de ser “caja negra” y se convierte en un pipeline controlado y auditable, como se espera en un rol Senior/Staff.

---

<a id="ejercicio"></a>

## ✅ Ejercicio: Implementar tu Trainer

Crea una clase `PriceTrainer` para CarVision siguiendo el patrón:

```python
class PriceTrainer:
    """Tu tarea: implementar siguiendo el patrón de ChurnTrainer."""
    
    def __init__(self, config: dict):
        # TODO: Inicializar atributos
        pass
    
    def run(self, input_path: Path, output_dir: Path) -> dict:
        # TODO: Implementar flujo completo
        pass
    
    def load_data(self, path: Path) -> pd.DataFrame:
        # TODO: Cargar y validar
        pass
    
    def build_pipeline(self) -> Pipeline:
        # TODO: Construir pipeline [features -> pre -> model]
        pass
```

---

## 📦 Cómo se Usó en el Portafolio

El proyecto **BankChurn** implementa el patrón de training profesional completo:

### Clase ChurnTrainer Real

```python
# BankChurn-Predictor/src/bankchurn/trainer.py (estructura)
class ChurnTrainer:
    """Entrenador profesional con CV, MLflow y artefactos."""
    
    def __init__(self, config: BankChurnConfig):
        self.config = config
        self.model_ = None
        self.metrics_ = {}
    
    def run(self, input_path: Path, output_dir: Path) -> dict:
        """Flujo completo: load → split → CV → train → evaluate → save."""
        df = self.load_data(input_path)
        X, y = self.prepare_features(df)
        X_train, X_test, y_train, y_test = self.split_data(X, y)
        
        # Cross-validation
        cv_scores = self.cross_validate(X_train, y_train)
        
        # Entrenamiento final
        self.model_ = self.build_pipeline()
        self.model_.fit(X_train, y_train)
        
        # Evaluación
        self.metrics_ = self.evaluate(X_test, y_test)
        
        # Guardar artefactos
        self.save_artifacts(output_dir)
        
        return self.metrics_
```

### Flujo de Entrenamiento

```
┌───────────────────────────────────────────────────────────────┐
│                    FLUJO DE TRAINING                          │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  load_data → prepare_features → split_data                    │
│      │              │               │                         │
│      ▼              ▼               ▼                         │
│  DataFrame     X, y arrays    train/test split                │
│                                     │                         │
│                    ┌────────────────┴────────────────┐        │
│                    │                                 │        │
│              cross_validate                    build_pipeline │
│                    │                                 │        │
│              cv_scores                          Pipeline      │
│                    │                                 │        │
│                    └────────────────┬────────────────┘        │
│                                     │                         │
│                              model_.fit()                     │
│                                     │                         │
│                              evaluate()                       │
│                                     │                         │
│                           save_artifacts()                    │
│                                     │                         │
│                       pipeline.joblib + metrics.json          │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Archivos de Training por Proyecto

| Proyecto | Trainer | Config | Artefactos |
|----------|---------|--------|------------|
| BankChurn | `src/bankchurn/trainer.py` | `configs/config.yaml` | `artifacts/` |
| CarVision | `main.py` | `configs/config.yaml` | `artifacts/` |
| TelecomAI | `src/telecomai/training.py` | `configs/config.yaml` | `artifacts/` |

### 🔧 Ejercicio: Ejecuta Training Real

```bash
# 1. Ve a BankChurn
cd BankChurn-Predictor

# 2. Entrena el modelo
python main.py --config configs/config.yaml

# 3. Verifica artefactos generados
ls -la artifacts/
cat artifacts/training_results.json

# 4. Verifica MLflow
mlflow ui  # Abre http://localhost:5000
```

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **Cross-Validation**: Explica stratified k-fold, time series split, y cuándo usar cada uno.

2. **Hyperparameter Tuning**: RandomSearch vs GridSearch vs Bayesian (Optuna).

3. **Métricas de negocio**: Traduce métricas técnicas a impacto de negocio.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Clases desbalanceadas | SMOTE, class_weight, o threshold tuning |
| Overfitting | Early stopping, regularización, más datos |
| Modelo en producción | Entrena con todos los datos al final |
| Reproducibilidad | Fija seeds en todos los componentes |

### Pipeline de Training Profesional

```
1. Split estratificado (train/val/test)
2. Feature engineering solo en train
3. Hyperparameter tuning con val
4. Evaluación final en test (una sola vez)
5. Re-entrenamiento con todos los datos
6. Versionado de modelo + métricas
```


---

## 📺 Recursos Externos Recomendados

> Ver [RECURSOS_POR_MODULO.md](RECURSOS_POR_MODULO.md) para la lista completa.

| 🏷️ | Recurso | Tipo |
|:--:|:--------|:-----|
| 🔴 | [Cross-Validation - StatQuest](https://www.youtube.com/watch?v=fSytzGwwBVw) | Video |
| 🟡 | [ML Training Best Practices](https://www.youtube.com/watch?v=uQc5BZw5o_g) | Video |

---

## 🔗 Referencias del Glosario

Ver [21_GLOSARIO.md](21_GLOSARIO.md) para definiciones de:
- **Cross-Validation**: Validación cruzada para evaluar modelos
- **class_weight**: Manejo de clases desbalanceadas
- **Reproducibility**: Resultados repetibles con random_state

---

## ✅ Ejercicios

Ver [EJERCICIOS.md](EJERCICIOS.md) - Módulo 09:
- **9.1**: Implementar Trainer class
- **9.2**: Garantizar reproducibilidad

---

<div align="center">

[← Ingeniería de Features](08_INGENIERIA_FEATURES.md) | [Siguiente: Experiment Tracking →](10_EXPERIMENT_TRACKING.md)

</div>
