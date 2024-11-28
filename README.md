# Angular flake builder

Helper lib for building angular projects with nix

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    angular-builder = {
      url = "github:junglerobba/angular-flake-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs_20;
        src = pkgs.lib.cleanSource ./.;
        lib = inputs.angular-builder.lib.${system} {
          # uses `pkgs.nodejs` by default
          inherit nodejs;
          # `packageRoot` can be provided instead of these two
          # in order to just read the files from their default location
          angularJson = ./angular.json;
          packageJson = ./package.json;
        };
        # see `lib.nix` for others
        inherit (lib) forAllEnvs buildAngularApp;
      in
      {
        packages = builtins.listToAttrs (
          forAllEnvs
            {
              # forAllEnvs optionally takes a project name (as specified in `angular.json`),
              # and will otherwise use the first one
              name = "demo-project";
            }
            (env: {
              name = "dist:${env}";
              # name and version are read from package.json by default,
              # but can also be provided here instead
              value = buildAngularApp { inherit src env; };
            })
        );
        # any arguments for `pkgs.mkShell` are supported here, nodejs and angular cli are always provided by default
        devShells.default = lib.mkShell {
          nativeBuildInputs = with pkgs; [
            angular-language-server
            nodePackages.eslint
            nodePackages.prettier
            nodePackages.typescript-language-server
            vscode-langservers-extracted
          ];
        };
      }
    );
}
```


