local function deep_copy(array, temp_seen)
    if type(array) ~= "table" then 
        return array 
    end

    if temp_seen ~= nil and temp_seen[array] ~= nil then 
        return temp_seen[array]
    end
  
    local copy = {}
    local cache = temp_seen or {}

    cache[array] = copy; for k, v in pairs(array) do 
        copy[deep_copy(k, cache)] = deep_copy(v, cache) 
    end

    return setmetatable(copy, getmetatable(array))
end

return deep_copy
