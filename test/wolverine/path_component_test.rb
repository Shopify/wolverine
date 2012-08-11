require File.join(File.expand_path('../../test_helper', __FILE__))

class Wolverine
  class PathComponentTest < MiniTest::Unit::TestCase

    def root
      @root ||= Pathname.new('.')
    end

    def pc
      @pc ||= Wolverine::PathComponent.new(root)
    end
    
    def test_directory_caching
      pc.expects(:directory?).with(root + 'bar').returns(true)
      assert_equal pc.bar.object_id, pc.bar.object_id
    end

    def test_script_caching
      pc.expects(:directory?).with(root + 'bar').returns(false)
      pc.expects(:file?).with(root + 'bar.lua').returns(true)
      script = stub
      Wolverine::Script.expects(:new).once.returns(script)
      script.expects(:call).twice.returns(:success)

      assert_equal pc.bar, pc.bar
    end

  end
end
