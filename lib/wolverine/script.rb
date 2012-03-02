require 'digest/sha1'

module Wolverine
  class InvalidScriptError < StandardError ; end
  class Script
    attr_reader :content, :digest
    def initialize file
      @file = file
      @content = load_lua file
      @digest = Digest::SHA1.hexdigest @content
    end

    def call redis, *args
      begin
        run_evalsha redis, *args
      rescue => e
        e.message =~ /NOSCRIPT/ ? run_eval(redis, *args) : raise
      end
    rescue => e
      if e.message =~ /ERR Error (compiling|running) script/
        raise InvalidScriptError, "#{e.message} (in #{@file.inspect})"
      else
        raise
      end
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

