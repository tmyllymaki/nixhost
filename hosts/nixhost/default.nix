{ config, lib, pkgs, ... }:

let
  fetchKeys = username:
    (builtins.fetchurl {
      url = "https://github.com/${username}.keys";
      sha256 = "0d228c4vzbx4s6jp5si9c1zqcjmncs0qqjc7hl6s6mfk9nilkkx6";
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
  ];

  nixpkgs.config.allowUnfree = true;


  networking.hostName = "nix";
  networking.firewall.enable = false;
  time.timeZone = "Europe/Helsinki";

  users.users.root.openssh.authorizedKeys.keyFiles = [ (fetchKeys "tmyllymaki") ];

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

  environment.defaultPackages = lib.mkForce [ ];
  environment.systemPackages = with pkgs; [ 
    vim
  ];

  nix.settings.allowed-users = [ "root" ];

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

/* 
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    dataDir = "/srv/paperless/data";
    mediaDir = "/srv/paperless/media";
    settings = {
      PAPERLESS_OCR_LANGUAGE = "fin+eng";
      PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
      PAPERLESS_ADMIN_PASSWORD = "admin";
    };
  }; */

}
