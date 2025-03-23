#!/bin/bash

# Usar variables pasadas por la terminal o establecer valores por defecto
MANAGER_JID=${MANAGER_JID:-"cmanager@localhost"}
SERVICE_JID=${SERVICE_JID:-"cservice@localhost"}
NUM_PLAYERS=${NUM_PLAYERS:-6}
AGENTS_DIR=${AGENTS_DIR:-"./sid_agentspeak"}
CONFIG_FILE=${CONFIG_FILE:-"ejemplo.json"}

# Iniciar el manager en una terminal
echo "Iniciando PyGOMAS Manager..."
gnome-terminal -- bash -c "pygomas manager -j $MANAGER_JID -sj $SERVICE_JID -np $NUM_PLAYERS; exec bash" &

# Esperar a que el manager esté completamente iniciado
sleep 5

# Iniciar el render en otra terminal
echo "Iniciando PyGOMAS Render..."
gnome-terminal -- bash -c "pygomas render; exec bash" &

# Esperar un poco más
sleep 2

# Iniciar los agentes en una tercera terminal
echo "Iniciando agentes PyGOMAS..."
gnome-terminal -- bash -c "cd $AGENTS_DIR && pygomas run -g $CONFIG_FILE; exec bash" &

echo "PyGOMAS en ejecución. Cierra las terminales manualmente cuando hayas terminado."
