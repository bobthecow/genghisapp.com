usage       'ruin-my-database [options]'
summary     'DANGER: deletes all your data.'
description 'Deletes all your data and replaces it with fake stuff. Seriously, don\'t use this.'

flag :y, :yes, 'confirm destruction'
flag nil, :'delete-all-the-things', 'really, do this'


run do |opts, args|
  $stderr.puts '*************'
  $stderr.puts '** WARNING **'
  $stderr.puts '*************'
  $stderr.puts

  unless opts.has_key?(:yes)
    $stderr.puts 'This will definitely mess up your Mongo database. You shouldn\' run it.'
    $stderr.puts
    $stderr.puts 'To continue, you have to add a `--yes` flag.'
    exit 1
  end

  require 'mongo'
  conn = Mongo::Connection.new
  dbs  = conn.database_names

  unless opts.has_key?(:'delete-all-the-things')
    size = (conn.database_info.values.inject{|sum,x| sum + x } / (1024 * 1024).to_f).ceil

    $stderr.puts "You have #{dbs.length} Mongo databases — " + dbs.join(', ') +
                 " — taking up about #{size} MB of disk space. "
    $stderr.puts 'If you continue, this will all be destroyed. To confirm that you really, '
    $stderr.puts 'really are okay with this, you\'ll need to supply one more flag: '
    $stderr.puts
    $stderr.puts '`--delete-all-the-things`.'
    $stderr.puts
    exit 1
  end

  $stderr.puts "In 10 seconds, we will delete #{dbs.length} databases — " + dbs.join(', ')
  $stderr.puts 'Hit ctrl+c to abort.'
  $stderr.puts

  sleep 10

  $stderr.puts 'Hokey then.'
  $stderr.puts 'Don\'t say I didn\'t warn you.'
  $stderr.puts

  dbs.each do |name|
    sleep 1
    $stderr.puts '  Deleting ' + name
    conn.drop_database name
  end

  $stderr.puts
  $stderr.puts 'Now let\'s fill \'em back up with fake data!'
  $stderr.puts

  require 'faker'

  buzz      = Faker::Company.buzzwords
  now       = Time.now
  last_year = now - (60 * 60 * 24 * 365)
  5.times do
    name = "#{buzz.sample} #{buzz.sample}".gsub(/[^a-zA-Z0-9]/, '_').downcase
    db = conn[name]
    (rand(10)+5).times do
      name = buzz.sample.gsub(/[^a-zA-Z0-9]/, '_').downcase
      $stderr.puts "  Creating #{name}"
      coll = db[name]

      doc_count = rand(450)+50
      $stderr.puts "    Adding #{doc_count} documents"

      keys = Faker::Lorem.words(rand(10) + 5)
      doc_count.times do
        doc = {}

        # Pre-fill a few "user profile" type things...
        5.times do
          case rand(20)
            when 1 then doc['name']     = Faker::Name.name
            when 2 then doc['phone']    = Faker::PhoneNumber.phone_number
            when 3 then doc['email']    = Faker::Internet.safe_email
            when 4 then doc['username'] = Faker::Internet.user_name
            when 5 then doc['website']  = Faker::Internet.domain_name
            when 6 then doc['twitter']  = "@#{Faker::Internet.user_name}"
          end
        end

        # Then fill it up with garbage
        keys.each do |key|
          doc[key] = case rand(10)
            when 1 then Faker::Lorem.paragraphs.join "\n\n"
            when 2 then rand(100000)
            when 3 then (1..rand(5)).map {|i| (rand * rand(1000)).round(2) }
            when 4 then Time.at(rand(last_year..now))
            else Faker::Lorem.words(1).first
          end
        end
        coll.insert(doc)
      end
    end
  end


  $stderr.puts
  $stderr.puts 'It is finished.'
end
