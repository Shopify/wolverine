require "wolverine/version"
require 'redis'

module Wolverine
  def self.script_path
    Rails.root + 'app/redis'
  end

  def self.call(file, *args)
    file << ".lua" unless file =~ /\.lua$/
    LuaFile.new(script_path + file).call(redis, *args)
  end

  def self.redis
    $redis ||= Redis.new
  end

  class LuaFile
    attr_reader :content, :digest
    def initialize file
      @content = load_lua file
      @digest = Digest::SHA1.hexdigest @content
    end

    def call redis, *args
      run_evalsha redis, *args
    rescue => e
      e.message =~ /NOSCRIPT/ ? run_eval(redis, *args) : raise
    end

    private

    def run_evalsha redis, *args
      redis.evalsha digest, args.size, *args
    end

    def run_eval redis, *args
      redis.eval content, args.size, *args
    end

    def load_lua file
      File.read file
    end
  end

end
