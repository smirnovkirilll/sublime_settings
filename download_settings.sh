#!/usr/bin/env bash
set -euo pipefail


# ---- Config ----
DIR_SRC_DEFAULT="https://raw.githubusercontent.com/smirnovkirilll/sublime_settings/main/src/"
# Optional override:
#   DIR_SRC="https://raw.githubusercontent.com/.../src/"
DIR_SRC="${DIR_SRC:-$DIR_SRC_DEFAULT}"


SETTINGS_TO_COPY=(
  "Default (Linux).sublime-keymap"
  "Default (Linux).sublime-mousemap"
  "Default (OSX).sublime-mousemap"
  "MarkdownPreview.sublime-settings"
  "Package Control.sublime-settings"
  "PlainTasks.sublime-settings"
  "Preferences.sublime-settings"
)


# ---- Helpers ----
require_cmd() { command -v "$1" >/dev/null 2>&1; }


die() { echo "error: $*" >&2; exit 1; }


detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      echo "unknown" ;;
  esac
}


url_escape_spaces() {
  # Only spaces considered as special and will be translated
  local s="$1"
  printf '%s' "${s// /%20}"
}


ensure_downloader() {
  if require_cmd curl; then
    echo "curl"
    return 0
  fi
  if require_cmd wget; then
    echo "wget"
    return 0
  fi
  die "curl or wget is required"
}


# SublimeText-4 user dir:
# macOS:  ~/Library/Application Support/Sublime Text/Packages/User
sublime_user_dir_macos() {
  printf '%s' "${HOME}/Library/Application Support/Sublime Text/Packages/User/"
}


# Linux:  ~/.config/sublime-text/Packages/User  (or $XDG_CONFIG_HOME/sublime-text/Packages/User)
sublime_user_dir_linux() {
  local base="${XDG_CONFIG_HOME:-$HOME/.config}"
  printf '%s' "${base}/sublime-text/Packages/User/"
}


get_target_dir() {
  local os
  os="$(detect_os)"
  case "$os" in
    macos) sublime_user_dir_macos ;;
    linux) sublime_user_dir_linux ;;
    *) die "unsupported OS: $(uname -s)" ;;
  esac
}


download_file() {
  local downloader="$1"
  local url="$2"
  local out="$3"

  case "$downloader" in
    curl) curl -fsSL "$url" -o "$out" ;;
    wget) wget -qO "$out" "$url" ;;
    *) die "unknown downloader: $downloader" ;;
  esac
}


download_settings() {
  local downloader="$1"
  local dir_tgt="$2"

  mkdir -p "$dir_tgt"

  local failures=0
  local setting url out

  for setting in "${SETTINGS_TO_COPY[@]}"; do
    url="${DIR_SRC}$(url_escape_spaces "$setting")"
    out="${dir_tgt}${setting}"

    echo "downloading: ${setting} -> ${out}"
    if ! download_file "$downloader" "$url" "$out"; then
      echo "failed to download: ${setting}" >&2
      failures=$((failures + 1))
    fi
  done

  if [ "$failures" -ne 0 ]; then
    die "completed with ${failures} download failure(s)"
  fi
}


main() {
  local downloader dir_tgt
  downloader="$(ensure_downloader)"
  dir_tgt="$(get_target_dir)"

  echo "OS: $(detect_os)"
  echo "Source: ${DIR_SRC}"
  echo "Target: ${dir_tgt}"

  download_settings "$downloader" "$dir_tgt"
  echo "Sublime Text settings downloaded successfully."
}


main "$@"
