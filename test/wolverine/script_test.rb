require_relative '../test_helper'
require 'digest/sha1'

module Wolverine
  class ScriptTest < MiniTest::Unit::TestCase
    CONTENT = "return 1"
    DIGEST = Digest::SHA1.hexdigest(CONTENT)

    def setup
      Wolverine::Script.any_instance.stubs(load_lua: CONTENT)
    end

    def script
      @script ||= Wolverine::Script.new('file1')
    end

    def test_digest_and_content
      content = "return 1" 
      assert_equal CONTENT, script.content
      assert_equal DIGEST, script.digest
    end

    def test_call_with_cache_hit
      tc = self
      redis = Class.new do
        define_method(:evalsha) do |digest, size, *args|
          tc.assert_equal DIGEST, digest
          tc.assert_equal 2, size
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
        define_method(:eval) do |content, size, *args|
          tc.assert_equal CONTENT, content
          tc.assert_equal 2, size
          tc.assert_equal [:a, :b], args
        end
      end
      script.call(redis.new, :a, :b)
    end

  end
end
