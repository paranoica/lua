--- @diagnostic disable-next-line
--- @export : -> automatic
--- @listing : -> disabled

--- @description: cleaning the gargabe from possible contamination from past loads
collectgarbage("collect")

--- @region tools for script
local old_random, random_table, random = math.random do
    --- @description: overriding seed for math["random"]
    if os and os.time and os.clock and collectgarbage then
        math.randomseed(os.time() + os.clock() * 1000000 + collectgarbage("count"))
    end

    --- @hook: overriding math["random"] function for better randomization
    math.random = function()
        if not random_table then
            random_table = {}
            for i = 1, 97 do
                random_table[i] = old_random()
            end
        end

        local x = old_random()
        local i = math.floor(x * 97) + 1

        x, random_table[i] = random_table[i], x

        return x
    end

    --- @param min number
    --- @param max number
    --- @return number
    random = function(min, max)
        local result = min + math.random() * (max - min)
        if min ~= math.floor(min) or max ~= math.floor(max) then
            return result
        end
        return math.floor(result)
    end
end

local warning, valid_input, clamp do
    --- @param message string
    --- @return @void
    warning = function(message)
        print(string.format("[!] %s", message))
    end

    --- @alias Value angle(type: p, y, r; data: number):void
    --- @alias Value vector(type: x, y, z; data: number):void
    --- @param input Value
    --- @return booolean, message
    valid_input = function(input)
        if type(input) == "nil" then
            return true
        end
        
        if type(input) == "number" then
            return input ~= math.huge, "The argument in the vector is very large!"
        end
    
        return false, ("The argument was expected to be a number, but %s (%s) was received!"):format(input, type(input))
    end

    --- @param value number
    --- @param min number
    --- @param max number
    --- @return number
    clamp = function(value, min, max)
        return math.min(math.max(min, value or 0), max)
    end
end
--- @endregion

--- @region: creating modules
local angle = {}
local vector = {}
--- @endregion

--- @region: updating {angle} module
do
    --- @param content table
    --- @return boolean
    local is_angle = function(content)
        return getmetatable(content) == angle
    end

    --- @class angle : p, y, r
    --- @type p -> pitch, y -> yaw, r -> roll
    --- @param p number {-89, 89}
    --- @param y number {-180, 180}
    --- @param r number {-90, 90}
    setmetatable(angle, angle); angle.__index = angle; angle.__call = function(self, p, y, r)
        local f_valid, f_msg = valid_input(p)
        if not f_valid then
            warning(f_msg)
            return
        end

        local s_valid, s_msg = valid_input(y)
        if not s_valid then
            warning(s_msg)
            return
        end

        local t_valid, t_msg = valid_input(r)
        if not t_valid then
            warning(t_msg)
            return
        end

        local p = p and clamp(p, -89, 89) or 0
        local y = y and clamp(y, -180, 180) or 0
        local r = r and clamp(r, -90, 90) or 0

        return setmetatable({
            p = p, 
            y = y, 
            r = r
        }, angle)
    end

    --- @param self angle
    --- @return angle
    angle.__tostring = function(self)
        return string.format("angle(p: %f, y: %f, r: %f)", self.p, self.y, self.r)
    end

    --- @param self angle
    --- @return angle
    angle.__concat = function(v1, v2)
        return tostring(v1) .. " | " .. tostring(v2)
    end

    --- @param self angle
    --- @return -angle
    angle.__unm = function(self)
        return angle(-self.p, -self.y, -self.r)
    end

    --- @param self angle
    --- @return number
    angle.__len = function(self)
        return self:length()
    end

    --- @param self angle
    --- @return META_METHOD[{META_OPERATION}]
    for metamethod, metafunction in pairs({
        ["__add"] = function(a, b) return angle(a[1] + b[1], a[2] + b[2], a[3] + b[3]) end,
        ["__sub"] = function(a, b) return angle(a[1] - b[1], a[2] - b[2], a[3] - b[3]) end,
        ["__mul"] = function(a, b) return angle(a[1] * b[1], a[2] * b[2], a[3] * b[3]) end,
        ["__div"] = function(a, b) return angle(a[1] / b[1], a[2] / b[2], a[3] / b[3]) end,
        ["__mod"] = function(a, b) return angle(a[1] % b[1], a[2] % b[2], a[3] % b[3]) end,
        ["__pow"] = function(a, b) return angle(a[1] ^ b[1], a[2] ^ b[2], a[3] ^ b[3]) end,

        ["__eq"] = function(a, b) return a[1] == b[1] and a[2] == b[2] and a[3] + b[3] end,
        ["__lt"] = function(a, b) return a[1] < b[1] and a[2] < b[2] and a[3] < b[3] end,
        ["__le"] = function(a, b) return a[1] <= b[1] and a[2] <= b[2] and a[3] <= b[3] end
    }) do
        angle[metamethod] = function(first, second)
            local first = type(first) == "number" and {first, first, first} or {first.p, first.y, first.r}
            local second = type(second) == "number" and {second, second, second} or {second.p, second.y, second.r}

            return metafunction(first, second)
        end
    end

    --- @param self angle
    --- @return number
    --- @description: converts the angle in {[...]} and returns itself
    function angle:array()
        return {self.p, self.y, self.r}
    end

    --- @param self angle
    --- @param need_return boolean
    --- @return number, number, number
    --- @return @void
    --- @description: return itself as {[...]} if need_return->{true}, otherwise prints one time the content of {[...]}
    function angle:inspect(need_return)
        if need_return then
            return self.p, self.y, self.r
        end

        print(self.p, self.y, self.r)
        return
    end

    --- @param self angle
    --- @return number, number, number
    --- @description: returns the content of {[...]}
    function angle:unpack()
		return self.p, self.y, self.r
	end

    --- @param self angle
    --- @param p number
    --- @param y number
    --- @param r number
    --- @return @class[{angle}]
    --- @description: copying the angle and returns the new one -> you can override any argument
    function angle:copy(p, y, r)
        return angle(
            p or self.p,
            y or self.y,
            r or self.r
        )
    end

    --- @param self angle
    --- @param p number
    --- @param y number
    --- @param r number
    --- @return @class[{angle}]
    --- @description: overrides any argument in the angle{[...]}
    function angle:set(p, y, r)
        if type(p) == "table" and not is_angle(p) then
            warning("The function only supports [angle]-data!")
            return self
        end

        self.p = type(p) == "table" and p.p or (type(p) == "number" and p or self.p)
        self.y = type(p) == "table" and p.y or (type(y) == "number" and y or self.y)
        self.r = type(p) == "table" and p.r or (type(r) == "number" and r or self.r)

        return self
    end

    --- @param self angle
    --- @param p number
    --- @param y number
    --- @param r number
    --- @return @class[{angle}]
    --- @description: adds to angle[{...}] arguments[{...}] [angle(1, 2, 3):offset(4, 5, 6)]->[angle(5, 7, 9)]
    function angle:offset(p, y, r)
        if type(p) == "table" and not is_angle(p) then
            warning("The function only supports [angle]-data!")
            return self
        end

        self.p = self.p + (type(p) == "table" and p.p or type(p) == "number" and p or 0)
        self.y = self.y + (type(p) == "table" and p.y or type(y) == "number" and y or 0)
        self.r = self.r + (type(p) == "table" and p.r or type(r) == "number" and r or 0)

        return self
    end

    --- @param self angle
    --- @return @class[{angle}]
    --- @description: extracts negative numbers into positive ones
    function angle:abs()
        self.p = math.abs(self.p)
        self.y = math.abs(self.y)
        self.r = math.abs(self.r)

        return self
    end

    --- @param self angle
    --- @return @class[{angle}]
    --- @description: round number in the lower position [angle(1.5, 2.5, 3.5):floor()]->[angle(1, 2, 3)]
    function angle:floor()
        self.p = math.floor(self.p)
        self.y = math.floor(self.y)
        self.r = math.floor(self.r)

        return self
    end

    --- @param self angle
    --- @return @class[{angle}]
    --- @description: round number in the higher position [angle(1.5, 2.5, 3.5):floor()]->[angle(2, 3, 4)]
    function angle:ceil()
        self.p = math.ceil(self.p)
        self.y = math.ceil(self.y)
        self.r = math.ceil(self.r)

        return self
    end

    --- @param self angle
    --- @param slow_method boolean
    --- @param precision number
    --- @return @class[{angle}]
    --- @description: round number in the faor position [angle(1.3, 2.6, 3.25):floor()]->[angle(1, 3, 3)]
    --- @description: [{slow_method}]-> making really accurate calculations
    --- @description: [{precision}]-> last point of rounding break
    function angle:round(slow_method, precision)
        if slow_method then
            local multiplier = 10 ^ (precision or 0)

            self.p = (self.p >= 0 and math.floor(self.p * multiplier + 0.5) or math.ceil(self.p * multiplier - 0.5)) / multiplier
            self.y = (self.y >= 0 and math.floor(self.y * multiplier + 0.5) or math.ceil(self.y * multiplier - 0.5)) / multiplier
            self.r = (self.r >= 0 and math.floor(self.r * multiplier + 0.5) or math.ceil(self.r * multiplier - 0.5)) / multiplier
        else
            self.p = math.floor(self.p + 0.5)
            self.y = math.floor(self.y + 0.5)
            self.r = math.floor(self.r + 0.5)
        end

        return self
    end

    --- @param self angle
    --- @return @class[{angle}]
    --- @description: normalizes every argument of class[{angle}]
    function angle:normalize()
        self.p = clamp(self.p, -89, 89)
        self.r = clamp(self.r, -90, 90)

        while self.y > 180 do
            self.y = self.y - 360
        end
    
        while self.y < -180 do
            self.y = self.y + 360
        end

        return self
    end

    --- @param self angle
    --- @param new angle to comparise
    --- @return @class[{angle}]
    --- @description: find the difference between two class[{angle}], and returns new normalized differenced class[{angle}]
    function angle:difference(new)
        if not is_angle(new) then
            warning("The function only supports [angle]-data!")
            return self
        end

        return (new - self):normalize()
    end

    --- @param self angle
    --- @param new angle to comparise
    --- @return @class[{angle}]
    --- @description: find the difference between two class[{angle}], and returns new normalized differenced class[{angle}[::abs()]]
    function angle:abs_difference(new)
        if not is_angle(new) then
            warning("The function only supports [angle]-data!")
            return self
        end

        return (new - self):normalize():abs()
    end

    --- @param self angle
    --- @param new angle
    --- @param weight interpolate speed
    --- @return @class[{angle}]
    --- @description: create the interpolation process between two class[{angle}]
    function angle:lerp(new, weight)
        local delta = self:difference(new)
  
        if delta.p > weight then
            delta.p = delta.p + weight
        elseif delta.p < -weight then
            delta.p = delta.p - weight
        else
            delta.p = new.p
        end
    
        if delta.y > weight then
            delta.y = delta.y + weight
        elseif delta.y < -weight then
            delta.y = delta.y - weight
        else
            delta.y = new.y
        end

        if delta.r > weight then
            delta.r = delta.r + weight
        elseif delta.r < -weight then
            delta.r = delta.r - weight
        else
            delta.r = new.r
        end
    
        self.p = delta.p
        self.y = delta.y
        self.r = delta.r
    
        return self
    end

    --- @param self angle
    --- @return number
    --- @description: find the start (system of degrees) in the circle system
    function angle:start_degrees()
        self.y = self.y > 180 and self.y - 360 or self.y
        return self.y
    end

    --- @param self angle
    --- @return number
    --- @description: find the accurate bearing, example-> localPlayer:getCameraAngles():bearing()
    function angle:bearing()
        self.y = ((180 - self.y + 90) % 360 + 360) % 360
        return math.floor(self:start_degrees() + 180 + 0.5)
    end

    --- @param self angle
    --- @return number
    --- @description: find if bearing are strictly perpendicular, so we can find where cardinal directions are located
    function angle:cardinal_direction()
        local bearing = self:bearing()
        return bearing == 0 or bearing == 90 or bearing == 180 or bearing == 270 or bearing == 360
    end

    --- @param self angle
    --- @return number
    --- @description: find exactly cardinal direction
    function angle:bearing_at_cardinal_direction()
        local bearing = self:bearing()
        if ((bearing >= 315 and bearing <= 360) or (bearing >= 0 and bearing <= 45)) then
            return "North"
        elseif (bearing >= 45 and bearing <= 135) then
            return "East"
        elseif (bearing >= 135 and bearing <= 225) then
            return "South"
        else
            return "West"
        end
    end

    --- @param self angle
    --- @return number
    --- @description: convert the angle into a forward vector
    function angle:forward()
        local sin_yaw = math.sin(math.rad(self.y))
        local cos_yaw = math.cos(math.rad(self.y))

        local sin_pitch = math.sin(math.rad(self.p))
        local cos_pitch = math.cos(math.rad(self.p))
    
        return vector(cos_pitch * cos_yaw, cos_pitch * sin_yaw, -sin_pitch)
    end

    --- @param self angle
    --- @return number
    --- @description: convert the angle into a backward vector
    function angle:backward()
        return -self:forward()
    end

    --- @param self angle
    --- @return number
    --- @description: convert the angle into a right vector
    function angle:right()
        local sin_yaw = math.sin(math.rad(self.y))
        local cos_yaw = math.cos(math.rad(self.y))

        local sin_pitch = math.sin(math.rad(self.p))
        local cos_pitch = math.cos(math.rad(self.p))
    
        return vector(sin_pitch * cos_yaw * -1 + sin_yaw, sin_pitch * sin_yaw * -1 + -1 * cos_yaw, -1 * cos_pitch)
    end

    --- @param self angle
    --- @return number
    --- @description: convert the angle into a left vector
    function angle:left()
        return -self:right()
    end

    --- @param self angle
    --- @return number
    --- @description: convert the angle into a up vector
    function angle:up()
        local sin_yaw = math.sin(math.rad(self.y))
        local cos_yaw = math.cos(math.rad(self.y))

        local sin_pitch = math.sin(math.rad(self.p))
        local cos_pitch = math.cos(math.rad(self.p))
    
        return vector(sin_pitch * cos_yaw + sin_yaw, sin_pitch * sin_yaw + cos_yaw * -1, cos_pitch)
    end

    --- @param self angle
    --- @return number
    --- @description: convert the angle into a down vector
    function angle:down()
        return -self:up()
    end

    --- @param self angle
    --- @return number
    --- @description: find the FOV difference between two vectors (localPlayer:getViewOffset(), localPlayer:getViewPosition()) and one angle (localplayer:getCameraAngles())
    function angle:fov(v1, v2)
        local delta = v1:difference(v2)
        return math.max(0, math.deg(math.acos(self:forward():dot(delta) / delta:length())))
    end
end
--- @endregion

--- @region: vector
do
    --- @param content table
    --- @return boolean
    local is_vector = function(content)
        return getmetatable(content) == vector
    end

    --- @class vector : x, y, z
    --- @type x -> x-coordinate, y -> y-coordinate, z -> z-coordinate
    --- @param x number {-inf, inf}
    --- @param y number {-inf, inf}
    --- @param z number {-inf, inf}
    setmetatable(vector, vector); vector.__index = vector; vector.__call = function(self, x, y, z)
        local f_valid, f_msg = valid_input(x)
        if not f_valid then
            warning(f_msg)
            return
        end

        local s_valid, s_msg = valid_input(y)
        if not s_valid then
            warning(s_msg)
            return
        end

        local t_valid, t_msg = valid_input(z)
        if not t_valid then
            warning(t_msg)
            return
        end

        return setmetatable({
            x = x or 0,
            y = y or 0,
            z = z or 0
        }, vector)
    end

    --- @param self vector
    --- @return vector
    vector.__tostring = function(self)
        return string.format("vector(x: %f, y: %f, z: %f)", self.x, self.y, self.z)
    end
    
    --- @param self vector
    --- @return vector
    vector.__concat = function(v1, v2)
        return tostring(v1) .. " | " .. tostring(v2)
    end

    --- @param self vector
    --- @return -vector
    vector.__unm = function(self)
        return vector(-self.x, -self.y, -self.z)
    end

    --- @param self vector
    --- @return number
    vector.__len = function(self)
        return self:length()
    end

    --- @param self vector
    --- @return META_METHOD[{META_OPERATION}]
    for metamethod, metafunction in pairs({
        ["__add"] = function(a, b) return vector(a[1] + b[1], a[2] + b[2], a[3] + b[3]) end,
        ["__sub"] = function(a, b) return vector(a[1] - b[1], a[2] - b[2], a[3] - b[3]) end,
        ["__mul"] = function(a, b) return vector(a[1] * b[1], a[2] * b[2], a[3] * b[3]) end,
        ["__div"] = function(a, b) return vector(a[1] / b[1], a[2] / b[2], a[3] / b[3]) end,
        ["__mod"] = function(a, b) return vector(a[1] % b[1], a[2] % b[2], a[3] % b[3]) end,
        ["__pow"] = function(a, b) return vector(a[1] ^ b[1], a[2] ^ b[2], a[3] ^ b[3]) end,

        ["__eq"] = function(a, b) return a[1] == b[1] and a[2] == b[2] and a[3] + b[3] end,
        ["__lt"] = function(a, b) return a[1] < b[1] and a[2] < b[2] and a[3] < b[3] end,
        ["__le"] = function(a, b) return a[1] <= b[1] and a[2] <= b[2] and a[3] <= b[3] end
    }) do
        vector[metamethod] = function(first, second)
            local first = type(first) == "number" and {first, first, first} or {first.x, first.y, first.z}
            local second = type(second) == "number" and {second, second, second} or {second.x, second.y, second.z}

            return metafunction(first, second)
        end
    end

    --- @param self vector
    --- @param min number
    --- @param max number
    --- @return @class[{vector}]
    --- @description: randomizing the arguments of [{...}]
    function vector:random(min, max)
        min = min or -100
        max = max or 100

        self.x = random(min, max)
        self.y = random(min, max)
        self.z = random(min, max)

        return self
    end

    --- @param self vector
    --- @return number
    --- @description: converts the vector in {[...]} and returns itself
    function vector:array()
        return {self.x, self.y, self.z}
    end

    --- @param self vector
    --- @param need_return boolean
    --- @return number, number, number
    --- @return @void
    --- @description: return itself as {[...]} if need_return->{true}, otherwise prints one time the content of {[...]}
    function vector:inspect(need_return)
        if need_return then
            return self.x, self.y, self.z
        end

        print(self.x, self.y, self.z)
        return
    end

    --- @param self vector
    --- @return number, number, number
    --- @description: returns the content of {[...]}
    function vector:unpack()
		return self.x, self.y, self.z
	end

    --- @param self vector
    --- @param p number
    --- @param y number
    --- @param r number
    --- @return @class[{angle}]
    --- @description: copying the vector and returns the new one -> you can override any argument
    function vector:copy(x, y, z)
        return vector(
            x or self.x,
            y or self.y,
            z or self.z
        )
    end

    --- @param self vector
    --- @param p number
    --- @param y number
    --- @param r number
    --- @return @class[{vector}]
    --- @description: overrides any argument in the vector{[...]}
    function vector:set(x, y, z)
        if type(x) == "table" and not is_vector(x) then
            warning("The function only supports [vector]-data!")
            return self
        end

        self.x = type(x) == "table" and x.x or (type(x) == "number" and x or self.x)
        self.y = type(x) == "table" and x.y or (type(y) == "number" and y or self.y)
        self.z = type(x) == "table" and x.z or (type(z) == "number" and z or self.z)

        return self
    end

    --- @param self vector
    --- @param p number
    --- @param y number
    --- @param r number
    --- @return @class[{vector}]
    --- @description: adds to vector[{...}] arguments[{...}] [vector(1, 2, 3):offset(4, 5, 6)]->[vector(5, 7, 9)]
    function vector:offset(x, y, z)
        if type(x) == "table" and not is_vector(x) then
            warning("The function only supports [vector]-data!")
            return self
        end

        self.x = self.x + (type(x) == "table" and x.x or type(x) == "number" and x or 0)
        self.y = self.y + (type(x) == "table" and x.y or type(y) == "number" and y or 0)
        self.z = self.z + (type(x) == "table" and x.z or type(z) == "number" and z or 0)

        return self
    end

    --- @param self vector
    --- @return @class[{vector}]
    --- @description: extracts negative numbers into positive ones
    function vector:abs()
        self.x = math.abs(self.x)
        self.y = math.abs(self.y)
        self.z = math.abs(self.z)

        return self
    end

    --- @param self vector
    --- @return @class[{vector}]
    --- @description: round number in the lower position [vector(1.5, 2.5, 3.5):floor()]->[vector(1, 2, 3)]
    function vector:floor()
        self.x = math.floor(self.x)
        self.y = math.floor(self.y)
        self.z = math.floor(self.z)

        return self
    end

    --- @param self vector
    --- @return @class[{vector}]
    --- @description: round number in the higher position [vector(1.5, 2.5, 3.5):floor()]->[vector(2, 3, 4)]
    function vector:ceil()
        self.x = math.ceil(self.x)
        self.y = math.ceil(self.y)
        self.z = math.ceil(self.z)

        return self
    end

    --- @param self vector
    --- @param slow_method boolean
    --- @param precision number
    --- @return @class[{vector}]
    --- @description: round number in the faor position [vector(1.3, 2.6, 3.25):floor()]->[vector(1, 3, 3)]
    --- @description: [{slow_method}]-> making really accurate calculations
    --- @description: [{precision}]-> last point of rounding break
    function vector:round(slow_method, precision)
        if slow_method then
            local multiplier = 10 ^ (precision or 0)

            self.x = (self.x >= 0 and math.floor(self.x * multiplier + 0.5) or math.ceil(self.x * multiplier - 0.5)) / multiplier
            self.y = (self.y >= 0 and math.floor(self.y * multiplier + 0.5) or math.ceil(self.y * multiplier - 0.5)) / multiplier
            self.z = (self.z >= 0 and math.floor(self.z * multiplier + 0.5) or math.ceil(self.z * multiplier - 0.5)) / multiplier
        else
            self.x = math.floor(self.x + 0.5)
            self.y = math.floor(self.y + 0.5)
            self.z = math.floor(self.z + 0.5)
        end

        return self
    end

    --- @param self vector
    --- @return @class[{vector}]
    --- @description: converts vector to 2D world coordinates
    function vector:to_2d()
        return self:copy(_, _, 0)
    end

    --- @param self vector
    --- @param new vector
    --- @return @class[{vector}]
    --- @description: returns the forward vector from itself to another vector
    function vector:forward(new)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return new - self
    end

    --- @param self vector
    --- @param is_2d boolean
    --- @return @class[{vector}]
    --- @description: returns the inversed vector from itself
    function vector:inverse(is_2d)
        return vector(1 / self.x, 1 / self.y, 1 / self.z):set(_, _, is_2d and 0)
    end

    --- @param self vector
    --- @param is_2d boolean
    --- @return number
    --- @description: returns the Euclidean length of the vector (@may return the length in two dimensions, if [is_2d]->true)
    function vector:length(is_2d)
        return is_2d and math.sqrt(self.x ^ 2 + self.y ^ 2) or math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
    end

    --- @param self vector
    --- @param length number
    --- @return number
    --- @description: sets the new Euclidean length to the itself
    function vector:set_length(length)
        self:normalize()
        self:set(self * length)
        
        return self
    end

    --- @param self vector
    --- @param is_2d boolean
    --- @return number
    --- @description: returns the squared Euclidean length of the vector (@may return the length in two dimensions, if [is_2d]->true)
    function vector:sqr_length(is_2d)
        return is_2d and self.x ^ 2 + self.y ^ 2 or self.x ^ 2 + self.y ^ 2 + self.z ^ 2
    end

    --- @param self vector
    --- @param max number
    --- @param is_2d boolean
    --- @return number
    --- @description: clamps the max length of vector
    function vector:length_limit(max, is_2d)
        local length = self:length(is_2d)
        if length > max ^ 2 then
            self:set_length(max)
        end
        return self
    end

    --- @param self vector
    --- @param is_2d boolean
    --- @return boolean
    --- @description: checks if the length of vector is === 1
    function vector:is_unit(is_2d)
        return self:sqr_length(is_2d) == 1
    end

    --- @param self vector
    --- @param min number
    --- @param max number
    --- @return @class[{vector}]
    --- @description: clamps the [min,max] values of vector
    function vector:clamp(min, max)
        if (type(min) == "table" and not is_vector(min)) or (type(max) == "table" and not is_vector(max)) then
            warning("The function only supports [vector]-data!")
            return self
        end

        self.x = clamp(self.x, type(min) == "table" and min.x or min, type(max) == "table" and max.x or max)
        self.y = clamp(self.y, type(min) == "table" and min.y or min, type(max) == "table" and max.y or max)
        self.z = clamp(self.z, type(min) == "table" and min.z or min, type(max) == "table" and max.z or max)
        
        return self
    end

    --- @param self vector
    --- @param return_length boolean
    --- @return @class[{vector}]
    --- @return number
    --- @description: normalizes the vector and returns the length {[return_length]->true} of the vector.
    function vector:normalize(return_length)
        local length = self:length()

        self.x = length == 0 and 0 or self.x / length
        self.y = length == 0 and 0 or self.y / length
        self.z = length == 0 and 1 or self.z / length

        return return_length and length or self
    end

    --- @param self vector
    --- @param return_length boolean
    --- @return @class[{vector}]
    --- @return number
    --- @description: normalizes and copies the vector and returns the length {[return_length]->true} of the vector.
    function vector:normalized(return_length)
        return self:copy():normalize(return_length)
    end

    --- @param self vector
    --- @param new vector
    --- @param range number
    --- @return boolean
    --- @description: checks if first vector in the range {[range]} of the second vector
    function vector:in_range(new, range)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return (self - new):length() <= range
    end

    --- @param self vector
    --- @param new vector
    --- @param range number
    --- @return boolean
    --- @description: checks if first vector out the range {[range]} of the second vector
    function vector:out_range(new, range)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return (self - new):length() > range
    end

    --- @param self vector
    --- @param new vector
    --- @param range number
    --- @return boolean
    --- @description: returns true, if first vector is closer to [self]vector than second vector; within tolerance if specified
    function vector:closest(v1, v2, tolerance)
        return self:distance(v1) < self:distance(v2) - (tolerance or 1)
    end

    --- @param self vector
    --- @param new vector
    --- @param range number
    --- @return boolean
    --- @description: returns true, if first vector is in front of [self]vector compared to the second vector
    function vector:in_front(v1, v2)
        return self:distance(v1) < self:distance(v2) and self:distance(v1) < v1:distance(v2)
    end

    --- @param self vector
    --- @param new vector
    --- @return @class[{vector}]
    --- @description: get the size of two vectors
    function vector:dimensions(new)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return (self - new):abs()
    end

    --- @param self vector
    --- @param new vector
    --- @return @class[{vector}]
    --- @description: get the normalized difference of two vectors
    function vector:difference(new)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return (new - self):normalize()
    end

    --- @param self vector
    --- @param new vector
    --- @return @class[{vector}]
    --- @description: get the absed normalized difference of two vectors
    function vector:abs_difference(new)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return (new - self):normalize():abs()
    end

    --- @param self vector
    --- @param new vector
    --- @param is_2d boolean
    --- @return number
    --- @description: returns the distance between two vectors
    function vector:distance(new, is_2d)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return (new - self):length(is_2d)
    end

    --- @param self vector
    --- @param new vector
    --- @param is_2d boolean
    --- @return number
    --- @description: returns the squared distance between two vectors
    function vector:sqr_distance(new, is_2d)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return (new - self):sqr_length(is_2d)
    end

    --- @param self vector
    --- @param ray_start vector
    --- @param ray_direction vector
    --- @return number
    --- @description: returns the distance to a ray
    function vector:distance_to_ray(ray_start, ray_direction)
        if not is_vector(ray_start) or not is_vector(ray_direction) then
            warning("The function only supports [vector]-data!")
            return self
        end

        local direction = ray_direction:normalize()
        local along_ray = (self - ray_start):dot(direction)

        local closest_point = ray_start + direction * along_ray
        local distance_result = (self - closest_point):length()

        return distance_result
    end

    --- @param self vector
    --- @param new vector
    --- @return number
    --- @description: returns the dot product of the two given vectors
    function vector:dot(new)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return self.x * new.x + self.y * new.y + self.z * new.z
    end

    --- @param self vector
    --- @param new vector
    --- @return @class[{vector}]
    --- @description: returns the cross product of two given vectors
    function vector:cross(new)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return vector(
            self.y * new.z - self.z * new.y,
            self.z * new.x - self.x * new.z,
            self.x * new.y - self.y * new.x
        )
    end

    --- @param self vector
    --- @param ray_start vector
    --- @param ray_end vector
    --- @return number
    --- @description: returns the vector of the closest point along a ray
    function vector:closest_ray(ray_start, ray_end)
        if not is_vector(ray_start) or not is_vector(ray_end) then
            warning("The function only supports [vector]-data!")
            return self
        end

        local direction = ray_end - ray_start
        local length = direction:length()

        direction:normalize()
        local along_ray = (self - ray_start):dot(direction)
        
        return along_ray < 0 and ray_start or along_ray > length and ray_end or ray_start + direction * along_ray
    end

    --- @param self vector
    --- @param new vector
    --- @param weight interpolate speed
    --- @return number
    --- @description: returns the interpolation progress
    function vector:get_lerp(new, weight)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        return self + (new - self) * weight
    end

    --- @param self vector
    --- @param new vector
    --- @param weight interpolate speed
    --- @return @class[{vector}]
    --- @description: create the interpolation process between two class[{vector}]
    function vector:lerp(new, weight)
        if not is_vector(new) then
            warning("The function only supports [vector]-data!")
            return self
        end

        local lerp = self:get_lerp(new, weight)

        self.x = lerp.x
        self.y = lerp.y
        self.z = lerp.z

        return self
    end

    --- @param self vector
    --- @param ray_end vector
    --- @param m number
    --- @param n number
    --- @return @class[{vector}]
    --- @description: finds the division point of a segment connecting two vectors
    function vector:internal_ray_division(ray_end, m, n)
        return ((self * n + ray_end * m) / (m + n)):copy()
    end

    --- @param self vector
    --- @param ray_end vector
    --- @param segments number
    --- @return @class[{vector}]
    --- @description: divides a segment connecting two vectors into a given number of equal parts.
    function vector:ray_segmented(ray_end, segments)
        local segmented_rays = {}
        for i = 1, segments do
            segmented_rays[i] = self:internal_ray_division(ray_end, i, segments - i)
        end
        return segmented_rays
    end

    --- @param self vector
    --- @param ray_end vector
    --- @param ratio number
    --- @return @class[{vector}]
    --- @description: finds a point dividing the segment between two vectors in a given ratio.
    function vector:ray_divided(ray_end, ratio)
        return (self * ratio + ray_end) / (1 + ratio)
    end

    --- @param self vector
    --- @param rotation_angle number
    --- @param extension number
    --- @return @class[{vector}]
    --- @description: performs a vector rotation by a given angle
    function vector:rotate(rotation_angle, extension)
        if getmetatable(rotation_angle) == angle then
            self = self + rotation_angle:forward() * (extension or 1)
            return self:copy()
        end

        if type(rotation_angle) == "number" then
            local cos = math.cos(rotation_angle)
            local sin = math.sin(rotation_angle)
            
            return vector(
                self.x * cos - self.y * sin,
                self.x * sin + self.y * cos,
                self.z
            )
        end
    end

    --- @param self vector
    --- @param new vector
    --- @return @class[{angle}]
    --- @description: returns the angle vector representing the normal of the vector
    function vector:angle_product(new)
        if not is_vector(new) then  
            warning("The function only supports [vector]-data!")
            return self
        end

        local delta = (new - self):copy()
        return angle(
            math.deg(math.atan2(-delta.z, math.sqrt(delta.x * delta.x + delta.y * delta.y))),
            math.deg(math.atan2(delta.y, delta.x))
        )
    end
end
--- @endregion

--- @region: __ENV
local __ENV = {
    __AUTHOR = "paranoica",
    __VERSION = "[vector_angle].lua 28.07.2024 1.0",
    __URL = "https://github.com/paranoica/lua/modules/vector_angle.lua",
    __LICENSE = [[
        MIT License

        Copyright (c) 2024 paranoica

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
    ]]
}

angle["__ENV"] = __ENV
vector["__ENV"] = __ENV
--- @endregion

--- @region: collect garbage and finish the library
collectgarbage("collect"); return function(local_definition)
    if local_definition then
        return {
            angle = angle,
            vector = vector
        }
    else
        _G["angle"] = angle
        _G["vector"] = vector
    end
end
--- @endregion

--- @diagnostic enable
--- @export : -> disabled
--- @listing : -> enabled
