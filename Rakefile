require File.expand_path('../config/application', __FILE__)
# require 'dawn/tasks' # Comment this out until dawnscanner gets better

Rails.application.load_tasks

task clear_call_lists: :environment do
  User.all.each(&:clean_call_list_between_shifts)
end

Knapsack.load_tasks if defined?(Knapsack)
