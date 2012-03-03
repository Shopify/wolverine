require File.join(File.expand_path('../../test_helper', __FILE__))

class WolverineIntegrationTest < MiniTest::Unit::TestCase

  CONTENT = File.read(File.expand_path('../lua/util/mexists.lua', __FILE__))

  def mock_redis
    stub.tap do |redis|
      redis.expects(:evalsha).
        with('fe24f4dd4ba7881608cca4b846f009195e06d79a', 2, :a, :b).
        raises("NOSCRIPT")
      redis.expects(:eval).
        with(CONTENT, 2, :a, :b).
        returns([1, 0])
    end
  end

  def test_everything
    Wolverine.config.redis = mock_redis
    Wolverine.config.script_path = Pathname.new(File.expand_path('../lua', __FILE__))

    assert_equal [1, 0], Wolverine.util.mexists(:a, :b)
  end

end
