# frozen_string_literal: true

module Rack
  ENCRYPTED_CONFIG_PATH = Pathname.new('config/credentials.yml.enc')
  MASTER_KEY_PATH = Pathname.new('config/master.key')

  module_function

  def root
    @root ||= Pathname.new(::File.expand_path('..', __dir__))
  end

  def env
    ActiveSupport::EnvironmentInquirer.new(ENV.fetch('RACK_ENV', nil))
  end

  def config
    encrypted_file.config[env.to_sym]
  end

  def db_config_path
    Pathname.new(::File.join(root, 'config/database.yml'))
  end

  def db_config
    @db_config ||= YAML.load(parse_erb(db_config_path.read)).with_indifferent_access
  end

  def parse_erb(string)
    ERB.new(string).result
  rescue StandardError => e
    line_number = e.backtrace.first.split(':')[1].to_i
    print_range = (line_number - 10)...(line_number + 10)
    string.lines.each.with_index do |line, index|
      line_number = index + 1
      next unless print_range.include?(line_number)

      puts "#{line_number} #{line}"
    end
    raise e
  end

  def db_dir
    ::File.join root, 'db'
  end

  def db_migrate_path
    @db_migrate_path ||= db_config.fetch(env).flat_map do |name, config|
      next if config[:replica] || config.fetch('migrations_paths', true) == false

      Array.wrap(config.fetch('migrations_paths'))
    rescue KeyError
      raise "No migrations_paths for #{name} database"
    end.compact
  rescue KeyError
    raise "No database configuration for #{env} environment found in #{db_config_path}. Available configurations: #{db_config.keys.join(', ')}"
  end

  def fixtures_path
    ::File.join root, 'test/fixtures'
  end

  def seed_file
    ::File.join root, 'db/seeds.rb'
  end

  def encrypted_file
    ActiveSupport::EncryptedConfiguration.new(
      config_path: ENCRYPTED_CONFIG_PATH,
      key_path: MASTER_KEY_PATH,
      env_key: 'RACK_MASTER_KEY',
      raise_if_missing_key: true
    )
  end

  def log_destination
    @log_destination ||= if ENV.fetch('LOG_STDOUT', 'false') == 'true'
                           $stdout
                         else
                           log_path = Pathname.new('log')
                           log_path.mkpath unless log_path.exist?
                           log_path.join("#{env}.log")
                         end
  end

  def logger
    @logger ||= ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(log_destination))
  end

  def log_level
    ENV.fetch('LOG_LEVEL', 'debug').downcase.to_sym
  end

  def cache
    @cache ||= ActiveSupport::Cache.lookup_store(
      :file_store, "tmp/cache/#{env}", expires_in: 1.day
    )
  end
end
