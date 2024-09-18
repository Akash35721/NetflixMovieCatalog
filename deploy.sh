#!/bin/bash

# Update and upgrade the system
sudo apt update -y
sudo apt upgrade -y

# Install required dependencies (assuming Python and pip are already installed)
sudo apt install -y python3-pip python3-venv git

# Navigate to the home directory and clone the repository if it doesn't exist
cd ~
if [ -d "NetflixMovieCatalog" ]; then
  # If the directory exists, pull the latest changes
  cd NetflixMovieCatalog
  git reset --hard  # Remove local changes that prevent pull
  git pull
else
  # Clone the repository if it doesn't exist
  git clone https://github.com/Akash35721/NetflixMovieCatalog.git
  cd NetflixMovieCatalog
fi

# Set up a virtual environment if not already present
if [ ! -d "venv" ]; then
  python3 -m venv venv
fi

# Activate the virtual environment
source venv/bin/activate

# Install dependencies, using --break-system-packages to avoid PEP 668 errors
pip install --upgrade pip
pip install --break-system-packages -r requirements.txt

# Deactivate the virtual environment
deactivate

# Create a systemd service file for the Netflix Movie Catalog app
sudo bash -c 'cat <<EOF > /etc/systemd/system/netflixcatalog.service
[Unit]
Description=Netflix Movie Catalog Service
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/NetflixMovieCatalog
ExecStart=/home/ubuntu/NetflixMovieCatalog/.venv/bin/python3 /home/ubuntu/NetflixMovieCatalog/app.py
Restart=always
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF'

# Reload systemd and restart the service
sudo systemctl daemon-reload
sudo systemctl start netflixcatalog.service
sudo systemctl enable netflixcatalog.service

# Output the status of the service
sudo systemctl status netflixcatalog.service
