#Let's do this: rake db:seed:training should create 20 accounts as follows:

#email: training-account-#{i}@test.com
#password: P4ssword
#password_confirmation: P4ssword
#name: Training Account #{i}

namespace :db do
  namespace :seed do
    task :training => :environment do
      # Create two test users
      20.times do |i|
        User.create! name: "Training Account #{i}",
                     email: "training-account-#{i}@test.com",
                     password: "P4ssword",
                     password_confirmation: "P4ssword"
      end 
    end
  end
end