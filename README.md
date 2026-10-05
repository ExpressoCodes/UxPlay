# UxPlay

A NixOS flake module that packages [UxPlay](https://github.com/FDH2/UxPlay) — an
open-source AirPlay mirroring server — together with a small GTK system-tray
applet for starting and stopping it.

## What it does

Importing the module into your NixOS configuration:

- installs `uxplay` and a lightweight tray applet (`uxplay-tray`),
- adds a desktop entry ("UxPlay") so the tray applet shows up in your launcher,
- enables and configures Avahi (mDNS/Bonjour) so Apple devices can discover the
  server,
- optionally opens the firewall ports UxPlay needs
  (TCP 7000/7001/7100, UDP 5353/6000/6001/7011).

The tray applet (`uxplay-tray.c`, GTK 3 + libayatana-appindicator) launches
`uxplay` on start and provides a "Quit UxPlay" menu entry that stops the server.

## Usage

Add the flake as an input and import the module:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    uxplay.url = "github:ExpressoCodes/UxPlay";
  };

  outputs = { self, nixpkgs, uxplay, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        uxplay.nixosModules.default
      ];
    };
  };
}
```

Then rebuild:

```sh
sudo nixos-rebuild switch --flake .#myhost
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `services.uxplay.enable` | bool | `true` | Enable the UxPlay server and tray applet. |
| `services.uxplay.openFirewall` | bool | `true` | Open the TCP/UDP ports UxPlay requires. |

## License

The tray applet and Nix packaging in this repository are released under the
[MIT License](LICENSE). UxPlay itself is a separate upstream project with its
own license.
