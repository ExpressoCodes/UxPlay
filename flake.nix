{
  description = "UxPlay NixOS module - AirPlay receiver configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: {
    nixosModules.default = import ./uxplay.nix;
  };
}
