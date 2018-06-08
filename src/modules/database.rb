require 'sequel'

module Bot
  # SQL Database
  module Database
    # Load migrations
    Sequel.extension :migration

    # Connect to database
    DB = Sequel.connect(ENV['DATABASE_URL'] || 'postgres://localhost/ouijabot')

    # Run migrations
    Sequel::Migrator.run(DB, 'src/modules/database/migrations')

    # Load models
    Dir['src/modules/database/*.rb'].each { |mod| load mod }
  end
end
