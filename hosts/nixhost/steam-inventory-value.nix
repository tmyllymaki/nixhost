{outputs, ...}: {
  imports = [outputs.nixosModules.steam-inventory-value];

  services.steamInventoryValue = {
    enable = true;
  };
}
