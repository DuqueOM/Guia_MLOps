# 21. Cloud FinOps y Estrategia de Costos ML

## 🎯 Objetivo

Dominar la gestión de costos cloud para cargas de trabajo ML, incluyendo estrategias de Spot/On-Demand, auto-scaling inteligente y cálculo de TCO.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  "El mejor modelo no es el más preciso, sino el que genera más ROI          ║
║   considerando costos de entrenamiento, inferencia e infraestructura."      ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Contenido

1. [Fundamentos de FinOps](#1-fundamentos)
2. [Costos en ML: Training vs Inference](#2-training-inference)
3. [Estrategias Spot vs On-Demand](#3-spot-ondemand)
4. [Auto-scaling Inteligente](#4-autoscaling)
5. [Cálculo de TCO](#5-tco)
6. [Ejercicio: Reducir 30% el TCO](#6-ejercicio)
7. [Preguntas de Entrevista Senior](#7-entrevista)

---

<a id="1-fundamentos"></a>

## 1. Fundamentos de FinOps

### ¿Qué es FinOps?

**FinOps** = Financial Operations para Cloud. Práctica de gestionar costos cloud con la misma rigurosidad que el código.

### Principios Clave

| Principio | Descripción | Aplicación ML |
|-----------|-------------|---------------|
| **Visibility** | Ver todos los costos | Tags por proyecto/modelo |
| **Optimization** | Reducir desperdicio | Right-sizing de instancias |
| **Governance** | Políticas y límites | Budgets y alertas |

### Estructura de Costos ML

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DISTRIBUCIÓN TÍPICA DE COSTOS ML                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TRAINING (30-50% del costo total)                                         │
│  ├── Compute (GPU/CPU)................ 70%                                 │
│  ├── Storage (datasets)............... 20%                                 │
│  └── Networking....................... 10%                                 │
│                                                                             │
│  INFERENCE (40-60% del costo total)                                        │
│  ├── Compute (API servers)............ 60%                                 │
│  ├── Load Balancer.................... 15%                                 │
│  ├── Storage (model artifacts)........ 15%                                 │
│  └── Networking (egress).............. 10%                                 │
│                                                                             │
│  SUPPORTING (10-20% del costo total)                                       │
│  ├── MLflow/Experiment Tracking....... 30%                                 │
│  ├── Monitoring/Logging............... 40%                                 │
│  └── CI/CD............................ 30%                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

<a id="2-training-inference"></a>

## 2. Costos: Training vs Inference

### 2.1 Calculadora de Costos

```python
# cost_calculator.py
"""Calculadora de costos ML para AWS/GCP/Azure."""

from dataclasses import dataclass                   # Contenedores de datos inmutables.
from typing import Dict                             # Type hints para diccionarios.
from enum import Enum                               # Enumeraciones tipadas.


class InstanceType(Enum):
    """
    Tipos de instancia comunes para ML.
    
    Valores incluyen specs y precio/hora On-Demand.
    """
    # CPU - Para inferencia ligera y preprocesamiento.
    CPU_SMALL = "t3.medium"                         # 2 vCPU, 4GB RAM - $0.0416/hr.
    CPU_LARGE = "c5.2xlarge"                        # 8 vCPU, 16GB RAM - $0.34/hr.
    
    # GPU - Para entrenamiento e inferencia de modelos.
    GPU_T4 = "g4dn.xlarge"                          # 1x NVIDIA T4, 4 vCPU - $0.526/hr.
    GPU_V100 = "p3.2xlarge"                         # 1x NVIDIA V100, 8 vCPU - $3.06/hr.
    GPU_A100 = "p4d.24xlarge"                       # 8x NVIDIA A100, 96 vCPU - $32.77/hr.


# ========== PRECIOS DE REFERENCIA ==========
# Fuente: AWS us-east-1, On-Demand pricing (2024).
# Nota: Precios cambian frecuentemente, verificar en consola AWS.
HOURLY_PRICES: Dict[str, float] = {
    "t3.medium": 0.0416,                            # Uso general, burstable.
    "c5.2xlarge": 0.34,                             # Compute-optimized.
    "g4dn.xlarge": 0.526,                           # GPU T4 (inference/training ligero).
    "p3.2xlarge": 3.06,                             # GPU V100 (training intensivo).
    "p4d.24xlarge": 32.77,                          # GPU A100 (LLMs, modelos grandes).
}

# Descuento típico de Spot Instances (60-90% off On-Demand).
SPOT_DISCOUNT = 0.70                                # 70% descuento = pagar 30% del precio.


@dataclass
class TrainingJob:
    """
    Representa un job de entrenamiento.
    
    Attributes:
        name: Nombre identificador del job.
        instance_type: Tipo de instancia EC2.
        hours: Duración promedio por ejecución.
        runs_per_month: Frecuencia de ejecución mensual.
    """
    name: str                                       # Ej: "BankChurn-Train".
    instance_type: str                              # Ej: "g4dn.xlarge".
    hours: float                                    # Horas por ejecución.
    runs_per_month: int = 1                         # Ejecuciones mensuales.


@dataclass
class InferenceEndpoint:
    """
    Representa un endpoint de inferencia (API).
    
    Attributes:
        name: Nombre del endpoint.
        instance_type: Tipo de instancia.
        instances: Número de réplicas.
        hours_per_day: Horas de operación diaria.
    """
    name: str                                       # Ej: "BankChurn-API".
    instance_type: str                              # Ej: "t3.medium".
    instances: int                                  # Número de réplicas para HA.
    hours_per_day: float = 24.0                     # 24 = 24/7, 12 = solo día.


def calculate_training_cost(
    job: TrainingJob,                               # Configuración del job.
    use_spot: bool = False,                         # True = usar Spot instances.
) -> Dict[str, float]:
    """
    Calcula costo mensual de entrenamiento.
    
    Returns:
        Dict con desglose: hourly_rate, monthly_cost_usd, etc.
    """
    # Obtener precio base (fallback a $0.5/hr si no existe).
    base_price = HOURLY_PRICES.get(job.instance_type, 0.5)
    
    # Aplicar descuento Spot si corresponde.
    if use_spot:
        effective_price = base_price * (1 - SPOT_DISCOUNT)  # 30% del precio.
    else:
        effective_price = base_price                        # Precio completo.
    
    # Costo mensual = precio/hr × horas/run × runs/mes.
    monthly_cost = effective_price * job.hours * job.runs_per_month
    
    return {
        "job_name": job.name,                       # Identificador.
        "instance": job.instance_type,              # Tipo de instancia.
        "hourly_rate": round(effective_price, 4),   # Precio efectivo/hr.
        "hours_per_run": job.hours,                 # Duración por ejecución.
        "runs_per_month": job.runs_per_month,       # Frecuencia mensual.
        "monthly_cost_usd": round(monthly_cost, 2), # Costo total mensual.
        "using_spot": use_spot,                     # Indicador de Spot.
    }


def calculate_inference_cost(
    endpoint: InferenceEndpoint,                    # Configuración del endpoint.
    days_per_month: int = 30,                       # Días de operación.
) -> Dict[str, float]:
    """
    Calcula costo mensual de inferencia.
    
    Fórmula: precio/hr × instancias × horas/día × días/mes.
    """
    base_price = HOURLY_PRICES.get(endpoint.instance_type, 0.5)
    
    # Calcular horas totales al mes.
    hours_per_month = endpoint.hours_per_day * days_per_month
    
    # Costo = precio × número de instancias × horas totales.
    monthly_cost = base_price * endpoint.instances * hours_per_month
    
    return {
        "endpoint_name": endpoint.name,             # Identificador.
        "instance": endpoint.instance_type,         # Tipo de instancia.
        "instances": endpoint.instances,            # Número de réplicas.
        "hours_per_day": endpoint.hours_per_day,    # Horas de operación.
        "monthly_cost_usd": round(monthly_cost, 2), # Costo mensual.
    }


# ========== EJEMPLO: CALCULAR COSTOS DEL PORTFOLIO ==========
if __name__ == "__main__":
    # Definir jobs de entrenamiento del Portfolio.
    jobs = [
        TrainingJob("BankChurn-Train", "g4dn.xlarge", hours=2, runs_per_month=4),
        TrainingJob("CarVision-Train", "p3.2xlarge", hours=8, runs_per_month=2),
        TrainingJob("TelecomAI-Train", "c5.2xlarge", hours=1, runs_per_month=8),
    ]
    
    # Definir endpoints de inferencia.
    endpoints = [
        InferenceEndpoint("BankChurn-API", "t3.medium", instances=2),  # 24/7.
        InferenceEndpoint("CarVision-API", "g4dn.xlarge", instances=1, hours_per_day=12),  # Solo día.
    ]
    
    # ===== REPORTE DE TRAINING =====
    print("=" * 60)
    print("COSTOS DE TRAINING (mensual)")
    print("=" * 60)
    
    total_training = 0                              # Acumulador.
    for job in jobs:
        # Comparar On-Demand vs Spot para cada job.
        od = calculate_training_cost(job, use_spot=False)   # Precio completo.
        spot = calculate_training_cost(job, use_spot=True)  # Con descuento.
        savings = od["monthly_cost_usd"] - spot["monthly_cost_usd"]  # Ahorro.
        
        print(f"\n{job.name}:")                     # Nombre del job.
        print(f"  On-Demand: ${od['monthly_cost_usd']:.2f}/mes")
        print(f"  Spot:      ${spot['monthly_cost_usd']:.2f}/mes")
        print(f"  Ahorro:    ${savings:.2f}/mes ({SPOT_DISCOUNT*100:.0f}%)")
        
        total_training += spot["monthly_cost_usd"]  # Sumar costo Spot.
    
    # ===== REPORTE DE INFERENCE =====
    print("\n" + "=" * 60)
    print("COSTOS DE INFERENCE (mensual)")
    print("=" * 60)
    
    total_inference = 0                             # Acumulador.
    for ep in endpoints:
        cost = calculate_inference_cost(ep)         # Calcular costo.
        print(f"\n{ep.name}:")
        print(f"  Instancias: {cost['instances']}x {cost['instance']}")
        print(f"  Horas/día:  {cost['hours_per_day']}")
        print(f"  Costo:      ${cost['monthly_cost_usd']:.2f}/mes")
        
        total_inference += cost["monthly_cost_usd"]  # Sumar.
    
    # ===== RESUMEN TOTAL =====
    print("\n" + "=" * 60)
    print(f"TOTAL TRAINING:  ${total_training:.2f}/mes")
    print(f"TOTAL INFERENCE: ${total_inference:.2f}/mes")
    print(f"TOTAL MENSUAL:   ${total_training + total_inference:.2f}/mes")
```

---

<a id="3-spot-ondemand"></a>

## 3. Estrategias Spot vs On-Demand

### Matriz de Decisión

| Caso de Uso | Recomendación | Razón |
|-------------|---------------|-------|
| **Training batch** | ✅ Spot | Tolerante a interrupciones, checkpoints |
| **Hyperparameter tuning** | ✅ Spot | Muchos jobs pequeños, algunos pueden fallar |
| **API de inferencia crítica** | ❌ On-Demand | Disponibilidad 99.9% requerida |
| **API de inferencia no-crítica** | ⚠️ Mixed | Base On-Demand + Spot para picos |
| **Notebooks/Dev** | ✅ Spot | Bajo costo, interrupciones aceptables |

### Implementación con Checkpoints

```python
# spot_training.py
"""Training tolerante a interrupciones con checkpoints."""

import os                                           # Variables de entorno.
import json                                         # Serialización de checkpoints.
import signal                                       # Manejo de señales del SO.
from pathlib import Path                            # Manejo de paths.
from datetime import datetime                       # Timestamps.
from typing import Optional, Dict, Any              # Type hints.
import logging                                      # Sistema de logging.

# Configurar logging básico.
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class SpotInterruptionHandler:
    """
    Maneja interrupciones de instancias Spot de forma graceful.
    
    Funcionamiento:
    1. AWS envía SIGTERM 2 minutos antes de terminar Spot.
    2. Este handler captura la señal.
    3. Guarda checkpoint del estado actual.
    4. Permite que el proceso termine limpiamente.
    
    Uso: Permite resumir entrenamiento desde el último checkpoint.
    """
    
    def __init__(self, checkpoint_dir: str = "checkpoints"):
        """Inicializa el handler de interrupciones."""
        self.checkpoint_dir = Path(checkpoint_dir)  # Directorio de checkpoints.
        self.checkpoint_dir.mkdir(exist_ok=True)    # Crear si no existe.
        self.interrupted = False                    # Flag de interrupción.
        
        # Registrar handlers para señales del sistema operativo.
        signal.signal(signal.SIGTERM, self._handle_sigterm)  # Señal de terminación.
        signal.signal(signal.SIGINT, self._handle_sigterm)   # Ctrl+C.
    
    def _handle_sigterm(self, signum, frame):
        """
        Handler para SIGTERM (señal de interrupción Spot).
        
        Args:
            signum: Número de señal recibida.
            frame: Stack frame actual (no usado).
        """
        logger.warning("⚠️ Spot interruption detected! Saving checkpoint...")
        self.interrupted = True                     # Marcar como interrumpido.
    
    def save_checkpoint(
        self,
        epoch: int,                                 # Época actual del entrenamiento.
        model_state: Dict[str, Any],                # state_dict del modelo.
        optimizer_state: Dict[str, Any],            # state_dict del optimizador.
        metrics: Dict[str, float],                  # Métricas actuales (loss, acc).
    ) -> str:
        """
        Guarda checkpoint del entrenamiento.
        
        Returns:
            Path al archivo de checkpoint guardado.
        """
        # Construir diccionario de checkpoint.
        checkpoint = {
            "epoch": epoch,                         # Para resumir desde aquí.
            "model_state": model_state,             # Pesos del modelo.
            "optimizer_state": optimizer_state,     # Estado del optimizador (momentum, etc).
            "metrics": metrics,                     # Para comparar al resumir.
            "timestamp": datetime.now().isoformat(),  # Cuándo se guardó.
        }
        
        # Nombre de archivo con número de época.
        path = self.checkpoint_dir / f"checkpoint_epoch_{epoch}.json"
        
        # Guardar (en producción usarías torch.save() o joblib).
        with open(path, "w") as f:
            json.dump(checkpoint, f, indent=2, default=str)
        
        logger.info(f"✅ Checkpoint saved: {path}")
        return str(path)
    
    def load_latest_checkpoint(self) -> Optional[Dict[str, Any]]:
        """
        Carga el checkpoint más reciente.
        
        Returns:
            Dict con el checkpoint o None si no existe.
        """
        # Buscar todos los checkpoints ordenados.
        checkpoints = sorted(self.checkpoint_dir.glob("checkpoint_*.json"))
        
        if not checkpoints:                         # No hay checkpoints previos.
            logger.info("No checkpoints found, starting fresh")
            return None
        
        latest = checkpoints[-1]                    # Último (más reciente).
        logger.info(f"📂 Loading checkpoint: {latest}")
        
        with open(latest) as f:
            return json.load(f)                     # Deserializar y retornar.
    
    def should_stop(self) -> bool:
        """Retorna True si se detectó interrupción Spot."""
        return self.interrupted                     # Verificar flag.


def train_with_spot_support(
    model,                                          # Modelo a entrenar.
    train_data,                                     # Datos de entrenamiento.
    epochs: int = 100,                              # Número total de épocas.
    checkpoint_every: int = 5,                      # Guardar cada N épocas.
):
    """
    Entrenamiento con soporte para Spot instances.
    
    Features:
    - Resume automático desde checkpoint.
    - Guardado periódico.
    - Graceful shutdown en interrupción.
    """
    handler = SpotInterruptionHandler()             # Crear handler de interrupciones.
    
    # ===== INTENTAR RESUMIR DESDE CHECKPOINT =====
    checkpoint = handler.load_latest_checkpoint()   # Buscar checkpoint previo.
    start_epoch = checkpoint["epoch"] + 1 if checkpoint else 0  # Época inicial.
    
    if checkpoint:
        # Restaurar estado del modelo (pseudo-código).
        # model.load_state_dict(checkpoint["model_state"])
        # optimizer.load_state_dict(checkpoint["optimizer_state"])
        logger.info(f"Resuming from epoch {start_epoch}")
    
    # ===== LOOP DE ENTRENAMIENTO =====
    for epoch in range(start_epoch, epochs):
        # Verificar interrupción ANTES de cada época.
        if handler.should_stop():                   # Se detectó SIGTERM.
            logger.warning("Stopping due to Spot interruption")
            handler.save_checkpoint(                # Guardar estado actual.
                epoch=epoch,
                model_state={"weights": "..."},
                optimizer_state={"lr": 0.001},
                metrics={"loss": 0.5},
            )
            break                                   # Salir del loop limpiamente.
        
        # Training de una época (pseudo-código).
        logger.info(f"Training epoch {epoch}/{epochs}")
        # loss = train_one_epoch(model, train_data)
        
        # Checkpoint periódico cada N épocas.
        if epoch % checkpoint_every == 0:           # Guardar cada 5 épocas por defecto.
            handler.save_checkpoint(
                epoch=epoch,
                model_state={"weights": "..."},
                optimizer_state={"lr": 0.001},
                metrics={"loss": 0.5},
            )
    
    logger.info("Training completed!")              # Fin del entrenamiento.
```

---

<a id="4-autoscaling"></a>

## 4. Auto-scaling Inteligente

### 4.1 Kubernetes HPA para ML

```yaml
# k8s/hpa-ml-api.yaml
# HPA optimizado para APIs de ML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: bankchurn-api-hpa
  namespace: ml-production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: bankchurn-api
  
  # Rango de réplicas.
  minReplicas: 2          # Mínimo para HA.
  maxReplicas: 10         # Máximo para controlar costos.
  
  # Métricas para escalar.
  metrics:
    # CPU: escalar si > 70%.
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    
    # Memoria: escalar si > 80%.
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
    
    # Custom: requests por segundo (requiere Prometheus).
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: "100"
  
  # Comportamiento de escalado.
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300   # 5 min antes de bajar.
      policies:
        - type: Percent
          value: 10                     # Bajar máx 10% por vez.
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0     # Escalar inmediato.
      policies:
        - type: Percent
          value: 100                    # Duplicar si necesario.
          periodSeconds: 15
        - type: Pods
          value: 4                      # O +4 pods máximo.
          periodSeconds: 15
      selectPolicy: Max                 # Usar política más agresiva.
```

### 4.2 Scaling Basado en Costo/Latencia

```python
# cost_aware_scaler.py
"""Scaler que balancea costo vs latencia."""

from dataclasses import dataclass                   # Contenedores de datos.
from typing import Tuple                            # Type hints para tuplas.
import logging                                      # Sistema de logging.

logger = logging.getLogger(__name__)                # Logger del módulo.


@dataclass
class ScalingConfig:
    """
    Configuración de scaling.
    
    Define límites y umbrales para el auto-scaler.
    """
    min_replicas: int = 2                           # Mínimo para HA (High Availability).
    max_replicas: int = 10                          # Máximo para controlar costos.
    target_latency_p95_ms: float = 200.0            # SLA: P95 < 200ms.
    max_cost_per_hour: float = 10.0                 # Budget máximo por hora.
    cost_per_replica_hour: float = 0.50             # Costo de cada réplica/hora.


class CostAwareScaler:
    """
    Auto-scaler que optimiza costo vs latencia.
    
    Algoritmo de decisión (en orden de prioridad):
    1. Si latency > target → SCALE UP (prioridad máxima).
    2. Si cost > budget Y latency OK → SCALE DOWN.
    3. Si ambos OK → HOLD (mantener).
    
    Esto prioriza la experiencia del usuario sobre el costo.
    """
    
    def __init__(self, config: ScalingConfig):      # Constructor.
        self.config = config                        # Guardar configuración.
        self.current_replicas = config.min_replicas # Iniciar con mínimo.
    
    def calculate_decision(
        self,
        current_latency_p95: float,                 # Latencia P95 actual (ms).
        current_replicas: int,                      # Número de réplicas actuales.
    ) -> Tuple[str, int]:
        """
        Decide acción de scaling basada en métricas.
        
        Returns:
            Tuple de (nombre_acción, nuevas_réplicas).
        """
        # Calcular costo actual por hora.
        current_cost = current_replicas * self.config.cost_per_replica_hour
        
        # ===== CASO 1: LATENCIA MUY ALTA (>150% del target) =====
        # Prioridad máxima: escalar agresivamente.
        if current_latency_p95 > self.config.target_latency_p95_ms * 1.5:
            new_replicas = min(                     # Agregar 2 réplicas.
                current_replicas + 2,               # +2 réplicas.
                self.config.max_replicas,           # Sin exceder máximo.
            )
            return ("SCALE_UP_URGENT", new_replicas)
        
        # ===== CASO 2: LATENCIA ALTA (>100% del target) =====
        # Escalar gradualmente (+1 réplica).
        if current_latency_p95 > self.config.target_latency_p95_ms:
            new_replicas = min(                     # Agregar 1 réplica.
                current_replicas + 1,               # +1 réplica.
                self.config.max_replicas,           # Sin exceder máximo.
            )
            return ("SCALE_UP", new_replicas)
        
        # ===== CASO 3: COSTO ALTO PERO LATENCIA OK =====
        # Solo bajar si latencia está muy por debajo del target (<70%).
        if (current_cost > self.config.max_cost_per_hour and 
            current_latency_p95 < self.config.target_latency_p95_ms * 0.7):
            new_replicas = max(                     # Quitar 1 réplica.
                current_replicas - 1,               # -1 réplica.
                self.config.min_replicas,           # Sin bajar del mínimo.
            )
            return ("SCALE_DOWN_COST", new_replicas)
        
        # ===== CASO 4: TODO OK =====
        # Mantener configuración actual.
        return ("HOLD", current_replicas)
    
    def log_decision(
        self,
        action: str,                                # Nombre de la acción tomada.
        old_replicas: int,                          # Réplicas antes de la decisión.
        new_replicas: int,                          # Réplicas después.
        latency: float,                             # Latencia que disparó la decisión.
        cost: float,                                # Costo actual por hora.
    ):
        """Log la decisión de scaling para auditoría."""
        logger.info(
            f"Scaling: {action} | "                 # Acción tomada.
            f"Replicas: {old_replicas}→{new_replicas} | "  # Cambio.
            f"Latency P95: {latency:.0f}ms | "      # Métrica de latencia.
            f"Cost: ${cost:.2f}/hr"                 # Costo horario.
        )


# ========== EJEMPLO DE USO ==========
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)         # Configurar logging.
    
    # Crear configuración de scaling.
    config = ScalingConfig(
        min_replicas=2,                             # Mínimo 2 para HA.
        max_replicas=10,                            # Máximo 10 por costos.
        target_latency_p95_ms=200,                  # SLA: P95 < 200ms.
        max_cost_per_hour=5.0,                      # Budget: $5/hr.
        cost_per_replica_hour=0.50,                 # $0.50 por réplica/hr.
    )
    
    scaler = CostAwareScaler(config)                # Crear scaler.
    
    # Simular diferentes escenarios de carga.
    scenarios = [
        (150, 2),                                   # Latencia OK, pocas réplicas → HOLD.
        (250, 2),                                   # Latencia alta, pocas réplicas → SCALE_UP.
        (350, 3),                                   # Latencia muy alta → SCALE_UP_URGENT.
        (120, 8),                                   # Latencia baja, muchas réplicas → SCALE_DOWN.
    ]
    
    # Evaluar cada escenario.
    for latency, replicas in scenarios:
        action, new_replicas = scaler.calculate_decision(latency, replicas)
        cost = replicas * config.cost_per_replica_hour  # Costo actual.
        scaler.log_decision(action, replicas, new_replicas, latency, cost)
```

---

<a id="5-tco"></a>

## 5. Cálculo de TCO (Total Cost of Ownership)

### 5.1 Framework de TCO

```python
# tco_calculator.py
"""Calculadora de TCO (Total Cost of Ownership) para arquitecturas MLOps."""

from dataclasses import dataclass, field            # Contenedores de datos.
from typing import List, Dict                       # Type hints.
from enum import Enum                               # Enumeraciones.


class CostCategory(Enum):
    """
    Categorías de costos cloud.
    
    Permite agrupar y analizar costos por tipo.
    """
    COMPUTE = "compute"                             # EC2, Lambda, EKS, etc.
    STORAGE = "storage"                             # S3, EBS, EFS.
    NETWORK = "network"                             # Data transfer, ALB, NAT.
    SERVICES = "managed_services"                   # CloudWatch, Secrets Manager.
    LABOR = "labor"                                 # Costo de personal (opcional).


@dataclass
class CostItem:
    """
    Item de costo individual.
    
    Representa un recurso o servicio con su costo mensual.
    """
    name: str                                       # Nombre descriptivo.
    category: CostCategory                          # Categoría para agrupación.
    monthly_cost: float                             # Costo mensual en USD.
    notes: str = ""                                 # Notas adicionales (specs, etc).


@dataclass
class TCOAnalysis:
    """
    Análisis completo de TCO.
    
    Agrega múltiples CostItems y genera reportes.
    """
    project_name: str                               # Nombre del proyecto.
    items: List[CostItem] = field(default_factory=list)  # Lista de items.
    
    def add_item(self, item: CostItem):             # Añadir item a la lista.
        """Añade un item de costo al análisis."""
        self.items.append(item)
    
    def total_monthly(self) -> float:               # Sumar todos los costos mensuales.
        """Retorna costo mensual total."""
        return sum(i.monthly_cost for i in self.items)
    
    def total_annual(self) -> float:                # Costo anual = mensual * 12.
        """Retorna costo anual total."""
        return self.total_monthly() * 12
    
    def by_category(self) -> Dict[str, float]:      # Agrupar por categoría.
        """Retorna costos agrupados por categoría."""
        result = {}                                 # Diccionario de resultados.
        for item in self.items:                     # Iterar items.
            cat = item.category.value               # Obtener nombre de categoría.
            result[cat] = result.get(cat, 0) + item.monthly_cost  # Sumar.
        return result
    
    def generate_report(self) -> str:
        """
        Genera reporte de TCO formateado.
        
        Returns:
            String con el reporte completo.
        """
        # Encabezado del reporte.
        lines = [
            "=" * 60,
            f"TCO ANALYSIS: {self.project_name}",
            "=" * 60,
            "",
            "DESGLOSE POR CATEGORÍA:",
            "-" * 40,
        ]
        
        # Desglose por categoría (ordenado por costo descendente).
        by_cat = self.by_category()
        for cat, cost in sorted(by_cat.items(), key=lambda x: -x[1]):
            pct = (cost / self.total_monthly()) * 100  # Porcentaje del total.
            lines.append(f"  {cat:20} ${cost:>10,.2f} ({pct:>5.1f}%)")
        
        # Totales.
        lines.extend([
            "",
            "-" * 40,
            f"  TOTAL MENSUAL:      ${self.total_monthly():>10,.2f}",
            f"  TOTAL ANUAL:        ${self.total_annual():>10,.2f}",
            "=" * 60,
        ])
        
        return "\n".join(lines)                     # Unir líneas con saltos.


def calculate_portfolio_tco() -> TCOAnalysis:
    """
    Calcula TCO del Portfolio MLOps.
    
    Returns:
        TCOAnalysis con todos los costos del portfolio.
    """
    tco = TCOAnalysis("ML-MLOps-Portfolio")         # Crear análisis.
    
    # ========== COMPUTE ==========
    # Training jobs (usando Spot para ahorro).
    tco.add_item(CostItem(
        name="BankChurn Training (Spot)",           # Modelo de churn.
        category=CostCategory.COMPUTE,
        monthly_cost=15.80,                         # $15.80/mes.
        notes="g4dn.xlarge, 2hr/run, 4 runs/month, 70% Spot discount"
    ))
    tco.add_item(CostItem(
        name="CarVision Training (Spot)",           # Modelo de visión.
        category=CostCategory.COMPUTE,
        monthly_cost=14.69,                         # $14.69/mes.
        notes="p3.2xlarge, 8hr/run, 2 runs/month, 70% Spot discount"
    ))
    
    # APIs de inferencia (On-Demand para disponibilidad).
    tco.add_item(CostItem(
        name="BankChurn API (On-Demand)",           # API de predicción.
        category=CostCategory.COMPUTE,
        monthly_cost=59.90,                         # $59.90/mes.
        notes="2x t3.medium, 24/7"                  # 2 réplicas 24/7.
    ))
    tco.add_item(CostItem(
        name="CarVision API (On-Demand)",           # API de imágenes.
        category=CostCategory.COMPUTE,
        monthly_cost=189.36,                        # $189.36/mes.
        notes="1x g4dn.xlarge, 12hr/day"            # Solo horario laboral.
    ))
    
    # ========== STORAGE ==========
    tco.add_item(CostItem(
        name="S3 - Datasets",                       # Datos de entrenamiento.
        category=CostCategory.STORAGE,
        monthly_cost=23.00,                         # $23/mes.
        notes="~1TB, S3 Standard"                   # Tier Standard para acceso frecuente.
    ))
    tco.add_item(CostItem(
        name="S3 - Model Artifacts",                # Modelos guardados.
        category=CostCategory.STORAGE,
        monthly_cost=5.00,                          # $5/mes.
        notes="~200GB, S3 Standard-IA"              # Infrequent Access para artefactos.
    ))
    tco.add_item(CostItem(
        name="ECR - Docker Images",                 # Imágenes Docker.
        category=CostCategory.STORAGE,
        monthly_cost=10.00,                         # $10/mes.
        notes="~100GB images"                       # Imágenes de contenedores.
    ))
    
    # ========== NETWORK ==========
    tco.add_item(CostItem(
        name="Data Transfer (Egress)",              # Tráfico de salida.
        category=CostCategory.NETWORK,
        monthly_cost=45.00,                         # $45/mes.
        notes="~500GB egress/month"                 # Tráfico hacia internet.
    ))
    tco.add_item(CostItem(
        name="Load Balancer",                       # Balanceador de carga.
        category=CostCategory.NETWORK,
        monthly_cost=18.00,                         # $18/mes.
        notes="ALB + LCU"                           # Application Load Balancer.
    ))
    
    # ========== MANAGED SERVICES ==========
    tco.add_item(CostItem(
        name="CloudWatch Logs",                     # Logging centralizado.
        category=CostCategory.SERVICES,
        monthly_cost=15.00,                         # $15/mes.
        notes="Ingestion + Storage"                 # Ingesta y almacenamiento.
    ))
    tco.add_item(CostItem(
        name="Secrets Manager",                     # Gestión de secretos.
        category=CostCategory.SERVICES,
        monthly_cost=2.00,                          # $2/mes.
        notes="~5 secrets"                          # API keys, credenciales.
    ))
    
    return tco                                      # Retornar análisis completo.


# ========== EJEMPLO DE USO ==========
if __name__ == "__main__":
    tco = calculate_portfolio_tco()                 # Calcular TCO.
    print(tco.generate_report())                    # Imprimir reporte.
```

**Output esperado:**
```
============================================================
TCO ANALYSIS: ML-MLOps-Portfolio
============================================================

DESGLOSE POR CATEGORÍA:
----------------------------------------
  compute              $   279.75 (70.5%)
  network              $    63.00 (15.9%)
  storage              $    38.00 ( 9.6%)
  managed_services     $    17.00 ( 4.3%)

----------------------------------------
  TOTAL MENSUAL:      $   397.75
  TOTAL ANUAL:        $ 4,773.00
============================================================
```

---

<a id="6-ejercicio"></a>

## 6. Ejercicio: Reducir TCO en 30%

### Escenario

El Portfolio actual tiene TCO de ~$400/mes. Tu objetivo: **reducir a $280/mes (-30%)**.

### Estrategias a Evaluar

1. **Spot para Training** (ya implementado) - ✅
2. **Reserved Instances para APIs 24/7**
3. **Right-sizing de instancias**
4. **Apagar APIs en horarios de bajo tráfico**
5. **Migrar storage a tiers más baratos**

### Template de Solución

```python
# ejercicio_tco_reduction.py
"""Ejercicio: Reducir TCO del Portfolio en 30%."""

from dataclasses import dataclass                   # Contenedores de datos.
from typing import List, Tuple                      # Type hints.


@dataclass
class OptimizationStrategy:
    """
    Estrategia de optimización de costos.
    
    Representa una oportunidad de reducción con su
    impacto esperado y nivel de riesgo.
    """
    name: str                                       # Nombre descriptivo.
    current_cost: float                             # Costo actual mensual.
    optimized_cost: float                           # Costo después de optimizar.
    implementation: str                             # Cómo implementar.
    risk: str                                       # "low", "medium", "high".
    
    @property
    def savings(self) -> float:                     # Propiedad calculada.
        """Ahorro mensual en USD."""
        return self.current_cost - self.optimized_cost
    
    @property
    def savings_pct(self) -> float:                 # Propiedad calculada.
        """Porcentaje de ahorro."""
        return (self.savings / self.current_cost) * 100


def propose_optimizations() -> List[OptimizationStrategy]:
    """
    Propone estrategias de optimización.
    
    Returns:
        Lista de estrategias ordenadas por impacto.
    """
    return [
        # Estrategia 1: Reserved Instances para APIs 24/7.
        OptimizationStrategy(
            name="Reserved Instances para BankChurn API",
            current_cost=59.90,                     # On-Demand actual.
            optimized_cost=35.94,                   # 40% descuento con RI 1yr.
            implementation="Comprar RI 1-year para 2x t3.medium",
            risk="low"                              # Bajo riesgo: compromiso conocido.
        ),
        # Estrategia 2: Reducir horas de operación.
        OptimizationStrategy(
            name="Apagar CarVision API en noches",
            current_cost=189.36,                    # 12hr/día actual.
            optimized_cost=94.68,                   # Reducir a 6hr/día.
            implementation="Schedule: 8am-8pm únicamente",
            risk="medium"                           # Medio: requiere validar uso nocturno.
        ),
        # Estrategia 3: Storage tiering.
        OptimizationStrategy(
            name="Migrar datasets antiguos a S3 Glacier",
            current_cost=23.00,                     # S3 Standard actual.
            optimized_cost=8.00,                    # Glacier para datos antiguos.
            implementation="Lifecycle policy: 30 días → Glacier",
            risk="low"                              # Bajo: políticas automáticas.
        ),
        # Estrategia 4: Right-sizing.
        OptimizationStrategy(
            name="Right-size BankChurn API",
            current_cost=59.90,                     # t3.medium actual.
            optimized_cost=29.95,                   # t3.small (50% ahorro).
            implementation="Reducir a t3.small (validar latencia)",
            risk="medium"                           # Medio: requiere pruebas de carga.
        ),
    ]


def calculate_optimized_tco(
    strategies: List[OptimizationStrategy],         # Lista de estrategias.
) -> Tuple[float, float]:
    """
    Calcula TCO optimizado aplicando todas las estrategias.
    
    Returns:
        Tuple de (ahorro_total, nuevo_tco).
    """
    current_tco = 397.75                            # TCO actual del portfolio.
    total_savings = sum(s.savings for s in strategies)  # Sumar ahorros.
    new_tco = current_tco - total_savings           # Nuevo TCO.
    
    return total_savings, new_tco


# ========== EJEMPLO DE USO ==========
if __name__ == "__main__":
    strategies = propose_optimizations()            # Obtener estrategias.
    
    # Imprimir encabezado.
    print("=" * 60)
    print("PLAN DE OPTIMIZACIÓN DE TCO")
    print("=" * 60)
    
    # Mostrar cada estrategia.
    for s in strategies:
        print(f"\n📌 {s.name}")                      # Nombre.
        print(f"   Actual:     ${s.current_cost:.2f}/mes")  # Costo actual.
        print(f"   Optimizado: ${s.optimized_cost:.2f}/mes")  # Costo optimizado.
        print(f"   Ahorro:     ${s.savings:.2f}/mes ({s.savings_pct:.0f}%)")  # Ahorro.
        print(f"   Riesgo:     {s.risk}")           # Nivel de riesgo.
        print(f"   Cómo:       {s.implementation}")  # Implementación.
    
    # Calcular totales.
    savings, new_tco = calculate_optimized_tco(strategies)
    reduction_pct = (savings / 397.75) * 100        # Porcentaje de reducción.
    
    # Imprimir resumen.
    print("\n" + "=" * 60)
    print("RESUMEN")
    print("=" * 60)
    print(f"TCO Actual:     ${397.75:.2f}/mes")
    print(f"TCO Optimizado: ${new_tco:.2f}/mes")
    print(f"Ahorro Total:   ${savings:.2f}/mes ({reduction_pct:.0f}%)")
    print(f"Meta (30%):     {'✅ CUMPLIDA' if reduction_pct >= 30 else '❌ NO CUMPLIDA'}")
```

### Entregables

- [ ] Script con estrategias de optimización.
- [ ] Cálculo de nuevo TCO.
- [ ] Plan de implementación con timeline.
- [ ] Análisis de riesgos por estrategia.

---

<a id="7-entrevista"></a>

## 7. Preguntas de Entrevista Senior

### Conceptuales

1. **¿Qué es FinOps y cómo se aplica a ML?**
2. **¿Cuándo usar Spot vs On-Demand vs Reserved?**
3. **¿Cómo calculas el ROI de un modelo ML?**

### Diseño

4. **Diseña un sistema de auto-scaling que balancee costo y latencia.**
5. **¿Cómo implementarías checkpointing para training en Spot?**
6. **¿Cómo reducirías costos de inference sin afectar latencia?**

### Caso Práctico

7. **Tu modelo de churn cuesta $10K/mes en inference. El CFO pide reducir 40%. ¿Qué opciones propones?**

### Respuestas Clave

**P1**: FinOps es la práctica de gestionar costos cloud como código: visibilidad, optimización y governance. En ML: tagging por experimento, right-sizing GPU, Spot para training.

**P2**: 
- **Spot**: Training batch, hyperparameter tuning, dev/test.
- **On-Demand**: APIs críticas, cargas impredecibles.
- **Reserved**: APIs 24/7 con carga estable (40-70% descuento).

**P7**: Opciones:
1. Reserved Instances (-40%).
2. Auto-scaling agresivo en horarios de bajo tráfico.
3. Model distillation (modelo más pequeño).
4. Batch predictions en lugar de real-time donde sea posible.
5. Edge inference para reducir llamadas al cloud.

---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [AWS Cost Optimization](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/) | Well-Architected |
| 🟡 | [FinOps Foundation](https://www.finops.org/) | Comunidad y certificaciones |
| 🟢 | [Spot Instance Advisor](https://aws.amazon.com/ec2/spot/instance-advisor/) | Herramienta AWS |

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **FinOps** | Práctica de gestionar costos cloud como código |
| **TCO** | Total Cost of Ownership - costo total de propiedad |
| **Spot Instance** | Capacidad excedente de cloud a ~70% descuento |
| **Reserved Instance** | Compromiso 1-3 años con 40-70% descuento |

---

<div align="center">

**Siguiente módulo** → [22. IaC Empresarial](22_IAC_EMPRESARIAL.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
