specialArgs@{ lib, pkgs, ... }:
let
  sgdiskOffset = lib.types.strMatching "^([+-])([0-9]+)([KMGTP])$";
  sgdiskSize = lib.types.strMatching "^([0-9]+)([KMGTP])$";
  sgdiskTypecode = lib.types.strMatching "^([a-f0-9]{4})$";

  diskModule = lib.types.submoduleWith {
    modules = [ ./disk-module.nix ];
    inherit specialArgs;
    description = lib.mdDoc ''
      Attrset of options representing the layout, mount points,
      mount options, and all other necessary parameters of an individual disk.
    '';
  };
  partModule = lib.types.submoduleWith {
    modules = [ ./part-module.nix ];
    inherit specialArgs;
    description = lib.mdDoc ''
      The configuration options containing information required
      format and mount each disk partiton, either in scripts
      or system configurations.
    '';
  };
in {
  inherit
  #
    sgdiskOffset sgdiskSize sgdiskTypecode diskModule partModule;
}
