{ pkgs, ... }:

let
  colors = import ./colors.nix;
in
{
  home.packages = [ pkgs.libnotify ];                   # Dependency
  services.dunst = {
    enable = true;
    iconTheme = {                                       # Icons
      name = "Papirus Dark";
      package = pkgs.papirus-icon-theme;
      size = "16x16";
    };
    settings = with colors.scheme.solarized; {               # Settings
      global = {
        monitor = 0;
        # geometry [{width}x{height}][+/-{x}+/-{y}]
        # geometry = "600x50-50+65";
        width = 500;
        # height = 200;
        origin = "top-right";
        offset = "20x20";
        shrink = "yes";
        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        # transparency = 10;
        padding = 10;
        horizontal_padding = 10;
        frame_width = 0;
        frame_color = "#${bg}";
        separator_color = "frame";
        font = "Cantarell 12";
        corner_radius = 5;
        line_height = 0;
        idle_threshold = 120;
        markup = "full";
        format = ''<b>%s</b>\n%b'';
        alignment = "left";
        vertical_alignment = "center";
        icon_position = "left";
        word_wrap = "yes";
        ignore_newline = "no";
        show_indicators = "yes";
        sort = true;
        stack_duplicates = true;
        # startup_notification = false;
        hide_duplicate_count = true;
        browser = "${pkgs.firefox}/bin/firefox --new-tab";
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
      urgency_low = {                                   # Colors
        background = "#${bg}";
        foreground = "#${text}";
        timeout = 12;
      };
      urgency_normal = {
        background = "#${bg}";
        foreground = "#${text}";
        timeout = 12;
      };
      urgency_critical = {
        background = "#${bg}";
        foreground = "#${text}";
        frame_color = "#${red}";
        timeout = 12;
      };
    };
  };
  xdg.dataFile."dbus-1/services/org.knopwob.dunst.service".source = "${pkgs.dunst}/share/dbus-1/services/org.knopwob.dunst.service";
}
