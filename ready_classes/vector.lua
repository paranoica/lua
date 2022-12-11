--- @note: vector for 2d and 3d system
--- @note: library will be better and safer, if you handle return-result by safe_library.lua

local vector do
    vector = {}
    vector.__index = vector

    vector.check_arguments = function(x, y, z)
        local arguments = {x, y, z}
        for _, object in pairs(arguments) do
            if type(object) ~= "number" or object == math.huge then
                print(("Error: the argument in the vector was expected to be a number, but %s:%s was received!"):format(object, type(object)))
                return false
            end
        end

        return true
    end

    vector.__tostring = function(self)
        return ("vector(x: %s, y: %s, z: %s)"):format(self.x, self.y, self.z)
    end

    vector.__unm = function(self)
        return vector.new(-self.x, -self.y, -self.z)
    end

    for operation, process in pairs({
        ["__add"] = function(a, b) return vector.new(a[1] + b[1], a[2] + b[2], a[3] + b[3]) end,
        ["__sub"] = function(a, b) return vector.new(a[1] - b[1], a[2] - b[2], a[3] - b[3]) end,
        ["__mul"] = function(a, b) return vector.new(a[1] * b[1], a[2] * b[2], a[3] * b[3]) end,
        ["__div"] = function(a, b) return vector.new(a[1] / b[1], a[2] / b[2], a[3] / b[3]) end,
        ["__mod"] = function(a, b) return vector.new(a[1] % b[1], a[2] % b[2], a[3] % b[3]) end,
        ["__pow"] = function(a, b) return vector.new(a[1] ^ b[1], a[2] ^ b[2], a[3] ^ b[3]) end,

        ["__eq"] = function(a, b) return a[1] == b[1] and a[2] == b[2] and a[3] + b[3] end,
        ["__lt"] = function(a, b) return a[1] < b[1] and a[2] < b[2] and a[3] < b[3] end,
        ["__le"] = function(a, b) return a[1] <= b[1] and a[2] <= b[2] and a[3] <= b[3] end
    }) do
        vector[operation] = function(first, second)
            local first = type(first) == "number" and {first, first, first} or {first.x, first.y, first.z}
            local second = type(second) == "number" and {second, second, second} or {second.x, second.y, second.z}

            return process(first, second)
        end
    end
	
	function vector:unpack()
		return self.x, self.y, self.z
	end
    
    function vector:clone(x, y, z)
        return vector.new(
            type(x) == "nil" and self.x or x,
            type(y) == "nil" and self.y or y,
            type(z) == "nil" and self.z or z
        )
    end

    function vector:set(x, y, z)
        self.x = type(x) == "table" and x.x or (type(x) == "number" and x or self.x)
        self.y = type(x) == "table" and x.y or (type(y) == "number" and y or self.y)
        self.z = type(x) == "table" and x.z or (type(z) == "number" and z or self.z)

        return self
    end

    function vector:offset(x, y, z)
        self.x = self.x + (type(x) == "table" and x.x or type(x) == "number" and x or 0)
        self.y = self.y + (type(x) == "table" and x.y or type(y) == "number" and y or 0)
        self.z = self.z + (type(x) == "table" and x.z or type(z) == "number" and z or 0)

        return self
    end

    function vector:abs()
        self.x = math.abs(self.x)
        self.y = math.abs(self.y)
        self.z = math.abs(self.z)

        return self
    end

    function vector:floor()
        self.x = math.floor(self.x)
        self.y = math.floor(self.y)
        self.z = math.floor(self.z)

        return self
    end

    function vector:ceil()
        self.x = math.ceil(self.x)
        self.y = math.ceil(self.y)
        self.z = math.ceil(self.z)

        return self
    end
    
    function vector:fast_round()
        self.x = math.floor(self.x + 0.5)
        self.y = math.floor(self.y + 0.5)
        self.z = math.floor(self.z + 0.5)

        return self
    end

    function vector:slow_round(precision)
        local multiplier = 10 ^ (precision or 0)

        self.x = (self.x >= 0 and math.floor(self.x * multiplier + 0.5) or math.ceil(self.x * multiplier - 0.5)) / multiplier
        self.y = (self.y >= 0 and math.floor(self.y * multiplier + 0.5) or math.ceil(self.y * multiplier - 0.5)) / multiplier
        self.z = (self.z >= 0 and math.floor(self.z * multiplier + 0.5) or math.ceil(self.z * multiplier - 0.5)) / multiplier

        return self
    end

    function vector:get_length()
        return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
    end

    function vector:normalize()
        local length = self:get_length()
        if length == 0 then
            self.x = 0
            self.y = 0
            self.z = 1
        else
            self.x = self.x / length
            self.y = self.y / length
            self.z = self.z / length
        end
    end

    function vector:get_dimensions(target)
        return (self - target):abs()
    end

    function vector:get_difference(target)
        return (target - self):normalize()
    end

    function vector:get_distance(target)
        return (target - self):get_length()
    end

    function vector:get_dot_product(target)
        return self.x * target.x + self.y * target.y + self.z * target.z
    end

    function vector:get_cross_product(target)
        return vector.new(
            self.y * target.z - self.z * target.y,
            self.z * target.x - self.x * target.z,
            self.x * target.y - self.y * target.x
        )
    end

    --- @note: you can put by yourself some vector:trace or vector:bullet functions
    --- @note: you can put by yourself some render functions by using world_to_screen
    --- @note: here is function with _G[angle] access only

    --[[
        function vector:get_angle_product(target)
            local delta = target - self
            return angle(
                math.deg(math.atan2(-delta.z, math.sqrt(delta.x ^ 2 + delta.y ^ 2))),
  		        math.deg(math.atan2(delta.y, delta.x))
            )
        end
    --]]

    function vector:get_closest_ray(start, final)
        local delta = (final - start):normalize()
        local along_ray = (self - start):get_dot_product(delta)
        
        return along_ray < 0 and start or along_ray > (final - start):get_length() and final or final + delta * along_ray
    end

    vector.new = function(x, y, z)
        if not vector.check_arguments(x, y, z) then
            return
        end

        return setmetatable({
            x = x or 0,
            y = y or 0,
            z = z or 0
        }, vector)
    end
end

return vector.new
