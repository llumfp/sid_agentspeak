#!/bin/bash

# Project and environment paths
PROJECT_DIR="~/sid_agentspeak"
AGENTS_DIR="${PROJECT_DIR}/cool-agents"
VENV_PATH="${PROJECT_DIR}/venv/bin/activate"
CONFIG_FILE="${AGENTS_DIR}/ejemplo.json"

# Manager JID settings
MANAGER_JID=${MANAGER_JID:-"{MANAGER_NAME}"}
SERVICE_JID=${SERVICE_JID:-"{SERVICE_NAME}"}
NUM_PLAYERS=${NUM_PLAYERS:-6}

if [ -f pygomas_stats.txt ]; then
    rm pygomas_stats.txt
fi

echo "Starting PyGOMAS Manager..."
osascript -e 'tell application "Terminal" to do script "cd '"${PROJECT_DIR}"' && source '"${VENV_PATH}"'  && pygomas manager -j '"${MANAGER_JID}"' -sj '"${SERVICE_JID}"' -np '"${NUM_PLAYERS}"'; exec bash"' &
sleep 5

echo "Starting PyGOMAS Render..."
osascript -e 'tell application "Terminal" to do script "cd '"${PROJECT_DIR}"' && source '"${VENV_PATH}"' && pygomas render; exec bash"' &
sleep 1

echo "Starting PyGOMAS Agents..."
osascript -e 'tell application "Terminal" to do script "cd '"${AGENTS_DIR}"' && source '"${VENV_PATH}"' && pygomas run -g '"${CONFIG_FILE}"'; exec bash"' &

echo "PyGOMAS running. May the best flag-grabber win! 🚩"
