nixos-dotfiles
==============

 
This is a work in progress and might fail and destroy the world.
---------------------------------------------------------------

To use this, clone this repository and modify default.nix to point to your dotfiles.    
If your repository is local, you can use this:
~~~~
user = callPackage ./user { };
~~~~
and if you have it on github, you can use this:
~~~~
usersrc = pkgs.fetchFromGitHub {
  owner = "yourGithubUser"; 
  repo = "yourGithubRepo";
  rev = "githubRevision";
  sha256 = "revisionSha256";
};

user = callPackage usersrc { };
~~~~
Then you can add this to your configuration.nix:
~~~~
dotfiles = import (/path/to/nixos-dotfiles) {};
~~~~
to import your local clone of your dotfiles repository, or 
~~~~
dotfiles = import (fetchTarball https://github.com/yourGithubUser/yourGithubRepo/archive/master.tar.gz) {};
~~~~
to import it from github.    
You can use as an example my dotfiles located at [my github](https://github.com/xvapx/dotfiles).

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
and on every system activation it will link those dotfiles the user(s) home(s).

You can install multiple user packages and link them all to their respective homes on system activation.

PROS of this method:
--------------------
* You can have a git repository with your dotfiles and another with your copy of nixos-dotfiles (or use mine and either PR your users or use overrides), and just add a few lines to your configuration.nix to have them deployed.    
* Your dotfiles are read-only symlinks. To modify them you are forced to either make your changes in your git repository or delete the symlink an manually create the file.    
* I like it.    

CONS of this method:
--------------------
* It is more cumbersome than just working with you local dotfiles.    
* Your dotfiles are read-only symlinks. To modify them you are forced to either make your changes in your git repository or delete the symlink an manually create the file.    
* It might destroy the world.    
* You may not like it.    
* Some more for sure...    
