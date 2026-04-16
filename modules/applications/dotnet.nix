{ pkgs, config, ... }:

let
  # This script creates a 'userlocal' file which tells dotnet 
  # it's okay to install workloads in the user directory.
  workloadfix = ''
    for i in $out/share/dotnet/sdk/*
    do
      i=$(basename $i)
      length=$(printf "%s" "$i" | wc -c)
      # Adjust version string to end in "00" (e.g., 8.0.101 -> 8.0.100)
      substring=$(printf "%s" "$i" | cut -c 1-$(expr $length - 2))
      i="$substring""00"

      mkdir -p $out/share/dotnet/metadata/workloads/''${i/-*}
      touch $out/share/dotnet/metadata/workloads/''${i/-*}/userlocal
    done
  '';

  sdkOverride = (finalAttrs: previousAttrs: {
    src = (previousAttrs.src.overrideAttrs (finalAttrs: previousAttrs: {
      postBuild = (previousAttrs.postBuild or "") + workloadfix;
    }));
  });

  # Combine the SDKs you need (e.g., .NET 8 or 9)
  dotnet-full = with pkgs.dotnetCorePackages; combinePackages [
    # (sdk_8_0.overrideAttrs sdkOverride)
    (sdk_9_0.overrideAttrs sdkOverride)
    (sdk_10_0.overrideAttrs sdkOverride)
  ];

in {
  home.packages = [
    dotnet-full
  ];

  home.sessionVariables = {
    DOTNET_ROOT = "${dotnet-full}/share/dotnet";
    DOTNET_PATH = "${dotnet-full}/bin/dotnet";
  };

  home.sessionPath = [ 
    "${config.home.homeDirectory}/.dotnet/tools" 
  ];
}