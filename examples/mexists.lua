local exists = {}
local existence
for _, key in ipairs(KEYS) do
	table.insert(exists, redis.call('exists', key))
end
return exists