# 03C. Creación de Librerías Compartidas (common_utils)

## 🎯 Objetivo

Aprender a crear y mantener librerías de utilidades compartidas entre proyectos ML, siguiendo el patrón `common_utils/` del Portfolio.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  "DRY (Don't Repeat Yourself) no es solo para código dentro de un proyecto:  ║
║   aplica a toda tu organización. common_utils es DRY a nivel de equipo."     ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Contenido

1. [¿Por qué Librerías Compartidas?](#1-porque)
2. [Estructura de common_utils](#2-estructura)
3. [Módulo de Logging](#3-logging)
4. [Módulo de Reproducibilidad (Seed)](#4-seed)
5. [Patrones de Uso](#5-patrones)
6. [Versionado y Distribución](#6-versionado)
7. [Ejercicio](#7-ejercicio)

---

<a id="1-porque"></a>

## 1. ¿Por qué Librerías Compartidas?

### Problemas que Resuelve

| Problema | Sin common_utils | Con common_utils |
|----------|------------------|------------------|
| **Logging** | Cada proyecto configura diferente | Formato consistente |
| **Seeds** | Olvidar setear todas las librerías | Una función para todo |
| **Config** | Duplicación de código | Validación centralizada |
| **Utils** | Copy-paste entre repos | Import compartido |

### Análisis del Portfolio

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

---

<a id="2-estructura"></a>

## 2. Estructura de common_utils

### Organización Recomendada

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

### __init__.py: API Pública

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

---

<a id="3-logging"></a>

## 3. Módulo de Logging

### Implementación

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


def setup_file_logging(
    name: str,
    log_file: str,
    level: int = logging.INFO,
) -> logging.Logger:
    """
    Configura logging a archivo además de stdout.
    
    Args:
        name: Nombre del logger.
        log_file: Path al archivo de log.
        level: Nivel de logging.
    
    Returns:
        Logger con handlers para stdout y archivo.
    """
    logger = setup_logging(name, level)
    
    # Añadir handler de archivo.
    file_handler = logging.FileHandler(log_file)
    file_handler.setFormatter(
        logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
    )
    
    if file_handler not in logger.handlers:
        logger.addHandler(file_handler)
    
    return logger
```

### Uso en Proyectos

```python
# src/bankchurn/training.py
"""Ejemplo de uso de common_utils.logger."""

from common_utils import setup_logging

# Configurar logger al inicio del módulo.
logger = setup_logging(__name__)


def train_model(X, y, config):
    """Entrena modelo con logging consistente."""
    logger.info(f"Starting training with {len(X)} samples")
    logger.debug(f"Config: {config}")
    
    try:
        # ... entrenamiento ...
        logger.info("Training completed successfully")
    except Exception as e:
        logger.error(f"Training failed: {e}")
        raise
```

---

<a id="4-seed"></a>

## 4. Módulo de Reproducibilidad (Seed)

### Implementación

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


def get_seed_info() -> dict:
    """
    Retorna información sobre el estado actual de seeds.
    
    Útil para debugging y logging de experimentos.
    
    Returns:
        Dict con información de seeds configurados.
    """
    info = {
        "python_hash_seed": os.getenv("PYTHONHASHSEED"),
        "numpy_seed": "configured",
    }
    
    try:
        import torch
        info["torch_seed"] = torch.initial_seed()
        info["cuda_available"] = torch.cuda.is_available()
    except ImportError:
        info["torch"] = "not_installed"
    
    try:
        import tensorflow as tf
        info["tensorflow"] = "configured"
    except ImportError:
        info["tensorflow"] = "not_installed"
    
    return info
```

### Uso en Proyectos

```python
# src/bankchurn/training.py
"""Ejemplo de uso de common_utils.seed."""

from common_utils import set_seed, setup_logging

logger = setup_logging(__name__)


def run_experiment(config):
    """Ejecuta experimento reproducible."""
    # Setear seed al inicio de cada experimento.
    actual_seed = set_seed(config.seed)
    logger.info(f"Experiment seed: {actual_seed}")
    
    # ... resto del experimento ...
```

---

<a id="5-patrones"></a>

## 5. Patrones de Uso

### 5.1 Importación desde Proyecto

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

### 5.2 Configuración en pyproject.toml

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

### 5.3 Patrón de Inicialización

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

---

<a id="6-versionado"></a>

## 6. Versionado y Distribución

### 6.1 Estructura para Publicación

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

### 6.2 pyproject.toml para Distribución

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

### 6.3 Instalación en Proyectos

```bash
# Desde Git (privado)
pip install git+https://github.com/tu-org/common-utils.git

# Desde path local (desarrollo)
pip install -e /path/to/common_utils

# Desde PyPI (si publicas)
pip install mlops-common-utils
```

---

<a id="7-ejercicio"></a>

## 7. Ejercicio Práctico

### Objetivo

Crea tu propio `common_utils` con al menos 3 utilidades.

### Requisitos

1. **Módulo de Config**: Función para cargar YAML con validación.
2. **Módulo de Metrics**: Función para calcular métricas comunes.
3. **Tests**: Al menos 2 tests por módulo.

### Template

```python
# common_utils/config_utils.py
"""Utilidades de configuración."""

import yaml
from pathlib import Path
from typing import Dict, Any


def load_yaml_config(path: Path) -> Dict[str, Any]:
    """
    Carga configuración desde YAML con validación básica.
    
    Args:
        path: Path al archivo YAML.
    
    Returns:
        Dict con la configuración.
    
    Raises:
        FileNotFoundError: Si el archivo no existe.
        yaml.YAMLError: Si el YAML es inválido.
    """
    # TODO: Implementar
    pass


# common_utils/metrics_utils.py
"""Utilidades de métricas ML."""

import numpy as np
from typing import Dict


def calculate_classification_metrics(
    y_true: np.ndarray,
    y_pred: np.ndarray,
) -> Dict[str, float]:
    """
    Calcula métricas estándar de clasificación.
    
    Args:
        y_true: Labels verdaderos.
        y_pred: Predicciones.
    
    Returns:
        Dict con accuracy, precision, recall, f1.
    """
    # TODO: Implementar
    pass
```

### Entregables

- [ ] `common_utils/` con 3 módulos.
- [ ] `__init__.py` con exports.
- [ ] Tests para cada módulo.
- [ ] README documentando uso.

---

## 📚 Recursos

- [Python Packaging Guide](https://packaging.python.org/)
- [Logging HOWTO](https://docs.python.org/3/howto/logging.html)
- [Reproducibility in ML](https://pytorch.org/docs/stable/notes/randomness.html)

---

**Siguiente**: [04_ENTORNOS.md](04_ENTORNOS.md)
