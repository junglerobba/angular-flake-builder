{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  packageJson,
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

      npx ng build --configuration=${environment} \
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
