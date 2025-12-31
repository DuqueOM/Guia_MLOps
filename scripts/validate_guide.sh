#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# validate_guide.sh - Script de validación para guia_mlops
# Verifica integridad de la guía: links, YAML, archivos requeridos
# ═══════════════════════════════════════════════════════════════════════════════

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GUIDE_DIR="$REPO_ROOT/docs"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "═══════════════════════════════════════════════════════════════════════════"
echo "🔍 VALIDACIÓN DE GUÍA MLOps"
echo "═══════════════════════════════════════════════════════════════════════════"
echo "Directorio: $GUIDE_DIR"
echo ""

# Contadores
ERRORS=0
WARNINGS=0

# ═══════════════════════════════════════════════════════════════════════════════
# 1. Verificar archivos requeridos
# ═══════════════════════════════════════════════════════════════════════════════
echo "📁 [1/5] Verificando archivos requeridos..."

REQUIRED_FILES=(
    "00_INDICE.md"
    "01_PYTHON_MODERNO.md"
    "07_SKLEARN_PIPELINES.md"
    "11_TESTING_ML.md"
    "12_CI_CD.md"
    "14_FASTAPI.md"
    "21_GLOSARIO.md"
    "EJERCICIOS.md"
    "EJERCICIOS_SOLUCIONES.md"
    "RECURSOS_POR_MODULO.md"
    "RUBRICA_EVALUACION.md"
    "DECISIONES_TECH.md"
    "MAINTENANCE_GUIDE.md"
    "mkdocs.yml"
    "requirements.txt"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$GUIDE_DIR/$file" ]]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file - NO ENCONTRADO"
        ERRORS=$((ERRORS+1))
    fi
done

# Verificar 23 módulos
echo ""
echo "  Verificando 23 módulos..."
for i in $(seq -w 1 23); do
    # Buscar archivo que empiece con el número
    if ls "$GUIDE_DIR"/${i}_*.md 1> /dev/null 2>&1; then
        MODULE=$(ls "$GUIDE_DIR"/${i}_*.md 2>/dev/null | head -1 | xargs basename)
        echo -e "  ${GREEN}✓${NC} $MODULE"
    else
        echo -e "  ${RED}✗${NC} Módulo $i - NO ENCONTRADO"
        ERRORS=$((ERRORS+1))
    fi
done

# ═══════════════════════════════════════════════════════════════════════════════
# 2. Validar sintaxis YAML
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "📋 [2/5] Validando sintaxis YAML..."

YAML_FILES=(
    "mkdocs.yml"
)

for file in "${YAML_FILES[@]}"; do
    if [[ -f "$GUIDE_DIR/$file" ]]; then
        if python3 - "$GUIDE_DIR/$file" <<'PY' 2>/dev/null; then
import sys

import yaml
from pathlib import Path


path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")


class Loader(yaml.SafeLoader):
    pass


def python_name_multi_constructor(loader, tag_suffix, node):
    # MkDocs configs commonly use !!python/name:... (e.g. pymdownx.superfences)
    # We only validate YAML structure, so keep the referenced name as a string.
    return tag_suffix


Loader.add_multi_constructor(
    "tag:yaml.org,2002:python/name:",
    python_name_multi_constructor,
)

yaml.load(text, Loader=Loader)
PY
            echo -e "  ${GREEN}✓${NC} $file - Sintaxis válida"
        else
            echo -e "  ${RED}✗${NC} $file - Error de sintaxis YAML"
            ERRORS=$((ERRORS+1))
        fi
    fi
done

# ═══════════════════════════════════════════════════════════════════════════════
# 3. Verificar links internos en Markdown
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "🔗 [3/5] Verificando links internos..."

# Extraer todos los links .md y verificar que existen
BROKEN_LINKS=0
CONTENT_DIRS=(
    "$REPO_ROOT/docs"
    "$REPO_ROOT/templates"
    "$REPO_ROOT/exams"
    "$REPO_ROOT/notebooks/labs"
)

for dir in "${CONTENT_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        continue
    fi

    while IFS= read -r -d '' mdfile; do
        base_dir="$(dirname "$mdfile")"

        # Extraer links tipo [texto](archivo.md) o [texto](archivo.md#anchor)
        # Ignorar contenido dentro de bloques de código (``` / ~~~)
        # Nota: solo consideramos el cierre cuando la línea no tiene texto extra tras la fence
        links=$(awk '
            BEGIN {
                in_code = 0
                fence_char = ""
                fence_len = 0
            }
            {
                line = $0
                sub(/^[[:space:]]*/, "", line)

                if (in_code == 0) {
                    if (match(line, /^[`~]{3,}/)) {
                        curr = substr(line, RSTART, RLENGTH)
                        fence_char = substr(curr, 1, 1)
                        fence_len = length(curr)
                        in_code = 1
                        next
                    }
                } else {
                    # Cierre: misma fence (mismo char) con longitud >= apertura y SIN info string
                    if (substr(line, 1, fence_len) == sprintf("%" fence_len "s", "")) {
                        # Unreachable: placeholder to keep awk syntax compatible
                    }
                    if (match(line, "^" fence_char "{" fence_len ",}")) {
                        rem = substr(line, RLENGTH + 1)
                        if (rem ~ /^[[:space:]]*$/) {
                            in_code = 0
                            fence_char = ""
                            fence_len = 0
                            next
                        }
                    }
                }

                if (in_code == 0) {
                    print
                }
            }
        ' "$mdfile" \
            | grep -oE '\]\([^)]+\.md[^)]*\)' 2>/dev/null \
            | sed 's/](\([^)#]*\).*/\1/' \
            | sort -u)

        for link in $links; do
            # Ignorar links externos (http/https)
            if [[ "$link" == http* ]]; then
                continue
            fi

            # Verificar si el archivo existe (resolución relativa al archivo actual)
            target="$base_dir/$link"
            if [[ ! -f "$target" ]]; then
                echo -e "  ${YELLOW}⚠${NC} $(basename "$mdfile"): Link roto → $link"
                BROKEN_LINKS=$((BROKEN_LINKS+1))
                WARNINGS=$((WARNINGS+1))
            fi
        done
    done < <(find "$dir" -type f -name "*.md" -print0)
done

if [[ $BROKEN_LINKS -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} Todos los links internos son válidos"
else
    echo -e "  ${YELLOW}⚠${NC} $BROKEN_LINKS links potencialmente rotos"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# 4. Verificar referencias cruzadas
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "🔀 [4/5] Verificando referencias cruzadas..."

# Verificar que archivos clave están referenciados
check_reference() {
    local file=$1
    local min_refs=$2
    local count=$(grep -r "$file" "$GUIDE_DIR"/*.md 2>/dev/null | wc -l)
    
    if [[ $count -ge $min_refs ]]; then
        echo -e "  ${GREEN}✓${NC} $file referenciado $count veces"
    else
        echo -e "  ${YELLOW}⚠${NC} $file solo referenciado $count veces (esperado: $min_refs+)"
        WARNINGS=$((WARNINGS+1))
    fi
}

check_reference "EJERCICIOS.md" 5
check_reference "RECURSOS_POR_MODULO.md" 5
check_reference "21_GLOSARIO.md" 5
check_reference "RUBRICA_EVALUACION.md" 3
check_reference "DECISIONES_TECH.md" 3

# ═══════════════════════════════════════════════════════════════════════════════
# 5. Verificar tamaño de módulos
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "📊 [5/5] Verificando tamaño de módulos..."

MIN_SIZE=5000  # 5KB mínimo esperado

for i in $(seq -w 1 23); do
    if ls "$GUIDE_DIR"/${i}_*.md 1> /dev/null 2>&1; then
        MODULE=$(ls "$GUIDE_DIR"/${i}_*.md 2>/dev/null | head -1)
        SIZE=$(stat -f%z "$MODULE" 2>/dev/null || stat -c%s "$MODULE" 2>/dev/null)
        
        if [[ $SIZE -lt $MIN_SIZE ]]; then
            echo -e "  ${YELLOW}⚠${NC} $(basename $MODULE): ${SIZE} bytes (< ${MIN_SIZE} bytes)"
            WARNINGS=$((WARNINGS+1))
        fi
    fi
done

if [[ $WARNINGS -eq 0 ]]; then
    echo -e "  ${GREEN}✓${NC} Todos los módulos tienen tamaño adecuado"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# Resumen
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo "📊 RESUMEN"
echo "═══════════════════════════════════════════════════════════════════════════"

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${GREEN}✅ VALIDACIÓN EXITOSA - Sin errores ni advertencias${NC}"
    exit 0
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${YELLOW}⚠️  VALIDACIÓN CON ADVERTENCIAS${NC}"
    echo "   Errores: $ERRORS"
    echo "   Advertencias: $WARNINGS"
    exit 0
else
    echo -e "${RED}❌ VALIDACIÓN FALLIDA${NC}"
    echo "   Errores: $ERRORS"
    echo "   Advertencias: $WARNINGS"
    exit 1
fi
