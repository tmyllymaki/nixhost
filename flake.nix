{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    impermanence.url = "github:nix-community/impermanence";
    hardware.url = "github:nixos/nixos-hardware";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # what will be produced (i.e. the build)
  outputs = {
    self,
    nixpkgs,
    devenv,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs ["x86_64-linux"];
    forEachPkgs = f: forEachSystem (sys: f nixpkgs.legacyPackages.${sys});

    mkNixos = host: system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit (self) inputs outputs;};
        modules = [
          ./hosts/${host}
        ];
      };
    # mkHome = host: system:
    #   home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.${system};
    #     extraSpecialArgs = {inherit (self) inputs outputs;};
    #     modules = [
    #       ./home/tm/${host}.nix
    #     ];
    #   };
  in {
    formatter = forEachPkgs (pkgs: pkgs.alejandra);

    #packages = forEachPkgs (pkgs: import ./pkgs {inherit pkgs;});

    nixosModules = import ./modules/nixos;
    #homeManagerModules = import ./modules/home-manager;

    #overlays = import ./overlays {inherit inputs;};

    devShells = forEachPkgs (pkgs: import ./shell.nix {inherit pkgs devenv inputs;});

    nixosConfigurations = {
      nixhost = mkNixos "nixhost" "x86_64-linux";
    };

    # homeConfigurations = {
    #   "edgar@horus" = mkHome "horus" "aarch64-linux";
    #   "edgar@hestia" = mkHome "hestia" "x86_64-linux";
    #   "edgar@deimos" = mkHome "deimos" "x86_64-linux";
    # };
  };
}
