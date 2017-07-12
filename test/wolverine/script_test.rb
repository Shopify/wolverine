require File.join(File.expand_path('../../test_helper', __FILE__))
require 'digest/sha1'

class Wolverine
  class ScriptTest < MiniTest::Unit::TestCase
    CONTENT = <<EOC
local key, score, member, context, max_rank = KEYS[1], ARGV[1], ARGV[2], ARGV[3], ARGV[4]
redis.call('ZADD', key, score, member)

local rank = redis.call('ZRANK', key, member)
if rank > max_rank then
  return {}
end
return redis.call('ZRANGE', start, end, 'WITHSCORES')
EOC
    DIGEST = Digest::SHA1.hexdigest(CONTENT)

    def setup
      base = Pathname.new('/a/b/c/d')
      Wolverine.config.script_path = base
      Wolverine::Script.any_instance.stubs(:load_lua => CONTENT)
    end

    def teardown
      Wolverine.config.instrumentation = proc{}
    end

    def script
      @script ||= Wolverine::Script.new('/a/b/c/d/e/file1.lua')
    end

    def test_error
      redis = stub
      redis.expects(:evalsha).raises(%q{ERR Error running script (call to f_178d75adaa46af3d8237cfd067c9fdff7b9d504f): [string "func definition"]:5: attempt to compare nil with number})
      begin
        script.call(redis)
      rescue Wolverine::LuaError => e
        assert_equal <<EOS, e.message
attempt to compare nil with number

    3: 
    4: local rank = redis.call('ZRANK', key, member)
 => 5: if rank > max_rank then
    6:   return {}
    7: end

EOS
        assert_equal "/a/b/c/d/e/file1.lua:5", e.backtrace.first
        assert_match(/script.rb/, e.backtrace[1])
      end
    end

    def test_instrumentation
      callback = Object.new
      tc = self
      meta = class << callback ; self ; end
      meta.send(:define_method, :call) { |a, b, c|
        tc.assert_equal "e/file1.lua", a
        tc.assert_operator b, :<, 1
        tc.assert_equal :evalsha, c
      }
      Wolverine.config.instrumentation = callback
      redis = Class.new do
        define_method(:evalsha) do |digest, *args|
          nil
        end
      end
      script.call(redis.new, :a, :b)
    end

    def test_call_with_cache_hit
      tc = self
      redis = Class.new do
        define_method(:evalsha) do |digest, *args|
          tc.assert_equal DIGEST, digest
          tc.assert_equal [:a, :b], args
        end
      end
      script.call(redis.new, :a, :b)
    end

    def test_call_with_cache_miss
      tc = self
      redis = Class.new do
        define_method(:evalsha) do |*|
          raise "NOSCRIPT No matching script. Please use EVAL."
        end
        define_method(:eval) do |content, *args|
          tc.assert_equal CONTENT, content
          tc.assert_equal [:a, :b], args
        end
      end
      script.call(redis.new, :a, :b)
    end

  end
end
