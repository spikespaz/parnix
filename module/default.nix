args@{ config, pkgs, lib, ... }:
let
  cfg = config.parnix;
  inherit (lib.parnix.types) diskModule;
in {
  options = {
    parnix = { disks = lib.mkOption { type = lib.types.listOf diskModule; }; };
  };

  config = { };
}
