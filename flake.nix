{
  description = "NixOS module for UxPlay — AirPlay Unix mirroring server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosModules.uxplay = { config, pkgs, lib, ... }: {
      options.services.uxplay = {
        enable = lib.mkEnableOption "UxPlay AirPlay mirroring server";

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Open firewall ports required by UxPlay.";
        };
      };

      config = lib.mkIf config.services.uxplay.enable {
        environment.systemPackages = [ pkgs.uxplay ];

        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true;
          publish = {
            enable = true;
            addresses = true;
            workstation = true;
            userServices = true;
            domain = true;
          };
        };

        networking.firewall = lib.mkIf config.services.uxplay.openFirewall {
          allowedTCPPorts = [ 7000 7001 7100 ];
          allowedUDPPorts = [ 5353 6000 6001 7011 ];
        };
      };
    };

    nixosModules.default = self.nixosModules.uxplay;
  };
}
