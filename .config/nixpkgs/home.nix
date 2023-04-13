{ config, pkgs, ... }:

let
  # ...
  nixgl = import <nixgl> {} ;
  nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
    mkdir $out
    ln -s ${pkg}/* $out
    rm $out/bin
    mkdir $out/bin
    for bin in ${pkg}/bin/*; do
      wrapped_bin=$out/bin/$(basename $bin)
      echo "exec ${lib.getExe nixgl.auto.nixGLDefault} $bin \$@" > $wrapped_bin
      chmod +x $wrapped_bin
    done
  '';
in {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "j-ace-svg";
  home.homeDirectory = "/home/j-ace-svg";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Manage Bash
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      . ~/.bashrc.old
    '';
    profileExtra = ''
      export XDG_DATA_DIRS=$HOME/.nix-profile/share:$HOME/.share:"${XDG_DATA_DIRS:-/usr/local/share/:/usr/share/}"
      . ~/.profile.old
    '';
  };

  home.packages = [
    # nixGL for OpenGL applications
    nixgl.auto.nixGLDefault

    # Regular packages
    pkgs.nodejs
    pkgs.tmux

    # Packages with nixGL wrapper
    (nixGLWrap pkgs.qutebrowser)
  ];
}
