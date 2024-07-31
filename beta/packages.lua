local preload = {
    paths = {}
} do
    setmetatable(preload, preload)

    preload.__index = preload
    preload.__call = function(self, path, name, fn)
        if type(path) == "string" and path ~= "name" then
            local name = tostring(name)
            local correct_path = path:sub(#path) ~= "/" and path .. "/" or path

            if not preload["paths"][correct_path] then
                preload["paths"][correct_path] = {}
            end

            if preload["paths"][correct_path][name] then
                return preload["paths"][correct_path][name]
            end; preload["paths"][correct_path][name] = true
            
            return setmetatable({
                name = name,
                path = correct_path,

                fn = fn or function()
                    return nil
                end,

                restore_fn = fn or function()
                    return nil
                end
            }, preload)
        end
        return
    end

    function preload:get_path()
        return self.path
    end

    function preload:set_path(path)
        if type(path) ~= "string" then
            return self
        end

        local path = path:sub(#path) ~= "/" and path .. "/" or path
        if not self["paths"][path] then
            self["paths"][path] = {}
            self["paths"][path][self.name] = true
        end

        self["paths"][self.path][self.name] = nil
        self.path = path

        return self
    end

    function preload:get_name()
        return self.name
    end

    function preload:set_name(name)
        if type(name) ~= "string" then
            return self
        end

        if self["paths"][self.path][name] then
            return self["paths"][self.path][name]
        end

        self["paths"][self.path][self.name] = nil
        self["paths"][self.path][name] = true
        self.name = name

        return self
    end

    function preload:get_function(load, ...)
        return load == nil and self.fn or self.fn(...)
    end

    function preload:set_function(fn)
        if type(fn) ~= "function" then
            return self
        end

        self.restore_fn = self.fn
        self.fn = fn

        return self
    end

    function preload:restore_function()
        self.fn = self.restore_fn
        return self
    end

    function preload:set_restore_function(fn)
        if type(fn) ~= "function" then
            return self
        end

        self.restore_fn = fn
        return self
    end

    function preload:get_info(n_return)
        if n_return then
            return self.directory, self.name, self.fn, self.restore_fn
        end

        --todo active/inactive/error status
        print(string.format(
            "name: %s\npath: %s\nfull-directory: %s\nfunction: %s (%s)\nrestore-function: %s (%s)", 
            self.name, self.path, self.path .. self.name .. "/",
            tostring(self.fn), "active", tostring(self.restore_fn), "active"
        ))

        return self
    end

    function preload:set_info(path, name, fn, restore_fn)
        if type(path) ~= "string" or path == "path" then
            return self
        end

        self:set_path(path)
        self:set_name(name)

        self:set_function(fn)
        self:set_restore_function(restore_fn)

        return self
    end

    function preload:load()
        package.preload[self.path .. self.name .. "/"] = function()
            return function(...)
                return self.fn(...)
            end
        end
    end

    function preload:unload()
        package.preload[self.path .. self.name .. "/"] = nil
    end
end

return preload

--todo make :enable_function(), :disable_function(), :pcall()
--todo make pcall-check in preload, and restore function, if we caught error
