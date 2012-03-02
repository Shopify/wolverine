require_relative 'test_helper'

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

end
