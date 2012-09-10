usage       'update-screenshots'
summary     'Create a new set of screenshots'
description 'Replaces the current screenshots with new ones.'

run do |opts, args|

  # remove the old ones first
  FileUtils.rm Dir.glob('content/screenshots/*.png')
  FileUtils.rm Dir.glob('content/screenshots/mobile/*.png')
  FileUtils.rm Dir.glob('content/screenshots/*.gif')

  i = 0
  screenshots = YAML.load(File.read('screenshots.yaml'))

  # do the desktop screenshots

  screenshot_defaults = %w{webkit2png --clipped --width=800 --height=600 --scale=1 --clipwidth=800 --clipheight=600 --dir=./content/screenshots}
  screenshots['screenshots'].each do |batch|
    i += 1

    args = screenshot_defaults.clone
    js   = batch['before'].nil? ? '' : batch['before'].gsub(/\n\s*/, ' ')

    unless js.empty?
      args << "--delay=#{batch['delay'] || 1}"
      args << '--js'
      args << js
    end

    args << "-o#{i}"
    args << batch['url']

    # once before any actions...
    # puts args.join " "
    system(*args)

    unless batch['actions'].nil?
      batch['actions'].each do |action|
        i += 1

        args = screenshot_defaults.clone
        args << "--delay=#{batch['delay'] || 1}"
        args << '--js'
        args << js + ';' + action
        args << "-o#{i}"
        args << batch['url']

        # puts args.join " "
        system(*args)
      end
    end
  end

  # and the mobile screenshots

  mobile_defaults = %w{webkit2png --clipped --width=460 --height=660 --scale=1 --clipwidth=460 --clipheight=660 --dir=./content/screenshots/mobile}
  screenshots['mobile'].each do |batch|
    i += 1

    args = mobile_defaults.clone
    js   = batch['before'].nil? ? '' : batch['before'].gsub(/\n\s*/, ' ')

    unless js.empty?
      args << "--delay=#{batch['delay'] || 1}"
      args << '--js'
      args << js
    end

    args << "-o#{i}"
    args << batch['url']

    # once before any actions...
    # puts args.join " "
    system(*args)

    unless batch['actions'].nil?
      batch['actions'].each do |action|
        i += 1

        args = mobile_defaults.clone
        args << "--delay=#{batch['delay'] || 1}"
        args << '--js'
        args << js + ';' + action
        args << "-o #{i}"
        args << batch['url']

        # puts args.join " "
        system(*args)
      end
    end
  end

  # and now clean up all the stupid names :)
  Dir.glob('content/screenshots/**/*.png').each do |file|
    FileUtils.mv file, file.sub('-clipped.', '.')
  end

  system(*%w{convert -resize 400x300 +dither -posterize 256 -delay 100 -loop 0 content/screenshots/*.png content/screenshots/screenshots.gif})
  system(*%w{convert -posterize 256 -delay 100 -loop 0 content/screenshots/mobile/*.png content/screenshots/mobile.gif})
end