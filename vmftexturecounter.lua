
concommand.Add("CountLeastUsedTextures", function(player, command, arguments)
	local map, count = arguments[1], tonumber(arguments[2])

	-- Prepare the map name and texture count
	if (!map) then
		MsgC(Color(255, 100, 100), "Invalid map. (Ex: gm_construct.vmf 10)\n")

		return
	end

	map = string.lower(map)

	local extension = string.GetExtensionFromFilename(map)

	if (extension) then
		if (extension != "vmf") then
			MsgC(Color(255, 100, 100), "Invalid map. (Ex: gm_construct.vmf 10)\n")

			return
		end
	else
		map = map .. ".vmf"
	end

	if (!count or count < 1) then
		MsgC(Color(255, 100, 100), "Invalid texture count. (Ex: gm_construct.vmf 10)\n")

		return
	end

	local vmfInfo = file.Read(map, "DATA") -- Get the VMF file from the data folder in txt form

	if (!vmfInfo) then
		MsgC(Color(255, 100, 100), "Invalid map. (Ex: gm_construct.vmf 10)\n")

		return
	end

	vmfInfo = "vmf\n{\n" .. vmfInfo .. "\n}" -- Add the required formatting to the VMF

	local kvTable = util.KeyValuesToTablePreserveOrder(vmfInfo) -- Convert to a table
	local materials = {}

	-- Loop through the table and find all the materials from solids and entities
	for _, v in pairs(kvTable) do
		if (v.Key != "world" and v.Key != "entity") then continue end

		for _, v2 in pairs(v.Value) do
			if (v2.Key != "solid" or !istable(v2.Value)) then continue end

			for _, v3 in pairs(v2.Value) do
				if (v3.Key != "side") then continue end

				for _, v4 in pairs(v3.Value) do
					if (v4.Key != "material") then continue end

					-- Add the material to the table
					if (materials[v4.Value]) then
						materials[v4.Value] = materials[v4.Value] + 1
					else
						materials[v4.Value] = 1
					end
				end
			end
		end
	end

	local sortedMaterials = {}

	for k, v in pairs(materials) do
		table.insert(sortedMaterials, {material = k, count = v})
	end

	-- Sort the materials by count
	table.sort(sortedMaterials, function(a, b) return a.count < b.count end)

	-- Print the top materials with the least amount of occurrences
	MsgC(Color(200, 200, 50), "TOP " .. count .. " LEAST USED TEXTURES IN " .. string.upper(string.StripExtension(map)) .. ":\n")
	MsgC(Color(200, 150, 100), "==================================================\n")

	for i = 1, count do
		local material = sortedMaterials[i]

		MsgC(Color(200, 200, 100), string.format("%-10s ", material.material), color_white, string.rep(".", 70 - #material.material), Color(100, 150, 255), " " .. material.count, "\n") -- Overcomplicated formatting to make it look nicer
	end
end, nil, "Outputs the least used textures in a .vmf file.")
