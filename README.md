# Wolverine [![Build Status](https://secure.travis-ci.org/burke/wolverine.png)](http://travis-ci.org/burke/wolverine) [![Dependency Status](https://gemnasium.com/Shopify/wolverine.png)](https://gemnasium.com/Shopify/wolverine)

Wolverine is a simple library to allow you to manage and run redis server-side lua scripts from a rails app, or other ruby code.

Redis versions 2.6 and up allow lua scripts to be run on the server that execute atomically and very quickly.

Wolverine is a wrapper around that functionality, to package it up in a format more familiar to a Rails codebase.

## How do I use it?

1) Make sure you have redis 2.6 or higher installed.

```
redis-server -v
```

2) Add wolverine to your Gemfile:

```ruby
gem 'wolverine'
```

3) Add your lua scripts to `app/wolverine`:

```lua
-- app/wolverine/util/mexists.lua
local exists = {}
local existence
for _, key in ipairs(KEYS) do
  table.insert(exists, redis.call('exists', key))
end
return exists
```

4) Call wolverine from your code:

```ruby
Wolverine.util.mexists(['key1', 'key2', 'key3']) #=> [0, 1, 0]
```

Or

```ruby
Wolverine.util.mexists(:keys => ['key1', 'key2', 'key3']) #=> [0, 1, 0]
```

Methods are available on `Wolverine` paralleling the directory structure
of wolverine's `script_path`.

## Configuration

Available configuration options:

* `Wolverine.config.redis` (default `Redis.new`)
* `Wolverine.config.script_path` (default `Rails.root + 'app/wolverine'`)
* `Wolverine.config.instrumentation` (default none)

If you want to override one or more of these, doing so in an initializer is recommended but not required. See the [full documentation](http://shopify.github.com/wolverine/Wolverine/Configuration.html) for more details.

## More information

For more information on scripting redis with lua, refer to redis' excellent documentation: http://redis.io/commands/eval

