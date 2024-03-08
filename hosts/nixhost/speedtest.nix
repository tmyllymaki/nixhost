{...}: let
  userId = 992;
  groupId = 991;
in {
  virtualisation.oci-containers.containers = {
    speedtest-test = {
      autoStart = true;
      image = "ghcr.io/alexjustesen/speedtest-tracker:latest";
      ports = [
        "8085:80"
      ];
      environment = {
        PUID = toString userId;
        PGID = toString groupId;
        POSTGRES_PASSWORD = "password";
        POSTGRES_USER = "postgres";
        POSTGRES_DB = "postgres";

        APP_NAME = "Speedtest Tracker";
        APP_ENV = "production";
        APP_KEY = "base64:1OGkNOZoZj0EUZjsP2TGig4ata8x1BsbFcTMKJH0tPY=";
        APP_DEBUG = "false";
        APP_URL = "http://localhost";
        FORCE_HTTPS = "false";

        LOG_CHANNEL = "stderr";
        LOG_DEPRECATIONS_CHANNEL = "null";
        LOG_LEVEL = "debug";

        DB_CONNECTION = "pgsql";
        DB_HOST = "/run/postgresql";
        DB_PORT = "5432";
        DB_DATABASE = "speedtest";
        DB_USERNAME = "speedtest";

        BROADCAST_DRIVER = "log";
        CACHE_DRIVER = "database";
        FILESYSTEM_DISK = "local";
        QUEUE_CONNECTION = "database";
        SESSION_DRIVER = "database";
        SESSION_LIFETIME = "120";
      };
      volumes = [
        "/srv/containers/speedtest/config:/config"
        "/run/postgresql:/run/postgresql"
      ];
    };
  };

  users = {
    users = {
      speedtest = {
        isSystemUser = true;
        group = "speedtest";
        uid = userId;
      };
    };

    groups.speedtest = {
      gid = groupId;
    };
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = "speedtest";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [
      "speedtest"
    ];
  };
}
