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


# Package Control binary package (for manual installation)
PACKAGE_CONTROL_URL="https://packagecontrol.io/Package%20Control.sublime-package"
PACKAGE_CONTROL_FILENAME="Package Control.sublime-package"


# ---- Helpers ----
require_cmd() { command -v "$1" >/dev/null 2>&1; }


die() { echo "error: $*" >&2; exit 1; }


detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      die "unsupported OS: $(uname -s)" ;;
  esac
}


downloader() {
  if require_cmd curl; then echo "curl"; return 0; fi
  if require_cmd wget; then echo "wget"; return 0; fi
  die "curl or wget is required"
}


download_file() {
  local tool="$1" url="$2" out="$3"
  case "$tool" in
    curl) curl -fsSL "$url" -o "$out" ;;
    wget) wget -qO "$out" "$url" ;;
    *) die "unknown downloader: $tool" ;;
  esac
}


url_escape_spaces() {
  # Only spaces considered as special and will be translated
  local s="$1"
  printf '%s' "${s// /%20}"
}


# ---- Sublime Text 4 paths ----
st4_user_dir_macos() {
  printf '%s' "${HOME}/Library/Application Support/Sublime Text/Packages/User/"
}


st4_installed_packages_dir_macos() {
  printf '%s' "${HOME}/Library/Application Support/Sublime Text/Installed Packages/"
}


st4_user_dir_linux() {
  local base="${XDG_CONFIG_HOME:-$HOME/.config}"
  printf '%s' "${base}/sublime-text/Packages/User/"
}


st4_installed_packages_dir_linux() {
  local base="${XDG_CONFIG_HOME:-$HOME/.config}"
  printf '%s' "${base}/sublime-text/Installed Packages/"
}


get_user_dir() {
  case "$(detect_os)" in
    macos) st4_user_dir_macos ;;
    linux) st4_user_dir_linux ;;
  esac
}


get_installed_packages_dir() {
  case "$(detect_os)" in
    macos) st4_installed_packages_dir_macos ;;
    linux) st4_installed_packages_dir_linux ;;
  esac
}


# ---- Actions ----
install_package_control() {
  local tool="$1"
  local dir out

  dir="$(get_installed_packages_dir)"
  mkdir -p "$dir"

  out="${dir}${PACKAGE_CONTROL_FILENAME}"

  echo "Installing Package Control -> $out"
  download_file "$tool" "$PACKAGE_CONTROL_URL" "$out"
}


download_settings() {
  local tool="$1"
  local dir_tgt setting url out
  local failures=0

  dir_tgt="$(get_user_dir)"
  mkdir -p "$dir_tgt"

  for setting in "${SETTINGS_TO_COPY[@]}"; do
    url="${DIR_SRC}$(url_escape_spaces "$setting")"
    out="${dir_tgt}${setting}"

    echo "Downloading ${setting} -> ${out}"
    if ! download_file "$tool" "$url" "$out"; then
      echo "failed to download: ${setting}" >&2
      failures=$((failures + 1))
    fi
  done

  if [ "$failures" -ne 0 ]; then
    die "completed with ${failures} download failure(s)"
  fi
}


main() {
  local tool
  tool="$(downloader)"

  echo "OS: $(detect_os)"
  echo "Settings source: ${DIR_SRC}"
  echo "User dir: $(get_user_dir)"
  echo "Installed Packages dir: $(get_installed_packages_dir)"

  install_package_control "$tool"
  download_settings "$tool"

  echo "Done. If Sublime Text is running, restart it to load Package Control/settings."
}

main "$@"
