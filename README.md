# Wolverine [![Build Status](https://secure.travis-ci.org/burke/wolverine.png)](http://travis-ci.org/burke/wolverine) [![Dependency Status](https://gemnasium.com/Shopify/wolverine.png)](https://gemnasium.com/Shopify/wolverine)

Wolverine is a simple library to allow you to manage and run redis server-side lua scripts from a rails app, or other ruby code.

Redis versions 2.6 and up allow lua scripts to be run on the server that execute atomically and very quickly.

This is *extremely* useful.

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

## License

Copyright (C) 2012 [Shopify](http://shopify.com) by [Burke Libbey](http://burkelibbey.org)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

