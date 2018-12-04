with import <nixpkgs> { config.allowUnfree = true; };
let
  composer2nix = import (fetchTarball https://api.github.com/repos/svanderburg/composer2nix/tarball/8453940d79a45ab3e11f36720b878554fe31489f) {};
  custom = import (fetchGit {
    url = "https://github.com/ariutta/nixpkgs-custom.git";
    rev = "76b4e3d420f440aa8998fb9d0e8fda92a1d85d9f";
    ref = "master";
  }) {};
  pathvisio = callPackage custom.pathvisio {
    organism="Homo sapiens";
    headless=true;
    genes=false;
    interactions=false;
    metabolites=false;
    # NOTE: this seems high, but I got an error
    #       regarding memory when it was lower.
    memory="2048m";
  };
in [
  pkgs.apacheHttpd
  pkgs.php
  php72Packages.composer
  pkgs.mysql
  pkgs.solr

  pkgs.coreutils

  pathvisio
] ++ (if stdenv.isDarwin then [] else [])
