--- @diagnostic disable-next-line
--- @export : -> automatic
--- @listing : -> disabled

--- @description: cleaning the gargabe from possible contamination from past loads
collectgarbage("collect")

--- @region: update {math} module
local o_math = {} do
    --- @param x number
    --- @param base number
    --- @return number
    --- @description: returns logarithm of number x to an arbitrary base
    o_math.log_base = function(x, base)
        return math.log(x) / math.log(base)
    end

    --- @param number number
    --- @return boolean
    --- @description: checks validation of number
    o_math.is_number_valid = function(number)
        return type(number) == "number" and number ~= math.huge
    end

    --- @param number number
    --- @return number
    --- @description: returns sign of number
    function math.get_sign(number)
        return number > 0 and 1 or number < 0 and -1 or 0
    end

    --- @param number number
    --- @return string
    --- @description: returns deep type of number
    o_math.get_deep_type = function(number)
        return type(number) == "number" and (number % 1 == 0 and "int" or "float") or type(number)
    end

    --- @param number number
    --- @return number
    --- @description: clamps number with [min, max] arguments
    o_math.clamp = function(number, min, max)
        return math.min(max, math.max(number, min))
    end

    --- @param number number
    --- @return number
    --- @description: returns fast round
    o_math.fast_round = function(number)
        return math.floor(number + 0.5)
    end

    --- @param number number
    --- @param precision number
    --- @return number
    --- @description: returns slow, but accurate round
    o_math.slow_round = function(number, precision)
        local multiplier = 10 ^ (precision or 0)
        return (number >= 0 and math.floor(number * multiplier + 0.5) or math.ceil(number * multiplier - 0.5)) / multiplier
    end

    --- @param number number
    --- @param area number
    --- @return number
    --- @description: returns normalized angle[::yaw]
    o_math.normalize_yaw = function(number, area)
        area = area or 360

        while number > area / 2 do
            number = number - area
        end

        while number < -(area / 2) do
            number = number + area
        end

        return number
    end

    --- @param number number
    --- @param max number
    --- @return number
    --- @description: returns percentage of number
    o_math.get_percentage = function(number, max)
        return 1 - (max - number) / max
    end

    --- @param number number
    --- @param max number
    --- @return number
    --- @description: returns negative percentage of number
    o_math.get_negative_percentage = function(number, max)
        return 0 - (max - number) / max
    end

    --- @param number number
    --- @param in_min number
    --- @param in_max number
    --- @param out_min number
    --- @param out_max number
    --- @param should_clamp boolean
    --- @return number
    --- @description: returns linear transformation of the number from one range to another
    o_math.map = function(number, in_min, in_max, out_min, out_max, should_clamp)
        local area = out_min + (number - in_min) * (out_max - out_min) / (in_max - in_min)
        return should_clamp and o_math.clamp(area, in_min, in_max) or area
    end

    --- @param number number
    --- @param precision number
    --- @return number
    --- @description: returns number with the custom precision
    o_math.set_precision = function(number, precision)
        return tonumber(string.format("%." .. (precision or 0) .. "f", number))
    end

    --- @param number number
    --- @return number
    --- @description: returns smooth monotone function
    o_math.sigmoid = function(number)
        return 1 / (1 + math.exp(-number))
    end
    
    --- @param number number
    --- @return number
    --- @description: returns the derivative of smooth monotone function
    o_math.sigmoid_derivative = function(number)
        local sigmoid = math.sigmoid(number)
        return sigmoid * (1 - sigmoid)
    end

    --- @param a number
    --- @param b number
    --- @return number
    --- @description: finds the least common multiple (LCM) of two numbers
    o_math.lcm = function(a, b)
        local function gcd(a, b)
            if b == 0 then
                return a
            else
                return gcd(b, a % b)
            end
        end
        return math.abs(a * b) / gcd(a, b)
    end

    --- @param a number
    --- @param b number
    --- @return number
    --- @description: finds the greatest common divisor (GCD) of two numbers
    o_math.gcd = function(a, b)
        while b ~= 0 do
            a, b = b, a % b
        end
        return math.abs(a)
    end

    --- @param number number
    --- @return number
    --- @description: returns factorization of the number into prime factors
    o_math.decompose_number = function(number)
        local factors = {}
        for i = 2, number do
            while number % i == 0 do
                factors[#factors + 1] = i
                number = number / i
            end
        end
        return factors
    end

    --- @param f number
    --- @param s number
    --- @param w number
    --- @return number
    --- @description: returns the interpolation between two numbers with setted speed
    o_math.lerp = function(f, s, w)
        return (1 - w) * f + w * s
    end
    
    --- @param array table
    --- @return number, number
    --- @description: finds the most lowest and the most highest numbers in the array
    o_math.min_max = function(array)
        local min, max = array[1], array[1]
        for _, v in ipairs(array) do
            if v < min then min = v end
            if v > max then max = v end
        end
        return min, max
    end

    --- @param array table
    --- @return number
    --- @description: finds the mean value in the array
    o_math.mean_value = function(array)
        local sum = 0
        for _, v in ipairs(array) do
            sum = sum + v
        end
        return sum / #array
    end

    --- @param array table
    --- @return number
    --- @description: finds the median value in the array
    o_math.median_value = function(array)
        table.sort(array)
        
        local length = #array
        if length % 2 == 0 then
            return (array[length / 2] + array[length / 2 + 1]) / 2
        else
            return array[math.ceil(length / 2)]
        end
    end

    --- @param array table
    --- @return number
    --- @description: finds the most repeating value in the array
    o_math.popular_value = function(array)
        local counts = {}
        for _, v in ipairs(array) do
            counts[v] = (counts[v] or 0) + 1
        end

        local max_count, popular = 0, nil
        for k, v in pairs(counts) do
            if v > max_count then
                max_count, popular = v, k
            end
        end

        return popular
    end

    --- @param array table
    --- @return number
    --- @description: calculates the standard deviation of elements in the table
    o_math.standart_deviation = function(array)
        local sum = 0
        local mean = o_math.mean_value(array)

        for _, v in ipairs(array) do
            sum = sum + (v - mean) ^ 2
        end

        return math.sqrt(sum / #array)
    end

    --- @param array table
    --- @return number
    --- @description: calculates the absolute deviation of elements in the table
    o_math.absolute_deviation = function(array)
        local sum = 0
        local mean = math.mean_value(array)

        for _, v in ipairs(array) do
            sum = sum + math.abs(v - mean)
        end

        return sum / #array
    end

    --- @param n number
    --- @param k number
    --- @return number
    --- @description: calculates the binomial coefficient
    o_math.binomial_coefficient = function(n, k)
        local result = 1
        if k > n - k then
            k = n - k
        end

        for i = 1, k do
            result = result * (n - i + 1) / i
        end

        return result
    end

    --- @param array table
    --- @param alpha number
    --- @return number
    --- @description: calculates an exponential moving average for a table of values with a smoothing factor
    o_math.exp_avg_moving = function(array, alpha)
        local ema = array[1]
        for i = 2, #array do
            ema = alpha * array[i] + (1 - alpha) * ema
        end
        return ema
    end

    --- @param a number
    --- @param b number
    --- @param c number
    --- @return @void
    --- @return number
    --- @return number, number
    --- @description: solves quadratic equation
    o_math.quadratic_equation = function(a, b, c)
        local discriminant = b ^ 2 - 4 * a * c
        if discriminant < 0 then
            return
        end

        if discriminant == 0 then
            return -b / (2 * a)
        end

        local sqrt_discriminant = math.sqrt(discriminant)
        return (-b + sqrt_discriminant) / (2 * a), (-b - sqrt_discriminant) / (2 * a)
    end
end
--- @endregion

--- @region: __ENV
local __ENV = {
    __AUTHOR = "paranoica",
    __VERSION = "math.lua 29.07.2024 1.0",
    __URL = "https://github.com/paranoica/lua/modules/math.lua",
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

o_math["__ENV"] = __ENV
--- @endregion

--- @region: collect garbage and finish the library
collectgarbage("collect"); return function(local_definition)
    _G["INT_MAX"] = 2 ^ 1024
    _G["INT_MIN"] = -(2 ^ 1024)
    _G["GOLDEN_RATIO"] = 1.6180339887

    if local_definition then
        return o_math
    else
        for class, object in pairs(o_math) do
            _G["math"][class] = object
        end
    end
end
--- @endregion

--- @diagnostic enable
--- @export : -> disabled
--- @listing : -> enabled
