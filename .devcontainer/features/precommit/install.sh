#!/bin/bash
set -e

USERNAME="${_REMOTE_USER:-vscode}"
INSTALL_GLOBAL="${GLOBAL:-true}"

echo "Installing pre-commit for user: $USERNAME..."

# Ensure Python and pip are available
if ! command -v python3 >/dev/null 2>&1; then
    echo "Installing Python (python3 and pip3)..."
    sudo dnf update -y
    sudo dnf install -y python3 python3-pip
fi

if ! command -v pip3 >/dev/null 2>&1; then
    echo "Installing pip3..."
    sudo dnf install -y python3-pip
fi

# Check if pre-commit is already installed
if sudo -u "$USERNAME" command -v pre-commit >/dev/null 2>&1; then
    echo "pre-commit is already installed. Skipping installation."
else
    echo "Installing pre-commit..."
    if [[ "$INSTALL_GLOBAL" == "true" ]]; then
        sudo -u "$USERNAME" pip3 install --user pre-commit
    else
        sudo -u "$USERNAME" pip3 install pre-commit
    fi
fi

# Symlink to /usr/local/bin if installed with --user and not in PATH
if [[ "$INSTALL_GLOBAL" == "true" ]]; then
    USER_BIN="/home/$USERNAME/.local/bin"
    PRECOMMIT_BIN="$USER_BIN/pre-commit"
    if [ -f "$PRECOMMIT_BIN" ] && [ ! -f "/usr/local/bin/pre-commit" ]; then
        echo "Linking pre-commit to /usr/local/bin"
        ln -sf "$PRECOMMIT_BIN" /usr/local/bin/pre-commit
    fi
fi

# Final check
echo "Verifying pre-commit installation:"
sudo -u "$USERNAME" pre-commit --version || echo "Warning: pre-commit installation check failed."