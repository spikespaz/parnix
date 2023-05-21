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
config ? null,
# Extra modules to evaluate.
extraModules ? [ ],
# Special argument to pass to modules.
# If `lib` is provided in this attrset
# it will be used instead of `nixpkgs.lib`.
specialArgs ? { }
  #
}:
let
  lib = (specialArgs.lib or pkgs.lib or nixpkgs.lib).extend (import ./lib.nix);

  evaluated = lib.evalModules {
    modules = [ ./. ] ++ lib.optional (config != null) config ++ extraModules;
    specialArgs = {
      inherit pkgs lib;
      parnixTypes = import ./types.nix { inherit pkgs lib; };
    } // specialArgs;
  };
in { inherit (evaluated) options config; }
