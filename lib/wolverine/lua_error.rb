class Wolverine
  # Reformats errors raised by redis representing failures while executing
  # a lua script. The default errors have confusing messages and backtraces,
  # and a type of +RuntimeError+. This class improves the message and
  # modifies the backtrace to include the lua script itself in a reasonable
  # way.
  class LuaError < StandardError
    PATTERN = /ERR Error (compiling|running) script \(.*?\): .*?:(\d+): (.*)/
    WOLVERINE_LIB_PATH = File.expand_path('../../', __FILE__)
    CONTEXT_LINE_NUMBER = 2

    # Is this error one that should be reformatted?
    #
    # @param error [StandardError] the original error raised by redis
    # @return [Boolean] is this an error that should be reformatted?
    def self.intercepts? error
      error.message =~ PATTERN
    end

    # Initialize a new {LuaError} from an existing redis error, adjusting
    # the message and backtrace in the process.
    #
    # @param error [StandardError] the original error raised by redis
    # @param file [Pathname] full path to the lua file the error ocurred in
    # @param content [String] lua file content the error ocurred in
    def initialize error, file, content
      @error = error
      @file = file
      @content = content

      @error.message =~ PATTERN
      _stage, line_number, message = $1, $2, $3
      error_context = generate_error_context(content, line_number.to_i)

      super "#{message}\n\n#{error_context}\n\n"
      set_backtrace generate_backtrace file, line_number
    end

    private

    def generate_error_context(content, line_number)
      lines = content.lines.to_a
      beginning_line_number = [1, line_number - CONTEXT_LINE_NUMBER].max
      ending_line_number = [lines.count, line_number + CONTEXT_LINE_NUMBER].min
      line_number_width = ending_line_number.to_s.length

      (beginning_line_number..ending_line_number).map do |number|
        indicator = number == line_number ? '=>' : '  '
        formatted_number = "%#{line_number_width}d" % number
        " #{indicator} #{formatted_number}: #{lines[number - 1]}"
      end.join.chomp
    end

    def generate_backtrace(file, line_number)
      pre_wolverine = backtrace_before_entering_wolverine(@error.backtrace)
      index_of_first_wolverine_line = (@error.backtrace.size - pre_wolverine.size - 1)
      pre_wolverine.unshift(@error.backtrace[index_of_first_wolverine_line])
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
