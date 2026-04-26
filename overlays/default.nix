{ inputs }:
builtins.concatLists [
  (import ./claude-code.nix { inherit inputs; })
  (import ./claude-desktop.nix { inherit inputs; })
]
