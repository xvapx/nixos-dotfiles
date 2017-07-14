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
and then symlinks the content of the package to the specified folders each system activation.

How to use nixos-dotfiles
-------------------------
1. Clone nixos-dotfiles
First you need to clone this repository and replace my users for yours and their dotfiles repositories in default.nix.

To add a local repository, add this:
~~~~
user1 = callPackage /path/to/dotfiles { };
~~~~
to default.nix.
To add a github repository, use this to pin a specific commit:
~~~~
user2src = pkgs.fetchFromGitHub {
  owner = "yourGithubUser"; 
  repo = "yourGithubRepo";
  rev = "githubRevision";
  sha256 = "revisionSha256";
};

user2 = callPackage user2src { };
~~~~
or this to follow a branch:
~~~~
user3src = fetchTarball https://github.com/yourGithubUser/yourGithubRepo/archive/branch.tar.gz;

user3 = callPackage usersrc { };
~~~~

2. Add a default.nix to your dotfiles repository
You will need to add a default.nix to each of your dotfiles repositories, listing all the files to copy to the nix store.
you can use as an example my [default.nix](https://github.com/xvapx/dotfiles/blob/master/default.nix) on my [dotfiles repository](https://github.com/xvapx/dotfiles).
I prefer manually listing some files, but you can easily copy everything in your dotfiles folder if you want.

3. Import your nixos-dotfiles clone as a NixOS channel and install your user packages
As you can see in [this configuration.nix](https://github.com/xvapx/dotfiles/blob/master/nixos/machines/xvapx-homestation.nix), I have [a channels file](https://github.com/xvapx/dotfiles/blob/master/nixos/software/channels.nix) in which I import my nixos-dotfiles repository using this line:
~~~~
dotfiles = import (fetchTarball https://github.com/xvapx/nixos-dotfiles/archive/master.tar.gz) {};
~~~~
you can instead import a local reposiroty using this way:
~~~~
dotfiles = import (/path/to/your/nixos-dotfiles) {};
~~~~
You can import all these channels to your configuration.nix and install your dotfiles this way (shortened example):
~~~~
{ config, pkgs, lib, ... }:

let

channels = import ../software/channels.nix;

in
{

environment.systemPackages = with pkgs; with channels;[
  dotfiles.user1
  dotfiles.user2
  dotfiles.user3
~~~~
With all the dotfiles installed in the nix store, the only thing to do now is symlink the dotfiles to each user's home.
I do it each system activation (each boot or nixos-rebuild switch) with this in my configuration.nix:
~~~~
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

      reclink ${dotfiles.user1} /home/user1
      reclink ${dotfiles.user2} /home/user2
      reclink ${dotfiles.user3} /home/user3

      unset -f reclink
      unset -f linkdir
    '';
  };
~~~~
To use this activation script you only need to change the user name and home.
**This will replace any file with a symlink to the corresponding file in the nix store**.
The script should make a backup of all the files it replaces, appending ~ to their name, but **you can still lose your dotfiles if something goes wrong**.
to disable the automatic backup, deplace ~~~~ ln -s -b -v $1/$f $2/$f; ~~~~ for ~~~~ ln -s -v $1/$f $2/$f; ~~~~ in the linkdir function.

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
