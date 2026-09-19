{ config, pkgs, lib, ... }:

let
  uxplayTray = pkgs.writeShellApplication {
    name = "uxplay-tray";
    runtimeInputs = [ pkgs.uxplay pkgs.yad ];
    text = ''
      uxplay -p &
      UXPLAY_PID=$!

      yad --notification \
          --image="${./Airplay.png}" \
          --text="UxPlay - AirPlay Receiver" \
          --menu="Quit UxPlay!kill $UXPLAY_PID"

      kill "$UXPLAY_PID" 2>/dev/null
    '';
  };

  uxplayDesktop = pkgs.makeDesktopItem {
    name = "uxplay";
    desktopName = "UxPlay";
    exec = "uxplay-tray";
    icon = "uxplay";
    terminal = false;
  };

  uxplayIcon = pkgs.runCommand "uxplay-icon" {} ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${./Airplay.png} $out/share/icons/hicolor/256x256/apps/uxplay.png
  '';
in
{
  networking.firewall.allowedTCPPorts = [ 7000 7001 7100 ];
  networking.firewall.allowedUDPPorts = [ 5353 6000 6001 7011 ];

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

  environment.systemPackages = [
    uxplayTray
    uxplayDesktop
    uxplayIcon
  ];
}
