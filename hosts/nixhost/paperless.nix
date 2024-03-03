{config, ...}: let
  # port = 53214;
  # virtualHost = "paperless.myllymaki.dev";
in {
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    dataDir = "/srv/paperless/data";
    mediaDir = "/srv/paperless/media";
    settings = {
      PAPERLESS_OCR_LANGUAGE = "fin+eng";
      PAPERLESS_OCR_USER_ARGS = ''
        {
          "invalidate_digital_signatures": true
        }
      '';

      PAPERLESS_DBENGINE = "postgresql";
      PAPERLESS_DBHOST = "/run/postgresql";
      PAPERLESS_DBPORT = "5432";
      PAPERLESS_DBNAME = "paperless";
      PAPERLESS_DBUSER = "paperless";
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      PAPERLESS_AUTO_LOGIN_USERNAME = "admin";
    };
    # passwordFile = config.sops.secrets.paperless.path;
    # consumptionDir = "/shared/edgar/documents/paperless";
    # consumptionDirIsPublic = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = config.services.paperless.dataDir;
        mode = "0750";
        user = "paperless";
        group = "paperless";
      }
    ];
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "paperless";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [
      "paperless"
    ];
  };
}
