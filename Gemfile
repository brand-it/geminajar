# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.3'

gem 'activerecord', require: 'active_record'
gem 'activesupport', require: ['active_support', 'active_support/encrypted_configuration']
gem 'progressbar'
gem 'rack'
gem 'rake'
gem 'sinatra'

group :development, :test do
  gem 'rubocop'
end
