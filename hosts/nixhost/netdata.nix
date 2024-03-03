{
  services.netdata = {
    enable = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      {
        directory = "/var/lib/netdata";
        user = "netdata";
        group = "netdata";
        mode = "0755";
      }
    ];
  };
}
