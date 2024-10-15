### HOW TO USE
---
1. Installing NixOS
```
sh <(curl -L https://nixos.org/nix/install)
```

2. Download code and put into a folder ~/nix

3. Rename to just flake.nix

4. Install NixOS Darwin, Make sure you use the correct config name ( #main or #worklaptop )
```
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#*name of config*
```
