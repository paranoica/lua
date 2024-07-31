local warning = function(message)
    print(string.format("[!] %s", message))
end

local new_class = function()
    local this_metatable = {}
    local metatable_cache = {}
    local repointed_metatable = {}

    this_metatable.__metatable = false
    metatable_cache.block = function(self, name)
        if type(name) ~= "string" then
            warning(string.format("Class name must be a string, instead of yours ::%s::", type(name)))
            return
        end

        if rawget(self, name) ~= nil then
            warning(string.format("Class with this name is already exists!", type(name)))
            return
        end

        return function(content)
            if type(content) ~= "table" then
                warning(string.format("Block in the class must be a table, instead of yours ::%s::", type(content)))
            end

            rawset(self, name, setmetatable(content, {
                __metatable = false,
                __index = function(self, key)
                    return rawget(this_metatable, key) or rawget(repointed_metatable, key)
                end
            }))

            return repointed_metatable
        end
    end

    repointed_metatable = setmetatable(metatable_cache, this_metatable); return repointed_metatable
end

return new_class

--[[ @example
local ctx = new_class()
    :block("test") {
        data = 1,
        fn = function(self)
            return self.data
        end
    }

    :block("test1") {
        a = 5,
        b = 10,
        fn = function(self, c)
            return (a + b) / c
        end
    }

    print(ctx.test:fn()) -> output: 1
    print(ctx.test1:fn(3)) -> output: 5
]]
