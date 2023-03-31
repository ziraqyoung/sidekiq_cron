# Load the required packages
#

require 'yaml'
require 'sidekiq'
require 'sidekiq-cron'

Dir['lib/**/*.rb'].each { |file| require_relative file }

# Load schedule file & instruct Sidekiq that we want to
# setup a Cron Job
schedule_file = './config/schedule.yml'
Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
