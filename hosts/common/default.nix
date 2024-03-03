# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./sops.nix
    ./impermanence.nix
    ./tailscale.nix
    ./nix.nix
  ];
  
  system.activationScripts.diff = ''
    if [[ -e /run/current-system ]]; then
      echo "NixOS system closure diff:"
      ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig"
    fi
  '';
}