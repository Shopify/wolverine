module Wolverine
  class PathComponent
    class MissingTemplate < StandardError ; end

    def initialize path
      @path = path
    end

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