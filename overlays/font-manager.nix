{ inputs }:
[
  # font-manager 0.9.4 fails to build against vala >= 0.56.19, whose gtk4.vapi
  # declares Gtk.DragIcon.get_for_drag as a creation method:
  #   error: use `new' operator to create new objects
  # Fixed upstream in FontManager/font-manager#468 and already carried by
  # nixpkgs master; drop this once our nixpkgs pin includes it.
  (final: prev: {
    font-manager = prev.font-manager.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./patches/font-manager-fix-newer-vala.patch
      ];
    });
  })
]
