#!/bin/bash

# Variables específicas para JAVI22
MANAGER_JID="cmanager-javi@JAVI22.mshome.net"
SERVICE_JID="cservice-javi@JAVI22.mshome.net"
NUM_PLAYERS=6
AGENTS_DIR="."
CONFIG_FILE="ejemplo_local.json"

# Comprobar sistema operativo para abrir terminales
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux con gnome-terminal
    TERMINAL_CMD="gnome-terminal --"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    TERMINAL_CMD="osascript -e 'tell app \"Terminal\" to do script'"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows con Git Bash o similar
    TERMINAL_CMD="start cmd //k"
else
    # Fallback
    echo "Sistema operativo no detectado correctamente, usando comando genérico"
    TERMINAL_CMD="xterm -e"
fi

# Iniciar el manager en una terminal
echo "Iniciando PyGOMAS Manager..."
$TERMINAL_CMD "pygomas manager -j $MANAGER_JID -sj $SERVICE_JID -np $NUM_PLAYERS" &

# Esperar a que el manager esté completamente iniciado
echo "Esperando 5 segundos para inicialización del manager..."
sleep 5

# Iniciar el render en otra terminal
echo "Iniciando PyGOMAS Render..."
$TERMINAL_CMD "pygomas render" &

# Esperar un poco más
sleep 2

# Iniciar los agentes en una tercera terminal
echo "Iniciando agentes PyGOMAS..."
$TERMINAL_CMD "cd $AGENTS_DIR && pygomas run -g $CONFIG_FILE" &

echo "PyGOMAS en ejecución. Cierra las terminales manualmente cuando hayas terminado."
