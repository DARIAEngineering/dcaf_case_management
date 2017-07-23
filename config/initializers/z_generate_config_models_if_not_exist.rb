# Generates backing config objects based on Config::CONFIG_FIELDS
puts 'Confirming fund config fields exist...'

Config::CONFIG_FIELDS.map(&:to_s).each do |field|
  if Config.where(config_key: field).count != 1
    puts "Creating config for #{field}..."
    Config.create config_key: field,
                  config_value: { options: [] }
  end
end

if Config::CONFIG_FIELDS.count != Config.count
  puts Config::CONFIG_FIELDS.count
  puts Config.count
  raise "Problem with configs! Check and make sure " \
        "there are config objects for " \
        "#{Config::CONFIG_FIELDS.uniq.to_sentence}."
end

puts 'Confirmed fund config fields exist!'
