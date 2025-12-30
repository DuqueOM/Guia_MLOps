# ════════════════════════════════════════════════════════════════════════════════
# MÓDULO 17: SERVERLESS VS CONTENEDORES
# Cuándo Usar Lambda, ECS o Kubernetes
# Guía MLOps v5.0: Senior Edition | DuqueOM | Noviembre 2025
# ════════════════════════════════════════════════════════════════════════════════

<div align="center">

# 🌐 MÓDULO 17: Serverless vs Contenedores

### La Decisión que Define tu Arquitectura

*"No hay solución universal. Hay trade-offs que debes entender."*

| Duración             | Teoría               | Práctica             |
| :------------------: | :------------------: | :------------------: |
| **4-5 horas**        | 40%                  | 60%                  |

</div>

---

## 📋 Contenido

- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
- **17.1** [Matriz de Decisión](#171-matriz-de-decision)
- **17.2** [Opción 1: Serverless (AWS Lambda)](#172-opcion-1-serverless-aws-lambda)
- **17.3** [Opción 2: Contenedores Managed](#173-opcion-2-contenedores-managed-aws-ecs-gcp-cloud-run)
- **17.4** [Opción 3: Kubernetes](#174-opcion-3-kubernetes)
- **17.5** [Análisis de Costos (FinOps)](#175-analisis-de-costos-finops)
- **17.6** [Decisión para BankChurn](#176-decision-para-bankchurn)
- **17.7** [🔬 Ingeniería Inversa: K8s Ingress Real](#177-ingenieria-inversa-k8s) ⭐ NUEVO
- [Errores habituales](#errores-habituales)
- [✅ Ejercicio](#ejercicio)
- [✅ Checkpoint](#checkpoint)

<a id="00-prerrequisitos"></a>

## 0.0 Prerrequisitos

- Haber completado el módulo 13 (Docker) para entender imágenes, redes y puertos.
- Haber completado el módulo 14 (FastAPI) y contar con un endpoint `/health`.
- Conocer los conceptos de latencia, throughput y costo (FinOps básico).

---

<a id="01-protocolo-e-como-estudiar-este-modulo"></a>

## 0.1 🧠 Protocolo E: Cómo estudiar este módulo

- **Antes de elegir**: define tu escenario (tráfico, latencia, costo y equipo Ops).
- **Durante el estudio**: convierte la teoría en una decisión explícita (ADR) y un deploy mínimo (Cloud Run/ECS o Lambda).
- **Si te atoras >15 min** con puertos, healthchecks, cold starts o tamaño de imagen, registra el caso en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

---

<a id="02-entregables-verificables-minimo-viable"></a>

## 0.2 ✅ Entregables verificables (mínimo viable)

- [ ] ADR (decisión y trade-offs) para tu caso (por ejemplo: MVP en Cloud Run).
- [ ] Deploy funcional (Cloud Run/ECS o Lambda) con `/health` y un endpoint de predicción.
- [ ] Healthcheck verificado en plataforma (readiness/liveness o equivalente).
- [ ] Plan de rollback (documentado y probado al menos una vez).

---

<a id="03-puente-teoria-codigo-portafolio"></a>

## 0.3 🧩 Puente teoría ↔ código (Portafolio)

- **Teoría**: serverless vs contenedores vs Kubernetes
- **Práctica**: Dockerfile + deploy en Cloud Run/ECS + runbooks
- **Prueba**: `curl /health` en el endpoint desplegado + revisión de logs/healthchecks

---

<a id="171-matriz-de-decision"></a>

## 17.1 Matriz de Decisión

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    MATRIZ DE DECISIÓN DE DESPLIEGUE                           ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Factor              │ Lambda/Serverless │ ECS/Cloud Run │ Kubernetes        ║
║   ────────────────────┼───────────────────┼───────────────┼───────────────────║
║   Tráfico             │ < 1M req/mes      │ 1M-100M       │ > 100M            ║
║   Latencia            │ Variable (cold)   │ Consistente   │ Consistente       ║
║   Costo bajo tráfico  │ 💰 Muy bajo       │ 💰💰 Medio    │ 💰💰💰 Alto      ║
║   Costo alto tráfico  │ 💰💰💰 Caro       │ 💰💰 Medio    │ 💰 Barato        ║
║   Complejidad Ops     │ ⭐ Baja           │ ⭐⭐ Media   │ ⭐⭐⭐⭐ Alta  ║
║   Equipo necesario    │ 1 persona         │ 2-3 personas  │ 5+ personas       ║
║   GPU Support         │ ❌                │ ✅           │ ✅               ║
║   Max memoria         │ 10GB              │ 120GB+        │ Ilimitado         ║
║   Max timeout         │ 15 min            │ Ilimitado     │ Ilimitado         ║
║   Modelo size límite  │ ~250MB pkg        │ Sin límite    │ Sin límite        ║
║   Auto-scaling        │ Automático        │ Automático    │ Configurable      ║
║   Vendor lock-in      │ Alto              │ Medio         │ Bajo              ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

<a id="172-opcion-1-serverless-aws-lambda"></a>

## 17.2 Opción 1: Serverless (AWS Lambda)

### Cuándo Usar

```
✅ USA LAMBDA SI:
• Tráfico bajo o esporádico (< 1M requests/mes)
• Modelo pequeño (< 250MB empaquetado)
• Latencia variable es aceptable
• No tienes equipo de DevOps
• Quieres minimizar costos en bajo tráfico

❌ NO USES LAMBDA SI:
• Necesitas GPU
• Modelo > 250MB
• Cold starts son inaceptables (< 100ms requerido)
• Tráfico constante y alto
```

### Estructura para Lambda

```
lambda_function/
├── handler.py          # Entry point
├── model/
│   └── pipeline.pkl    # Modelo (< 250MB)
├── src/
│   └── inference.py    # Lógica
└── requirements.txt
```

### handler.py

```python
# handler.py - AWS Lambda Handler
import json                              # Parse/serialize JSON.
import joblib                            # Cargar modelo sklearn.
import pandas as pd                      # DataFrame para predicción.
from pathlib import Path                 # Rutas multiplataforma.

# Cargar modelo al inicio (fuera del handler para reutilizar)
MODEL_PATH = Path(__file__).parent / "model" / "pipeline.pkl"  # Ruta relativa al handler.
model = joblib.load(MODEL_PATH)          # Se carga UNA vez (warm start reutiliza).

def lambda_handler(event, context):      # Punto de entrada de Lambda. context: metadata del runtime.
    """AWS Lambda handler."""
    try:
        # Parse input - Lambda puede recibir body como string o dict
        if isinstance(event.get("body"), str):  # API Gateway envía body como string.
            body = json.loads(event["body"])    # Deserializa JSON.
        else:
            body = event.get("body", event)     # Invocación directa: body es dict.
        
        # Crear DataFrame
        df = pd.DataFrame([body])               # Lista con 1 elemento → 1 fila.
        
        # Predecir
        proba = model.predict_proba(df)[0, 1]   # [0,1]: fila 0, clase positiva.
        prediction = "churn" if proba >= 0.5 else "no_churn"  # Umbral 0.5.
        
        return {                                # Response format para API Gateway.
            "statusCode": 200,                  # HTTP 200 OK.
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({                # body DEBE ser string JSON.
                "churn_probability": round(proba, 4),
                "prediction": prediction,
            })
        }
    except Exception as e:
        return {
            "statusCode": 500,                  # 500: Internal Server Error.
            "body": json.dumps({"error": str(e)})
        }
```

### serverless.yml (Serverless Framework)

```yaml
# serverless.yml
service: bankchurn-predictor             # Nombre del servicio (prefijo de recursos).

provider:
  name: aws                              # Cloud provider.
  runtime: python3.11                    # Versión de Python.
  region: us-east-1                      # Región de AWS.
  memorySize: 1024                       # MB de RAM (más RAM = más CPU proporcional).
  timeout: 30                            # Timeout en segundos (máx 15 min).

functions:
  predict:                               # Nombre de la función Lambda.
    handler: handler.lambda_handler      # módulo.función a ejecutar.
    events:                              # Triggers que invocan la función.
      - http:                            # API Gateway HTTP trigger.
          path: predict                  # Ruta: /predict
          method: post                   # Método HTTP.
          cors: true                     # Habilita CORS automáticamente.

plugins:
  - serverless-python-requirements      # Plugin para empaquetar deps de Python.

custom:
  pythonRequirements:
    dockerizePip: true                   # Compila deps en Docker (para binarios nativos).
    slim: true                           # Elimina archivos innecesarios (reduce tamaño).
```

---

<a id="173-opcion-2-contenedores-managed-aws-ecs-gcp-cloud-run"></a>

## 17.3 Opción 2: Contenedores Managed (AWS ECS / GCP Cloud Run)

### Cuándo Usar

```
✅ USA ECS/CLOUD RUN SI:
• Tráfico medio-alto (1M-100M requests/mes)
• Necesitas latencia consistente
• Modelo de cualquier tamaño
• Quieres balance entre control y simplicidad
• Equipo pequeño de DevOps (2-3 personas)

❌ NO USES SI:
• Necesitas control granular de networking
• Multi-cloud es requisito
• Tráfico extremadamente alto (> 100M)
```

### AWS ECS Task Definition

```json
{
  "family": "bankchurn-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "api",
      "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/bankchurn:latest",
      "portMappings": [
        {
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "LOG_LEVEL", "value": "INFO"}
      ],
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/bankchurn",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "api"
        }
      }
    }
  ]
}
```

### GCP Cloud Run (más simple)

```bash
# Deploy a Cloud Run
gcloud run deploy bankchurn-api \
  --image gcr.io/my-project/bankchurn:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 1Gi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --port 8000
```

---

<a id="174-opcion-3-kubernetes"></a>

## 17.4 Opción 3: Kubernetes

### Cuándo Usar

```
✅ USA KUBERNETES SI:
• Tráfico muy alto (> 100M requests/mes)
• Múltiples servicios ML que escalan diferente
• Necesitas GPU para inferencia
• Multi-cloud o hybrid cloud
• Equipo de Ops experimentado (5+ personas)
• Ya tienes inversión en K8s

❌ NO USES SI:
• Un solo modelo simple
• Equipo pequeño sin experiencia K8s
• Presupuesto limitado para Ops
```

### Manifiestos Básicos

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bankchurn-api
  labels:
    app: bankchurn-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: bankchurn-api
  template:
    metadata:
      labels:
        app: bankchurn-api
    spec:
      containers:
      - name: api
        image: ghcr.io/username/bankchurn:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 15
          periodSeconds: 10
        env:
        - name: LOG_LEVEL
          value: "INFO"
---
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: bankchurn-api
spec:
  selector:
    app: bankchurn-api
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
---
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: bankchurn-api
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: bankchurn-api
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

---

<a id="175-analisis-de-costos-finops"></a>

## 17.5 Análisis de Costos (FinOps)

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    ANÁLISIS DE COSTOS MENSUAL                                 ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   ESCENARIO: 1M requests/mes, ~1 req/seg promedio                             ║
║                                                                               ║
║   AWS Lambda:                                                                 ║
║   • 1M requests × $0.20/1M = $0.20                                            ║
║   • 1M × 200ms × 1GB = 200K GB-s × $0.0000166 = $3.32                         ║
║   • Total: ~$4/mes ✅ (bajo tráfico es barato)                                ║
║                                                                               ║
║   ECS Fargate:                                                                ║
║   • 0.5 vCPU × 730h × $0.04 = $14.60                                          ║
║   • 1GB RAM × 730h × $0.004 = $2.92                                           ║
║   • Total: ~$18/mes (consistente)                                             ║
║                                                                               ║
║   EKS (3 nodos t3.small):                                                     ║
║   • 3 × $15/mes (EC2) = $45                                                   ║
║   • EKS fee: $72/mes                                                          ║
║   • Total: ~$120/mes (overkill para este volumen)                             ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   ESCENARIO: 100M requests/mes, ~40 req/seg promedio                          ║
║                                                                               ║
║   AWS Lambda:                                                                 ║
║   • 100M × $0.20/1M = $20                                                     ║
║   • 100M × 200ms × 1GB = 20M GB-s × $0.0000166 = $332                         ║
║   • Total: ~$350/mes (ya no tan barato)                                       ║
║                                                                               ║
║   ECS Fargate (auto-scaling):                                                 ║
║   • ~5 tareas promedio                                                        ║
║   • Total: ~$90/mes ✅                                                        ║
║                                                                               ║
║   EKS (auto-scaling):                                                         ║
║   • 5 nodos t3.medium promedio                                                ║
║   • Total: ~$200/mes                                                          ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

<a id="176-decision-para-bankchurn"></a>

## 17.6 Decisión para BankChurn

### Recomendación por Fase

| Fase | Plataforma | Razón |
| :--- | :--------- | :---- |
| **MVP/Desarrollo** | Cloud Run o Lambda | Simplicidad, bajo costo inicial |
| **Producción inicial** | ECS/Cloud Run | Balance costo-control |
| **Escala enterprise** | Kubernetes | Control total, multi-service |

### ADR para BankChurn

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║  ADR-009: Despliegue de BankChurn en Cloud Run                                ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  DECISIÓN: Usar Google Cloud Run para el MVP                                  ║
║                                                                               ║
║  RAZONES:                                                                     ║
║  • Escala a cero cuando no hay tráfico (costo mínimo)                         ║
║  • Sin gestión de infraestructura                                             ║
║  • Latencia consistente (mejor que Lambda para ML)                            ║
║  • Soporta contenedores Docker estándar                                       ║
║  • Fácil migración a GKE si necesario                                         ║
║                                                                               ║
║  TRADE-OFFS ACEPTADOS:                                                        ║
║  • Vendor lock-in medio (GCP)                                                 ║
║  • Menos control que K8s                                                      ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

<a id="177-ingenieria-inversa-k8s"></a>

## 17.7 🔬 Ingeniería Inversa Pedagógica: Kubernetes Ingress Real

> **Objetivo**: Entender CADA decisión detrás del Ingress del portafolio que expone los 3 proyectos ML.

### 17.7.1 🎯 El "Por Qué" Arquitectónico

¿Por qué el portafolio usa Ingress con subdominios en lugar de un solo LoadBalancer por servicio?

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DECISIONES ARQUITECTÓNICAS DEL PORTAFOLIO                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  PROBLEMA 1: ¿Cómo expongo 3 APIs ML al internet sin 3 LoadBalancers?           │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: $15-20/mes por LoadBalancer × 3 = $45-60/mes solo en networking        │
│  DECISIÓN: Un solo Ingress con routing por host/path                            │
│  RESULTADO: Un LoadBalancer, 3 servicios accesibles, ~$15/mes                   │
│  REFERENCIA: ingress.yaml spec.rules (líneas 24-78)                             │
│                                                                                 │
│  PROBLEMA 2: ¿Cómo protejo las APIs con HTTPS sin gestionar certificados?       │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: HTTP en producción = credenciales expuestas, penalización SEO          │
│  DECISIÓN: cert-manager + Let's Encrypt (renovación automática)                 │
│  RESULTADO: TLS gratis, automático, sin intervención manual                     │
│  REFERENCIA: ingress.yaml annotations cert-manager.io (línea 8)                 │
│                                                                                 │
│  PROBLEMA 3: ¿Cómo evito que un atacante sature las APIs con requests?          │
│  ─────────────────────────────────────────────────────────────                  │
│  RIESGO: DDoS, costos inflados, degradación para usuarios legítimos             │
│  DECISIÓN: Rate limiting vía annotations nginx (100 req/s, 10 rps por IP)       │
│  RESULTADO: Protección básica sin WAF externo                                   │
│  REFERENCIA: ingress.yaml annotations rate-limit (líneas 10-11)                 │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 17.7.2 🔍 Anatomía de `ingress.yaml`

**Archivo**: `ML-MLOps-Portfolio/k8s/ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ml-portfolio-ingress
  namespace: ml-portfolio               # Todos los recursos en un namespace.
  annotations:
    # ═══════════════════════════════════════════════════════════════════════════
    # BLOQUE 1: Configuración del Ingress Controller
    # ═══════════════════════════════════════════════════════════════════════════
    kubernetes.io/ingress.class: nginx  # Usa NGINX Ingress Controller.
    # ¿Por qué nginx? Es el estándar, bien documentado, muchas features.
    
    # ═══════════════════════════════════════════════════════════════════════════
    # BLOQUE 2: TLS Automático con Let's Encrypt
    # ═══════════════════════════════════════════════════════════════════════════
    cert-manager.io/cluster-issuer: letsencrypt-prod
    # ¿Cómo funciona?
    # 1. cert-manager detecta esta annotation.
    # 2. Solicita certificado a Let's Encrypt vía ACME challenge.
    # 3. Almacena el certificado en el Secret indicado en spec.tls.
    # 4. Renueva automáticamente antes de expirar (cada 90 días).
    
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    # Fuerza HTTPS: cualquier request HTTP → 301 a HTTPS.
    
    # ═══════════════════════════════════════════════════════════════════════════
    # BLOQUE 3: Rate Limiting (Protección DDoS básica)
    # ═══════════════════════════════════════════════════════════════════════════
    nginx.ingress.kubernetes.io/rate-limit: "100"       # 100 req/s globales.
    nginx.ingress.kubernetes.io/limit-rps: "10"         # 10 req/s por IP.
    # ¿Por qué 10 rps por IP?
    # - Un usuario legítimo no hace 10 predicciones por segundo.
    # - Un scraper/bot sí, y esto lo bloquea.
    
    # ═══════════════════════════════════════════════════════════════════════════
    # BLOQUE 4: Timeouts para ML (inferencia puede ser lenta)
    # ═══════════════════════════════════════════════════════════════════════════
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"  # Max body 10MB (imágenes).
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    # ¿Por qué 60s?
    # - Inferencia de modelos grandes (CarVision con imágenes) puede tardar.
    # - Default de NGINX es 60s, pero lo hacemos explícito.

spec:
  # ═══════════════════════════════════════════════════════════════════════════
  # BLOQUE 5: Certificados TLS
  # ═══════════════════════════════════════════════════════════════════════════
  tls:
  - hosts:
    - ml.duqueom.com                    # Dominio principal.
    - bankchurn.ml.duqueom.com          # Subdominio por proyecto.
    - telecom.ml.duqueom.com
    - carvision.ml.duqueom.com
    secretName: ml-portfolio-tls        # Donde cert-manager guarda el cert.
  # ¿Por qué un solo Secret para 4 dominios?
  # - Let's Encrypt soporta certificados multi-dominio (SAN).
  # - Un cert = menos gestión que 4 certs separados.
  
  # ═══════════════════════════════════════════════════════════════════════════
  # BLOQUE 6: Routing por Subdominio (Patrón preferido)
  # ═══════════════════════════════════════════════════════════════════════════
  rules:
  - host: bankchurn.ml.duqueom.com      # Subdominio dedicado.
    http:
      paths:
      - path: /                          # Todo el tráfico va al servicio.
        pathType: Prefix
        backend:
          service:
            name: bankchurn-service
            port:
              number: 80
  # ¿Por qué subdominios vs paths?
  # - Aislamiento: cada proyecto tiene su propio "namespace" de URLs.
  # - Cookies: no se mezclan entre servicios.
  # - Escalado: puedes mover un subdominio a otro cluster sin afectar otros.
  
  # ═══════════════════════════════════════════════════════════════════════════
  # BLOQUE 7: Routing por Path (Alternativa para API Gateway)
  # ═══════════════════════════════════════════════════════════════════════════
  - host: ml.duqueom.com
    http:
      paths:
      - path: /bankchurn                 # /bankchurn/* → bankchurn-service
        pathType: Prefix
        backend:
          service:
            name: bankchurn-service
            port:
              number: 80
      - path: /telecom                   # /telecom/* → telecom-service
        pathType: Prefix
        backend:
          service:
            name: telecom-service
            port:
              number: 80
  # ¿Cuándo usar paths?
  # - Cuando necesitas un "API Gateway" con un solo dominio.
  # - Para frontends que consumen múltiples APIs.
```

### 17.7.3 🧪 Laboratorio de Replicación

**Tu misión**: Crear un Ingress para tu proyecto BankChurn.

1. **Instala NGINX Ingress Controller** (si no lo tienes):
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
   ```

2. **Instala cert-manager** para TLS automático:
   ```bash
   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
   ```

3. **Crea tu ClusterIssuer**:
   ```yaml
   # clusterissuer.yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-prod
   spec:
     acme:
       server: https://acme-v02.api.letsencrypt.org/directory
       email: tu-email@example.com
       privateKeySecretRef:
         name: letsencrypt-prod
       solvers:
       - http01:
           ingress:
             class: nginx
   ```

4. **Crea tu Ingress básico**:
   ```yaml
   # mi-ingress.yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: bankchurn-ingress
     annotations:
       cert-manager.io/cluster-issuer: letsencrypt-prod
       nginx.ingress.kubernetes.io/ssl-redirect: "true"
   spec:
     tls:
     - hosts:
       - tu-dominio.com
       secretName: bankchurn-tls
     rules:
     - host: tu-dominio.com
       http:
         paths:
         - path: /
           pathType: Prefix
           backend:
             service:
               name: bankchurn-service
               port:
                 number: 80
   ```

5. **Verifica**:
   ```bash
   kubectl apply -f mi-ingress.yaml
   kubectl get certificate  # Espera a que esté "Ready"
   curl https://tu-dominio.com/health
   ```

### 17.7.4 🚨 Troubleshooting Preventivo

| Síntoma | Causa Probable | Solución |
|---------|----------------|----------|
| **404 en el Ingress** | Servicio no existe o puerto incorrecto | `kubectl get svc` y verifica nombre/puerto. |
| **502 Bad Gateway** | Pods no están ready o healthcheck falla | `kubectl get pods` y revisa logs del pod. |
| **Certificate no se genera** | DNS no apunta al Ingress IP o ClusterIssuer mal | `kubectl describe certificate` para ver eventos. |
| **HTTP funciona pero HTTPS no** | Secret TLS no existe o está vacío | `kubectl get secret bankchurn-tls -o yaml`. |
| **Rate limit bloquea usuarios legítimos** | Umbral muy bajo | Incrementa `limit-rps` o usa whitelist por IP. |

---

<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en despliegue ML

En despliegue ML es muy fácil elegir mal la plataforma o romper detalles como puertos, healthchecks o tamaños de imagen.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) Elegir la plataforma equivocada (costos o latencia inesperados)

**Síntomas típicos**

- Con Lambda: facturas altas al subir el tráfico o latencias variables por cold starts.
- Con K8s: infraestructura sobredimensionada para un solo modelo simple.

**Cómo identificarlo**

- Compara tu caso con la **matriz de decisión** del módulo (tráfico, latencia, equipo Ops, presupuesto).

**Cómo corregirlo**

- Para MVPs y tráfico moderado, prefiere **Cloud Run/ECS** en lugar de K8s.
- Reserva K8s para escenarios enterprise con múltiples servicios y tráfico muy alto.

---

### 2) Lambdas que no despliegan o fallan al importar el modelo

**Síntomas típicos**

- Errores como `Unable to import module 'handler'`.
- Deployment fallido por paquete demasiado grande (> 250MB).

**Cómo identificarlo**

- Revisa el tamaño del zip y la estructura de `lambda_function/`.

**Cómo corregirlo**

- Empaqueta solo lo necesario (`model/`, `src/`, `handler.py`, `requirements.txt`).
- Usa capas o reduce dependencias pesadas si es posible.

---

### 3) Contenedores que arrancan pero nunca pasan el healthcheck

**Síntomas típicos**

- En ECS/Cloud Run/K8s el servicio queda en estado `UNHEALTHY` o se reinicia en bucle.

**Cómo identificarlo**

- Compara el `healthCheck`/`readinessProbe` con los endpoints reales (`/health`, puerto 8000). 

**Cómo corregirlo**

- Asegura que tu API expone exactamente el endpoint y puerto que la plataforma espera.
- Ajusta `initialDelaySeconds`/`timeout` si el modelo tarda en cargar.

---

### 4) Puertos y rutas inconsistentes entre Docker y la plataforma

**Síntomas típicos**

- Funciona en `docker run -p 8000:8000` pero falla al desplegar en Cloud Run/ECS.

**Cómo identificarlo**

- Verifica que el `EXPOSE` del Dockerfile, el puerto del servidor (uvicorn) y el puerto configurado en la plataforma coincidan.

**Cómo corregirlo**

- Usa un puerto estándar (8000) y mantén el mismo valor en Dockerfile y manifiestos.

---

### 5) Patrón general de debugging en despliegue ML

1. Verifica primero que la imagen Docker funciona **en local** (`docker run` + `curl /health`).
2. Revisa logs de la plataforma (Lambda logs, Cloud Run logs, ECS/K8s events) para ver errores reales.
3. Comprueba healthchecks, puertos y variables de entorno.
4. Ajusta la plataforma elegida si tus patrones de tráfico o equipo no encajan con la decisión inicial.

Con esta disciplina, pasar de local a producción se vuelve un proceso repetible y menos doloroso.

---

## 17.6.1 Kubernetes Ingress con TLS y Rate Limiting

> **Referencia del portafolio**: `k8s/ingress.yaml`

### Ingress con cert-manager (TLS automático)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ml-portfolio-ingress
  annotations:
    # TLS con cert-manager
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    # Rate limiting con nginx-ingress
    nginx.ingress.kubernetes.io/limit-rps: "10"
    nginx.ingress.kubernetes.io/limit-connections: "5"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ml-api.example.com
    secretName: ml-api-tls
  rules:
  - host: ml-api.example.com
    http:
      paths:
      - path: /bankchurn
        pathType: Prefix
        backend:
          service:
            name: bankchurn-service
            port:
              number: 80
      - path: /carvision
        pathType: Prefix
        backend:
          service:
            name: carvision-service
            port:
              number: 80
```

### ClusterIssuer para Let's Encrypt

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: tu-email@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

### Verificación

```bash
# Verificar ingress
kubectl get ingress ml-portfolio-ingress

# Verificar certificado TLS
kubectl get certificate ml-api-tls

# Test con curl
curl -v https://ml-api.example.com/bankchurn/health
```

---

<a id="ejercicio"></a>

## 17.7 Ejercicio: Deploy a Cloud Run

```bash
# 1. Build imagen
docker build -t gcr.io/my-project/bankchurn:v1 .

# 2. Push a GCR
docker push gcr.io/my-project/bankchurn:v1

# 3. Deploy
gcloud run deploy bankchurn \
  --image gcr.io/my-project/bankchurn:v1 \
  --platform managed \
  --region us-central1 \
  --memory 1Gi \
  --allow-unauthenticated

# 4. Test
curl -X POST https://bankchurn-xxx.run.app/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{"credit_score": 650, "age": 35, ...}'
```

---

## ✅ Ejercicios

Ver [EJERCICIOS.md](EJERCICIOS.md) - Módulo 17:
- **17.1**: Dockerfile multi-stage
- **17.2**: Docker Compose para stack ML

---

<a id="checkpoint"></a>

## ✅ Checkpoint

- [ ] Puedes explicar (en 60s) por qué tu caso usa Lambda vs Cloud Run/ECS vs Kubernetes.
- [ ] Tu servicio desplegado responde `/health` en la plataforma elegida.
- [ ] El healthcheck/readiness/liveness está configurado y pasa en producción.
- [ ] Tienes un plan de rollback (y sabes ejecutarlo).
- [ ] Registraste en runbook qué hacer ante latencia alta y error rate alto.

---

## 🔜 Siguiente Paso

Con la plataforma elegida, es hora de gestionar **infraestructura como código**.

**[Ir a Módulo 18: Infraestructura como Código →](18_INFRAESTRUCTURA.md)**

---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **Cloud Run Tutorial** | Google Cloud | 25 min | [YouTube](https://www.youtube.com/watch?v=3OP-q55hOUI) |
| 🟡 | **AWS Lambda for ML** | AWS | 30 min | [YouTube](https://www.youtube.com/watch?v=eOBq__h4OJ4) |
| 🟢 | **Blue-Green Deployments** | DevOps Toolkit | 20 min | [YouTube](https://www.youtube.com/watch?v=gfQRuL8Gj_A) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [Cloud Run Docs](https://cloud.google.com/run/docs) | Guía oficial GCP |
| 🟡 | [AWS Lambda](https://docs.aws.amazon.com/lambda/) | Serverless AWS |

---

## ⚖️ Decisión Técnica: ADR-007 Plataforma de Deployment

**Contexto**: Necesitamos elegir dónde desplegar APIs ML.

**Decisión**: Cloud Run para APIs de inferencia (default), K8s para casos complejos.

**Alternativas Consideradas**:
- **AWS Lambda**: Cold starts problemáticos para ML
- **EC2/GCE**: Más control pero más gestión
- **Kubernetes**: Más complejo pero más flexible

**Consecuencias**:
- ✅ Escalado automático (0 a N)
- ✅ Pay-per-use, sin servidores ociosos
- ✅ CI/CD simple con Cloud Build
- ❌ Cold starts (mitigable con min-instances)

---

## 🔧 Ejercicios del Módulo

### Ejercicio 17.1: Análisis de Costos
**Objetivo**: Comparar costos entre plataformas.
**Dificultad**: ⭐⭐

```
Escenario:
- API con 10,000 requests/día
- Latencia promedio 200ms
- Imagen Docker 500MB
- 1GB RAM por instancia

TU TAREA: Calcular costo mensual aproximado en:
- Cloud Run
- AWS Lambda
- EC2 t3.small
```

<details>
<summary>💡 Ver solución</summary>

```
CLOUD RUN (GCP):
- Requests: 10,000/día × 30 = 300,000/mes
- CPU: 300,000 × 0.2s = 60,000 CPU-seconds = 16.7 CPU-hours
- Memory: 16.7 hours × 1GB = 16.7 GB-hours
- Costo: ~$5-10/mes (con free tier)

AWS LAMBDA:
- Requests: 300,000/mes (1M free)
- Duration: 300,000 × 200ms = 60,000 GB-seconds
- Costo: ~$1-5/mes (pero cold starts!)

EC2 t3.small (always on):
- $0.0208/hour × 720h = ~$15/mes
- + Load Balancer: ~$20/mes
- Total: ~$35/mes

RECOMENDACIÓN:
- < 100K req/mes: Cloud Run (escala a 0)
- 100K-1M req/mes: Cloud Run con min-instances
- > 1M req/mes: Kubernetes o EC2 dedicado
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **Blue-Green** | Estrategia de deployment con dos ambientes idénticos |
| **Canary** | Despliegue gradual a un % de tráfico |
| **Cold Start** | Tiempo de inicio cuando no hay instancias activas |
| **Serverless** | Modelo donde el proveedor gestiona la infraestructura |

---

<div align="center">

**Siguiente módulo** → [18. Infraestructura](18_INFRAESTRUCTURA.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
