{ config, pkgs, ... }:
let
  # OpenWrt router at 192.168.86.1, interface `vpn` (`wg show`).
  serverPublicKey = "17gxiHHbmgBzV0guhu7kjRqp7mahAxfE4I22Fnm05xM=";
  endpoint = "igster.org:51820"; # Cloudflare DDNS name, updated by the router
  # Address assigned to the `wglaptop` peer on the router.
  laptopAddress = "192.168.9.3/24";
  vpnDns = "192.168.9.1"; # router's VPN-side address, so home hostnames resolve
in
{
  # NetworkManager renders the profile from a keyfile with $VARS substituted at
  # activation, so the keys never land in the world-readable nix store.
  sops = {
    defaultSopsFile = ../secrets/laptop.yaml;
    # Decrypted with an age key derived from this host's SSH host key, so the
    # secret is available at boot without a user session (unlike the
    # home-manager sops setup, which needs ~/.config/sops/age/keys.txt).
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      "wireguard/laptop-private-key" = { };
      "wireguard/laptop-preshared-key" = { };
    };

    templates."wireguard-home.env".content = ''
      WG_HOME_PRIVATE_KEY=${config.sops.placeholder."wireguard/laptop-private-key"}
      WG_HOME_PRESHARED_KEY=${config.sops.placeholder."wireguard/laptop-preshared-key"}
    '';
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.templates."wireguard-home.env".path ];

    profiles.home-vpn = {
      connection = {
        id = "home-vpn";
        type = "wireguard";
        interface-name = "wg-home";
        # Roaming laptop: connect on demand from the applet or `nmcli`, rather
        # than tunnelling everything while sitting on the home LAN.
        autoconnect = false;
      };

      wireguard = {
        private-key = "$WG_HOME_PRIVATE_KEY";
        private-key-flags = 0; # store in the profile; don't prompt an agent
      };

      "wireguard-peer.${serverPublicKey}" = {
        inherit endpoint;
        # Full tunnel. NM notices the default route and installs it in its own
        # table with policy rules, keeping the endpoint reachable underneath.
        allowed-ips = "0.0.0.0/0;";
        preshared-key = "$WG_HOME_PRESHARED_KEY";
        preshared-key-flags = 0;
        persistent-keepalive = 25; # hold the NAT mapping open on hotel/cafe wifi
      };

      ipv4 = {
        method = "manual";
        address1 = laptopAddress;
        dns = "${vpnDns};";
        dns-search = "~;"; # claim every domain, so nothing leaks to the local resolver
        dns-priority = -10; # outrank the underlying wifi connection's DNS
      };

      # networking.enableIPv6 = false in nixos/common.nix, and the tunnel would
      # otherwise offer a v6 default route that nothing can use.
      ipv6.method = "disabled";
    };
  };

  environment.systemPackages = with pkgs; [ wireguard-tools ]; # `wg show` for debugging
}
