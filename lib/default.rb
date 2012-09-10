# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

def item_slug(item=nil)
  item ||= @item
  'item-' + item.identifier.gsub(/[^\w]+/, ' ').strip.gsub(' ', '-') unless item.identifier == '/'
end

def screenshots
  @items.select {|i| i.identifier =~ /^\/screenshots\/./ && i[:extension] == 'png' }
end