args@{ config, pkgs, lib, parnixTypes, ... }:
let
  cfg = config.parnix;
  inherit (parnixTypes) diskModule;
in {
  options = {
    parnix = { disks = lib.mkOption { type = lib.types.listOf diskModule; }; };
  };

  config = { };
}
