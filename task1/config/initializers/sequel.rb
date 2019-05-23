require 'sequel'

::DB = Sequel.connect(
  Rails.env.production? ? ENV.fetch('POSTGRES_URL') : "postgres://localhost/umbrellio-task1-#{Rails.env}",
  loggers: [Rails.logger]
)

DB.extension :pg_array
DB.register_array_type('inet')
