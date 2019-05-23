ENV['RAILS_ENV'] ||= 'test'

require_relative 'spec_helper'
require_relative '../config/environment'

abort if Rails.env.production?

require 'rspec/rails'
require 'sequel/extensions/migration'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before :suite do
    ::Sequel::Migrator.run(::DB, Rails.root.join('db/migrate'))
  end

  config.around :each do |example|
    ::DB.transaction(rollback: :always, auto_savepoint: true, &example)
  end
end
