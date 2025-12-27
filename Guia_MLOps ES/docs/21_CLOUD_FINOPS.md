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

from dataclasses import dataclass
from typing import Dict
from enum import Enum


class InstanceType(Enum):
    """Tipos de instancia comunes para ML."""
    # CPU
    CPU_SMALL = "t3.medium"      # 2 vCPU, 4GB - $0.0416/hr
    CPU_LARGE = "c5.2xlarge"     # 8 vCPU, 16GB - $0.34/hr
    
    # GPU
    GPU_T4 = "g4dn.xlarge"       # 1x T4, 4 vCPU - $0.526/hr
    GPU_V100 = "p3.2xlarge"      # 1x V100, 8 vCPU - $3.06/hr
    GPU_A100 = "p4d.24xlarge"    # 8x A100, 96 vCPU - $32.77/hr


# Precios por hora (AWS us-east-1, On-Demand).
HOURLY_PRICES: Dict[str, float] = {
    "t3.medium": 0.0416,
    "c5.2xlarge": 0.34,
    "g4dn.xlarge": 0.526,
    "p3.2xlarge": 3.06,
    "p4d.24xlarge": 32.77,
}

# Descuento Spot (típicamente 60-90% off).
SPOT_DISCOUNT = 0.70  # 70% descuento.


@dataclass
class TrainingJob:
    """Representa un job de entrenamiento."""
    name: str
    instance_type: str
    hours: float
    runs_per_month: int = 1


@dataclass
class InferenceEndpoint:
    """Representa un endpoint de inferencia."""
    name: str
    instance_type: str
    instances: int
    hours_per_day: float = 24.0


def calculate_training_cost(
    job: TrainingJob,
    use_spot: bool = False,
) -> Dict[str, float]:
    """
    Calcula costo mensual de entrenamiento.
    
    Args:
        job: Configuración del job.
        use_spot: Si usar instancias Spot.
    
    Returns:
        Dict con costos desglosados.
    """
    base_price = HOURLY_PRICES.get(job.instance_type, 0.5)
    
    if use_spot:
        effective_price = base_price * (1 - SPOT_DISCOUNT)
    else:
        effective_price = base_price
    
    monthly_cost = effective_price * job.hours * job.runs_per_month
    
    return {
        "job_name": job.name,
        "instance": job.instance_type,
        "hourly_rate": round(effective_price, 4),
        "hours_per_run": job.hours,
        "runs_per_month": job.runs_per_month,
        "monthly_cost_usd": round(monthly_cost, 2),
        "using_spot": use_spot,
    }


def calculate_inference_cost(
    endpoint: InferenceEndpoint,
    days_per_month: int = 30,
) -> Dict[str, float]:
    """
    Calcula costo mensual de inferencia.
    
    Args:
        endpoint: Configuración del endpoint.
        days_per_month: Días de operación.
    
    Returns:
        Dict con costos desglosados.
    """
    base_price = HOURLY_PRICES.get(endpoint.instance_type, 0.5)
    
    hours_per_month = endpoint.hours_per_day * days_per_month
    monthly_cost = base_price * endpoint.instances * hours_per_month
    
    return {
        "endpoint_name": endpoint.name,
        "instance": endpoint.instance_type,
        "instances": endpoint.instances,
        "hours_per_day": endpoint.hours_per_day,
        "monthly_cost_usd": round(monthly_cost, 2),
    }


# Ejemplo: Calcular costos del Portfolio.
if __name__ == "__main__":
    # Training jobs.
    jobs = [
        TrainingJob("BankChurn-Train", "g4dn.xlarge", hours=2, runs_per_month=4),
        TrainingJob("CarVision-Train", "p3.2xlarge", hours=8, runs_per_month=2),
        TrainingJob("TelecomAI-Train", "c5.2xlarge", hours=1, runs_per_month=8),
    ]
    
    # Inference endpoints.
    endpoints = [
        InferenceEndpoint("BankChurn-API", "t3.medium", instances=2),
        InferenceEndpoint("CarVision-API", "g4dn.xlarge", instances=1, hours_per_day=12),
    ]
    
    print("=" * 60)
    print("COSTOS DE TRAINING (mensual)")
    print("=" * 60)
    
    total_training = 0
    for job in jobs:
        # Comparar On-Demand vs Spot.
        od = calculate_training_cost(job, use_spot=False)
        spot = calculate_training_cost(job, use_spot=True)
        savings = od["monthly_cost_usd"] - spot["monthly_cost_usd"]
        
        print(f"\n{job.name}:")
        print(f"  On-Demand: ${od['monthly_cost_usd']:.2f}/mes")
        print(f"  Spot:      ${spot['monthly_cost_usd']:.2f}/mes")
        print(f"  Ahorro:    ${savings:.2f}/mes ({SPOT_DISCOUNT*100:.0f}%)")
        
        total_training += spot["monthly_cost_usd"]
    
    print("\n" + "=" * 60)
    print("COSTOS DE INFERENCE (mensual)")
    print("=" * 60)
    
    total_inference = 0
    for ep in endpoints:
        cost = calculate_inference_cost(ep)
        print(f"\n{ep.name}:")
        print(f"  Instancias: {cost['instances']}x {cost['instance']}")
        print(f"  Horas/día:  {cost['hours_per_day']}")
        print(f"  Costo:      ${cost['monthly_cost_usd']:.2f}/mes")
        
        total_inference += cost["monthly_cost_usd"]
    
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

import os
import json
import signal
from pathlib import Path
from datetime import datetime
from typing import Optional, Dict, Any
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class SpotInterruptionHandler:
    """
    Maneja interrupciones de instancias Spot.
    
    AWS envía señal 2 minutos antes de terminar Spot.
    Este handler guarda checkpoint y termina gracefully.
    """
    
    def __init__(self, checkpoint_dir: str = "checkpoints"):
        self.checkpoint_dir = Path(checkpoint_dir)
        self.checkpoint_dir.mkdir(exist_ok=True)
        self.interrupted = False
        
        # Registrar handlers de señales.
        signal.signal(signal.SIGTERM, self._handle_sigterm)
        signal.signal(signal.SIGINT, self._handle_sigterm)
    
    def _handle_sigterm(self, signum, frame):
        """Handler para SIGTERM (señal de interrupción Spot)."""
        logger.warning("⚠️ Spot interruption detected! Saving checkpoint...")
        self.interrupted = True
    
    def save_checkpoint(
        self,
        epoch: int,
        model_state: Dict[str, Any],
        optimizer_state: Dict[str, Any],
        metrics: Dict[str, float],
    ) -> str:
        """
        Guarda checkpoint del entrenamiento.
        
        Args:
            epoch: Época actual.
            model_state: Estado del modelo (state_dict).
            optimizer_state: Estado del optimizador.
            metrics: Métricas actuales.
        
        Returns:
            Path al checkpoint guardado.
        """
        checkpoint = {
            "epoch": epoch,
            "model_state": model_state,
            "optimizer_state": optimizer_state,
            "metrics": metrics,
            "timestamp": datetime.now().isoformat(),
        }
        
        path = self.checkpoint_dir / f"checkpoint_epoch_{epoch}.json"
        
        # En producción, usarías torch.save() o joblib.
        with open(path, "w") as f:
            json.dump(checkpoint, f, indent=2, default=str)
        
        logger.info(f"✅ Checkpoint saved: {path}")
        return str(path)
    
    def load_latest_checkpoint(self) -> Optional[Dict[str, Any]]:
        """Carga el checkpoint más reciente."""
        checkpoints = sorted(self.checkpoint_dir.glob("checkpoint_*.json"))
        
        if not checkpoints:
            logger.info("No checkpoints found, starting fresh")
            return None
        
        latest = checkpoints[-1]
        logger.info(f"📂 Loading checkpoint: {latest}")
        
        with open(latest) as f:
            return json.load(f)
    
    def should_stop(self) -> bool:
        """Retorna True si se detectó interrupción."""
        return self.interrupted


def train_with_spot_support(
    model,
    train_data,
    epochs: int = 100,
    checkpoint_every: int = 5,
):
    """
    Entrenamiento con soporte para Spot instances.
    
    Features:
    - Resume automático desde checkpoint.
    - Guardado periódico.
    - Graceful shutdown en interrupción.
    """
    handler = SpotInterruptionHandler()
    
    # Intentar resumir desde checkpoint.
    checkpoint = handler.load_latest_checkpoint()
    start_epoch = checkpoint["epoch"] + 1 if checkpoint else 0
    
    if checkpoint:
        # Restaurar estado (pseudo-código).
        # model.load_state_dict(checkpoint["model_state"])
        logger.info(f"Resuming from epoch {start_epoch}")
    
    for epoch in range(start_epoch, epochs):
        # Verificar interrupción antes de cada época.
        if handler.should_stop():
            logger.warning("Stopping due to Spot interruption")
            handler.save_checkpoint(
                epoch=epoch,
                model_state={"weights": "..."},
                optimizer_state={"lr": 0.001},
                metrics={"loss": 0.5},
            )
            break
        
        # Training loop (pseudo-código).
        logger.info(f"Training epoch {epoch}/{epochs}")
        # loss = train_one_epoch(model, train_data)
        
        # Checkpoint periódico.
        if epoch % checkpoint_every == 0:
            handler.save_checkpoint(
                epoch=epoch,
                model_state={"weights": "..."},
                optimizer_state={"lr": 0.001},
                metrics={"loss": 0.5},
            )
    
    logger.info("Training completed!")
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

from dataclasses import dataclass
from typing import Tuple
import logging

logger = logging.getLogger(__name__)


@dataclass
class ScalingConfig:
    """Configuración de scaling."""
    min_replicas: int = 2
    max_replicas: int = 10
    target_latency_p95_ms: float = 200.0    # Target: P95 < 200ms.
    max_cost_per_hour: float = 10.0          # Budget: $10/hr máx.
    cost_per_replica_hour: float = 0.50      # $0.50/replica/hr.


class CostAwareScaler:
    """
    Scaler que optimiza costo vs latencia.
    
    Algoritmo:
    1. Si latency > target → scale up (prioridad).
    2. Si cost > budget → scale down (si latency OK).
    3. Si ambos OK → mantener.
    """
    
    def __init__(self, config: ScalingConfig):
        self.config = config
        self.current_replicas = config.min_replicas
    
    def calculate_decision(
        self,
        current_latency_p95: float,
        current_replicas: int,
    ) -> Tuple[str, int]:
        """
        Decide acción de scaling.
        
        Args:
            current_latency_p95: Latencia P95 actual (ms).
            current_replicas: Réplicas actuales.
        
        Returns:
            Tuple de (acción, nuevas_réplicas).
        """
        current_cost = current_replicas * self.config.cost_per_replica_hour
        
        # Caso 1: Latencia muy alta → SCALE UP.
        if current_latency_p95 > self.config.target_latency_p95_ms * 1.5:
            new_replicas = min(
                current_replicas + 2,
                self.config.max_replicas
            )
            return ("SCALE_UP_URGENT", new_replicas)
        
        # Caso 2: Latencia alta → SCALE UP gradual.
        if current_latency_p95 > self.config.target_latency_p95_ms:
            new_replicas = min(
                current_replicas + 1,
                self.config.max_replicas
            )
            return ("SCALE_UP", new_replicas)
        
        # Caso 3: Latencia OK pero costo alto → SCALE DOWN.
        if (current_cost > self.config.max_cost_per_hour and 
            current_latency_p95 < self.config.target_latency_p95_ms * 0.7):
            new_replicas = max(
                current_replicas - 1,
                self.config.min_replicas
            )
            return ("SCALE_DOWN_COST", new_replicas)
        
        # Caso 4: Todo OK → mantener.
        return ("HOLD", current_replicas)
    
    def log_decision(
        self,
        action: str,
        old_replicas: int,
        new_replicas: int,
        latency: float,
        cost: float,
    ):
        """Log la decisión de scaling."""
        logger.info(
            f"Scaling: {action} | "
            f"Replicas: {old_replicas}→{new_replicas} | "
            f"Latency P95: {latency:.0f}ms | "
            f"Cost: ${cost:.2f}/hr"
        )


# Ejemplo de uso.
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    
    config = ScalingConfig(
        min_replicas=2,
        max_replicas=10,
        target_latency_p95_ms=200,
        max_cost_per_hour=5.0,
        cost_per_replica_hour=0.50,
    )
    
    scaler = CostAwareScaler(config)
    
    # Simular escenarios.
    scenarios = [
        (150, 2),   # Latencia OK, pocas réplicas.
        (250, 2),   # Latencia alta, pocas réplicas.
        (350, 3),   # Latencia muy alta.
        (120, 8),   # Latencia baja, muchas réplicas (caro).
    ]
    
    for latency, replicas in scenarios:
        action, new_replicas = scaler.calculate_decision(latency, replicas)
        cost = replicas * config.cost_per_replica_hour
        scaler.log_decision(action, replicas, new_replicas, latency, cost)
```

---

<a id="5-tco"></a>

## 5. Cálculo de TCO (Total Cost of Ownership)

### 5.1 Framework de TCO

```python
# tco_calculator.py
"""Calculadora de TCO para arquitecturas MLOps."""

from dataclasses import dataclass, field
from typing import List, Dict
from enum import Enum


class CostCategory(Enum):
    COMPUTE = "compute"
    STORAGE = "storage"
    NETWORK = "network"
    SERVICES = "managed_services"
    LABOR = "labor"


@dataclass
class CostItem:
    """Item de costo individual."""
    name: str
    category: CostCategory
    monthly_cost: float
    notes: str = ""


@dataclass
class TCOAnalysis:
    """Análisis completo de TCO."""
    project_name: str
    items: List[CostItem] = field(default_factory=list)
    
    def add_item(self, item: CostItem):
        self.items.append(item)
    
    def total_monthly(self) -> float:
        return sum(i.monthly_cost for i in self.items)
    
    def total_annual(self) -> float:
        return self.total_monthly() * 12
    
    def by_category(self) -> Dict[str, float]:
        result = {}
        for item in self.items:
            cat = item.category.value
            result[cat] = result.get(cat, 0) + item.monthly_cost
        return result
    
    def generate_report(self) -> str:
        """Genera reporte de TCO."""
        lines = [
            "=" * 60,
            f"TCO ANALYSIS: {self.project_name}",
            "=" * 60,
            "",
            "DESGLOSE POR CATEGORÍA:",
            "-" * 40,
        ]
        
        by_cat = self.by_category()
        for cat, cost in sorted(by_cat.items(), key=lambda x: -x[1]):
            pct = (cost / self.total_monthly()) * 100
            lines.append(f"  {cat:20} ${cost:>10,.2f} ({pct:>5.1f}%)")
        
        lines.extend([
            "",
            "-" * 40,
            f"  TOTAL MENSUAL:      ${self.total_monthly():>10,.2f}",
            f"  TOTAL ANUAL:        ${self.total_annual():>10,.2f}",
            "=" * 60,
        ])
        
        return "\n".join(lines)


def calculate_portfolio_tco() -> TCOAnalysis:
    """Calcula TCO del Portfolio MLOps."""
    tco = TCOAnalysis("ML-MLOps-Portfolio")
    
    # COMPUTE.
    tco.add_item(CostItem(
        "BankChurn Training (Spot)",
        CostCategory.COMPUTE,
        monthly_cost=15.80,
        notes="g4dn.xlarge, 2hr/run, 4 runs/month, 70% Spot discount"
    ))
    tco.add_item(CostItem(
        "CarVision Training (Spot)",
        CostCategory.COMPUTE,
        monthly_cost=14.69,
        notes="p3.2xlarge, 8hr/run, 2 runs/month, 70% Spot discount"
    ))
    tco.add_item(CostItem(
        "BankChurn API (On-Demand)",
        CostCategory.COMPUTE,
        monthly_cost=59.90,
        notes="2x t3.medium, 24/7"
    ))
    tco.add_item(CostItem(
        "CarVision API (On-Demand)",
        CostCategory.COMPUTE,
        monthly_cost=189.36,
        notes="1x g4dn.xlarge, 12hr/day"
    ))
    
    # STORAGE.
    tco.add_item(CostItem(
        "S3 - Datasets",
        CostCategory.STORAGE,
        monthly_cost=23.00,
        notes="~1TB, S3 Standard"
    ))
    tco.add_item(CostItem(
        "S3 - Model Artifacts",
        CostCategory.STORAGE,
        monthly_cost=5.00,
        notes="~200GB, S3 Standard-IA"
    ))
    tco.add_item(CostItem(
        "ECR - Docker Images",
        CostCategory.STORAGE,
        monthly_cost=10.00,
        notes="~100GB images"
    ))
    
    # NETWORK.
    tco.add_item(CostItem(
        "Data Transfer (Egress)",
        CostCategory.NETWORK,
        monthly_cost=45.00,
        notes="~500GB egress/month"
    ))
    tco.add_item(CostItem(
        "Load Balancer",
        CostCategory.NETWORK,
        monthly_cost=18.00,
        notes="ALB + LCU"
    ))
    
    # MANAGED SERVICES.
    tco.add_item(CostItem(
        "CloudWatch Logs",
        CostCategory.SERVICES,
        monthly_cost=15.00,
        notes="Ingestion + Storage"
    ))
    tco.add_item(CostItem(
        "Secrets Manager",
        CostCategory.SERVICES,
        monthly_cost=2.00,
        notes="~5 secrets"
    ))
    
    return tco


if __name__ == "__main__":
    tco = calculate_portfolio_tco()
    print(tco.generate_report())
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

from dataclasses import dataclass
from typing import List, Tuple


@dataclass
class OptimizationStrategy:
    """Estrategia de optimización."""
    name: str
    current_cost: float
    optimized_cost: float
    implementation: str
    risk: str  # "low", "medium", "high"
    
    @property
    def savings(self) -> float:
        return self.current_cost - self.optimized_cost
    
    @property
    def savings_pct(self) -> float:
        return (self.savings / self.current_cost) * 100


def propose_optimizations() -> List[OptimizationStrategy]:
    """Propone estrategias de optimización."""
    
    return [
        OptimizationStrategy(
            name="Reserved Instances para BankChurn API",
            current_cost=59.90,
            optimized_cost=35.94,  # 40% descuento RI 1yr.
            implementation="Comprar RI 1-year para 2x t3.medium",
            risk="low"
        ),
        OptimizationStrategy(
            name="Apagar CarVision API en noches",
            current_cost=189.36,
            optimized_cost=94.68,  # 12hr → 6hr/día.
            implementation="Schedule: 8am-8pm únicamente",
            risk="medium"
        ),
        OptimizationStrategy(
            name="Migrar datasets antiguos a S3 Glacier",
            current_cost=23.00,
            optimized_cost=8.00,
            implementation="Lifecycle policy: 30 días → Glacier",
            risk="low"
        ),
        OptimizationStrategy(
            name="Right-size BankChurn API",
            current_cost=59.90,
            optimized_cost=29.95,  # t3.medium → t3.small.
            implementation="Reducir a t3.small (validar latencia)",
            risk="medium"
        ),
    ]


def calculate_optimized_tco(strategies: List[OptimizationStrategy]) -> Tuple[float, float]:
    """
    Calcula TCO optimizado.
    
    Returns:
        Tuple de (total_savings, new_tco).
    """
    current_tco = 397.75  # TCO actual.
    total_savings = sum(s.savings for s in strategies)
    new_tco = current_tco - total_savings
    
    return total_savings, new_tco


if __name__ == "__main__":
    strategies = propose_optimizations()
    
    print("=" * 60)
    print("PLAN DE OPTIMIZACIÓN DE TCO")
    print("=" * 60)
    
    for s in strategies:
        print(f"\n📌 {s.name}")
        print(f"   Actual:     ${s.current_cost:.2f}/mes")
        print(f"   Optimizado: ${s.optimized_cost:.2f}/mes")
        print(f"   Ahorro:     ${s.savings:.2f}/mes ({s.savings_pct:.0f}%)")
        print(f"   Riesgo:     {s.risk}")
        print(f"   Cómo:       {s.implementation}")
    
    savings, new_tco = calculate_optimized_tco(strategies)
    reduction_pct = (savings / 397.75) * 100
    
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
