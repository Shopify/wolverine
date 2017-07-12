class Wolverine
  # A {PathComponent} represents either the +Wolverine.config.script_path+
  # directory, or a subdirectory of it. Calling (nearly) any method on it will
  # cause it to look in the filesystem at the location it refers to for a file
  # or directory matching the method name. These results are cached.
  #
  # Calling a method that maps to a directory will return a new {PathComponent}
  # with a +path+ referring to that directory.
  #
  # Calling a method that maps to a file (with +'.lua'+ automatically appended
  # to the name) will load the file via {Script} and call it with the
  # arugments passed, returning the result ({method_missing}).
  class PathComponent
    class MissingTemplate < StandardError ; end

    # @param path [Pathname] full path to the current file or directory
    # @param redis [Redis]
    def initialize path, options = {}
      @path = path
      @options = options
      @cache_to = options[:cache_to]
      @redis = options[:redis] || Wolverine.redis
      @config = options[:config] || Wolverine.config
    end

    # @param sym [Symbol] the file or directory to look up and execute
    # @param args [*Objects] arguments to pass to the {Script}, if +sym+ resolves to a lua file
    # @return [PathComponent, Object] A new, nested {PathComponent} if +sym+ resolves to
    #   a directory, or an execution result if it resolves to a file.
    # @raise [MissingTemplate] if +sym+ maps to neither a directory or a file
    def method_missing sym, *args
      create_method sym, *args
      send sym, *args
    end

    private

    def create_method sym, *args
      if directory?(path = @path + sym.to_s)
        define_directory_method path, sym
      elsif file?(path = @path + "#{sym}.lua")
        define_script_method path, sym, *args
      else
        raise MissingTemplate
      end
    end

    def directory?(path)
      File.directory?(path)
    end

    def file?(path)
      File.exist?(path) && !File.directory?(path)
    end

    def define_directory_method path, sym
      options = @options.merge({:cache_to => nil})
      dir = PathComponent.new(path, options)
      cb = proc { dir }
      define_metaclass_method(sym, &cb)
      cache_metaclass_method(sym, &cb)
    end

    def define_script_method path, sym, *args
      redis, options = @redis, @options.merge({:cache_to => nil})
      script = Wolverine::Script.new(path, options)
      cb = proc { |*cb_args| script.call(redis, *cb_args) }
      define_metaclass_method(sym, &cb) 
      cache_metaclass_method(sym, &cb)
    end

    def define_metaclass_method sym, &block
      metaclass = class << self; self; end
      metaclass.send(:define_method, sym, &block)
    end

    def cache_metaclass_method sym, &block
      unless @cache_to.nil?
        metaclass = class << @cache_to; self; end
        metaclass.send(:define_method, sym, &block)
        cached_methods = @cache_to.send(:cached_methods)
        cached_methods[sym] = self
      end
    end

  end

end
