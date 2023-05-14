specialArgs@{ lib, pkgs, ... }:
let
  sgdiskOffset = lib.types.strMatching "^([+-])([0-9]+)([KMGTP])$";
  sgdiskSize = lib.types.strMatching "^([0-9]+)([KMGTP])$";
  sgdiskStart = lib.types.either sgdiskOffset (lib.types.enum [ "0" ]);
  sgdiskTypecode = lib.types.strMatching "^([a-f0-9]{4})$";

  diskModule = lib.types.submoduleWith {
    modules = [ ./disk-module.nix ];
    inherit specialArgs;
    description = lib.mdDoc ''
      Attrset of options representing the layout, mount points,
      mount options, and all other necessary parameters of an individual disk.
    '';
  };
in {
  inherit
  #
    sgdiskOffset sgdiskSize sgdiskStart sgdiskTypecode diskModule;
}
