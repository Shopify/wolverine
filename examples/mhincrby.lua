local hash, key, increment
for i = 1, #KEYS, 3 do
	hash      = KEYS[i]
	key       = KEYS[i + 1]
	increment = KEYS[i + 2]
	redis.call('hincrby', hash, key, increment)
end
return "OK"