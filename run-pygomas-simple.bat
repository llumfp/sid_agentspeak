@echo off
setlocal

:: Variables específicas para JAVI22
set "MANAGER_JID=cmanager-javi@JAVI22.mshome.net"
set "SERVICE_JID=cservice-javi@JAVI22.mshome.net"
set "NUM_PLAYERS=4"
set "AGENTS_DIR=./cool-agents"
set "CONFIG_FILE=ejemplo_local.json"

:: Iniciar el manager en una nueva ventana de cmd
echo Iniciando PyGOMAS Manager...
start cmd /k "pygomas manager -j %MANAGER_JID% -sj %SERVICE_JID% -np %NUM_PLAYERS%"

:: Esperar 5 segundos para inicialización del manager
timeout /t 2 /nobreak >nul

:: Iniciar el render en otra ventana
echo Iniciando PyGOMAS Render...
start cmd /k "pygomas render"

:: Esperar 2 segundos adicionales
timeout /t 2 /nobreak >nul

:: Iniciar los agentes en una tercera ventana
echo Iniciando agentes PyGOMAS...
start cmd /k "cd /d %AGENTS_DIR% && pygomas run -g %CONFIG_FILE%"

echo PyGOMAS en ejecución. Cierra las terminales manualmente cuando hayas terminado.

endlocal
