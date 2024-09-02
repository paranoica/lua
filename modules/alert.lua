--- @diagnostic disable-next-line
--- @export : -> automatic
--- @listing : -> disabled

--- @description: cleaning the gargabe from possible contamination from past loads
collectgarbage("collect")

--- @region tools for script
local warning do
    --- @param message string
    --- @return @void
    warning = function(message)
        print(string.format("[!] %s", message))
    end
end
--- @endregion

--- @region: create alert module
local alert = {}
--- @endregion

--- @region: update alert module
do
    --- @class alert : message
    --- @param message string
    setmetatable(alert, alert); alert.__index = alert; alert.__call = function(self, message)
        if type(message) ~= "string" then
            warning("The greeting message was expected to be a string, but %s (%s) was received!"):format(tostring(message), type(message))
            return
        end

        return setmetatable({
            default_language = "en",
            translations = {
                ["en"] = {
                    ["greeting"] = "Welcome!"
                }
            }
        }, alert)
    end

    --- @param self alert
    --- @return @class[{alert}]
    --- @description: prints the greeting message
    function alert:start()
        if not self.translations[self.default_language]["greeting"] then
            warning(("Selected %s-language does not have greeting message in data!"):format(self.default_language))
            return self
        end

        print(self.translations[self.default_language]["greeting"])
        return self
    end

    --- @param self alert
    --- @param translation array
    --- @return @class[{alert}]
    --- @description: loads into language base your data-translation array
    function alert:load_translation(traslation)
        if type(traslation) ~= "table" then
            warning(("The translation data was expected to be a table, but %s (%s) was received!"):format(tostring(traslation), type(traslation)))
            return self
        end

        for translation_language, translation_data in pairs(traslation) do
            if self.translations[translation_language] then
                warning(("The loaded translation data with %s-language already exists in data!"):format(translation_language))
                return self
            end

            self.translations[translation_language] = translation_data
        end

        return self
    end

    --- @param self alert
    --- @param path string
    --- @return @class[{alert}]
    --- @description: loads into language base your translation data from path
    function alert:load_translation_from_file(path)
        if type(path) ~= "string" then
            warning(("The path was expected to be a string, but %s (%s) was received!"):format(tostring(path), type(path)))
            return self
        end

        local file = nil
        local succeed, _ = pcall(function()
            file = loadfile(path)()
        end)

        if not succeed then
            warning(("Error: no file or directory {%s}"):format(path))
            return self
        end

        if type(file) ~= "table" then
            warning(("The loaded file was expected to be a table, but %s (%s) was received!"):format(tostring(file), type(file)))
            return self
        end

        for translation_language, translation_data in pairs(file) do
            if self.translations[translation_language] then
                warning(("The loaded file with %s-language already exists in data!"):format(translation_language))
                return self
            end

            self.translations[translation_language] = translation_data
        end
        
        return self
    end

    --- @param self alert
    --- @param language string
    --- @return @class[{alert}]
    --- @description: sets the default language of alert
    function alert:set_language(language)
        if not self.translations[language] then
            warning(("Your %s-language must be exist in data"):format(language))
            return self
        end

        self.default_language = language
        return self
    end

    --- @param self alert
    --- @return @class[{alert}]
    --- @description: sets the default [en] language of alert
    function alert:set_default_language()
        self.default_language = "en"
        return
    end

    --- @param self alert
    --- @param language string
    --- @return @class[{alert}]
    --- @description: deletes the selected language from base
    function alert:delete_language(language)
        if language == "en" then
            warning("You cannot delete the default [en] language!")
            return self
        end

        if not self.translations[language] then
            warning(("Your %s-language must be exist in data!"):format(language))
            return self
        end

        self.translations[language] = nil

        return self
    end

    --- @param self alert
    --- @param translation_data array
    --- @return @class[{alert}]
    --- @description: creates the new alert messages in global data
    function alert:create(translation_data)
        if type(translation_data) ~= "table" then
            warning(("The translation data was expected to be a table, but %s (%s) was received!"):format(tostring(translation_data), type(translation_data)))
            return self
        end

        for data_language, data in pairs(translation_data) do
            if not self.translations[data_language] then
                -- i know about goto continue statement, but it does not support in LUA 5.1 version :(
                warning(("Translation key with %s-language does not exist in data"):format(data_language))
                return self
            end

            if type(data) ~= "table" then
                warning(("Translation data with %s-language was expected to be a table, but %s (%s) was received!"):format(tostring(data_language), data, type(data)))
                return self
            end

            for data_key, key in pairs(data) do
                if self.translations[data_language][data_key] then
                    warning(("The [%s] data-key already exists in %s-language data!"):format(data_key, data_language))
                    return self
                end

                if type(key) ~= "string" then
                    warning(("The [%s] data-key was expected to be a string, but %s (%s) was received!"):format(tostring(data_key), key, type(key)))
                    return self
                end

                self.translations[data_language][data_key] = key
            end
        end

        return self
    end

    --- @param self alert
    --- @param key string
    --- @param language [string, nil]
    --- @param parameters string
    --- @return @class[{alert}]
    --- @description: prints the unique message taken from base
    function alert:call(key, language, parameters)
        if type(key) ~= "string" then
            warning(("The key was expected to be a string, but %s (%s) was received!"):format(tostring(key), type(key)))
            return self
        end

        local selected_language = language or self.default_language
        if type(selected_language) ~= "string" then
            warning(("Selected language was expected to be a string, but %s (%s) was received!"):format(tostring(selected_language), type(selected_language)))
            return self
        end

        if not self.translations[selected_language] then
            warning(("Your %s-language must be exist in data"):format(language))
            return self
        end

        if not self.translations[selected_language][key] then
            warning(("Cannot find [%s] key in %s-language data!"):format(key, selected_language))
            return self
        end

        if parameters then
            local message = self.translations[selected_language][key]:gsub("(.?)%%{%s*(.-)%s*}", function(letter, key)
                if letter == "%" then
                    return
                else
                    local suffix = parameters[key] and tostring(parameters[key]) or ("%%{%s}"):format(key)
                    return letter .. suffix
                end
            end)

            if message == self.translations[selected_language][key] then
                message = self.translations[selected_language][key]:gsub("%%([cdEefgGiouXxsq])", function(format)
                    local replacement = table.remove(parameters, 1)
                    return string.format("%" .. format, replacement)
                end)
            end

            print(message)
        else
            print(self.translations[selected_language][key])
        end

        return self
    end

    --- @param self alert
    --- @param ... [keys, languages, parameters] or [...strings]
    --- @return @class[{alert}]
    --- @description: prints the unique messages [!!!] taken from base
    function alert:multiple_call(...)
        local arguments = {...}
        if type(arguments[1]) ~= "table" and type(arguments[1]) ~= "string" then
            warning(("The keys were expected to be a table or string, but %s (%s) was received!"):format(tostring(arguments[1]), type(arguments[1])))
            return self
        end

        if type(arguments[1]) == "table" then
            local selected_language = arguments[2] or self.default_language
            if not self.translations[selected_language] then
                warning(("Your %s-language must be exist in data"):format(selected_language))
                return self
            end

            for i = 1, #arguments[1] do
                if not self.translations[selected_language][arguments[1][i]] then
                    warning(("Cannot find [%s] key in %s-language data!"):format(arguments[1][i], selected_language))
                    return self
                end

                if arguments[3] then
                    local message = self.translations[selected_language][arguments[1][i]]:gsub("(.?)%%{%s*(.-)%s*}", function(letter, key)
                        if letter == "%" then
                            return
                        else
                            if not arguments[3][arguments[1][i]] then
                                return
                            end

                            local suffix = arguments[3][arguments[1][i]][key] and tostring(arguments[3][arguments[1][i]][key]) or ("%%{%s}"):format(key)
                            return letter .. suffix
                        end
                    end)

                    if message == self.translations[selected_language][arguments[1][i]] then
                        message = self.translations[selected_language][arguments[1][i]]:gsub("%%([cdEefgGiouXxsq])", function(format)
                            local replacement = table.remove(arguments[3][arguments[1][i]], 1)
                            return string.format("%" .. format, replacement)
                        end)
                    end

                    print(message)
                else
                    print(self.translations[selected_language][arguments[1][i]])
                end
            end
        else
            for i = 1, #arguments do
                if not self.translations[self.default_language][arguments[i]] then
                    warning(("Cannot find [%s] key in %s-language data!"):format(arguments[i], self.default_language))
                    return self
                end

                print(self.translations[self.default_language][arguments[i]])
            end
        end

        return self
    end
end

--- @region: __ENV
local __ENV = {
    __AUTHOR = "paranoica",
    __VERSION = "alert.lua 02.09.2024 1.0",
    __URL = "https://github.com/paranoica/lua/modules/alert.lua",
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

alert["__ENV"] = __ENV
--- @endregion

--- @region: examples
--[[
    local object = alert("Welcome!"):start() --> Welcome!

    object:start() --> Welcome!

    local translations = {
        en = {
            name = "Objects name: undefined.",
            age = "Objects age: undefined."
        },

        ru = {
            name = "Имя объекта: не установлено.",
            age = "Возраст объекта: не установлен."
        }
    }

    local other_translations = {
        ru = {
            name = "Имя объекта: не установлено.",
            age = "Возраст объекта: не установлен."
        },

        de = {
            name = "Objektname: nicht festgelegt.",
            age = "Objektalter: nicht festgelegt."
        }
    }

    object:load_translation(translations) --> error: [en] language is already exists in base.
    object:load_translation(other_translations) --> succesfull

    object:load_translation_from_file("./translations/de.lua") --> error: [de] language is already exists in base.
    object:load_translation_from_file("./translations/fr.lua") --> succesfull

    --[
        example of the translation file:
        [fr.lua] -> [
            return {
                fr = {
                    greeting = "Bonjour!" -- necessarily!!! otherwise you will catch error.
                    name = "Nom de l'objet : non défini.",
                    age = "Âge de l'objet : non défini."
                }
            }
        ]
    --]

    object:create({ -- properly method instance of translations, because [en] language is already exists.
        en = {
            name = "Objects name: undefined.",
            age = "Objects age: undefined.",
            cat = "Cats name is %{name}.",
            cat_age = "Cats age is %{age}.",
            cat_status = "Today cat is in %s mood and he wanna %d fishes."
        },

        ru = {
            ....
        }
    })

    -- default language is [en]
    object:call("name") --> Objects name: undefined.
    object:call("age", "de") --> Objektalter: nicht festgelegt.

    object:set_language("ru")
    object:call("age") --> Возраст объекта: не установлен.

    object:set_default_language()
    object:call("age") --> Objects age: undefined.

    object:call("cat", _, {name = "Richard"}) --> Cats name is Richard.
    object:call("cat", _, {age = 18}) --> Cats name is %{name}.
    object:call("cat_age", _, {age = 18}) --> Cats age is 18.
    object:call("cat_status", _, {"good", 18}) --> Today cat is in good mood and he wanna 18 fishes.

    object:multiple_call("name", "age", "cat", "cat_age", "cat_status")
    -->
    --[
        Objects name: undefined.
        Objects age: undefined.
        Cats name is %{name}.
        Cats age is %{age}.
        Today cat is in %s mood and he wanna %d fishes.
    --]

    object:multiple_call({"name", "age", "cat", "cat_age", "cat_status"}, _, {
        cat = "Arthur",
        cat_age = "17",
        cat_status = {"sad", 2}
    })

    --> 
    --[
        Objects name: undefined.
        Objects age: undefined.
        Cats name is %{name}.
        Cats age is %{age}.
        Today cat is in sad mood and he wanna 2 fishes.
    --]

    print(object.translations["ru"]) --> table: XXXXXXXX

    object:delete_language("br") --> error: br-language does not exist
    object:delete_language("ru") --> succesfull

    print(object.translations["ru"]) --> nil
--]]
--- @endregion

--- @region: collect garbage and finish the library
collectgarbage("collect"); return function(local_definition)
    if local_definition then
        return {
            alert = alert
        }
    else
        _G["alert"] = alert
    end
end
--- @endregion

--- @diagnostic enable
--- @export : -> disabled
--- @listing : -> enabled
