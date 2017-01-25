# require 'quality/rake/task'
#
# Quality::Rake::Task.new do |t|
#   t.quality_name = 'quality'
#   t.ratchet_name = 'ratchet'
#   t.skip_tools = %w(flog flay cane pep8 jscs eslint)
#   t.verbose = false
#   t.ruby_dirs = %w(app lib test)
#   t.extra_ruby_files = %w('Rakefile')
#   t.exclude_files = ['db/schema.rb']
#   t.ruby_file_extensions_arr = %w(rb rake)
#   t.source_file_extensions_arr =
#     %w(rb rake swift cpp c java py clj cljs scala js yml sh json)
#   t.output_dir = 'metrics'
#   t.punchlist_regexp = 'XXX|TODO'
# end
