{ lib, primaryDevice, ... }: {
  parnix.disks = [{
    device = primaryDevice.path;
    partitions = [
      {
        format = "efi";
        label = "BOOT";
        start = "1M";
        size = "512M";
      }
      {
        format = "swap";
        label = "swap";
        size = "${toString primaryDevice.swapSize}K";
      }
      (let
        reserveFree =
          builtins.floor (primaryDevice.size * primaryDevice.reservePercent);
      in {
        format = "ext4";
        label = "root";
        end = "-${toString reserveFree}K";
      })
    ];
  }];
}
