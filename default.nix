let
  pkgs = import ./package-lock.nix;
in with pkgs;
[
  # the base environment
  bash
  coreutils
  curl
  fswatch
  git
  gnumake
  lua # just something to drop into on the command line to play
  libarchive # bsdtar allows stripping top level dir from zips
  rsync
]
