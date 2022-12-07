local secure_library = function(create_function)
	local source = create_function()
	local source_cache = create_function()

	source.__index = nil
	source.__newindex = nil

	for field, _ in pairs(source) do
		source[field] = nil
	end

	local metatable = {
		__metatable = false,
		__index = function(self, index)
			if source_cache[index] then
				return source_cache[index]
			else
				print("Error: this library has read-only access!")
				return nil
			end
		end,

		__newindex = function()
			print("Error: this library has read-only access!")
			return nil
		end
	}

	return setmetatable(source, metatable)
end

return secure_library

--[[ @example:
	local new_class = secure_library(function()
		local structure do
			structure = {}
			structure.__index = structure
		end

		structure.FIRST = 1
		structure.MESSAGE = "Hello!"

		function structure:get()
			return self.FIRST, self.MESSAGE
		end

		return structure
	end)

	print(new_class.FIRST, new_class.MESSAGE) -> 1 Hello!
	print(new_class:get()) -> 1 Hello!

	new_class.init_new_variable = true -> Error: this library has read-only access!
	print(new_class.init_new_variable) -> nil

	for field, object in pairs(new_class) do
		--- @note: loop will not work and inspect values due to security!
	end
--]]
