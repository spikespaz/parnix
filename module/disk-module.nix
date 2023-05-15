{ config, lib, pkgs, parnixTypes, ... }:
let
  inherit (lib.parnix) mkHookOption mkScriptOption;
  inherit (parnixTypes) partModule;
in {
  options = {
    device = lib.mkOption {
      type = with lib.types; singleLineStr; # TODO
      description = lib.mdDoc ""; # TODO
    };
    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      readOnly = true;
    };
    partitions = lib.mkOption {
      type = lib.types.listOf partModule;
      description = lib.mdDoc ""; # TODO
    };
    alignment = lib.mkOption {
      type = with lib.types; nullOr ints.unsigned;
      default = null;
      description = lib.mdDoc ''
        The sector alignment multiple to use to align the
        starts (and optionally ends) of partitions to sector
        boundaries.

        A default of `null` will not spedicy the option `-a`,
        which will use a default of 1 MiB (or 2048 on disks with
        512-byte sectors) on freshly-formatted disks.
      '';
    };
    alignEnds = lib.mkOption {
      type = with lib.types; bool;
      default = true;
      description = lib.mdDoc ''
        Whether to align the ends of partitons to sector boundaries
        using the alignment multiple set by {option}`alignment`.

        Note that the default for this option is `true` while `sgdisk`
        does not align the ends by default.
      '';
    };

    hooks.preCreate = mkHookOption "preCreate";
    createScript = mkScriptOption "createScript";
    hooks.postCreate = mkHookOption "postCreate";

    hooks.preFormat = mkHookOption "preFormat";
    formatScript = mkScriptOption "formatScript";
    hooks.postFormat = mkHookOption "postFormat";

    hooks.preMount = mkHookOption "preMount";
    mountScript = mkScriptOption "mountScript";
    hooks.postMount = mkHookOption "postMount";

    hooks.preUnmount = mkHookOption "preUnmount";
    unmountScript = mkScriptOption "unmountScript";
    hooks.postUnmount = mkHookOption "postUnmount";

    requiredPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = lib.mdDoc ''
        Packages to be installed to the system to make this
        filesystem function. This includes packages that include the
        formatting command used in the shell {option}`hooks`.
      '';
    };
  };
  config = {
    name = baseNameOf config.device;
    requiredPackages = config.requiredPackages ++ [ pkgs.gptfdisk ];

    createScript = pkgs.writeShellScript "createScript-${config.name}" "";
    formatScript = pkgs.writeShellScript "formatScript-${config.name}" "";
    mountScript = pkgs.writeShellScript "mountScript-${config.name}" "";
    unmountScript = pkgs.writeShellScript "unmountScript-${config.name}" "";

  };
}
