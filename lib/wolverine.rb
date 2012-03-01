require 'redis'

require "wolverine/version"
require 'wolverine/configuration'
require 'wolverine/script'

module Wolverine
  def self.config
    @config ||= Configuration.new
  end

  def self.redis
    config.redis
  end

  def self.call(file, *args)
    Script.new(full_path(file)).call(redis, *args)
  end

  def self.full_path(file)
    file << ".lua" unless file =~ /\.lua$/
    config.script_path + file
  end

end
