#!/bin/bash
set -e

# Check for python3-venv
if ! command -v python3 -m venv >/dev/null 2>&1; then
    echo "Error: python3-venv is not installed. Run 'sudo apt install python3-venv python3-full'"
    exit 1
fi

# Create and activate virtual environment
if [ ! -d "venv" ]; then
    python3 -m venv ansible_deps/venv
fi
source ansible_deps/venv/bin/activate

# Verify pip is from the virtual environment
if ! pip --version | grep -q "venv"; then
    echo "Error: pip is not using the virtual environment"
    exit 1
fi

# Install Python packages
if [ -f "ansible_deps/requirements.txt" ] && [ -d "ansible_deps/python_packages" ]; then
    pip install --no-index --find-links=ansible_deps/python_packages -r ansible_deps/requirements.txt
else
    echo "Error: requirements.txt or python_packages directory is missing"
    exit 1
fi

# Install Ansible collections
if ls ansible_deps/collections/*.tar.gz >/dev/null 2>&1; then
    ansible-galaxy collection install ansible_deps/collections/*.tar.gz -p ~/.ansible/collections
else
    echo "Error: No collection tarballs found in ansible_deps/collections"
    exit 1
fi

# # Deactivate virtual environment
# deactivate