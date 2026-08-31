{ inputs }:
builtins.concatLists [
  (import ./claude-code.nix { inherit inputs; })
  (import ./claude-desktop.nix { inherit inputs; })
  (import ./font-manager.nix { inherit inputs; })
]
