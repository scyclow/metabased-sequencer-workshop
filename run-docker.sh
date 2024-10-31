# Script to verify setup
#!/bin/bash
echo "Checking Docker installation..."
docker --version

echo "Checking setup..."
docker compose up -d
docker compose exec metabased-dev forge build

if [ $? -eq 0 ]; then
    echo "Setup successful! You're ready for the workshop!"
else
    echo "Setup failed. Please check the troubleshooting guide."
fi