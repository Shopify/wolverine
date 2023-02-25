# Wolverine [![Dependency Status](https://gemnasium.com/Shopify/wolverine.png)](https://gemnasium.com/Shopify/wolverine) [![Build Status](https://travis-ci.org/Shopify/wolverine.svg?branch=master)](https://travis-ci.org/Shopify/wolverine)

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

#### Nested Lua Scripts

For lua scripts with shared code, Wolverine supports ERB style templating.

If your app has lua scripts at

- `app/wolverine/do_something.lua`
- `app/wolverine/do_something_else.lua`

that both have shared lua code, you can factor it out into a lua "partial":

- `app/wolverine/shared/_common.lua`

```lua
-- app/wolverine/shared/_common.lua
local function complex_redis_command(key, value)
  local dict = {}
  dict[key] = value
end
```

```lua
-- app/wolverine/do_something.lua
<%= include_partial 'shared/_common.lua' %>
complex_redis_command("foo", "bar")
return true
```

```lua
-- app/wolverine/do_something_else.lua
<%= include_partial 'shared/_common.lua' %>
complex_redis_command("bar", "baz")
return false
```

- partials are loaded relative to the `Wolverine.config.script_path` location
- partials can be protected by adding an underscore (eg. `shared/_common.lua`). This disallows EVAL access through `Wolverine.shared._common`

## Configuration

Available configuration options:

* `Wolverine.config.redis` (default `Redis.new`)
* `Wolverine.config.script_path` (default `Rails.root + 'app/wolverine'`)
* `Wolverine.config.instrumentation` (default none)

If you want to override one or more of these, doing so in an initializer is recommended but not required. See the [full documentation](http://shopify.github.io/wolverine/Wolverine/Configuration.html) for more details.

## More information

For more information on scripting redis with lua, refer to redis' excellent documentation: http://redis.io/commands/eval

