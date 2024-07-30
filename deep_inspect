local spaces = "    "
local key_quote_separator = function(str)
    return type(str) ~= "string" and tostring(str) or ("\"" .. str .. "\"")
end

local value_quote_separator = function(str)
    local str_fn = tostring(str)
    return str_fn:find("function") ~= nil and str_fn:sub(1, 8) or key_quote_separator(str)
end

local function deep_inspect(array, is_metatable, indent, second_time, visited)
    local indent = indent or 1
    local visited = visited or {}
    local tabulation = string.rep(spaces, indent)

    if type(array) ~= "table" then
        return
    end

    if visited[array] then
        return
    end; visited[array] = true

    if not second_time then
        print("table -> {")
    end

    local metatables = getmetatable(array)
    if metatables then
        print(string.format("%s__metatable = {", tabulation))
        deep_inspect(metatables, true, indent + 1, true, visited)
        print(tabulation .. "},")
    end

    local count = 0
    local array_size = 0

    for _ in pairs(array) do
        array_size = array_size + 1
    end

    for k, v in pairs(array) do
        if type(v) == "table" and visited[v] then
            array_size = array_size - 1
        else
            count = count + 1
            if type(v) == "table" then
                print(string.format("%s[%s] = {", tabulation, key_quote_separator(k)))
                deep_inspect(v, false, indent + 1, true, visited)
                print(tabulation .. (count < array_size and "}," or "}"))
            else
                print(string.format("%s%s = %s%s", tabulation, is_metatable and k or "[" .. key_quote_separator(k) .. "]", value_quote_separator(v), count < array_size and "," or ""))
            end
        end
    end
    
    if not second_time then
        print("}")
    end
end

return deep_inspect
