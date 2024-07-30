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

local warning, valid_input, clamp, round do
    --- @param message string
    --- @return @void
    warning = function(message)
        print(string.format("[!] %s", message))
    end

    --- @alias Value color(type: r, g, b, a; data: number):void
    --- @alias Value color(type: h, s, l, a; data: number):void
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

    --- @param value number
    --- @return number
    round = function(number)
        return math.floor(number + 0.5)
    end
end

local hsla_to_rgba, rgba_to_hsla, hex_to_rgba, rgba_to_hex do
    --- @param p number
    --- @param q number
    --- @param t number
    --- @return number
    local hue_to_rgb = function(p, q, t)
        if t < 0 then
            t = t + 1
        end
    
        if t > 1 then
            t = t - 1
        end
    
        if t < 1 / 6 then
            return p + (q - p) * 6 * t
        end
    
        if t < 1 / 2 then
            return q
        end
    
        if t < 2 / 3 then
            return p + (q - p) * (2 / 3 - t) * 6
        end
    
        return p
    end

    --- @param h number
    --- @param s number
    --- @param l number
    --- @param hsl_a number
    --- @return number, number, number, number
    hsla_to_rgba = function(h, s, l, hsl_a)
        local r, g, b, q = 0, 0, 0, 0
        local h, s, l = h or 360, (s or 100) / 100, (l or 100) / 100

        if s == 0 then
            r, g, b = l, l, l
        else
            if l < 0.5 then
                q = l * (1 + s)
            else
                q = l + s - l * s
            end
    
            local p = 2 * l - q
            local h = h / 360
    
            r = hue_to_rgb(p, q, h + 1 / 3)
            g = hue_to_rgb(p, q, h)
            b = hue_to_rgb(p, q, h - 1 / 3)
        end

        return round(r * 255), round(g * 255), round(b * 255), round((hsl_a or 1) * 255)
    end

    --- @param r number
    --- @param g number
    --- @param b number
    --- @param a number
    --- @return number, number, number, number
    rgba_to_hsla = function(r, g, b, a)
        local r, g, b = (r or 255) / 255,  (g or 255) / 255, (b or 255) / 255
        local max, min = math.max(r, g, b), math.min(r, g, b)

        local delta = max - min
        local h, s, l = 0, 0, (max + min) / 2

        if max == min then
            h, s = 0, 0
        else
            if l > 0.5 then
                s = delta / (2 - max - min)
            else
                s = delta / (max + min)
            end
    
            if max == r then
                h = (g - b) / delta
    
                if g < b then
                    h = h + 6
                end
            elseif max == g then
                h = (b - r) / delta + 2
            elseif max == b then
                h = (r - g) / delta + 4
            end
    
            h = h / 6
        end
    
        return round(h * 360), round(s * 100), round(l * 100), (a or 255) / 255
    end

    --- @param hex string
    --- @return number, number, number, number
    hex_to_rgba = function(hex)
        local hex = hex:gsub("#", "")
        return  clamp(tonumber(hex:sub(1, 2), 16), 0, 255), 
                clamp(tonumber(hex:sub(3, 4), 16), 0, 255),
                clamp(tonumber(hex:sub(5, 6), 16), 0, 255),
                #hex < 7 and 255 or clamp(tonumber(hex:sub(7, 8), 16), 0, 255)
    end

    --- @param r number
    --- @param g number
    --- @param b number
    --- @param a number
    --- @return string
    rgba_to_hex = function(r, g, b, a)
        local hex = "#"
        local array = {r, g, b, a}

        for i = 1, #array do
            hex = hex .. string.format("%02x", round(array[i]))
        end

        return hex:upper()
    end
end

--- @type COLOR_PRESETS table
local COLOR_PRESETS = {
    ["alice blue"] = {240, 248, 255, 255},
    ["AliceBlue"] = {240, 248, 255, 255},
    ["antique white"] = {250, 235, 215, 255},
    ["AntiqueWhite"] = {250, 235, 215, 255},
    ["AntiqueWhite1"] = {255, 239, 219, 255},
    ["AntiqueWhite2"] = {238, 223, 204, 255},
    ["AntiqueWhite3"] = {205, 192, 176, 255},
    ["AntiqueWhite4"] = {139, 131, 120, 255},
    ["aqua"] = {0, 255, 255, 255},
    ["aquamarine"] = {127, 255, 212, 255},
    ["aquamarine1"] = {127, 255, 212, 255},
    ["aquamarine2"] = {118, 238, 198, 255},
    ["aquamarine3"] = {102, 205, 170, 255},
    ["aquamarine4"] = {69, 139, 116, 255},
    ["azure"] = {240, 255, 255, 255},
    ["azure1"] = {240, 255, 255, 255},
    ["azure2"] = {224, 238, 238, 255},
    ["azure3"] = {193, 205, 205, 255},
    ["azure4"] = {131, 139, 139, 255},
    ["beige"] = {245, 245, 220, 255},
    ["bisque"] = {255, 228, 196, 255},
    ["bisque1"] = {255, 228, 196, 255},
    ["bisque2"] = {238, 213, 183, 255},
    ["bisque3"] = {205, 183, 158, 255},
    ["bisque4"] = {139, 125, 107, 255},
    ["black"] = {0, 0, 0, 255},
    ["blanched almond"] = {255, 235, 205, 255},
    ["BlanchedAlmond"] = {255, 235, 205, 255},
    ["blue violet"] = {138, 43, 226, 255},
    ["blue"] = {0, 0, 255, 255},
    ["blue1"] = {0, 0, 255, 255},
    ["blue2"] = {0, 0, 238, 255},
    ["blue3"] = {0, 0, 205, 255},
    ["blue4"] = {0, 0, 139, 255},
    ["BlueViolet"] = {138, 43, 226, 255},
    ["brown"] = {165, 42, 42, 255},
    ["brown1"] = {255, 64, 64, 255},
    ["brown2"] = {238, 59, 59, 255},
    ["brown3"] = {205, 51, 51, 255},
    ["brown4"] = {139, 35, 35, 255},
    ["burlywood"] = {222, 184, 135, 255},
    ["burlywood1"] = {255, 211, 155, 255},
    ["burlywood2"] = {238, 197, 145, 255},
    ["burlywood3"] = {205, 170, 125, 255},
    ["burlywood4"] = {139, 115, 85, 255},
    ["cadet blue"] = {95, 158, 160, 255},
    ["CadetBlue"] = {95, 158, 160, 255},
    ["CadetBlue1"] = {152, 245, 255, 255},
    ["CadetBlue2"] = {142, 229, 238, 255},
    ["CadetBlue3"] = {122, 197, 205, 255},
    ["CadetBlue4"] = {83, 134, 139, 255},
    ["chartreuse"] = {127, 255, 0, 255},
    ["chartreuse1"] = {127, 255, 0, 255},
    ["chartreuse2"] = {118, 238, 0, 255},
    ["chartreuse3"] = {102, 205, 0, 255},
    ["chartreuse4"] = {69, 139, 0, 255},
    ["chocolate"] = {210, 105, 30, 255},
    ["chocolate1"] = {255, 127, 36, 255},
    ["chocolate2"] = {238, 118, 33, 255},
    ["chocolate3"] = {205, 102, 29, 255},
    ["chocolate4"] = {139, 69, 19, 255},
    ["coral"] = {255, 127, 80, 255},
    ["coral1"] = {255, 114, 86, 255},
    ["coral2"] = {238, 106, 80, 255},
    ["coral3"] = {205, 91, 69, 255},
    ["coral4"] = {139, 62, 47, 255},
    ["cornflower blue"] = {100, 149, 237, 255},
    ["CornflowerBlue"] = {100, 149, 237, 255},
    ["cornsilk"] = {255, 248, 220, 255},
    ["cornsilk1"] = {255, 248, 220, 255},
    ["cornsilk2"] = {238, 232, 205, 255},
    ["cornsilk3"] = {205, 200, 177, 255},
    ["cornsilk4"] = {139, 136, 120, 255},
    ["crimson"] = {220, 20, 60, 255},
    ["cyan"] = {0, 255, 255, 255},
    ["cyan1"] = {0, 255, 255, 255},
    ["cyan2"] = {0, 238, 238, 255},
    ["cyan3"] = {0, 205, 205, 255},
    ["cyan4"] = {0, 139, 139, 255},
    ["dark blue"] = {0, 0, 139, 255},
    ["dark cyan"] = {0, 139, 139, 255},
    ["dark goldenrod"] = {184, 134, 11, 255},
    ["dark gray"] = {169, 169, 169, 255},
    ["dark green"] = {0, 100, 0, 255},
    ["dark grey"] = {169, 169, 169, 255},
    ["dark khaki"] = {189, 183, 107, 255},
    ["dark magenta"] = {139, 0, 139, 255},
    ["dark olive green"] = {85, 107, 47, 255},
    ["dark orange"] = {255, 140, 0, 255},
    ["dark orchid"] = {153, 50, 204, 255},
    ["dark red"] = {139, 0, 0, 255},
    ["dark salmon"] = {233, 150, 122, 255},
    ["dark sea green"] = {143, 188, 143, 255},
    ["dark slate blue"] = {72, 61, 139, 255},
    ["dark slate gray"] = {47, 79, 79, 255},
    ["dark slate grey"] = {47, 79, 79, 255},
    ["dark turquoise"] = {0, 206, 209, 255},
    ["dark violet"] = {148, 0, 211, 255},
    ["DarkBlue"] = {0, 0, 139, 255},
    ["DarkCyan"] = {0, 139, 139, 255},
    ["DarkGoldenrod"] = {184, 134, 11, 255},
    ["DarkGoldenrod1"] = {255, 185, 15, 255},
    ["DarkGoldenrod2"] = {238, 173, 14, 255},
    ["DarkGoldenrod3"] = {205, 149, 12, 255},
    ["DarkGoldenrod4"] = {139, 101, 8, 255},
    ["DarkGray"] = {169, 169, 169, 255},
    ["DarkGreen"] = {0, 100, 0, 255},
    ["DarkGrey"] = {169, 169, 169, 255},
    ["DarkKhaki"] = {189, 183, 107, 255},
    ["DarkMagenta"] = {139, 0, 139, 255},
    ["DarkOliveGreen"] = {85, 107, 47, 255},
    ["DarkOliveGreen1"] = {202, 255, 112, 255},
    ["DarkOliveGreen2"] = {188, 238, 104, 255},
    ["DarkOliveGreen3"] = {162, 205, 90, 255},
    ["DarkOliveGreen4"] = {110, 139, 61, 255},
    ["DarkOrange"] = {255, 140, 0, 255},
    ["DarkOrange1"] = {255, 127, 0, 255},
    ["DarkOrange2"] = {238, 118, 0, 255},
    ["DarkOrange3"] = {205, 102, 0, 255},
    ["DarkOrange4"] = {139, 69, 0, 255},
    ["DarkOrchid"] = {153, 50, 204, 255},
    ["DarkOrchid1"] = {191, 62, 255, 255},
    ["DarkOrchid2"] = {178, 58, 238, 255},
    ["DarkOrchid3"] = {154, 50, 205, 255},
    ["DarkOrchid4"] = {104, 34, 139, 255},
    ["DarkRed"] = {139, 0, 0, 255},
    ["DarkSalmon"] = {233, 150, 122, 255},
    ["DarkSeaGreen"] = {143, 188, 143, 255},
    ["DarkSeaGreen1"] = {193, 255, 193, 255},
    ["DarkSeaGreen2"] = {180, 238, 180, 255},
    ["DarkSeaGreen3"] = {155, 205, 155, 255},
    ["DarkSeaGreen4"] = {105, 139, 105, 255},
    ["DarkSlateBlue"] = {72, 61, 139, 255},
    ["DarkSlateGray"] = {47, 79, 79, 255},
    ["DarkSlateGray1"] = {151, 255, 255, 255},
    ["DarkSlateGray2"] = {141, 238, 238, 255},
    ["DarkSlateGray3"] = {121, 205, 205, 255},
    ["DarkSlateGray4"] = {82, 139, 139, 255},
    ["DarkSlateGrey"] = {47, 79, 79, 255},
    ["DarkTurquoise"] = {0, 206, 209, 255},
    ["DarkViolet"] = {148, 0, 211, 255},
    ["deep pink"] = {255, 20, 147, 255},
    ["deep sky blue"] = {0, 191, 255, 255},
    ["DeepPink"] = {255, 20, 147, 255},
    ["DeepPink1"] = {255, 20, 147, 255},
    ["DeepPink2"] = {238, 18, 137, 255},
    ["DeepPink3"] = {205, 16, 118, 255},
    ["DeepPink4"] = {139, 10, 80, 255},
    ["DeepSkyBlue"] = {0, 191, 255, 255},
    ["DeepSkyBlue1"] = {0, 191, 255, 255},
    ["DeepSkyBlue2"] = {0, 178, 238, 255},
    ["DeepSkyBlue3"] = {0, 154, 205, 255},
    ["DeepSkyBlue4"] = {0, 104, 139, 255},
    ["dim gray"] = {105, 105, 105, 255},
    ["dim grey"] = {105, 105, 105, 255},
    ["DimGray"] = {105, 105, 105, 255},
    ["DimGrey"] = {105, 105, 105, 255},
    ["dodger blue"] = {30, 144, 255, 255},
    ["DodgerBlue"] = {30, 144, 255, 255},
    ["DodgerBlue1"] = {30, 144, 255, 255},
    ["DodgerBlue2"] = {28, 134, 238, 255},
    ["DodgerBlue3"] = {24, 116, 205, 255},
    ["DodgerBlue4"] = {16, 78, 139, 255},
    ["firebrick"] = {178, 34, 34, 255},
    ["firebrick1"] = {255, 48, 48, 255},
    ["firebrick2"] = {238, 44, 44, 255},
    ["firebrick3"] = {205, 38, 38, 255},
    ["firebrick4"] = {139, 26, 26, 255},
    ["floral white"] = {255, 250, 240, 255},
    ["FloralWhite"] = {255, 250, 240, 255},
    ["forest green"] = {34, 139, 34, 255},
    ["ForestGreen"] = {34, 139, 34, 255},
    ["fuchsia"] = {255, 0, 255, 255},
    ["gainsboro"] = {220, 220, 220, 255},
    ["ghost white"] = {248, 248, 255, 255},
    ["GhostWhite"] = {248, 248, 255, 255},
    ["gold"] = {255, 215, 0, 255},
    ["gold1"] = {255, 215, 0, 255},
    ["gold2"] = {238, 201, 0, 255},
    ["gold3"] = {205, 173, 0, 255},
    ["gold4"] = {139, 117, 0, 255},
    ["goldenrod"] = {218, 165, 32, 255},
    ["goldenrod1"] = {255, 193, 37, 255},
    ["goldenrod2"] = {238, 180, 34, 255},
    ["goldenrod3"] = {205, 155, 29, 255},
    ["goldenrod4"] = {139, 105, 20, 255},
    ["gray"] = {190, 190, 190, 255},
    ["gray0"] = {0, 0, 0, 255},
    ["gray1"] = {3, 3, 3, 255},
    ["gray10"] = {26, 26, 26, 255},
    ["gray100"] = {255, 255, 255, 255},
    ["gray11"] = {28, 28, 28, 255},
    ["gray12"] = {31, 31, 31, 255},
    ["gray13"] = {33, 33, 33, 255},
    ["gray14"] = {36, 36, 36, 255},
    ["gray15"] = {38, 38, 38, 255},
    ["gray16"] = {41, 41, 41, 255},
    ["gray17"] = {43, 43, 43, 255},
    ["gray18"] = {46, 46, 46, 255},
    ["gray19"] = {48, 48, 48, 255},
    ["gray2"] = {5, 5, 5, 255},
    ["gray20"] = {51, 51, 51, 255},
    ["gray21"] = {54, 54, 54, 255},
    ["gray22"] = {56, 56, 56, 255},
    ["gray23"] = {59, 59, 59, 255},
    ["gray24"] = {61, 61, 61, 255},
    ["gray25"] = {64, 64, 64, 255},
    ["gray26"] = {66, 66, 66, 255},
    ["gray27"] = {69, 69, 69, 255},
    ["gray28"] = {71, 71, 71, 255},
    ["gray29"] = {74, 74, 74, 255},
    ["gray3"] = {8, 8, 8, 255},
    ["gray30"] = {77, 77, 77, 255},
    ["gray31"] = {79, 79, 79, 255},
    ["gray32"] = {82, 82, 82, 255},
    ["gray33"] = {84, 84, 84, 255},
    ["gray34"] = {87, 87, 87, 255},
    ["gray35"] = {89, 89, 89, 255},
    ["gray36"] = {92, 92, 92, 255},
    ["gray37"] = {94, 94, 94, 255},
    ["gray38"] = {97, 97, 97, 255},
    ["gray39"] = {99, 99, 99, 255},
    ["gray4"] = {10, 10, 10, 255},
    ["gray40"] = {102, 102, 102, 255},
    ["gray41"] = {105, 105, 105, 255},
    ["gray42"] = {107, 107, 107, 255},
    ["gray43"] = {110, 110, 110, 255},
    ["gray44"] = {112, 112, 112, 255},
    ["gray46"] = {117, 117, 117, 255},
    ["gray47"] = {120, 120, 120, 255},
    ["gray48"] = {122, 122, 122, 255},
    ["gray49"] = {125, 125, 125, 255},
    ["gray5"] = {13, 13, 13, 255},
    ["gray50"] = {127, 127, 127, 255},
    ["gray51"] = {130, 130, 130, 255},
    ["gray52"] = {133, 133, 133, 255},
    ["gray53"] = {135, 135, 135, 255},
    ["gray54"] = {138, 138, 138, 255},
    ["gray55"] = {140, 140, 140, 255},
    ["gray56"] = {143, 143, 143, 255},
    ["gray57"] = {145, 145, 145, 255},
    ["gray58"] = {148, 148, 148, 255},
    ["gray59"] = {150, 150, 150, 255},
    ["gray6"] = {15, 15, 15, 255},
    ["gray60"] = {153, 153, 153, 255},
    ["gray61"] = {156, 156, 156, 255},
    ["gray62"] = {158, 158, 158, 255},
    ["gray63"] = {161, 161, 161, 255},
    ["gray64"] = {163, 163, 163, 255},
    ["gray65"] = {166, 166, 166, 255},
    ["gray66"] = {168, 168, 168, 255},
    ["gray67"] = {171, 171, 171, 255},
    ["gray68"] = {173, 173, 173, 255},
    ["gray69"] = {176, 176, 176, 255},
    ["gray7"] = {18, 18, 18, 255},
    ["gray70"] = {179, 179, 179, 255},
    ["gray71"] = {181, 181, 181, 255},
    ["gray72"] = {184, 184, 184, 255},
    ["gray73"] = {186, 186, 186, 255},
    ["gray74"] = {189, 189, 189, 255},
    ["gray75"] = {191, 191, 191, 255},
    ["gray76"] = {194, 194, 194, 255},
    ["gray77"] = {196, 196, 196, 255},
    ["gray78"] = {199, 199, 199, 255},
    ["gray79"] = {201, 201, 201, 255},
    ["gray8"] = {20, 20, 20, 255},
    ["gray80"] = {204, 204, 204, 255},
    ["gray81"] = {207, 207, 207, 255},
    ["gray82"] = {209, 209, 209, 255},
    ["gray83"] = {212, 212, 212, 255},
    ["gray84"] = {214, 214, 214, 255},
    ["gray85"] = {217, 217, 217, 255},
    ["gray86"] = {219, 219, 219, 255},
    ["gray87"] = {222, 222, 222, 255},
    ["gray88"] = {224, 224, 224, 255},
    ["gray89"] = {227, 227, 227, 255},
    ["gray9"] = {23, 23, 23, 255},
    ["gray90"] = {229, 229, 229, 255},
    ["gray91"] = {232, 232, 232, 255},
    ["gray92"] = {235, 235, 235, 255},
    ["gray93"] = {237, 237, 237, 255},
    ["gray94"] = {240, 240, 240, 255},
    ["gray95"] = {242, 242, 242, 255},
    ["gray96"] = {245, 245, 245, 255},
    ["gray97"] = {247, 247, 247, 255},
    ["gray98"] = {250, 250, 250, 255},
    ["gray99"] = {252, 252, 252, 255},
    ["green yellow"] = {173, 255, 47, 255},
    ["green"] = {0, 255, 0, 255},
    ["green1"] = {0, 255, 0, 255},
    ["green2"] = {0, 238, 0, 255},
    ["green3"] = {0, 205, 0, 255},
    ["green4"] = {0, 139, 0, 255},
    ["GreenYellow"] = {173, 255, 47, 255},
    ["grey"] = {190, 190, 190, 255},
    ["grey0"] = {0, 0, 0, 255},
    ["grey1"] = {3, 3, 3, 255},
    ["grey10"] = {26, 26, 26, 255},
    ["grey100"] = {255, 255, 255, 255},
    ["grey11"] = {28, 28, 28, 255},
    ["grey12"] = {31, 31, 31, 255},
    ["grey13"] = {33, 33, 33, 255},
    ["grey14"] = {36, 36, 36, 255},
    ["grey15"] = {38, 38, 38, 255},
    ["grey16"] = {41, 41, 41, 255},
    ["grey17"] = {43, 43, 43, 255},
    ["grey18"] = {46, 46, 46, 255},
    ["grey19"] = {48, 48, 48, 255},
    ["grey2"] = {5, 5, 5, 255},
    ["grey20"] = {51, 51, 51, 255},
    ["grey21"] = {54, 54, 54, 255},
    ["grey22"] = {56, 56, 56, 255},
    ["grey23"] = {59, 59, 59, 255},
    ["grey24"] = {61, 61, 61, 255},
    ["grey25"] = {64, 64, 64, 255},
    ["grey26"] = {66, 66, 66, 255},
    ["grey27"] = {69, 69, 69, 255},
    ["grey28"] = {71, 71, 71, 255},
    ["grey29"] = {74, 74, 74, 255},
    ["grey3"] = {8, 8, 8, 255},
    ["grey30"] = {77, 77, 77, 255},
    ["grey31"] = {79, 79, 79, 255},
    ["grey32"] = {82, 82, 82, 255},
    ["grey33"] = {84, 84, 84, 255},
    ["grey34"] = {87, 87, 87, 255},
    ["grey35"] = {89, 89, 89, 255},
    ["grey36"] = {92, 92, 92, 255},
    ["grey37"] = {94, 94, 94, 255},
    ["grey38"] = {97, 97, 97, 255},
    ["grey39"] = {99, 99, 99, 255},
    ["grey4"] = {10, 10, 10, 255},
    ["grey40"] = {102, 102, 102, 255},
    ["grey41"] = {105, 105, 105, 255},
    ["grey42"] = {107, 107, 107, 255},
    ["grey43"] = {110, 110, 110, 255},
    ["grey44"] = {112, 112, 112, 255},
    ["grey45"] = {115, 115, 115, 255},
    ["grey46"] = {117, 117, 117, 255},
    ["grey47"] = {120, 120, 120, 255},
    ["grey48"] = {122, 122, 122, 255},
    ["grey49"] = {125, 125, 125, 255},
    ["grey5"] = {13, 13, 13, 255},
    ["grey50"] = {127, 127, 127, 255},
    ["grey51"] = {130, 130, 130, 255},
    ["grey52"] = {133, 133, 133, 255},
    ["grey53"] = {135, 135, 135, 255},
    ["grey54"] = {138, 138, 138, 255},
    ["grey55"] = {140, 140, 140, 255},
    ["grey56"] = {143, 143, 143, 255},
    ["grey57"] = {145, 145, 145, 255},
    ["grey58"] = {148, 148, 148, 255},
    ["grey59"] = {150, 150, 150, 255},
    ["grey6"] = {15, 15, 15, 255},
    ["grey60"] = {153, 153, 153, 255},
    ["grey61"] = {156, 156, 156, 255},
    ["grey62"] = {158, 158, 158, 255},
    ["grey63"] = {161, 161, 161, 255},
    ["grey64"] = {163, 163, 163, 255},
    ["grey65"] = {166, 166, 166, 255},
    ["grey66"] = {168, 168, 168, 255},
    ["grey67"] = {171, 171, 171, 255},
    ["grey68"] = {173, 173, 173, 255},
    ["grey69"] = {176, 176, 176, 255},
    ["grey7"] = {18, 18, 18, 255},
    ["grey70"] = {179, 179, 179, 255},
    ["grey71"] = {181, 181, 181, 255},
    ["grey72"] = {184, 184, 184, 255},
    ["grey73"] = {186, 186, 186, 255},
    ["grey74"] = {189, 189, 189, 255},
    ["grey75"] = {191, 191, 191, 255},
    ["grey76"] = {194, 194, 194, 255},
    ["grey77"] = {196, 196, 196, 255},
    ["grey78"] = {199, 199, 199, 255},
    ["grey79"] = {201, 201, 201, 255},
    ["grey8"] = {20, 20, 20, 255},
    ["grey80"] = {204, 204, 204, 255},
    ["grey81"] = {207, 207, 207, 255},
    ["grey82"] = {209, 209, 209, 255},
    ["grey83"] = {212, 212, 212, 255},
    ["grey84"] = {214, 214, 214, 255},
    ["grey85"] = {217, 217, 217, 255},
    ["grey86"] = {219, 219, 219, 255},
    ["grey87"] = {222, 222, 222, 255},
    ["grey88"] = {224, 224, 224, 255},
    ["grey89"] = {227, 227, 227, 255},
    ["grey9"] = {23, 23, 23, 255},
    ["grey90"] = {229, 229, 229, 255},
    ["grey91"] = {232, 232, 232, 255},
    ["grey93"] = {237, 237, 237, 255},
    ["grey94"] = {240, 240, 240, 255},
    ["grey92"] = {235, 235, 235, 255},
    ["grey95"] = {242, 242, 242, 255},
    ["grey96"] = {245, 245, 245, 255},
    ["grey97"] = {247, 247, 247, 255},
    ["grey98"] = {250, 250, 250, 255},
    ["grey99"] = {252, 252, 252, 255},
    ["honeydew"] = {240, 255, 240, 255},
    ["honeydew1"] = {240, 255, 240, 255},
    ["honeydew2"] = {224, 238, 224, 255},
    ["honeydew3"] = {193, 205, 193, 255},
    ["honeydew4"] = {131, 139, 131, 255},
    ["hot pink"] = {255, 105, 180, 255},
    ["HotPink"] = {255, 105, 180, 255},
    ["HotPink1"] = {255, 110, 180, 255},
    ["HotPink2"] = {238, 106, 167, 255},
    ["HotPink3"] = {205, 96, 144, 255},
    ["HotPink4"] = {139, 58, 98, 255},
    ["indian red"] = {205, 92, 92, 255},
    ["IndianRed"] = {205, 92, 92, 255},
    ["IndianRed1"] = {255, 106, 106, 255},
    ["IndianRed2"] = {238, 99, 99, 255},
    ["IndianRed3"] = {205, 85, 85, 255},
    ["IndianRed4"] = {139, 58, 58, 255},
    ["indigo"] = {75, 0, 130, 255},
    ["ivory"] = {255, 255, 240, 255},
    ["ivory1"] = {255, 255, 240, 255},
    ["ivory2"] = {238, 238, 224, 255},
    ["ivory3"] = {205, 205, 193, 255},
    ["ivory4"] = {139, 139, 131, 255},
    ["khaki"] = {240, 230, 140, 255},
    ["khaki1"] = {255, 246, 143, 255},
    ["khaki2"] = {238, 230, 133, 255},
    ["khaki3"] = {205, 198, 115, 255},
    ["khaki4"] = {139, 134, 78, 255},
    ["lavender blush"] = {255, 240, 245, 255},
    ["lavender"] = {230, 230, 250, 255},
    ["LavenderBlush"] = {255, 240, 245, 255},
    ["LavenderBlush1"] = {255, 240, 245, 255},
    ["LavenderBlush2"] = {238, 224, 229, 255},
    ["LavenderBlush3"] = {205, 193, 197, 255},
    ["LavenderBlush4"] = {139, 131, 134, 255},
    ["lawn green"] = {124, 252, 0, 255},
    ["LawnGreen"] = {124, 252, 0, 255},
    ["lemon chiffon"] = {255, 250, 205, 255},
    ["LemonChiffon"] = {255, 250, 205, 255},
    ["LemonChiffon1"] = {255, 250, 205, 255},
    ["LemonChiffon2"] = {238, 233, 191, 255},
    ["LemonChiffon3"] = {205, 201, 165, 255},
    ["LemonChiffon4"] = {139, 137, 112, 255},
    ["light blue"] = {173, 216, 230, 255},
    ["light coral"] = {240, 128, 128, 255},
    ["light cyan"] = {224, 255, 255, 255},
    ["light goldenrod yellow"] = {250, 250, 210, 255},
    ["light goldenrod"] = {238, 221, 130, 255},
    ["light gray"] = {211, 211, 211, 255},
    ["light green"] = {144, 238, 144, 255},
    ["light grey"] = {211, 211, 211, 255},
    ["light pink"] = {255, 182, 193, 255},
    ["light salmon"] = {255, 160, 122, 255},
    ["light sea green"] = {32, 178, 170, 255},
    ["light sky blue"] = {135, 206, 250, 255},
    ["light slate blue"] = {132, 112, 255, 255},
    ["light slate gray"] = {119, 136, 153, 255},
    ["light slate grey"] = {119, 136, 153, 255},
    ["light steel blue"] = {176, 196, 222, 255},
    ["light yellow"] = {255, 255, 224, 255},
    ["LightBlue"] = {173, 216, 230, 255},
    ["LightBlue1"] = {191, 239, 255, 255},
    ["LightBlue2"] = {178, 223, 238, 255},
    ["LightBlue3"] = {154, 192, 205, 255},
    ["LightBlue4"] = {104, 131, 139, 255},
    ["LightCoral"] = {240, 128, 128, 255},
    ["LightCyan"] = {224, 255, 255, 255},
    ["LightCyan1"] = {224, 255, 255, 255},
    ["LightCyan2"] = {209, 238, 238, 255},
    ["LightCyan3"] = {180, 205, 205, 255},
    ["LightCyan4"] = {122, 139, 139, 255},
    ["LightGoldenrod"] = {238, 221, 130, 255},
    ["LightGoldenrod1"] = {255, 236, 139, 255},
    ["LightGoldenrod2"] = {238, 220, 130, 255},
    ["LightGoldenrod3"] = {205, 190, 112, 255},
    ["LightGoldenrod4"] = {139, 129, 76, 255},
    ["LightGoldenrodYellow"] = {250, 250, 210, 255},
    ["LightGray"] = {211, 211, 211, 255},
    ["LightGreen"] = {144, 238, 144, 255},
    ["LightGrey"] = {211, 211, 211, 255},
    ["LightPink"] = {255, 182, 193, 255},
    ["LightPink1"] = {255, 174, 185, 255},
    ["LightPink2"] = {238, 162, 173, 255},
    ["LightPink3"] = {205, 140, 149, 255},
    ["LightPink4"] = {139, 95, 101, 255},
    ["LightSalmon"] = {255, 160, 122, 255},
    ["LightSalmon1"] = {255, 160, 122, 255},
    ["LightSalmon2"] = {238, 149, 114, 255},
    ["LightSalmon3"] = {205, 129, 98, 255},
    ["LightSalmon4"] = {139, 87, 66, 255},
    ["LightSeaGreen"] = {32, 178, 170, 255},
    ["LightSkyBlue"] = {135, 206, 250, 255},
    ["LightSkyBlue1"] = {176, 226, 255, 255},
    ["LightSkyBlue2"] = {164, 211, 238, 255},
    ["LightSkyBlue3"] = {141, 182, 205, 255},
    ["LightSkyBlue4"] = {96, 123, 139, 255},
    ["LightSlateBlue"] = {132, 112, 255, 255},
    ["LightSlateGray"] = {119, 136, 153, 255},
    ["LightSlateGrey"] = {119, 136, 153, 255},
    ["LightSteelBlue"] = {176, 196, 222, 255},
    ["LightSteelBlue1"] = {202, 225, 255, 255},
    ["LightSteelBlue2"] = {188, 210, 238, 255},
    ["LightSteelBlue3"] = {162, 181, 205, 255},
    ["LightSteelBlue4"] = {110, 123, 139, 255},
    ["LightYellow"] = {255, 255, 224, 255},
    ["LightYellow1"] = {255, 255, 224, 255},
    ["LightYellow2"] = {238, 238, 209, 255},
    ["LightYellow3"] = {205, 205, 180, 255},
    ["LightYellow4"] = {139, 139, 122, 255},
    ["lime green"] = {50, 205, 50, 255},
    ["lime"] = {0, 255, 0, 255},
    ["LimeGreen"] = {50, 205, 50, 255},
    ["linen"] = {250, 240, 230, 255},
    ["magenta"] = {255, 0, 255, 255},
    ["magenta1"] = {255, 0, 255, 255},
    ["magenta2"] = {238, 0, 238, 255},
    ["magenta3"] = {205, 0, 205, 255},
    ["magenta4"] = {139, 0, 139, 255},
    ["maroon"] = {176, 48, 96, 255},
    ["maroon1"] = {255, 52, 179, 255},
    ["maroon2"] = {238, 48, 167, 255},
    ["maroon3"] = {205, 41, 144, 255},
    ["maroon4"] = {139, 28, 98, 255},
    ["medium aquamarine"] = {102, 205, 170, 255},
    ["medium blue"] = {0, 0, 205, 255},
    ["medium orchid"] = {186, 85, 211, 255},
    ["medium purple"] = {147, 112, 219, 255},
    ["medium sea green"] = {60, 179, 113, 255},
    ["medium slate blue"] = {123, 104, 238, 255},
    ["medium spring green"] = {0, 250, 154, 255},
    ["medium turquoise"] = {72, 209, 204, 255},
    ["medium violet red"] = {199, 21, 133, 255},
    ["MediumAquamarine"] = {102, 205, 170, 255},
    ["MediumBlue"] = {0, 0, 205, 255},
    ["MediumOrchid"] = {186, 85, 211, 255},
    ["MediumOrchid1"] = {224, 102, 255, 255},
    ["MediumOrchid2"] = {209, 95, 238, 255},
    ["MediumOrchid3"] = {180, 82, 205, 255},
    ["MediumOrchid4"] = {122, 55, 139, 255},
    ["MediumPurple"] = {147, 112, 219, 255},
    ["MediumPurple1"] = {171, 130, 255, 255},
    ["MediumPurple2"] = {159, 121, 238, 255},
    ["MediumPurple3"] = {137, 104, 205, 255},
    ["MediumPurple4"] = {93, 71, 139, 255},
    ["MediumSeaGreen"] = {60, 179, 113, 255},
    ["MediumSlateBlue"] = {123, 104, 238, 255},
    ["MediumSpringGreen"] = {0, 250, 154, 255},
    ["MediumTurquoise"] = {72, 209, 204, 255},
    ["MediumVioletRed"] = {199, 21, 133, 255},
    ["midnight blue"] = {25, 25, 112, 255},
    ["MidnightBlue"] = {25, 25, 112, 255},
    ["mint cream"] = {245, 255, 250, 255},
    ["MintCream"] = {245, 255, 250, 255},
    ["misty rose"] = {255, 228, 225, 255},
    ["MistyRose"] = {255, 228, 225, 255},
    ["MistyRose1"] = {255, 228, 225, 255},
    ["MistyRose2"] = {238, 213, 210, 255},
    ["MistyRose3"] = {205, 183, 181, 255},
    ["MistyRose4"] = {139, 125, 123, 255},
    ["moccasin"] = {255, 228, 181, 255},
    ["navajo white"] = {255, 222, 173, 255},
    ["NavajoWhite"] = {255, 222, 173, 255},
    ["NavajoWhite1"] = {255, 222, 173, 255},
    ["NavajoWhite2"] = {238, 207, 161, 255},
    ["NavajoWhite3"] = {205, 179, 139, 255},
    ["NavajoWhite4"] = {139, 121, 94, 255},
    ["navy blue"] = {0, 0, 128, 255},
    ["navy"] = {0, 0, 128, 255},
    ["NavyBlue"] = {0, 0, 128, 255},
    ["old lace"] = {253, 245, 230, 255},
    ["OldLace"] = {253, 245, 230, 255},
    ["olive drab"] = {107, 142, 35, 255},
    ["olive"] = {128, 128, 0, 255},
    ["OliveDrab"] = {107, 142, 35, 255},
    ["OliveDrab1"] = {192, 255, 62, 255},
    ["OliveDrab2"] = {179, 238, 58, 255},
    ["OliveDrab3"] = {154, 205, 50, 255},
    ["OliveDrab4"] = {105, 139, 34, 255},
    ["orange red"] = {255, 69, 0, 255},
    ["orange"] = {255, 165, 0, 255},
    ["orange1"] = {255, 165, 0, 255},
    ["orange2"] = {238, 154, 0, 255},
    ["orange3"] = {205, 133, 0, 255},
    ["orange4"] = {139, 90, 0, 255},
    ["OrangeRed"] = {255, 69, 0, 255},
    ["OrangeRed1"] = {255, 69, 0, 255},
    ["OrangeRed2"] = {238, 64, 0, 255},
    ["OrangeRed3"] = {205, 55, 0, 255},
    ["OrangeRed4"] = {139, 37, 0, 255},
    ["orchid"] = {218, 112, 214, 255},
    ["orchid1"] = {255, 131, 250, 255},
    ["orchid2"] = {238, 122, 233, 255},
    ["orchid3"] = {205, 105, 201, 255},
    ["orchid4"] = {139, 71, 137, 255},
    ["pale goldenrod"] = {238, 232, 170, 255},
    ["pale green"] = {152, 251, 152, 255},
    ["pale turquoise"] = {175, 238, 238, 255},
    ["pale violet red"] = {219, 112, 147, 255},
    ["PaleGoldenrod"] = {238, 232, 170, 255},
    ["PaleGreen"] = {152, 251, 152, 255},
    ["PaleGreen1"] = {154, 255, 154, 255},
    ["PaleGreen2"] = {144, 238, 144, 255},
    ["PaleGreen3"] = {124, 205, 124, 255},
    ["PaleGreen4"] = {84, 139, 84, 255},
    ["PaleTurquoise"] = {175, 238, 238, 255},
    ["PaleTurquoise1"] = {187, 255, 255, 255},
    ["PaleTurquoise2"] = {174, 238, 238, 255},
    ["PaleTurquoise3"] = {150, 205, 205, 255},
    ["PaleTurquoise4"] = {102, 139, 139, 255},
    ["PaleVioletRed"] = {219, 112, 147, 255},
    ["PaleVioletRed1"] = {255, 130, 171, 255},
    ["PaleVioletRed2"] = {238, 121, 159, 255},
    ["PaleVioletRed3"] = {205, 104, 137, 255},
    ["PaleVioletRed4"] = {139, 71, 93, 255},
    ["papaya whip"] = {255, 239, 213, 255},
    ["PapayaWhip"] = {255, 239, 213, 255},
    ["peach puff"] = {255, 218, 185, 255},
    ["PeachPuff"] = {255, 218, 185, 255},
    ["PeachPuff1"] = {255, 218, 185, 255},
    ["PeachPuff2"] = {238, 203, 173, 255},
    ["PeachPuff3"] = {205, 175, 149, 255},
    ["PeachPuff4"] = {139, 119, 101, 255},
    ["peru"] = {205, 133, 63, 255},
    ["pink"] = {255, 192, 203, 255},
    ["pink1"] = {255, 181, 197, 255},
    ["pink2"] = {238, 169, 184, 255},
    ["pink3"] = {205, 145, 158, 255},
    ["pink4"] = {139, 99, 108, 255},
    ["plum"] = {221, 160, 221, 255},
    ["plum1"] = {255, 187, 255, 255},
    ["plum2"] = {238, 174, 238, 255},
    ["plum3"] = {205, 150, 205, 255},
    ["plum4"] = {139, 102, 139, 255},
    ["powder blue"] = {176, 224, 230, 255},
    ["PowderBlue"] = {176, 224, 230, 255},
    ["purple"] = {160, 32, 240, 255},
    ["purple1"] = {155, 48, 255, 255},
    ["purple2"] = {145, 44, 238, 255},
    ["purple3"] = {125, 38, 205, 255},
    ["purple4"] = {85, 26, 139, 255},
    ["rebecca purple"] = {102, 51, 153, 255},
    ["RebeccaPurple"] = {102, 51, 153, 255},
    ["red"] = {255, 0, 0, 255},
    ["red1"] = {255, 0, 0, 255},
    ["red2"] = {238, 0, 0, 255},
    ["red3"] = {205, 0, 0, 255},
    ["red4"] = {139, 0, 0, 255},
    ["rosy brown"] = {188, 143, 143, 255},
    ["RosyBrown"] = {188, 143, 143, 255},
    ["RosyBrown1"] = {255, 193, 193, 255},
    ["RosyBrown2"] = {238, 180, 180, 255},
    ["RosyBrown3"] = {205, 155, 155, 255},
    ["RosyBrown4"] = {139, 105, 105, 255},
    ["royal blue"] = {65, 105, 225, 255},
    ["RoyalBlue"] = {65, 105, 225, 255},
    ["RoyalBlue1"] = {72, 118, 255, 255},
    ["RoyalBlue2"] = {67, 110, 238, 255},
    ["RoyalBlue3"] = {58, 95, 205, 255},
    ["RoyalBlue4"] = {39, 64, 139, 255},
    ["saddle brown"] = {139, 69, 19, 255},
    ["SaddleBrown"] = {139, 69, 19, 255},
    ["salmon"] = {250, 128, 114, 255},
    ["salmon1"] = {255, 140, 105, 255},
    ["salmon2"] = {238, 130, 98, 255},
    ["salmon3"] = {205, 112, 84, 255},
    ["salmon4"] = {139, 76, 57, 255},
    ["sandy brown"] = {244, 164, 96, 255},
    ["SandyBrown"] = {244, 164, 96, 255},
    ["sea green"] = {46, 139, 87, 255},
    ["SeaGreen"] = {46, 139, 87, 255},
    ["SeaGreen1"] = {84, 255, 159, 255},
    ["SeaGreen2"] = {78, 238, 148, 255},
    ["SeaGreen3"] = {67, 205, 128, 255},
    ["SeaGreen4"] = {46, 139, 87, 255},
    ["seashell"] = {255, 245, 238, 255},
    ["seashell1"] = {255, 245, 238, 255},
    ["seashell2"] = {238, 229, 222, 255},
    ["seashell3"] = {205, 197, 191, 255},
    ["seashell4"] = {139, 134, 130, 255},
    ["sienna"] = {160, 82, 45, 255},
    ["sienna1"] = {255, 130, 71, 255},
    ["sienna2"] = {238, 121, 66, 255},
    ["sienna3"] = {205, 104, 57, 255},
    ["sienna4"] = {139, 71, 38, 255},
    ["silver"] = {192, 192, 192, 255},
    ["sky blue"] = {135, 206, 235, 255},
    ["SkyBlue"] = {135, 206, 235, 255},
    ["SkyBlue1"] = {135, 206, 255, 255},
    ["SkyBlue2"] = {126, 192, 238, 255},
    ["SkyBlue3"] = {108, 166, 205, 255},
    ["SkyBlue4"] = {74, 112, 139, 255},
    ["slate blue"] = {106, 90, 205, 255},
    ["slate gray"] = {112, 128, 144, 255},
    ["slate grey"] = {112, 128, 144, 255},
    ["SlateBlue"] = {106, 90, 205, 255},
    ["SlateBlue1"] = {131, 111, 255, 255},
    ["SlateBlue2"] = {122, 103, 238, 255},
    ["SlateBlue3"] = {105, 89, 205, 255},
    ["SlateBlue4"] = {71, 60, 139, 255},
    ["SlateGray"] = {112, 128, 144, 255},
    ["SlateGray1"] = {198, 226, 255, 255},
    ["SlateGray2"] = {185, 211, 238, 255},
    ["SlateGray3"] = {159, 182, 205, 255},
    ["SlateGray4"] = {108, 123, 139, 255},
    ["SlateGrey"] = {112, 128, 144, 255},
    ["snow"] = {255, 250, 250, 255},
    ["snow1"] = {255, 250, 250, 255},
    ["snow2"] = {238, 233, 233, 255},
    ["snow3"] = {205, 201, 201, 255},
    ["snow4"] = {139, 137, 137, 255},
    ["spring green"] = {0, 255, 127, 255},
    ["SpringGreen"] = {0, 255, 127, 255},
    ["SpringGreen1"] = {0, 255, 127, 255},
    ["SpringGreen2"] = {0, 238, 118, 255},
    ["SpringGreen3"] = {0, 205, 102, 255},
    ["SpringGreen4"] = {0, 139, 69, 255},
    ["steel blue"] = {70, 130, 180, 255},
    ["SteelBlue"] = {70, 130, 180, 255},
    ["SteelBlue1"] = {99, 184, 255, 255},
    ["SteelBlue2"] = {92, 172, 238, 255},
    ["SteelBlue3"] = {79, 148, 205, 255},
    ["SteelBlue4"] = {54, 100, 139, 255},
    ["tan"] = {210, 180, 140, 255},
    ["tan1"] = {255, 165, 79, 255},
    ["tan2"] = {238, 154, 73, 255},
    ["tan3"] = {205, 133, 63, 255},
    ["tan4"] = {139, 90, 43, 255},
    ["teal"] = {0, 128, 128, 255},
    ["thistle"] = {216, 191, 216, 255},
    ["thistle1"] = {255, 225, 255, 255},
    ["thistle2"] = {238, 210, 238, 255},
    ["thistle3"] = {205, 181, 205, 255},
    ["thistle4"] = {139, 123, 139, 255},
    ["tomato"] = {255, 99, 71, 255},
    ["tomato1"] = {255, 99, 71, 255},
    ["tomato2"] = {238, 92, 66, 255},
    ["tomato3"] = {205, 79, 57, 255},
    ["tomato4"] = {139, 54, 38, 255},
    ["turquoise"] = {64, 224, 208, 255},
    ["turquoise1"] = {0, 245, 255, 255},
    ["turquoise2"] = {0, 229, 238, 255},
    ["turquoise3"] = {0, 197, 205, 255},
    ["turquoise4"] = {0, 134, 139, 255},
    ["violet red"] = {208, 32, 144, 255},
    ["violet"] = {238, 130, 238, 255},
    ["VioletRed"] = {208, 32, 144, 255},
    ["VioletRed1"] = {255, 62, 150, 255},
    ["VioletRed2"] = {238, 58, 140, 255},
    ["VioletRed3"] = {205, 50, 120, 255},
    ["VioletRed4"] = {139, 34, 82, 255},
    ["web gray"] = {128, 128, 128, 255},
    ["web green"] = {0, 128, 0, 255},
    ["web grey"] = {128, 128, 128, 255},
    ["web maroon"] = {128, 0, 0, 255},
    ["web purple"] = {128, 0, 128, 255},
    ["WebGray"] = {128, 128, 128, 255},
    ["WebGreen"] = {0, 128, 0, 255},
    ["WebGrey"] = {128, 128, 128, 255},
    ["WebMaroon"] = {128, 0, 0, 255},
    ["WebPurple"] = {128, 0, 128, 255},
    ["wheat"] = {245, 222, 179, 255},
    ["wheat1"] = {255, 231, 186, 255},
    ["wheat2"] = {238, 216, 174, 255},
    ["wheat3"] = {205, 186, 150, 255},
    ["wheat4"] = {139, 126, 102, 255},
    ["white smoke"] = {245, 245, 245, 255},
    ["white"] = {255, 255, 255, 255},
    ["WhiteSmoke"] = {245, 245, 245, 255},
    ["x11 gray"] = {190, 190, 190, 255},
    ["x11 green"] = {0, 255, 0, 255},
    ["x11 grey"] = {190, 190, 190, 255},
    ["x11 maroon"] = {176, 48, 96, 255},
    ["x11 purple"] = {160, 32, 240, 255},
    ["X11Gray"] = {190, 190, 190, 255},
    ["X11Green"] = {0, 255, 0, 255},
    ["X11Grey"] = {190, 190, 190, 255},
    ["X11Maroon"] = {176, 48, 96, 255},
    ["X11Purple"] = {160, 32, 240, 255},
    ["yellow green"] = {154, 205, 50, 255},
    ["yellow"] = {255, 255, 0, 255},
    ["yellow1"] = {255, 255, 0, 255},
    ["yellow2"] = {238, 238, 0, 255},
    ["yellow3"] = {205, 205, 0, 255},
    ["yellow4"] = {139, 139, 0, 255},
    ["YellowGreen"] = {154, 205, 50, 255}
}
--- @endregion

--- @region: create and update {color} module
local color = {} do
    --- @param content table
    --- @return boolean
    local is_color = function(content)
        return getmetatable(content) == color
    end

    --- @type COLOR_TYPES table
    local COLOR_TYPES = {
        WHITE = 0,
        BLACK = 1
    }

    --- @class color : r, g, b, a
    --- @class color : h, s, l, a
    --- @type r -> red, g -> green, b -> blue, a -> alpha
    --- @type h -> hue, s -> saturation, l -> lightness, a -> alpha
    --- @param r number {0, 255}
    --- @param g number {0, 255}
    --- @param b number {0, 255}
    --- @param a number {0, 255}
    --- @param h number {0, 360}
    --- @param s number {0, 100%}
    --- @param l number {0, 100%}
    --- @param hsl_a number {0.0, 1.0}
    setmetatable(color, color); color.__index = color; color.__call = function(self, _r, _g, _b, _a)
        local hex
        local r, g, b, a, h, s, l, hsl_a

        if type(_r) == "string" then
            if #(_r) > 9 then
                warning(string.format("Amount (%d) of HEX-symbols is more than 8!", #(_r)))
                return
            end

            r, g, b, a = hex_to_rgba(_r)
        else
            local f_valid, f_msg = valid_input(_r)
            if not f_valid then
                warning(f_msg)
                return
            end

            local s_valid, s_msg = valid_input(g)
            if not s_valid then
                warning(s_msg)
                return
            end

            local t_valid, t_msg = valid_input(b)
            if not t_valid then
                warning(t_msg)
                return
            end

            local fo_valid, fo_msg = valid_input(a)
            if not fo_valid then
                warning(fo_msg)
                return
            end

            r = _r and clamp(_r, 0, 255) or 255
            g = _g and clamp(_g, 0, 255) or 255
            b = _b and clamp(_b, 0, 255) or 255
            a = _a and clamp(_a, 0, 255) or 255
        end

        hex = rgba_to_hex(r, g, b, a)
        h, s, l, hsl_a = rgba_to_hsla(r, g, b, a)

        return setmetatable({
            r = r,
            g = g,
            b = b,
            a = a,

            h = h,
            s = s,
            l = l,

            hex = hex,
            d_hex = hex:sub(1, 7),

            hsl_a = hsl_a
        }, color)
    end

    --- @param self color
    --- @return string
    color.__tostring = function(self)
        return string.format("color(r: %f, g: %f, b: %f, a: %f) %s color(h: %f, s: %f, l: %f, a: %f)", self.r, self.g, self.b, self.a, " | ", self.h, self.s, self.l, self.hsl_a)
    end

    --- @param self color
    --- @return string
    color.__concat = function(v1, v2)
        return tostring(v1) .. "\n" .. tostring(v2)
    end

    --- @param self color
    --- @return @self
    color.__unm = function(self)
        return self
    end

    --- @param self color
    --- @return number
    color.__len = function(self)
        return 0
    end

    --- @param self color
    --- @return META_METHOD[{META_OPERATION}]
    for metamethod, metafunction in pairs({
        ["__add"] = function(a, b) return color(a[1] + b[1], a[2] + b[2], a[3] + b[3]) end,
        ["__sub"] = function(a, b) return color(a[1] - b[1], a[2] - b[2], a[3] - b[3]) end,
        ["__mul"] = function(a, b) return color(a[1] * b[1], a[2] * b[2], a[3] * b[3]) end,
        ["__div"] = function(a, b) return color(a[1] / b[1], a[2] / b[2], a[3] / b[3]) end,
        ["__mod"] = function(a, b) return color(a[1] % b[1], a[2] % b[2], a[3] % b[3]) end,
        ["__pow"] = function(a, b) return color(a[1] ^ b[1], a[2] ^ b[2], a[3] ^ b[3]) end,

        ["__eq"] = function(a, b) return a[1] == b[1] and a[2] == b[2] and a[3] + b[3] end,
        ["__lt"] = function(a, b) return a[1] < b[1] and a[2] < b[2] and a[3] < b[3] end,
        ["__le"] = function(a, b) return a[1] <= b[1] and a[2] <= b[2] and a[3] <= b[3] end
    }) do
        color[metamethod] = function(first, second)
            local first = type(first) == "number" and {first, first, first, first} or {first.r, first.g, first.b, first.a}
            local second = type(second) == "number" and {second, second, second, second} or {second.r, second.g, second.b, second.a}

            return metafunction(first, second)
        end
    end

    --- @param self color
    --- @param h number
    --- @param s number
    --- @param l number
    --- @param hsl_a number
    --- @return @class[{color}]
    --- @description: sets the hsla of the argument[{@color}] and returns itself
    function color:hsla(h, s, l, hsl_a)
        if type(h) == "table" and not is_color(h) then
            warning("The function only supports [color]-data!")
            return self
        end

        self.h = clamp(type(h) == "table" and h.h or (type(h) == "number" and h or self.h), 0, 360); if self.h >= 360 then self.h = 0 end
        self.s = clamp(type(h) == "table" and h.s or (type(s) == "number" and s or self.s), 0, 100)
        self.l = clamp(type(h) == "table" and h.l or (type(l) == "number" and l or self.l), 0, 100)
        self.hsl_a = clamp(type(h) == "table" and h.hsl_a or (type(hsl_a) == "number" and hsl_a or self.hsl_a), 0, 1)
        self.r, self.g, self.b, self.a = hsla_to_rgba(self.h, self.s, self.l, self.hsl_a)

        return self
    end

    --- @param self color
    --- @param min number
    --- @param max number
    --- @return @class[{color}]
    --- @description: randomizing the arguments of [{...}]
    function color:random(min, max)
        min = min and clamp(min, 0, 255) or 0
        max = max and clamp(max, 0, 255) or 255

        self.r = random(min, max)
        self.g = random(min, max)
        self.b = random(min, max)
        self.a = random(min, max)
        self.h, self.s, self.l, self.hsl_a = rgba_to_hsla(self.r, self.g, self.b, self.a)

        return self
    end

    --- @param self color
    --- @return number
    --- @description: converts the color in {[...]} and returns itself
    function color:array()
        return {self.r, self.g, self.b, self.a, self.h, self.s, self.l, self.hsl_a}
    end

    --- @param self color
    --- @param need_return boolean
    --- @return number, number, number, number
    --- @return @void
    --- @description: return itself as {[...]} if need_return->{true}, otherwise prints one time the content of {[...]}
    function color:inspect(need_return)
        if need_return then
            return self.r, self.g, self.b, self.a, self.h, self.s, self.l, self.hsl_a
        end

        print(self.r, self.g, self.b, self.a, " || ", self.h, self.s, self.l, self.hsl_a)
        return self
    end

    --- @param self color
    --- @return number, number, number, number, number, number, number, number
    --- @description: returns the content of {[...]}
    function color:unpack()
		return self.r, self.g, self.b, self.a, self.h, self.s, self.l, self.hsl_a
	end

    --- @param self color
    --- @param r number
    --- @param g number
    --- @param b number
    --- @param a number
    --- @return @class[{color}]
    --- @description: copying the color and returns the new one -> you can override any argument
    function color:copy(r, g, b, a)
        return color(
            r or self.r,
            g or self.g,
            b or self.b,
            a or self.a
        )
    end

    --- @param self color
    --- @param r number
    --- @param g number
    --- @param b number
    --- @param a number
    --- @return @class[{color}]
    --- @description: overrides any argument in the color{[...]}
    function color:set(r, g, b, a)
        if type(r) == "table" and not is_color(r) then
            warning("The function only supports [color]-data!")
            return self
        end

        self.r = clamp(type(r) == "table" and r.p or (type(r) == "number" and r or self.r), 0, 255)
        self.g = clamp(type(r) == "table" and r.y or (type(g) == "number" and g or self.g), 0, 255)
        self.b = clamp(type(r) == "table" and r.r or (type(b) == "number" and b or self.b), 0, 255)
        self.a = clamp(type(r) == "table" and r.a or (type(a) == "number" and a or self.a), 0, 255)
        self.h, self.s, self.l, self.hsl_a = rgba_to_hsla(self.r, self.g, self.b, self.a)

        return self
    end

    --- @param self color
    --- @param name string
    --- @return @class[{color}]
    --- @description: overrides preset in the color{[...]}
    function color:preset(name)
        if type(name) ~= "string" then
            warning("The function only supports string-data!")
            return self
        end

        if not COLOR_PRESETS[name] then
            warning("This preset name is not found in [COLOR_PRESETS] library!")
            return self
        end

        return self:set(unpack(COLOR_PRESETS[name]))
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: show every preset and his colors in @type[{COLOR_PRESETS}]
    function color:show_presets()
        for k, v in pairs(COLOR_PRESETS) do
            print(string.format("[%s] -> {%d, %d, %d, %d}", k, v[1], v[2], v[3], v[4]))
        end

        return self
    end

    --- @param self color
    --- @param r number
    --- @param g number
    --- @param b number
    --- @param a number
    --- @return @class[{color}]
    --- @description: adds to color[{...}] arguments[{...}] [color(1, 2, 3):offset(4, 5, 6)]->[color(5, 7, 9)]
    function color:offset(r, g, b, a)
        if type(r) == "table" and not is_color(r) then
            warning("The function only supports [color]-data!")
            return self
        end

        self.r = clamp(self.r + (type(r) == "table" and r.r or type(r) == "number" and r or 0), 0, 255)
        self.g = clamp(self.g + (type(r) == "table" and r.g or type(g) == "number" and g or 0), 0, 255)
        self.b = clamp(self.b + (type(r) == "table" and r.b or type(b) == "number" and b or 0), 0, 255)
        self.a = clamp(self.a + (type(r) == "table" and r.a or type(a) == "number" and a or 0), 0, 255)
        self.h, self.s, self.l, self.hsl_a = rgba_to_hsla(self.r, self.g, self.b, self.a)

        return self
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: round number in the lower position [color(1.5, 2.5, 3.5):floor()]->[color(1, 2, 3)]
    function color:floor()
        self.r = math.floor(self.r)
        self.g = math.floor(self.g)
        self.b = math.floor(self.b)
        self.a = math.floor(self.a)

        return self
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: round number in the higher position [color(1.5, 2.5, 3.5):ceil()]->[color(2, 3, 4)]
    function color:ceil()
        self.r = math.ceil(self.r)
        self.g = math.ceil(self.g)
        self.b = math.ceil(self.b)
        self.a = math.ceil(self.a)

        return self
    end

    --- @param self color
    --- @param slow_method boolean
    --- @param precision number
    --- @return @class[{color}]
    --- @description: round number in the faor position [color(1.3, 2.6, 3.25):round()]->[color(1, 3, 3)]
    --- @description: [{slow_method}]-> making really accurate calculations
    --- @description: [{precision}]-> last point of rounding break
    function color:round(slow_method, precision)
        if slow_method then
            local multiplier = 10 ^ (precision or 0)

            self.r = math.floor(self.r * multiplier + 0.5) / multiplier
            self.g = math.floor(self.g * multiplier + 0.5) / multiplier
            self.b = math.floor(self.b * multiplier + 0.5) / multiplier
            self.a = math.floor(self.a * multiplier + 0.5) / multiplier
        else
            self.r = round(self.r)
            self.g = round(self.g)
            self.b = round(self.b)
            self.a = round(self.a)
        end

        self.r = clamp(self.r, 0, 255)
        self.g = clamp(self.g, 0, 255)
        self.b = clamp(self.b, 0, 255)
        self.a = clamp(self.a, 0, 255)

        return self
    end

    --- @param self color
    --- @param new color to comparise
    --- @return @class[{color}]
    --- @description: find the difference between two class[{color}], and returns new normalized differenced class[{color}]
    function color:difference(new)
        if not is_color(new) then
            warning("The function only supports [color]-data!")
            return self
        end

        local copied = self:copy()

        copied.r = new.r - self.r
        copied.g = new.g - self.g
        copied.b = new.b - self.b
        copied.a = new.a - self.a

        copied.h = new.h - self.h
        copied.s = new.s - self.s
        copied.l = new.l - self.l
        copied.a = new.a - self.a

        return copied
    end

    --- @param self color
    --- @param inverse_alpha boolean
    --- @return @class[{color}]
    --- @description: returns the inversed color from itself
    function color:inverse(inverse_alpha)
        return color(255 - self.r, 255 - self.g, 255 - self.b, inverse_alpha and 255 - self.a or self.a)
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: sets the argument[{@self[@class[{@color}]]}] in the white tones
    function color:white()
        return self:set(255, 255, 255, 255)
    end

    --- @param self color
    --- @return boolean
    --- @description: checks the argument[{@self[@class[{@color}]]}] is in the white tones
    function color:is_white()
        return self == color()
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: sets the argument[{@self[@class[{@color}]]}] in the black tones
    function color:black()
        return self:set(0, 0, 0, 255)
    end

    --- @param self color
    --- @return boolean
    --- @description: checks the argument[{@self[@class[{@color}]]}] is in the black tones
    function color:is_black()
        return self == color(0, 0, 0, 255)
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: sets the argument[{@self[@class[{@color}]]}] in the red tones
    function color:red()
        return self:set(255, 0, 0, 255)
    end

    --- @param self color
    --- @return boolean
    --- @description: checks the argument[{@self[@class[{@color}]]}] is in the red tones
    function color:is_red()
        return self == color(255, 0, 0, 255)
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: sets the argument[{@self[@class[{@color}]]}] in the green tones
    function color:green()
        return self:set(0, 255, 0, 255)
    end

    --- @param self color
    --- @return boolean
    --- @description: checks the argument[{@self[@class[{@color}]]}] is in the green tones
    function color:is_green()
        return self == color(0, 255, 0, 255)
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: sets the argument[{@self[@class[{@color}]]}] in the blue tones
    function color:blue()
        return self:set(0, 0, 255, 255)
    end

    --- @param self color
    --- @return boolean
    --- @description: checks the argument[{@self[@class[{@color}]]}] is in the blue tones
    function color:is_blue()
        return self == color(0, 0, 255, 255)
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: sets the zero alpha of argument[{@self[@class[{@color}]]}]
    function color:transparent()
        return self:set(_, _, _, 0)
    end

    --- @param self color
    --- @return boolean
    --- @description: checks the alpha of argument[{@self[@class[{@color}]]}] is zero
    function color:is_transparent()
        return self.a == 0
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: sets the full alpha of argument[{@self[@class[{@color}]]}]
    function color:visible()
        return self:set(_, _, _, 255)
    end

    --- @param self color
    --- @return @class[{color}]
    --- @description: sets the medium alpha of argument[{@self[@class[{@color}]]}]
    function color:medium_visible()
        return self:set(_, _, _, 127.5)
    end

    --- @param self color
    --- @return boolean
    --- @description: checks the alpha of argument[{@self[@class[{@color}]]}] is not zero
    function color:is_visible()
        return self.a > 0
    end

    --- @param self color
    --- @return boolean
    --- @description: checks the alpha of argument[{@self[@class[{@color}]]}] is higher or equal than medium
    function color:is_medium_visible()
        return self.a >= 127.5
    end

    --- @param self color
    --- @return boolean
    --- @description: checks the alpha of argument[{@self[@class[{@color}]]}] is full
    function color:is_full_visible()
        return self.a == 255
    end

    --- @param self color
    --- @param value number
    --- @return @class[{@color}]
    --- @description: sets custom alpha in the argument[{@self[@class[{color}]]}]
    function color:alpha(value)
        self.a = clamp(value, 0, 255)
        self.hsl_a = self.a / 255

        return self
    end

    --- @param self color
    --- @param amount number
    --- @return @class[{@color}]
    --- @description: alpha fades-in in the argument[{@self[@class[{color}]]}]
    function color:fade_in(amount)
        self.a = math.min(self.a + amount, 255)
        self.hsl_a = self.a / 255

        return self
    end

    --- @param self color
    --- @param amount number
    --- @return @class[{@color}]
    --- @description: alpha fades-out in the argument[{@self[@class[{color}]]}]
    function color:fade_out(amount)
        self.a = math.max(self.a - amount, 0)
        self.hsl_a = self.a / 255

        return self
    end

    --- @param self color
    --- @param tolerance number
    --- @param return_text boolean
    --- @return string
    --- @return number[{@type}]
    --- @description: checks the contrast type of the argument[{@self[@class[{color}]]}]
    function color:contrast(tolerance, return_text)
        if self.r * 0.213 + self.g * 0.715 + self.b * 0.072 < (tolerance or 150) then
            return return_text and "WHITE" or COLOR_TYPES.WHITE
        end
    
        return return_text and "BLACK" or COLOR_TYPES.BLACK
    end
    
    --- @param self color
    --- @param strength number
    --- @return @class[{@color}]
    --- @description: saturates the argument[{@self[@class[{color}]]}]
    function color:saturate(strength)
        self.s = clamp(self.l + (strength or 5), 0, 100)
        self.r, self.g, self.b, self.a = hsla_to_rgba(self.h, self.s, self.l, self.hsl_a)

        return self
    end

    --- @param self color
    --- @param strength number
    --- @return @class[{@color}]
    --- @description: desaturates the argument[{@self[@class[{color}]]}]
    function color:desaturate(strength)
        self.s = clamp(self.l - (strength or 5), 0, 100)
        self.r, self.g, self.b, self.a = hsla_to_rgba(self.h, self.s, self.l, self.hsl_a)

        return self
    end

    --- @param self color
    --- @param strength number
    --- @return @class[{@color}]
    --- @description: lights the argument[{@self[@class[{color}]]}]
    function color:lighten(strength)
        self.l = clamp(self.l + (strength or 20), 0, 100)
        self.r, self.g, self.b, self.a = hsla_to_rgba(self.h, self.s, self.l, self.hsl_a)

        return self
    end

    --- @param self color
    --- @param strength number
    --- @return @class[{@color}]
    --- @description: darks the argument[{@self[@class[{color}]]}]
    function color:darken(strength)
        self.l = clamp(self.l - (strength or 20), 0, 100)
        self.r, self.g, self.b, self.a = hsla_to_rgba(self.h, self.s, self.l, self.hsl_a)

        return self
    end

    --- @param self color
    --- @param strength number
    --- @return @class[{@color}]
    --- @description: tints the argument[{@self[@class[{color}]]}]
    function color:tint(strength)
        return self:lighten(self.l + (1 - self.l) * (strength or 0.5))
    end

    --- @param self color
    --- @param strength number
    --- @return @class[{@color}]
    --- @description: shades the argument[{@self[@class[{color}]]}]
    function color:shade(strength)
        return self:lighten(self.l - self.l * (strength or 0.5))
    end
end

local f = color(168, 219, 127):show_presets()
--- @endregion

--- @region: __ENV
local __ENV = {
    __AUTHOR = "paranoica",
    __VERSION = "color.lua 30.07.2024 1.0",
    __URL = "https://github.com/paranoica/lua/modules/color.lua",
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

color["__ENV"] = __ENV
--- @endregion

--- @region: collect garbage and finish the library
collectgarbage("collect"); return function(local_definition)
    _G["COLOR_PRESETS"] = COLOR_PRESETS

    if local_definition then
        return {
            color = color
        }
    else
        _G["color"] = color
    end
end
--- @endregion

--- @diagnostic enable
--- @export : -> disabled
--- @listing : -> enabled
