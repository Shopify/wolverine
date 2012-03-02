require_relative 'test_helper'

class WolverineTest < MiniTest::Unit::TestCase

  def setup
    Wolverine.config.redis = :redis
    Wolverine.config.script_path = Pathname.new('foo')
  end

  def test_adds_extension_if_none_present
    assert_equal Pathname.new('foo/bar.lua'), Wolverine.full_path('bar')
  end

  def test_redis
    assert_equal :redis, Wolverine.redis
  end

  def test_call
    script = stub
    script.expects(:call).with(:redis, :a, :b).returns(:return)
    Wolverine::Script.expects(:new).with(Pathname.new('foo/bar.lua')).returns(script)
    assert_equal :return, Wolverine.call('bar', :a, :b)
  end

end
