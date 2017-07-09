desc 'Create stub configs to edit if not yet created'
task generate_configs: :environment do
  raise 'Configs already exist!' if Config.count === Config::CONFIG_KEY.count
  Config.create config_key: :insurance,
                config_value: { options: ['DC Medicaid', 'Other State Medicaid', 'Private or employer-sponsored health insurance']}
  Config.create config_key: :external_pledge_source,
                config_value: { options: ['Baltimore Abortion Fund', 'Carolina Abortion Fund']}
  puts "Configs created! Total configs: #{Config.count}"
end