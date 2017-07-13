nixos-dotfiles
==============

 
This is a work in progress and might fail and destroy the world.
---------------------------------------------------------------

To use nixos-dotfiles, clone this repository and modify default.nix to point to your dotfiles repository.    
If your dotfiles repository is local, you can use this:
~~~~
user = callPackage /path/to/user { };
~~~~
and if you have it on github, you can use this to use a specific commit:
~~~~
usersrc = pkgs.fetchFromGitHub {
  owner = "yourGithubUser"; 
  repo = "yourGithubRepo";
  rev = "githubRevision";
  sha256 = "revisionSha256";
};

user = callPackage usersrc { };
~~~~
or this to use a branch:
~~~~
usersrc = fetchTarball https://github.com/yourGithubUser/yourGithubRepo/archive/branch.tar.gz;

user = callPackage usersrc { };
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
system.activationScripts = with dotfiles; {
    dotfiles = 
    ''
      cp -fsr ${dotfiles.user}/. /home/user/
    '';
  };
~~~~
to your configuration.nix.    
On every nixos-rebuild it will copy your dotfiles to the nix store, 
and on every system activation it will link those dotfiles to the user(s) home(s).

You can install multiple user packages and link them all to their respective homes on system activation.

PROS of this method:
--------------------
* You can have a git repository with your dotfiles and another with your copy of nixos-dotfiles (or use mine and either PR your users or use overrides), and just add a few lines to your configuration.nix to have them deployed.    
* Your dotfiles are read-only symlinks. To modify them you are forced to either make your changes in your git repository or delete the symlink an manually create the file.    
* I like it.    

CONS of this method:
--------------------
* It is more cumbersome than just working with your local dotfiles.    
* Your dotfiles are read-only symlinks. To modify them you are forced to either make your changes in your git repository or delete the symlink an manually create the file.    
* It might destroy the world.    
* You may not like it.    
* Some more for sure...    
