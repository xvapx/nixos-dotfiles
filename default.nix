{ system ? builtins.currentSystem }:

let
  pkgs = import <nixpkgs> { inherit system; };

  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  # Example A: get a user's dotfiles from a github repository, following a branch.
  # Replace (user), (repository) and (branch).
  # dotfiles = fetchTarball https://github.com/(user)/(repository)/archive/(branch).tar.gz;

  # Example B: get a user's dotfiles from a specific commit in a github repository.
  # Replace (user), (repository), (revision) and (sha256).
  # dotfiles = pkgs.fetchFromGitHub {
  #   user = "(user)"; 
  #   repo = "(repository)";
  #   rev = "(revision)";
  #   sha256 = "(sha256)";
  # };

  # Example C: get multiple users's dotfiles from a single github branch.
  # To use this, your github repository must have a folder for each user.
  # Replace (user), (repository) and (branch)
  # dotfiles = fetchTarball https://github.com/(user)/(repository)/archive/(branch).tar.gz;

  # Example D: get multiple users's dotfiles from muliple github repositories.
  # Replace (user1), (user2), (repository1), (repository2), (branch1) and (branch2).
  # dotfiles1 = fetchTarball https://github.com/(user1)/(repository1)/archive/(branch1).tar.gz;
  # dotfiles2 = fetchTarball https://github.com/(user2)/(repository2)/archive/(branch2).tar.gz;

  # Example E: get a user's dotfiles from a local directory.
  # nothing to do here

  dotfiles = fetchTarball https://github.com/xvapx/dotfiles/archive/master.tar.gz;

  self = rec {
    pkgconfig = callPackage ./pkgs/pkgconfig { };

    # Example A: get a user's dotfiles from a github repository, following a branch.
    # user_A = callPackage dotfiles { };

    # Example B: get a user's dotfiles from a specific commit in a github repository.
    # user_B = callPackage dotfiles { };

    # Example C: get multiple users's dotfiles from a single github branch.
    # user_C_1 = callPackage dotfiles1 { };
    # user_C_2 = callPackage dotfiles2 { };

    # Example D: get multiple users's dotfiles from muliple github repositories.
    # user_D_1 = callPackage (dotfiles + "/user1Folder") { };
    # user_D_2 = callPackage (dotfiles + "/user2Folder") { };
 
    # Example E: get a user's dotfiles from a local directory.
    # user_E = callPackage /mnt/projectes/dotfiles/nixos { };

    nixos = callPackage (dotfiles + "/nixos") { };
    xvapx = callPackage (dotfiles + "/xvapx") { };
  };
in
self