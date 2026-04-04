{ ... }:
{
  imports = [
    ./bootloader.nix
    ./xserver.nix
    ./network.nix
    ./bluetooth.nix
    ./fonts.nix
    ./security.nix # lockscreen
    ./services.nix
    ./system.nix
    ./user.nix
    # TODO: Comback later
    # ./pipewire.nix
    # ./wayland.nix
    # ./nixpkgs.nix

    # NOTE: For reference
    # ./nh.nix
    # ./steam.nix
    # ./program.nix
    # ./flatpak.nix
    # ./virtualization.nix
    # ./qmk.nix
  ];
}
