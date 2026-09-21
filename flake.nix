{
  description = "NixOS module for UxPlay — AirPlay Unix mirroring server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosModules.uxplay = { config, pkgs, lib, ... }:
    let
      uxplayIcon = pkgs.runCommand "uxplay-icon" {} ''
        mkdir -p $out/share/icons/hicolor/scalable/apps
        cp ${./uxplay.svg} $out/share/icons/hicolor/scalable/apps/uxplay.svg
        cp ${./uxplay.svg} $out/share/icons/hicolor/scalable/apps/uxplay-indicator.svg
      '';

      uxplayTray = pkgs.stdenv.mkDerivation {
        name = "uxplay-tray";
        src = ./.;
        nativeBuildInputs = [ pkgs.pkg-config pkgs.makeWrapper ];
        buildInputs = [ pkgs.gtk3 pkgs.libayatana-appindicator ];
        buildPhase = ''
          cc uxplay-tray.c -o uxplay-tray \
            $(pkg-config --cflags --libs gtk+-3.0 ayatana-appindicator3-0.1)
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp uxplay-tray $out/bin/
          wrapProgram $out/bin/uxplay-tray \
            --prefix PATH : ${lib.makeBinPath [ pkgs.uxplay ]} \
            --set UXPLAY_ICON_THEME_PATH ${uxplayIcon}/share/icons/hicolor
        '';
      };

      uxplayDesktop = pkgs.makeDesktopItem {
        name = "uxplay";
        desktopName = "UxPlay";
        exec = "uxplay-tray";
        icon = "uxplay";
        terminal = false;
        comment = "AirPlay mirroring server — streams from iPhone/iPad/Mac";
        categories = [ "Utility" "Network" ];
      };
    in
    {
      options.services.uxplay = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable UxPlay AirPlay mirroring server. Defaults to true so that importing the module activates it.";
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Open firewall ports required by UxPlay (TCP 7000 7001 7100, UDP 5353 6000 6001 7011).";
        };
      };

      config = lib.mkIf config.services.uxplay.enable {
        environment.systemPackages = [ pkgs.uxplay uxplayTray uxplayIcon uxplayDesktop ];

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
