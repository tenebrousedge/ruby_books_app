require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :db do
  desc 'Run DB migrations'
  task :migrate => :app do
   require 'sequel/extensions/migration'

   Sequel::Migrator.apply(RubyBooks::DB, 'db/migrations')
  end
end
