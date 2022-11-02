let
  pkgs = import ./package-lock.nix;
in with pkgs;
stdenv.mkDerivation {
  name = "Neuron-env";
  buildInputs = import ./default.nix;
}
