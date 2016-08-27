require File.expand_path('../config/application', __FILE__)
# require 'dawn/tasks' # Comment this out until dawnscanner gets better

Rails.application.load_tasks

task clear_call_lists: :environment do
  User.all.each(&:clear_call_list)
end
