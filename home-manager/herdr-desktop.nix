{
  config,
  lib,
  pkgs,
  ...
}:
let
  appHome = "herdr-app";
  checkout = "${config.home.homeDirectory}/Work/dotfiles/home-manager/herdr-app";

  names = dir: type: lib.attrNames (lib.filterAttrs (_: t: t == type) (builtins.readDir dir));

  # Mods link to the checkout, not the store: Herdr hot-reloads on save and
  # writes jsconfig.json into each mod folder.
  mods = lib.genAttrs' (names ./herdr-app/mods "directory") (
    name:
    lib.nameValuePair "${appHome}/mods/${name}" {
      source = config.lib.file.mkOutOfStoreSymlink "${checkout}/mods/${name}";
    }
  );

  themes = lib.genAttrs' (names ./herdr-app/themes "regular") (
    name:
    lib.nameValuePair "${appHome}/themes/${name}" {
      source = ./herdr-app/themes/${name};
    }
  );

  # Herdr has no weight setting and asks a family for 400 and 700, so the faces
  # Ghostty uses are re-registered at those weights under their own family.
  terminalFont = "JetBrainsMono Herdr";
  ghosttyStyle = key: lib.head (lib.toList config.programs.ghostty.settings.${key});
  faces = {
    "Regular" = ghosttyStyle "font-style";
    "Bold" = ghosttyStyle "font-style-bold";
    "Italic" = ghosttyStyle "font-style-italic";
    "Bold Italic" = ghosttyStyle "font-style-bold-italic";
  };

  retagFont = pkgs.writeText "retag-font.py" ''
    import sys
    from fontTools.ttLib import TTFont

    src, dst, family, style = sys.argv[1:5]
    bold = "Bold" in style
    italic = "Italic" in style
    names = {
        1: family,
        2: style,
        4: f"{family} {style}",
        6: f"{family}-{style}".replace(" ", ""),
        16: family,
        17: style,
    }
    font = TTFont(src)
    for record in list(font["name"].names):
        if record.nameID in names:
            record.string = names[record.nameID]
    os2 = font["OS/2"]
    os2.usWeightClass = 700 if bold else 400
    os2.fsSelection = (os2.fsSelection & ~0x61) | (
        (0x20 if bold else 0) | (0x01 if italic else 0) or 0x40
    )
    font["head"].macStyle = (1 if bold else 0) | (2 if italic else 0)
    font.save(dst)
  '';

  terminalFonts =
    pkgs.runCommand "herdr-app-terminal-fonts"
      {
        nativeBuildInputs = [ (pkgs.python3.withPackages (ps: [ ps.fonttools ])) ];
      }
      (
        "mkdir $out\n"
        + lib.concatStrings (
          lib.mapAttrsToList (style: source: ''
            python3 ${retagFont} \
              ${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFont-${
                lib.replaceStrings [ " " ] [ "" ] source
              }.ttf \
              "$out/${lib.replaceStrings [ " " ] [ "" ] style}.ttf" ${lib.escapeShellArgs [
                terminalFont
                style
              ]}
          '') faces
        )
      );

  fonts = lib.genAttrs' (lib.attrNames faces) (
    style:
    let
      file = "${lib.replaceStrings [ " " ] [ "" ] style}.ttf";
    in
    lib.nameValuePair "${appHome}/fonts/${file}" { source = "${terminalFonts}/${file}"; }
  );

  # deploy-watch reveals this column and selects its tab by these ids.
  insightsColumn = (pkgs.formats.json { }).generate "herdr-app-insights-column.json" {
    id = "insights";
    type = "column";
    size.px = 380;
    min = 280;
    max = 900;
    children = [
      {
        id = "insights-tabs";
        type = "stack";
        header.content = "tabs";
        active = "reviews";
        children = [
          {
            id = "reviews";
            title = "Reviews";
            type = "block";
            content.mod = "pr-reviews";
          }
          {
            id = "deploy";
            title = "Deploy";
            type = "block";
            content.mod = "deploy-watch";
          }
          {
            id = "wh-plan";
            title = "WH Plan";
            type = "block";
            content.mod = "wh-plan";
          }
        ];
      }
    ];
  };

  # Herdr restores its shipped layouts on every start, so changes to main
  # have to live in a layout under another name.
  layout =
    pkgs.runCommand "herdr-app-layout-home.json"
      {
        nativeBuildInputs = [ pkgs.jq ];
      }
      ''
        jq --slurpfile insights ${insightsColumn} '
          .toast = "system-toast"
          | (.. | objects | select(.id == "work-body") | .children) += $insights
        ' ${pkgs.herdr-desktop.src}/defaults/layouts/main.json > $out
        jq -e '[.. | objects | select(.id == "insights")] | length == 1' $out > /dev/null
      '';

  settings = (pkgs.formats.json { }).generate "herdr-app-settings.json" {
    sounds.enabled = false;
    font = terminalFont;
    font_size = 14.2;
    theme = {
      dark = "solarized-dark";
      light = "solarized-light";
    };
  };
in
{
  home.packages = [ pkgs.herdr-desktop ];

  xdg.configFile =
    mods
    // themes
    // fonts
    // {
      "${appHome}/layouts/home.json".source = layout;
    };

  home.activation.herdrAppSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] (
    lib.hm.generators.mkImpureConfigMerger {
      inherit pkgs;
      format = "json";
      empty = "{}";
      jqOperation = "$dynamic * $static";
      path = "${config.xdg.configHome}/${appHome}/settings.json";
      staticSettings = settings;
    }
  );
}
