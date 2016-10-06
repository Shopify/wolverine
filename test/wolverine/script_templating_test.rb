require File.join(File.expand_path('../../test_helper', __FILE__))
require 'digest/sha1'
require 'fileutils'

RESULT = <<EOF
local function do_something()
  return 15;
end
return do_something()
EOF

class Wolverine
  class ScriptTemplatingTest < MiniTest::Unit::TestCase

    def setup
      base = Pathname.new('test/wolverine/lua')
      Wolverine.config.script_path = base
    end

    def teardown
      Wolverine.config.instrumentation = proc{}
    end

    def script
      @script ||= Wolverine::Script.new('test/wolverine/lua/outer.lua')
    end

    def test_templating
      assert_equal script.instance_variable_get('@content'), RESULT
    end

  end
end
