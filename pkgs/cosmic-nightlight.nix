{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  pkg-config,
  libdrm,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-nightlight";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "cosmic-nightlight";
    repo = "cosmic-nightlight";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CbCABZO+5UgdCG5DolJGg5BShRHbWMZfR7jNUnYFAgU=";
  };

  cargoHash = "sha256-0A+KBqEU+brqmtZ1hfwcmRmvuetkVPuO1q5n5P8KGHc=";

  nativeBuildInputs = [
    pkg-config
    libcosmicAppHook
  ];

  buildInputs = [ libdrm ];

  # The GUI only looks for the helper at FHS paths, and the polkit rule in
  # nixos/cosmic-nightlight.nix whitelists this exact store path.
  postPatch = ''
    substituteInPlace crates/cosmic-nightlight/src/backend.rs \
      --replace-fail '"/usr/bin/cosmic-nightlight-helper"' "\"$out/lib/cosmic-nightlight/cosmic-nightlight-helper\""
  '';

  # Kept out of bin/ and libexec/ so libcosmicAppHook doesn't wrap the root helper.
  postInstall = ''
    install -Dm755 -t $out/lib/cosmic-nightlight $out/bin/cosmic-nightlight-helper
    rm $out/bin/cosmic-nightlight-helper
    install -Dm644 -t $out/share/applications data/*.desktop
    install -Dm644 -t $out/share/metainfo data/io.github.cosmic_nightlight.metainfo.xml
    cp -r data/icons $out/share/icons
  '';

  meta = {
    description = "Night light applet for the COSMIC desktop";
    homepage = "https://github.com/cosmic-nightlight/cosmic-nightlight";
    license = lib.licenses.mpl20;
    mainProgram = "cosmic-nightlight";
    platforms = lib.platforms.linux;
  };
})
