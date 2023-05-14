{
# The system to use to import nixpkgs.
system ? "x86_64-linux",
# Nixpkgs input. Thiswill only be used if `pkgs` is unspecified.
nixpkgs ? null,
# Custom instance of `pkgs`, for example, with overlays.
pkgs ? nixpkgs.legacyPackages.${system},
# The config to evaluate. Should contain top level `parnix`.
# Note that this is required, however a default is provided
# so that the `extraModules` list may be used instead,
# as a convenience.
config ? ({ ... }: { }),
# Extra modules to evaluate.
extraModules ? [ ],
# Special argument to pass to modules.
# If `lib` is provided in this attrset
# it will be used instead of `nixpkgs.lib`.
specialArgs ? { }
  #
}:
let
  lib = specialArgs.lib or pkgs.lib or nixpkgs.lib;
  parnixLib = lib.extend (import ./lib.nix);

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
