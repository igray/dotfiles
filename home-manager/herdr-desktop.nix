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

  prFlowBlock = (pkgs.formats.json { }).generate "herdr-app-pr-flow-block.json" {
    id = "pr-flow";
    type = "block";
    content = {
      mod = "pr-flow";
      props.mine = true;
    };
    size.px = 340;
    min = 260;
    max = 700;
  };

  # Herdr restores its shipped layouts on every start, so changes to main
  # have to live in a layout under another name.
  layout =
    pkgs.runCommand "herdr-app-layout-home.json"
      {
        nativeBuildInputs = [ pkgs.jq ];
      }
      ''
        jq --slurpfile prFlow ${prFlowBlock} '
          .toast = "system-toast"
          | (.. | objects | select(.id == "work-body") | .children) += $prFlow
        ' ${pkgs.herdr-desktop.src}/defaults/layouts/main.json > $out
        jq -e '[.. | objects | select(.id == "pr-flow")] | length == 1' $out > /dev/null
      '';

  settings = (pkgs.formats.json { }).generate "herdr-app-settings.json" {
    sounds.enabled = false;
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
