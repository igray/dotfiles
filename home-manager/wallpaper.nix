{ ... }:

{
  home.file = {
    ".config/wallchange/guardian_pod.rb" = {
      text = ''
        #! /usr/bin/env nix-shell
        #! nix-shell -i ruby -p "ruby.withPackages (ps: with ps; [ nokogiri ])"

        require 'fileutils';
        require 'nokogiri';
        require 'open-uri';
        require 'tmpdir';

        CFG="#{ENV['HOME']}/.local/wallchange/guardian_pod"
        DIR="#{ENV['HOME']}/Pictures/wallpapers"

        rss = Nokogiri::XML(URI.open('https://www.theguardian.com/news/series/ten-best-photographs-of-the-day/rss'))
        pod_url = rss.xpath('//item/link').first.content
        puts "pod_url: #{pod_url}"
        last_url = File.exist?(CFG) ? File.read(CFG).strip : nil
        puts "last_url: #{last_url}"
        exit if pod_url == last_url

        doc = URI.open(pod_url).read
        img_data = {}
        doc.scan(/srcSet="([^"]+)"/)
          .flatten
          .reject { |val| val.include?(',') }
          .each do |fullpath|

          uri = URI.parse(fullpath)
          filename = uri.path.split('/').last
          params = Hash[URI.decode_www_form(uri.query.gsub('&amp;','&'))]
          width = params['width'].to_i
          if img_data.key?(filename) && img_data[filename][:width] > width
            puts "Skipping #{filename} with width #{width}"
            next
          end

          img_data[filename] = {
            fullpath: fullpath.gsub('&amp;', '&'),
            local: "#{DIR}/#{filename}",
            width: width
          }
        end
        puts "Found #{img_data.length} images"
        if img_data.length > 0
          tmp = Dir.mktmpdir('wallchange', File.dirname(DIR))
          img_data.values.each do |d|
            IO.copy_stream(URI.open(d[:fullpath]), File.join(tmp, File.basename(d[:local])))
          end
          Dir.glob("#{DIR}/*").each { |f| File.delete(f) }
          Dir.glob("#{tmp}/*").each { |f| File.rename(f, File.join(DIR, File.basename(f))) }
          Dir.rmdir(tmp)
          FileUtils.mkdir_p(File.dirname(CFG))
          File.write(CFG, "#{pod_url}\n")

          # cosmic-bg 1.6 never re-scans a slideshow dir; rewriting this key makes it reload.
          same = "#{ENV['HOME']}/.config/cosmic/com.system76.CosmicBackground/v1/same-on-all"
          File.write(same, File.read(same)) if File.exist?(same)
        end
      '';
      executable = true;
    };
  };
}
