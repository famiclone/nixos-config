{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
  };

  outputs = { self, nixpkgs }: {
		nixosConfigurations = {
			brinstar = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					./configuration.nix
					./hardware-configuration.nix
				];
			};
		};
  };
}
