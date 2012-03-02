require 'redis'
require 'pathname'

require 'wolverine/version'
require 'wolverine/configuration'
require 'wolverine/script'
require 'wolverine/path_component'

module Wolverine
  def self.config
    @config ||= Configuration.new
  end

  def self.redis
    config.redis
  end

  def self.root_directory
    @root_directory ||= PathComponent.new(config.script_path)
  end

  def self.method_missing sym, *args
    root_directory.send(sym, *args) 
  rescue PathComponent::MissingTemplate
    super 
  end

end
