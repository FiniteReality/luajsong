local json = require("json")
local imlib = require("imlib2")

local _M = { }
_M._VERSION = "1.0"
_M._COPYRIGHT = "copyright (C) 2017 FiniteReality"

local function create_jsong(file, location)
	local img = assert(imlib.image.load(file))
	local result = {
		version = "1.0",
		transparency = img:has_alpha(),
		size = {
			width = img:get_width(),
			height = img:get_height()
		},
		layers = { { pixels = { } } },
		comment = string.format("luajsong %s - lua %s", _M._VERSION, _VERSION)
	}

	local layer = result.layers[1].pixels

	for x = 0, result.size.width - 1 do
		for y = 0, result.size.height - 1 do
			local pixel = img:get_pixel(x, y)
			layer[#layer+1] = {
				position = {x = x, y = y},
				color = {red = pixel.red, green = pixel.green, blue = pixel.blue, alpha = pixel.alpha}
			}
		end
	end

	result = json.encode(result)
	local f = assert(io.open(location, "wb"))
	f:write(result)
	f:close()
end

local function load_jsong_data(data, location)
	assert(data.version == "1.0", "invalid or missing jsong version (supports jsong=1.0)")
	assert(data.transparency ~= nil, "missing transparency field")
	assert(data.size, "missing size field")
	assert(data.layers, "missing layers field")

	local img = assert(imlib.image.new(data.size.width, data.size.height))
	img:set_has_alpha(data.transparency)

	for _, layer in ipairs(data.layers) do
		if layer.default_color or layer.default_colour then
			local color = layer.default_color or layer.default_colour
			img:fill_rectangle(0, 0, data.size.width, data.size.height, color)
		end
		for _, pixel in ipairs(layer.pixels) do
			local color = imlib.color.new((pixel.color or pixel.colour).red, (pixel.color or pixel.colour).green, (pixel.color or pixel.colour).blue, (pixel.color or pixel.colour).alpha)
			img:draw_pixel(pixel.position.x, pixel.position.y, color)
		end
	end

	img:save(location)
end

local function load_jsong(data, location)
	if type(data) == "table" then
		return load_jsong_data(data, location)
	else
		local f = io.open(data)
		if f then
			-- load from file
			return load_jsong_data(json.decode(f:read("*a")), location)
		else
			return load_jsong_data(json.decode(data), location)
		end
	end
end

return {
	to_jsong = create_jsong,
	from_jsong = load_jsong
}
