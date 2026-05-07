#!/bin/bash
set -e

echo "Updating system packages..."
sudo apt-get update -y

echo "Installing Nginx..."
sudo apt-get install -y nginx

echo "Starting and enabling Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Creating a simple landing page..."
echo "<h1>Welcome to the Hub-Spoke Jenkins Demo</h1>" | sudo tee /var/www/html/index.html

echo "Nginx installation completed successfully."
