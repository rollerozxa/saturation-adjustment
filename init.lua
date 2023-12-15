
local storage = minetest.get_mod_storage()

local current_saturation = tonumber(storage:get("saturation") or 1)
local huds = {}

minetest.register_on_joinplayer(function(player)
	player:set_lighting{ saturation = current_saturation }
end)

local function get_formspec(val)
	local W = 10

	local fs = {
		"formspec_version[6]",
		"size[", W, ",0.5]",
		"position[0.5,0.75]",
		"no_prepend[]",
		"bgcolor[#00000000]",

		"style[lbl;border=false;noclip=true]",
		"style_type[label;noclip=true;font_size=14]",
		"button[0,-1.25;", W, ",0.8;lbl;Adjust the saturation:]",

		"scrollbar[0,0;", W, ",0.5;horizontal;saturation;", val * 500, "]"
	}

	for i, val in ipairs{"0.0", "0.5", "1.0", "1.5", "2.0"} do
		table.insert(fs, "label["..(0.52+(i-1)*2.12)..",0.75;"..val.."]")
	end

	return table.concat(fs)
end

minetest.register_chatcommand('set_saturation', {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)

		minetest.show_formspec(name, 'set_saturation:fs', get_formspec(current_saturation))

		huds[name] = player:hud_add{
			hud_elem_type = "text",
			position = {x=0.5, y=0.715},
			name = "set_saturation:hud",
			scale = {x = 1.1, y = 1},
			text = string.format("%1.2f", current_saturation),
			number = 0xFFFFFF,
			z_index = 10000
		}
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= 'set_saturation:fs' then return end

	local name = player:get_player_name()

	if fields.quit then
		player:hud_remove(huds[name])
	end

	if not fields.saturation then return end

	local scrl = minetest.explode_scrollbar_event(fields.saturation)

	if scrl.type == 'CHG' then
		local saturation = scrl.value / 500
		storage:set_float("saturation", saturation)
		current_saturation = saturation

		player:set_lighting{ saturation = saturation }

		player:hud_change(huds[name], "text", string.format("%1.2f", saturation))
	end
end)
