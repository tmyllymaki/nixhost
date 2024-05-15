{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.steamInventoryValue;
  steamInventoryValue = pkgs.callPackage ../../steam-inventory-value/app {};
in {
  options.services.steamInventoryValue = {
    enable = mkEnableOption "steamInventoryValue";
  };

  config = mkIf cfg.enable {
    systemd.services.steam-inventory-value = {
      description = "Steam Inventory Value Web Server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      environment = {
        DB_PATH = "/srv/steam-inventory-value/inventory.sqlite";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${steamInventoryValue}/bin/app.py";
        Restart = "always";
        WorkingDirectory = "/srv/steam-inventory-value/app"; # Specify your application's working directory
      };
    };

    services.caddy.virtualHosts."steam.myllymaki.dev:80".extraConfig = ''
      reverse_proxy http://127.0.0.1:5000
    '';

    systemd.services.steam-inventory-value-script = {
      description = "Steam Inventory Value Script";
      path = [pkgs.nix];
      script = "${../../steam-inventory-value/script.sh}";
      serviceConfig = {
        Type = "oneshot";
        WorkingDirectory = "/srv/steam-inventory-value";
      };
    };

    systemd.timers.steam-inventory-value-script = {
      description = "Timer for Steam Inventory Value Script";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "*-*-* 12:00:00";
        RandomizedDelaySec = "1800";
        Persistent = true;
      };
    };
  };
}
