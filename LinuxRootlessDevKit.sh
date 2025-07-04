#!/usr/bin/env bash
set -e

LinuxRootlessDevKit::install()
{
  if [[ "$1" == "bash" ]]; then
    ################### BASH ###################
    # Install Oh My Bash
    if [[ -f "${PROJECT_TOP_DIR}/src/bash/omb_install.sh" ]]; then
      source "${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      Omb::install || exit 1
    else
      echo "Error: Could not find omb_install.sh at ${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      exit 1
    fi
  elif [[ "$1" == "zsh" ]]; then
    ################### ZSH ###################
    # Install zsh
    bash ./src/zsh/zsh_install.sh
    export PATH="$HOME/.local/bin:$PATH"
    source "$HOME/.bashrc"
  else
    echo "Error: Unsupported shell '$1'. Use 'bash' or 'zsh'." >&2
    exit 1
  fi

  ### RUST ###
  # Source rust install file
  RUST_INSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/rust_install.sh"
  if [[ -f "${RUST_INSTALL_PATH}" ]]; then
      source "${RUST_INSTALL_PATH}"
  else
      echo "Error: Could not find rust_install.sh at ${RUST_INSTALL_PATH}"
      exit 1
  fi
  # Install rust with shell config file as an argument
  Rust::install "${SHELLRC_PATH}" || exit 1
  source "${SHELLRC_PATH}"

  ### RUST TOOLS ###
  # Source Rust Cli tools install file
  RUST_TOOLS_INSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/rust_install_cli_tools.sh"
  if [[ -f "${RUST_TOOLS_INSTALL_PATH}" ]]; then
      source "${RUST_TOOLS_INSTALL_PATH}"
  else
      echo "Error: Could not find rust_install_cli_tools.sh at ${RUST_TOOLS_INSTALL_PATH}"
      exit 1
  fi
  # Install all defined rust tools with shell config file as an argument
  Rust::Cli::install_all_tools "${SHELLRC_PATH}" || exit 1

  ### GO ###
  # Install Go
  bash ./src/golang/go_install.sh
}

LinuxRootlessDevKit::verify_installation()
{
  source "${SHELLRC_PATH}"
  source ~/.bashrc.user

  if [[ "$1" == "bash" ]]; then
    ################### BASH ###################
    # Verify Oh My Bash
    if [[ -f "${PROJECT_TOP_DIR}/src/bash/omb_install.sh" ]]; then
      source "${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      Omb::verify_installation || exit 1
    else
      echo "Error: Could not find omb_install.sh at ${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      exit 1
    fi
  elif [[ "$1" == "zsh" ]]; then
    ################### ZSH ###################
    # Verify installation
    if command -v zsh >/dev/null 2>&1; then
      zsh --version
      echo "✅ zsh successfully installed."
    else
      echo "❌ zsh not found after install."
      exit 1
    fi
  else
    echo "Error: Unsupported shell '$1'. Use 'bash' or 'zsh'." >&2
    exit 1
  fi

  ### RUST ###
  # Verify installation
  if command -v rustc >/dev/null 2>&1; then
    rustc --version
  else
    echo "❌ rustc not found after install."
    exit 1
  fi

  ### RUST TOOLS ###
  # Verify installation of rust tools
  Rust::Cli::verify_installed || exit 1

  ### GO ###
  # Verify Go installation
  if command -v go >/dev/null 2>&1; then
    go version
  else
    echo "❌ Go not found after install."
    exit 1
  fi
}

LinuxRootlessDevKit::uninstall()
{
  source "${SHELLRC_PATH}"
  source ~/.bashrc.user

  if [[ "$1" == "bash" ]]; then
    ################### BASH ###################
    # Remove Oh My Bash
    if [[ -f "${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh" ]]; then
      source "${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh"
      Omb::uninstall || exit 1
    else
      echo "Error: Could not find omb_uninstall.sh at ${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh"
      exit 1
    fi
  elif [[ "$1" == "zsh" ]]; then
    ################### ZSH ###################
    # Uninstall zsh
    bash ./src/zsh/zsh_uninstall.sh
    source "$HOME/.bashrc"
  else
    echo "Error: Unsupported shell '$1'. Use 'bash' or 'zsh'." >&2
    exit 1
  fi

  ### RUST TOOLS ###
  # Source Rust Cli tools uninstall file
  RUST_TOOLS_UNINSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/rust_uninstall_cli_tools.sh"
  if [[ -f "${RUST_TOOLS_UNINSTALL_PATH}" ]]; then
      source "${RUST_TOOLS_UNINSTALL_PATH}"
  else
      echo "Error: Could not find rust_uninstall_cli_tools.sh at ${RUST_TOOLS_UNINSTALL_PATH}"
      exit 1
  fi
  # Uninstall all defined rust tools with shell config file as an argument
  Rust::Cli::uninstall_all_tools "${SHELLRC_PATH}" || exit 1

  ### RUST ###
  # Source rust uninstall file
  RUST_UNINSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/rust_uninstall.sh"
  if [[ -f "${RUST_UNINSTALL_PATH}" ]]; then
      source "${RUST_UNINSTALL_PATH}"
  else
      echo "Error: Could not find rust_uninstall.sh at ${RUST_UNINSTALL_PATH}"
      exit 1
  fi
  # Uninstall Rust with shell config file as an argument
  Rust::uninstall "${SHELLRC_PATH}" || exit 1

  ### GO ###
  # Uninstall Go
  bash ./src/golang/go_uninstall.sh
}

LinuxRootlessDevKit::verify_uninstallation()
{
  source "${SHELLRC_PATH}"
  source ~/.bashrc.user

  if [[ "$1" == "bash" ]]; then
    ################### BASH ###################
    # Remove Oh My Bash
    if [[ -f "${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh" ]]; then
      source "${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh"
      Omb::verify_uninstallation || exit 1
    else
      echo "Error: Could not find omb_uninstall.sh at ${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh"
      exit 1
    fi
  elif [[ "$1" == "zsh" ]]; then
    ################### ZSH ###################
    # Verify uninstallation
    if [ ! -d "$HOME/.oh-my-zsh" ] && [ ! -d "$HOME/.local/bin/zsh" ]; then
      echo "✅ zsh successfully uninstalled."
    else
      echo "❌ zsh files still exist after uninstall."
      exit 1
    fi
  else
    echo "Error: Unsupported shell '$1'. Use 'bash' or 'zsh'." >&2
    exit 1
  fi

  ### RUST TOOLS ###
  # Verify uninstallation of rust tools
  Rust::Cli::verify_uninstalled || exit 1

  ### RUST ###
  # Verify Rust uninstallation
  if [ ! -d "$HOME/.cargo" ] && [ ! -d "$HOME/.rustup" ]; then
    echo "✅ Rust successfully uninstalled."
  else
    echo "❌ Rust files still exist after uninstall."
    exit 1
  fi

  ### GO ###
  # Verify Go uninstallation
  if [ ! -d "$HOME/go" ] && [ ! -d "$HOME/.local/go" ]; then
    echo "✅ Go successfully uninstalled."
  else
    echo "❌ Go files still exist after uninstall."
    exit 1
  fi
}