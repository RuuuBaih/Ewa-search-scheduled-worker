# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.7.2'

# APPLICATION LAYER
# Web Application
gem 'econfig', '~> 2.1'
gem 'roda', '~> 3.8'
gem 'pry', '~> 0.11.3'

# Messaging
gem 'aws-sdk-sqs'


# DOMAIN LAYER
# Validation
gem 'dry-struct', '~> 1.3'
gem 'dry-types', '~> 1.4'

# INFRASTRUCTURE LAYER
# INFRASTRUCTURE LAYER
# Networking
gem 'http', '~> 4.0'

# Asynchronicity
gem 'concurrent-ruby', '~> 1.1'

# Database
gem 'hirb', '~> 0.7'
gem 'hirb-unicode'
gem 'sequel', '~> 5.0'

group :development, :test do
  gem 'database_cleaner', '~> 1.8'
  gem 'sqlite3', '~> 1.4'
end

group :production do
  gem 'pg', '~> 1.2'
end

