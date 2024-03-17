{ ... }:

{
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
        if [ ! -d "$image_path" ]; then
          image_path="$HOME/Pictures/wallpapers"
        fi

        local_dir="$HOME/.local/wallchange"
        mkdir -p $local_dir
        pic=$(find $image_path -regextype posix-extended -regex "(.*\.jpg)|(.*\.png)"|shuf -n1)
        #echo $pic

        local_wallpaper=$local_dir/mywallpaper.jpg
        cp "$pic" $local_wallpaper
        hyprctl hyprpaper unload "$local_wallpaper"
        hyprctl hyprpaper preload "$local_wallpaper"
        for mon in $(hyprctl monitors | grep Monitor | /run/current-system/sw/bin/awk -e '{ print $2; }'); do
          hyprctl hyprpaper wallpaper "$mon,$local_wallpaper"
        done
      '';
      executable = true;
    };
  };
}
