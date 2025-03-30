#!/bin/bash

# Manager JID settings
MANAGER_JID=${MANAGER_JID:-"{MANAGER_NAME}"}
SERVICE_JID=${SERVICE_JID:-"{SERVICE_NAME}"}
NUM_PLAYERS=${NUM_PLAYERS:-6}

PROJECT_DIR="~/sid_agentspeak"
AGENTS_DIR="${PROJECT_DIR}/cool-agents"
VENV_PATH="${PROJECT_DIR}/venv/bin/activate"
CONFIG_FILE="${AGENTS_DIR}/ejemplo.json"

if [ -f pygomas_stats.txt ]; then
    rm pygomas_stats.txt
fi

echo "Iniciando PyGOMAS Manager..."
gnome-terminal -- bash -ic "pyenv activate sid; pygomas manager -j $MANAGER_JID -sj $SERVICE_JID -np $NUM_PLAYERS -m map_01 --fps 10; exec bash" &

sleep 7.5

echo "Iniciando PyGOMAS Render..."
gnome-terminal -- bash -ic "pyenv activate sid; pygomas render ; exec bash" &

sleep 2

echo "Iniciando agentes PyGOMAS..."
gnome-terminal -- bash -ic "pyenv activate sid; cd $AGENTS_DIR && pygomas run -g $CONFIG_FILE; exec bash" &

echo "PyGOMAS en ejecución. Cierra las terminales manualmente cuando hayas terminado."

exit