namespace :solid do
  desc "Create and migrate Solid Cache and Solid Cable databases"
  task setup: :environment do
    %w[cache cable queue].each do |db_name|
      puts "Setting up solid_#{db_name} database..."
      config = ActiveRecord::Base.configurations.configs_for(
        env_name: Rails.env, name: db_name
      )
      next unless config

      begin
        ActiveRecord::Tasks::DatabaseTasks.create(config)
        puts "  Created #{db_name} database"
      rescue ActiveRecord::DatabaseAlreadyExists
        puts "  #{db_name} database already exists"
      end

      begin
        ActiveRecord::Tasks::DatabaseTasks.migrate(config)
        puts "  Migrated #{db_name} database"
      rescue => e
        # If no migrations exist, load schema directly
        schema_file = Rails.root.join("db", "#{db_name}_schema.rb")
        if schema_file.exist?
          ActiveRecord::Schema.verbose = false
          ActiveRecord::Base.establish_connection(config)
          load(schema_file)
          puts "  Loaded #{db_name} schema"
        else
          puts "  Warning: Could not set up #{db_name}: #{e.message}"
        end
      end
    end

    # Reconnect to primary database
    ActiveRecord::Base.establish_connection(
      ActiveRecord::Base.configurations.configs_for(
        env_name: Rails.env, name: "primary"
      )
    )
    puts "Solid infrastructure setup complete!"
  end
end
