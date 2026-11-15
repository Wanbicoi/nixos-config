# Host: merry-laptop — merry's personal laptop (native NixOS, not WSL).
#
# Two accounts, matching the WSL hosts' split: `nixos` is the admin (wheel,
# runs `nixos-rebuild`, no desktop profile) and `merry` is the everyday user
# who owns the KDE session. merry is deliberately *not* in wheel: she never
# needs sudo to use the machine, and the admin account stays the only way to
# change the system.
{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ../../modules/nixos/common.nix
  ]
  # Produced on the laptop by `nixos-generate-config` and copied in before
  # the first switch; it carries the disk UUIDs, kernel modules, and CPU
  # microcode settings that cannot be guessed from another machine. Guarded
  # with pathExists so this shared checkout still evaluates on the WSL hosts
  # (which never have the file) instead of breaking `nix flake check` there.
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  # Everything below is under `config` because the fallback block at the end
  # conditionally defines options; a module cannot mix top-level options with
  # an explicit `config` attribute.
  config =
    let
      missingHardwareConfig = !(builtins.pathExists ./hardware-configuration.nix);

      # Only opencode from llm-agents.nix, not the full agent set WSL imports:
      # this is merry's machine. The input packages v2 as `opencode2`; the
      # wrapper exposes it under the normal command name, because running v1
      # and v2 side by side collides in ~/.local/share/opencode (see
      # modules/nixos/llm-agents.nix).
      llm = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      networking.hostName = "merry-laptop";

      environment.systemPackages = [
        (pkgs.runCommand "opencode-v2-symlink" { } ''
          mkdir -p $out/bin
          ln -s ${llm.opencode2}/bin/opencode2 $out/bin/opencode
        '')

        # AnyConnect-compatible VPN client. The official Cisco Secure Client
        # has no nixpkgs package and its posture/Umbrella modules cannot be
        # reproduced; openconnect speaks the same protocol for the VPN part.
        # Kept on PATH as the diagnostic path, since the NetworkManager plugin
        # gives no useful errors when a gateway rejects the client.
        pkgs.openconnect
      ];

      system.stateVersion = "26.05";

      # Until the generated file is copied in, keep evaluation working with the
      # installer's default root label. Switching with this fallback still
      # active produces a machine that cannot mount /, hence the warning.
      warnings = lib.optional missingHardwareConfig ''
        hosts/merry-laptop: hardware-configuration.nix is missing, so a
        /dev/disk/by-label/nixos placeholder root is used. Copy the file that
        `nixos-generate-config` wrote to /etc/nixos/ into this host directory
        before switching.
      '';

      fileSystems."/" = lib.mkIf missingHardwareConfig {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      # Only the proprietary packages this machine actually needs. Zalo is
      # unfree too, but its flake builds the package with its own scoped
      # predicate, so it is intentionally absent here.
      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "google-chrome"
          "microsoft-edge"
          "wpsoffice"
        ];

      # UEFI install (the installer's default); sd-boot keeps the generation
      # rollback menu, which matters on a machine the admin only visits
      # remotely.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # X stays enabled because SDDM's greeter and the Plasma X11 fallback need
      # it; the Plasma 6 session itself is Wayland (`defaultSession =
      # "plasma"`).
      services.xserver.enable = true;
      services.desktopManager.plasma6.enable = true;
      services.displayManager.sddm.enable = true;
      services.displayManager.defaultSession = "plasma";

      # PipeWire only. 26.05 renamed the aliases (pulseaudio -> pulse); they
      # keep PulseAudio-only clients — Chrome, Edge, WPS — working without a
      # real pulseaudio daemon fighting PipeWire for the same devices.
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      services.libinput.enable = true;

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };

      hardware.enableRedistributableFirmware = true;

      services.upower.enable = true;
      services.power-profiles-daemon.enable = true;
      services.fwupd.enable = true;

      # Brother HL-L2320D: a host-based (PJL/HBP) laser, so CUPS needs brlaser;
      # the driver's 1284DeviceID entry matches the printer over USB
      # automatically. The queue itself is created once from KDE's printer
      # settings, so the USB serial stays whatever the hardware reports.
      services.printing = {
        enable = true;
        drivers = [ pkgs.brlaser ];
      };

      networking.networkmanager.enable = true;

      # KDE's Connections editor and the tray applet only offer "Cisco
      # AnyConnect" once the plugin is registered; it shells out to openconnect
      # from the systemPackages above.
      networking.networkmanager.plugins = [ pkgs.networkmanager-openconnect ];

      # Remote admin access without exposing SSH on whatever Wi-Fi the laptop
      # joins: sshd still binds every interface, but the firewall accepts port
      # 22 only on tailscale0, so it is reachable exclusively from the tailnet.
      # `nixos` authenticates with the password set after the first switch.
      # Run `sudo tailscale up` once to join the tailnet.
      services.tailscale.enable = true;
      services.openssh = {
        enable = true;
        openFirewall = false;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };
      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

      time.timeZone = "Asia/Ho_Chi_Minh";
      i18n.defaultLocale = "en_US.UTF-8";

      # Vietnamese Telex/VNI typing for Zalo and WPS. The module exports the
      # GTK/Qt/XIM variables, so both browsers and native apps pick it up.
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = [ pkgs.fcitx5-bamboo ];
      };

      # Liberation/DejaVu are the metric-compatible stand-ins WPS expects for
      # Word documents; Plasma brings Noto for the UI and Vietnamese glyphs.
      fonts.packages = with pkgs; [
        liberation_ttf
        dejavu_fonts
      ];

      users.users.nixos = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        shell = pkgs.zsh;
      };

      users.users.merry = {
        isNormalUser = true;
        uid = 1001;
        extraGroups = [
          "networkmanager"
          "video"
          "audio"
        ];
        shell = pkgs.zsh;
      };

      # No initial passwords are declared: the accounts start locked and are
      # set on the first switch with `sudo passwd nixos` / `sudo passwd merry`
      # (users.mutableUsers is on by default). A hashed password in the store
      # would be world-readable and wrong to share.
      #
      # Only merry gets a Home Manager profile. home/nixos pulls in the
      # personal sops secrets and WSL-only tooling, neither of which belongs on
      # this machine, so the admin account stays a bare system account.
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
        backupFileExtension = "hm-backup";

        users.merry.imports = [ ../../home/merry ];
      };
    };
}
