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
}:

stdenv.mkDerivation {
  inherit
    name
    src
    version
    nodejs
    ;
  nativeBuildInputs = nativeBuildInputs ++ [ importNpmLock.npmConfigHook ];
  npmDeps = importNpmLock { npmRoot = src; };
  buildPhase = ''
    npm ci
    ng build --configuration=${env}
  '';
  installPhase = ''
    cp -r dist $out
  '';
}
