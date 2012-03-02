require 'redis'

require 'wolverine/version'
require 'wolverine/configuration'
require 'wolverine/script'

module Wolverine

  class Directory
    class MissingTemplate < StandardError ; end
    def initialize path
      @path = path
    end

    def method_missing sym, *args
      resolve sym, *args
    end

    def resolve sym, *args
      if File.directory?(path = @path + sym.to_s)
        Directory.new(path)
      elsif File.exists?(path = @path + "#{sym}.lua")
        Wolverine.call path, *args
      else
        raise MissingTemplate
      end
    end
  end

  def self.config
    @config ||= Configuration.new
  end

  def self.redis
    config.redis
  end

  def self.method_missing sym, *args
    Directory.new(config.script_path).resolve(sym, *args)
  rescue Directory::MissingTemplate
    super 
  end

  def self.call(file, *args)
    pathname = file.kind_of?(Pathname) ? file : full_path(file)
    Script.new(pathname).call(redis, *args)
  end

  def self.full_path(file)
    file << ".lua" unless file =~ /\.lua$/
    config.script_path + file
  end

end
