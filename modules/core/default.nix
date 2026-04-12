{ ... }:
{
  imports = [
    ./bootloader.nix
    ./xserver.nix
    ./wayland.nix
    ./network.nix
    ./bluetooth.nix
    ./security.nix # lockscreen
    ./services.nix
    ./system.nix
    ./user.nix
    ./displaymanager.nix
    ./fonts.nix
    ./system-programs.nix
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
