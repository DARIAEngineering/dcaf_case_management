# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'quality/rake/task'

Rails.application.load_tasks

Quality::Rake::Task.new do |t|
  t.quality_name = 'quality'
  t.ratchet_name = 'ratchet'
  t.skip_tools = []
  t.verbose = false
  t.ruby_dirs = %w(app lib test)
  t.extra_ruby_files = %w('Rakefile')
  t.exclude_files = ['db/schema.rb']
  t.ruby_file_extensions_arr = %w(rb rake)
  t.source_file_extensions_arr =
    %w(rb rake swift cpp c java py clj cljs scala js yml sh json)
  t.output_dir = 'metrics'
  t.punchlist_regexp = 'XXX|TODO'
end
