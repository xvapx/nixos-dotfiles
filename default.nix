# This file imports all dotfiles

{ system ? builtins.currentSystem }:

let 
  pkgs = import <nixpkgs> { inherit system; };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = rec {
  	pkgconfig = callPackage ./pkgs/pkgconfig { };

    xvapxsrc = pkgs.fetchFromGitHub {
    	owner = "xvapx";
    	repo = "dotfiles";
    	rev = "3b42fa9d1991052a3e25d095b6e357d745cdaaf1";
    	sha256 = "1zja8wz6qz3vlh5wiiqglnj3j5b830xyirhg8905rqlz2gy882za";
    };

    xvapx = callPackage xvapxsrc { };
	};
in
self