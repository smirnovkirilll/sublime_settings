#!/usr/bin/env bash
set -euo pipefail


require_cmd() {
  command -v "$1" >/dev/null 2>&1
}


as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}


ensure_sublime_command() {
  # adds `sublime` command to PATH
  if require_cmd sublime; then
    echo "Command 'sublime' already exists: $(command -v sublime)"
    return 0
  fi

  local target=""

  if require_cmd subl; then
    target="$(command -v subl)"
  elif require_cmd sublime_text; then
    target="$(command -v sublime_text)"
  elif [ -x /opt/sublime_text/sublime_text ]; then
    target="/opt/sublime_text/sublime_text"
  elif [ "$(uname -s)" = "Darwin" ] && [ -x "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ]; then
    target="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
  fi

  if [ -z "$target" ]; then
    echo "Could not find Sublime CLI target (subl/sublime_text or known locations)."
    echo "You can create the symlink manually once you know the binary path."
    return 1
  fi

  # /usr/local/bin usually in PATH (both: Linux & macOS)
  as_root mkdir -p /usr/local/bin
  as_root ln -sf "$target" /usr/local/bin/sublime

  echo "Created: /usr/local/bin/sublime -> $target"
  echo "Now you can run: sublime"
}


install_macos() {
  echo "Detected macOS"

  if ! require_cmd curl; then
    echo "curl not found. On macOS it's usually provided by Xcode Command Line Tools. Try: xcode-select --install"
    exit 1
  fi

  if ! require_cmd brew; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to current shell (for Apple Silicon/Intel)
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  echo "Installing Sublime Text via Homebrew..."
  brew install --cask sublime-text
  ensure_sublime_command
  echo "Done."
}


install_linux_apt() {
  echo "Detected Debian/Ubuntu (apt)"
  as_root apt-get update
  as_root apt-get install -y wget gpg apt-transport-https ca-certificates

  wget -qO- https://download.sublimetext.com/sublimehq-pub.gpg \
    | gpg --dearmor \
    | as_root tee /usr/share/keyrings/sublimehq-archive-keyring.gpg >/dev/null

  echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" \
    | as_root tee /etc/apt/sources.list.d/sublime-text.list >/dev/null

  as_root apt-get update
  as_root apt-get install -y sublime-text

  ensure_sublime_command
  echo "Done."
}


install_linux_dnf() {
  echo "Detected Fedora/RHEL (dnf)"
  as_root rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
  as_root dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
  as_root dnf install -y sublime-text

  ensure_sublime_command
  echo "Done."
}


install_linux_pacman() {
  echo "Detected Arch (pacman)"
  as_root pacman -Sy --noconfirm sublime-text || {
    echo "Package 'sublime-text' may not be available in your enabled repos."
    echo "You can install via AUR (e.g. 'yay -S sublime-text') if you use an AUR helper."
    exit 1
  }

  ensure_sublime_command
  echo "Done."
}


install_linux_zypper() {
  echo "Detected openSUSE (zypper)"
  as_root rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
  as_root zypper addrepo -f https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
  as_root zypper --non-interactive refresh
  as_root zypper --non-interactive install sublime-text

  ensure_sublime_command
  echo "Done."
}


main() {
  os="$(uname -s)"

  case "$os" in
    Darwin)
      install_macos
      ;;
    Linux)
      if require_cmd apt-get; then
        install_linux_apt
      elif require_cmd dnf; then
        install_linux_dnf
      elif require_cmd pacman; then
        install_linux_pacman
      elif require_cmd zypper; then
        install_linux_zypper
      else
        echo "Unsupported Linux distro: no apt-get/dnf/pacman/zypper found."
        exit 1
      fi
      ;;
    *)
      echo "Unsupported OS: $os"
      exit 1
      ;;
  esac
}


main "$@"
