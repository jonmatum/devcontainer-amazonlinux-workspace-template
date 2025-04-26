#!/bin/bash
set -e

USERNAME="${_REMOTE_USER:-vscode}"
TERRAFORM_VERSION="${VERSION:-1.6.5}"
TFSWITCH_BIN="/home/$USERNAME/bin"
TF_BIN="$TFSWITCH_BIN/terraform"

echo "Installing Terraform using tfswitch (version: $TERRAFORM_VERSION)..."

# Install dependencies
echo "Installing dependencies (curl, unzip, gnupg)..."
sudo dnf install -y curl unzip gnupg shadow-utils sudo || true

# Install tfswitch if not already installed
if ! command -v tfswitch >/dev/null 2>&1; then
    echo "Installing tfswitch..."
    curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/master/install.sh | bash
fi

# Prepare the user bin directory
mkdir -p "$TFSWITCH_BIN"
chown -R "$USERNAME:$USERNAME" "$TFSWITCH_BIN"

# Use .tfswitchrc if available, otherwise install specific version
if [ -f "/workspaces/.tfswitchrc" ]; then
    echo "Found .tfswitchrc, using specified version inside it..."
    su - "$USERNAME" -c "cd /workspaces && PATH=\$PATH:$TFSWITCH_BIN tfswitch"
else
    echo "No .tfswitchrc found, installing version $TERRAFORM_VERSION..."
    su - "$USERNAME" -c "cd /workspaces && PATH=\$PATH:$TFSWITCH_BIN tfswitch $TERRAFORM_VERSION"
fi

# Symlink terraform to /usr/local/bin
if [ -f "$TF_BIN" ]; then
    echo "Linking Terraform binary to /usr/local/bin..."
    cp "$TF_BIN" /usr/local/bin/terraform
    chmod +x /usr/local/bin/terraform
else
    echo "Error: Terraform binary not found at expected path: $TF_BIN"
    exit 1
fi

# Final verification
echo "Terraform installation complete:"
terraform --version