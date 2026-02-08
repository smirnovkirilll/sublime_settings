#!/usr/bin/env sh
set -euo pipefail


DIR_SRC="https://raw.githubusercontent.com/smirnovkirilll/sublime_settings/src/main/"
DIR_TGT_OSX="${HOME}/Library/Application\ Support/Sublime\ Text/Packages/User/"
DIR_TGT_LINUX="${HOME}/.config/sublime-text/Packages/User/"
SETTINGS_TO_COPY=(
  "Anaconda.sublime-settings"
  "Default (Linux).sublime-keymap"
  "Default (Linux).sublime-mousemap"
  "Default (OSX).sublime-mousemap"
  "MarkdownPreview.sublime-settings"
  "Package Control.sublime-settings"
  "PlainTasks.sublime-settings"
  "Preferences.sublime-settings"
)

# 1. ensure curl exists
command -v curl >/dev/null 2>&1 || {
  echo "error: curl is required" >&2
  exit 1
}

# 2. pick target directory
# shellcheck disable=sc3010
if [[ -d $DIR_TGT_OSX ]]; then
  dir_tgt=$DIR_TGT_OSX
else
  dir_tgt=DIR_TGT_LINUX
fi

# 3. ensure target dir exists
mkdir -p "${dir_tgt}"

# 4. download settings
# shellcheck disable=sc3054
for setting in "${SETTINGS_TO_COPY[@]}"; do
  # download (convert spaces to "%20" in urls)
  # shellcheck disable=sc3060
  echo "downloading ${setting} -> ${dir_tgt}"
  if ! curl -fsSL "${DIR_SRC}${setting// /%20}" -o "${dir_tgt}${setting}"; then
    echo "failed to download ${setting}" >&2
  fi
done

echo "sublime settings downloaded to system specific config directory"
