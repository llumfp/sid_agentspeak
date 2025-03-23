#!/bin/bash

MANAGER_JID=${MANAGER_JID:-"cmanager-gia@sidfib.mooo.com"}
SERVICE_JID=${SERVICE_JID:-"cservice-gia@sidfib.mooo.com"}
NUM_PLAYERS=${NUM_PLAYERS:-6}
AGENTS_DIR=${AGENTS_DIR:-"./sid_agentspeak"}
CONFIG_FILE=${CONFIG_FILE:-"./agents-oscar/config.json"}

echo "Iniciando PyGOMAS Manager..."
gnome-terminal -- bash -c "pygomas manager -j $MANAGER_JID -sj $SERVICE_JID -np $NUM_PLAYERS; exec bash" &

sleep 3

echo "Iniciando PyGOMAS Render..."
gnome-terminal -- bash -c "pygomas render; exec bash" &

sleep 1

echo "Iniciando agentes PyGOMAS..."
gnome-terminal -- bash -c "cd $AGENTS_DIR && pygomas run -g $CONFIG_FILE; exec bash" &

echo "PyGOMAS en ejecución. Cierra las terminales manualmente cuando hayas terminado."
