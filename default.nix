with import <nixpkgs> { config.allowUnfree = true; };
let
  custom = import (fetchGit {
    url = "https://github.com/ariutta/nixpkgs-custom.git";
    rev = "76b4e3d420f440aa8998fb9d0e8fda92a1d85d9f";
    ref = "master";
  }) {};
# Do we need PathVisio-Java other than for GPMLConverter?
# Leaving this here in case we do, but it's commented out.
#  pathvisio = callPackage (custom.pathvisio {
#    organism="Homo sapiens";
#    headless=true;
#    genes=false;
#    interactions=false;
#    metabolites=false;
#    # NOTE: this seems high, but I got an error
#    #       regarding memory when it was lower.
#    memory="2048m";
#  });
in [
  # https://www.mediawiki.org/wiki/Manual:Installation_requirements
  pkgs.apacheHttpd
  pkgs.php
  pkgs.mysql

  # https://www.mediawiki.org/wiki/Manual:Installation_requirements#Optional_dependencies
  pkgs.bash
  pkgs.diffutils # diff3

  # We're not using ImageMagick, right?
  #pkgs.imagemagick
  pkgs.inkscape

  # Other
  php72Packages.composer
  pkgs.lucene
  pkgs.openssh

  # Are we using sendmail or postfix?
  # https://www.mediawiki.org/wiki/Manual_talk:$wgSMTP#Using_Sendmail_or_Postfix_(on_Ubuntu/Linux)
  pkgs.postfix

  # Are we using Parsoid?
  # https://www.mediawiki.org/wiki/Parsoid

  # See note above.
  #pathvisio
] ++ (if stdenv.isDarwin then [] else [])
