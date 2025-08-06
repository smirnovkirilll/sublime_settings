#!/usr/bin/env sh
# warning: script should be used after installing package control
# (otherwise it will not install other packages defined in "Package Control.sublime-settings")
# way to execute:
# wget -O - https://raw.githubusercontent.com/smirnovkirilll/sublime_settings/main/download_settings.sh | bash && rm download_settings.sh


DIR_SRC="https://raw.githubusercontent.com/smirnovkirilll/sublime_settings/main/"
DIR_TGT_OSX="${HOME}/Library/Application\ Support/Sublime\ Text/Packages/User/"
DIR_TGT_LINUX="${HOME}/.config/sublime-text/Packages/User/"
SETTINGS_TO_COPY=(
  "Anaconda.sublime-settings"
  "Default (Linux).sublime-mousemap"
  "Default (OSX).sublime-mousemap"
  "MarkdownPreview.sublime-settings"
  "Package Control.sublime-settings"
  "PlainTasks.sublime-settings"
  "Preferences.sublime-settings" )

# 1. choose target dir
# shellcheck disable=sc3010
if [[ -d $DIR_TGT_OSX ]]; then
  dir_tgt=$DIR_TGT_OSX
else
  dir_tgt=DIR_TGT_LINUX
fi

# 2. download
# shellcheck disable=sc3054
for setting in "${SETTINGS_TO_COPY[@]}"; do
  # download (convert spaces to "%20" in urls)
  # shellcheck disable=sc3060
  curl "${DIR_SRC}${setting// /%20}" -o "${dir_tgt}${setting}"
done

echo "sublime settings downloaded to system specific config directory"
