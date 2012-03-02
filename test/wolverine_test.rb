require_relative 'test_helper'

class WolverineTest < MiniTest::Unit::TestCase
  
  def test_redis
    Wolverine.config.redis = :redis
    assert_equal :redis, Wolverine.redis
  end

end
