# This file imports all dotfiles

{ system ? builtins.currentSystem }:

let 
  pkgs = import <nixpkgs> { inherit system; };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = rec {
  	pkgconfig = callPackage ./pkgs/pkgconfig { };

    xvapxsrc = fetchTarball https://github.com/xvapx/dotfiles/archive/master.tar.gz;

    xvapx = callPackage xvapxsrc { };
	};
in
self