{
  config,
  lib,
  pkgs,
  ...
}: let
  fetchKeys = username: (builtins.fetchurl {
    url = "https://github.com/${username}.keys";
    sha256 = "1i2c67n69j15ini9k91cx0qi3gb3czpxwnrikij4vhvn7xkplqhj";
  });
in {
  imports = [
    ../common
    ./hardware-configuration.nix
    ./paperless.nix
    ./caddy.nix
    ./postgresql.nix
    ./netdata.nix
    ./microbin.nix
    ./speedtest.nix
    ./steam-inventory-value.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = "nixhost";
  networking.firewall.enable = false;
  time.timeZone = "Europe/Helsinki";

  users = {
    users = {
      root.openssh.authorizedKeys.keyFiles = [(fetchKeys "tmyllymaki")];
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding yes
      AllowAgentForwarding yes
      AllowStreamLocalForwarding yes
      AuthenticationMethods publickey
      AcceptEnv NIX_LD NIX_LD_LIBRARY_PATH
    '';
  };

  users.mutableUsers = false;
  security.sudo.execWheelOnly = true;

  environment.defaultPackages = lib.mkForce [];
  environment.systemPackages = with pkgs; [
    vim
    git
    podman-compose
    rsync
  ];

  nix.settings.allowed-users = ["root"];

  # Make vscode remote ssh work
  programs.nix-ld.enable = true;
  environment.etc."vscode-ssh-support".source = pkgs.stdenv.mkDerivation {
    name = "vscode-ssh-support";
    phases = ["installPhase"];
    installPhase = ''
      set -e
      mkdir -p $out
      for lib in ${pkgs.glibc}/lib/ld-linux* ${pkgs.stdenv.cc.cc.lib}/lib/*; do
        ln -sf $lib $out/$(basename $lib)
      done
    '';
  };

  virtualisation = {
    docker = {
      enable = true;
      rootless.enable = true;
      daemon.settings = {
        data-root = "/srv/docker";
      };
    };
  };
}
