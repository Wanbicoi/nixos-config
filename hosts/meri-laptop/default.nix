# Host: meri-laptop — meri's personal laptop (native NixOS, not WSL).
#
# Two accounts, matching the WSL hosts' split: `nixos` is the admin (wheel,
# runs `nixos-rebuild`) and also carries the same developer profile the WSL
# machines use; `meri` is the everyday user who owns the KDE session and keeps
# a KDE-only profile. meri is deliberately *not* in wheel: she never needs sudo
# to use the machine, and the admin account stays the only way to change the
# system.
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
    # Developer stack for the `nixos` profile, exactly as on the WSL hosts:
    # the agent CLIs, herdr, and the journals daemon.
    ../../modules/nixos/llm-agents.nix
    ../../modules/nixos/herdr.nix
    ../../modules/nixos/journals.nix
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
    in
    {
      networking.hostName = "meri-laptop";

      # opencode v1 is installed as a bootstrap by the first-install guide; the
      # `nixos` profile then gets v2 from modules/nixos/llm-agents.nix, under
      # the plain command name.
      environment.systemPackages = [
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
        hosts/meri-laptop: hardware-configuration.nix is missing, so a
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
          "corefonts"
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

      # Spectacle's OCR ("Copy Text") is compiled against libtesseract and
      # reads the traineddata from the library's compiled-in path; it never
      # calls the `tesseract` CLI, so installing the CLI (home/meri/packages.nix)
      # is not enough. nixpkgs builds it with `tesseractLanguages = [ ]`, which
      # means no traineddata at all, so rebuild Spectacle in the KDE scope the
      # plasma6 module installs from with English and Vietnamese data.
      nixpkgs.overlays = [
        (final: prev: {
          kdePackages = prev.kdePackages.overrideScope (
            self: super: {
              spectacle = super.spectacle.override {
                tesseractLanguages = [
                  "eng"
                  "vie"
                ];
              };
            }
          );
        })
      ];

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

      # The `nixos` profile is the same one the WSL hosts use, so the checkout
      # lives at /srv/nixconfig there too: outside the home, linked back out of
      # store for the nvim/agent submodules, and group-readable so the journals
      # daemon can read its source through the `nixconfig` group. Only nixos
      # writes it; root re-evaluates it on every rebuild, hence the
      # safe.directory entries (not recursive, so the glob is needed).
      users.groups.nixconfig = { };
      systemd.tmpfiles.rules = [
        "z /srv/nixconfig 2750 nixos nixconfig - -"
      ];
      programs.git = {
        enable = true;
        config.safe.directory = [
          "/srv/nixconfig"
          "/srv/nixconfig/*"
        ];
      };

      # Shared journal, configured exactly like the WSL hosts. The database
      # stays at /srv/shared/journals/data.sqlite (module default).
      services.journals = {
        enable = true;
        repoRoot = "/srv/nixconfig";
      };

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
      # corefonts adds the genuine Times New Roman (unfree; allowlisted above)
      # so documents rendered here look exactly as on Windows.
      #
      # WPS/Office templates ask for Calibri and Cambria, which are not
      # redistributable; carlito/caladea are the metric-compatible clones, so
      # lesson plans keep their page breaks when printed. gyre-fonts and
      # stix-two/lmodern give exam papers and maths formulas proper glyphs.
      # All of them cover Vietnamese diacritics.
      fonts.packages = with pkgs; [
        corefonts
        carlito
        caladea
        gyre-fonts
        stix-two
        lmodern
        liberation_ttf
        dejavu_fonts
      ];

      # Admin account, and the one that gets the shared developer profile. The
      # audio/video groups mirror meri's so the Plasma/PipeWire session works
      # the same for both. linger keeps a user manager at boot, so the sops-nix
      # user service renders ~/.config/sops-nix/secrets before the first login
      # (without it the render is skipped until someone actually logs in).
      users.users.nixos = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = [
          "wheel"
          "networkmanager"
          "audio"
          "video"
        ];
        shell = pkgs.zsh;
        linger = true;
      };

      users.users.meri = {
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
      # set on the first switch with `sudo passwd nixos` / `sudo passwd meri`
      # (users.mutableUsers is on by default). A hashed password in the store
      # would be world-readable and wrong to share.
      #
      # meri keeps the KDE-only profile; nixos gets the same shared developer
      # profile as the WSL machines (home/nixos + home/common), including the
      # personal sops namespace. repoRoot points the submodule links and the
      # journals TUI at the /srv checkout, replacing the WSL-only value from
      # home/common/wsl.nix.
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
        backupFileExtension = "hm-backup";

        users.nixos = {
          imports = [ ../../home/nixos ];
          submodules.repoRoot = "/srv/nixconfig";
          # Wayland clipboard for the zsh vi-yank fallback in
          # home/common/shell.nix; the WSL profiles get the same tool from
          # home/common/wsl.nix instead.
          home.packages = [ pkgs.wl-clipboard ];
        };
        users.meri.imports = [ ../../home/meri ];
      };
    };
}
