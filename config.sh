#!/bin/bash
set -e  # Detiene el script si ocurre un error

# === CONFIGURACIÓN ===
APP_DIR="/home/ubuntu/fastapi_app"
REPO_URL="https://github.com/CardozoEIA/PracticaSO.git"   # <-- cámbialo
SERVICE_NAME="fastapi"
PYTHON_VERSION="python3"
PORT=8000

echo " Iniciando configuración del entorno para FastAPI..."

# === Actualizar sistema ===
sudo apt update && sudo apt upgrade -y
sudo apt install -y git $PYTHON_VERSION $PYTHON_VERSION-venv

# === Clonar o actualizar el repositorio ===
if [ ! -d "$APP_DIR" ]; then
  echo " Clonando repositorio..."
  git clone $REPO_URL $APP_DIR
else
  echo " Actualizando repositorio existente..."
  cd $APP_DIR
  git pull
fi

# === Crear entorno virtual ===
cd $APP_DIR
if [ ! -d "venv" ]; then
  echo " Creando entorno virtual"
  $PYTHON_VERSION -m venv venv
fi

# === Instalar dependencias ===
source venv/bin/activate
echo "Instalando dependencias desde requirements.txt"
pip install --upgrade pip
pip install -r requirements.txt
deactivate

# === Crear servicio systemd ===
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "Creando servicio systemd en $SERVICE_FILE ..."
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=FastAPI Service
After=network.target

[Service]
User=ubuntu
Group=ubuntu
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port $PORT
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

# === Activar servicio ===
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "Servicio $SERVICE_NAME levantado correctamente."
