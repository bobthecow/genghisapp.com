# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

def item_slug(item=nil)
  item ||= @item
  'item-' + item.identifier.gsub(/[^\w]+/, ' ').strip.gsub(' ', '-')
end