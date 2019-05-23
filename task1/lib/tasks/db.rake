require 'sequel/extensions/migration'

namespace :db do
  task :seed => [:environment] do
    abort if Rails.env.production?

    Rails.logger.level = :warn
    Rails.application.load_seed
  end

  task :migrate => [:environment] do
    ::Sequel::Migrator.run(::DB, Rails.root.join('db/migrate'))
  end
end
