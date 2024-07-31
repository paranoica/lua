--todo rework this
local new_class = function(body, contacts)
    local class_list = {}
    local add_to_class_list = function(class_member)
        if not class_list[class_member] then
            class_list[class_member] = true
        end
    end

    local class do
        class = type(body) == "table" and body or type(body) == "nil" and {} or {body}
        class.__index = class
    end

    if contacts and type(contacts) == "table" then
        for node_type, node in pairs(contacts) do
            class[node_type] = node
        end
    end

    --- @note: custom functions
    add_to_class_list("copy")
    function class:copy(avoid_metatable)
        local result = {}
        for field, object in pairs(self) do
            if avoid_metatable and field:sub(1, 2) == "__" then
                break
            end

            result[field] = object
        end

        return result
    end

    add_to_class_list("count")
    function class:count()
        local results = {
            visible = 0,
            class_members = 0
        }

        for field, object in pairs(self) do
            if class_list[field] or (type(field) == "string" and field:sub(1, 2) == "__") then
                results.class_members = results.class_members + 1
            else
                results.visible = results.visible + 1
            end
        end

        return results
    end

    add_to_class_list("inspect")
    function class:inspect(only_user)
        local counter = self:count()
        print(("[%d:%d:%d] -> user:class:total"):format(
            counter.visible, counter.class_members, counter.visible + counter.class_members
        ))

        for field, object in pairs(self) do
            if only_user and (class_list[field] or (type(field) == "string" and field:sub(1, 2) == "__")) then
                break
            end

            print(("\t[%s] -> %s"):format(field, tostring(object)))
        end

        return self
    end

    add_to_class_list("valid")
    function class:valid(element)
        return self[element] ~= nil
    end

    add_to_class_list("stringify")
    function class:stringify(copy)
        local amount = self:count().visible
        if copy then
            local result = {}
            for field, object in pairs(self) do
                result[field] = tostring(object)
            end

            for i = 1, amount do
                if type(result[i]) == "nil" then
                    result[i] = "nil"
                end
            end

            return result
        else
            for field, object in pairs(self) do
                self[field] = tostring(object)
            end

            for i = 1, amount do
                if type(self[i]) == "nil" then
                    self[i] = "nil"
                end
            end

            return self
        end
    end

    add_to_class_list("position")
    function class:position(element)
        for field, object in pairs(self) do
            if object == element then
                return field
            end
        end
        return -1
    end

    add_to_class_list("find")
    function class:find(target)
        for field, object in pairs(self) do
            if object == target then
                return true, field
            end
        end
        return false, -1
    end

    add_to_class_list("fill")
    function class:fill(how_much, fill_element, overwrite)
        for i = (overwrite and 1 or #self + 1), how_much + (overwrite and 0 or #self) do
            self[i] = fill_element
        end
        return self
    end

    --- @note: rebuild default functions
    add_to_class_list("concat")
    function class:concat(...)
        table.concat(self, ...)
        return self
    end

    add_to_class_list("insert")
    function class:insert(...)
        table.insert(self, ...)
        return self
    end

    add_to_class_list("remove")
    function class:remove(target)
        table.remove(self, type(target) == "string" and self:position(target) or target)
        return self
    end

    add_to_class_list("sort")
    function class:sort(...)
        table.sort(self, ...)
        return self
    end

    return class
end

return new_class
