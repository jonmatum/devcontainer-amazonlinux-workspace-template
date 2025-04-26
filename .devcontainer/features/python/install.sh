#!/bin/bash
set -euo pipefail

USERNAME="${_REMOTE_USER:-vscode}"
PYTHON_VERSION="${VERSION:-3.11.9}"
INSTALL_PIPENV="${PIPENV:-true}"
PYENV_ROOT="/home/${USERNAME}/.pyenv"
PROFILE_PATH="/home/${USERNAME}/.bashrc"
PYTHON_BIN="${PYENV_ROOT}/versions/${PYTHON_VERSION}/bin"

echo "Installing Python $PYTHON_VERSION for user $USERNAME..."

# === Helper: Install system dependencies ===
install_dependencies() {
  echo "Installing system packages..."
  sudo dnf update -y
  sudo dnf groupinstall -y "Development Tools"
  sudo dnf install -y \
    gcc gcc-c++ make \
    zlib-devel bzip2 bzip2-devel \
    readline-devel sqlite-devel \
    openssl-devel xz-devel libffi-devel \
    wget curl git tar xz \
    findutils
}

# === Helper: Install pyenv ===
install_pyenv() {
  if [ ! -d "$PYENV_ROOT" ]; then
    echo "Installing pyenv..."
    sudo -u "$USERNAME" git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
  fi

  if ! grep -q 'pyenv init' "$PROFILE_PATH"; then
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >>"$PROFILE_PATH"
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >>"$PROFILE_PATH"
    echo 'eval "$(pyenv init --path)"' >>"$PROFILE_PATH"
    echo 'eval "$(pyenv init -)"' >>"$PROFILE_PATH"
  fi
}

# === Helper: Install specific Python version ===
install_python_version() {
  if ! sudo -u "$USERNAME" bash -c "PYENV_ROOT=$PYENV_ROOT PATH=\$PYENV_ROOT/bin:\$PATH pyenv versions --bare | grep -qx \"$PYTHON_VERSION\""; then
    echo "Installing Python version $PYTHON_VERSION..."
    sudo -u "$USERNAME" bash -c "PYENV_ROOT=$PYENV_ROOT PATH=\$PYENV_ROOT/bin:\$PATH pyenv install $PYTHON_VERSION"
  fi
  sudo -u "$USERNAME" bash -c "PYENV_ROOT=$PYENV_ROOT PATH=\$PYENV_ROOT/bin:\$PATH pyenv global $PYTHON_VERSION"
}

# === Helper: Create symlinks for Python and pip ===
symlink_python() {
  echo "Linking Python and pip to /usr/local/bin..."
  ln -sf "$PYTHON_BIN/python" /usr/local/bin/python
  ln -sf "$PYTHON_BIN/pip" /usr/local/bin/pip
}

# === Helper: Install pipenv ===
install_pipenv() {
  echo "Installing pipenv using pyenv-managed Python..."
  sudo -u "$USERNAME" bash <<EOF
export PYENV_ROOT="$PYENV_ROOT"
export PATH="\$PYENV_ROOT/bin:\$PYENV_ROOT/versions/$PYTHON_VERSION/bin:\$PATH"
eval "\$(pyenv init --path)"
eval "\$(pyenv init -)"
hash -r
python -m pip install --user pipenv
EOF

  if ! grep -q '.local/bin' "/home/$USERNAME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"/home/$USERNAME/.bashrc"
  fi
}

# === Ensure ~/.local/bin is in PATH ===
ensure_local_bin_in_path() {
  echo "Ensuring ~/.local/bin is in the PATH for $USERNAME..."

  # Add to .bashrc if missing
  if ! grep -q '.local/bin' "/home/$USERNAME/.bashrc"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"/home/$USERNAME/.bashrc"
  fi

  # Add to .profile if missing
  if [ -f "/home/$USERNAME/.profile" ] && ! grep -q '.local/bin' "/home/$USERNAME/.profile"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >>"/home/$USERNAME/.profile"
  fi

  # (Optional extra safe) Global profile.d script
  if [ ! -f "/etc/profile.d/user-local-bin.sh" ]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' | sudo tee /etc/profile.d/user-local-bin.sh >/dev/null
    sudo chmod +x /etc/profile.d/user-local-bin.sh
  fi
}

# === Main install flow ===

install_dependencies
install_pyenv
install_python_version
symlink_python

if [[ "$INSTALL_PIPENV" == "true" ]]; then
  install_pipenv
  ensure_local_bin_in_path
fi

# === Confirm installation ===
echo "Installed Python version:"
/usr/local/bin/python --version
/usr/local/bin/pip --version

if [[ "$INSTALL_PIPENV" == "true" ]]; then
  echo "Installed pipenv version:"
  sudo -u "$USERNAME" bash -c "PATH=\$HOME/.local/bin:\$PATH pipenv --version" || echo "Warning: pipenv installation check failed."
fi