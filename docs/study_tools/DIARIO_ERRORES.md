# 📓 Diario de Errores

> Tu base de conocimiento personal de problemas resueltos.

---

## 🎯 Propósito

El Diario de Errores es tu **segundo cerebro** para debugging. Cada error que documentas hoy es una solución instantánea mañana.

### Beneficios

1. **Evita resolver el mismo problema dos veces**
2. **Acelera tu debugging** con patrones reconocibles
3. **Demuestra tu crecimiento** como ingeniero
4. **Material para entrevistas**: "Cuéntame de un bug difícil que resolviste"

---

## 📋 Formato de Entrada

```markdown
---
## [FECHA] - [Título descriptivo]

**Módulo:** [Número y nombre del módulo]
**Herramientas:** [Python, Docker, MLflow, etc.]
**Tiempo para resolver:** [X minutos/horas]
**Severidad:** 🟢 Menor | 🟡 Moderado | 🔴 Bloqueante

### Síntoma
[¿Qué comportamiento observaste?]

### Error exacto
```
[Pegar mensaje de error completo]
```

### Causa raíz
[¿Por qué ocurrió realmente?]

### Solución
```bash
# Comandos o código que lo resolvieron
```

### Prevención
[¿Cómo evitar que vuelva a pasar?]

### Tags
`#docker` `#mlflow` `#python` `#permisos` `#dependencias`

---
```

---

## 📚 Ejemplos de Entradas

### Ejemplo 1: Error de Docker

```markdown
---
## 2024-01-15 - Container no encuentra módulo Python

**Módulo:** 13_DOCKER
**Herramientas:** Docker, Python, pip
**Tiempo para resolver:** 45 minutos
**Severidad:** 🔴 Bloqueante

### Síntoma
La API funciona localmente pero falla en Docker con ModuleNotFoundError.

### Error exacto
```
Traceback (most recent call last):
  File "/app/main.py", line 3, in <module>
    from sklearn.ensemble import RandomForestClassifier
ModuleNotFoundError: No module named 'sklearn'
```

### Causa raíz
El Dockerfile instalaba desde `requirements.txt` pero `scikit-learn` 
estaba en `pyproject.toml` como dependencia opcional.

### Solución
```dockerfile
# Antes (incorrecto)
RUN pip install -r requirements.txt

# Después (correcto)
RUN pip install -e ".[all]"
```

### Prevención
- Siempre verificar que las dependencias del Dockerfile coincidan con el entorno local
- Usar `pip freeze > requirements.txt` después de instalar localmente
- Añadir test de smoke en CI que importe los módulos principales

### Tags
`#docker` `#python` `#dependencias` `#sklearn`

---
```

### Ejemplo 2: Error de MLflow

```markdown
---
## 2024-01-20 - MLflow no registra modelo en Registry

**Módulo:** 10_EXPERIMENT_TRACKING
**Herramientas:** MLflow, PostgreSQL
**Tiempo para resolver:** 30 minutos
**Severidad:** 🟡 Moderado

### Síntoma
`mlflow.sklearn.log_model()` funciona pero `mlflow.register_model()` falla.

### Error exacto
```
mlflow.exceptions.MlflowException: Model registry functionality 
is unavailable; got unsupported URI './mlruns' for model registry
```

### Causa raíz
Model Registry requiere backend de base de datos (PostgreSQL/MySQL), 
no funciona con el backend de archivos por defecto.

### Solución
```bash
# Iniciar MLflow con backend de PostgreSQL
mlflow server \
    --backend-store-uri postgresql://user:pass@localhost/mlflow \
    --default-artifact-root ./mlruns \
    --host 0.0.0.0
```

### Prevención
- Leer la documentación de Model Registry antes de usarlo
- Usar docker-compose con PostgreSQL desde el inicio
- Añadir check de conexión a DB en scripts de setup

### Tags
`#mlflow` `#model-registry` `#postgresql` `#configuracion`

---
```

### Ejemplo 3: Error de Git/Pre-commit

```markdown
---
## 2024-01-25 - Pre-commit bloquea commits

**Módulo:** 05_GIT_PROFESIONAL
**Herramientas:** Git, pre-commit, Black
**Tiempo para resolver:** 15 minutos
**Severidad:** 🟢 Menor

### Síntoma
No puedo hacer commit, Black reformatea archivos infinitamente.

### Error exacto
```
black....................................................................Failed
- hook id: black
- files were modified by this hook

reformatted src/model.py

All done! ✨ 🍰 ✨
1 file reformatted.
```

### Causa raíz
Black reformatea el archivo, pero pre-commit no añade los cambios 
automáticamente, así que el siguiente intento vuelve a reformatear.

### Solución
```bash
# Ejecutar Black primero, luego añadir cambios
black src/
git add -u
git commit -m "mensaje"

# O hacer commit en dos pasos
git commit -m "mensaje"  # falla y reformatea
git add -u               # añadir cambios de Black
git commit -m "mensaje"  # ahora funciona
```

### Prevención
- Ejecutar `pre-commit run --all-files` antes del primer commit
- Configurar IDE para formatear con Black al guardar
- Usar `pre-commit install --hook-type pre-commit`

### Tags
`#git` `#pre-commit` `#black` `#formateo`

---
```

---

## 🔍 Cómo Buscar en tu Diario

### Por Tags
```bash
# Buscar todos los errores de Docker
grep -l "#docker" DIARIO_ERRORES.md

# Buscar errores bloqueantes
grep -B5 "🔴 Bloqueante" DIARIO_ERRORES.md
```

### Por Módulo
```bash
grep -A20 "Módulo: 13_DOCKER" DIARIO_ERRORES.md
```

### Por Herramienta
```bash
grep -B2 -A20 "MLflow" DIARIO_ERRORES.md
```

---

## 📊 Estadísticas Útiles

Al final de cada mes, revisa:

```markdown
## Resumen Mensual - [MES]

**Total de errores documentados:** X
**Tiempo total de debugging:** X horas
**Error más común:** [descripción]
**Herramienta más problemática:** [nombre]
**Módulo más desafiante:** [número]

### Top 3 aprendizajes del mes:
1. 
2. 
3. 
```

---

## 🚀 Tu Diario Empieza Aquí

```markdown
---
## [FECHA] - [Tu primer error]

**Módulo:** 
**Herramientas:** 
**Tiempo para resolver:** 
**Severidad:** 🟢 Menor | 🟡 Moderado | 🔴 Bloqueante

### Síntoma


### Error exacto
```

```

### Causa raíz


### Solución
```

```

### Prevención


### Tags


---
```

---

## 🔗 Navegación

- [← Volver a Herramientas de Estudio](index.md)
- [← Protocolo E](PROTOCOLO_E.md)
- [→ Cierre Semanal](CIERRE_SEMANAL.md)
