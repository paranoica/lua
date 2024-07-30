--- @diagnostic disable-next-line
--- @export : -> automatic
--- @listing : -> disabled

--- @description: cleaning the gargabe from possible contamination from past loads
collectgarbage("collect")

--- @region tools for script
local standard_easing, time do
    standard_easing = function(t, b, c, d)
        return c * t / d + b
    end

    time = function()
        --return globals.frametime()
    end
end

local get_type, deep_copy do
    get_type = function(value)
        if type(value) == "boolean" then
            value = value and 1 or 0
        end
        return type(value)
    end

    local function copy_tables(destination, keys, values)
        local values = values or keys
        local metatable = getmetatable(keys)
    
        if metatable and getmetatable(destination) == nil then
            setmetatable(destination, metatable)
        end
    
        for k, v in pairs(keys) do
            if type(v) == "table" then
                destination[k] = copy_tables({}, v, values[k])
            else
                local value = values[k]
                if type(value) == "boolean" then
                    value = value and 1 or 0
                end
    
                destination[k] = value
            end
        end
    
        return destination
    end; deep_copy = copy_tables
end
--- @endregion

--- @region: create and update {easing} module
local easing = {} do
    local function resolve_floats(old, new, easing_fn, timer, duration)
        if type(new) == "boolean" then 
            new = new and 1 or 0 
        end

        if type(old) == "boolean" then 
            old = old and 1 or 0 
        end
    
        local delta = new - old
        local old = easing_fn(timer, old, delta, duration)

        if type(new) == "number" then
            if math.abs(delta) <= 0.001 then
                old = new
            end
    
            if old % 1 < 0.0001 then
                old = math.floor(old)
            elseif old % 1 > 0.9999 then
                old = math.ceil(old)
            end
        end

        return old
    end

    local function process_ease(old, new, o_type, easing_fn, timer, duration)
        if o_type == "table" then
            for k, v in pairs(new) do
                old[k] = old[k] or v
                old[k] = process_ease(
                    type(v), easing_fn,
                    old[k], v,
                    timer, duration
                )
            end
            return old
        end
        return resolve_floats(old, new, easing_fn, timer, duration)
    end

    setmetatable(easing, easing); easing.__index = easing; easing.__call = function(self, default_value)
        return setmetatable({
            easing = standard_easing,
            value = type(default_value) == "boolean" and (default_value and 1 or 0) or type(default_value) ~= "nil" and default_value or 0
        }, easing)
    end

    function easing:set_function(easing_fn)
        self.easing = type(easing_fn) == "function" and easing_fn or self.easing
    end

    function easing:update(new_value, duration, easing_fn)
        if type(new_value) == "boolean" then
            new_value = new_value and 1 or 0
        end

        local timer = time()
        local duration = duration or 0.2

        local value_type = get_type(self.value)
        local target_type = get_type(new_value)

        if value_type ~= target_type then
            return self
        end

        if self.value == new_value then
            return new_value
        end
    
        if timer <= 0 or timer >= duration then
            if value_type == "table" then
                deep_copy(self.value, new_value)
            else
                self.value = new_value
            end
        else
            self.value = process_ease(
                self.value, new_value,
                value_type, easing_fn or self.easing,
                timer, duration
            )
        end
    
        return self.value
    end
end
--- @endregion

--- @region: __ENV

--- @endregion

--- @region: collect garbage and finish the library
collectgarbage("collect"); return function(local_definition)
    if local_definition then
        return easing
    else
        _G["easing"] = easing
    end
end
--- @endregion

--- @diagnostic enable
--- @export : -> disabled
--- @listing : -> enabled
