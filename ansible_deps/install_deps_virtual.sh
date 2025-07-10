#!/bin/bash
set -e

# Check for python3-venv
if ! command -v python3 -m venv >/dev/null 2>&1; then
    echo "Error: python3-venv is not installed. Run 'sudo apt install python3-venv python3-full'"
    exit 1
fi

# Create and activate virtual environment
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate

# Verify pip is from the virtual environment
if ! pip --version | grep -q "venv"; then
    echo "Error: pip is not using the virtual environment"
    exit 1
fi

# Install Python packages
if [ -f "requirements.txt" ] && [ -d "python_packages" ]; then
    pip install --no-index --find-links=./python_packages -r requirements.txt
else
    echo "Error: requirements.txt or python_packages directory is missing"
    exit 1
fi

# Install Ansible collections
if ls ./collections/*.tar.gz >/dev/null 2>&1; then
    ansible-galaxy collection install ./collections/*.tar.gz -p ~/.ansible/collections
else
    echo "Error: No collection tarballs found in ./collections"
    exit 1
fi

# # Ensure binaries are executable
# if [ -d "./bin" ] && ls ./bin/* >/dev/null 2>&1; then
#     chmod +x ./bin/*
# else
#     echo "Warning: No binaries found in ./bin"
# fi

source venv/bin/activate

# # Deactivate virtual environment
# deactivate