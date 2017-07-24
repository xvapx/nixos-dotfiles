nixos-dotfiles
==============
Deploy user dotfiles from configuration.nix.    
This project provides a way to deploy multiple users dotfiles to their home dirs from multiple git repositories using nixos-rebuild.

Warning
--------
This is a work in progress and has **NOT** been tested enough to be considered stable.     
I'm currently using it, but there is no guarantee it won't destroy your system.

How does nixos-dotfiles work
----------------------------
nixos-dotfiles installs your dotfiles to the nix store as packages, 
and then symlinks the content of each package to the specified folders, each system activation.

How to use nixos-dotfiles
-------------------------
#### 1. Add your user(s) to nixos-dotfiles.    
First you need to clone this repository and replace my users for yours and their dotfiles repositories in default.nix.

```nix
{ system ? builtins.currentSystem }:

let 
  pkgs = import <nixpkgs> { inherit system; };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  # Example A: get a user's dotfiles from a github repository, following a branch.
  # Replace (user), (repository) and (branch).
  dotfiles = fetchTarball https://github.com/(user)/(repository)/archive/(branch).tar.gz;

  # Example B: get a user's dotfiles from a specific commit in a github repository.
  # Replace (user), (repository), (revision) and (sha256).
  dotfiles = pkgs.fetchFromGitHub {
    user = "(user)"; 
    repo = "(repository)";
    rev = "(revision)";
    sha256 = "(sha256)";
  };

  # Example C: get multiple users's dotfiles from a single github branch.
  # To use this, your github repository must have a folder for each user.
  # Replace (user), (repository) and (branch)
  dotfiles = fetchTarball https://github.com/(user)/(repository)/archive/(branch).tar.gz;

  # Example D: get multiple users's dotfiles from muliple github repositories.
  # Replace (user1), (user2), (repository1), (repository2), (branch1) and (branch2).
  dotfiles1 = fetchTarball https://github.com/(user1)/(repository1)/archive/(branch1).tar.gz;
  dotfiles2 = fetchTarball https://github.com/(user2)/(repository2)/archive/(branch2).tar.gz;

  # Example E: get a user's dotfiles from a local directory.
  # nothing to do here

  self = rec {
    pkgconfig = callPackage ./pkgs/pkgconfig { };

    # Example A: get a user's dotfiles from a github repository, following a branch.
    user_A = callPackage dotfiles { };

    # Example B: get a user's dotfiles from a specific commit in a github repository.
    user_B = callPackage dotfiles { };

    # Example C: get multiple users's dotfiles from a single github branch.
    user_C_1 = callPackage dotfiles1 { };
    user_C_2 = callPackage dotfiles2 { };

    # Example D: get multiple users's dotfiles from muliple github repositories.
    user_D_1 = callPackage (dotfiles + "/user1Folder") { };
    user_D_2 = callPackage (dotfiles + "/user2Folder") { };
 
    # Example E: get a user's dotfiles from a local directory.
    user_E = callPackage /mnt/projectes/dotfiles/nixos { };
  };
in
self
```

#### 2. Add a default.nix to your dotfiles repository.    
You will need to add a default.nix to each of your dotfiles repositories, listing all the files to copy to the nix store.    
you can use as an example [this default.nix](https://github.com/xvapx/dotfiles/blob/ef6d4260e6c1b88e3e43f7e9943807507adea899/default.nix) for the examples A, B, C, and E, and 
[this one](https://github.com/xvapx/dotfiles/blob/bf1faefdee50e312520c5a1e44dcaa7593f075b0/default.nix) in 
[this repository](https://github.com/xvapx/dotfiles/tree/bf1faefdee50e312520c5a1e44dcaa7593f075b0) for the example D.

#### 3. Import your nixos-dotfiles clone as a NixOS channel and install your user packages.    
As you can see in [this configuration.nix](https://github.com/xvapx/dotfiles/blob/bf1faefdee50e312520c5a1e44dcaa7593f075b0/nixos/machines/xvapx-homestation.nix#L14), I have [a channels file](https://github.com/xvapx/dotfiles/blob/bf1faefdee50e312520c5a1e44dcaa7593f075b0/nixos/software/channels.nix#L29) in which I import my nixos-dotfiles repository.
You can import different repositories as nixos-channels this way:

```nix
rec {
  # nixos 17.03
  nixos-1703 = import (fetchTarball http://nixos.org/channels/nixos-17.03/nixexprs.tar.xz) {};

  # nixos unstable
  nixos-unstable = import (fetchTarball http://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};

  # nixos unstable-small
  nixos-unstable-small = import (fetchTarball http://nixos.org/channels/nixos-unstable-small/nixexprs.tar.xz) {};

  # nixpkgs unstable
  nixpkgs-unstable = import (fetchTarball https://github.com/nixos/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz) {};

  # nixpkgs master
  nixpkgs-master = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz) {};

  # xvapx stable
  xvapx-stable = import (fetchTarball https://github.com/xvapx/nixpkgs/archive/xvapx/stable.tar.gz) {};

  # xvapx testing
  xvapx-testing = import (fetchTarball https://github.com/xvapx/nixpkgs/archive/xvapx/testing.tar.gz) {};

  # Local nixpkgs
  local-nixpkgs = import (/mnt/projectes/nixpkgs) {};

  # xvapx dotfiles
  dotfiles = import (fetchTarball https://github.com/xvapx/nixos-dotfiles/archive/master.tar.gz) {};

  # Local dotfiles
  local-dotfiles = import (/mnt/projectes/nixos-dotfiles) {};

}
```
You can import all these channels to your configuration.nix and install your dotfiles this way (shortened example):
```nix
{ config, pkgs, lib, ... }:

let

channels = import ../channels.nix;

in
{
  environment.systemPackages = with pkgs; with channels;[
    dotfiles.user_A
    dotfiles.user_B
    dotfiles.user_C_1
    dotfiles.user_C_2
    dotfiles.user_D_1
    dotfiles.user_D_2
    dotfiles.user_E
  ];
}
```
#### 4. symlink the dotfiles to each user's home.    
I do it each system activation (each boot or nixos-rebuild switch) with this in my configuration.nix:
```nix
{ config, pkgs, lib, ... }:

{

  # Here usually goes the rest of the file...

  # And here is our linking script
  system.activationScripts = with pkgs; with channels;{
    dotfiles = 
    ''
      # symlink all the files in $1 to $2, $1 needs to be an absolute path
      linkdir() {
        for f in $(find $1 -maxdepth 1 -type f -printf '%P\n'); do
          ln -s -b -v $1/$f $2/$f;
        done
      }

      # recursively symlink all the files in $1 to $2
      reclink () {
        linkdir $1 $2
        for d in $(find $1 -type d -printf '%P\n'); do
          mkdir -p -v $2/$d;
          linkdir $1/$d $2/$d;
        done
      };

      reclink ${dotfiles.user_A} /home/userA
      reclink ${dotfiles.user_B} /home/userB
      reclink ${dotfiles.user_C_1} /home/userC1
      reclink ${dotfiles.user_C_2} /home/userC2
      reclink ${dotfiles.user_D_1} /home/userD1
      reclink ${dotfiles.user_D_2} /home/userD2
      reclink ${dotfiles.user_E} /home/userE

      unset -f reclink
      unset -f linkdir
    '';
  };
}
```
To use this activation script you only need to change the users names and homes.    
**This will replace any file with a symlink to the corresponding file in the nix store**.    
The script should make a backup of all the files it replaces, appending ~ to their name, but **you can still lose your dotfiles if something goes wrong**.    
to disable the automatic backup, replace 
```
ln -s -b -v $1/$f $2/$f; 
```
for 
```
ln -s -v $1/$f $2/$f; 
```
in the linkdir function.

PROS of this method:
--------------------
* Once you have a git repository with your dotfiles and another with your copy of nixos-dotfiles (or use mine and either PR your users, or use overrides), you just need to add a few lines to your configuration.nix to have all your dotfiles automatically deployed.
* Your dotfiles are read-only symlinks to the nix store. To modify them you are forced to either make your changes in your git repository or delete the symlink and manually create the file.
* Your dotfiles become part of your system derivation. You should be able to roll-back any change by reverting to a previous generation.

CONS of this method:
-------------------- 
* Your dotfiles are read-only symlinks. To modify them you are forced to either make your changes in your git repository or delete the symlink and manually create the file.
* It might break your dotfiles, your home or your entire system.
* Tedious.
* Some more for sure.

CREDITS
=======
I have used code from or been heavily inspired by:    
* [Sander van der Burg's blog](https://sandervanderburg.blogspot.com.es/).
* [Lethalman's blog](https://lethalman.blogspot.com.es).
* [The nix-dev mailing list](https://www.mail-archive.com/nix-dev@lists.science.uu.nl/).
* [The NixUP PR](https://github.com/NixOS/nixpkgs/pull/9250).
* [The nix-home project](https://github.com/sheenobu/nix-home).
* [The home-manager project](https://github.com/rycee/home-manager).
* [NixOS](https://nixos.org/).
