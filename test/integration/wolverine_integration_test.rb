require File.join(File.expand_path('../../test_helper', __FILE__))

class WolverineIntegrationTest < MiniTest::Unit::TestCase

  CONTENT = File.read(File.expand_path('../lua/util/mexists.lua', __FILE__))

  def mock_redis
    stub.tap do |redis|
      redis.expects(:evalsha).
        with('fe24f4dd4ba7881608cca4b846f009195e06d79a', :a, :b).
        raises("NOSCRIPT").once
      redis.expects(:eval).
        with(CONTENT, :a, :b).
        returns([1, 0]).once
    end
  end

  def test_everything
    Wolverine.config.redis = mock_redis
    Wolverine.config.script_path = Pathname.new(File.expand_path('../lua', __FILE__))

    assert_equal [1, 0], Wolverine.util.mexists(:a, :b)
    assert Wolverine.methods.include?(:util)
  end

  def test_everything_instantiated
    script_path = Pathname.new(File.expand_path('../lua', __FILE__))
    config = Wolverine::Configuration.new(mock_redis, script_path)

    wolverine = Wolverine.new(config)
    assert_equal [1, 0], wolverine.util.mexists(:a, :b)
    assert wolverine.methods.include?(:util)
  end

  # This class emulates the behaviour of redis-namespace
  # https://github.com/resque/redis-namespace/blob/master/lib/redis/namespace.rb#L415-L418
  class EvilRedis
    include ::MiniTest::Assertions

    @original_args = nil

    def evalsha(_digest, *args)
      @original_args = args.map {|x| x.dup}
      if args.last.is_a?(Hash)
        args.last[:keys] = modify_key(args.last[:keys])
      else
        args[0] = modify_key(args[0])
      end
      raise "NOSCRIPT"
    end

    def eval(_content, *args)
      assert_equal @original_args, args
      return [1, 0]
    end

    private

    def modify_key(key)
      return key unless key

      case key
      when Array
        key.map {|k| modify_key k}
      when Hash
        Hash[*key.map {|k, v| [ modify_key(k), v ]}.flatten]
      else
        "modified:#{key}"
      end
    end
  end

  def get_test_script
    redis = EvilRedis.new
    Wolverine.config.script_path = Pathname.new(File.expand_path('../lua', __FILE__))
    test_script = Wolverine::Script.new(File.expand_path('../lua/util/mexists.lua', __FILE__))
  end

  def test_retries_with_original_hash_args
    result = get_test_script.call(
      EvilRedis.new,
      keys: [:a, :b],
      argv: [:d, :e]
    )
    assert_equal [1, 0], result
  end

end
