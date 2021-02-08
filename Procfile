release: rails db:migrate && rails db:mongoid:create_indexes
web: bundle exec puma -p $PORT -C ./config/puma.rb
