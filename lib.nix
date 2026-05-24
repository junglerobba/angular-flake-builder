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

  outputPathFn =
    project:
    let
      options = angular.projects.${project}.architect.build.options;
      hasOverride = options ? outputPath;
      isString = hasOverride && builtins.isString options.outputPath;
      isAttrs = hasOverride && builtins.isAttrs options.outputPath;
    in
    if isString then
      options.outputPath
    else if isAttrs then
      options.outputPath.base or "dist"
    else
      "dist";

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
    inherit
      packageJson
      nativeBuildInputs
      defaultProject
      outputPathFn
      ;
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
