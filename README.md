# Control-Powercord
Powershell script that controls the Powercord Discord-CLI

## Installation
Save the file anywhere, change the `$PowershellInstallationFolder` variable to the root of you Powercord installation, then add it's folder path to your path variable to make full use of it.

## Usage
```
() is optional
[] is choice separated by /
{} is your input
```
### Update
Updates Powercord itself, but only Powercord
```
Control-Powercord update
```

### Update All
Updates Powercord, as well as all plugins and themes in their respective folders.
```
Control-Powercord update-all
```

### Plugging/Unpluging
Plugs or unplugs Powercord
```
Control-Powercord (un)plug
```

### Adding Plugins/Themes
Adds a plugin or theme to it's respective folder
```
Control-Powercord add [plugin/theme] {url}
```

## Troubleshooting
---
Although it should give sensible errors, if you are very stuck, send me a message on discord at Sparib#0913
