desc 'Mass-set patient identifiers if there is a change to how ids are calculated'
task set_identifiers: :environment do
  User.all.each do |user|
    user.save_identifier
    user.save
  end
end
