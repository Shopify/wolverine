require 'redis'
require 'pathname'

require 'wolverine/version'
require 'wolverine/configuration'
require 'wolverine/script'
require 'wolverine/path_component'
require 'wolverine/lua_error'

module Wolverine
  # Returns the configuration object for reading and writing
  # configuration values.
  # 
  # @return [Wolverine::Configuration] the configuration object
  def self.config
    @config ||= Configuration.new
  end

  # Provides access to the redis connection currently in use by Wolverine.
  #
  # @return [Redis] the redis connection used by Wolverine
  def self.redis
    config.redis
  end

  # Resets all the scripts cached by Wolverine. Scripts are lazy-loaded and
  # cached in-memory, so if a file changes on disk, it will be necessary to
  # manually reset the cache using +reset!+.
  #
  # @return [void]
  def self.reset!
    @root_directory = nil
  end

  # Used to handle dynamic accesses to scripts. Successful lookups will be
  # cached on the {PathComponent} object. See {PathComponent#method_missing}
  # for more detail on how this works.
  # 
  # @return [PathComponent, Object] a PathComponent if the method maps to a
  #   directory, or an execution result if the the method maps to a lua file.
  def self.method_missing sym, *args
    root_directory.send(sym, *args) 
  rescue PathComponent::MissingTemplate
    super 
  end

  private

  def self.root_directory
    @root_directory ||= PathComponent.new(config.script_path)
  end

end
