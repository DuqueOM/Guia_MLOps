# 12. CI/CD con GitHub Actions
 
 <a id="00-prerrequisitos"></a>
 
 ## 0.0 Prerrequisitos
 
 - Tener una cuenta de GitHub y saber abrir Pull Requests.
 - Haber ejecutado `pytest` localmente al menos una vez en un proyecto del portafolio.
 - Conocer la ubicación del workflow real: `.github/workflows/ci-mlops.yml`.
 
 ---
 
 <a id="01-protocolo-e-como-estudiar-este-modulo"></a>
 
 ## 0.1 🧠 Protocolo E: Cómo estudiar este módulo
 
 - **Antes de empezar**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define el output mínimo (un workflow que corre en PR).
 - **Durante el debugging**: si te atoras >15 min (YAML, permisos, paths, matrix), registra el caso en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
 - **Al cierre de semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para evaluar si CI te protege de regressions.
 
 ---
 
 <a id="02-entregables-verificables-minimo-viable"></a>
 
 ## 0.2 ✅ Entregables verificables (mínimo viable)
 
 - [ ] Un workflow que corre en `push` y `pull_request`.
 - [ ] Matrix con (mínimo) 2 versiones de Python.
 - [ ] Tests con coverage y threshold (`--cov-fail-under`).
 - [ ] Al menos 1 check de seguridad (Bandit o secret scanning).
 - [ ] Evidencia en GitHub Actions (runs verdes + artifacts si aplica).
 
 ---
 
 <a id="03-puente-teoria-codigo-portafolio"></a>
 
 ## 0.3 🧩 Puente teoría ↔ código (Portafolio)
 
 - **Concepto**: CI (validación automática) + gates (coverage/security) + CD (build/push)
 - **Archivo**: `.github/workflows/ci-mlops.yml`
 - **Prueba**: abre un PR y verifica que corran jobs por `project` y `python-version`.
 
 ## 🎯 Objetivo del Módulo
 
 Implementar un pipeline CI/CD profesional que valide automáticamente tu código en cada push, como el workflow `ci-mlops.yml` del portafolio.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  🔄 CI/CD = Tu Guardián Automático                                          ║
║                                                                              ║
║  ANTES (sin CI/CD):                                                          ║
║  • "Olvidé correr los tests antes de mergear"                                ║
║  • "Rompí producción con un cambio pequeño"                                  ║
║  • "No sabía que mi código no pasaba linting"                                ║
║                                                                              ║
║  DESPUÉS (con CI/CD):                                                        ║
║  • Cada push ejecuta tests automáticamente                                   ║
║  • No puedes mergear si los tests fallan                                     ║
║  • Coverage, linting, y seguridad verificados siempre                        ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 📋 Contenido

- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
- **12.1** [Anatomía de un Workflow](#121-anatomia-de-un-workflow)
- **12.2** [Matrix Testing: Múltiples Versiones](#122-matrix-testing-multiples-versiones)
- **12.3** [Coverage Enforcement](#123-coverage-enforcement)
- **12.4** [Security Scanning](#124-security-scanning)
- **12.5** [Docker Build y Push](#125-docker-build-y-push)
- **12.6** [El Workflow Completo del Portafolio](#126-el-workflow-completo-del-portafolio)
- [Errores habituales](#errores-habituales)
- [✅ Ejercicio](#ejercicio)
- [✅ Checkpoint](#checkpoint)

---

<a id="121-anatomia-de-un-workflow"></a>

## 12.1 Anatomía de un Workflow

### Estructura Básica

```yaml
# .github/workflows/ci.yml

name: CI Pipeline                    # Nombre visible en GitHub

on:                                   # ¿Cuándo ejecutar?
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:                                 # ¿Qué ejecutar?
  test:
    runs-on: ubuntu-latest           # Sistema operativo
    steps:                           # Pasos secuenciales
      - uses: actions/checkout@v4    # Paso 1: Descargar código
      - uses: actions/setup-python@v5 # Paso 2: Configurar Python
        with:
          python-version: '3.11'
      - run: pip install -r requirements.txt  # Paso 3: Instalar deps
      - run: pytest                           # Paso 4: Correr tests
```

### Analogía: La Línea de Inspección de Calidad

```
╔═══════════════════════════════════════════════════════════════════════════╗
║  🏭 IMAGINA UNA FÁBRICA DE AUTOS:                                         ║
║                                                                           ║
║  Workflow = Línea de inspección de calidad                                ║
║                                                                           ║
║  on (trigger):                                                            ║
║  → "Cada vez que un auto nuevo llega a la línea"                          ║
║                                                                           ║
║  jobs:                                                                    ║
║  → Diferentes estaciones de inspección                                    ║
║                                                                           ║
║  steps:                                                                   ║
║  → Tareas específicas en cada estación                                    ║
║                                                                           ║
║  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐                    ║
║  │ Checkout│──►│ Install │──►│  Test   │──►│  Build  │                    ║
║  │  (get   │   │  (prep  │   │  (run   │   │ (create │                    ║
║  │  code)  │   │  tools) │   │  tests) │   │ Docker) │                    ║
║  └─────────┘   └─────────┘   └─────────┘   └─────────┘                    ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

---

<a id="122-matrix-testing-multiples-versiones"></a>

## 12.2 Matrix Testing: Múltiples Versiones

### El Problema: "Funciona en mi versión de Python"

```yaml
# ❌ ANTES: Solo pruebas con una versión
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'  # ¿Y si alguien usa 3.12?
```

### La Solución: Matrix Strategy

```yaml
# ✅ DESPUÉS: Pruebas con múltiples versiones
# Código REAL de ci-mlops.yml del portafolio

jobs:
  tests:
    name: Tests & Coverage               # Nombre visible en GitHub Actions UI.
    runs-on: ubuntu-latest               # Runner: máquina virtual donde corre el job.
    strategy:
      fail-fast: false                   # false: sigue ejecutando otros jobs aunque uno falle.
      matrix:
        python-version: ['3.11', '3.12'] # Matrix: ejecuta el job con cada valor.
        project:                         # Segundo eje del matrix: proyectos.
          - BankChurn-Predictor
          - CarVision-Market-Intelligence
          - TelecomAI-Customer-Intelligence
    
    # Esto crea 2 x 3 = 6 jobs paralelos:
    # - BankChurn con Python 3.11        # Cada combinación es un job independiente.
    # - BankChurn con Python 3.12
    # - CarVision con Python 3.11
    # - CarVision con Python 3.12
    # - TelecomAI con Python 3.11
    # - TelecomAI con Python 3.12
    
    steps:
      - name: Checkout code              # Paso: clona el repositorio.
        uses: actions/checkout@v4        # Action oficial de GitHub para checkout.
      
      - name: Set up Python ${{ matrix.python-version }}  # ${{ }}: expresión de GitHub Actions.
        uses: actions/setup-python@v5    # Instala Python en el runner.
        with:
          python-version: ${{ matrix.python-version }}  # Usa el valor del matrix.
          cache: 'pip'                   # Cachea ~/.cache/pip → installs más rápidos.
      
      - name: Install dependencies
        working-directory: ${{ matrix.project }}  # cd al proyecto antes de ejecutar.
        run: |                           # run: ejecuta comandos shell.
          python -m pip install --upgrade pip      # Actualiza pip primero.
          pip install -r requirements.txt          # Instala dependencias del proyecto.
          pip install pytest pytest-cov            # Instala herramientas de testing.
      
      - name: Run tests
        working-directory: ${{ matrix.project }}
        run: pytest --cov=src/ --cov-fail-under=80  # --cov-fail-under: falla si coverage < 80%.
```

### Visualización del Matrix

```
                    Python 3.11          Python 3.12
                  ┌─────────────┐      ┌─────────────┐
BankChurn         │   Job 1     │      │   Job 2     │
                  │   ✅ Pass   │      │   ✅ Pass  │
                  └─────────────┘      └─────────────┘

                  ┌─────────────┐      ┌─────────────┐
CarVision         │   Job 3     │      │   Job 4     │
                  │   ✅ Pass   │      │   ✅ Pass  │
                  └─────────────┘      └─────────────┘

                  ┌─────────────┐      ┌─────────────┐
TelecomAI         │   Job 5     │      │   Job 6     │
                  │   ✅ Pass   │      │   ✅ Pass  │
                  └─────────────┘      └─────────────┘

Total: 6 jobs ejecutándose EN PARALELO
```

---

<a id="123-coverage-enforcement"></a>

## 12.3 Coverage Enforcement

### Thresholds por Proyecto

```yaml
# Código REAL de ci-mlops.yml

- name: Run tests with coverage
  working-directory: ${{ matrix.project }}
  run: |
    # Cada proyecto puede tener diferente threshold
    if [ "${{ matrix.project }}" = "BankChurn-Predictor" ]; then
      COV_TARGET="src"
      THRESHOLD=79
    elif [ "${{ matrix.project }}" = "CarVision-Market-Intelligence" ]; then
      COV_TARGET="src/carvision"
      THRESHOLD=80
    else
      COV_TARGET="src/telecom"
      THRESHOLD=80
    fi
    
    pytest --maxfail=1 --disable-warnings -q \
      -m "not slow" \
      --cov=$COV_TARGET \
      --cov-report=xml \
      --cov-report=term-missing \
      --cov-fail-under=$THRESHOLD  # ← FALLA si está por debajo
```

### Upload de Coverage a Codecov

```yaml
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v5
  with:
    files: ${{ matrix.project }}/coverage.xml
    flags: ${{ matrix.project }}
    name: ${{ matrix.project }}-coverage-${{ matrix.python-version }}
    fail_ci_if_error: false  # No fallar si Codecov tiene problemas

- name: Upload coverage artifact
  uses: actions/upload-artifact@v5
  with:
    name: coverage-${{ matrix.project }}-py${{ matrix.python-version }}
    path: ${{ matrix.project }}/coverage.xml
    retention-days: 30
```

---

<a id="124-security-scanning"></a>

## 12.4 Security Scanning

### Múltiples Capas de Seguridad

```yaml
# Job de seguridad - Código REAL del portafolio

security-scan:
  name: Security Scan
  runs-on: ubuntu-latest
  needs: [tests]  # Solo corre si tests pasan
  
  steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Necesario para gitleaks (analiza historial)
    
    # 1. GITLEAKS: Detecta secretos en el código
    - name: Gitleaks (Secret Detection)
      uses: gitleaks/gitleaks-action@v2
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    
    # 2. BANDIT: Análisis de seguridad de Python
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.12'
    
    - name: Run Bandit
      run: |
        pip install bandit
        for project in BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence; do
          echo "Scanning $project..."
          bandit -r "$project/src" -f json -o "bandit-$project.json" || true
        done
    
    # 3. PIP-AUDIT: Vulnerabilidades en dependencias
    - name: Run pip-audit
      run: |
        pip install pip-audit
        for project in BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence; do
          echo "Auditing $project..."
          pip-audit -r "$project/requirements.txt" --format json || true
        done
```

### TRIVY: Escaneo de Imágenes Docker

```yaml
docker-security:
  name: Docker Security Scan
  runs-on: ubuntu-latest
  needs: [docker-build]
  
  steps:
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'ml-portfolio-bankchurn:latest'
        format: 'sarif'
        output: 'trivy-results.sarif'
        severity: 'CRITICAL,HIGH'
    
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: 'trivy-results.sarif'
```

---

<a id="125-docker-build-y-push"></a>

## 12.5 Docker Build y Push

### Build Multi-Proyecto

```yaml
docker-build:
  name: Docker Build
  runs-on: ubuntu-latest
  needs: [tests, quality-gates]
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  
  strategy:
    matrix:
      include:
        - project: BankChurn-Predictor
          image: ml-portfolio-bankchurn
        - project: CarVision-Market-Intelligence
          image: ml-portfolio-carvision
        - project: TelecomAI-Customer-Intelligence
          image: ml-portfolio-telecom
  
  steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Login to GitHub Container Registry
      uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        context: ./${{ matrix.project }}
        push: true
        tags: |
          ghcr.io/${{ github.repository_owner }}/${{ matrix.image }}:latest
          ghcr.io/${{ github.repository_owner }}/${{ matrix.image }}:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

---

<a id="126-el-workflow-completo-del-portafolio"></a>

## 12.6 El Workflow Completo del Portafolio

### Diagrama del Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CI/CD Pipeline: ci-mlops.yml                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TRIGGER: push to main/develop OR pull_request to main                      │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         JOB 1: tests                                │    │
│  │  Matrix: Python 3.11/3.12 × 3 proyectos = 6 jobs paralelos          │    │
│  │                                                                     │    │
│  │  Steps:                                                             │    │
│  │  1. Checkout code                                                   │    │
│  │  2. Setup Python (con cache)                                        │    │
│  │  3. Install dependencies                                            │    │
│  │  4. Run linting (flake8, black, isort)                              │    │
│  │  5. Run tests with coverage                                         │    │
│  │  6. Upload coverage to Codecov                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      JOB 2: quality-gates                           │    │
│  │  needs: [tests]                                                     │    │
│  │                                                                     │    │
│  │  Steps:                                                             │    │
│  │  1. Check Black formatting                                          │    │
│  │  2. Check import sorting (isort)                                    │    │
│  │  3. Run flake8 strict                                               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      JOB 3: security-scan                           │    │
│  │  needs: [tests]                                                     │    │
│  │                                                                     │    │
│  │  Steps:                                                             │    │
│  │  1. Gitleaks (secretos)                                             │    │
│  │  2. Bandit (código Python)                                          │    │
│  │  3. pip-audit (dependencias)                                        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      JOB 4: docker-build                            │    │
│  │  needs: [tests, quality-gates]                                      │    │
│  │  if: push to main                                                   │    │
│  │                                                                     │    │
│  │  Steps:                                                             │    │
│  │  1. Setup Docker Buildx                                             │    │
│  │  2. Login to GHCR                                                   │    │
│  │  3. Build multi-stage images                                        │    │
│  │  4. Push to registry                                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                        JOB 5: e2e-test                              │    │
│  │  needs: [docker-build]                                              │    │
│  │                                                                     │    │
│  │  Steps:                                                             │    │
│  │  1. Start Docker Compose stack                                      │    │
│  │  2. Wait for services                                               │    │
│  │  3. Run API health checks                                           │    │
│  │  4. Run integration tests                                           │    │
│  │  5. Cleanup                                                         │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### El Archivo Completo

```yaml
# .github/workflows/ci-mlops.yml - Versión simplificada del portafolio

name: CI/CD MLOps Portfolio

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

permissions:
  actions: read
  contents: read
  security-events: write
  packages: write

env:
  PYTHON_VERSION: '3.12'

jobs:
  # ═══════════════════════════════════════════════════════════════════════════
  # JOB 1: Tests con Coverage
  # ═══════════════════════════════════════════════════════════════════════════
  tests:
    name: Tests & Coverage
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        python-version: ['3.11', '3.12']
        project:
          - BankChurn-Predictor
          - CarVision-Market-Intelligence
          - TelecomAI-Customer-Intelligence
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'
      
      - name: Install dependencies
        working-directory: ${{ matrix.project }}
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt 2>/dev/null || pip install -e .
          pip install pytest pytest-cov flake8 black isort mypy
      
      - name: Run linting
        working-directory: ${{ matrix.project }}
        run: |
          flake8 src/ --count --select=E9,F63,F7,F82 --show-source --statistics || true
          black --check src/ || true
      
      - name: Run tests with coverage
        working-directory: ${{ matrix.project }}
        run: |
          # Determinar threshold por proyecto
          if [ "${{ matrix.project }}" = "BankChurn-Predictor" ]; then
            THRESHOLD=79
          else
            THRESHOLD=80
          fi
          
          pytest -m "not slow" \
            --cov=src/ \
            --cov-report=xml \
            --cov-report=term-missing \
            --cov-fail-under=$THRESHOLD
      
      - name: Upload coverage
        uses: codecov/codecov-action@v5
        with:
          files: ${{ matrix.project }}/coverage.xml
          flags: ${{ matrix.project }}
  
  # ═══════════════════════════════════════════════════════════════════════════
  # JOB 2: Quality Gates
  # ═══════════════════════════════════════════════════════════════════════════
  quality-gates:
    name: Quality Gates
    runs-on: ubuntu-latest
    needs: [tests]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Install tools
        run: pip install black flake8 isort
      
      - name: Check formatting
        run: |
          for project in BankChurn-Predictor CarVision-Market-Intelligence TelecomAI-Customer-Intelligence; do
            echo "Checking $project..."
            black --check "$project/src" "$project/app" 2>/dev/null || true
            isort --check-only "$project/src" 2>/dev/null || true
          done
  
  # ═══════════════════════════════════════════════════════════════════════════
  # JOB 3: Security Scan
  # ═══════════════════════════════════════════════════════════════════════════
  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: [tests]
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Run Bandit
        run: |
          pip install bandit
          bandit -r */src/ -f json -o bandit-report.json || true
      
      - name: Upload security report
        uses: actions/upload-artifact@v5
        with:
          name: security-reports
          path: bandit-report.json
  
  # ═══════════════════════════════════════════════════════════════════════════
  # JOB 4: Docker Build (solo en main)
  # ═══════════════════════════════════════════════════════════════════════════
  docker-build:
    name: Docker Build
    runs-on: ubuntu-latest
    needs: [tests, quality-gates]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    strategy:
      matrix:
        include:
          - project: BankChurn-Predictor
            image: ml-portfolio-bankchurn
          - project: CarVision-Market-Intelligence
            image: ml-portfolio-carvision
          - project: TelecomAI-Customer-Intelligence
            image: ml-portfolio-telecom
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: ./${{ matrix.project }}
          push: true
          tags: |
            ghcr.io/${{ github.repository_owner }}/${{ matrix.image }}:latest
            ghcr.io/${{ github.repository_owner }}/${{ matrix.image }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

---

<a id="127-workflows-avanzados-mlops"></a>

## 12.7 Workflows Avanzados de MLOps ⭐ NUEVO

El portafolio incluye workflows especializados para ML que van más allá del CI/CD tradicional. Estos workflows automatizan tareas críticas como detección de drift, reentrenamiento y comparación de modelos.

### Workflows Disponibles en el Portafolio

```
.github/workflows/
├── ci-mlops.yml              # CI/CD principal (ya cubierto)
├── drift-detection.yml       # Detecta drift de datos/modelo
├── drift-bankchurn.yml       # Drift específico para BankChurn
├── retrain-bankchurn.yml     # Reentrenamiento automático
├── cml-training-comparison.yml # Comparación de runs con CML
└── docs.yml                  # Build de documentación
```

### 12.7.1 Drift Detection: Monitoreo Automático

```yaml
# .github/workflows/drift-detection.yml (simplificado)
name: Drift Detection

on:
  schedule:
    - cron: '0 6 * * 1'  # Cada lunes a las 6 AM
  workflow_dispatch:      # También manual

jobs:
  detect-drift:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        project: [BankChurn-Predictor, CarVision-Market-Intelligence]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      
      - name: Install dependencies
        run: |
          pip install evidently pandas scikit-learn joblib
      
      - name: Run drift detection
        working-directory: ${{ matrix.project }}
        run: |
          python scripts/detect_drift.py \
            --reference data/reference.csv \
            --current data/production.csv \
            --output reports/drift_report.html
      
      - name: Upload drift report
        uses: actions/upload-artifact@v5
        with:
          name: drift-report-${{ matrix.project }}
          path: ${{ matrix.project }}/reports/drift_report.html
      
      - name: Create issue if drift detected
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: '⚠️ Drift detectado en ${{ matrix.project }}',
              body: 'El workflow de drift detection ha detectado cambios significativos. Ver artifacts para detalles.',
              labels: ['drift', 'ml-ops', 'automated']
            })
```

### 12.7.2 Retrain Automático: Cuando el Modelo Necesita Actualización

```yaml
# .github/workflows/retrain-bankchurn.yml (simplificado)
name: Retrain BankChurn Model

on:
  workflow_dispatch:
    inputs:
      reason:
        description: 'Razón del reentrenamiento'
        required: true
        default: 'scheduled-retrain'
      promote_if_better:
        description: '¿Promover automáticamente si mejora métricas?'
        required: true
        default: 'false'
        type: boolean

env:
  PROJECT: BankChurn-Predictor
  MLFLOW_TRACKING_URI: http://localhost:5000

jobs:
  retrain:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      
      - name: Install dependencies
        working-directory: ${{ env.PROJECT }}
        run: pip install -r requirements.txt
      
      - name: Train new model
        working-directory: ${{ env.PROJECT }}
        run: |
          python main.py --mode train \
            --experiment-name "retrain-${{ github.run_id }}" \
            --run-name "${{ inputs.reason }}"
      
      - name: Evaluate model
        working-directory: ${{ env.PROJECT }}
        id: evaluate
        run: |
          python scripts/evaluate_model.py \
            --model artifacts/model.joblib \
            --test-data data/test.csv \
            --output metrics.json
          
          # Exportar métricas para comparación
          F1=$(jq '.f1_score' metrics.json)
          echo "f1_score=$F1" >> $GITHUB_OUTPUT
      
      - name: Compare with production model
        id: compare
        run: |
          PROD_F1=$(cat production_metrics.json | jq '.f1_score')
          NEW_F1=${{ steps.evaluate.outputs.f1_score }}
          
          if (( $(echo "$NEW_F1 > $PROD_F1" | bc -l) )); then
            echo "is_better=true" >> $GITHUB_OUTPUT
            echo "✅ Nuevo modelo es mejor: $NEW_F1 > $PROD_F1"
          else
            echo "is_better=false" >> $GITHUB_OUTPUT
            echo "❌ Nuevo modelo no mejora: $NEW_F1 <= $PROD_F1"
          fi
      
      - name: Promote model (if better and enabled)
        if: steps.compare.outputs.is_better == 'true' && inputs.promote_if_better
        run: |
          python scripts/promote_model.py \
            --model artifacts/model.joblib \
            --stage production \
            --run-id ${{ github.run_id }}
      
      - name: Upload training artifacts
        uses: actions/upload-artifact@v5
        with:
          name: retrain-artifacts-${{ github.run_id }}
          path: |
            ${{ env.PROJECT }}/artifacts/
            ${{ env.PROJECT }}/metrics.json
```

### 12.7.3 CML: Continuous Machine Learning

[CML](https://cml.dev/) permite generar reportes visuales de entrenamiento directamente en PRs. El portafolio lo usa para comparar runs de MLflow:

```yaml
# .github/workflows/cml-training-comparison.yml (simplificado)
name: CML Training Report

on:
  pull_request:
    paths:
      - '**/src/**'
      - '**/configs/**'

jobs:
  train-and-report:
    runs-on: ubuntu-latest
    container: ghcr.io/iterative/cml:0-dvc2-base1
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Train model
        run: |
          pip install -r BankChurn-Predictor/requirements.txt
          cd BankChurn-Predictor
          python main.py --mode train
      
      - name: Generate CML report
        env:
          REPO_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Crear reporte markdown
          echo "## 📊 Training Report" >> report.md
          echo "" >> report.md
          
          # Agregar métricas
          echo "### Metrics" >> report.md
          cat BankChurn-Predictor/artifacts/training_results.json | \
            python -c "import json,sys; d=json.load(sys.stdin); print(f'- **F1**: {d[\"f1\"]:.4f}')" >> report.md
          
          # Agregar gráficos si existen
          if [ -f BankChurn-Predictor/artifacts/confusion_matrix.png ]; then
            echo "### Confusion Matrix" >> report.md
            cml-publish BankChurn-Predictor/artifacts/confusion_matrix.png --md >> report.md
          fi
          
          # Publicar como comentario en PR
          cml comment create report.md
```

### 12.7.4 Diagrama de Workflows MLOps Integrados

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    WORKFLOWS MLOPS DEL PORTAFOLIO                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  DESARROLLO                           OPERACIÓN                                 │
│  ──────────                           ─────────                                 │
│                                                                                 │
│  ┌──────────────┐                     ┌──────────────┐                          │
│  │ Push/PR      │                     │ Schedule     │                          │
│  └──────┬───────┘                     │ (cron)       │                          │
│         │                             └──────┬───────┘                          │
│         ▼                                    │                                  │
│  ┌──────────────┐                            ▼                                  │
│  │ ci-mlops.yml │                     ┌──────────────┐                          │
│  │              │                     │ drift-       │                          │
│  │ • Tests      │                     │ detection    │                          │
│  │ • Coverage   │                     │              │                          │
│  │ • Security   │                     │ • Compare    │                          │
│  │ • Docker     │                     │   reference  │                          │
│  └──────┬───────┘                     │   vs current │                          │
│         │                             └──────┬───────┘                          │
│         ▼                                    │                                  │
│  ┌──────────────┐                            ▼                                  │
│  │ cml-report   │                     ┌──────────────┐                          │
│  │              │    ◄────────────    │ ¿Drift?      │                          │
│  │ • Metrics    │        NO           │              │                          │
│  │   comparison │                     └──────┬───────┘                          │
│  │ • Plots in   │                            │ SÍ                               │
│  │   PR comment │                            ▼                                  │
│  └──────────────┘                     ┌──────────────┐                          │
│                                       │ retrain-     │                          │
│                                       │ bankchurn    │                          │
│                                       │              │                          │
│                                       │ • Train new  │                          │
│                                       │ • Compare    │                          │
│                                       │ • Promote?   │                          │
│                                       └──────────────┘                          │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 🔧 Ejercicio: Implementar Drift Detection Básico

```bash
# 1. Crear script de drift detection
cat > scripts/detect_drift.py << 'EOF'
"""Drift detection básico usando Evidently."""
import argparse
import pandas as pd
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference", required=True)
    parser.add_argument("--current", required=True)
    parser.add_argument("--output", default="drift_report.html")
    args = parser.parse_args()
    
    reference = pd.read_csv(args.reference)
    current = pd.read_csv(args.current)
    
    report = Report(metrics=[DataDriftPreset()])
    report.run(reference_data=reference, current_data=current)
    report.save_html(args.output)
    
    # Exit con código de error si hay drift significativo
    drift_share = report.as_dict()["metrics"][0]["result"]["share_of_drifted_columns"]
    if drift_share > 0.3:  # >30% de columnas con drift
        print(f"⚠️ Drift detectado: {drift_share:.1%} de columnas")
        exit(1)
    print(f"✅ Sin drift significativo: {drift_share:.1%} de columnas")

if __name__ == "__main__":
    main()
EOF

# 2. Crear workflow básico de drift
mkdir -p .github/workflows
cat > .github/workflows/drift-check.yml << 'EOF'
name: Weekly Drift Check
on:
  schedule:
    - cron: '0 8 * * 1'  # Lunes 8 AM
  workflow_dispatch:

jobs:
  drift:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install evidently pandas
      - run: python scripts/detect_drift.py --reference data/train.csv --current data/new_data.csv
EOF
```

---

<a id="128-ingenieria-inversa-cicd"></a>

## 12.8 🔬 Ingeniería Inversa Pedagógica: El Pipeline CI/CD Real

> **Objetivo**: Entender CADA decisión técnica detrás del workflow `.github/workflows/ci-mlops.yml` del portafolio.

Esta sección aplica el método de "Shadow Coder Senior": diseccionamos el pipeline real que orquesta los 3 proyectos del portafolio.

### 12.8.1 🎯 El "Por Qué" Arquitectónico

¿Por qué el portafolio usa un workflow tan complejo (500+ líneas) en lugar de un simple `pytest`?

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    DECISIONES ARQUITECTÓNICAS DEL PORTAFOLIO                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  PROBLEMA 1: Tenemos 3 proyectos (BankChurn, CarVision, Telecom) en un repo     │
│  ─────────────────────────────────────────────────────────────                  │
│  DECISIÓN: Matrix Strategy con variable `project`                               │
│  RESULTADO: Un solo workflow gestiona 3 proyectos en paralelo                   │
│  REFERENCIA: ci-mlops.yml líneas 34-38                                          │
│                                                                                 │
│  PROBLEMA 2: Incompatibilidad de versiones de Python entre dev y prod           │
│  ─────────────────────────────────────────────────────────────                  │
│  DECISIÓN: Matrix de `python-version: ['3.11', '3.12']`                         │
│  RESULTADO: Validamos compatibilidad futura automáticamente                     │
│  REFERENCIA: ci-mlops.yml línea 34                                              │
│                                                                                 │
│  PROBLEMA 3: Instalar dependencias toma 2 minutos por job (x6 jobs = 12 min)    │
│  ─────────────────────────────────────────────────────────────                  │
│  DECISIÓN: `cache: 'pip'` en setup-python                                       │
│  RESULTADO: Builds bajan de 15 min a 3 min                                      │
│  REFERENCIA: ci-mlops.yml línea 65                                              │
│                                                                                 │
│  PROBLEMA 4: Tests de integración requieren base de datos real (MLflow)         │
│  ─────────────────────────────────────────────────────────────                  │
│  DECISIÓN: Service containers (Postgres) en el runner                           │
│  RESULTADO: Tests reales sin mocks para la DB                                   │
│  REFERENCIA: ci-mlops.yml líneas 40-53                                          │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 12.8.2 🔍 Anatomía Línea por Línea: `ci-mlops.yml`

Analicemos los bloques críticos que distinguen a un Senior MLOps Engineer.

```yaml
# .github/workflows/ci-mlops.yml

# BLOQUE 1: Disparadores Inteligentes
# ───────────────────────────────────
on:
  push:
    branches: [ main, develop ]   # Corre en ramas principales
  pull_request:
    branches: [ main ]            # Corre en PRs hacia main
  workflow_dispatch:              # Permite ejecución manual desde UI
    inputs:
      run_integration:
        description: 'Run full integration tests'
        required: false
        default: 'true'
        type: boolean
# ¿Por qué? workflow_dispatch es vital para debuggear CI sin hacer commits vacíos.

# BLOQUE 2: Matrix Strategy (El corazón del monorepo)
# ───────────────────────────────────────────────────
jobs:
  tests:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false            # CRÍTICO: Si falla BankChurn, NO canceles CarVision
      matrix:
        python-version: ['3.11', '3.12']
        project:
          - BankChurn-Predictor
          - CarVision-Market-Intelligence
          - TelecomAI-Customer-Intelligence
# ¿Por qué? Esto genera 6 jobs (2 versiones * 3 proyectos).
# fail-fast: false nos permite ver TODOS los errores de una vez.

# BLOQUE 3: Servicios para Tests de Integración
# ─────────────────────────────────────────────
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_DB: mlflow
          POSTGRES_USER: mlflow
          POSTGRES_PASSWORD: mlflow_test
        options: >-
          --health-cmd "pg_isready -U mlflow"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
# ¿Por qué? MLflow necesita backend. Usar mocks oculta errores de integración real.
# El health-cmd asegura que Postgres esté LISTO antes de iniciar los tests.

# BLOQUE 4: Instalación Inteligente de Dependencias
# ─────────────────────────────────────────────────
      - name: Install dependencies
        working-directory: ${{ matrix.project }}  # cd al directorio del proyecto actual
        run: |
          # Manejo híbrido de requirements.txt vs .in
          if [ -f requirements.in ]; then
            pip install -r requirements.in
          elif [ -f requirements.txt ]; then
            # Hack para limpiar hashes si causan conflictos en CI
            grep -v '^[[:space:]]*--hash=' requirements.txt ... > requirements_no_hash.txt
            pip install -r requirements_no_hash.txt
          fi
# ¿Por qué? En un monorepo, cada proyecto tiene sus propias deps.
# El `working-directory` es clave aquí.

# BLOQUE 5: Thresholds de Coverage Dinámicos
# ──────────────────────────────────────────
      - name: Run tests with coverage
        working-directory: ${{ matrix.project }}
        run: |
          # Lógica condicional en Bash dentro del YAML
          if [ "${{ matrix.project }}" = "BankChurn-Predictor" ]; then
            THRESHOLD=79
          else
            THRESHOLD=80
          fi
          
          pytest ... --cov-fail-under=$THRESHOLD
# ¿Por qué? No todos los proyectos maduran igual. BankChurn puede ser legacy (79%)
# mientras CarVision es nuevo (80%). No bajes la vara del nuevo por culpa del viejo.
```

### 12.8.3 🧪 Laboratorio de Replicación

**Tu misión**: Crear un mini-pipeline matrix que pruebe 2 carpetas ficticias.

1. **Crea la estructura**:
   ```bash
   mkdir -p labs/ci-matrix/{api-a,api-b}
   touch labs/ci-matrix/api-a/test_a.py
   touch labs/ci-matrix/api-b/test_b.py
   ```

2. **Crea el workflow `.github/workflows/lab-matrix.yml`**:
   ```yaml
   name: Lab Matrix
   on: workflow_dispatch
   jobs:
     test:
       runs-on: ubuntu-latest
       strategy:
         matrix:
           service: [api-a, api-b]
       steps:
         - uses: actions/checkout@v4
         - name: Test ${{ matrix.service }}
           working-directory: labs/ci-matrix/${{ matrix.service }}
           run: echo "Running tests for ${{ matrix.service }}"
   ```

3. **Ejecútalo manualmente** y observa cómo se crean 2 jobs paralelos.

### 12.8.4 🚨 Troubleshooting Preventivo

| Síntoma | Causa Probable | Solución |
|---------|----------------|----------|
| **"Process completed with exit code 1" en `pip install`** | Conflicto de hashes en `requirements.txt` entre OS (Linux CI vs Mac Local) | Usar el script `sed` para limpiar hashes o usar `pip-compile` multiplataforma. |
| **Tests pasan pero Coverage falla** | El threshold es muy alto para el estado actual | Ajustar `THRESHOLD` en el bloque condicional bash. |
| **Postgres connection refused** | El servicio no estaba listo cuando pytest arrancó | Verificar `options: --health-cmd` en la definición del servicio. |
| **"ModuleNotFoundError" en CI** | `working-directory` incorrecto | Asegurar que `working-directory: ${{ matrix.project }}` esté en CADA paso que use archivos del proyecto. |

---

<a id="errores-habituales"></a>

## 🧨 Errores habituales y cómo depurarlos en CI/CD

En este módulo los problemas suelen venir de **triggers mal configurados**, **rutas incorrectas** o **jobs mal encadenados**.

Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.

### 1) El workflow no se dispara

**Síntomas típicos**

- Haces push o abres un PR y GitHub no muestra ningún run nuevo.

**Cómo identificarlo**

- Revisa la sección `on:` del workflow:
  - ¿Incluye las ramas correctas (`main`, `develop`, feature branches)?
  - ¿Estás haciendo push a una rama no contemplada?

**Cómo corregirlo**

- Ajusta los triggers a tu flujo real:
  ```yaml
  on:
    push:
      branches: [main, develop, "feature/*"]
    pull_request:
      branches: [main]
  ```

---

### 2) Falla solo en un proyecto o en una versión de Python

**Síntomas típicos**

- En la matrix, solo falla `CarVision` en Python 3.12, el resto pasa.

**Cómo identificarlo**

- Mira los logs filtrando por `matrix.project` y `matrix.python-version`.

**Cómo corregirlo**

- Ejecuta localmente con la misma versión de Python y el mismo directorio (`working-directory`) que en el job.
- Asegúrate de que los paths (`src/`, `app/`, `requirements.txt`) sean correctos para cada proyecto en la matrix.

---

### 3) Coverage o linting no respetan el threshold esperado

**Síntomas típicos**

- Crees haber configurado `--cov-fail-under`, pero el job pasa aunque el coverage sea bajo.

**Cómo identificarlo**

- Verifica la línea exacta del comando `pytest` en el workflow.

**Cómo corregirlo**

- Asegúrate de que el parámetro `--cov-fail-under` se pase realmente al comando que se ejecuta (no a un alias intermedio).
- Diferencia claramente entre thresholds por proyecto usando condiciones `if` en el script del job.

---

### 4) Jobs que fallan por falta de dependencias o rutas

**Síntomas típicos**

- Errores como `ModuleNotFoundError` en CI pero no en local.
- `pip install -r requirements.txt` falla porque el archivo no existe en ese directorio.

**Cómo identificarlo**

- Verifica el `working-directory` de cada `step`.
- Revisa la estructura real del repo y compara con las rutas usadas en el workflow.

**Cómo corregirlo**

- Ajusta `working-directory` para que apunte al proyecto correcto (`BankChurn-Predictor`, etc.).
- Si un proyecto no tiene `requirements.txt`, instala en modo editable con `pip install -e .` como fallback.

---

### 5) Patrón general de debugging en GitHub Actions

1. Reproduce localmente el comando exacto que falla (`pytest`, `docker build`, etc.).
2. Verifica `on:` y `matrix` para asegurarte de que el job se ejecuta en los contextos esperados.
3. Usa `working-directory` y rutas relativas coherentes con la estructura del repo.
4. Encadena bien los jobs usando `needs` para que la lógica del pipeline sea clara.

Con este enfoque, CI/CD pasa de ser una caja negra “que a veces falla” a un pipeline confiable que te protege al hacer cambios en el portafolio.

---

<a id="ejercicio"></a>

## ✅ Ejercicio: Crear Tu Propio Workflow

### Paso 1: Workflow Mínimo

Crea `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install pytest
      - run: pytest
```

### Paso 2: Añadir Coverage

```yaml
      - run: pip install pytest pytest-cov
      - run: pytest --cov=src/ --cov-fail-under=80
```

### Paso 3: Añadir Matrix

```yaml
    strategy:
      matrix:
        python-version: ['3.11', '3.12']
```

### Paso 4: Añadir Security

Añade un job nuevo con Bandit y Gitleaks.

---

<a id="checkpoint"></a>

## ✅ Checkpoint

- [ ] Tienes un workflow básico que ejecuta tests
- [ ] El workflow usa matrix testing (múltiples versiones Python)
- [ ] Coverage está enforced con threshold
- [ ] Tienes al menos un scan de seguridad
- [ ] Los artifacts se suben correctamente

---

## 📦 Cómo se Usó en el Portafolio

El portafolio tiene un workflow CI/CD real en `.github/workflows/ci-mlops.yml`:

### Workflow Real del Portafolio

```yaml
# .github/workflows/ci-mlops.yml (extracto)
name: CI/CD MLOps Portfolio

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        project: [BankChurn-Predictor, CarVision-Market-Intelligence, TelecomAI-Customer-Intelligence]
        python-version: ['3.10', '3.11']
    
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install dependencies
        run: |
          cd ${{ matrix.project }}
          pip install -e ".[dev]"
      
      - name: Run tests with coverage
        run: |
          cd ${{ matrix.project }}
          pytest tests/ --cov=src/ --cov-fail-under=79
```

### Features del CI/CD

| Feature | Implementación |
|---------|----------------|
| Matrix Testing | 3 proyectos × 2 versiones Python |
| Coverage Gate | `--cov-fail-under=79` |
| Security Scan | gitleaks en pre-commit |
| Artifacts | Coverage reports |

### 🔧 Ejercicio: Revisa el CI Real

```bash
# 1. Ve el workflow real
cat .github/workflows/ci-mlops.yml

# 2. Simula localmente con act (opcional)
act -j test --matrix project:BankChurn-Predictor

# 3. Ve los runs en GitHub
# https://github.com/DuqueOM/ML-MLOps-Portfolio/actions
```

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **CI vs CD**: CI = integrar código frecuentemente, CD = desplegar automáticamente.

2. **GitHub Actions vs Jenkins vs GitLab CI**: Trade-offs de cada uno.

3. **ML-specific CI**: Explica cómo CI para ML incluye validación de datos y modelos.

### Para Proyectos Reales

| Situación | Consejo |
|-----------|---------|
| Secrets | Usa GitHub Secrets, nunca hardcodees |
| Caching | Cachea dependencias y datos para velocidad |
| Paralelización | Matriz de tests para múltiples versiones |
| Rollback | Siempre ten estrategia de rollback |

### Pipeline CI/CD para ML

```yaml
1. Lint + Format (ruff, black)
2. Unit Tests (pytest)
3. Integration Tests
4. Security Scan (gitleaks, bandit)
5. Build Docker Image
6. Model Validation
7. Deploy to Staging
8. Smoke Tests
9. Deploy to Production
```


---

## 📺 Recursos Externos del Módulo

> 🏷️ Sistema: 🔴 Obligatorio | 🟡 Recomendado | 🟢 Complementario

### 🎬 Videos

| 🏷️ | Título | Canal | Duración | Link |
|:--:|:-------|:------|:--------:|:-----|
| 🔴 | **GitHub Actions Tutorial** | TechWorld Nana | 1h | [YouTube](https://www.youtube.com/watch?v=R8_veQiYBjI) |
| 🟡 | **CI/CD for ML** | Made With ML | 45 min | [MadeWithML](https://madewithml.com/courses/mlops/cicd/) |
| 🟢 | **GitHub Actions for Python** | mCoding | 20 min | [YouTube](https://www.youtube.com/watch?v=WTofttoD2xg) |

### 📄 Documentación

| 🏷️ | Recurso | Descripción |
|:--:|:--------|:------------|
| 🔴 | [GitHub Actions](https://docs.github.com/en/actions) | Documentación oficial |
| 🟡 | [Actions Marketplace](https://github.com/marketplace?type=actions) | Acciones reutilizables |

---

## ⚖️ Decisión Técnica: ADR-005 GitHub Actions

**Contexto**: Necesitamos automatizar testing, linting y deployment.

**Decisión**: Usar GitHub Actions como plataforma CI/CD.

**Alternativas Consideradas**:
- **Jenkins**: Más flexible pero requiere infraestructura propia
- **GitLab CI**: Excelente pero vendor lock-in
- **CircleCI**: Potente pero con límites en free tier

**Consecuencias**:
- ✅ Integración nativa con GitHub
- ✅ Free tier generoso para open source
- ✅ Marketplace con acciones reutilizables
- ❌ Menos flexible que Jenkins para casos complejos

---

## 🔧 Ejercicios del Módulo

### Ejercicio 12.1: GitHub Actions Básico
**Objetivo**: Crear workflow de CI para proyecto ML.
**Dificultad**: ⭐⭐

```yaml
# .github/workflows/ci.yml
# TU TAREA: Completar workflow que:
# 1. Ejecute en push y PR
# 2. Instale dependencias
# 3. Ejecute tests con coverage
# 4. Falle si coverage < 80%
```

<details>
<summary>💡 Ver solución</summary>

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          pip install -e ".[dev]"
      
      - name: Run linting
        run: |
          ruff check .
          ruff format --check .
      
      - name: Run tests with coverage
        run: |
          pytest tests/ -v \
            --cov=src \
            --cov-report=xml \
            --cov-fail-under=80
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
```
</details>

---

## 🔗 Glosario del Módulo

| Término | Definición |
|---------|------------|
| **CI** | Continuous Integration - integrar código frecuentemente |
| **CD** | Continuous Deployment - desplegar automáticamente |
| **Workflow** | Archivo YAML que define jobs y steps |
| **Matrix** | Ejecutar mismo job con diferentes configuraciones |

---

<div align="center">

**Siguiente módulo** → [13. Docker](13_DOCKER.md)

---

[← Volver al Índice](00_INDICE.md)

</div>
