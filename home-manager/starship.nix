{ lib, ... }:
let
  lang = icon: {
    symbol = icon;
    format = "[$symbol ]($style)";
  };
in
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      status = {
        symbol = "✗";
        not_found_symbol = "󰍉 Not Found";
        not_executable_symbol = " Can't Execute E";
        sigint_symbol = "󰂭 ";
        signal_symbol = "󱑽 ";
        success_symbol = "";
        format = "[$symbol](fg:red)";
        map_symbol = true;
        disabled = false;
      };
      cmd_duration = {
        min_time = 1000;
        format = "[$duration ](fg:yellow)";
      };
      character = {
        success_symbol = "[❯](bold purple)";
        error_symbol = "[❯](bold red)";
      };
      nix_shell = {
        disabled = false;
        format = "[](fg:white)[ ](bg:white fg:black)[](fg:white) ";
        symbol = " ";
      };
      container = {
        symbol = " 󰏖";
        format = "[$symbol ](yellow dimmed)";
      };
      directory = {
        format = " [](fg:bright-black)[$path](bg:bright-black fg:white)[](fg:bright-black)";
        truncation_length = 4;
        truncation_symbol = "~/…/";
        read_only = " 󰌾";
      };
      directory.substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = " ";
        "Music" = " ";
        "Pictures" = " ";
        "Videos" = " ";
        "Work" = "󱌢 ";
        "GitHub" = "";
        ".config" = " ";
      };
      git_branch = {
        symbol = " ";
        style = "";
        format = "[ $symbol $branch](fg:purple)(:$remote_branch)";
      };
      os = {
        disabled = true;
      };
      hostname.ssh_symbol = " ";
      aws = {
        disabled = true;
        symbol = " ";
        format = "[$symbol]($style)";
      };
      buf = lang " ";
      c = lang " ";
      conda = lang " ";
      dart = lang " ";
      docker_context = lang " ";
      elixir = lang " ";
      elm = lang " ";
      fossil_branch = lang " ";
      golang = lang " ";
      guix_shell = lang " ";
      haskell = lang " ";
      haxe = lang " ";
      hg_branch = lang " ";
      java = lang " ";
      julia = lang " ";
      lua = lang " ";
      memory_usage = lang "󰍛 ";
      meson = lang "󰔷 ";
      nim = lang "󰆥 ";
      nodejs = lang " ";
      package = lang "󰏗 ";
      pijul_channel = lang " ";
      python = lang " ";
      rlang = lang "󰟔 ";
      ruby = lang " ";
      rust = lang " ";
      scala = lang " ";
    };
  };
}
