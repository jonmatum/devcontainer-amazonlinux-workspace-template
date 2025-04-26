# DevContainer Amazon Linux Workspace Template

A modern, opinionated, and extensible Dev Container template built for cloud, full-stack, DevOps, and infrastructure developers — now based on Amazon Linux 2023.  
Easily reproducible, portable, and ready for work in seconds.

## Features

This template includes support for:

- Amazon Linux 2023 base image
- Shell environment with:
  - Zsh, Oh My Zsh, Powerlevel10k
  - Syntax highlighting and autosuggestions
- AWS CLI v2
- Terraform + tfswitch
- Node.js (default: 20.11.1) via nvm
- Python 3.11.9 via pyenv with pipenv support
- OpenTofu CLI (open-source Terraform alternative)
- Pre-commit hooks with optional global configuration
- Modular features — customize and toggle each feature as needed

## Installed Tools

- `terraform`, `aws`, `node`, `npm`, `python`, `pip`, `pipenv`, `tofu`, `pre-commit`, `zsh`, `git`, `curl`, `unzip`, `bash-completion`

## VS Code Extensions

Curated and recommended extensions:

- Cloud & Infrastructure: `hashicorp.terraform`, `amazonwebservices.aws-toolkit-vscode`, `redhat.vscode-yaml`
- Python: `ms-python.python`, `ms-python.vscode-pylance`, `ms-toolsai.jupyter`
- Node/Web Development: `dbaeumer.vscode-eslint`, `esbenp.prettier-vscode`, `bradlc.vscode-tailwindcss`
- Shell: `timonwong.shellcheck`, `foxundermoon.shell-format`
- Containers: `ms-azuretools.vscode-docker`
- Git/Collaboration: `eamodio.gitlens`, `ms-vsliveshare.vsliveshare`, `github.vscode-github-actions`
- Markdown & Docs: `bierner.markdown-mermaid`, `streetsidesoftware.code-spell-checker`
- Remote Development: `ms-vscode-remote.remote-containers`, `ms-vscode-remote.remote-ssh`
- General Enhancements: `visualstudioexptteam.vscodeintellicode`, `naumovs.color-highlight`

## Getting Started

1. Clone this template:
   ```bash
   gh repo create my-devcontainer --template jonmatum/devcontainer-amazonlinux-workspace-template
   ```

2. Open in Visual Studio Code:
   - Open the project folder
   - Use **Dev Containers: Reopen in Container** from the Command Palette

3. Begin developing with a fully configured environment.

## Customization

You can modify `.devcontainer/devcontainer.json` to:

- Enable or disable specific features
- Set specific tool versions
- Add or customize VS Code extensions
- Change workspace folder paths

Feature options are fully documented within each feature's directory under `./features/`.

## Architecture Overview

- Each tool (Python, Node.js, AWS CLI, Terraform, OpenTofu, etc.) is installed via its own modular, reusable Feature.
- Full support for ARM64 and x86_64 platforms.
- Designed to match production cloud environments closely, using Amazon Linux 2023.

## License

This project is licensed under the [MIT License](LICENSE).

---

> echo 'Pura Vida & Happy Coding!";

