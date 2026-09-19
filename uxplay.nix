{ config, pkgs, lib, ... }:

let
  uxplayDesktop = pkgs.makeDesktopItem {
    name = "uxplay";
    desktopName = "UxPlay";
    exec = "uxplay -p";
    icon = "uxplay";
    terminal = false;
  };

  uxplayIcon = pkgs.runCommand "uxplay-icon" {} ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${./Airplay.png} $out/share/icons/hicolor/256x256/apps/uxplay.png
  '';
in
{
  # Open network ports
  networking.firewall.allowedTCPPorts = [ 7000 7001 7100 ];
  networking.firewall.allowedUDPPorts = [ 5353 6000 6001 7011 ];

  # To enable network-discovery
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

  environment.systemPackages = with pkgs; [
    uxplay
    uxplayDesktop
    uxplayIcon
  ];
}
