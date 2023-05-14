{
  outputs = inputs@{ self, nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
      systems = lib.systems.doubles.all;
    in {
      # In your flake, create `partitionConfigurations` outputs by calling
      # `inputs.parnix.lib.partitionConfiguration`, and specify arguments defined
      # by `./module/eval-config.nix`.
      lib.partitionConfiguration = import ./module/eval-config.nix;
      nixosModules.parnix = import ./module.nix;

      # A very simple example configuration
      # for a standard system with an SSD.
      partitionConfigurations.simple-ssd = self.lib.partitionConfiguration {
        inherit nixpkgs;
        # Because `pkgs` needs instantiation and this configuration
        # is specific to a host, specify the system this config
        # will be used on.
        # This is the default value.
        system = "x86_64-linux";
        # The parnix configuration could be written directly here,
        # however I find it convenient to import as if it were a template.
        config = import ./examples/simple.nix;
        # Then any disk-specific options (or system-specific) can go here,
        # which is specific to the "simple" configuration,
        # which in a real flake would be associated with a host.
        specialArgs.primaryDevice = {
          # This is a configuration for a Western Digital 2 TiB SN770.
          # Normally this would be `/dev/nvme0n1`.
          path = "/dev/sda";
          # Command to get the size in bytes for a drive:
          # `blockdev --getsize64 /dev/sda`
          # Then divide by 1024 to get KiB (kibibytes).
          size = 2000398934016 / 1024;
          # This is a 5% reserved free space at the end of the drive.
          # Good for solid state.
          reservePercent = 5.0e-2;
          # Command to get the mount of physical memory in KiB:
          # `awk '{if ($1 == "MemTotal:") print $2}' /proc/meminfo`
          # Two gibibytes extra is added so that uncompressed hibernation
          # does not fail.
          swapSize = 38735612 + 2 * 1024 * 1024;
        };
      };

      formatter =
        lib.genAttrs systems (system: inputs.nixfmt.packages.${system}.default);
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # birdos.url = "github:spikespaz/dotfiles/master";
    nixfmt.url = "github:serokell/nixfmt";
  };
}
