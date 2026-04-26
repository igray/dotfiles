{ inputs }:
[
  inputs.claude-desktop.overlays.default
  (final: prev: {
    claude-desktop-fhs = final.buildFHSEnv {
      name = "claude-desktop";
      targetPkgs = pkgs: with pkgs; [
        final.claude-desktop
        bubblewrap
        docker
        docker-compose
        glibc
        nodejs
        openssl
        uv
        virtiofsd
      ];
      runScript = "${final.claude-desktop}/bin/claude-desktop";
      extraInstallCommands = ''
        mkdir -p $out/share/applications
        cp ${final.claude-desktop}/share/applications/* $out/share/applications/
        mkdir -p $out/share/icons
        cp -r ${final.claude-desktop}/share/icons/* $out/share/icons/
        substituteInPlace $out/share/applications/claude-desktop.desktop \
          --replace-fail "Exec=claude-desktop" "Exec=$out/bin/claude-desktop"
      '';
      meta = prev.claude-desktop-fhs.meta;
    };
  })
]
