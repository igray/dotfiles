{ pkgs, ... }:
{
  boot = {
    kernelParams = [ "quiet" ];
    initrd = {
      systemd.enable = true;
    };
    plymouth.enable = true;
  };
  hardware = {
    amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
      amdvlk.enable = true;
    };
    enableRedistributableFirmware = true;
    cpu = {
      amd = {
        updateMicrocode = true;
      };
    };
    graphics = {
      # Hardware Accelerated Video
      enable = true;
      extraPackages = with pkgs; [
        mesa
      ];
    };
    bluetooth = {
      enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };
  services = {
    hardware.bolt.enable = true;
  };
}
