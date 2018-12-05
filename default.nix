with import <nixpkgs> { config.allowUnfree = true; };
let
  custom = import (fetchGit {
    url = "https://github.com/ariutta/nixpkgs-custom.git";
    #rev = "722afd6c5a66446f65e4737f55a2b0b98775c4cb";
    rev = "b0e122e3d0c726dada9ba3dd5ca211084ce2b231";
    ref = "master";
  });
# TODO: I'd like to specify parameters for pathvisio,
# but I get an error when I use the second expression
# below, so I'm just using the first one for now.
  pathvisio = custom.pathvisio;
#  pathvisio = callPackage custom.pathvisio {
#    organism="Homo sapiens";
#    headless=true;
#    genes=false;
#    interactions=false;
#    metabolites=false;
#    # NOTE: this seems high, but I got an error
#    #       regarding memory when it was lower.
#    memory="2048m";
#  };
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

  pathvisio
] ++ (if stdenv.isDarwin then [] else [])
