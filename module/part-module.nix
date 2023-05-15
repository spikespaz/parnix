{ config, lib, pkgs, parnixTypes, ... }:
let inherit (parnixTypes) sgdiskOffset sgdiskSize sgdiskTypecode;
in {
  options = {
    format = lib.mkOption {
      type = with lib.types;
        nullOr (enum [ "efi" "vfat" "ntfs" "swap" "ext2" "ext3" "ext4" "zfs" ]);
      description = lib.mdDoc ''
        The what filesystem to format the partition with.
      '';
    };
    formatArguments = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      default = [ ];
      description = lib.mdDoc ''
        Extra arguments to give to the formatting command.
        The command used depends on the {option}`format`,
        for example, `"ntfs"` would use the `mkfs.ntfs` command.

        This list of strings will be passed though `lib.escapeShellArgs`.
      '';
    };
    mountArguments = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      default = [ ];
      description = lib.mdDoc ''
        Extra arguments to give to the mount command,

        This list of strings will be passed through `lib.escapeShellArgs`.
      '';
    };
    typecode = lib.mkOption {
      type = sgdiskTypecode;
      description = lib.mdDoc ''
        The typecode to use for the partition. See `sgdisk -L` for
        mappings to common names.
      '';
    };
    label = lib.mkOption {
      type = lib.types.singleLineStr;
      description = lib.mdDoc ''
        The label to use for the formatted partition.
      '';
    };
    start = lib.mkOption {
      type = with lib.types; either sgdiskOffset (enum [ "0" ]);
      default = "0";
      description = lib.mdDoc ''
        A default of `"0"` will use the start of the next unallocated block.
      '';
    };
    size = lib.mkOption {
      type = lib.types.nullOr sgdiskSize;
      default = null;
      description = lib.mdDoc ''
        A default of `null` will not create partition based on size,
        but instead defer to the value of {option}`end`.
      '';
    };
    end = lib.mkOption {
      type = with lib.types; either sgdiskOffset (enum [ "0" ]);
      default = "0";
      description = lib.mdDoc ''
        A default of `"0"` will use the end of the next unallocated block.
      '';
    };

    hooks.preCreate = lib.parnix.mkHookOption "preCreate";
    createCommands = lib.parnix.mkHookOption "createCommands";
    hooks.postCreate = lib.parnix.mkHookOption "postCreate";

    hooks.preFormat = lib.parnix.mkHookOption "preFormat";
    formatCommands = lib.parnix.mkHookOption "formatCommands";
    hooks.postFormat = lib.parnix.mkHookOption "postFormat";

    hooks.preMount = lib.parnix.mkHookOption "preMount";
    mountCommands = lib.parnix.mkHookOption "mountCommands";
    hooks.postMount = lib.parnix.mkHookOption "postMount";

    hooks.preUnmount = lib.parnix.mkHookOption "preUnmount";
    unmountCommands = lib.parnix.mkHookOption "unmountCommands";
    hooks.postUnmount = lib.parnix.mkHookOption "postUnmount";

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
  config = lib.mkMerge [
    (lib.mkIf (config.format == "efi") {
      typecode = lib.mkDefault "ef00"; # EFI system partition
    })
    (lib.mkIf (config.format == "vfat") {
      typecode = lib.mkDefault "0700"; # Microsoft basic data
    })
    (lib.mkIf (config.format == "ntfs") {
      typecode = lib.mkDefault "0700"; # Microsoft basic data
    })
    (lib.mkIf (config.format == "swap") {
      typecode = lib.mkDefault "8200"; # Linux swap
    })
    (lib.mkIf (config.format == "ext2") {
      typecode = lib.mkDefault "8300"; # Linux filesystem
    })
    (lib.mkIf (config.format == "ext3") {
      typecode = lib.mkDefault "8300"; # Linux filesystem
    })
    (lib.mkIf (config.format == "ext4") {
      typecode = lib.mkDefault "8300"; # Linux filesystem
    })
  ];
}
