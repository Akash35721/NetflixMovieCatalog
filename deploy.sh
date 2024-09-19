#!/bin/bash

# Ensure the correct working directory
cd ~/NetflixMovieCatalog || exit

# Check if virtual environment exists, if not create one
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
    echo "Virtual environment created."
fi

# Activate the virtual environment
source .venv/bin/activate

# Install dependencies from requirements.txt
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "requirements.txt not found. Installing Flask manually."
    pip install flask
fi

# Free port 8080 if in use
sudo fuser -k 8080/tcp

# Restart the systemd service
sudo systemctl daemon-reload
sudo systemctl restart netflixcatalog.service

# Check the status of the service
sudo systemctl status netflixcatalog.service
