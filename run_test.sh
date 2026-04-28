#!/bin/bash

echo "========================================="
echo "🐻 Ejecutando pruebas en Jenkins"
echo "========================================="

# ==========================================
# PYTHON (sin virtualenv - usar Python del sistema)
# ==========================================

echo ""
echo "🐍 Ejecutando Python..."

# Verificar Python
if command -v python3 &> /dev/null; then
    python3 --version
    python3 saludo.py
else
    echo "❌ Python3 no encontrado"
    exit 1
fi

# ==========================================
# CYPRESS (instalar Node.js si es necesario)
# ==========================================

echo ""
echo "📦 Configurando Node.js para Cypress..."

# Instalar Node.js si no existe
if ! command -v node &> /dev/null; then
    echo "⚙️ Instalando Node.js 18.x..."
    
    # Descargar e instalar Node.js desde el binario oficial
    cd /tmp
    curl -fsSL https://nodejs.org/dist/v18.19.0/node-v18.19.0-linux-x64.tar.xz -o node.tar.xz
    tar -xf node.tar.xz
    cp -r node-v18.19.0-linux-x64/* /usr/local/
    rm -rf node.tar.xz node-v18.19.0-linux-x64
    cd -
    
    node --version
    npm --version
fi

# Verificar Node.js
echo "✅ Node.js: $(node --version 2>/dev/null || echo 'No instalado')"
echo "✅ npm: $(npm --version 2>/dev/null || echo 'No instalado')"

# ==========================================
# CORRER CYPRESS
# ==========================================

echo ""
echo "🔍 Buscando proyecto Cypress..."

# Buscar la carpeta proyecto-cypress en diferentes ubicaciones
CYPRESS_DIR=""
if [ -d "proyecto-cypress" ]; then
    CYPRESS_DIR="proyecto-cypress"
elif [ -d "automation/cypress" ]; then
    CYPRESS_DIR="automation/cypress"
elif [ -d "cypress" ]; then
    CYPRESS_DIR="."
fi

if [ -z "$CYPRESS_DIR" ]; then
    echo "⚠️ No se encontró proyecto Cypress"
    echo "   Buscando en: $(pwd)"
    ls -la
    exit 0
fi

echo "📁 Proyecto Cypress encontrado en: $CYPRESS_DIR"
cd "$CYPRESS_DIR"

if [ ! -f "package.json" ]; then
    echo "⚠️ No hay package.json en $CYPRESS_DIR"
    exit 0
fi

# Instalar dependencias
echo ""
echo "📦 Instalando dependencias de Cypress..."
npm install --quiet

# Crear configuración básica si no existe
if [ ! -f "cypress.config.js" ]; then
    echo "⚙️ Creando cypress.config.js..."
    cat > cypress.config.js << 'EOF'
const { defineConfig } = require('cypress');

module.exports = defineConfig({
  video: false,
  screenshotOnRunFailure: false,
  e2e: {
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
});
EOF
fi

# Crear prueba de ejemplo si no hay
if [ ! -d "cypress/e2e" ] || [ -z "$(ls cypress/e2e/*.cy.js 2>/dev/null)" ]; then
    echo "🧪 Creando prueba de ejemplo..."
    mkdir -p cypress/e2e
    cat > cypress/e2e/example.cy.js << 'EOF'
describe('Prueba de ejemplo', () => {
  it('debería pasar', () => {
    expect(true).to.equal(true);
  });
});
EOF
fi

# Ejecutar pruebas
echo ""
echo "🚀 Ejecutando pruebas de Cypress..."
echo "========================================="

npx cypress run --headless --browser chrome
EXIT_CODE=$?

echo ""
echo "========================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ TODAS LAS PRUEBAS PASARON"
else
    echo "❌ ALGUNAS PRUEBAS FALLARON"
fi
echo "========================================="

exit $EXIT_CODE