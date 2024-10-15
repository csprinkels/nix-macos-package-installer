For personal workstation = Make sure name is sprinkel
For work workstation = Make sure name is christiansprinkel

1. Install NixOS
```
sh <(curl -L https://nixos.org/nix/install)
```

2. Download code and put into a folder ~/nix

3. Rename flake-*name*.nix to just flake.nix

4. Install NixOS Darwin, Make sure you use the correct config name ( #main or #worklaptop )
```
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#*name of config*
```
