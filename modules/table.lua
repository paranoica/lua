--- @diagnostic disable-next-line
--- @export : -> automatic
--- @listing : -> disabled

--- @description: cleaning the gargabe from possible contamination from past loads
collectgarbage("collect")

--- @region: update {math} module
local o_table = {} do
    --- @param array table
    --- @return boolean
    --- @description: checks if the argument is table
    o_table.is_table = function(array)
        return type(array) == "table"
    end

    --- @param array table
    --- @return boolean
    --- @description: checks if the array is without erros and [NULL] values
    o_table.is_array = function(array)
        if not o_table.is_table(array) then 
            return false 
        end

        local i = 0
        for _ in pairs(array) do
            i = i + 1
            if type(array[i]) == "nil" then 
                return false 
            end
        end
    
        return true
    end

    --- @param array table
    --- @return boolean
    --- @description: checks if the array is empty
    o_table.is_empty = function(array)
        return o_table.is_array(array) and #array == 0
    end

    --- @param array table
    --- @return @void
    --- @description: executes the specified function once for each element in the array
    o_table.foreach = function(array, __function)
        for i = 1, #array do
            __function(array[i], i)
        end
    end

    --- @param array table
    --- @return @void
    --- @description: executes the specified function once for each element in the reversed array
    o_table.reverse_foreach = function(array, __function)
        for i = #array, 1, -1 do
            __function(array[i], i)
        end
    end

    --- @param array table
    --- @return table
    --- @description: creates a new array with all values of argument[@class[{table}]]
    o_table.keys = function(array)
        local src = {}
        for k, v in pairs(array) do
            table.insert(src, k)
        end
        return src
    end

    --- @param array table
    --- @return table
    --- @description: reverses the array
    o_table.reverse = function(array)
        local src = {}
        for i = #array, 1, -1 do
            src[#src + 1] = array[i]
        end
        return src
    end

    --- @param array table
    --- @return number
    --- @description: finds the minimum value in the array
    o_table.min = function(array)
        local min = array[1]
        for i = 2, #array do
            min = math.min(min, array[i])
        end
        return min
    end

    --- @param array table
    --- @return number
    --- @description: finds the maximum value in the array
    o_table.max = function(array)
        local max = array[1]
        for i = 2, #array do
            max = math.max(max, array[i])
        end
        return max
    end

    --- @param array table
    --- @return number, number
    --- @description: finds the minimum and the maximum value in the array
    o_table.min_max = function(array)
        local min, max = array[1], array[1]
        for i = 2, #array do
            min = math.min(min, array[i])
            max = math.max(max, array[i])
        end
        return min, max
    end

    --- @param array table
    --- @return number
    --- @description: finds the sum of the all values in the array
    o_table.sum = function(array)
        local sum = 0
        for i = 1, #array do
            sum = sum + array[i]
        end
        return sum
    end

    --- @param array table
    --- @param j @anything
    --- @return @index[{@iteration_step}][{@any_index}]
    --- @return boolean
    --- @description: finds the specified argument[{@j}] in the array and returns index[{@iteration_step}][{@any_index}]
    o_table.find = function(array, j)
        for k, v in pairs(array) do 
            if v == j then
                return k 
            end 
        end 
        return false
    end

    --- @param array table
    --- @param j @anything
    --- @return number
    --- @return boolean
    --- @description: finds the specified argument[{@j}] in the array with the method of for[@iteration] and returns index[{@iteration_step}]
    o_table.ifind = function(array, j)
        for i = 1, #array do
            if array[i] == j then
                return i
            end
        end
        return false
    end

    --- @param array table
    --- @param j @anything
    --- @return number
    --- @return boolean
    --- @description: finds the specified argument[{@j}] in the array with the method of for[@iteration[@maxn]] and returns index[{@iteration_step}]
    o_table.mfind = function(array, j)
        for i = 1, table.maxn(array) do 
            if array[i] == j then
                return i
            end
        end
        return false
    end

    --- @param array table
    --- @param ... @tables
    --- @return @anything[{@key}]
    --- @description: inserts all the values of {...}[{@tables}] in the argument[{@input_array}]
    o_table.append = function(array, ...)
        for _, v in ipairs{...} do
            table.insert(array, v)
        end
        return array
    end

    --- @param array table
    --- @return table
    --- @description: creates a new table containing all elements that pass [NULL] test
    o_table.filter = function(array)
        local res = {}
        for i = 1, table.maxn(array) do
            if array[i] ~= nil then 
                res[#res + 1] = array[i] 
            end 
        end 
        return res
    end

    --- @param array table
    --- @return table
    --- @description: creates a deep copy of argument[{@array}] with ignoring metatables
    function o_table.copy(array)
        if type(array) ~= "table" then
            return array 
        end

        local res = {} 
        for k, v in pairs(array) do 
            res[o_table.copy(k)] = o_table.copy(v) 
        end

        return res 
    end

    --- @param array table
    --- @param ... @tables
    --- @return boolean
    --- @description: checks if the elements of argument[{@input_array}] coincide with argument[{@{...}tables}]
    o_table.ihas = function(array, ...)
        local arg = {...} 
        for i = 1, table.maxn(array) do
            for j = 1, #arg do 
                if array[i] == arg[j] then 
                    return true 
                end 
            end 
        end 
        return false 
    end

    --- @param array table
    --- @param r [@table, @nil]
    --- @param k [@table, @nil]
    --- @return table
    --- @description: distributes elements from an argument[{@array}] into a new array based on specified rules
    o_table.distribute = function(array, r, k)
        local res = {} 
        for i, v in ipairs(array) do 
            res[k and v[k] or i] = r == nil and i or v[r] 
        end 
        return res
    end

    --- @param array table
    --- @param path table
    --- @param place @any
    --- @return table
    --- @description: navigates through an argument[{@array}] using a specified path and place a given value at the desired location
    o_table.place = function(array, path, place)
        local p = array 
        for i, v in ipairs(path) do 
            if type(p[v]) == "table" then 
                p = p[v]
            else 
                p[v] = (i < #path) and {} or place 
                p = p[v]
            end
        end
        return array
    end

    --- @param content [@function, @any]
    --- @param quantity number
    --- @return table
    --- @description: creates and returns a table filled with a specified quantity of elements, where each element is either the result of a function call or a specified value
    o_table.populate = function(content, quantity)
        local res = {}
        for i = 1, quantity do
            res[i] = type(content) == "function" and content() or content
        end
        return res
    end

    --- @param array table
    --- @return table
    --- @description: creates a new array without repeated values
    o_table.distinct = function(array)
        local src = {}
        local temp = {}
      
        for _, v in pairs(array) do
            if not temp[v] then
                table.insert(src, v)
                temp[v] = true
            end
        end
      
        return src
    end

    --- @param array1 table
    --- @param array2 table
    --- @return boolean
    --- @description: compares the values of argument[{@array1}] and argument[{@array2}] for each key of both
    function o_table.comparison(array1, array2)
        if #array1 ~= #array2 then 
            return false 
        end
      
        for _, key in pairs(o_table.distinct(o_table.append(o_table.keys(array1), o_table.keys(array2)))) do
            if type(array1[key]) ~= type(array2[key]) then
                return false
            end
        
            if type(array1[key]) == "table" then
                if not o_table.comparise(array1[key], array2[key]) then
                    return false
                end
            elseif array1[key] ~= array2[key] then
                return false
            end
        end
      
        return true
    end

    --- @param array table
    --- @param level [@number, @void]
    --- @return table
    --- @description: flattens up array items of argument[{@array}] into single values
    function o_table.flat(array, level)
        local src = {}
        local level = level or 1
      
        for k, v in pairs(array) do
            if type(v) == "table" and level > 0 then
                o_table.append(src, o_table.flat(v, level - 1))
            else 
                src[k] = v 
            end
        end
      
        return src
    end

    --- @param array1 table
    --- @param array2 table
    --- @return table
    --- @description: copies all keys and values of argument[{@array1}] and argument[{@array2}] into a new array and returns it
    o_table.join = function(array1, array2)
        local src = {}
        for k, v in pairs(array1) do
            src[k] = v
        end
      
        for k, v in pairs(array2) do
            src[k] = v
        end
      
        return src
    end

    --- @param array1 table
    --- @param array2 table
    --- @return table
    --- @description: copies all keys and values of argument[{@array2}] into argument[{@array1}] and returns argument[{@array1}]
    o_table.merge = function(array1, array2)
        for k, v in pairs(array2) do
            array1[k] = v
        end
        
        return array1
    end
    
    --- @param array table
    --- @param start number
    --- @param finish number
    --- @return table
    --- @description: returns a shallow copy of a portion of a argument[{@array}] into a new array
    o_table.slice = function(array, start, finish)
        if o_table.is_empty(start) or start == finish then 
            return {} 
        end

        local src = {}
        local point, break_p = 1, #array
    
        if start >= 0 then
            point = start
        elseif type(finish) == "nil" and start < 0 then
            point = #array + start + 1
        end
    
        if finish and finish >= 0 then
            break_p = finish - 1
        elseif finish and finish < 0 then
            break_p = #array + finish
        end
    
        for i = point, break_p do
            table.insert(src, array[i])
        end
    
        return src
    end
end
--- @endregion

--- @region: __ENV
local __ENV = {
    __AUTHOR = "paranoica",
    __VERSION = "table.lua 30.07.2024 1.0",
    __URL = "https://github.com/paranoica/lua/modules/table.lua",
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

o_table["__ENV"] = __ENV
--- @endregion

--- @region: collect garbage and finish the library
collectgarbage("collect"); return function(local_definition)
    if local_definition then
        return o_table
    else
        for class, object in pairs(o_table) do
            _G["table"][class] = object
        end
    end
end
--- @endregion

--- @diagnostic enable
--- @export : -> disabled
--- @listing : -> enabled

--todo [#@table + 1] = @anything
