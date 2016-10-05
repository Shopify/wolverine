require 'pathname'
require 'benchmark'
require 'digest/sha1'
require 'erb'

class Wolverine
  # {Script} represents a lua script in the filesystem. It loads the script
  # from disk and handles talking to redis to execute it. Error handling
  # is handled by {LuaError}.
  class Script

    # Loads the script file from disk and calculates its +SHA1+ sum.
    #
    # @param file [Pathname] the full path to the indicated file
    def initialize file, options = {}
      @file = Pathname.new(file)
      @config = options[:config] || Wolverine.config
      @content = load_lua file
      @digest = Digest::SHA1.hexdigest @content
    end

    # Passes the script and supplied arguments to redis for evaulation.
    # It first attempts to use a script redis has already cached by using
    # the +EVALSHA+ command, but falls back to providing the full script
    # text via +EVAL+ if redis has not seen this script before. Future
    # invocations will then use +EVALSHA+ without erroring.
    #
    # @param redis [Redis] the redis connection to run against
    # @param args [*Objects] the arguments to the script
    # @return [Object] the value passed back by redis after script execution
    # @raise [LuaError] if the script failed to compile of encountered a
    #   runtime error
    def call redis, *args
      t = Time.now
      begin
        run_evalsha redis, *args
      rescue => e
        e.message =~ /NOSCRIPT/ ? run_eval(redis, *args) : raise
      end
    rescue => e
      if LuaError.intercepts?(e)
        raise LuaError.new(e, @file)
      else
        raise
      end
    ensure
      StatsD.measure(statsd_key, (Time.now - t) * 1000, 0.001) if Wolverine.statsd_enabled?
    end

    private

    def statsd_key
      k = @file.relative_path_from(Wolverine.config.script_path).to_s.sub!(/\.lua$/,'').gsub!(/\//,'.')
      "Wolverine.#{k}"
    end

    def run_evalsha redis, *args
      instrument :evalsha do
        redis.evalsha @digest, *args
      end
    end

    def run_eval redis, *args
      instrument :eval do
        redis.eval @content, *args
      end
    end

    def instrument eval_type
      ret = nil
      runtime = Benchmark.realtime { ret = yield }
      @config.instrumentation.call relative_path.to_s, runtime, eval_type
      ret
    end

    def relative_path
      @path ||= @file.relative_path_from(@config.script_path)
    end

    def load_lua file
      TemplateContext.new(@config.script_path).template(file)
    end

    class TemplateContext
      def initialize(script_path)
        @script_path = script_path
      end

      def template(pathname)
        @partial_templates ||= {}
        ERB.new(File.read(pathname)).result binding
      end

      # helper method to include a lua partial within another lua script
      #
      # @param relative_path [String] the relative path to the script from
      #     `Wolverine.config.script_path`
      def include_partial(relative_path)
        unless @partial_templates.has_key? relative_path
          @partial_templates[relative_path] = nil
          template( Pathname.new("#{@script_path}/#{relative_path}") )
        end
      end
    end

  end
end

