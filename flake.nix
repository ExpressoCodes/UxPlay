{
  description = "UxPlay NixOS module - AirPlay receiver configuration";

  outputs = { self }: {
    nixosModules.default = import ./uxplay.nix;
  };
}
