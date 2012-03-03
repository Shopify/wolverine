module Wolverine
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
    def initialize path
      @path = path
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
      File.exists?(path) && !File.directory?(path)
    end

    def define_directory_method path, sym
      dir = PathComponent.new(path)
      define_metaclass_method(sym) { dir }
    end

    def define_script_method path, sym, *args
      script = Wolverine::Script.new(path)
      define_metaclass_method(sym) { |*args|
        script.call(Wolverine.redis, *args)
      }
    end

    def define_metaclass_method sym, &block
      metaclass = class << self; self; end
      metaclass.send(:define_method, sym, &block)
    end

  end

end
