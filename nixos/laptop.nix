{ pkgs, ... }:
{
  boot = {
    kernelParams = [ "quiet" ];
    initrd = {
      kernelModules = [ "amdgpu" ];        # Video Drivers
      systemd.enable = true;
    };
    plymouth.enable = true;
  };
  hardware = {
    enableRedistributableFirmware = true;
    cpu = {
      amd = {
        updateMicrocode = true;
      };
    };
    opengl = {                                  # Hardware Accelerated Video
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
        mesa.drivers
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
    blueman.enable = true;
  };
}
