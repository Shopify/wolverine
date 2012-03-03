module Wolverine
  class LuaError < StandardError
    PATTERN = /ERR Error (compiling|running) script \(.*?\): \[.*?\]:(\d+): (.*)/
    WOLVERINE_LIB_PATH = File.expand_path('../../', __FILE__)

    def self.intercepts?(e)
      e.message =~ PATTERN
    end

    attr_reader :error, :file
    def initialize(error, file)
      @error = error
      @file = file

      error.message =~ PATTERN
      stage, line_number, message = $1, $2, $3


      super(message)
      set_backtrace generate_backtrace(file, line_number)
    end

    def generate_backtrace(file, line_number)
      pre_wolverine = backtrace_before_entering_wolverine(error.backtrace)
      index_of_first_wolverine_line = (error.backtrace.size - pre_wolverine.size - 1)
      pre_wolverine.unshift(error.backtrace[index_of_first_wolverine_line])
      pre_wolverine.unshift("#{file}:#{line_number}")
      pre_wolverine
    end

    def backtrace_before_entering_wolverine(backtrace)
      backtrace.reverse.take_while { |line| ! line_from_wolverine(line) }.reverse
    end

    def line_from_wolverine(line)
      line.split(':').first.include?(WOLVERINE_LIB_PATH)
    end

  end

end