{
  lib,
  stdenv,
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
      npm ci
      npx ng build --configuration=${environment}
    '';
    installPhase = ''
      cp -r dist $out
    '';
  }
  // args
  // {
    nativeBuildInputs =
      nativeBuildInputs
      ++ [ importNpmLock.npmConfigHook ]
      ++ (lib.optionals (args ? nativeBuildInputs) args.nativeBuildInputs);
  }
)
