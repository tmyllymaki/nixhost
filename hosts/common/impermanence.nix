{inputs, ...}: {
  imports = [
    inputs.impermanence.nixosModule
  ];
  # always persist these
  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
      "/var/lib/nixos"
      "/var/lib/containers"
      "/var/lib/systemd/coredump"
      "/var/log"
      "/srv"
      "/root/.ssh"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
