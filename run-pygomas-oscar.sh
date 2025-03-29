#!/bin/bash

MANAGER_JID=${MANAGER_JID:-"cmanager-gia@sidfib.mooo.com"}
SERVICE_JID=${SERVICE_JID:-"cservice-gia@sidfib.mooo.com"}
NUM_PLAYERS=${NUM_PLAYERS:-6}
AGENTS_DIR=${AGENTS_DIR:-"/home/oscar/sid/sid_agentspeak/agents-oscar"}
CONFIG_FILE=${CONFIG_FILE:-"/home/oscar/sid/sid_agentspeak/agents-oscar/config.json"}

if [ -f pygomas_stats.txt ]; then
    rm pygomas_stats.txt
fi

rm -rf ~/.cache/qtshadercache-x86_64-little_endian-lp64
rm -rf ~/.cache/matplotlib
rm -rf ~/.cache/pip
rm -rf ~/.cache/mesa_shader_cache
rm -rf ~/.cache/mesa_shader_cache_db
rm -rf ~/.cache/fontconfig

echo "Iniciando PyGOMAS Manager..."
gnome-terminal -- bash -ic "pyenv activate sid; pygomas manager -j $MANAGER_JID -sj $SERVICE_JID -np $NUM_PLAYERS -m map_04 --fps 60; exec bash" &

sleep 5

echo "Iniciando PyGOMAS Render..."
gnome-terminal -- bash -ic "pyenv activate sid; pygomas render ; exec bash" &

sleep 1

echo "Iniciando agentes PyGOMAS..."
gnome-terminal -- bash -ic "pyenv activate sid; cd $AGENTS_DIR && pygomas run -g $CONFIG_FILE; exec bash" &

echo "PyGOMAS en ejecución. Cierra las terminales manualmente cuando hayas terminado."

exit