namespace :db do
  namespace :seed do
    desc 'Generate 20 training accounts - training-account-n@test.com'
    task :training => :environment do
      fail 'No running seeds in prod' unless [nil, 'Sandbox'].include? ENV['DARIA_FUND']

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