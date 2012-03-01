# Wolverine

Wolverine is a simple library to allow you to manage and run redis server-side lua scripts from a rails app, or other ruby code.

## What are you talking about?

Redis versions 2.6 and up allow lua scripts to be run on the server that execute atomically and very, very quickly.

This is really, really cool.

Wolverine is a wrapper around that functionality, to package it up in a format more familiar to a Rails codebase.

## How do I use it?

1) Make sure you have redis 2.6 or higher installed. As of now, that means compiling from source:

```shell
git clone https://github.com/antirez/redis.git
cd redis && make
./src/redis-server
```

2) Add wolverine to your Gemfile:

```ruby
gem 'wolverine'
```

3) Add your lua scripts to `app/redis`:

```lua
-- app/redis/util/mexists.lua
local exists = {}
local existence
for _, key in ipairs(KEYS) do
  table.insert(exists, redis.call('exists', key))
end
return exists
```

4) Call wolverine from your code:

```ruby
Wolverine.call('util/mexists', 'key1', 'key2', 'key3') #=> [0, 1, 0]
```

## Configuration

Available configuration options:

* `Wolverine.config.redis` (default `Redis.new`)
* `Wolverine.config.script_path` (default `Rails.root + 'app/redis'`)

If you want to override one or both of these, doing so in an initializer is recommended but not required.

## More information

For more information on scripting redis with lua, refer to redis' excellent documentation: http://redis.io/commands/eval

## License

Copyright (C) 2012 Shopify

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

