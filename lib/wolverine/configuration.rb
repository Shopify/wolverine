module Wolverine
  class Configuration < Struct.new(:redis, :script_path)
    def redis
      super || @redis ||= Redis.new
    end

    def script_path
      super || @script_path ||= Rails.root + 'app/redis'
    end
  end
end
