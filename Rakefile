# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

task clean_call_list: :environment do
  User.all.each(&:clean_call_list_between_shifts)
end
