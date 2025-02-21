{
  description = "Cisco Packet Tracer 7";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      ptFiles = pkgs.stdenv.mkDerivation {
        name = "PacketTracer7drv";
        version = "7.3.1";
        dontUnpack = true;
        src = pkgs.fetchurl {
          url = "http://kafpi.local/PacketTracer_731_amd64.deb";
          hash = "sha256-w5gC0V3WHQC6J/uMEW2kX9hWKrS0mZZVWtZriN6s4n8=";
        };
        nativeBuildInputs = with pkgs; [ dpkg makeWrapper ];
        installPhase = ''
          dpkg-deb -x $src $out
          makeWrapper "$out/opt/pt/bin/PacketTracer7" "$out/bin/packettracer7" --prefix LD_LIBRARY_PATH : "$out/opt/pt/bin"
        '';
      };
      ptFhsEnv = pkgs.buildFHSEnv {
        name = "packettracer7";
        runScript = "${ptFiles}/bin/packettracer7";

        targetPkgs = pkgs:
          with pkgs; [
            alsa-lib
            dbus
            expat
            fontconfig
            glib
            libglvnd
            libpulseaudio
            libudev0-shim
            libxkbcommon
            libxml2
            libxslt
            nspr
            nss
            xorg.libICE
            xorg.libSM
            xorg.libX11
            xorg.libXScrnSaver
          ];
      };

      packettracer7 = pkgs.stdenv.mkDerivation {
        pname = "ciscoPacketTracer7";
        version = "7.3.1";
        dontUnpack = true;
        installPhase = ''
          mkdir $out
          ${pkgs.xorg.lndir}/bin/lndir -silent ${ptFhsEnv} $out
        '';
        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "cisco-pt7.desktop";
            desktopName = "Cisco Packet Tracer 7";
            icon = "${ptFiles}/opt/pt/art/app.png";
            exec = "packettracer7 %f";
            mimeTypes =
              [ "application/x-pkt" "application/x-pka" "application/x-pkz" ];
          })
        ];
        nativeBuildInputs = [ pkgs.xorg.lndir ];
      };
    in { packages.x86_64-linux.default = packettracer7; };
}
