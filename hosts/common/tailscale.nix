{
  config,
  pkgs,
  outputs,
  ...
}: {
  imports = [outputs.nixosModules.tailscale-autoconnect];

  services.tailscaleAutoconnect = {
    enable = true;
  };

  environment.persistence = {
    "/nix/persist".directories = ["/var/lib/tailscale"];
  };
}