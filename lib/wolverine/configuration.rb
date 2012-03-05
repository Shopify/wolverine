module Wolverine
  class Configuration < Struct.new(:redis, :script_path, :instrumentation)

    # @return [Redis] the redis connection actively in use by Wolverine
    def redis
      super || @redis ||= Redis.new
    end

    # Wolverine.config.instrumentation can be used to specify a callback to
    # fire with the runtime of each script. This can be useful for analyzing
    # scripts to make sure they aren't running for an unreasonable amount of
    # time.
    # 
    # The proc will receive three parameters: 
    # 
    # * +script_name+: A unique identifier for the script, based on its
    #   location in the file system
    # * +runtime+: A float, the total execution time of the script
    # * +eval_type+: Either +eval+ or +evalsha+, the method used to run
    #   the script
    # @return [#call] the proc or other callable to be triggered on completion
    #   of a script.
    def instrumentation
      super || @instrumentation ||= proc { |script_name, runtime, eval_type| nil }
    end

    # @return [Pathname] the path wolverine will check for scripts
    def script_path
      super || @script_path ||= Rails.root + 'app/wolverine'
    end
  end
end
