{
  pkgs ? import <nixpkgs> { },
  packageJson,
  nativeBuildInputs,
  nodejs,
}:
with pkgs;
let
  package = lib.importJSON packageJson;
in
{
  name ? package.name,
  version ? package.version,
  env ? "production",
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
      ng build --configuration=${env}
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
