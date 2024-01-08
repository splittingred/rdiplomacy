# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0.8'

gem 'importmap-rails' # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'jbuilder' # Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'sprockets-rails' # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'stimulus-rails' # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'turbo-rails' # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]

gem 'bootsnap', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'mysql2', '~> 0.5'
gem 'puma', '~> 5.6' # Use the Puma web server [https://github.com/puma/puma]
gem 'redis', '~> 4.0' # Use Redis adapter to run Action Cable in production

# user auth
gem 'devise'
gem 'dotenv-rails'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

gem 'dry-monads'
gem 'dry-rails', '~> 0.7'
gem 'dry-struct'
gem 'rgl'

# svg parsing
gem 'inline_svg', '~> 1.9'
gem 'victor'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem 'kredis'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'ffaker'
  gem 'pry'
  gem 'rspec_junit_formatter'
  gem 'rspec-rails', '~> 6.0'
  gem 'rubocop', '>= 1.7'
  gem 'rubocop-performance', '>= 0.0.1'
  gem 'rubocop-rails'
  gem 'rubocop-rspec', '>= 2.0'
  gem 'simplecov', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'web-console'
end
