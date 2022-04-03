require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task clean_call_list: :environment do
  User.all.each(&:clean_call_list_between_shifts)
end

Knapsack.load_tasks if defined?(Knapsack)
