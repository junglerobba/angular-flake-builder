{
  lib,
  callPackage,
  nodejs,
}:
{
  packageRoot ? null,
  angularJson ? "${packageRoot}/angular.json",
  packageJson ? "${packageRoot}/package.json",
  nodejsPackage ? nodejs,
}:
let
  angular = lib.importJSON angularJson;
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

  forAllEnvsWithName = name: fn: (map fn (envs name));

  forAllEnvs =
    {
      name ? defaultProject,
    }:
    forAllEnvsWithName name;

  nativeBuildInputs = [
    nodejsPackage
    nodejsPackage.passthru.python
  ];

  buildAngularApp = callPackage ./angular.nix {
    inherit packageJson nativeBuildInputs;
    nodejs = nodejsPackage;
  };

in
{
  inherit
    defaultProject
    forAllEnvs
    buildAngularApp
    ;
}
