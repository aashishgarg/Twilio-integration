require 'dalli'
require 'singleton'

class CacheManagementException < Exception
  def initialize(msg='Cache is already full')
    super(msg)
  end
end

class CacheManagement
  include Singleton

  def initialize
    options = YAML.load_file(File.join(Rails.root, 'config', 'memcache_settings.yml'))[Rails.env]
    host = options.delete('host')
    port = options.delete('port')
    @connection ||= Dalli::Client.new("#{host}:#{port}", options)
  end

  def get_value(key)
    @connection.get(key)
  end

  def set_value(key, value, expires_in = 30.days)
    @connection.set(key, value, expires_in)
  end

  def set_value_optimistically(key, value)
    raise CacheManagement, "Cache is already full with #{key}" unless get_value(key).nil?
    set_value(key, value)
  end

  def delete_value(key)
    @connection.delete(key)
  end
end