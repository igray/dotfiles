set -g VISUAL nvim
set -g EDITOR nvim
starship init fish | source
if test -e '/home/igray/.nix-profile/etc/profile.d/nix.sh'
  fenv source '/home/igray/.nix-profile/etc/profile.d/nix.sh'
end

