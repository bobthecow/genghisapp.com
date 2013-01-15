class ChangelogDataSource < Nanoc::DataSource
  identifier :changelog

  CHANGELOG = 'https://raw.github.com/bobthecow/genghis/master/CHANGELOG.markdown'

  def up
    require 'open-uri'
  end

  def items
    items = []
    lines = open(CHANGELOG).read.split(/(?:^|\n\n\n)## (v[\d\.]+)\n\n/)
    lines.shift
    lines.each_slice(2) do |version, changes|
      items << Nanoc::Item.new(
        changes,
        {
          kind:      'changelog',
          version:   version.sub(/^v/, ''),
          is_hidden: true,
        },
        version
      )
    end

    items
  end
end

