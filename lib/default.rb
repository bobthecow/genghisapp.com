# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

def item_slug(item=nil)
  item ||= @item
  'item-' + item.identifier.gsub(/[^\w]+/, ' ').strip.gsub(' ', '-') unless item.identifier == '/'
end

def screenshots
  @items.select {|i| i.identifier =~ %r{^/screenshots/.} && i[:extension] == 'png' }.sort_by { |i| i.identifier  }
end

def get_genghis_version
  require 'open-uri'
  open('https://raw.github.com/bobthecow/genghis/master/VERSION').read
end

def changes
  @items.select { |i| i.identifier =~ %r{^/changelog/.} }.sort do |a, b|
    Gem::Version.new(b[:version].dup) <=> Gem::Version.new(a[:version].dup)
  end
end

def version_hash(version)
  version.gsub(/[^\w]+/, '_').sub(/^v?/, 'v')
end

def mobile?(item)
  item.identifier.include? '/mobile/'
end
