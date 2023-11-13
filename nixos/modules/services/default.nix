#
#  Services
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix
#   └─ ./modules
#       └─ ./services
#           └─ default.nix *
#               └─ ...
#

[
  ./avahi.nix
  ./docker.nix
  ./dunst.nix
  ./keyring.nix
  ./flameshot.nix
  ./picom.nix
  ./polybar.nix
# ./samba.nix
  ./sxhkd.nix
  ./udiskie.nix
]

