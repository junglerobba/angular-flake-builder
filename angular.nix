{
  lib,
  stdenv,
  importNpmLock,
  nodejs,
  node-gyp-build,
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
  ...
}@args:

stdenv.mkDerivation (
  {
    inherit
      name
      src
      version
      nodejs
      ;
    npmDeps = importNpmLock { npmRoot = src; };
    buildPhase = ''
      runHook preBuild

      export NG_CLI_ANALYTICS="false"

      npm ci
      patchShebangs node_modules

      runHook postBuild
    '';
    installPhase = ''
      cp -r dist $out
    '';
  }
  // args
  // {
    nativeBuildInputs =
      nativeBuildInputs
      ++ [
        importNpmLock.npmConfigHook
        node-gyp-build
      ]
      ++ (lib.optionals (args ? nativeBuildInputs) args.nativeBuildInputs);
  }
)
