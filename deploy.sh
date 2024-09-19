#!/bin/bash

# Log everything to a file
LOG_FILE=~/NetflixMovieCatalog/deploy.log
exec > >(tee -a $LOG_FILE) 2>&1

echo "Starting deployment at $(date)"

# Check if Python service is running on port 8080 and kill if needed
PORT=8080
if lsof -i :$PORT; then
  echo "Port $PORT is in use. Attempting to kill processes on port $PORT..."
  sudo fuser -k ${PORT}/tcp
  echo "Port $PORT cleared."
else
  echo "Port $PORT is free."
fi

# Activate virtual environment and install dependencies
echo "Activating virtual environment..."
source ~/NetflixMovieCatalog/.venv/bin/activate

echo "Installing dependencies..."
pip install -r ~/NetflixMovieCatalog/requirements.txt

# Restart the service
echo "Restarting Netflix catalog service..."
sudo systemctl daemon-reload
sudo systemctl restart netflixcatalog.service

# Check if the service is running
if systemctl is-active --quiet netflixcatalog.service; then
  echo "Netflix catalog service restarted successfully."
else
  echo "Failed to restart Netflix catalog service."
  exit 1
fi

echo "Deployment finished at $(date)"
