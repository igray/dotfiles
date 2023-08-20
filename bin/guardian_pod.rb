require 'nokogiri'
require 'open-uri'

CFG='/home/igray/.guardian_pod'
DIR='/home/igray/Pictures/wallpapers'

rss = Nokogiri::XML(URI.open('https://www.theguardian.com/news/series/ten-best-photographs-of-the-day/rss'))
pod_url = rss.xpath('//item/link').first.content
#exit if File.exist?(CFG) && pod_url == open(CFG).read.strip

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

