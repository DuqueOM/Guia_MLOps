# MÓDULO 06: INGENIERÍA DE DATOS Y DVC

<div align="center">

# 📊 MÓDULO 06: Ingeniería de Datos y DVC

### El Arte de Versionar lo que Git No Puede

*"Si no puedo recrear tus datos, no puedo reproducir tu modelo."*

| Duración             | Teoría               | Práctica             |
| :------------------: | :------------------: | :------------------: |
| **5-6 horas**        | 30%                  | 70%                  |

</div>

---

<a id="00-prerrequisitos"></a>

## 0.0 Prerrequisitos

- Haber completado **[05_GIT_PROFESIONAL](05_GIT_PROFESIONAL.md)** (ramas limpias, PRs, `.gitignore`).
- Entender que **Git NO está hecho para datasets grandes**.
- Tener acceso (o plan) para un remote de DVC (local, GDrive, S3/GCS/Azure).

---

<a id="01-protocolo-e-como-estudiar-este-modulo"></a>

## 0.1 🧠 Protocolo E: Cómo estudiar este módulo

- **Antes de correr comandos**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define tu *output mínimo* (ej: “`dvc.yaml` + `params.yaml` + repro reproducible”).
- **Mientras integras DVC**: si te atoras >15 min (remotes, credenciales, `dvc repro`, `dvc checkout`), registra el bloqueo en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
- **Al cerrar la semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para decidir qué mejorar (reproducibilidad, estructura del pipeline, naming de stages).

---

<a id="02-entregables-verificables-minimo-viable"></a>

## 0.2 ✅ Entregables verificables (mínimo viable)

Al terminar este módulo, deberías poder mostrar (en al menos 1 proyecto del portafolio):

- [ ] **Datos trackeados por DVC** (no en Git), con `.dvc/` y/o archivos `.dvc` en el repo.
- [ ] **Remote configurado** y flujo básico funcionando: `dvc push` / `dvc pull`.
- [ ] **Pipeline reproducible** con `dvc.yaml` + `params.yaml` y `dvc repro`.
- [ ] **Evidencia**: poder recrear resultados al hacer `git checkout <tag>` + `dvc checkout` + `dvc pull`.

---

<a id="03-puente-teoria-codigo-portafolio"></a>

## 0.3 🧩 Puente teoría ↔ código (Portafolio)

Para que esto cuente como progreso real, fuerza este mapeo:

- **Concepto**: versionado de datos / DAG / reproducibilidad
- **Archivo**: `dvc.yaml`, `params.yaml`, `.dvc/config`, `data/**.dvc`, `metrics/*.json`
- **Comandos**: `dvc status`, `dvc dag`, `dvc repro`, `dvc push`, `dvc pull`, `dvc checkout`
- **Evidencia**: resultados reproducibles cuando cambias de commit/tag.

---

## 📋 Contenido

- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
- [ADR de Inicio](#adr-inicio)
- [6.1 El Problema](#61-problema)
- [6.2 Configuración Inicial](#62-configuracion)
- [6.3 Versionado Básico](#63-versionado-basico)
- [6.4 Pipelines con dvc.yaml](#64-pipelines)
- [6.5 Métricas y Experimentos](#65-metricas)
- [6.6 🔬 Ingeniería Inversa: DVC Pipeline Real](#66-ingenieria-inversa-dvc) ⭐ NUEVO
- [Errores habituales](#errores-habituales)
- [6.7 Ejercicio Integrador](#67-ejercicio)
- [6.8 Autoevaluación](#68-autoevaluacion)

---

<a id="adr-inicio"></a>

## 🎯 ADR de Inicio: ¿Cuándo (NO) Usar DVC?

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║  ADR-006: Criterios para Usar DVC                                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║  ✅ USA DVC SI:                                                               ║
║  • Datos > 100MB que no caben cómodamente en Git                              ║
║  • Necesitas reproducibilidad exacta de datasets                              ║
║  • Equipo colabora en el mismo pipeline de datos                              ║
║  • Quieres DAGs declarativos para pipelines                                   ║
║  • Datos son batch (no streaming)                                             ║
║                                                                               ║
║  ❌ NO USES DVC SI:                                                           ║
║  • Datos < 50MB y no cambian frecuentemente → Git LFS o Git directo           ║
║  • Datos son streaming (Kafka, Kinesis) → No aplica versionado batch          ║
║  • Ya tienes Data Lake con Delta Lake/Iceberg → Usar versionado nativo        ║
║  • Solo 1 persona trabaja en el proyecto → Puede ser overkill                 ║
║  • Pipeline ya está en Airflow/Prefect → Evitar duplicación                   ║
║                                                                               ║
║  DECISIÓN PARA BANKCHURN:                                                     ║
║  Usar DVC porque: datos ~50MB con potencial de crecer, equipo colabora,       ║
║  queremos reproducibilidad completa, y el pipeline es batch.                  ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### Lo Que Lograrás en Este Módulo

1. **Entender** el problema del versionado de datos en ML
2. **Configurar** DVC con remote storage
3. **Crear** pipelines reproducibles con `dvc.yaml`
4. **Diseñar** DAGs para proyectos complejos

### 🧩 Cómo se aplica en este portafolio

- En `BankChurn-Predictor/` ya tienes configurado DVC con:
  - `dvc.yaml` y `params.yaml` en la raíz del proyecto.
  - Carpeta `data/` con datasets y `.dvc/` con metadatos de versionado.
- Desde esa carpeta puedes practicar el flujo completo de este módulo ejecutando:
  ```bash
  cd BankChurn-Predictor
  dvc status
  dvc repro
  dvc pull
  ```
- Aplica los mismos principios a futuros proyectos del portafolio para mantener datos y
  pipelines de forma reproducible, especialmente cuando crees el proyecto integrador.

---

<a id="61-problema"></a>

## 6.1 El Problema: Git No Escala para Datos

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                    😱 EL INFIERNO DEL VERSIONADO DE DATOS                     ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   SIN VERSIONADO:                                                             ║
║                                                                               ║
║   data/                                                                       ║
║   ├── churn.csv                   # ¿Original o procesado?                    ║
║   ├── churn_v2.csv                # ¿Qué cambió?                              ║
║   ├── churn_final.csv             # ¿Es realmente el final?                   ║
║   ├── churn_final_v2.csv          # 😱                                        ║
║   ├── churn_final_FINAL.csv       # 💀                                        ║
║   └── churn_20231115_backup.csv   # ???                                       ║
║                                                                               ║
║   PROBLEMAS:                                                                  ║
║   • No sé qué datos usó el modelo v1.2.3                                      ║
║   • No puedo reproducir resultados de hace 2 meses                            ║
║   • Git se rompe con archivos grandes                                         ║
║   • Colaboración es imposible ("¿tienes el CSV actualizado?")                 ║
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   CON DVC:                                                                    ║
║                                                                               ║
║   data/                                                                       ║
║   └── raw/                                                                    ║
║       └── churn.csv.dvc     # Metadatos en Git, datos en storage              ║
║                                                                               ║
║   git checkout v1.2.3 && dvc checkout                                         ║
║   → Tengo EXACTAMENTE los datos de esa versión                                ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### Comparativa de Soluciones

| Solución | Tamaño Máx | Versionado | Pipelines | Costo | Complejidad |
| :------- | :--------: | :--------: | :-------: | :---: | :---------: |
| Git directo | ~10MB | ✅ | ❌ | Gratis | Baja |
| Git LFS | ~2GB | ✅ | ❌ | $$$ | Baja |
| **DVC** | Ilimitado | ✅ | ✅ | Storage | Media |
| Delta Lake | Ilimitado | ✅ | ❌ | Spark | Alta |
| LakeFS | Ilimitado | ✅ | ❌ | Server | Alta |

### 🧠 Mapa Mental de Conceptos: DVC y Versionado de Datos

```
                          ╔══════════════════════════════════════╗
                          ║   DVC: DATA VERSION CONTROL          ║
                          ╚══════════════════════════════════════╝
                                            │
         ┌──────────────────────────────────┼──────────────────────────────────┐
         ▼                                  ▼                                  ▼
┌──────────────────┐              ┌──────────────────┐              ┌──────────────────┐
│  VERSIONADO      │              │  PIPELINES       │              │  REMOTES         │
└──────────────────┘              └──────────────────┘              └──────────────────┘
       │                                 │                                 │
├─ data/*.dvc                     ├─ dvc.yaml                      ├─ S3
├─ .dvc/ (metadatos)              ├─ params.yaml                   ├─ GCS
├─ dvc add                        ├─ dvc repro                     ├─ Azure
├─ dvc checkout                   ├─ dvc dag                       ├─ GDrive
└─ dvc push/pull                  └─ stages                        └─ Local
```

**Términos clave que debes dominar:**

| Término | Significado | Comando |
|---------|-------------|---------|
| **dvc add** | Trackear archivo/carpeta con DVC | `dvc add data/raw/churn.csv` |
| **dvc.yaml** | Pipeline declarativo (DAG) | Define stages y dependencias |
| **params.yaml** | Parámetros del pipeline | Hiperparámetros, configs |
| **dvc repro** | Ejecutar pipeline reproducible | Solo re-ejecuta lo que cambió |
| **Remote** | Storage externo para datos | S3, GCS, GDrive, local |
| **.dvc file** | Metadatos del archivo trackeado | Hash MD5, tamaño |

---

### 💻 Ejercicio Puente: DVC Básico

> **Meta**: Antes de crear pipelines complejos, domina el versionado básico.

**Ejercicio 1: Inicializar DVC**
```bash
# TU TAREA: En un proyecto nuevo
mkdir my-dvc-project && cd my-dvc-project
git init
dvc init

# ¿Qué archivos creó dvc init?
ls -la .dvc/
```

**Ejercicio 2: Trackear un archivo**
```bash
# Crea un CSV de prueba
echo "id,value" > data.csv
echo "1,100" >> data.csv

# TU TAREA: Trackea con DVC
dvc add data.csv

# ¿Qué archivos se crearon?
ls -la data.csv*
cat data.csv.dvc
```

**Ejercicio 3: Simular cambio de versión**
```bash
# Commit versión 1
git add data.csv.dvc .gitignore
git commit -m "data: add initial dataset v1"

# Modifica el archivo
echo "2,200" >> data.csv
dvc add data.csv
git add data.csv.dvc
git commit -m "data: add new row to dataset v2"

# TU TAREA: Vuelve a la versión 1
git checkout HEAD~1 -- data.csv.dvc
dvc checkout
cat data.csv  # ¿Qué versión tienes?
```

<details>
<summary>🔍 Ver Solución</summary>

```bash
# Ejercicio 1: dvc init crea:
# .dvc/
# ├── .gitignore
# └── config

# Ejercicio 2: dvc add crea:
# data.csv.dvc  (metadatos con hash MD5)
# Además añade "data.csv" a .gitignore

# data.csv.dvc contiene algo como:
# outs:
# - md5: abc123...
#   size: 20
#   hash: md5
#   path: data.csv

# Ejercicio 3: Después de checkout
# Tienes la versión 1 (solo 1 fila de datos)
# Porque Git restauró el .dvc con el hash antiguo
# Y dvc checkout descargó esa versión del cache
```
</details>

---

### 🛠️ Práctica del Portafolio: DVC en BankChurn

> **Tarea**: Explorar y entender la configuración DVC de BankChurn-Predictor.

**Paso 1: Examina la estructura**
```bash
cd BankChurn-Predictor
ls -la .dvc/
cat .dvc/config
ls -la data/
```

**Paso 2: Entiende el pipeline**
```bash
# Ver el DAG visual
dvc dag

# Ver el pipeline completo
cat dvc.yaml

# Ver los parámetros
cat params.yaml
```

**Paso 3: Reproduce el pipeline**
```bash
# Ver qué está desactualizado
dvc status

# Ejecutar pipeline completo
dvc repro

# ¿Qué stages se ejecutaron?
```

**Paso 4: Simula un experimento**
```bash
# Cambia un parámetro en params.yaml
# ej: test_size: 0.3 → test_size: 0.2

# ¿Qué stages necesitan re-ejecutarse?
dvc status

# Ejecuta
dvc repro
```

---

### ✅ Checkpoint de Conocimiento: DVC

**Pregunta 1**: ¿Qué guarda Git cuando usas DVC para datos?

A) El archivo de datos completo  
B) Solo el archivo .dvc con metadatos (hash MD5)  
C) Una copia comprimida  
D) Nada, DVC reemplaza a Git  

**Pregunta 2**: ¿Cuál es la ventaja de `dvc repro` sobre correr scripts manualmente?

A) Es más rápido  
B) Solo re-ejecuta stages cuyas dependencias cambiaron  
C) Usa menos memoria  
D) Es más fácil de escribir  

**Pregunta 3**: Si haces `git checkout v1.0.0` pero NO haces `dvc checkout`, ¿qué pasa?

A) Tienes código v1.0.0 pero datos de la versión actual (inconsistente)  
B) Todo funciona automáticamente  
C) Git falla  
D) DVC borra los datos  

**🔧 Escenario de Debugging:**

```
Situación: Ejecutas dvc repro y obtienes:
  ERROR: failed to reproduce 'train': 
  Could not find data/raw/churn.csv

Pero el archivo .dvc existe: data/raw/churn.csv.dvc
```

**¿Cuál es el problema y cómo lo solucionarías?**

<details>
<summary>🔍 Ver Respuestas</summary>

**Pregunta 1**: B) Solo el archivo .dvc con metadatos. Los datos reales van al remote storage.

**Pregunta 2**: B) Solo re-ejecuta stages cuyas dependencias cambiaron. Ahorra tiempo y recursos.

**Pregunta 3**: A) Tienes código v1.0.0 pero datos de la versión actual. SIEMPRE haz `dvc checkout` después de `git checkout`.

**Escenario de Debugging**: 
- **Problema**: El archivo `.dvc` existe, pero los datos reales no están descargados.
- **Solución**: 
```bash
dvc pull  # Descarga los datos del remote
# O si no hay remote configurado:
dvc checkout  # Restaura desde cache local
```
- **Prevención**: Después de `git clone` siempre ejecuta `dvc pull`.
</details>

---

<a id="62-configuracion"></a>

## 6.2 Configuración Inicial de DVC

### Instalación

```bash
# Con pip
pip install dvc

# Con extras para storage
pip install "dvc[s3]"      # Amazon S3
pip install "dvc[gs]"      # Google Cloud Storage
pip install "dvc[azure]"   # Azure Blob Storage
pip install "dvc[gdrive]"  # Google Drive (para proyectos personales)
```

### Inicialización

```bash
# En un repo Git existente
cd bankchurn-predictor           # Navega al proyecto (debe ser repo Git).
dvc init                         # Inicializa DVC en el repositorio.

# Esto crea:
# .dvc/           - Directorio de configuración de DVC (como .git para Git).
# .dvc/.gitignore - Ignora cache local de DVC.
# .dvc/config     - Configuración de remotes y opciones.
# .dvcignore      - Archivos/carpetas que DVC debe ignorar.
```

### Configurar Remote Storage

```bash
# ════════════════════════════════════════════════════════════════════
# OPCIÓN 1: Local (para desarrollo)
# ════════════════════════════════════════════════════════════════════
dvc remote add -d localremote /path/to/dvc-storage  # Crea remote llamado "localremote".
# -d = default remote: este remote se usa por defecto en push/pull.

# ════════════════════════════════════════════════════════════════════
# OPCIÓN 2: Amazon S3
# ════════════════════════════════════════════════════════════════════
dvc remote add -d s3remote s3://my-bucket/dvc-storage  # s3://bucket/path formato S3.
dvc remote modify s3remote region us-east-1            # Configura región del bucket.
# Credenciales: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY en variables de entorno.

# ════════════════════════════════════════════════════════════════════
# OPCIÓN 3: Google Cloud Storage
# ════════════════════════════════════════════════════════════════════
dvc remote add -d gcsremote gs://my-bucket/dvc-storage  # gs://bucket/path formato GCS.
# Credenciales: GOOGLE_APPLICATION_CREDENTIALS apunta a JSON de service account.

# ════════════════════════════════════════════════════════════════════
# OPCIÓN 4: Google Drive (Gratis, bueno para proyectos personales)
# ════════════════════════════════════════════════════════════════════
dvc remote add -d gdriveremote gdrive://folder-id      # folder-id: ID de carpeta en Drive.
# La primera vez pedirá autenticación OAuth en el browser.

# ════════════════════════════════════════════════════════════════════
# Ver configuración
# ════════════════════════════════════════════════════════════════════
cat .dvc/config                                        # Muestra configuración actual.
```

### Estructura de Directorios Recomendada

```
bankchurn-predictor/
├── data/
│   ├── raw/                    # Datos originales (DVC tracked)
│   │   ├── .gitkeep
│   │   └── churn.csv          # → churn.csv.dvc en Git
│   ├── processed/             # Datos procesados (output de pipeline)
│   │   └── .gitkeep
│   └── external/              # Datos de terceros
│       └── .gitkeep
├── models/                    # Modelos entrenados (DVC tracked)
│   └── .gitkeep
├── .dvc/
│   └── config
├── .dvcignore
└── dvc.yaml                   # Pipeline definition
```

---

<a id="63-versionado-basico"></a>

## 6.3 Versionado Básico de Archivos

### Añadir Datos a DVC

```bash
# Añadir archivo
dvc add data/raw/churn.csv

# Esto crea:
# data/raw/churn.csv.dvc   - Metadatos (hash, size)
# data/raw/.gitignore      - Ignora el CSV en Git

# Ver contenido del .dvc
cat data/raw/churn.csv.dvc
```

```yaml
# data/raw/churn.csv.dvc
outs:
- md5: abc123def456...
  size: 52428800
  hash: md5
  path: churn.csv
```

### Flujo de Trabajo

```bash
# 1. Modificar datos
# ... (actualizar churn.csv con nuevos registros)

# 2. Actualizar tracking
dvc add data/raw/churn.csv

# 3. Commit ambos cambios
git add data/raw/churn.csv.dvc data/raw/.gitignore
git commit -m "data(raw): update churn dataset with Q4 2024 data"

# 4. Push datos a remote
dvc push

# 5. Push código a Git
git push
```

### Recuperar Datos de Versión Anterior

```bash
# Ver versiones del archivo
git log data/raw/churn.csv.dvc

# Checkout versión específica
git checkout v1.0.0 -- data/raw/churn.csv.dvc
dvc checkout data/raw/churn.csv

# O más simple: checkout todo
git checkout v1.0.0
dvc checkout
# → Ahora tienes código Y datos de v1.0.0
```

---

<a id="64-pipelines"></a>

## 6.4 Pipelines con dvc.yaml (El Poder Real)

### ¿Por Qué Pipelines?

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         PIPELINES DVC: REPRODUCIBILIDAD                       ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   SIN PIPELINE:                                                               ║
║   "Para reproducir, ejecuta preprocess.py, luego train.py, luego..."          ║
║   "Ah, pero primero asegúrate de tener los datos correctos..."                ║
║   "Y usa los mismos hiperparámetros que están en... algún lugar..."           ║
║                                                                               ║
║   CON PIPELINE DVC:                                                           ║
║   $ dvc repro                                                                 ║
║   → Ejecuta TODO automáticamente, en orden correcto,                          ║
║     saltando stages que no cambiaron.                                         ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### dvc.yaml Completo para BankChurn

```yaml
# dvc.yaml
stages:
  # ════════════════════════════════════════════════════════════════════
  # STAGE 1: Preparación de Datos
  # ════════════════════════════════════════════════════════════════════
  prepare:
    cmd: python src/bankchurn/data/prepare.py
    deps:
      - src/bankchurn/data/prepare.py
      - data/raw/churn.csv
      - configs/config.yaml
    params:
      - prepare.test_size
      - prepare.random_state
    outs:
      - data/processed/train.csv
      - data/processed/test.csv

  # ════════════════════════════════════════════════════════════════════
  # STAGE 2: Feature Engineering
  # ════════════════════════════════════════════════════════════════════
  featurize:
    cmd: python src/bankchurn/features/build.py
    deps:
      - src/bankchurn/features/build.py
      - data/processed/train.csv
      - data/processed/test.csv
      - configs/config.yaml
    params:
      - features.numerical
      - features.categorical
    outs:
      - data/processed/train_features.pkl
      - data/processed/test_features.pkl

  # ════════════════════════════════════════════════════════════════════
  # STAGE 3: Entrenamiento
  # ════════════════════════════════════════════════════════════════════
  train:
    cmd: python src/bankchurn/training.py
    deps:
      - src/bankchurn/training.py
      - data/processed/train_features.pkl
      - configs/config.yaml
    params:
      - train.n_estimators
      - train.max_depth
      - train.random_state
    outs:
      - models/pipeline.pkl
    metrics:
      - metrics/train_metrics.json:
          cache: false

  # ════════════════════════════════════════════════════════════════════
  # STAGE 4: Evaluación
  # ════════════════════════════════════════════════════════════════════
  evaluate:
    cmd: python src/bankchurn/evaluate.py
    deps:
      - src/bankchurn/evaluate.py
      - models/pipeline.pkl
      - data/processed/test_features.pkl
    metrics:
      - metrics/eval_metrics.json:
          cache: false
    plots:
      - metrics/roc_curve.json:
          x: fpr
          y: tpr
      - metrics/confusion_matrix.json:
          template: confusion
          x: predicted
          y: actual
```

### params.yaml (Configuración del Pipeline)

```yaml
# params.yaml
prepare:
  test_size: 0.2
  random_state: 42

features:
  numerical:
    - CreditScore
    - Age
    - Tenure
    - Balance
    - NumOfProducts
    - EstimatedSalary
  categorical:
    - Geography
    - Gender

train:
  n_estimators: 100
  max_depth: 10
  random_state: 42
```

### Comandos de Pipeline

```bash
# ════════════════════════════════════════════════════════════════════
# REPRODUCIR PIPELINE
# ════════════════════════════════════════════════════════════════════

# Ejecutar todo el pipeline
dvc repro

# Ejecutar stage específico (y sus dependencias)
dvc repro train

# Forzar re-ejecución (aunque no haya cambios)
dvc repro --force

# Ver qué se ejecutaría sin ejecutar
dvc repro --dry

# ════════════════════════════════════════════════════════════════════
# VISUALIZAR PIPELINE
# ════════════════════════════════════════════════════════════════════

# Ver DAG en terminal
dvc dag

# Generar imagen del DAG
dvc dag --dot | dot -Tpng -o pipeline.png

# Ver dependencias de un stage
dvc dag --outs train
```

### Visualización del DAG

```
╔═════════════════════════════════════════════════════════════════════════╗
║                         DVC DAG: BANKCHURN                              ║
╠═════════════════════════════════════════════════════════════════════════╣
║                                                                         ║
║                        ┌─────────────────┐                              ║
║                        │  data/raw/*.csv │                              ║
║                        │  configs/*.yaml │                              ║
║                        └────────┬────────┘                              ║
║                                 │                                       ║
║                                 ▼                                       ║
║                        ┌─────────────────┐                              ║
║                        │    prepare      │                              ║
║                        └────────┬────────┘                              ║
║                                 │                                       ║
║                                 ▼                                       ║
║                        ┌─────────────────┐                              ║
║                        │   featurize     │                              ║
║                        └────────┬────────┘                              ║
║                                 │                                       ║
║                     ┌───────────┴───────────┐                           ║
║                     ▼                       ▼                           ║
║            ┌─────────────────┐    ┌─────────────────┐                   ║
║            │     train       │    │    (test data)  │                   ║
║            └────────┬────────┘    └────────┬────────┘                   ║
║                     │                      │                            ║
║                     └──────────┬───────────┘                            ║
║                                ▼                                        ║
║                       ┌─────────────────┐                               ║
║                       │    evaluate     │                               ║
║                       └────────┬────────┘                               ║
║                                │                                        ║
║                                ▼                                        ║
║                       ┌─────────────────┐                               ║
║                       │    metrics/     │                               ║
║                       └─────────────────┘                               ║
║                                                                         ║
╚═════════════════════════════════════════════════════════════════════════╝
```

---

<a id="65-metricas"></a>

## 6.5 Métricas y Experimentos

### Tracking de Métricas

```bash
# Ver métricas actuales
dvc metrics show

# Comparar con otra rama/commit
dvc metrics diff HEAD~1

# Output ejemplo:
# Path                     Metric    HEAD     HEAD~1   Change
# metrics/eval_metrics.json  auc_roc   0.8721   0.8534   0.0187
# metrics/eval_metrics.json  f1        0.7234   0.7012   0.0222
```

### Experimentos con DVC

```bash
# ════════════════════════════════════════════════════════════════════
# EJECUTAR EXPERIMENTOS
# ════════════════════════════════════════════════════════════════════

# Experimento con cambio de parámetro
dvc exp run --set-param train.n_estimators=200

# Múltiples experimentos en paralelo
dvc exp run --queue --set-param train.n_estimators=100
dvc exp run --queue --set-param train.n_estimators=200
dvc exp run --queue --set-param train.n_estimators=300
dvc exp run --run-all --parallel 3

# ════════════════════════════════════════════════════════════════════
# COMPARAR EXPERIMENTOS
# ════════════════════════════════════════════════════════════════════

# Ver todos los experimentos
dvc exp show

# Output:
# ┏━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━┓
# ┃ Experiment    ┃ auc_roc     ┃ f1          ┃ n_estimators   ┃
# ┡━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━╇━━━━━━━━━━━━━╇━━━━━━━━━━━━━━━━┩
# │ main          │ 0.8721      │ 0.7234      │ 100            │
# │ exp-abc123    │ 0.8856      │ 0.7421      │ 200            │
# │ exp-def456    │ 0.8812      │ 0.7356      │ 300            │
# └───────────────┴─────────────┴─────────────┴────────────────┘

# ════════════════════════════════════════════════════════════════════
# APLICAR MEJOR EXPERIMENTO
# ════════════════════════════════════════════════════════════════════

# Aplicar a workspace
dvc exp apply exp-abc123

# O crear branch
dvc exp branch exp-abc123 feature/best-model
```

---

<a id="66-patrones-avanzados"></a>

## 6.6 Patrones Avanzados

### Multi-Output Stages

```yaml
# dvc.yaml
stages:
  split:
    cmd: python src/split.py
    deps:
      - data/raw/full_dataset.csv
    outs:
      - data/processed/train.csv
      - data/processed/val.csv
      - data/processed/test.csv
```

### Stages Condicionales (foreach)

```yaml
# dvc.yaml - Entrenar múltiples modelos
stages:
  train:
    foreach:
      - random_forest
      - xgboost
      - lightgbm
    do:
      cmd: python src/train.py --model ${item}
      deps:
        - src/train.py
        - data/processed/train.csv
      params:
        - train.${item}
      outs:
        - models/${item}.pkl
      metrics:
        - metrics/${item}_metrics.json:
            cache: false
```

### Integración con MLflow

```python
# src/bankchurn/training.py
import mlflow
import dvc.api
import yaml

def train():
    # Obtener parámetros de DVC
    params = dvc.api.params_show()
    
    with mlflow.start_run():
        # Log parámetros
        mlflow.log_params(params["train"])
        
        # Entrenar...
        model = train_model(params["train"])
        
        # Log métricas
        metrics = evaluate(model)
        mlflow.log_metrics(metrics)
        
        # Guardar métricas para DVC también
        with open("metrics/train_metrics.json", "w") as f:
            json.dump(metrics, f)
        
        # Log modelo
        mlflow.sklearn.log_model(model, "model")
```

---

<a id="66-ingenieria-inversa-dvc"></a>

## 6.6 🔬 Ingeniería Inversa Pedagógica: DVC Pipeline Real

> **Objetivo**: Entender CADA decisión detrás del `dvc.yaml` del portafolio.

### 6.6.1 🎯 El "Por Qué" Arquitectónico

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DECISIONES ARQUITECTÓNICAS DEL PORTAFOLIO                    │
├─────────────────────────────────────────────────────────────────────────────────┤
│  PROBLEMA 1: ¿Cómo garantizo que preprocesamiento se re-ejecuta si cambia algo? │
│  DECISIÓN: deps: [data/raw/Churn.csv, configs/config.yaml, script.py]           │
│  RESULTADO: DVC detecta cambios y re-ejecuta solo lo necesario                  │
│                                                                                 │
│  PROBLEMA 2: ¿Cómo evito re-entrenar si nada cambió?                            │
│  DECISIÓN: outs: [models/best_model.pkl] + DAG de dependencias                  │
│  RESULTADO: `dvc repro` es idempotente - solo ejecuta stages afectados          │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 6.6.2 🔍 Anatomía de `dvc.yaml`

**Archivo**: `ML-MLOps-Portfolio/BankChurn-Predictor/dvc.yaml`

```yaml
stages:
  preprocess:
    cmd: python data/preprocess.py --input data/raw/Churn.csv --output data/processed/churn_processed.csv
    deps:                           # Si CUALQUIERA cambia → re-ejecutar.
      - data/raw/Churn.csv          # Datos crudos.
      - configs/config.yaml         # Parámetros.
      - data/preprocess.py          # El script mismo.
    outs:
      - data/processed/churn_processed.csv

  train:
    cmd: python main.py --mode train --seed 42
    deps:
      - data/processed/churn_processed.csv  # Output del stage anterior (DAG).
      - main.py
    outs:
      - models/best_model.pkl
      - artifacts/training_results.json

  evaluate:
    cmd: python main.py --mode evaluate --model models/best_model.pkl
    deps:
      - models/best_model.pkl       # Depende del modelo entrenado.
    outs:
      - artifacts/metrics
```

### 6.6.3 🚨 Troubleshooting Preventivo

| Síntoma | Causa | Solución |
|---------|-------|----------|
| **Stage no se re-ejecuta** | Script no en `deps` | Añade el .py a deps. |
| **`dvc repro` ejecuta TODO** | Cache corrupto | `dvc gc -w` y re-ejecutar. |

---
 
<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en DVC

Aunque DVC parece “caja negra que falla”, en la práctica los errores suelen venir de **desalineación entre Git, datos y configuración**.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) Datos no aparecen al clonar el repo (`dvc pull`/`dvc checkout` olvidados)

**Síntomas típicos**

- Clonas el repositorio, ejecutas el código y obtienes errores como:
  ```text
  FileNotFoundError: data/raw/churn.csv not found
  ```
- La carpeta `data/` está vacía o solo tiene `.gitkeep`.

**Cómo identificarlo**

- Ejecuta:
  ```bash
  dvc list .
  dvc status
  ```
  para ver qué outs están trackeados.
- Mira si existen archivos `.dvc` (`data/raw/churn.csv.dvc`) pero no los datos reales.

**Cómo corregirlo**

- Después de clonar o cambiar de rama/tag, **siempre** ejecuta:
  ```bash
  dvc pull      # trae los datos desde el remote
  dvc checkout  # sincroniza versiones de datos con los .dvc actuales
  ```
- Documenta esto en el README del proyecto y en este módulo como parte del flujo estándar.

---

### 2) `.dvc` committeados pero remote sin configurar (`dvc push` fallando)

**Síntomas típicos**

- Haces `dvc push` y ves errores tipo:
  ```text
  ERROR: failed to push data to the cloud - config file error
  ```
  o credenciales faltantes.
- Compañeros de equipo tienen los `.dvc`, pero `dvc pull` no trae nada.

**Cómo identificarlo**

- Revisa `.dvc/config` para ver qué remote está configurado (`localremote`, `s3remote`, etc.).
- Ejecuta `dvc remote list` y valida que el remote por defecto (`-d`) exista y sea accesible.

**Cómo corregirlo**

- Asegúrate de que todos usen **el mismo nombre de remote** y que esté configurado en el repo (no solo en local).
- Para remotes cloud (S3, GCS): documenta las variables de entorno necesarias (`AWS_ACCESS_KEY_ID`, etc.).
- Haz un `dvc push` de prueba y luego un `dvc pull` desde otra máquina para validar.

---

### 3) `dvc repro` no ejecuta stages que esperas (cambios no detectados)

**Síntomas típicos**

- Modificas código o parámetros, ejecutas `dvc repro` y ves:
  ```text
  Stage 'train' didn't change, skipping
  ```
  aunque esperabas que volviera a entrenar.

**Cómo identificarlo**

- Mira el `dvc.yaml` y verifica que:
  - El script que cambiaste esté en `deps:` del stage.
  - Los parámetros que tocaste estén en `params:`.

**Cómo corregirlo**

- Asegúrate de listar **todas las dependencias reales** en `deps:` (scripts, configs, datos intermedios).
- Si cambiaste parámetros en `params.yaml`, agrégalos a la lista `params:` del stage correspondiente.
- Si quieres forzar una re-ejecución puntual, usa `dvc repro --force train`.

---

### 4) Conflictos entre `.gitignore` y `.dvc` (datos en Git por accidente)

**Síntomas típicos**

- Ves archivos grandes (`data/raw/*.csv`, `models/*.pkl`) en `git status`.
- Existen `.dvc` pero los datos también se han añadido a Git.

**Cómo identificarlo**

- Revisa `data/raw/.gitignore` generado por `dvc add` y el `.gitignore` del proyecto principal; puede que se estén pisando.

**Cómo corregirlo**

- Respeta el patrón DVC:
  - Los datos **no** se añaden a Git, solo los `.dvc`.
  - Asegúrate de que `.gitignore` incluya las carpetas de datos/artefactos y que no contradiga los `.gitignore` generados por DVC.
- Si ya has commiteado datos grandes, elimínalos del historial (o al menos del último commit) y deja solo los `.dvc`.

---

### 5) DVC + CI/CD: pipelines que fallan en GitHub Actions

**Síntomas típicos**

- En CI, `dvc repro` falla porque no encuentra datos o no tiene acceso al remote.

**Cómo identificarlo**

- Revisa el workflow de CI y verifica si:
  - Has instalado DVC con los extras correctos (`dvc[s3]`, etc.).
  - Has configurado variables de entorno con credenciales.
  - Estás ejecutando `dvc pull` **antes** de correr el pipeline.

**Cómo corregirlo**

- Añade pasos en tu workflow:
  ```yaml
  - name: Install DVC
    run: pip install "dvc[s3]"

  - name: Pull data with DVC
    run: dvc pull

  - name: Run pipeline
    run: dvc repro
  ```
- Usa `dvc repro --dry` localmente para ver qué debería ejecutarse antes de llevarlo a CI.

---

### Patrón general de debugging en DVC

1. **Inspecciona el estado** con `dvc status` y `dvc dag`.
2. **Verifica remotes y credenciales** (`dvc remote list`, `.dvc/config`).
3. **Comprueba deps/outs/params** en `dvc.yaml` para el stage problemático.
4. **Sincroniza Git + DVC**: `git checkout <tag/branch>` seguido de `dvc checkout` y `dvc pull` si hace falta.

Con este checklist, DVC pasa de ser “caja negra que falla” a una herramienta controlable para reproducir datos y pipelines.

---

<a id="67-ejercicio"></a>

## 6.7 Ejercicio Integrador

### Setup Completo de DVC

```bash
# 1. Inicializar DVC
cd bankchurn-predictor
dvc init

# 2. Configurar remote (local para empezar)
mkdir -p ~/dvc-storage
dvc remote add -d localremote ~/dvc-storage

# 3. Crear estructura de datos
mkdir -p data/{raw,processed} models metrics

# 4. Añadir datos raw
# (asumiendo que tienes churn.csv)
cp /path/to/churn.csv data/raw/
dvc add data/raw/churn.csv

# 5. Crear dvc.yaml (copiar del ejemplo anterior)

# 6. Crear params.yaml

# 7. Commit todo
git add .
git commit -m "data(dvc): setup DVC pipeline"

# 8. Ejecutar pipeline
dvc repro

# 9. Push a remote
dvc push
git push
```

### Checklist de Verificación

```
CONFIGURACIÓN:
[ ] DVC inicializado
[ ] Remote configurado y funcionando
[ ] Datos raw tracked con DVC

PIPELINE:
[ ] dvc.yaml con stages definidos
[ ] params.yaml con parámetros
[ ] dvc repro ejecuta sin errores

VERSIONADO:
[ ] Puedo hacer git checkout + dvc checkout a versiones anteriores
[ ] dvc push/pull funcionan correctamente
[ ] Métricas se trackean con dvc metrics show
```

---

<a id="68-autoevaluacion"></a>

## 6.8 Autoevaluación

### Preguntas de Reflexión

1. ¿Por qué DVC usa hashes MD5 en lugar de guardar los archivos?
2. ¿Qué pasa si cambio `params.yaml` pero no el código?
3. ¿Cuándo DVC salta un stage sin ejecutarlo?
4. ¿Cómo integrarías DVC con GitHub Actions para CI?

---

## 📦 Cómo se Usó en el Portafolio

El portafolio tiene DVC configurado a nivel global:

### Estructura DVC del Portafolio

```
ML-MLOps-Portfolio/
├── .dvc/                  # Configuración DVC
│   └── config             # Remote storage config
├── .dvc-storage/          # Remote local (para demo)
├── .dvcignore            # Archivos a ignorar
└── */data/raw/*.dvc       # Archivos .dvc en cada proyecto
```

### Archivos .dvc Reales

```bash
# BankChurn-Predictor/data/raw/bank_churn.csv.dvc
md5: abc123def456...
size: 1234567
path: bank_churn.csv

# CarVision-Market-Intelligence/data/raw/car_prices.csv.dvc
md5: xyz789ghi012...
size: 2345678
path: car_prices.csv
```

### Flujo de Datos en el Portafolio

```
┌──────────────────────────────────────────────────────────────┐
│                    FLUJO DE DATOS DVC                        │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  data/raw/*.csv    →    .dvc files    →    .dvc-storage/     │
│  (gitignored)           (tracked)          (remote local)    │
│                                                              │
│  Para CI/CD:                                                 │
│  git clone → dvc pull → datos disponibles                    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Comandos DVC del Portafolio

```bash
# Ver qué datos están trackeados
dvc status

# Obtener datos después de clonar
dvc pull

# Agregar nuevos datos
dvc add data/raw/nuevos_datos.csv
git add data/raw/nuevos_datos.csv.dvc data/raw/.gitignore
git commit -m "data(dvc): add nuevos_datos"
dvc push
```

### 🔧 Ejercicio: Trabaja con DVC Real

```bash
# 1. Ve a la raíz del portafolio
cd ML-MLOps-Portfolio

# 2. Verifica estado de DVC
dvc status

# 3. Obtén los datos (si no los tienes)
dvc pull

# 4. Verifica que los datos existen
ls -la BankChurn-Predictor/data/raw/
ls -la CarVision-Market-Intelligence/data/raw/

# 5. Experimenta: modifica params y reproduce
cd BankChurn-Predictor
dvc repro  # Si tienes dvc.yaml configurado
```

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **DVC vs Git LFS**: Explica que DVC es específico para ML (pipelines, métricas), LFS es genérico para archivos grandes.

2. **Reproducibilidad**: Menciona que puedes recrear cualquier experimento con `dvc checkout` + `git checkout`.

3. **Data Lineage**: Explica cómo DVC trackea la procedencia de datos transformados.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Datos sensibles | Usa DVC con storage encriptado (S3 + KMS) |
| Datasets grandes | Usa `dvc push/pull` selectivo por carpeta |
| CI/CD | Cachea datos en CI para evitar descargas repetidas |
| Colaboración | Documenta dónde está el remote storage |

### Flujo Profesional de Datos

1. Raw data → nunca modificar, solo agregar
2. Processed data → versionado con DVC
3. Features → cacheados para reutilización
4. Modelos → versionados con métricas


---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **DVC Tutorial - Data Version Control** | DVCorg | 12 min | [YouTube](https://www.youtube.com/watch?v=kLKBcPonMYw) |
| 🔴 | **DVC Pipelines Deep Dive** | DVCorg | 18 min | [YouTube](https://www.youtube.com/watch?v=71IGzyH95UY) |
| 🟡 | **MLOps with DVC and CML** | DataTalksClub | 45 min | [YouTube](https://www.youtube.com/watch?v=9BgIDqAzfuA) |

### 📚 Cursos

| 🏷️ | Título | Plataforma | Duración | Link |
|:--:|:-------|:-----------|:--------:|:-----|
| 🟡 | Iterative Tools for ML | DVCorg | 4h | [Learn.iterative.ai](https://learn.iterative.ai/) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [DVC Get Started](https://dvc.org/doc/start) | Tutorial oficial paso a paso |
| 🟡 | [DVC Remote Storage](https://dvc.org/doc/user-guide/data-management/remote-storage) | Configuración de remotes S3/GCS |

---

## ⚖️ Decisión Técnica: ADR-009 DVC

**Contexto**: Necesitamos versionar datasets grandes sin guardarlos en Git.

**Decisión**: Usar DVC (Data Version Control).

**Alternativas Consideradas**:
- **Git LFS**: Pago por storage, menos features
- **S3 directo**: Sin versionado semántico
- **Delta Lake**: Overkill para nuestro tamaño

**Consecuencias**:
- ✅ Versionado semántico de datos
- ✅ Pipelines reproducibles con `dvc.yaml`
- ✅ Integración con Git (`.dvc` files)
- ❌ Curva de aprendizaje adicional

---

## 🔧 Ejercicios del Módulo

### Ejercicio 6.1: Inicializar DVC
**Objetivo**: Configurar DVC en un proyecto.
**Dificultad**: ⭐⭐

```bash
# TU TAREA: Ejecutar y documentar cada paso

# 1. Inicializar DVC
dvc init

# 2. Añadir remote local (para práctica)
dvc remote add -d localremote /tmp/dvc-storage

# 3. Trackear datos
dvc add data/raw/dataset.csv

# 4. Commitear archivos .dvc
git add data/raw/dataset.csv.dvc data/raw/.gitignore
git commit -m "chore(data): track dataset with DVC"

# PREGUNTA: ¿Qué archivos se crean? ¿Qué contiene el .dvc?
```

<details>
<summary>💡 Ver solución</summary>

**Archivos creados:**
- `data/raw/dataset.csv.dvc` — Metadatos del archivo (hash MD5)
- `data/raw/.gitignore` — Ignora el archivo real, trackea solo el `.dvc`

**Contenido del .dvc:**
```yaml
outs:
- md5: abc123def456...
  size: 1234567
  path: dataset.csv
```

**Flujo completo:**
```bash
# Inicializar
dvc init
git add .dvc .dvcignore
git commit -m "chore: initialize DVC"

# Configurar remote
dvc remote add -d myremote s3://my-bucket/dvc-storage
git add .dvc/config
git commit -m "chore(dvc): configure S3 remote"

# Trackear datos
dvc add data/raw/dataset.csv
git add data/raw/dataset.csv.dvc data/raw/.gitignore
git commit -m "chore(data): track dataset with DVC"

# Push datos al remote
dvc push
```
</details>

---

### Ejercicio 6.2: Pipeline DVC
**Objetivo**: Definir pipeline reproducible.
**Dificultad**: ⭐⭐

```yaml
# dvc.yaml
# TU TAREA: Definir pipeline de 3 stages

stages:
  prepare:
    cmd: python src/data.py
    deps:
      # ¿Qué dependencias?
    outs:
      # ¿Qué outputs?

  train:
    cmd: python src/training.py
    deps:
      # ???
    outs:
      # ???
    metrics:
      # ???

  evaluate:
    cmd: python src/evaluate.py
    deps:
      # ???
    metrics:
      # ???
```

<details>
<summary>💡 Ver solución</summary>

```yaml
stages:
  prepare:
    cmd: python src/data.py
    deps:
      - src/data.py
      - data/raw/dataset.csv
    outs:
      - data/processed/train.csv
      - data/processed/test.csv

  train:
    cmd: python src/training.py
    deps:
      - src/training.py
      - data/processed/train.csv
    params:
      - train.n_estimators
      - train.max_depth
    outs:
      - models/model.joblib
    metrics:
      - metrics/train_metrics.json:
          cache: false

  evaluate:
    cmd: python src/evaluate.py
    deps:
      - src/evaluate.py
      - models/model.joblib
      - data/processed/test.csv
    metrics:
      - metrics/eval_metrics.json:
          cache: false
    plots:
      - plots/confusion_matrix.png
```

**Ejecutar pipeline:**
```bash
dvc repro          # Ejecuta stages necesarios
dvc metrics show   # Muestra métricas
dvc plots show     # Genera visualizaciones
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **DVC** | Data Version Control - herramienta para versionar datos y pipelines ML |
| **Remote Storage** | Almacenamiento externo (S3, GCS, Azure) para datos versionados |
| **dvc.yaml** | Archivo que define stages de un pipeline reproducible |
| **dvc.lock** | Archivo generado con hashes exactos de cada stage ejecutado |

---

## 🏁 CHECKPOINT FASE 1: Fundamentos Completados

> 🎯 **¡Has completado los módulos 01-06!**
>
> Ahora tienes las bases de un MLOps Engineer profesional:
> - ✅ Python moderno con type hints y Pydantic
> - ✅ Diseño de sistemas ML
> - ✅ Estructura de proyectos profesional
> - ✅ Entornos reproducibles
> - ✅ Git profesional con pre-commit
> - ✅ Versionado de datos con DVC

---

### 📋 Examen de Hito 1: Setup Profesional

> **Formato**: Self-Correction Code Review  
> **Duración**: 45-60 minutos  
> **Puntaje mínimo**: 70/100

#### Ejercicio de Examen: Type Hints y Estructura

**Código a Revisar:**
```python
# archivo: src/bankchurn/training.py

def load_data(path):
    """Carga datos desde CSV."""
    import pandas as pd
    return pd.read_csv(path)

def prepare_features(df, target_col, features):
    X = df[features]
    y = df[target_col]
    return X, y

def train_model(X, y, n_estimators=100, max_depth=None):
    from sklearn.ensemble import RandomForestClassifier
    model = RandomForestClassifier(n_estimators=n_estimators, max_depth=max_depth)
    model.fit(X, y)
    return model
```

**Tu tarea**: Identifica TODOS los errores y propón correcciones.

<details>
<summary>📝 Ver Solución del Examen</summary>

**Errores Encontrados:**

| # | Problema | Severidad | Corrección |
|---|----------|-----------|------------|
| 1 | `load_data(path)` sin type hints | 🟡 | `path: str \| Path` → `pd.DataFrame` |
| 2 | Import dentro de función | 🟢 | Mover imports al inicio |
| 3 | `prepare_features` sin tipos | 🟡 | Añadir tipos a parámetros y retorno |
| 4 | `train_model` sin tipo retorno | 🟡 | `-> RandomForestClassifier` |
| 5 | Sin `random_state` | 🟡 | Añadir para reproducibilidad |

**Código Corregido:**
```python
from pathlib import Path
from typing import Tuple, Sequence, Optional
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

def load_data(path: str | Path) -> pd.DataFrame:
    """Carga datos desde CSV."""
    return pd.read_csv(path)

def prepare_features(
    df: pd.DataFrame,
    target_col: str,
    features: Sequence[str]
) -> Tuple[pd.DataFrame, pd.Series]:
    """Separa features y target."""
    return df[list(features)], df[target_col]

def train_model(
    X: pd.DataFrame,
    y: pd.Series,
    n_estimators: int = 100,
    max_depth: Optional[int] = None
) -> RandomForestClassifier:
    """Entrena modelo Random Forest."""
    model = RandomForestClassifier(
        n_estimators=n_estimators,
        max_depth=max_depth,
        random_state=42
    )
    return model.fit(X, y)
```
</details>

---

### 🎤 Simulacro de Entrevista: Nivel Junior

> **50 preguntas** para validar fundamentos (Módulos 01-06)
> **Tiempo**: 60 minutos
> **Objetivo**: Preparación para posiciones Junior ML Engineer

#### Preguntas de Muestra

**Python Moderno (10 preguntas)**
1. ¿Qué son los type hints y por qué usarlos en ML?
2. ¿Diferencia entre `dataclass` y Pydantic `BaseModel`?
3. ¿Qué hace `Field(ge=0, le=100)` en Pydantic?

**Estructura de Proyecto (8 preguntas)**
4. ¿Por qué usar `src/` layout en vez de flat layout?
5. ¿Qué es `pip install -e .` y cuándo usarlo?
6. ¿Qué debe contener un `pyproject.toml` mínimo?

**Git Profesional (8 preguntas)**
7. ¿Qué es un Conventional Commit? Da un ejemplo.
8. ¿Para qué sirve pre-commit y qué hooks usarías?
9. ¿Diferencia entre `git merge` y `git rebase`?

**DVC y Datos (8 preguntas)**
10. ¿Por qué no versionar datos directamente en Git?
11. ¿Qué contiene un archivo `.dvc`?
12. ¿Cómo reproducir un experimento con DVC?

<details>
<summary>💡 Ver Respuestas de Muestra</summary>

**1. Type hints en ML:**
> Documentan tipos esperados, ayudan al IDE con autocompletado, y permiten validación estática con mypy. En ML, evitan errores como pasar un `np.array` donde se esperaba `pd.DataFrame`.

**4. src/ layout:**
> Evita que Python importe el código local en vez del paquete instalado. Es el estándar profesional que permite `pip install -e .` y tests aislados.

**7. Conventional Commit:**
> `feat(training): add cross-validation support`
> - `feat`: nueva funcionalidad
> - `(training)`: scope/módulo afectado
> - descripción en imperativo

**11. Archivo .dvc:**
> Contiene el hash MD5 del archivo real, su tamaño y path. El archivo real se ignora en Git y se almacena en el remote de DVC.
</details>

---

[Ver simulacro completo →](SIMULACRO_ENTREVISTA_JUNIOR.md)

---

## 🪤 La Trampa — Errores Comunes de Este Módulo

### Trampa 1: dvc add en archivo ya trackeado por Git

**Síntoma**:
```bash
dvc add data/customers.csv
# ERROR: data/customers.csv is already tracked by Git
```

**Solución**:
```bash
# 1. Remover de Git (mantener archivo local)
git rm --cached data/customers.csv

# 2. Ahora sí, añadir a DVC
dvc add data/customers.csv

# 3. Commitear el .dvc y .gitignore
git add data/customers.csv.dvc data/.gitignore
git commit -m "data: track customers.csv with DVC"
```

---

### Trampa 2: dvc repro no detecta cambios en código

**Síntoma**:
```bash
# Modifico train.py
vim src/bankchurn/train.py

dvc repro
# "Stage 'train' didn't change, skipping"  ← ¡Debería re-ejecutar!
```

**Causa raíz**: El archivo modificado no está en `deps:` del stage.

**Solución**:
```yaml
# dvc.yaml
stages:
  train:
    cmd: python src/bankchurn/train.py
    deps:
      - src/bankchurn/train.py      # ← El script
      - src/bankchurn/pipeline.py   # ← Dependencias del script
      - data/processed/train.csv    # ← Datos
    outs:
      - models/model.pkl
```

---

### Trampa 3: dvc pull falla silenciosamente

**Síntoma**:
```bash
dvc pull
# (sin output)
ls data/
# (vacío o archivos antiguos)
```

**Solución**:
```bash
# Verificar configuración
dvc remote list
dvc remote default

# Pull con verbose
dvc pull -v
```

---

## 📝 Quiz del Módulo — Semanas 5-6

### Quiz Semana 5: DVC Fundamentos

#### Pregunta 1 (25 pts)
¿Cuál es la diferencia fundamental entre Git LFS y DVC?

<details>
<summary>✅ Respuesta</summary>

| Aspecto | Git LFS | DVC |
|---------|---------|-----|
| **Storage** | GitHub (pago por ancho de banda) | Tu propio storage (S3, GCS, local) |
| **Pipelines** | ❌ No | ✅ `dvc.yaml` con DAGs |
| **Experimentos** | ❌ No | ✅ `dvc exp run` |
| **Cache** | ❌ No | ✅ Reutiliza artefactos |
</details>

#### Pregunta 2 (25 pts)
¿Qué hace `dvc add data/raw.csv` internamente?

<details>
<summary>✅ Respuesta</summary>

1. **Calcula hash MD5** del archivo
2. **Crea `data/raw.csv.dvc`** (puntero con el hash)
3. **Añade `data/raw.csv` a `.gitignore`**
4. **Mueve el archivo al cache** (`.dvc/cache/`)
</details>

#### Pregunta 3 (25 pts)
¿Por qué `dvc repro` no re-ejecuta si no hay cambios?

<details>
<summary>✅ Respuesta</summary>

DVC trackea **hashes de deps y outs** en `dvc.lock`. En `dvc repro`:
1. Calcula hashes actuales de deps
2. Compara con `dvc.lock`
3. Si coinciden → skip
4. Si difieren → re-ejecuta y actualiza lock
</details>

#### 🔧 Ejercicio Práctico (25 pts)

Escribe un `dvc.yaml` con dos stages:
1. `prepare`: lee `data/raw.csv`, genera `data/processed.csv`
2. `train`: lee `data/processed.csv` + `src/train.py`, genera `models/model.pkl`

<details>
<summary>✅ Solución</summary>

```yaml
stages:
  prepare:
    cmd: python src/prepare.py
    deps:
      - src/prepare.py
      - data/raw.csv
    outs:
      - data/processed.csv

  train:
    cmd: python src/train.py
    deps:
      - src/train.py
      - data/processed.csv
    outs:
      - models/model.pkl
    metrics:
      - metrics.json:
          cache: false
```
</details>

---

## 🔜 Siguiente Fase: ML Engineering

Con los fundamentos completados, es hora de construir **pipelines de sklearn avanzados**.

**[Comenzar Fase 2 → Módulo 07: sklearn Pipelines](07_SKLEARN_PIPELINES.md)**

---

<div align="center">

[← Git Profesional](05_GIT_PROFESIONAL.md) | [Siguiente: sklearn Pipelines →](07_SKLEARN_PIPELINES.md)

</div>
