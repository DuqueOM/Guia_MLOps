# 🔬 Lab 2: Pipeline de Entrenamiento Lento por Pandas

> **Escenario**: El pipeline tarda 10x más de lo esperado  
> **Duración**: 30 minutos  
> **Habilidad**: Optimización de Pandas

---

## El Escenario

Tu pipeline de features tarda 45 minutos en procesar 1M de filas.
El equipo de infra dice: "Con ese tiempo, no podemos hacer reentrenamiento diario."

---

## Código Original (Lento)

```python
# features.py - VERSIÓN LENTA
import pandas as pd

def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    """Feature engineering - tarda 45 min en 1M filas."""
    
    # Feature 1: Ratio por fila
    for idx in range(len(df)):
        df.loc[idx, "BalanceRatio"] = df.loc[idx, "Balance"] / (df.loc[idx, "Salary"] + 1)
    
    # Feature 2: Categoría de edad
    for idx, row in df.iterrows():
        if row["Age"] < 25:
            df.loc[idx, "AgeGroup"] = "young"
        elif row["Age"] < 50:
            df.loc[idx, "AgeGroup"] = "middle"
        else:
            df.loc[idx, "AgeGroup"] = "senior"
    
    # Feature 3: Agregación por grupo
    for customer_id in df["CustomerId"].unique():
        mask = df["CustomerId"] == customer_id
        total = df.loc[mask, "TransactionAmount"].sum()
        df.loc[mask, "CustomerTotal"] = total
    
    return df
```

---

## Paso 1: Identificar los Anti-patrones

### 🔴 Anti-patrón 1: `for idx in range(len(df))`

```python
# ❌ MALO: Iteración explícita
for idx in range(len(df)):
    df.loc[idx, "NewCol"] = df.loc[idx, "A"] / df.loc[idx, "B"]
```

**Problema**: 
- `df.loc[idx, ...]` es O(n) para encontrar la fila
- Total: O(n²) complejidad

### 🔴 Anti-patrón 2: `df.iterrows()`

```python
# ❌ MALO: iterrows es lentísimo
for idx, row in df.iterrows():
    df.loc[idx, "Category"] = categorize(row["Value"])
```

**Problema**:
- Crea una Series por cada fila (copia de memoria)
- ~100x más lento que vectorizado

### 🔴 Anti-patrón 3: Loop sobre valores únicos

```python
# ❌ MALO: Recalcula máscara cada vez
for group in df["Group"].unique():
    mask = df["Group"] == group
    df.loc[mask, "GroupSum"] = df.loc[mask, "Value"].sum()
```

**Problema**:
- Recrea máscara booleana en cada iteración
- No usa las optimizaciones de groupby

---

## Paso 2: Soluciones Vectorizadas

### ✅ Solución 1: Operaciones Vectorizadas

```python
# ✅ BUENO: Operación vectorizada (1 línea)
df["BalanceRatio"] = df["Balance"] / (df["Salary"] + 1)
```

**Speedup**: ~1000x

### ✅ Solución 2: np.select o pd.cut

```python
# ✅ BUENO: np.select para condiciones múltiples
import numpy as np

conditions = [
    df["Age"] < 25,
    df["Age"] < 50,
    df["Age"] >= 50
]
choices = ["young", "middle", "senior"]
df["AgeGroup"] = np.select(conditions, choices, default="unknown")

# O más limpio con pd.cut:
df["AgeGroup"] = pd.cut(
    df["Age"],
    bins=[0, 25, 50, 120],
    labels=["young", "middle", "senior"]
)
```

**Speedup**: ~500x

### ✅ Solución 3: GroupBy + Transform

```python
# ✅ BUENO: groupby().transform() mantiene índice original
df["CustomerTotal"] = df.groupby("CustomerId")["TransactionAmount"].transform("sum")
```

**Speedup**: ~100x

---

## Paso 3: Código Optimizado Completo

```python
# features.py - VERSIÓN RÁPIDA
import pandas as pd
import numpy as np

def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    """Feature engineering optimizado - 30 segundos en 1M filas."""
    
    df = df.copy()  # No modificar original
    
    # Feature 1: Vectorizado
    df["BalanceRatio"] = df["Balance"] / (df["Salary"] + 1)
    
    # Feature 2: pd.cut
    df["AgeGroup"] = pd.cut(
        df["Age"],
        bins=[0, 25, 50, 120],
        labels=["young", "middle", "senior"]
    )
    
    # Feature 3: groupby + transform
    df["CustomerTotal"] = (
        df.groupby("CustomerId")["TransactionAmount"]
        .transform("sum")
    )
    
    return df
```

---

## Paso 4: Benchmark

```python
import time
import pandas as pd
import numpy as np

# Crear datos de prueba
n_rows = 1_000_000
df = pd.DataFrame({
    "CustomerId": np.random.randint(1, 10000, n_rows),
    "Age": np.random.randint(18, 80, n_rows),
    "Balance": np.random.uniform(0, 100000, n_rows),
    "Salary": np.random.uniform(20000, 150000, n_rows),
    "TransactionAmount": np.random.uniform(10, 1000, n_rows),
})

# Benchmark
def time_function(func, df, name):
    start = time.time()
    result = func(df.copy())
    elapsed = time.time() - start
    print(f"{name}: {elapsed:.2f} segundos")
    return result

# Resultados típicos:
# Versión lenta: 2700.00 segundos (45 min)
# Versión rápida: 0.89 segundos
# Speedup: 3000x
```

---

## Paso 5: Más Optimizaciones

### Usar Dtypes Correctos

```python
# ❌ MALO: Todo como object/float64
df = pd.read_csv("data.csv")

# ✅ BUENO: Especificar dtypes
df = pd.read_csv(
    "data.csv",
    dtype={
        "CustomerId": "int32",      # vs int64
        "Age": "int8",               # vs int64
        "Category": "category",      # vs object
        "IsActive": "bool",          # vs int64
    }
)

# Reducción de memoria: ~70%
```

### Usar query() para Filtros

```python
# ❌ MALO: Máscaras booleanas complejas
result = df[(df["Age"] > 25) & (df["Balance"] > 1000) & (df["Status"] == "active")]

# ✅ BUENO: query() usa numexpr (más rápido)
result = df.query("Age > 25 and Balance > 1000 and Status == 'active'")
```

### Usar eval() para Cálculos

```python
# ❌ MALO: Crea intermedios
df["Result"] = (df["A"] + df["B"]) / (df["C"] * df["D"])

# ✅ BUENO: eval() sin intermedios
df["Result"] = df.eval("(A + B) / (C * D)")
```

---

## Checklist de Optimización Pandas

```
□ Eliminar loops explícitos (for, iterrows)
□ Usar operaciones vectorizadas
□ Usar np.select/pd.cut para categorías
□ Usar groupby().transform() para agregaciones
□ Especificar dtypes al cargar CSV
□ Usar category para strings repetitivos
□ Usar query() para filtros complejos
□ Usar eval() para fórmulas
```

---

## Ejercicio Final

Optimiza este código:

```python
# Tarda 10 minutos
def calculate_metrics(df):
    results = []
    for customer in df["CustomerId"].unique():
        customer_data = df[df["CustomerId"] == customer]
        results.append({
            "CustomerId": customer,
            "TotalSpend": customer_data["Amount"].sum(),
            "AvgSpend": customer_data["Amount"].mean(),
            "MaxSpend": customer_data["Amount"].max(),
        })
    return pd.DataFrame(results)
```

<details>
<summary>💡 Solución</summary>

```python
# Tarda 0.5 segundos
def calculate_metrics(df):
    return df.groupby("CustomerId")["Amount"].agg(
        TotalSpend="sum",
        AvgSpend="mean",
        MaxSpend="max"
    ).reset_index()
```

</details>
