{ pkgs ? import <nixpkgs> {} }:
let

  patchelf = libPath :
    if pkgs.stdenv.isDarwin
      then ""
      else
        ''
          chmod u+w $SPAGO
          patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath ${libPath} $SPAGO
          chmod u-w $SPAGO
        '';
in

  pkgs.stdenv.mkDerivation rec {
    name = "spago";
    version = "0.7.0.0";

    src =
      if pkgs.stdenv.isDarwin
        then pkgs.fetchurl
              { url = "https://github.com/spacchetti/spago/releases/download/0.7.0.0/osx.tar.gz";
                sha256 =  "10kb92ylk92hfgjzjvj5rvynmfdd2bmrs6bax4a7q2k513zfb2sp";
              }
        else pkgs.fetchurl
              { url = "https://github.com/spacchetti/spago/releases/download/0.6.0.0/linux.tar.gz";
                sha256 =  "13jdki193pif3w6lrzizil8s8az3gs9bg0jzx98ar5sy9d8iikrm";
              };

    buildInputs = [
      pkgs.gmp
      pkgs.zlib
      pkgs.ncurses5
    ];
    libPath = pkgs.lib.makeLibraryPath buildInputs;
    dontStrip = true;

    unpackPhase = ''
      mkdir -p $out/bin
      tar xf $src -C $out/bin

      SPAGO=$out/bin/spago
      ${patchelf libPath}


      mkdir -p $out/etc/bash_completion.d/
      $SPAGO --bash-completion-script $SPAGO > $out/etc/bash_completion.d/spago-completion.bash
    '';

    dontInstall = true;
  }
