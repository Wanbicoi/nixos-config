# SAP HANA Developer CLI, packaged from the npm tarball for offline use.
#
# The npm tarball ships an npm-shrinkwrap.json, so buildNpmPackage can fetch all
# dependencies reproducibly and run without network access. There is no build
# step; the package is plain JavaScript.
{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "hana-cli";
  version = "4.202609.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/hana-cli/-/hana-cli-${version}.tgz";
    hash = "sha256-V3GI4myZ6ddZzDMlHEUZzzUuTnY47tOV/PfmXX2flbA=";
  };

  npmDepsHash = "sha256-zPMyHEN2yFxYpHE+aMdJAZ9nc4kctw1lD6L0UqQMcPo=";

  # Upstream ships plain JS; there is nothing to compile. Skip lifecycle
  # scripts, some transitive dev deps try to download browsers at install time.
  dontNpmBuild = true;
  npmRebuildFlags = [ "--ignore-scripts" ];
  # `npm pack --dry-run` would otherwise run the Vue UI `prepare` script.
  npmPackFlags = [ "--ignore-scripts" ];
  npmPruneFlags = [ "--ignore-scripts" ];

  meta = {
    description = "SAP HANA Developer Command Line Interface";
    homepage = "https://github.com/SAP-samples/hana-developer-cli-tool-example";
    license = lib.licenses.asl20;
    mainProgram = "hana-cli";
  };
}
