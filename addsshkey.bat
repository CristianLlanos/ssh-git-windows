::
:: addsshkey.cmd
::
:: Cristian A. Llanos Malca <cristianllanos@outlook.com>
::
:: Automatiza el proceso de creación de llaves SSH,
:: actualiza el archivo config de la carpeta %userprofile%\.ssh,
:: agrega la llave privada al sistema y abre la
:: llave pública, lista para ser copiada.
::

@ECHO off
SETLOCAL
TITLE Crear llaves SSH
COLOR 0A

:: define las variables de autenticación
SET /p nombre_llave=Nombre de la llave: 
SET /p passphrase=Passphare (mas de 4 caracteres): 
SET /p comentario=Comentario (tu email): 
SET /p host=Host remoto (github.com) || SET host=github.com
SET /p host_alias=Alias del host remoto (github.com): || SET host_alias=github.com
:: SET nombre_llave=cristiankey
:: SET passphrase=anything
:: SET comentario=cristianllanos@outlook.com
:: SET host_alias=github.com

:: define la ubicación de los archivos
SET directorio_ssh=%USERPROFILE%\.ssh
SET archivo_key=%directorio_ssh%\%nombre_llave%
SET archivo_config=%directorio_ssh%\config

:: actualiza el archivo config para el alias
ECHO Host %host_alias%>>%archivo_config%
ECHO     HostName %host%>>%archivo_config%
ECHO     User git>>%archivo_config%
ECHO     IdentityFile %archivo_key%>>%archivo_config%

:: genera las llaves
ssh-keygen -t rsa -C "%comentario%" -f %archivo_key% -N %passphrase%

:: guarda los datos del ssh-agent
ssh-agent -s>ssh-agent-info.txt
:: procesa y obtiene las variables de entorno para ssh-add
python -c "f = open('ssh-agent-info.txt','r');e = open('ssh-agent.bat','w');line = f.readline();e.write('SET SSH_AUTH_SOCK=' + line[line.find('=')+1:line.find(';')]+'\n');line = f.readline();e.write('SET SSH_AGENT_PID=' + line[line.find('=')+1:line.find(';')]);"
call ssh-agent.bat
ECHO AUTH SOCK: %SSH_AUTH_SOCK%
ECHO AGENT PID: %SSH_AGENT_PID%

:: agrega la llave privada a la configuración ssh
ssh-add %archivo_key%

:: abre la llave pública para que pueda ser copiada y utilizada
notepad %archivo_key%.pub

:: limpia los residuros del proceso
DEL ssh-agent-info.txt
DEL ssh-agent.bat
