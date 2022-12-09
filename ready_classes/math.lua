local math_helpers do
    math_helpers = {}
    math_helpers.is_number_valid = function(value)
        return type(value) == "number" and value ~= math.huge or false
    end

    math_helpers.get_deep_type = function(value)
        return type(value) == "number" and (value % 1 == 0 and "int" or "float") or type(value)
    end

    math_helpers.clamp = function(value, min, max)
        return math.min(max, math.max(value, min))
    end

    math_helpers.fast_round = function(value)
        return math.floor(value + 0.5)
    end

    math_helpers.slow_round = function(value, precision)
        local multiplier = 10 ^ (precision or 0)
        return (value >= 0 and math.floor(value * multiplier + 0.5) or math.ceil(value * multiplier - 0.5)) / multiplier
    end

    math_helpers.normalize = function(value, area)
        area = area or 360

        while value > area / 2 do
            value = value - area
        end

        while value < -(area / 2) do
            value = value + area
        end

        return value
    end

    math_helpers.get_percentage = function(value, max)
        return 1 - (max - value) / max
    end

    math_helpers.get_negative_percentage = function(value, max)
        return 0 - (max - value) / max
    end

    math_helpers.map = function(value, in_min, in_max, out_min, out_max, should_clamp)
        local area = out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min)
        return should_clamp and math_helpers.clamp(area, in_min, in_max) or area
    end

    math_helpers.set_precision = function(value, precision)
        return tonumber(string.format("%." .. (precision or 0) .. "f", value))
    end
end

return function(is_local_definition)
    _G["INT_MAX"] = 2 ^ 1024
    _G["INT_MIN"] = -(2 ^ 1024)

    if is_local_definition then
        return math_helpers
    else
        for class, object in pairs(math_helpers) do
            _G["math"][class] = object
        end
    end
end
