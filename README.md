nixos-dotfiles
==============

Deploy user dotfiles from configuration.nix.    
This project provides a way to deploy multiple users dotfiles to their home dirs from multiple git repositories using nixos-rebuild.

This is a work in progress and might fail and destroy the world.
----------------------------------------------------------------

To use nixos-dotfiles, clone this repository and modify default.nix to point to your dotfiles repository.  
you can have a different repository for each user.      
If your dotfiles repository is local, you can use this:
~~~~
user1 = callPackage /path/to/dotfiles { };
~~~~
and if you have it on github, you can use this to pin a specific commit:
~~~~
user2src = pkgs.fetchFromGitHub {
  owner = "yourGithubUser"; 
  repo = "yourGithubRepo";
  rev = "githubRevision";
  sha256 = "revisionSha256";
};

user2 = callPackage user2src { };
~~~~
or this to use a branch:
~~~~
user3src = fetchTarball https://github.com/yourGithubUser/yourGithubRepo/archive/branch.tar.gz;

user3 = callPackage usersrc { };
~~~~
You will need to have a default.nix listing your dotfiles in your dotfiles repository,
you can use as an example my dotfiles located at [this repository](https://github.com/xvapx/dotfiles).    
Then you can add this to your configuration.nix:
~~~~
dotfiles = import (/path/to/nixos-dotfiles) {};
~~~~
to import your local clone of this repository, or 
~~~~
dotfiles = import (fetchTarball https://github.com/yourGithubUser/yourGithubRepo/archive/master.tar.gz) {};
~~~~
to import it from github.    

Then you add
~~~~
dotfiles.user1
dotfiles.user2
dotfiles.user3
~~~~
to your 
~~~~
  environment.systemPackages = with pkgs; with dotfiles; [
~~~~
and
~~~~
system.activationScripts = with dotfiles; {
    dotfiles = 
    ''
      cp -fsr ${dotfiles.user1}/. /home/user1/
      cp -fsr ${dotfiles.user2}/. /home/user2/
      cp -fsr ${dotfiles.user3}/. /home/user3/
    '';
  };
~~~~
to your configuration.nix.    
On every nixos-rebuild it will copy your dotfiles to the nix store, 
and on every system activation it will link those dotfiles to the user(s) home(s).

You can install multiple user packages and link them all to their respective homes on system activation.

PROS of this method:
--------------------
* You can have a git repository with your dotfiles and another with your copy of nixos-dotfiles (or use mine and either PR your users, or use overrides), and just add a few lines to your configuration.nix to have them deployed.    
* Your dotfiles are read-only symlinks. To modify them you are forced to either make your changes in your git repository or delete the symlink an manually create the file.    

CONS of this method:
--------------------
* It is more cumbersome than just working with your local dotfiles.    
* Your dotfiles are read-only symlinks. To modify them you are forced to either make your changes in your git repository or delete the symlink and manually create the file.    
* It might break your dotfiles, your home or your entire system.    
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