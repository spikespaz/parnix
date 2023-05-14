final: prev:
let
  lib = final;

  mkHookOption = stage:
    lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = lib.mdDoc ''
        Lines of shell code to run during the ${stage} stage.
      '';
    };

  mkScriptOption = stage:
    lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = lib.mdDoc ''
        The script to run during the ${stage} stage of installing the system.
      '';
    };

  # The following function is borrowed from disko.
  /* get a device and an index to get the matching device name

       deviceNumbering :: str -> int -> str

       Example:
       deviceNumbering "/dev/sda" 3
       => "/dev/sda3"

       deviceNumbering "/dev/disk/by-id/xxx" 2
       => "/dev/disk/by-id/xxx-part2"
  */
  getPartitionFileByNumber = device: index:
    if builtins.match "/dev/[vs]d.+" device != null then
      device + toString index # /dev/{s,v}da style
    else if builtins.match "/dev/(disk|zvol)/.+" device != null then
      "${device}-part${
        toString index
      }" # /dev/disk/by-id/xxx style, also used by zfs's zvolumes
    else if builtins.match "/dev/((nvme|mmcblk).+|md/.*[[:digit:]])" device
    != null then
      "${device}p${toString index}" # /dev/nvme0n1p1 style
    else if builtins.match "/dev/md/.+" device != null then
      "${device}${toString index}" # /dev/md/raid1 style
    else if builtins.match "/dev/mapper/.+" device != null then
      "${device}${toString index}" # /dev/mapper/vg-lv1 style
    else
      abort ''
        ${device} seems not to be a supported disk format. Please add this to disko in https://github.com/nix-community/disko/blob/master/types/default.nix
      '';
in {
  parnix = { inherit mkHookOption mkScriptOption getPartitionFileByNumber; };
}
