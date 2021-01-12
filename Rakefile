# frozen_string_literal: true

desc 'Run application console (pry)'
task :console do
  sh 'pry -r ./init.rb'
end

USERNAME = 'ruuubaih2020soa'
IMAGE = 'ewa-search_worker'
VERSION = '0.1.0'

desc 'Build Docker image'
task :worker do
  require_relative './init'
  Ewa::SearchWorker.new.call
end

# Docker tasks
namespace :docker do
  desc 'Build Docker image'
  task :build do
    puts "\nBUILDING WORKER IMAGE"
    sh "docker build --force-rm -t #{USERNAME}/#{IMAGE}:#{VERSION} ."
  end

  desc 'Run the local Docker container as a worker'
  task :run do
    env = ENV['WORKER_ENV'] || 'development'

    puts "\nRUNNING WORKER WITH LOCAL CONTEXT"
    puts " Running in #{env} mode"

    sh 'docker run -e WORKER_ENV -v $(pwd)/config:/worker/config -v $(pwd)/worker/database/local:/worker/database/local --rm -it ' \
       "#{USERNAME}/#{IMAGE}:#{VERSION}"
  end

  desc 'Remove exited containers'
  task :rm do
    sh 'docker rm -v $(docker ps -a -q -f status=exited)'
  end

  desc 'List all containers, running and exited'
  task :ps do
    sh 'docker ps -a'
  end

  # desc 'Push Docker image to Docker Hub'
  # task :push do
  #   puts "\nPUSHING IMAGE TO DOCKER HUB"
  #   sh "docker push #{USERNAME}/#{IMAGE}:#{VERSION}"
  # end
end

# Heroku container registry tasks
namespace :heroku do
  desc 'Build and Push Docker image to Heroku Container Registry'
  task :push do
    puts "\nBUILDING + PUSHING IMAGE TO HEROKU"
    sh 'heroku container:push worker'
  end

  desc 'Run worker on Heroku'
  task :run do
    puts "\nRUNNING CONTAINER ON HEROKU"
    sh 'heroku run rake worker'
  end
end

namespace :search_queues do
  task :config do
    require 'aws-sdk-sqs'
    require_relative 'config/environment' # load config info
    @api = Ewa::App

    @sqs = Aws::SQS::Client.new(
      access_key_id: @api.config.AWS_ACCESS_KEY_ID,
      secret_access_key: @api.config.AWS_SECRET_ACCESS_KEY,
      region: @api.config.AWS_REGION
    )
  end

  desc 'Create SQS queue for worker'
  task :create => :config do
    puts "Environment: #{@api.environment}"
    @sqs.create_queue(queue_name: @api.config.SEARCH_QUEUE)

    q_url = @sqs.get_queue_url(queue_name: @api.config.SEARCH_QUEUE).queue_url
    puts 'Queue created:'
    puts "  Name: #{@api.config.SEARCH_QUEUE}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{q_url}"
  rescue StandardError => e
    puts "Error creating queue: #{e}"
  end

  desc 'Report status of queue for worker'
  task :status => :config do
    q_url = @sqs.get_queue_url(queue_name: @api.config.SEARCH_QUEUE).queue_url

    puts "Environment: #{@api.environment}"
    puts 'Queue info:'
    puts "  Name: #{@api.config.SEARCH_QUEUE}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{q_url}"
  rescue StandardError => e
    puts "Error finding queue: #{e}"
  end

  desc 'Purge messages in SQS queue for worker'
  task :purge => :config do
    q_url = @sqs.get_queue_url(queue_name: @api.config.SEARCH_QUEUE).queue_url
    @sqs.purge_queue(queue_url: q_url)
    puts "Queue #{queue_name} purged"
  rescue StandardError => e
    puts "Error purging queue: #{e}"
  end
end

namespace :search_worker do
  namespace :run do
    desc 'Run the background searching worker in development mode'
    task :dev => :config do
      sh 'RACK_ENV=development bundle exec shoryuken -r ./workers/search_worker.rb -C ./workers/shoryuken_dev.yml'
    end

    desc 'Run the background searching worker in testing mode'
    task :test => :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/search_worker.rb -C ./workers/shoryuken_test.yml'
    end

    desc 'Run the background searching worker in production mode'
    task :production => :config do
      sh 'RACK_ENV=production bundle exec shoryuken -r ./workers/search_worker.rb -C ./workers/shoryuken.yml'
    end
  end
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info

    def worker
      Ewa::SearchWorker
    end
  end

  desc 'Run migrations'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{worker.environment} database to latest"
    Sequel::Migrator.run(worker.DB, 'worker/infrastructure/database/migrations')
  end

  desc 'Delete dev or test database file'
  task drop: :config do
    if worker.environment == :production
      puts 'Cannot remove production database!'
      return
    end

    FileUtils.rm(Ewa::SearchWorker.config.DB_FILENAME)
    puts "Deleted #{Ewa::SearchWorker.config.DB_FILENAME}"
  end
end
