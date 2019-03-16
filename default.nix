let
  pkgs = import <nixpkgs> {};

  inputs = rec {
    purs = import ./purs.nix { inherit pkgs; };
    purescript = purs;
    spago = import ./spago.nix { inherit pkgs; };
  };

  buildInputs = builtins.attrValues inputs;
in inputs // {
  inputs = inputs;

  buildInputs = buildInputs;

}
