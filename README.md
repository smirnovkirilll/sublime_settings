[![License](https://img.shields.io/github/license/smirnovkirilll/sublime_settings)](./LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/smirnovkirilll/sublime_settings?style=social)](https://github.com/smirnovkirilll/sublime_settings/stargazers)


> [!CAUTION]
> AI-created/vibe coded
>
> AI-model: ChatGPT 5.2
>
> AI-participation degree: 60%


Scripts to help install [Sublime Text](https://www.sublimetext.com) and set up its plugins, implementing MattDMo [proposal given on SO](https://stackoverflow.com/questions/19529999/add-package-control-in-sublime-text-3-through-the-command-line).


#### What it does
1. Installs brew (if needed, MacOS only) and Sublime Text.
2. Installs [Package Control](https://packagecontrol.io) and the [listed packages](src/Package%20Control.sublime-settings).
3. Customizes installed packages via [preferences](src).


#### Operation systems scripts intended to works with
```
MacOS
Debian/Ubuntu
Fedora/RHEL
Arch
openSUSE
```


#### Usage
```bash
curl -fsSL https://raw.githubusercontent.com/smirnovkirilll/sublime_settings/main/install_sublime.sh | bash
curl -fsSL https://raw.githubusercontent.com/smirnovkirilll/sublime_settings/main/install_packages.sh | bash
```


#### Customisation

You can provide another repo with packages and preferences via setting environment variable `DIR_SRC`.
