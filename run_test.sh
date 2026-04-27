#!/bin/bash
echo "instalando entorno virtual"
source venv/bin/activate


echo "instalando dependencias"

pip install -r requirements.txt

#!/bin/bash

echo "========================================="
echo "🐻 Ejecutando pruebas de Cypress"
echo "========================================="

# Verificar Node.js
echo "✅ Verificando Node.js..."
node --version
npm --version

# Navegar al proyecto Cypress
cd automation/cypress  # Ajusta la ruta según tu estructura

# Instalar dependencias (si no están instaladas)
echo "📦 Instalando dependencias de Cypress..."
npm ci  # o npm install

# Limpiar resultados anteriores
echo "🧹 Limpiando resultados anteriores..."
rm -rf cypress/videos/* cypress/screenshots/*

# Ejecutar Cypress en modo headless
echo "🚀 Ejecutando pruebas de Cypress..."
npx cypress run --headless --browser chrome

# Guardar el código de salida
EXIT_CODE=$?

# Mostrar resultados
echo "========================================="
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ TODAS LAS PRUEBAS PASARON"
else
    echo "❌ ALGUNAS PRUEBAS FALLARON"
    echo "📹 Revisa los videos en: cypress/videos/"
    echo "📸 Revisa las capturas en: cypress/screenshots/"
fi

echo "========================================="

exit $EXIT_CODE