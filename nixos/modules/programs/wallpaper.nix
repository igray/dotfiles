
{ config, lib, pkgs, vars, ... }:

{
  config = {
    systemd = {
      user = {
        services = {
          guardian = {
            wantedBy = [ "default.target" ];
            path = [ pkgs.nix ];
            script = "/home/${vars.user}/.config/wallchange/guardian_pod.rb";
            description = "update wallpapers";
          };
          wallchange = {
            wantedBy = [ "default.target" ];
            path = [ pkgs.nix pkgs.bash pkgs.hyprland ];
            script = "/home/${vars.user}/.config/wallchange/wallchange.sh";
            description = "change the wallpaper";
          };
        };
        timers = {
          guardian = {
            enable = true;
            wantedBy = [ "timers.target" ];
            description = "daily wallpaper update";
            timerConfig = {
              OnCalendar = "*-*-* 00/2:35";
              Persistent = true;
            };
          };
          wallchange = {
            enable = true;
            wantedBy = [ "timers.target" ];
            description = "hourly wallpaper change";
            timerConfig = {
              OnCalendar = "*-*-* *:50:00";
              Persistent = true;
            };
          };
        };
      };
    };

    home-manager.users.${vars.user} = {
      home.file = {
        ".config/wallchange/guardian_pod.rb" = {
          text = ''
            #! /usr/bin/env nix-shell
            #! nix-shell -i ruby -p "ruby.withPackages (ps: with ps; [ nokogiri ])"

            require 'nokogiri';
            require 'open-uri';

            CFG="#{ENV['HOME']}/.local/wallchange/guardian_pod"
            DIR="#{ENV['HOME']}/Pictures/wallpapers"

            rss = Nokogiri::XML(URI.open('https://www.theguardian.com/news/series/ten-best-photographs-of-the-day/rss'))
            pod_url = rss.xpath('//item/link').first.content
            exit if File.exist?(CFG) && pod_url == open(CFG).read.strip

            doc = URI.open(pod_url).read
            img_data = {}
            doc.scan(/srcset="([^"]+)"/)
              .flatten
              .reject { |val| val.include?(',') }
              .each do |srcpair|
              fullpath, rawwidth = srcpair.split(' ')
              filename = URI.parse(fullpath).path.split('/').last
              width = rawwidth.to_i
              next if img_data.key?(filename) && img_data[filename][:width] > width

              img_data[filename] = {
                fullpath: fullpath.gsub('&amp;', '&'),
                local: "#{DIR}/#{filename}",
                width: width
              }
            end
            if img_data.length > 0
              `rm -f #{DIR}/*`
              img_data.values.each do |d|
                IO.copy_stream(URI.open(d[:fullpath]), d[:local])
              end
              open(CFG, 'w') { |io| io.puts pod_url }
            end
          '';
          executable = true;
        };
        ".config/wallchange/wallchange.sh" = {
          text = ''
            #!/usr/bin/env bash
            image_path=$1
            #Setting up a path for local storage

            if [ ! -d "$image_path" ]; then
              image_path="$HOME/Pictures/wallpapers"
            fi
            local_dir="$HOME/.local/wallchange"
            #creating local directory
            mkdir -p $local_dir
            #getting name of the picture
            pic=$(find $image_path -regextype posix-extended -regex "(.*\.jpg)|(.*\.png)"|shuf -n1)
            #echo $pic

            #Storing image in local_dir
            local_wallpaper=$local_dir/mywallpaper.jpg
            #setting the wallpaper
            cp "$pic" $local_wallpaper
            #echo $local_wallpaper
            #Adding bogus wallpaper (don't know if this is a gsettings bug or i'm doing some basic flaw)
            #gsettings set org.gnome.desktop.background picture-uri file:/$local_wallpaper
            #try increasing the sleep if wallpaper doesn't change
            sleep 1;
            #gsettings set org.gnome.desktop.background picture-uri-dark file://$local_wallpaper
            hyprctl hyprpaper unload "$local_wallpaper"
            hyprctl hyprpaper preload "$local_wallpaper"
            hyprctl hyprpaper wallpaper "DP-2,$local_wallpaper"
            hyprctl hyprpaper wallpaper "DP-5,$local_wallpaper"
            hyprctl hyprpaper wallpaper "DP-7,$local_wallpaper"
            hyprctl hyprpaper wallpaper "eDP-1,$local_wallpaper"
          '';
          executable = true;
        };
      };
    };
  };
}
