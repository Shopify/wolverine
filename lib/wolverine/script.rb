require 'digest/sha1'

module Wolverine
  class LuaError < StandardError ; end
  class LuaCompilationError < LuaError ; end
  class LuaRuntimeError < LuaError ; end

  class Script
    attr_reader :content, :digest, :file
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
      if e.message =~ /ERR Error (compiling|running) script \(.*?\): \[.*?\]:(\d+): (.*)/
        stage, line_number, message = $1, $2, $3
        klass = (stage == "compiling") ? LuaCompilationError : LuaRuntimeError
        begin
          raise klass.new(message)
        rescue => e
          raise correct_lua_backtrace(e, file, line_number)
        end
      else
        raise
      end
    end

    private

    def correct_lua_backtrace(error, file, line_number)
      4.times { error.backtrace.shift }
      error.backtrace.unshift("#{file}:#{line_number}")
      error
    end

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

