require File.expand_path('../config/application', __FILE__)
# require 'dawn/tasks' # Comment this out until dawnscanner gets better

Rails.application.load_tasks

task clear_call_lists: :environment do
  User.all.each(&:clear_call_list)
end

Rake::Task['test:run'].clear
Rake::Task['test:integration'].clear
# Uncomment when throttling tests go live
# Rake::Task['test:middleware'].clear

namespace :test do
  Rails::TestTask.new(:limited) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb'].exclude(
      'test/integration/**/*_test.rb'
      )
  end

  Rails::TestTask.new(:everything) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/**/*_test.rb']
  end

  Rails::TestTask.new('integration' => 'test:prepare') do |t|
    t.libs << 'test'
    t.pattern = 'test/integration/**/*_test.rb'
  end

  # Allows for middleware to be tested separately
  #Rails::TestTask.new('middleware' => 'test:prepare') do |t|
    #t.libs << 'test'
    #t.pattern = 'test/middleware/**/*_test.rb'
  #end

  task :run => ['test:limited', 'test:integration']
end
