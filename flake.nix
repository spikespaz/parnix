{
  outputs = inputs@{ self, nixpkgs, ... }: {
    lib = { partitionConfiguration = import ./module/eval-config.nix; };
    nixosModules.parnix = import ./module.nix;

    partitionConfigurations.simple = self.lib.partitionConfiguration {
      inherit nixpkgs;
      config = import ./examples/simple.nix;
      specialArgs.primaryDevice = {
        path = "/dev/sda";
        # blockdev --getsize64 /dev/sda
        size = 2000398934016 / 1024;
        reservePercent = 5.0e-2;
        # awk '{if ($1 == "MemTotal:") print $2}' /proc/meminfo
        swapSize = 38735612 + 2 * 1024 * 1024;
      };
    };
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # birdos.url = "github:spikespaz/dotfiles/master";
  };
}
