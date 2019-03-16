{ pkgs ? import <nixpkgs> {} }:

let
  dynamic-linker = pkgs.stdenv.cc.bintools.dynamicLinker;

  patchelf = libPath :
    if pkgs.stdenv.isDarwin
      then ""
      else
        ''
          chmod u+w $PURS
          patchelf --interpreter ${dynamic-linker} --set-rpath ${libPath} $PURS
          chmod u-w $PURS
        '';

in pkgs.stdenv.mkDerivation rec {
  name = "purs-simple";
  version = "v0.12.2";

  src =
    if pkgs.stdenv.isDarwin
      then pkgs.fetchurl
        { url = "https://github.com/purerl/purescript/releases/download/v0.12.3-erl2/macos.tar.gz";
          sha256 =  "1clzwjdprd3q8l6b035bq89llabnq1h4qpn9mdgyn7fbpnzwv59f";
        }
      else pkgs.fetchurl
        { url = "https://github.com/purerl/purescript/releases/download/v0.12.3-erl2/linux64.tar.gz";
          sha256 =  "08k9irlm3l8sx9mq9a7vmrvmqjpnk5yypjn1cz2wccsv7486bhl8";
        };


  buildInputs = [ pkgs.zlib
                  pkgs.gmp
                  pkgs.ncurses5];
  libPath = pkgs.lib.makeLibraryPath buildInputs;
  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    PURS="$out/bin/purs"

    install -D -m555 -T purs $PURS
    ${patchelf libPath}

    mkdir -p $out/etc/bash_completion.d/
    $PURS --bash-completion-script $PURS > $out/etc/bash_completion.d/purs-completion.bash
  '';
}
