#!/bin/bash

# Define variables
APP_DIR="/home/ubuntu/NetflixMovieCatalog"
REPO_URL="https://github.com/Akash35721/NetflixMovieCatalog.git"
BRANCH="main"
PORT=80
SERVICE_NAME="netflixcatalog"

# Ensure the system is up to date
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y python3-pip python3-venv git nginx

# Stop and disable existing service
sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME

# Remove existing service file if present
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
if [ -f "$SERVICE_FILE" ]; then
    sudo rm $SERVICE_FILE
fi

# Ensure no process is using the port
sudo fuser -k $PORT/tcp

# Clone or update the repository
if [ ! -d "$APP_DIR" ]; then
    sudo git clone $REPO_URL $APP_DIR
else
    cd $APP_DIR
    sudo git fetch --all
    sudo git checkout $BRANCH
    sudo git pull origin $BRANCH
fi

cd $APP_DIR

# Create and activate a Python virtual environment
if [ ! -d "$APP_DIR/.venv" ]; then
    sudo python3 -m venv .venv
fi

source .venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Configure Nginx
sudo cp $APP_DIR/nginx/netflixcatalog /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/netflixcatalog /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Configure the systemd service
echo "[Unit]
Description=Netflix Movie Catalog Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/.venv/bin/python3 $APP_DIR/app.py
Restart=always

[Install]
WantedBy=multi-user.target" | sudo tee $SERVICE_FILE

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "Deployment complete. The app is now running on http://$(curl -s ifconfig.me):$PORT"
