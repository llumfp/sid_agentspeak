@echo off
setlocal

:: Variables específicas para USER
set "MANAGER_JID={MANAGER_NAME}"
set "SERVICE_JID={SERVICE_NAME}"
set "NUM_PLAYERS=6"
set "AGENTS_DIR=../cool-agents"
set "CONFIG_FILE=../cool-agents/ejemplo.json"

:: Iniciar el manager en una nueva ventana de cmd
echo Iniciando PyGOMAS Manager...
start cmd /k "pygomas manager -j %MANAGER_JID% -sj %SERVICE_JID% -np %NUM_PLAYERS% --fps 120" 
:: -m mine Para tener un mini mapa

:: Esperar 5 segundos para inicialización del manager
timeout /t 5 /nobreak >nul

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
