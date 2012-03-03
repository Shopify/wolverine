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

    # Wolverine::InvalidScriptError: ERR Error running script (call to f_f5fbb1da9ad036109842747becb4e2abb5e95966): [string "func definition"]:27: attempt to compare nil with number  (in #<Pathname:/Users/burke/src/s/shopify/app/wolverine/reservations/reserve.lua>)
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
        raise klass, "[#{relative_path}:#{line_number}] #{message}"
      else
        raise
      end
    end

    private

    def relative_path
      file.relative_path_from(Wolverine.config.script_path)
    end

    def format_error_message(error)
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

