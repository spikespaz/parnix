{
# The system to use to import nixpkgs.
system ? "x86_64-linux",
# Nixpkgs input.
nixpkgs,
# The config to evaluate. Should contain top level `parnix`.
config ? ({ ... }: { }),
# Extra modules to evaluate.
extraModules ? [ ],
# Special argument to pass to modules.
specialArgs ? { }
  #
}:
let
  lib = specialArgs.lib or nixpkgs.lib;
  parnixLib = lib.extend (import ./lib.nix);
  pkgs = nixpkgs.legacyPackages.${system};

  evaluated = lib.evalModules {
    modules = [ config ./. ] ++ extraModules;
    specialArgs = {
      inherit pkgs;
      lib = parnixLib.extend (final: prev: {
        parnix = prev.parnix // {
          types = import ./types.nix {
            inherit pkgs;
            lib = final;
          };
        };
      });
    } // specialArgs;
  };
in { inherit (evaluated) options config; }
