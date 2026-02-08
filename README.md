script to setup [sublime text](https://www.sublimetext.com/) and its plugins, implementing MattDMo [proposal given on SO](https://stackoverflow.com/questions/19529999/add-package-control-in-sublime-text-3-through-the-command-line).

1. install sublime (linux-based system)
```bash
sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo dnf config-manager --add-repo https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo dnf install sublime-text
sudo ln -s /opt/sublime_text/sublime_text /usr/bin/sublime
mkdir -p ~/.config/sublime-text/Packages/User
```

2. install package control manually, otherwise further script will not apply packages defined in `Package Control.sublime-settings` (at least I did not find way how to make it work).

3. use script (fits Linux and MacOs):
```bash
curl -fsSL https://raw.githubusercontent.com/smirnovkirilll/sublime_settings/main/download_settings.sh | bash
```
