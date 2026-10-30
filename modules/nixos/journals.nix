# Journals API server, run as a dedicated system service.
#
# The daemon is the only writer of the SQLite database and the only owner of the
# HTTP port. Human users run the TUI, which talks to it over 127.0.0.1. On
# wsl-laidon both identities share this one daemon and therefore one database.
#
# The source checkout is the writable submodule under /srv/nixconfig, read
# through the `nixconfig` group (see hosts/*). `make journals-deps` must have
# installed node_modules before the unit can start.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.journals;
  repo = "${cfg.repoRoot}/submodules/journals";
in
{
  options.services.journals = {
    enable = lib.mkEnableOption "Journals API server";

    repoRoot = lib.mkOption {
      type = lib.types.str;
      default = "/srv/nixconfig";
      description = "Path to the nixconfig checkout that contains the journals submodule.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4321;
      description = ''
        HTTP port for the daemon. WSL distros may share a network namespace, so
        hosts that can run at the same time need distinct ports.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.journals = { };
    users.groups.nixconfig = { };

    users.users.journals = {
      isSystemUser = true;
      group = "journals";
      # Repository access is read-only, through the nixconfig group.
      extraGroups = [ "nixconfig" ];
      home = "/var/lib/journals";
      description = "Journals API daemon";
    };

    # Same absolute path on every host: on wsl-laidon both users share it, on
    # the personal distro it is that distro's own data. The parent /srv/shared
    # is created automatically where it does not exist.
    systemd.tmpfiles.rules = [
      "d /srv/shared/journals 0700 journals journals -"
    ];

    environment.etc."journals/config.yaml" = {
      mode = "0444";
      text = ''
        server:
          host: "127.0.0.1"
          port: ${toString cfg.port}
          db_path: "/srv/shared/journals/data.sqlite"
          wal_mode: true
          auto_start: false
      '';
    };

    systemd.services.journals = {
      description = "Journals API server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "journals";
        Group = "journals";
        WorkingDirectory = repo;
        StateDirectory = "journals";
        Environment = [
          "JOURNAL_CONFIG=/etc/journals/config.yaml"
          "HOME=/var/lib/journals"
        ];
        ExecStartPre = "${pkgs.writeShellScript "journals-preflight" ''
          test -d ${repo}/node_modules || {
            echo "journals: run make journals-deps first" >&2
            exit 1
          }
        ''}";
        ExecStart = "${pkgs.bun}/bin/bun ${repo}/packages/server/src/index.ts";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}
