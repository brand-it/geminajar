# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'
require 'bundler'
Bundler.require(:default)
require './lib/friendly_progress'
require './lib/rack'

loader = Zeitwerk::Loader.new
# loader.push_dir('app/models')
# loader.push_dir('app/services')
loader.enable_reloading # you need to opt-in before setup
loader.setup
ENV['RAILS_ENV'] = ENV['RACK_ENV'] if ENV['RACK_ENV'] != ENV['RAILS_ENV']
# ActiveRecord::Base.configurations = Rack.db_config
Dir['./config/initializers/*.rb'].each { |file| require file }
ActiveSupport::Cache.format_version = 7.0

# create a background thread that will let you queue jobs to be executed in the background
