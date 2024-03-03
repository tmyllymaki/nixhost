{config, ...}: {
  services.microbin = {
    enable = true;
    dataDir = "/srv/microbin";
    passwordFile = config.sops.secrets.microbin.path;
    settings = {
      MICROBIN_PORT = 9345;
      MICROBIN_ENABLE_BURN_AFTER = true;
      MICROBIN_QR = true;
      MICROBIN_PUBLIC_PATH = "https://sp.myllymaki.dev";
      MICROBIN_EDITABLE = true;
      MICROBIN_NO_LISTING = true;
      MICROBIN_READONLY = true;
    };
  };

  services.caddy.virtualHosts."sp.myllymaki.dev:80".extraConfig = ''
    reverse_proxy http://127.0.0.1:9345
  '';

  users = {
    users.microbin = {
      isSystemUser = true;
      group = "microbin";
    };
    groups.microbin = {};
  };

  sops.secrets.microbin = {
    sopsFile = ./secrets.yaml;
  };
}
