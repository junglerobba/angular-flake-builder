{
  pkgs ? import <nixpkgs> { },
}:
with pkgs.lib;

{
  packageRoot ? null,
  angularJson ? "${packageRoot}/angular.json",
  packageJson ? "${packageRoot}/package.json",
  nodejs ? pkgs.nodejs,
}:
let
  angular = importJSON angularJson;
  envs =
    name:
    let
      configurations = angular.projects.${name}.architect.build.configurations;
    in
    builtins.attrNames configurations;

  defaultProject =
    let
      projects = builtins.attrNames angular.projects;
    in
    builtins.elemAt projects 0;

  forAllEnvsWithName = name: fn: (builtins.map fn (envs name));

  forAllEnvs =
    {
      name ? defaultProject,
    }:
    forAllEnvsWithName defaultProject;

  nativeBuildInputs = [
    nodejs
    nodejs.passthru.python
    pkgs.nodePackages."@angular/cli"
  ];

  buildAngularApp = pkgs.callPackage ./angular.nix { inherit packageJson nativeBuildInputs nodejs; };

  mkShell =
    { ... }@args:
    pkgs.mkShell (
      args
      // {
        name = defaultProject;
        nativeBuildInputs =
          nativeBuildInputs ++ (optionals (args ? nativeBuildInputs) args.nativeBuildInputs);
      }
    );
in
{
  inherit
    defaultProject
    forAllEnvs
    buildAngularApp
    mkShell
    ;
}
