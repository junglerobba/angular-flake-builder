{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  packageJson,
  defaultProject,
  nativeBuildInputs,
}:
let
  package = lib.importJSON packageJson;
in
{
  name ? package.name,
  version ? package.version,
  environment ? "production",
  src,
  ngBuildFlags ? [ ],
  project ? defaultProject,
  ...
}@args:

buildNpmPackage (
  {
    pname = name;
    inherit
      src
      version
      nodejs
      ;
    npmDeps = importNpmLock { npmRoot = src; };
    npmConfigHook = importNpmLock.npmConfigHook;

    buildPhase = ''
      runHook preBuild

      export NG_CLI_ANALYTICS="false"

      npx ng build ${project} --configuration=${environment} \
        ${lib.concatStringsSep "\\n" ngBuildFlags}

      runHook postBuild
    '';
    installPhase = ''
      cp -r dist $out
    '';
  }
  // args
  // {
    nativeBuildInputs =
      nativeBuildInputs ++ (lib.optionals (args ? nativeBuildInputs) args.nativeBuildInputs);
  }
)
