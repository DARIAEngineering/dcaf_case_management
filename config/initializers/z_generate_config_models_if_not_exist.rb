# Generates backing config objects based on Config::CONFIG_FIELDS
User.current = User.order(created_at: :asc).limit(1).first

Config::CONFIG_FIELDS.map(&:to_s).each do |field|
  if Config.where(config_key: field) != 1
    @a =Config.create config_key: field,
                      config_value: { options: [] }
                      

                      # created_by: @first_user,
                      # modified_by: @first_user
  # @a = Config.find_or_create_by(config_key: field)
  end
  puts @a
  puts @a.valid?
  puts @a.errors.to_s
end

# if Config::CONFIG_FIELDS.count != Config.count
#   puts Config::CONFIG_FIELDS.count
#   puts Config.count
#   raise "Problem with configs! Check and make sure " \
#         "there are config objects for " \
#         "#{Config::CONFIG_FIELDS.to_sentence}."
# end
