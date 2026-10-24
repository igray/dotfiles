{ pkgs, ... }:
let
  cosmic-nightlight = pkgs.callPackage ../pkgs/cosmic-nightlight.nix { };
  helper = "${cosmic-nightlight}/lib/cosmic-nightlight/cosmic-nightlight-helper";
in
{
  environment.systemPackages = [ cosmic-nightlight ];

  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (
        action.id == "org.freedesktop.policykit.exec" &&
        action.lookup("program") == "${helper}" &&
        subject.isInGroup("wheel")
      ) {
        return polkit.Result.YES;
      }
    });
  '';
}
