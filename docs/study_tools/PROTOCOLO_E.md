# 🆘 Protocolo E: Sistema de Rescate Cognitivo

> **"E"** = Emergencia, Error, Estancamiento

Cuando llevas **más de 15 minutos** atascado en un problema sin avanzar, es momento de activar el Protocolo E.

---

## 🎯 Objetivo

Convertir un bloqueo frustrante en una oportunidad de aprendizaje estructurado, evitando:

- Pérdida de tiempo en loops improductivos
- Frustración que lleva al abandono
- Soluciones "parche" que no enseñan nada

---

## 📋 El Protocolo (5 pasos)

### Paso 1: PARAR (1 minuto)

```
┌─────────────────────────────────────────────────────────────────┐
│  🛑 ALTO TOTAL                                                 │
│                                                                 │
│  - Quita las manos del teclado                                  │
│  - Respira profundo 3 veces                                     │
│  - Reconoce: "Estoy atascado y eso está bien"                   │
└─────────────────────────────────────────────────────────────────┘
```

### Paso 2: DOCUMENTAR (3-5 minutos)

Escribe en tu [Diario de Errores](DIARIO_ERRORES.md):

```markdown
## [FECHA] - [Módulo/Tema]

### ¿Qué intentaba hacer?
[Descripción clara del objetivo]

### ¿Qué esperaba que pasara?
[Resultado esperado]

### ¿Qué pasó en realidad?
[Resultado actual, error, comportamiento inesperado]

### ¿Qué ya intenté?
- [ ] Intento 1: ...
- [ ] Intento 2: ...
- [ ] Intento 3: ...
```

### Paso 3: REDUCIR (5 minutos)

Simplifica el problema al **mínimo reproducible**:

| Técnica | Ejemplo |
|---------|---------|
| **Aislar** | Si falla en un pipeline, ¿falla en un script simple? |
| **Reducir datos** | ¿Falla con 10 filas? ¿Con 1 fila? |
| **Eliminar dependencias** | ¿Falla sin Docker? ¿Sin la base de datos? |
| **Hardcodear** | ¿Falla si pongo valores fijos en vez de variables? |

```python
# Ejemplo de reducción
# En vez de debuggear todo el pipeline:
import pandas as pd
df = pd.DataFrame({'a': [1, 2], 'b': [3, 4]})
# Probar SOLO la operación que falla
result = df.groupby('a').sum()  # ¿Esto funciona?
```

### Paso 4: BUSCAR (10-15 minutos)

Sigue este orden de búsqueda:

1. **Mensaje de error exacto** → Google/StackOverflow
2. **Documentación oficial** de la herramienta
3. **Issues de GitHub** del proyecto/librería
4. **Este curso** (busca en otros módulos, glosario, FAQ)

```bash
# Tip: Busca el error exacto entre comillas
"ModuleNotFoundError: No module named 'sklearn'"

# Añade contexto relevante
"MLflow FileNotFoundError artifact" site:stackoverflow.com
```

### Paso 5: ESCALAR (si todo lo anterior falla)

| Opción | Cuándo |
|--------|--------|
| **Pregunta estructurada** | Foros, Discord, StackOverflow |
| **Rubber duck debugging** | Explica el problema en voz alta |
| **Cambiar de contexto** | Trabaja en otro módulo 30 min y vuelve |
| **Pedir ayuda** | A un compañero, mentor, comunidad |

**Formato para preguntas efectivas:**

```markdown
## Contexto
- Estoy en el módulo X de la guía MLOps
- Sistema: Ubuntu 22.04 / Python 3.11 / Docker 24.x

## Objetivo
Quiero lograr [X]

## Lo que hice
1. Ejecuté `comando`
2. Esperaba ver [Y]
3. En cambio, obtuve [Z]

## Error completo
[Pegar error completo, no resumido]

## Lo que ya intenté
- Intento 1: [resultado]
- Intento 2: [resultado]

## Código mínimo reproducible
[Código que reproduce el error]
```

---

## ⏱️ Timeboxing del Protocolo

| Paso | Tiempo máximo |
|------|---------------|
| 1. PARAR | 1 min |
| 2. DOCUMENTAR | 5 min |
| 3. REDUCIR | 5 min |
| 4. BUSCAR | 15 min |
| 5. ESCALAR | Variable |
| **TOTAL antes de escalar** | ~26 min |

> Si después de 30 minutos no has resuelto el problema, **ESCALA**. No es rendirse, es ser eficiente.

---

## 🧠 Mentalidad Correcta

### ❌ Mentalidad improductiva
- "Debería poder resolver esto solo"
- "Si pregunto van a pensar que soy tonto"
- "Voy a seguir intentando hasta que funcione"

### ✅ Mentalidad productiva
- "Documentar me ayuda a pensar mejor"
- "Una buena pregunta demuestra que entiendo el problema"
- "Mi tiempo es valioso, saber cuándo escalar es una habilidad"

---

## 📝 Plantilla Rápida

Copia y pega cuando actives el Protocolo E:

```markdown
## 🆘 Protocolo E - [FECHA]

**Módulo:** 
**Tiempo atascado:** 

### 1. ¿Qué intentaba?

### 2. ¿Qué esperaba?

### 3. ¿Qué pasó?

### 4. Intentos previos:
- [ ] 
- [ ] 
- [ ] 

### 5. Problema reducido:

### 6. Búsquedas realizadas:
- [ ] Google: 
- [ ] Docs oficiales: 
- [ ] GitHub Issues: 

### 7. Resolución:
[ ] Resuelto por mí | [ ] Escalado | [ ] Pendiente

**Solución:**

**Aprendizaje:**
```

---

## 🔗 Navegación

- [← Volver a Herramientas de Estudio](index.md)
- [→ Diario de Errores](DIARIO_ERRORES.md)
- [→ Cierre Semanal](CIERRE_SEMANAL.md)
