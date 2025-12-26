# 📋 Examen de Hito 3: Testing & CI/CD

> **Formato**: Self-Correction Code Review  
> **Duración**: 45-60 minutos  
> **Puntaje mínimo**: 70/100

---

## Ejercicio 1: Tests con Errores Sutiles (30 puntos)

### Código a Revisar

```python
# tests/test_training.py
import pytest
import pandas as pd
from bankchurn.training import ChurnTrainer
from bankchurn.config import BankChurnConfig

def test_trainer_fits():
    # Arrange
    df = pd.read_csv("data/raw/customers.csv")
    config = BankChurnConfig.from_yaml("configs/config.yaml")
    trainer = ChurnTrainer(config)
    
    # Act
    X = df.drop("Exited", axis=1)
    y = df["Exited"]
    trainer.fit(X, y)
    
    # Assert
    assert trainer._pipeline is not None

def test_predictions_are_binary():
    df = pd.read_csv("data/raw/customers.csv")
    config = BankChurnConfig.from_yaml("configs/config.yaml")
    trainer = ChurnTrainer(config)
    
    X = df.drop("Exited", axis=1)
    y = df["Exited"]
    trainer.fit(X, y)
    
    predictions = trainer.predict(X)
    assert all(p in [0, 1] for p in predictions)

def test_accuracy_above_threshold():
    df = pd.read_csv("data/raw/customers.csv")
    config = BankChurnConfig.from_yaml("configs/config.yaml")
    trainer = ChurnTrainer(config)
    
    X = df.drop("Exited", axis=1)
    y = df["Exited"]
    trainer.fit(X, y)
    
    accuracy = trainer.evaluate(X, y)["accuracy"]
    assert accuracy > 0.8
```

### Tu Respuesta

| # | Problema | Severidad | Corrección |
|---|----------|-----------|------------|

---

<details>
<summary>📝 Ver Solución</summary>

| # | Problema | Severidad | Corrección |
|---|----------|-----------|------------|
| 1 | Lee archivos reales (no aislado) | 🔴 Crítico | Usar fixtures con datos sintéticos |
| 2 | Depende de config.yaml externo | 🔴 Crítico | Crear config en el test o usar fixture |
| 3 | Tests no son independientes | 🟡 Medio | Cada test crea su propio trainer |
| 4 | Evalúa en datos de TRAIN (leakage) | 🔴 Crítico | Usar train_test_split |
| 5 | `assert trainer._pipeline` accede privado | 🟢 Menor | Usar método público `is_fitted()` |
| 6 | Mucho código duplicado | 🟡 Medio | Usar fixtures `@pytest.fixture` |
| 7 | `accuracy > 0.8` es frágil | 🟡 Medio | Test debe ser determinista o usar rango |

### Tests Corregidos

```python
# tests/conftest.py
import pytest
import pandas as pd
import numpy as np
from bankchurn.config import BankChurnConfig, ModelConfig, DataConfig

@pytest.fixture
def sample_data():
    """Datos sintéticos reproducibles."""
    np.random.seed(42)
    n = 100
    return pd.DataFrame({
        "CreditScore": np.random.randint(300, 850, n),
        "Age": np.random.randint(18, 80, n),
        "Balance": np.random.uniform(0, 100000, n),
        "NumOfProducts": np.random.randint(1, 4, n),
        "Exited": np.random.randint(0, 2, n),
    })

@pytest.fixture
def config():
    """Configuración de test (no depende de archivo)."""
    return BankChurnConfig(
        model=ModelConfig(test_size=0.2, random_state=42),
        data=DataConfig(target_column="Exited"),
    )

@pytest.fixture
def trained_trainer(sample_data, config):
    """Trainer ya entrenado."""
    from bankchurn.training import ChurnTrainer
    trainer = ChurnTrainer(config)
    X = sample_data.drop("Exited", axis=1)
    y = sample_data["Exited"]
    trainer.fit(X, y)
    return trainer


# tests/test_training.py
from sklearn.model_selection import train_test_split

def test_trainer_fits(sample_data, config):
    """Test que el trainer puede entrenar."""
    from bankchurn.training import ChurnTrainer
    
    trainer = ChurnTrainer(config)
    X = sample_data.drop("Exited", axis=1)
    y = sample_data["Exited"]
    
    trainer.fit(X, y)
    
    assert trainer.is_fitted()  # Método público

def test_predictions_are_binary(trained_trainer, sample_data):
    """Test que predicciones son 0 o 1."""
    X = sample_data.drop("Exited", axis=1)
    predictions = trained_trainer.predict(X)
    
    assert set(predictions.unique()).issubset({0, 1})

def test_model_generalizes(sample_data, config):
    """Test en datos NO vistos durante entrenamiento."""
    from bankchurn.training import ChurnTrainer
    
    X = sample_data.drop("Exited", axis=1)
    y = sample_data["Exited"]
    
    # Split ANTES de entrenar
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    trainer = ChurnTrainer(config)
    trainer.fit(X_train, y_train)
    
    # Evaluar en datos NO vistos
    metrics = trainer.evaluate(X_test, y_test)
    
    # Verificar que métricas son razonables (no perfectas)
    assert 0.3 < metrics["accuracy"] < 1.0  # Rango realista
```

</details>

---

## Ejercicio 2: GitHub Actions Workflow (25 puntos)

### Código a Revisar

```yaml
# .github/workflows/ci.yml
name: CI

on: push

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: 3.11
      
      - name: Install
        run: pip install -r requirements.txt
      
      - name: Test
        run: pytest
```

### Tu Respuesta

¿Qué falta o está mal?

---

<details>
<summary>📝 Ver Solución</summary>

| # | Problema | Corrección |
|---|----------|------------|
| 1 | `on: push` sin filtros | Añadir `branches: [main, develop]` |
| 2 | Sin cache de pip | Añadir `cache: pip` |
| 3 | No instala en modo editable | `pip install -e ".[dev]"` |
| 4 | pytest sin opciones | `pytest -v --cov --cov-fail-under=79` |
| 5 | Sin linting (mypy, ruff) | Añadir steps de lint |
| 6 | Sin matrix para múltiples Python | Añadir matrix strategy |
| 7 | Sin timeout | Añadir `timeout-minutes: 10` |

### Workflow Corregido

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"
          cache: pip
      
      - name: Install
        run: pip install -e ".[dev]"
      
      - name: Ruff
        run: ruff check src/ tests/
      
      - name: Mypy
        run: mypy src/ --strict

  test:
    needs: lint
    runs-on: ubuntu-latest
    timeout-minutes: 10
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python ${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: pip
      
      - name: Install
        run: pip install -e ".[dev]"
      
      - name: Test
        run: pytest tests/ -v --cov=src --cov-report=xml --cov-fail-under=79
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

</details>

---

## Ejercicio 3: Fixtures y Mocks (25 puntos)

### Código a Revisar

```python
# tests/test_api.py
import requests
from fastapi.testclient import TestClient
from app.fastapi_app import app

def test_predict_endpoint():
    client = TestClient(app)
    
    # Llama al modelo real
    response = client.post("/predict", json={
        "CreditScore": 650,
        "Age": 35,
        "Balance": 50000,
    })
    
    assert response.status_code == 200
    assert "prediction" in response.json()

def test_health_calls_database():
    # Llama a la base de datos real
    response = requests.get("http://localhost:8000/health")
    assert response.json()["database"] == "connected"
```

### Tu Respuesta

| # | Problema | Corrección |
|---|----------|------------|

---

<details>
<summary>📝 Ver Solución</summary>

| # | Problema | Corrección |
|---|----------|------------|
| 1 | `/predict` usa modelo real | Mock del modelo |
| 2 | Test depende de modelo entrenado | Usar fixture con mock |
| 3 | `requests.get` llama servidor real | Usar TestClient |
| 4 | Test depende de DB real | Mock de la conexión DB |
| 5 | Sin datos de entrada inválidos | Añadir test de validación |

### Tests Corregidos

```python
# tests/test_api.py
import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient
from app.fastapi_app import app

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def mock_model():
    """Mock del modelo que retorna predicción fija."""
    model = MagicMock()
    model.predict.return_value = [1]
    model.predict_proba.return_value = [[0.3, 0.7]]
    return model

def test_predict_endpoint(client, mock_model):
    """Test de predicción con modelo mockeado."""
    with patch("app.fastapi_app.model", mock_model):
        response = client.post("/predict", json={
            "CreditScore": 650,
            "Age": 35,
            "Balance": 50000.0,
            "NumOfProducts": 2,
        })
    
    assert response.status_code == 200
    data = response.json()
    assert "prediction" in data
    assert data["prediction"] in [0, 1]
    assert "probability" in data

def test_predict_invalid_input(client):
    """Test de validación de entrada."""
    response = client.post("/predict", json={
        "CreditScore": -100,  # Inválido
        "Age": 200,           # Inválido
    })
    
    assert response.status_code == 422  # Validation error

def test_health_endpoint(client):
    """Test de health sin dependencias externas."""
    with patch("app.fastapi_app.check_database") as mock_db:
        mock_db.return_value = True
        response = client.get("/health")
    
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
```

</details>

---

## Ejercicio 4: Cobertura de Tests (20 puntos)

### Output a Analizar

```
---------- coverage: ----------
Name                          Stmts   Miss  Cover
-------------------------------------------------
src/bankchurn/__init__.py         5      0   100%
src/bankchurn/config.py          45      2    96%
src/bankchurn/training.py        89     45    49%
src/bankchurn/evaluation.py      23      0   100%
src/bankchurn/prediction.py      34     34     0%
-------------------------------------------------
TOTAL                           196     81    59%

FAILED: Coverage 59% < 79% minimum
```

### Tu Respuesta

1. ¿Qué archivo necesita más tests urgentemente?
2. ¿Qué tipo de tests añadirías?

---

<details>
<summary>📝 Ver Solución</summary>

1. **Archivo más urgente**: `prediction.py` (0% coverage)

2. **Tests a añadir**:

```python
# tests/test_prediction.py

def test_predictor_loads_model(tmp_path, trained_model):
    """Test que el predictor carga modelo correctamente."""
    model_path = tmp_path / "model.pkl"
    joblib.dump(trained_model, model_path)
    
    predictor = ChurnPredictor(model_path)
    
    assert predictor.model is not None

def test_predictor_single_prediction(predictor, sample_input):
    """Test predicción de un solo registro."""
    result = predictor.predict_single(sample_input)
    
    assert "prediction" in result
    assert "probability" in result
    assert result["prediction"] in [0, 1]

def test_predictor_batch_prediction(predictor, sample_dataframe):
    """Test predicción en batch."""
    results = predictor.predict_batch(sample_dataframe)
    
    assert len(results) == len(sample_dataframe)
    assert all(r["prediction"] in [0, 1] for r in results)

def test_predictor_handles_missing_model():
    """Test error cuando no existe modelo."""
    with pytest.raises(FileNotFoundError):
        ChurnPredictor("nonexistent/model.pkl")
```

3. **Para `training.py` (49%)**:
   - Tests de edge cases (datos vacíos, una sola clase)
   - Tests de serialización (save/load)
   - Tests de cross-validation

</details>

---

## Rúbrica

| Ejercicio | Puntos |
|-----------|:------:|
| Tests con Errores | 30 |
| GitHub Actions | 25 |
| Fixtures y Mocks | 25 |
| Cobertura | 20 |
| **TOTAL** | **100** |
