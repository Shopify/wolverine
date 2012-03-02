local hash, key, value
for i = 1, #KEYS, 3 do
	hash  = KEYS[i]
	key   = KEYS[i + 1]
	value = KEYS[i + 2]
	redis.call('hsetnx', hash, key, value)
end
return "OK"