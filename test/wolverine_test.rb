require File.join(File.expand_path('../test_helper', __FILE__))

class WolverineTest < MiniTest::Unit::TestCase

  def test_redis
    Wolverine.config.redis = :redis
    assert_equal :redis, Wolverine.redis
  end

  def test_reset!
    dir = Wolverine.root_directory
    assert_equal Wolverine.root_directory, dir
    Wolverine.reset!
    refute_equal Wolverine.root_directory, dir
  end

  def test_instantiate_wolverine_with_config
    r = Struct.new(:Redis)
    config = Wolverine::Configuration.new(r, 'path')
    wolverine = Wolverine.new(config)

    assert_equal r, wolverine.config.redis
    assert_equal r, wolverine.redis
    assert_equal 'path', wolverine.config.script_path
  end

end
