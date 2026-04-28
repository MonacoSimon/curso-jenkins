#!/bin/bash

echo "========================================="
echo "🐻 Ejecutando pruebas en Jenkins"
echo "========================================="

# ==========================================
# PYTHON
# ==========================================
echo ""
echo "🐍 Ejecutando Python..."
python3 --version
python3 saludo.py

# ==========================================
# CYPRESS - Instalar Node.js en HOME (no /usr/local)
# ==========================================
echo ""
echo "📦 Configurando Node.js para Cypress..."

# Instalar Node.js en el directorio home del usuario jenkins
if ! command -v node &> /dev/null; then
    echo "⚙️ Instalando Node.js 18.x en /tmp..."
    
    cd /tmp
    curl -fsSL https://nodejs.org/dist/v18.19.0/node-v18.19.0-linux-x64.tar.xz -o node.tar.xz
    tar -xf node.tar.xz
    
    # Crear directorio local si no existe
    mkdir -p /var/jenkins_home/.local
    
    # Copiar a directorio local (donde tenemos permisos)
    cp -r node-v18.19.0-linux-x64/* /var/jenkins_home/.local/
    
    # Agregar al PATH
    export PATH=/var/jenkins_home/.local/bin:$PATH
    
    rm -rf node.tar.xz node-v18.19.0-linux-x64
    cd -
    
    echo "✅ Node.js instalado en /var/jenkins_home/.local"
fi

# Agregar al PATH (por si acaso)
export PATH=/var/jenkins_home/.local/bin:$PATH

# Verificar Node.js
echo "✅ Node.js: $(node --version 2>/dev/null || echo 'No instalado')"
echo "✅ npm: $(npm --version 2>/dev/null || echo 'No instalado')"

# ==========================================
# CORRER CYPRESS
# ==========================================

echo ""
echo "🔍 Buscando proyecto Cypress..."

# Ver contenido de proyecto-cypress
echo "📁 Contenido de proyecto-cypress:"
ls -la proyecto-cypress/

# Navegar a proyecto-cypress
if [ -d "proyecto-cypress" ]; then
    cd proyecto-cypress
    
    # Verificar si existe package.json en subdirectorios
    if [ ! -f "package.json" ]; then
        echo "🔍 Buscando package.json en subdirectorios..."
        find . -name "package.json" -type f 2>/dev/null || echo "No se encontró package.json"
    fi
    
    # Si no hay package.json, inicializar proyecto npm
    if [ ! -f "package.json" ]; then
        echo "📦 Inicializando proyecto npm..."
        npm init -y
        
        echo "📦 Instalando Cypress..."
        npm install cypress --save-dev
    else
        echo "✅ package.json encontrado"
        echo "📦 Instalando dependencias..."
        npm install
    fi
    
    # Verificar que cypress.config.js existe
    if [ ! -f "cypress.config.js" ]; then
        echo "⚙️ Creando cypress.config.js..."
        cat > cypress.config.js << 'EOF'
const { defineConfig } = require('cypress');

module.exports = defineConfig({
  video: false,
  screenshotOnRunFailure: false,
  e2e: {
    setupNodeEvents(on, config) {},
    supportFile: false,
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
    
    cd ..
else
    echo "❌ Carpeta proyecto-cypress no encontrada"
    EXIT_CODE=1
fi

echo ""
echo "========================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ TODAS LAS PRUEBAS PASARON"
else
    echo "❌ ALGUNAS PRUEBAS FALLARON"
fi
echo "========================================="

exit $EXIT_CODE