{ pkgs, ... }:
let
  lan = "192.168.86.0/24";
  nfsOptions = "rw,sync,all_squash,anonuid=1000,anongid=1001,insecure,no_subtree_check";
in
{
  services.samba = {
    enable = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "Samba Server";
        "server role" = "standalone server";
        "hosts allow" = "192.168.86. 127.";
        "dns proxy" = "no";
      };
      media = {
        comment = "Media";
        path = "/media/media";
        public = "yes";
        writable = "no";
      };
    };
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /media/media/movies      ${lan}(${nfsOptions})
      /media/media/television  ${lan}(${nfsOptions})
      /media/media/incoming    ${lan}(${nfsOptions})
      /home/igray              ${lan}(rw,sync,no_subtree_check)
    '';
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
    listenAddresses = [ "*:631" ];
    allowFrom = [
      "localhost"
      "192.168.86.*"
    ];
    browsing = true;
    defaultShared = true;
  };

  hardware.printers.ensurePrinters = [
    {
      name = "officejet_5740";
      description = "HP Officejet 5740";
      deviceUri = "usb://HP/Officejet%205740%20series?serial=TH52Q331D205ZF&interface=1";
      model = "drv:///hp/hpcups.drv/hp-officejet_5740_series.ppd";
    }
  ];
}
