# 11. Testing para Machine Learning
 
<a id="00-prerrequisitos"></a>
 
## 0.0 Prerrequisitos
 
- Tener `pytest` y `pytest-cov` disponibles en tu entorno.
- Haber revisado la estructura `src/` + `tests/` en al menos 1 proyecto del portafolio.
 
---
 
<a id="01-protocolo-e-como-estudiar-este-modulo"></a>
 
## 0.1 🧠 Protocolo E: Cómo estudiar este módulo
 
- **Antes de empezar**: abre **[Protocolo E](study_tools/PROTOCOLO_E.md)** y define tu *output mínimo* (una suite que corre en CI).
- **Durante el debugging**: si te atoras >15 min (fixtures, flaky tests, coverage), registra el caso en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)**.
- **Al cierre de semana**: usa **[Cierre Semanal](study_tools/CIERRE_SEMANAL.md)** para auditar si tus tests realmente protegen el pipeline.
 
---
 
<a id="02-entregables-verificables-minimo-viable"></a>
 
## 0.2 ✅ Entregables verificables (mínimo viable)
 
- [ ] Un `tests/` con:
  - `conftest.py` con fixtures reutilizables
  - unit tests para features/transformers
  - data tests (rango, NaN, schema)
  - al menos 1 integración (pipeline o API)
- [ ] Coverage `>= 80%` (en al menos 1 proyecto).
- [ ] 1 entrada en **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** si hubo bloqueo real.
 
---
 
<a id="03-puente-teoria-codigo-portafolio"></a>
 
## 0.3 🧩 Puente teoría ↔ código (Portafolio)
 
- **Concepto**: testing por capas (unit/data/model/integration/e2e) + coverage
- **Archivo**: `tests/`, `pyproject.toml` (pytest), workflows CI
- **Prueba**: `pytest -v --cov=src/<paquete> --cov-report=term-missing`
 
## 🎯 Objetivo del Módulo
 
Dominar el testing en proyectos ML para alcanzar **80%+ de coverage** sin tests frágiles ni falsos positivos.

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  🚨 LA REALIDAD DEL ML SIN TESTS:                                            ║
║                                                                              ║
║  "El modelo funcionaba ayer, hoy da predicciones random"                     ║
║  "Cambié una línea y rompí todo el pipeline"                                 ║
║  "No sé si el bug está en los datos, el preprocesamiento, o el modelo"       ║
║                                                                              ║
║  🛡️ LA REALIDAD CON TESTS:                                                   ║
║                                                                              ║
║  "CI me avisó que rompí algo antes de hacer merge"                           ║
║  "Sé exactamente qué componente falló"                                       ║
║  "Puedo refactorizar con confianza"                                          ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```
 
---
 
<a id="contenido"></a>
 
## 📋 Contenido
 
- **0.0** [Prerrequisitos](#00-prerrequisitos)
- **0.1** [Protocolo E: Cómo estudiar este módulo](#01-protocolo-e-como-estudiar-este-modulo)
- **0.2** [Entregables verificables (mínimo viable)](#02-entregables-verificables-minimo-viable)
- **0.3** [Puente teoría ↔ código (Portafolio)](#03-puente-teoria-codigo-portafolio)
- **11.1** [La Pirámide de Testing en ML](#111-la-piramide-de-testing-en-ml)
- **11.2** [Fixtures y conftest.py](#112-fixtures-y-conftestpy)
- **11.3** [Unit Tests: Funciones Individuales](#113-unit-tests-funciones-individuales)
- **11.4** [Data Tests: Validación de Datos](#114-data-tests-validacion-de-datos)
- **11.5** [Model Tests: Comportamiento del Modelo](#115-model-tests-comportamiento-del-modelo)
- **11.6** [Integration Tests: Pipeline Completo](#116-integration-tests-pipeline-completo)
- **11.7** [Alcanzar 80% Coverage](#117-alcanzar-80-coverage)
- [Errores habituales](#errores-habituales)
- [✅ Ejercicio](#ejercicio)
- [✅ Checkpoint](#checkpoint)
 
---
 
<a id="111-la-piramide-de-testing-en-ml"></a>
 
## 11.1 La Pirámide de Testing en ML
 
### Analogía: Inspección de un Avión
 
```
╔═══════════════════════════════════════════════════════════════════════════╗
║  ✈️ ANTES DE CADA VUELO, SE INSPECCIONA:                                  ║
║                                                                           ║
║  NIVEL 1 - Componentes individuales (Unit Tests):                         ║
║  • Cada tornillo está apretado                                            ║
║  • Cada cable está conectado                                              ║
║  • Cada sensor funciona                                                   ║
║                                                                           ║
║  NIVEL 2 - Sistemas (Integration Tests):                                  ║
║  • El motor arranca correctamente                                         ║
║  • Los flaps responden a los controles                                    ║
║  • El sistema hidráulico mantiene presión                                 ║
║                                                                           ║
║  NIVEL 3 - Vuelo de prueba (E2E Tests):                                   ║
║  • El avión despega, vuela, y aterriza                                    ║
║  • Todo funciona junto bajo condiciones reales                            ║
║                                                                           ║
║  EN ML ES IGUAL: Testeas componentes → sistemas → pipeline completo       ║
╚═══════════════════════════════════════════════════════════════════════════╝
```
 
### La Pirámide Específica para ML
 
```
                        ┌─────────────────┐
                        │    E2E Tests    │ ← 5-10% de tests
                        │   (API real)    │   Lentos, costosos
                        └────────┬────────┘   test_api_e2e.py
                                 │
                     ┌───────────┴───────────┐
                     │   Integration Tests   │ ← 15-20% de tests
                     │  (pipeline.fit())     │   Verifican interacción
                     └───────────┬───────────┘   test_training.py
                                 │
              ┌──────────────────┴──────────────────┐
              │           Model Tests               │ ← 20-25% de tests
              │  (predicciones, métricas, shapes)   │   Específicos de ML
              └──────────────────┬──────────────────┘   test_model_logic.py
                                 │
        ┌────────────────────────┴────────────────────────┐
        │                 Data Tests                      │ ← 20-25% de tests
        │    (schema, rangos, NaN, schema)                │   Validan datos
        └────────────────────────┬────────────────────────┘   test_data.py
                                 │
┌────────────────────────────────┴────────────────────────────────────────┐
│                           Unit Tests                                    │ ← 30-40% de tests
│              (funciones individuales, transformers)                     │   Rápidos, muchos
└─────────────────────────────────────────────────────────────────────────┘   test_features.py
```
 
### Coverage del Portafolio Real
 
| Proyecto | Coverage | Tests | Tipo Principal |
|----------|:--------:|:-----:|----------------|
| **BankChurn** | 79.5% | 45+ | Unit + Integration |
| **CarVision** | 97% | 50+ | Unit + Data + Model |
| **TelecomAI** | 97% | 35+ | Unit + Integration |
 
---
 
<a id="112-fixtures-y-conftestpy"></a>
 
## 11.2 Fixtures y conftest.py
 
### ¿Qué es una Fixture?
 
```
╔═══════════════════════════════════════════════════════════════════════════╗
║  🧪 FIXTURE = Datos o recursos preparados para tests                      ║
║                                                                           ║
║  Analogía del laboratorio:                                                ║
║  • Antes de cada experimento, preparas tus instrumentos                   ║
║  • Los instrumentos son los mismos para varios experimentos               ║
║  • No los preparas desde cero cada vez                                    ║
║                                                                           ║
║  En pytest:                                                               ║
║  • Fixture prepara datos/modelos/configs                                  ║
║  • Se reutiliza en múltiples tests                                        ║
║  • Se limpia automáticamente después                                      ║
╚═══════════════════════════════════════════════════════════════════════════╝
```
 
### conftest.py del Portafolio (CarVision)
 
```python
# tests/conftest.py - Código REAL del portafolio
 
import pytest
import pandas as pd
import numpy as np
from pathlib import Path
import tempfile
import yaml
 
# ═══════════════════════════════════════════════════════════════════════════
# FIXTURES DE DATOS
# ═══════════════════════════════════════════════════════════════════════════
 
@pytest.fixture
def sample_data() -> pd.DataFrame:
    """DataFrame pequeño para tests rápidos.
    
    Este fixture se usa en MUCHOS tests:
    - test_data.py: Verificar carga y limpieza
    - test_features.py: Verificar feature engineering
    - test_model.py: Verificar predicciones
    """
    return pd.DataFrame({
        "price": [15000, 25000, 35000, 45000, 55000],
        "model_year": [2015, 2018, 2020, 2019, 2021],
        "odometer": [80000, 45000, 20000, 30000, 10000],
        "model": ["ford f-150", "toyota camry", "honda civic", 
                  "chevrolet silverado", "ford mustang"],
        "fuel": ["gas", "gas", "gas", "diesel", "gas"],
        "transmission": ["automatic", "automatic", "manual", 
                        "automatic", "manual"],
        "condition": ["good", "excellent", "like new", 
                     "good", "excellent"],
    })
 
 
@pytest.fixture
def sample_data_with_nulls() -> pd.DataFrame:
    """DataFrame con valores faltantes para probar imputación."""
    return pd.DataFrame({
        "price": [15000, None, 35000, 45000, None],
        "model_year": [2015, 2018, None, 2019, 2021],
        "odometer": [80000, None, 20000, 30000, 10000],
        "model": ["ford f-150", None, "honda civic", None, "ford mustang"],
        "fuel": ["gas", "gas", None, "diesel", "gas"],
        "transmission": [None, "automatic", "manual", "automatic", None],
    })
 
 
@pytest.fixture
def large_sample_data() -> pd.DataFrame:
    """DataFrame más grande para tests de performance."""
    np.random.seed(42)
    n = 1000
    return pd.DataFrame({
        "price": np.random.uniform(5000, 80000, n),
        "model_year": np.random.randint(2010, 2024, n),
        "odometer": np.random.uniform(0, 200000, n),
        "model": np.random.choice(["ford f-150", "toyota camry", "honda civic"], n),
        "fuel": np.random.choice(["gas", "diesel", "electric"], n),
        "transmission": np.random.choice(["automatic", "manual"], n),
    })
 
 
# ═══════════════════════════════════════════════════════════════════════════
# FIXTURES DE CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════════════════════
 
@pytest.fixture
def sample_config() -> dict:
    """Configuración mínima para tests."""
    return {
        "seed": 42,
        "dataset_year": 2024,
        "paths": {
            "data_path": "data/raw/vehicles_us.csv",
            "artifacts_dir": "artifacts",
            "model_path": "artifacts/model.joblib",
        },
        "preprocessing": {
            "numeric_features": ["odometer", "vehicle_age"],
            "categorical_features": ["fuel", "transmission", "brand"],
            "drop_columns": ["price_per_mile", "price_category"],
            "filters": {
                "price_min": 1000,
                "price_max": 100000,
            }
        },
        "training": {
            "target": "price",
            "test_size": 0.2,
            "val_size": 0.1,
            "shuffle": True,
            "model": "random_forest",
            "random_forest_params": {
                "n_estimators": 10,  # Pocos para tests rápidos
                "max_depth": 5,
                "random_state": 42,
            }
        }
    }
 
 
@pytest.fixture
def temp_config_file(sample_config, tmp_path) -> Path:
    """Crea archivo config temporal para tests de carga."""
    config_path = tmp_path / "config.yaml"
    with open(config_path, "w") as f:
        yaml.dump(sample_config, f)
    return config_path
 
 
# ═══════════════════════════════════════════════════════════════════════════
# FIXTURES DE MODELO
# ═══════════════════════════════════════════════════════════════════════════
 
@pytest.fixture
def fitted_pipeline(sample_data, sample_config):
    """Pipeline entrenado para tests de predicción."""
    from src.carvision.training import build_pipeline
    from src.carvision.features import FeatureEngineer
    
    # Preparar datos
    fe = FeatureEngineer(current_year=2024)
    df = fe.transform(sample_data)
    
    X = df.drop(columns=["price"])
    y = df["price"]
    
    # Construir y entrenar pipeline
    # Nota: Usamos config simplificada para velocidad
    pipeline = build_pipeline(sample_config)
    pipeline.fit(X, y)
    
    return pipeline
 
 
# ═══════════════════════════════════════════════════════════════════════════
# FIXTURES ESPECIALES
# ═══════════════════════════════════════════════════════════════════════════
 
@pytest.fixture
def temp_artifacts_dir(tmp_path) -> Path:
    """Directorio temporal para artefactos."""
    artifacts = tmp_path / "artifacts"
    artifacts.mkdir()
    return artifacts
 
 
@pytest.fixture(scope="module")
def slow_fixture():
    """Fixture que tarda en crearse - se reutiliza en todo el módulo.
    
    scope="module" significa que se crea UNA vez por archivo de test,
    no una vez por cada test.
    """
    import time
    time.sleep(0.1)  # Simula operación lenta
    return {"expensive_resource": True}
```
 
### Uso de Fixtures en Tests
 
```python
# tests/test_features.py
 
def test_feature_engineer_creates_vehicle_age(sample_data):
    """Test que usa la fixture sample_data."""
    from src.carvision.features import FeatureEngineer
    
    fe = FeatureEngineer(current_year=2024)
    result = fe.transform(sample_data)
    
    assert "vehicle_age" in result.columns
    assert result["vehicle_age"].iloc[0] == 2024 - 2015  # 9 años
 
 
def test_pipeline_predicts_positive_prices(fitted_pipeline, sample_data):
    """Test que usa DOS fixtures."""
    X = sample_data.drop(columns=["price"])
    predictions = fitted_pipeline.predict(X)
    
    assert all(predictions > 0), "Precios deben ser positivos"
```
 
---
 
<a id="113-unit-tests-funciones-individuales"></a>
 
## 11.3 Unit Tests: Funciones Individuales
 
### Qué Testear en Unit Tests
 
```python
# tests/test_features.py - Código REAL del portafolio
 
import pytest
import pandas as pd
from src.carvision.features import FeatureEngineer
 
 
class TestFeatureEngineer:
    """Tests unitarios para FeatureEngineer."""
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Creación de features
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_creates_vehicle_age(self, sample_data):
        """Verifica que vehicle_age se calcula correctamente."""
        fe = FeatureEngineer(current_year=2024)
        result = fe.transform(sample_data)
        
        assert "vehicle_age" in result.columns
        # 2024 - 2015 = 9 años para el primer registro
        assert result.loc[0, "vehicle_age"] == 9
    
    def test_creates_brand_from_model(self, sample_data):
        """Verifica que brand extrae la primera palabra de model."""
        fe = FeatureEngineer(current_year=2024)
        result = fe.transform(sample_data)
        
        assert "brand" in result.columns
        assert result.loc[0, "brand"] == "ford"  # "ford f-150" → "ford"
        assert result.loc[1, "brand"] == "toyota"  # "toyota camry" → "toyota"
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Manejo de edge cases
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_handles_missing_model_year(self):
        """Verifica comportamiento con model_year faltante."""
        df = pd.DataFrame({
            "price": [15000],
            "model": ["ford f-150"],
            # Sin model_year
        })
        
        fe = FeatureEngineer(current_year=2024)
        result = fe.transform(df)
        
        # No debe crear vehicle_age si no hay model_year
        assert "vehicle_age" not in result.columns
    
    def test_handles_missing_model_column(self):
        """Verifica comportamiento sin columna model."""
        df = pd.DataFrame({
            "price": [15000],
            "model_year": [2015],
            # Sin model
        })
        
        fe = FeatureEngineer(current_year=2024)
        result = fe.transform(df)
        
        # No debe crear brand si no hay model
        assert "brand" not in result.columns
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Inmutabilidad
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_does_not_modify_input(self, sample_data):
        """Verifica que el DataFrame original no se modifica."""
        original_columns = sample_data.columns.tolist()
        original_values = sample_data.copy()
        
        fe = FeatureEngineer(current_year=2024)
        _ = fe.transform(sample_data)
        
        # Columnas originales sin cambio
        assert sample_data.columns.tolist() == original_columns
        # Valores originales sin cambio
        pd.testing.assert_frame_equal(sample_data, original_values)
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Compatibilidad con sklearn
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_fit_returns_self(self, sample_data):
        """Verifica que fit() retorna self (requerido por sklearn)."""
        fe = FeatureEngineer(current_year=2024)
        result = fe.fit(sample_data)
        
        assert result is fe
    
    def test_works_in_pipeline(self, sample_data):
        """Verifica que funciona dentro de un Pipeline sklearn."""
        from sklearn.pipeline import Pipeline
        from sklearn.preprocessing import StandardScaler
        
        pipe = Pipeline([
            ("features", FeatureEngineer(current_year=2024)),
            ("scaler", StandardScaler())
        ])
        
        # No debe lanzar excepción
        # (Solo probamos que no falla, no el resultado)
        try:
            # Seleccionar solo columnas numéricas para StandardScaler
            numeric_cols = ["price", "model_year", "odometer"]
            result = pipe.fit_transform(sample_data[numeric_cols])
            assert result is not None
        except Exception as e:
            pytest.fail(f"Pipeline falló: {e}")
```
 
---
 
<a id="114-data-tests-validacion-de-datos"></a>
 
## 11.4 Data Tests: Validación de Datos
 
### Tests de Schema y Calidad de Datos
 
```python
# tests/test_data.py - Código REAL del portafolio
 
import pytest
import pandas as pd
import numpy as np
from src.carvision.data import load_data, clean_data
 
 
class TestDataLoading:
    """Tests de carga y validación de datos."""
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Schema validation
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_required_columns_exist(self, sample_data):
        """Verifica que existen las columnas requeridas."""
        required = ["price", "model_year", "odometer", "model", "fuel"]
        
        for col in required:
            assert col in sample_data.columns, f"Falta columna: {col}"
    
    def test_column_types(self, sample_data):
        """Verifica tipos de datos correctos."""
        # Numéricas
        assert pd.api.types.is_numeric_dtype(sample_data["price"])
        assert pd.api.types.is_numeric_dtype(sample_data["model_year"])
        assert pd.api.types.is_numeric_dtype(sample_data["odometer"])
        
        # Categóricas/String
        assert pd.api.types.is_object_dtype(sample_data["model"])
        assert pd.api.types.is_object_dtype(sample_data["fuel"])
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Value ranges
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_price_is_positive(self, sample_data):
        """Verifica que precios son positivos."""
        assert (sample_data["price"] > 0).all(), "Hay precios <= 0"
    
    def test_price_in_reasonable_range(self, sample_data):
        """Verifica que precios están en rango razonable."""
        assert sample_data["price"].min() >= 100, "Precio muy bajo (posible error)"
        assert sample_data["price"].max() <= 500000, "Precio muy alto (posible error)"
    
    def test_model_year_in_range(self, sample_data):
        """Verifica que años son razonables."""
        current_year = pd.Timestamp.now().year
        
        assert sample_data["model_year"].min() >= 1900, "Año muy antiguo"
        assert sample_data["model_year"].max() <= current_year + 1, "Año futuro"
    
    def test_odometer_is_non_negative(self, sample_data):
        """Verifica que odometer no es negativo."""
        assert (sample_data["odometer"] >= 0).all(), "Hay odometer negativo"
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Categorical values
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_fuel_valid_values(self, sample_data):
        """Verifica que fuel tiene valores válidos."""
        valid_fuels = {"gas", "diesel", "electric", "hybrid", "other"}
        actual_fuels = set(sample_data["fuel"].dropna().unique())
        
        invalid = actual_fuels - valid_fuels
        assert len(invalid) == 0, f"Valores de fuel inválidos: {invalid}"
    
    def test_transmission_valid_values(self, sample_data):
        """Verifica que transmission tiene valores válidos."""
        valid = {"automatic", "manual", "other"}
        actual = set(sample_data["transmission"].dropna().unique())
        
        invalid = actual - valid
        assert len(invalid) == 0, f"Valores de transmission inválidos: {invalid}"
 
 
class TestDataCleaning:
    """Tests de limpieza de datos."""
    
    def test_clean_data_removes_invalid_prices(self, sample_data):
        """Verifica que clean_data filtra precios fuera de rango."""
        # Añadir registro con precio inválido
        bad_data = pd.concat([
            sample_data,
            pd.DataFrame({"price": [100], "model_year": [2020], 
                         "odometer": [1000], "model": ["test"],
                         "fuel": ["gas"], "transmission": ["automatic"],
                         "condition": ["good"]})
        ], ignore_index=True)
        
        filters = {"price_min": 1000, "price_max": 100000}
        cleaned = clean_data(bad_data, filters=filters)
        
        # El registro con price=100 debe ser eliminado
        assert len(cleaned) == len(sample_data)
        assert (cleaned["price"] >= 1000).all()
    
    def test_clean_data_handles_nulls(self, sample_data_with_nulls):
        """Verifica que clean_data no falla con NaN."""
        # No debe lanzar excepción
        filters = {"price_min": 1000}
        cleaned = clean_data(sample_data_with_nulls, filters=filters)
        
        assert cleaned is not None
        # Registros con price=None deben ser eliminados o manejados
        assert len(cleaned) <= len(sample_data_with_nulls)
```
 
---
 
<a id="115-model-tests-comportamiento-del-modelo"></a>
 
## 11.5 Model Tests: Comportamiento del Modelo
 
### Tests Específicos de ML
 
```python
# tests/test_model_logic.py - Código REAL del portafolio
 
import pytest
import numpy as np
import pandas as pd
 
 
class TestModelPredictions:
    """Tests de comportamiento del modelo."""
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Output shape y tipo
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_predict_returns_correct_shape(self, fitted_pipeline, sample_data):
        """Verifica que predict retorna un array del tamaño correcto."""
        X = sample_data.drop(columns=["price"])
        predictions = fitted_pipeline.predict(X)
        
        assert len(predictions) == len(X), "Número de predicciones incorrecto"
    
    def test_predict_returns_numeric(self, fitted_pipeline, sample_data):
        """Verifica que predicciones son numéricas."""
        X = sample_data.drop(columns=["price"])
        predictions = fitted_pipeline.predict(X)
        
        assert np.issubdtype(predictions.dtype, np.number), "Predicciones no son numéricas"
    
    def test_predict_no_nan(self, fitted_pipeline, sample_data):
        """Verifica que no hay NaN en predicciones."""
        X = sample_data.drop(columns=["price"])
        predictions = fitted_pipeline.predict(X)
        
        assert not np.isnan(predictions).any(), "Hay NaN en predicciones"
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Rangos razonables
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_predictions_are_positive(self, fitted_pipeline, sample_data):
        """Verifica que precios predichos son positivos."""
        X = sample_data.drop(columns=["price"])
        predictions = fitted_pipeline.predict(X)
        
        assert (predictions > 0).all(), "Hay predicciones <= 0"
    
    def test_predictions_in_training_range(self, fitted_pipeline, sample_data):
        """Verifica que predicciones están en rango similar al training."""
        X = sample_data.drop(columns=["price"])
        y = sample_data["price"]
        predictions = fitted_pipeline.predict(X)
        
        # Predicciones deben estar dentro de un margen razonable
        min_price = y.min() * 0.1  # 10% del mínimo
        max_price = y.max() * 3.0  # 300% del máximo
        
        assert predictions.min() >= min_price, "Predicción muy baja"
        assert predictions.max() <= max_price, "Predicción muy alta"
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Consistencia (determinismo)
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_predictions_are_deterministic(self, fitted_pipeline, sample_data):
        """Verifica que mismos inputs dan mismos outputs."""
        X = sample_data.drop(columns=["price"])
        
        pred1 = fitted_pipeline.predict(X)
        pred2 = fitted_pipeline.predict(X)
        
        np.testing.assert_array_equal(pred1, pred2, 
            "Predicciones no son determinísticas")
    
    # ═══════════════════════════════════════════════════════════════════════
    # TEST: Sensibilidad a features
    # ═══════════════════════════════════════════════════════════════════════
    
    def test_higher_odometer_lower_price(self, fitted_pipeline, sample_data):
        """Verifica que mayor odometer tiende a menor precio.
        
        Este es un test de "sanity check": verifica que el modelo
        aprendió relaciones básicas del dominio.
        """
        X = sample_data.drop(columns=["price"]).copy()
        
        # Predicción con odometer original
        pred_low_odo = fitted_pipeline.predict(X)
        
        # Aumentar odometer significativamente
        X_high_odo = X.copy()
        X_high_odo["odometer"] = X["odometer"] * 3
        pred_high_odo = fitted_pipeline.predict(X_high_odo)
        
        # En promedio, mayor odometer → menor precio
        # (No requiere que TODOS sean menores, solo el promedio)
        assert pred_high_odo.mean() < pred_low_odo.mean(), \
            "Modelo no aprendió que mayor odometer = menor precio"
    
    def test_newer_car_higher_price(self, fitted_pipeline, sample_data):
        """Verifica que autos más nuevos tienden a mayor precio."""
        X = sample_data.drop(columns=["price"]).copy()
        
        # Predicción con model_year original
        pred_original = fitted_pipeline.predict(X)
        
        # Hacer autos 5 años más nuevos
        X_newer = X.copy()
        X_newer["model_year"] = X["model_year"] + 5
        pred_newer = fitted_pipeline.predict(X_newer)
        
        # En promedio, más nuevo → mayor precio
        assert pred_newer.mean() > pred_original.mean(), \
            "Modelo no aprendió que autos nuevos cuestan más"
 
 
class TestModelMetrics:
    """Tests de métricas del modelo."""
    
    def test_rmse_below_threshold(self, fitted_pipeline, sample_data):
        """Verifica que RMSE está por debajo de umbral aceptable."""
        from sklearn.metrics import mean_squared_error
        
        X = sample_data.drop(columns=["price"])
        y = sample_data["price"]
        predictions = fitted_pipeline.predict(X)
        
        rmse = np.sqrt(mean_squared_error(y, predictions))
        
        # RMSE debe ser menor que el 50% del precio promedio
        # (umbral arbitrario para sample data pequeño)
        threshold = y.mean() * 0.5
        assert rmse < threshold, f"RMSE={rmse:.2f} > threshold={threshold:.2f}"
    
    def test_r2_above_threshold(self, fitted_pipeline, sample_data):
        """Verifica que R² está por encima de umbral mínimo."""
        from sklearn.metrics import r2_score
        
        X = sample_data.drop(columns=["price"])
        y = sample_data["price"]
        predictions = fitted_pipeline.predict(X)
        
        r2 = r2_score(y, predictions)
        
        # R² debe ser positivo (mejor que predecir la media)
        # Nota: Con sample data pequeño, R² puede ser bajo
        assert r2 > 0.0, f"R²={r2:.3f} <= 0 (peor que baseline)"
```
 
---
 
<a id="116-integration-tests-pipeline-completo"></a>
 
## 11.6 Integration Tests: Pipeline Completo
 
### Tests End-to-End
 
```python
# tests/test_main_workflow.py - Código REAL del portafolio
 
import pytest
import pandas as pd
import numpy as np
from pathlib import Path
import tempfile
import joblib
 
 
class TestTrainingWorkflow:
    """Tests de integración del flujo completo de entrenamiento."""
    
    def test_full_training_pipeline(self, sample_data, sample_config, tmp_path):
        """Test end-to-end: datos → entrenamiento → modelo guardado."""
        from src.carvision.training import train_model
        
        # Configurar paths temporales
        sample_config["paths"]["artifacts_dir"] = str(tmp_path)
        sample_config["paths"]["model_path"] = str(tmp_path / "model.joblib")
        
        # Guardar datos temporales
        data_path = tmp_path / "data.csv"
        sample_data.to_csv(data_path, index=False)
        sample_config["paths"]["data_path"] = str(data_path)
        
        # Ejecutar entrenamiento
        result = train_model(sample_config)
        
        # Verificaciones
        assert "rmse" in result, "Falta métrica RMSE"
        assert result["rmse"] > 0, "RMSE debe ser positivo"
        
        # Verificar que modelo se guardó
        model_path = Path(sample_config["paths"]["model_path"])
        assert model_path.exists(), "Modelo no se guardó"
        
        # Verificar que modelo se puede cargar
        model = joblib.load(model_path)
        assert model is not None, "Modelo no se puede cargar"
    
    def test_training_creates_all_artifacts(self, sample_data, sample_config, tmp_path):
        """Verifica que entrenamiento crea todos los artefactos esperados."""
        from src.carvision.training import train_model
        
        # Setup
        sample_config["paths"]["artifacts_dir"] = str(tmp_path)
        sample_config["paths"]["model_path"] = str(tmp_path / "model.joblib")
        sample_config["paths"]["metrics_path"] = str(tmp_path / "metrics.json")
        
        data_path = tmp_path / "data.csv"
        sample_data.to_csv(data_path, index=False)
        sample_config["paths"]["data_path"] = str(data_path)
        
        # Train
        train_model(sample_config)
        
        # Verificar artefactos
        assert (tmp_path / "model.joblib").exists(), "Falta model.joblib"
        # metrics.json es opcional en algunos configs
    
    def test_loaded_model_predicts_correctly(self, sample_data, sample_config, tmp_path):
        """Verifica que modelo guardado predice igual que antes de guardar."""
        from src.carvision.training import train_model, build_pipeline
        from src.carvision.features import FeatureEngineer
        
        # Setup y entrenamiento
        sample_config["paths"]["artifacts_dir"] = str(tmp_path)
        model_path = tmp_path / "model.joblib"
        sample_config["paths"]["model_path"] = str(model_path)
        
        data_path = tmp_path / "data.csv"
        sample_data.to_csv(data_path, index=False)
        sample_config["paths"]["data_path"] = str(data_path)
        
        train_model(sample_config)
        
        # Cargar modelo
        loaded_model = joblib.load(model_path)
        
        # Predecir con nuevo dato
        new_data = pd.DataFrame({
            "model_year": [2020],
            "odometer": [30000],
            "model": ["ford f-150"],
            "fuel": ["gas"],
            "transmission": ["automatic"],
        })
        
        prediction = loaded_model.predict(new_data)
        
        # Verificaciones básicas
        assert len(prediction) == 1
        assert prediction[0] > 0
        assert not np.isnan(prediction[0])
 
 
class TestAPIWorkflow:
    """Tests de integración del API."""
    
    @pytest.mark.slow
    def test_api_prediction_endpoint(self, fitted_pipeline, tmp_path):
        """Test E2E del endpoint de predicción."""
        from fastapi.testclient import TestClient
        import sys
        
        # Guardar modelo para el API
        model_path = tmp_path / "model.joblib"
        joblib.dump(fitted_pipeline, model_path)
        
        # Importar app (puede requerir configuración de paths)
        # Este test asume que ARTIFACTS_DIR está configurado
        import os
        os.environ["ARTIFACTS_DIR"] = str(tmp_path)
        
        try:
            from app.fastapi_app import app
            client = TestClient(app)
            
            # Request de predicción
            response = client.post("/predict", json={
                "model_year": 2020,
                "odometer": 30000,
                "model": "ford f-150",
                "fuel": "gas",
                "transmission": "automatic"
            })
            
            assert response.status_code == 200
            data = response.json()
            assert "prediction" in data
            assert data["prediction"] > 0
        except ImportError:
            pytest.skip("FastAPI app not available")
```
 
---
 
<a id="errores-habituales"></a>
 
## 🧨 Errores habituales y cómo depurarlos en testing ML
 
Aunque pytest es muy potente, en ML es fácil caer en tests frágiles o engañosos. Estos son los patrones más comunes y cómo atacarlos.
 
Si alguno de estos errores te tomó **>15 minutos**, regístralo en el **[Diario de Errores](study_tools/DIARIO_ERRORES.md)** y aplica el flujo de **rescate cognitivo** de **[Protocolo E](study_tools/PROTOCOLO_E.md)**.
 
### 1) Tests que dependen de datos reales o externos
 
**Síntomas típicos**
 
- Tests que leen de `data/raw/...` o llaman APIs externas.
- Fallan solo en CI o solo en ciertas máquinas.
 
**Cómo identificarlo**
 
- Busca en tests accesos directos a rutas del proyecto o a recursos externos.
- Revisa que tus fixtures (`sample_data`, `sample_config`, etc.) no lean de archivos reales salvo cuando se prueban funciones de I/O.
 
**Cómo corregirlo**
 
- Usa **fixtures sintéticas** en memoria para la mayoría de tests.
- Deja el acceso a disco/red solo en tests de integración marcados (`@pytest.mark.integration` o `@pytest.mark.slow`).
 
---
 
<a id="117-alcanzar-80-coverage"></a>
 
## 11.7 Alcanzar 80% Coverage
 
### Configuración de pytest-cov
 
```toml
# pyproject.toml
 
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "-v",
    "--cov=src/carvision",
    "--cov-report=term-missing",
    "--cov-report=html",
    "--cov-fail-under=80",
]
markers = [
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
    "integration: marks tests as integration tests",
]
 
[tool.coverage.run]
source = ["src"]
omit = [
    "tests/*",
    "*/__init__.py",
    "*/visualization.py",  # Excluir código de UI
]
 
[tool.coverage.report]
fail_under = 80
exclude_lines = [
    "pragma: no cover",
    "if __name__ == .__main__.:",
    "raise NotImplementedError",
]
```
 
### Ejecutar Tests con Coverage
 
```bash
# Tests rápidos (sin slow)
pytest -m "not slow"
 
# Todos los tests con coverage
pytest --cov=src/carvision --cov-report=term-missing
 
# Solo ver coverage sin ejecutar tests
pytest --cov=src/carvision --cov-report=html
# Abre htmlcov/index.html en el navegador
 
# Verificar que pasa el threshold
pytest --cov-fail-under=80
```
 
### Estrategias para Aumentar Coverage
 
```
╔═══════════════════════════════════════════════════════════════════════════╗
║  📈 CÓMO PASAR DE 60% A 80% COVERAGE                                      ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║  1. IDENTIFICAR GAPS                                                      ║
║     pytest --cov-report=term-missing                                      ║
║     → Muestra líneas NO cubiertas                                         ║
║                                                                           ║
║  2. PRIORIZAR                                                             ║
║     • Lógica de negocio crítica (training, prediction)                    ║
║     • Código que maneja errores                                           ║
║     • Branches condicionales (if/else)                                    ║
║                                                                           ║
║  3. EXCLUIR LO QUE NO VALE LA PENA                                        ║
║     • Código de visualización (Streamlit, plots)                          ║
║     • Scripts de utilidad one-off                                         ║
║     • Código de terceros                                                  ║
║                                                                           ║
║  4. TESTEAR EDGE CASES                                                    ║
║     • ¿Qué pasa con NaN?                                                  ║
║     • ¿Qué pasa con lista vacía?                                          ║
║     • ¿Qué pasa con tipos incorrectos?                                    ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```
 
---
 
<a id="checkpoint"></a>
 
## ✅ Checkpoint: ¿Completaste el Módulo?
 
Antes de continuar, verifica:
 
- [ ] Tienes `tests/conftest.py` con fixtures reutilizables
- [ ] Tienes tests unitarios para tus transformers
- [ ] Tienes tests de validación de datos
- [ ] Tienes tests de comportamiento del modelo
- [ ] Tienes al menos un test de integración
- [ ] Tu coverage es >= 80%
 
---
 
<a id="como-se-uso-en-el-portafolio"></a>
 
## 📦 Cómo se Usó en el Portafolio
 
Los 3 proyectos del portafolio implementan testing profesional con 80%+ coverage:
 
### Coverage por Proyecto
 
| Proyecto | Coverage | Tests | Archivos Clave |
|----------|:--------:|:-----:|----------------|
| BankChurn | 79%+ | 45+ | `tests/conftest.py`, `test_pipeline.py` |
| CarVision | 97% | 50+ | `tests/test_features.py`, `test_data.py` |
| TelecomAI | 97% | 35+ | `tests/test_training.py` |
 
### conftest.py Real (CarVision)
 
```python
# CarVision-Market-Intelligence/tests/conftest.py
import pytest
import pandas as pd
 
@pytest.fixture
def sample_df():
    """DataFrame de prueba con datos realistas."""
    return pd.DataFrame({
        'model': ['Ford F-150', 'Toyota Camry'],
        'model_year': [2020, 2019],
        'odometer': [50000, 30000],
        'price': [35000, 25000]
    })
 
 
@pytest.fixture
def config():
    """Configuración de prueba."""
    return {
        'data': {'target_column': 'price'},
        'model': {'random_state': 42}
    }
```
 
### Estructura de Tests
 
```
tests/
├── conftest.py           # Fixtures compartidas
├── test_config.py        # Tests de configuración
├── test_data.py          # Tests de carga/validación
├── test_features.py      # Tests de FeatureEngineer
├── test_pipeline.py      # Tests de pipeline
├── test_training.py      # Tests de entrenamiento
└── test_api.py           # Tests de FastAPI
```
 
### 🔧 Ejercicio: Ejecuta Tests Reales
 
<a id="ejercicio"></a>
 
```bash
# 1. Ejecuta tests de CarVision
cd CarVision-Market-Intelligence
pytest tests/ -v --cov=src/carvision --cov-report=term-missing
 
# 2. Ve qué líneas NO están cubiertas
pytest --cov-report=html  # Genera htmlcov/index.html

# 3. Compara con BankChurn
cd ../BankChurn-Predictor
pytest tests/ -v --cov=src/bankchurn
```

---

## 💼 Consejos Profesionales

> **Recomendaciones para destacar en entrevistas y proyectos reales**

### Para Entrevistas

1. **Testing ML es diferente**: Explica tests de datos, modelo, y serving (no solo código).

2. **Great Expectations**: Menciona que usas validación de datos como parte del pipeline.

3. **Coverage no es todo**: Un modelo con 100% coverage puede fallar en producción.

### Para Proyectos Reales

| Tipo de Test | Qué Verificar |
|--------------|---------------|
| Data Tests | Schema, rangos, distribuciones, nulls |
| Model Tests | Métricas mínimas, overfitting, invariancia |
| Integration | Pipeline end-to-end, API responses |
| Performance | Latencia, throughput, memory |

### Estrategia de Testing ML

```
Unit Tests:     Transformadores individuales
Integration:    Pipeline completo con datos sintéticos
Validation:     Métricas en holdout real
Monitoring:     Drift detection en producción
```


---

## 📺 Recursos Externos Recomendados

> Ver [RECURSOS_POR_MODULO.md](RECURSOS_POR_MODULO.md) para la lista completa.

| 🏷️ | Recurso | Tipo |
|:--:|:--------|:-----|
| 🔴 | [pytest Tutorial - ArjanCodes](https://www.youtube.com/watch?v=cHYq1MRoyI0) | Video |
| 🟡 | [Testing for Data Science - Eric Ma](https://www.youtube.com/watch?v=0ysyWk-ox-8) | Video |

**Documentación oficial:**
- [pytest Documentation](https://docs.pytest.org/)
- [pytest-cov](https://pytest-cov.readthedocs.io/)
- [Great Expectations](https://greatexpectations.io/) - Data validation

---

## 🔗 Referencias del Glosario

Ver [21_GLOSARIO.md](21_GLOSARIO.md) para definiciones de:
- **conftest.py**: Fixtures compartidas de pytest
- **Coverage**: Porcentaje de código ejecutado por tests
- **Fixture**: Setup reutilizable para tests

---

## ✅ Ejercicios

Ver [EJERCICIOS.md](EJERCICIOS.md) - Módulo 11:
- **11.1**: Test de validación de datos
- **11.2**: Test de pipeline ML

---

<div align="center">

[← Volver al Índice](00_INDICE.md) | [Siguiente: CI/CD →](12_CI_CD.md)

</div>
