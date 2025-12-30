# 18. Infraestructura como Código
 
 <a id="00-prerrequisitos"></a>
 
 ## 0.0 Prerrequisitos
 
 - Haber completado el módulo 17 (Despliegue) para entender plataformas y healthchecks.
 - Conocer Docker (imágenes, puertos, redes) antes de subir el nivel a IaC/K8s.
 - Entender el objetivo de IaC: reproducibilidad, auditoría y rollback de infraestructura.
 
 ---
 
 <a id="01-protocolo-e-como-estudiar-este-modulo"></a>
 
 ## 0.1 🧠 Protocolo E: Cómo estudiar este módulo
 
 - **Antes de profundizar**: decide si este módulo es “necesario ahora” o “skill complementario” para tu portafolio.
 - **Durante el estudio**: traduce cada concepto a un artefacto concreto (un `main.tf`, un `deployment.yaml`, un `hpa.yaml`).
 - **Si te atoras >15 min** (estado de Terraform, permisos de registry, probes, secrets), regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.
 
 ---
 
 <a id="02-entregables-verificables-minimo-viable"></a>
 
 ## 0.2 ✅ Entregables verificables (mínimo viable)
 
 - [ ] Puedes explicar (en 60s) qué problema resuelve IaC vs “click-ops”.
 - [ ] Puedes leer y modificar un `deployment.yaml` y un `service.yaml` básicos.
 - [ ] Entiendes `requests/limits`, `livenessProbe` y `readinessProbe` a nivel conceptual.
 - [ ] Sabes diseñar mínimos de FinOps: presupuestos + alertas + tags/labels.
 
 ---
 
 <a id="03-puente-teoria-codigo-portafolio"></a>
 
 ## 0.3 🧩 Puente teoría ↔ código (Portafolio)
 
 - **Terraform**: infraestructura reproducible (clusters, redes, servicios gestionados)
 - **Kubernetes**: manifests para desplegar y escalar APIs ML
 - **Prueba**: ser capaz de justificar cuándo usar Docker/CI-CD (portafolio) vs IaC/K8s (contexto profesional)
 
 ---
 
 ## 📋 Contenido
 
 - **0.0** [Prerrequisitos](#00-prerrequisitos)
 - **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
 - **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
 - **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
 - **18.1** [Terraform Básico](#181-terraform-basico)
 - **18.2** [Kubernetes Básico](#182-kubernetes-basico)
 - **18.3** [¿Cuándo usar qué?](#183-cuando-usar-que)
 - **18.4** [Cloud y Control de Costos (FinOps para MLOps)](#184-cloud-y-control-de-costos-finops-para-mlops)
 - **18.5** [Horizontal Pod Autoscaler (HPA)](#185-horizontal-pod-autoscaler-hpa)
 - **18.6** [ConfigMaps y Secrets](#186-configmaps-y-secrets)
 - **18.7** [Ingress para Routing HTTP](#187-ingress-para-routing-http)
 - **18.8** [Cómo se usó en el Portafolio](#188-como-se-uso-en-el-portafolio)
 - [Errores habituales](#errores-habituales)
 - [✅ Ejercicio](#ejercicio)
 - [<a id="checkpoint"></a>

✅ Checkpoint](#checkpoint)
 
 ## 🎯 Objetivo
 
 Conceptos de IaC (Terraform) y orquestación (Kubernetes) para despliegue ML.

> **Nota**: Este módulo es AVANZADO. Para el portafolio actual, Docker + GitHub Actions es suficiente.

---

<a id="181-terraform-basico"></a>


### 🧠 Mapa Mental de Conceptos

**Términos clave para este módulo:**
- Revisa los conceptos principales en las secciones siguientes
- Practica con los ejercicios del portafolio BankChurn
- Aplica los checkpoints para verificar tu comprensión

---



### 💻 Ejercicio Puente: Cloud/K8s

> **Meta**: Practica el concepto antes de aplicarlo al portafolio.

**Ejercicio básico:**
1. Lee la sección teórica siguiente
2. Identifica los patrones clave del código de ejemplo
3. Replica el patrón en un proyecto de prueba

---

### 🛠️ Práctica del Portafolio: Infraestructura en BankChurn

> **Tarea**: Aplicar este módulo en BankChurn-Predictor.

```bash
cd BankChurn-Predictor
# Explora el código relacionado con Cloud/K8s
```

**Checklist:**
- [ ] Localicé el código relevante
- [ ] Entendí la implementación actual
- [ ] Identifiqué posibles mejoras

---

### <a id="checkpoint"></a>

✅ Checkpoint de Conocimiento

**Pregunta 1**: ¿Cuál es el objetivo principal de Infraestructura?

**Pregunta 2**: ¿Cómo se implementa en el portafolio?

**🔧 Escenario Debugging**: Si algo falla en Cloud/K8s, ¿cuál sería tu primer paso de diagnóstico?


## Terraform Básico

### Concepto

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  TERRAFORM = Definir infraestructura en código                            ║
║                                                                           ║
║  En lugar de:                                                             ║
║  "Crear una instancia EC2 manualmente en la consola AWS"                  ║
║                                                                           ║
║  Escribes:                                                                ║
║  resource "aws_instance" "ml_server" {                                    ║
║    ami           = "ami-12345"                                            ║
║    instance_type = "t3.medium"                                            ║
║  }                                                                        ║
║                                                                           ║
║  Beneficios:                                                              ║
║  • Reproducible                                                           ║
║  • Versionado en Git                                                      ║
║  • Auditado                                                               ║
║  • Destruir y recrear fácilmente                                          ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Estructura Típica

```hcl
# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ECS para ML API
resource "aws_ecs_cluster" "ml_cluster" {
  name = "ml-portfolio-cluster"
}

resource "aws_ecs_service" "bankchurn_api" {
  name            = "bankchurn-api"
  cluster         = aws_ecs_cluster.ml_cluster.id
  task_definition = aws_ecs_task_definition.bankchurn.arn
  desired_count   = 2
  
  load_balancer {
    target_group_arn = aws_lb_target_group.bankchurn.arn
    container_name   = "bankchurn"
    container_port   = 8000
  }
}
```

---

<a id="182-kubernetes-basico"></a>

## Kubernetes Básico

### Concepto

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  KUBERNETES = Orquestar contenedores a escala                             ║
║                                                                           ║
║  Pod: Un contenedor corriendo                                             ║
║  Deployment: N réplicas de un Pod                                         ║
║  Service: Exponer Pods a la red                                           ║
║  Ingress: Routing HTTP externo                                            ║
║                                                                           ║
║  Para ML:                                                                 ║
║  • Deployment para API de inferencia                                      ║
║  • HPA (Horizontal Pod Autoscaler) para escalar con carga                 ║
║  • Secrets para API keys y credenciales                                   ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

### Deployment YAML

```yaml
# k8s/deployment.yaml

apiVersion: apps/v1                      # Versión de la API de K8s.
kind: Deployment                         # Tipo de recurso: gestiona réplicas de Pods.
metadata:
  name: bankchurn-api                    # Nombre del Deployment.
  labels:
    app: bankchurn                       # Label para seleccionar este recurso.
spec:
  replicas: 2                            # Número de Pods a mantener corriendo.
  selector:
    matchLabels:
      app: bankchurn                     # Selecciona Pods con este label.
  template:                              # Template del Pod.
    metadata:
      labels:
        app: bankchurn                   # Los Pods creados tendrán este label.
    spec:
      containers:
      - name: bankchurn                  # Nombre del contenedor.
        image: ghcr.io/user/bankchurn:latest  # Imagen Docker a usar.
        ports:
        - containerPort: 8000            # Puerto que expone el contenedor.
        resources:
          requests:                      # Recursos mínimos garantizados.
            memory: "256Mi"              # 256 MiB de RAM.
            cpu: "250m"                  # 0.25 CPU cores (milicores).
          limits:                        # Recursos máximos permitidos.
            memory: "512Mi"              # Si excede, OOMKilled.
            cpu: "500m"                  # Si excede, throttling.
        livenessProbe:                   # K8s verifica si el Pod está vivo.
          httpGet:
            path: /health                # Endpoint a llamar.
            port: 8000
          initialDelaySeconds: 30        # Espera antes de primer check.
          periodSeconds: 10              # Intervalo entre checks.
        env:                             # Variables de entorno.
        - name: MLFLOW_TRACKING_URI
          valueFrom:
            secretKeyRef:                # Lee valor de un Secret de K8s.
              name: ml-secrets           # Nombre del Secret.
              key: mlflow-uri            # Key dentro del Secret.
---
apiVersion: v1
kind: Service                            # Service: expone Pods a la red.
metadata:
  name: bankchurn-service
spec:
  selector:
    app: bankchurn                       # Enruta tráfico a Pods con este label.
  ports:
  - port: 80                             # Puerto externo.
    targetPort: 8000                     # Puerto del contenedor.
  type: LoadBalancer                     # Crea un balanceador de carga externo.
```

---

<a id="183-cuando-usar-que"></a>

## ¿Cuándo Usar Qué?

| Escenario | Solución Recomendada |
|-----------|---------------------|
| Proyecto personal/demo | Docker + docker-compose |
| Startup pequeña | ECS Fargate o Cloud Run |
| Empresa mediana | EKS/GKE con Terraform |
| Enterprise | Full K8s + GitOps (ArgoCD) |

### Para Este Portafolio

**Docker + GitHub Actions es suficiente.**

Terraform y K8s son skills valiosos, pero no necesarios para demostrar competencia MLOps en proyectos de portafolio.

---

<a id="184-cloud-y-control-de-costos-finops-para-mlops"></a>

##  Cloud y Control de Costos (FinOps para MLOps)

> Objetivo: que no te llegue una factura de 500 USD por dejar un cluster o una GPU encendidos sin uso.

### 1) Modelo mental de costos en cloud

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  REGLA DE ORO: En cloud, TODO lo que corre o almacena datos tiene costo.  ║
║                                                                           ║
║  Principales drivers de costo en MLOps:                                   ║
║  • Cómputo: EC2/VMs, nodos de K8s, GPUs, Jobs de entrenamiento            ║
║  • Almacenamiento: S3/GCS, volúmenes, snapshots, buckets "olvidados"      ║
║  • Networking: tráfico de salida (egress), balanceadores de carga         ║
║  • Servicios gestionados: EKS/GKE fee, bases de datos, colas, etc.        ║
║                                                                           ║
║  Pregunta que siempre debes hacerte:                                      ║
║  "¿Este recurso está generando valor AHORA MISMO o podría estar apagado?" ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

Buena parte del FinOps (gestión financiera en cloud) se reduce a:

- **Apagar lo que no usas** (clusters, GPUs, VMs demo).
- **Que los recursos escalen a cero** cuando no hay tráfico.
- **Poner límites y alertas** antes de que llegue una sorpresa.

---

### 2) Alertas de facturación mínimas en AWS y GCP

#### AWS: AWS Budgets + Cost Explorer

- **Paso 1**: Ir a `Billing > Budgets` y crear un **Budget mensual** por cuenta o proyecto.
- **Paso 2**: Configurar umbrales típicos, por ejemplo:
  - 50% del presupuesto → alerta informativa.
  - 80% del presupuesto → alerta de acción (revisar recursos).
  - 100% del presupuesto → posible freeze de entornos no críticos.
- **Paso 3**: Enviar alertas a:
  - Email del equipo.
  - (Opcional) SNS → Slack/Teams.
- **Paso 4**: Activar **Cost Explorer** para revisar qué servicio está creciendo (EKS, EC2, S3, etc.).

> 💡 En entrevistas, menciona que siempre configuras **AWS Budgets** en cuentas nuevas y usas **Cost Allocation Tags** (`Project`, `Env`, `Owner`) para saber quién gasta qué.

#### GCP: Presupuestos y alertas en Cloud Billing

- **Paso 1**: Entra a `Billing > Budgets & alerts` y crea un **presupuesto por proyecto**.
- **Paso 2**: Define umbrales 50/80/100% y activa notificaciones por correo.
- **Paso 3**: Opcionalmente integra con **Cloud Monitoring** para disparar alertas a Slack/PagerDuty.
- **Paso 4**: Usa el reporte de **Cost breakdown** para identificar servicios caros (GKE, Cloud Run, BigQuery, etc.).

Checklist rápido para cualquier cuenta cloud nueva:

- [ ] Hay un **owner claro** por entorno (quien responde a la factura).
- [ ] Cada recurso tiene **tags/labels** de `project`, `env`, `owner`.
- [ ] Hay un **runbook** para apagar recursos no críticos fuera de horario (scripts/programado).

---

### 3) Errores frecuentes de costo en MLOps y cómo evitarlos

#### a) Dejar un cluster de Kubernetes encendido sin tráfico

**Escenario típico**: EKS/GKE creado para pruebas, sin pods críticos, pero:

- Los **nodos** siguen encendidos.
- EKS cobra una **tarifa fija por cluster**.
- Hay LoadBalancers y volúmenes asociados que nadie recuerda.

**Señales de alarma**

- Factura con líneas como `EKS cluster fee`, `Compute Engine`, `Load Balancer` sin apenas requests.
- `kubectl get pods -A` muestra casi todo idle.

**Buenas prácticas**

- Para **dev/staging**, preferir:
  - Cloud Run/ECS con `min-instances = 0` o tareas bajo demanda.
  - Clusters efímeros destruidos con `terraform destroy` o scripts programados.
- Configurar **cluster autoscaler** con `minNodes = 0` en nodos no críticos.
- Revisar mensualmente: `kubectl get nodes -A` + panel de uso de CPU/RAM.

#### b) GPUs encendidas 24/7 para entrenamiento puntual

- **Problema**: nodos GPU (p.ej. `p3`, `a2-highgpu`) usados una vez al día pero pagando 24/7.
- **Solución**:
  - Usar **jobs efímeros** (Spot/Preemptible) y destruirlos al terminar.
  - Automatizar con IaC (`terraform apply` / `destroy`) o workflows de CI/CD.
  - Para portafolios, priorizar entrenamiento **local** y solo usar GPU cloud en casos concretos.

#### c) Configuración "cómoda" pero cara en serverless

- En Cloud Run/Lambda es fácil poner:
  - `min-instances` > 0 en todos los servicios.
  - Timeouts muy altos con mucha memoria.
- **Reglas sanas**:
  - Entornos **dev/staging**: `min-instances = 0` y límites de memoria modestos.
  - Reservar configuraciones "grandes" para prod con justificación.

---

### 4) Checklist de costos por entorno

| Entorno | Patrón recomendado |
|---------|-----------------------|
| Dev | Cloud Run/ECS con `min-instances = 0`, sin clusters K8s dedicados |
| Staging | Igual que dev, pero con presupuestos y alertas separados |
| Prod | K8s/cloud gestionado solo si hay tráfico real y equipo de Ops suficiente |

- [ ] Hay un **owner claro** por entorno (quien responde a la factura).
- [ ] Cada recurso tiene **tags/labels** de `project`, `env`, `owner`.
- [ ] Hay un **runbook** para apagar recursos no críticos fuera de horario (scripts/programado).

---

### 5) Consejos profesionales orientados a entrevistas

- **Cuenta una historia realista**: "Nos llegó una factura alta por X; la mitigación fue: budgets, etiquetado, autoscaling y IaC para destruir entornos efímeros".
- Menciona explícitamente:
  - **Presupuestos y alertas de facturación** (AWS Budgets / GCP Budgets).
  - **Autoscaling a cero** para workloads de baja criticidad.
  - **Tags/labels de costo** como requisito obligatorio.
- Conecta esta sección con:
  - La **matriz de costo** del módulo de despliegue (`17_DESPLIEGUE.md`).
  - Las **métricas y alertas** vistas en observabilidad (`16_OBSERVABILIDAD.md`).

---

<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en Infraestructura como Código

Aunque este módulo es avanzado, es común cometer errores que dejan tu IaC frágil o inconsistente.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) Terraform aplicado “a mano” sin estado controlado

**Síntomas típicos**

- Se ejecuta `terraform apply` desde distintas máquinas sin control del `terraform.tfstate`.
- Recursos que aparecen duplicados o que se destruyen sin querer.

**Cómo identificarlo**

- Verifica dónde se guarda el estado: local vs backend remoto (S3, GCS, etc.).

**Cómo corregirlo**

- Para proyectos serios, usa un **backend remoto** para el estado y controla quién puede aplicar cambios.

#### Configuración de Backend Remoto (AWS S3 + DynamoDB)

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket         = "ml-portfolio-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# Crear tabla DynamoDB para locking (una sola vez)
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

#### Backend Remoto para GCP (GCS)

```hcl
terraform {
  backend "gcs" {
    bucket  = "ml-portfolio-terraform-state"
    prefix  = "infra/terraform"
  }
}
```

#### Verificación

```bash
# Inicializar con backend remoto
terraform init -backend-config="bucket=ml-portfolio-terraform-state"

# Verificar estado
terraform state list
```

---

### 2) Manifiestos de K8s que funcionan en minikube pero no en cloud

**Síntomas típicos**

- Deployment correcto en local, pero en EKS/GKE los Pods quedan `CrashLoopBackOff` o `ImagePullBackOff`.

**Cómo identificarlo**

- Revisa la imagen referenciada (`image:`) y las credenciales de registry.

**Cómo corregirlo**

- Asegura que la imagen esté en un registry accesible desde el cluster (ECR/GCR/GHCR) y que el cluster tenga permisos para leerla.

---

### 3) Resources/limits mal configurados en K8s

**Síntomas típicos**

- Pods que se matan por OOMKilled o throttling excesivo de CPU.

**Cómo identificarlo**

- Observa eventos del Pod y métricas de consumo real.

**Cómo corregirlo**

- Ajusta `requests` y `limits` según el perfil real de uso de tu API ML, empezando conservador y ajustando con métricas.

---

### 4) ¿Cuándo escalar más allá de Docker?

**Síntomas típicos**

- Intentar introducir Terraform/K8s en un proyecto de portafolio cuando aún no dominas Docker + CI/CD.

**Cómo identificarlo**

- Si todavía no tienes un flujo sólido con Docker + GitHub Actions, probablemente es pronto para meter K8s.

**Cómo corregirlo**

- Sigue la recomendación del módulo: primero domina Docker + CI/CD. Usa IaC/K8s solo si tu contexto profesional lo exige.

---

### 5) Patrón general de debugging en IaC

1. Aplica primero en entornos de prueba pequeños (playgrounds, sandbox).
2. Revisa siempre el **plan** (`terraform plan`, `kubectl diff`) antes de aplicar.
3. Usa métricas y eventos del cluster para ajustar configuración en lugar de adivinar.

Con este enfoque, IaC y K8s se vuelven herramientas que suman, no otra fuente de problemas.

---

<a id="185-horizontal-pod-autoscaler-hpa"></a>

## Horizontal Pod Autoscaler (HPA)

El HPA escala automáticamente los pods basándose en métricas como CPU o memoria.

```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: bankchurn-hpa
  namespace: mlops
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
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # Esperar 5 min antes de escalar abajo
    scaleUp:
      stabilizationWindowSeconds: 0    # Escalar arriba inmediatamente
```

**¿Por qué 70% CPU?** Es un balance entre eficiencia (no desperdiciar recursos) y capacidad de respuesta (tener margen para picos).

---

<a id="186-configmaps-y-secrets"></a>

## ConfigMaps y Secrets

### ConfigMap (configuración no sensible)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: bankchurn-config
  namespace: mlops
data:
  LOG_LEVEL: "INFO"
  MODEL_PATH: "/app/artifacts/model.joblib"
  MLFLOW_TRACKING_URI: "http://mlflow-service:5000"
```

### Secret (ejemplo didáctico, **no usar en producción**)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ml-secrets
  namespace: mlops
type: Opaque
stringData:
  # Valores de ejemplo. En un entorno real se inyectan desde el sistema de secretos.
  mlflow-uri: "http://mlflow-service:5000"
  database-password: "REEMPLAZAR_EN_ENTORNO_REAL"
  api-key: "REEMPLAZAR_EN_ENTORNO_REAL"
```

### Uso en Deployment

```yaml
spec:
  containers:
  - name: bankchurn
    envFrom:
    - configMapRef:
        name: bankchurn-config
    - secretRef:
        name: ml-secrets
```

---

<a id="187-ingress-para-routing-http"></a>

## Ingress para Routing HTTP

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mlops-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: api.mlops.example.com
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

---

<a id="188-como-se-uso-en-el-portafolio"></a>

## 📦 Cómo se usó en el Portafolio

El directorio `k8s/` del portafolio contiene 8 manifests production-ready:

| Archivo | Propósito |
|---------|-----------|
| `namespace.yaml` | Namespace `mlops` aislado |
| `bankchurn-deployment.yaml` | Deployment + Service + HPA |
| `carvision-deployment.yaml` | Deployment + Service |
| `telecom-deployment.yaml` | Deployment + Service |
| `prometheus-deployment.yaml` | Monitoreo |
| `grafana-deployment.yaml` | Dashboards |
| `ingress.yaml` | Routing HTTP |
| `storage.yaml` | PersistentVolumeClaims |

**Comandos útiles:**

```bash
# Aplicar todos los manifests
kubectl apply -f k8s/

# Ver estado de pods
kubectl get pods -n mlops

# Ver logs de un pod
kubectl logs -f deployment/bankchurn-api -n mlops

# Escalar manualmente (si no usas HPA)
kubectl scale deployment bankchurn-api --replicas=3 -n mlops

# Port-forward para testing local
kubectl port-forward svc/bankchurn-service 8001:80 -n mlops
```

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **IaC (Infrastructure as Code)**: Por qué Terraform/Pulumi sobre click-ops.

2. **Kubernetes basics**: Pods, Deployments, Services, ConfigMaps.

3. **Cloud agnostic**: Diseña para portabilidad cuando sea posible.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Multi-environment | Usa Terraform workspaces o directorios |
| Secrets | External Secrets Operator o cloud-native solutions |
| Costos | Tagging obligatorio para cost allocation |
| DR (Disaster Recovery) | Documenta y prueba regularmente |

### Stack Recomendado

```
IaC:        Terraform + Terragrunt
Containers: Docker + Kubernetes
CI/CD:      GitHub Actions + ArgoCD
Secrets:    Vault o AWS Secrets Manager
Monitoring: Prometheus + Grafana
```

---

## 📺 Recursos Externos Recomendados

> Ver [RECURSOS_POR_MODULO.md](apoyo/RECURSOS.md) para la lista completa.

| 🏷️ | Recurso | Tipo | Duración |
|:--:|:--------|:-----|:--------:|
## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **Kubernetes Tutorial** | TechWorld Nana | 4h | [YouTube](https://www.youtube.com/watch?v=X48VuDVv0do) |
| 🔴 | **Terraform Tutorial** | freeCodeCamp | 2.5h | [YouTube](https://www.youtube.com/watch?v=7xngnjfIlK4) |
| 🟡 | **Helm Charts Explained** | TechWorld Nana | 30 min | [YouTube](https://www.youtube.com/watch?v=-ykwb1d0DXU) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [Kubernetes Docs](https://kubernetes.io/docs/) | Documentación oficial |
| 🟡 | [Terraform Docs](https://developer.hashicorp.com/terraform/docs) | HashiCorp docs |

---

## ⚖️ Decisión Técnica: ADR-009 Terraform

**Contexto**: Necesitamos gestionar infraestructura de forma reproducible.

**Decisión**: Usar Terraform para IaC en AWS/GCP.

**Alternativas Consideradas**:
- **CloudFormation**: Solo AWS, menos portable
- **Pulumi**: Code-first pero más complejo
- **Ansible**: Mejor para configuración que infraestructura

**Consecuencias**:
- ✅ Multi-cloud (AWS, GCP, Azure)
- ✅ Estado declarativo
- ✅ Plan antes de apply
- ❌ Curva de aprendizaje inicial

---

## 🔧 Ejercicios del Módulo

### Ejercicio 18.1: Leer Kubernetes Manifest
**Objetivo**: Entender deployment y service de K8s.
**Dificultad**: ⭐⭐

```yaml
# ¿Qué hace este manifest?
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ml-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ml-api
  template:
    spec:
      containers:
      - name: api
        image: myregistry/ml-api:v1
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

<details>
<summary>💡 Ver solución</summary>

```
ANÁLISIS DEL MANIFEST:

1. Deployment "ml-api":
   - Crea 2 réplicas del pod
   - Selector matchLabels para encontrar pods

2. Container "api":
   - Imagen: myregistry/ml-api:v1
   - Resources requests: mínimo garantizado
     - 512Mi RAM, 250m CPU (0.25 cores)
   - Resources limits: máximo permitido
     - 1Gi RAM, 500m CPU (0.5 cores)

3. Comportamiento:
   - K8s programa pods en nodos con recursos disponibles
   - Si excede limits → throttling (CPU) o OOMKilled (memory)
   - HPA puede escalar basado en % de requests

4. Mejoras recomendadas:
   - Añadir livenessProbe y readinessProbe
   - Definir securityContext (non-root)
   - Usar configMapRef para variables
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **Kubernetes** | Orquestador de contenedores para escalar aplicaciones |
| **Terraform** | Herramienta IaC declarativa para provisionar infraestructura |
| **HPA** | Horizontal Pod Autoscaler - escala pods basado en métricas |
| **ConfigMap** | Objeto K8s para configuración no sensible |

---

## 🏁 FIN DE FASE 4: Producción

> 🎯 **¡Has completado los módulos 17-18!**
>
> Ahora entiendes deployment y infraestructura para producción:
> - ✅ Estrategias de despliegue (blue-green, canary)
> - ✅ Plataformas cloud (Cloud Run, Lambda, K8s)
> - ✅ Infrastructure as Code con Terraform
> - ✅ Kubernetes basics

**Siguiente**: Fase 5 - Senior/Staff (Documentación, Observabilidad Avanzada, FinOps)

---

<div align="center">

**Siguiente módulo** → [19. Documentación](19_DOCUMENTACION.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
