{modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  users.users.root.initialPassword = "tm";

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["defaults" "size=2G" "mode=755" "noexec"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "ext4";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nix";
    autoResize = true;
    fsType = "ext4";
  };
  #  security.auditd.enable = true;
  #  security.audit.enable = true;
  #  security.audit.rules = [
  #    "-a exit,always -F arch=b64 -S execve"
  #  ];

  #  fileSystems."/etc/nixos".options = [ "noexec" ];
  #  fileSystems."/srv".options = [ "noexec" ];
  #  fileSystems."/var/log".options = [ "noexec" ];

  boot.tmp.cleanOnBoot = true;
}
