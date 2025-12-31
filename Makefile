# Makefile for Guía MLOps
# Usage: make <target>

.PHONY: help install docs-serve docs-build validate clean

# Default target
help:
	@echo "╔═══════════════════════════════════════════════════════════════╗"
	@echo "║               Guía MLOps - Comandos Disponibles               ║"
	@echo "╠═══════════════════════════════════════════════════════════════╣"
	@echo "║  make install      - Instalar dependencias de documentación   ║"
	@echo "║  make docs-serve   - Iniciar servidor MkDocs local            ║"
	@echo "║  make docs-build   - Compilar documentación estática          ║"
	@echo "║  make validate     - Validar integridad de la guía            ║"
	@echo "║  make lint-md      - Verificar formato Markdown               ║"
	@echo "║  make clean        - Limpiar archivos generados               ║"
	@echo "╚═══════════════════════════════════════════════════════════════╝"

# Install documentation dependencies
install:
	@echo "📦 Instalando dependencias..."
	pip install -r docs/requirements-docs.txt
	@echo "✅ Dependencias instaladas"

# Serve documentation locally
docs-serve:
	@echo "🚀 Iniciando servidor MkDocs en http://localhost:8000"
	cd docs && mkdocs serve --config-file mkdocs.yml

# Build documentation
docs-build:
	@echo "🔨 Compilando documentación..."
	cd docs && mkdocs build --config-file mkdocs.yml
	@echo "✅ Documentación compilada en site/"

# Validate guide integrity
validate:
	@echo "🔍 Validando integridad de la guía..."
	@chmod +x scripts/validate_guide.sh
	@bash scripts/validate_guide.sh

# Lint markdown files
lint-md:
	@echo "📝 Verificando formato Markdown..."
	@if command -v markdownlint &> /dev/null; then \
		markdownlint docs/**/*.md --ignore docs/apoyo/GLOSARIO.md; \
	else \
		echo "⚠️  markdownlint no instalado. Instalar con: npm install -g markdownlint-cli"; \
	fi

# Clean generated files
clean:
	@echo "🧹 Limpiando archivos generados..."
	rm -rf site/
	rm -rf docs/__pycache__/
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@echo "✅ Limpieza completada"

# Quick validation (just check for critical issues)
validate-quick:
	@echo "⚡ Validación rápida..."
	@test -f docs/index.md || (echo "❌ docs/index.md no existe" && exit 1)
	@test -f docs/mkdocs.yml || (echo "❌ docs/mkdocs.yml no existe" && exit 1)
	@test -f docs/00_INDICE.md || (echo "❌ docs/00_INDICE.md no existe" && exit 1)
	@echo "✅ Archivos críticos presentes"

# Check all links (requires linkchecker)
check-links:
	@echo "🔗 Verificando enlaces..."
	@if command -v linkchecker &> /dev/null; then \
		cd docs && mkdocs serve & sleep 5 && linkchecker http://localhost:8000 --ignore-url='github.com' && kill %1; \
	else \
		echo "⚠️  linkchecker no instalado. Instalar con: pip install linkchecker"; \
	fi

# Deploy to GitHub Pages (for local use)
deploy:
	@echo "🚀 Desplegando a GitHub Pages..."
	cd docs && mkdocs gh-deploy --config-file mkdocs.yml --force
	@echo "✅ Desplegado a GitHub Pages"
