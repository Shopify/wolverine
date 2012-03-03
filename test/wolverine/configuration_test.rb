require File.join(File.expand_path('../../test_helper', __FILE__))
require 'pathname'

module Rails
  def self.root
    Pathname.new('foo')
  end
end

module Wolverine
  class ConfigurationTest < MiniTest::Unit::TestCase

    def test_default_redis
      assert_instance_of Redis, Wolverine::Configuration.new.redis
    end

    def test_default_script_path
      actual = Wolverine::Configuration.new.script_path
      assert_equal Pathname.new('foo/app/wolverine'), actual
    end

    def test_setting_redis
      config = Wolverine::Configuration.new
      config.redis = :foo
      assert_equal :foo, config.redis
    end

    def test_setting_script_path
      config = Wolverine::Configuration.new
      config.script_path = :foo
      assert_equal :foo, config.script_path
    end

  end
end
