{ config, pkgs, lib, ... }:

let
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
  };

  uxplayIcon = pkgs.runCommand "uxplay-icon" {} ''
    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp ${./uxplay.svg} $out/share/icons/hicolor/scalable/apps/uxplay.svg
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
