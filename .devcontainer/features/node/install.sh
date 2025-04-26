#!/bin/bash
set -euo pipefail

USERNAME="${_REMOTE_USER:-vscode}"
NODE_VERSION="${VERSION:-lts/*}"
NVM_VERSION="v0.40.3"
NVM_DIR="/home/$USERNAME/.nvm"

echo "Installing nvm $NVM_VERSION for user $USERNAME and Node.js $NODE_VERSION..."

# Install system dependencies
sudo dnf update -y
sudo dnf install -y curl ca-certificates git

# Ensure nvm directory and permissions
mkdir -p "$NVM_DIR"
chown -R "$USERNAME":"$USERNAME" "$NVM_DIR"

# Install nvm if not already installed
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "Installing nvm..."
  sudo -u "$USERNAME" bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | PROFILE=/dev/null bash"
else
  echo "nvm already installed at $NVM_DIR, skipping install."
fi

# Install Node.js using nvm
sudo -u "$USERNAME" bash <<EOF
export NVM_DIR="$NVM_DIR"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"
nvm install "$NODE_VERSION"
nvm alias default "$NODE_VERSION"
nvm use default
EOF

# Symlink node and npm binaries to /usr/local/bin
NODE_BIN_PATH="$(sudo -u "$USERNAME" bash -c "export NVM_DIR=$NVM_DIR && source \$NVM_DIR/nvm.sh && nvm which $NODE_VERSION")"

if [ -x "$NODE_BIN_PATH" ]; then
  ln -sf "$NODE_BIN_PATH" /usr/local/bin/node
  ln -sf "$(dirname "$NODE_BIN_PATH")/npm" /usr/local/bin/npm
  ln -sf "$(dirname "$NODE_BIN_PATH")/npx" /usr/local/bin/npx
else
  echo "Error: Node.js binary not found at expected path: $NODE_BIN_PATH"
  exit 1
fi

# Ensure nvm is available in all future shells
if ! grep -q 'NVM_DIR' "/home/$USERNAME/.bashrc"; then
  echo 'export NVM_DIR="$HOME/.nvm"' >>"/home/$USERNAME/.bashrc"
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>"/home/$USERNAME/.bashrc"
fi

# Final verification
echo "Verifying Node.js installation:"
/usr/local/bin/node -v
/usr/local/bin/npm -v