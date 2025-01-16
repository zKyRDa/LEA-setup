--[[
	   
	Author: СоМиК
	Links:
		- https://www.blast.hk/members/406277/
		- https://t.me/klamet_one
		- https://vk.com/klamet1

]]

local imgui = require 'mimgui'
local vk = require 'vkeys'

HOTKEY = {
	MODULEINFO = {
		version = 3,
		author = 'СоМиК',
		modified_by = "Law Enforcer Assistant | KyRDa"
	},
	Text = {
		WaitForKey = 'Нажмите любую клавишу...',
		NoKey = '< Свободно >'
	},
	List = {},
	ActiveKeys = {},
	ReturnHotKeys = nil,
	HotKeyIsEdit = nil,
	CancelKey = 0x1B,
	RemoveKey = 0x08,
	True = true
}

local specialKeys = {
	0x10,
	0x11,
	0x12,
	0xA4,
	0xA5
}

deepcopy = function(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

local keyIsSpecial = function(key)
	for k, v in ipairs(specialKeys) do
		if v == key then
			return true
		end
	end
	return false
end

HOTKEY.getKeysText = function(name)
	local keysText = {}
	if HOTKEY.List[name] ~= nil then
		for k, v in ipairs(HOTKEY.List[name].keys) do
			table.insert(keysText, vk.id_to_name(v))
		end
	end
	return table.concat(keysText, ' + ')
end

local searchHotKey = function(keys)
	local needCombo = deepcopy(keys)

	table.sort(needCombo)
	needCombo = table.concat(needCombo, ':')

	for k, v in pairs(HOTKEY.List) do
		if next(v.keys) then
			local foundCombo = deepcopy(v.keys)

			table.sort(foundCombo)
			foundCombo = table.concat(foundCombo, ':')
			
			if foundCombo == needCombo and not imgui.IsAnyItemActive() and (v.no_inChat or not sampIsChatInputActive()) and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
				consumeWindowMessage(true, false)
				v.callback(k)
			end
		end
	end
end

HOTKEY.RegisterHotKey = function(name, soloKey, keys, callback, no_inChat)
	if HOTKEY.List[name] == nil then

		HOTKEY.List[name] = {
			soloKey = soloKey,
			keys = keys,
			callback = callback,
			no_inChat = no_inChat
		}

		return {
			name,
			['ShowHotKey'] = setmetatable({}, {__call = function(self, arg1, arg2) return HOTKEY.ShowHotKey(arg1[1], arg2) end}),
			['EditHotKey'] = setmetatable({}, {__call = function(self, arg1, arg2) return HOTKEY.EditHotKey(arg1[1], arg2) end}),
			['RemoveHotKey'] = setmetatable({}, {__call = function(self, arg) return HOTKEY.RemoveHotKey(arg[1]) end}),
			['GetHotKey'] = setmetatable({}, {__call = function(self, arg) return HOTKEY.GetHotKey(arg[1]) end})
		}
	end
end

HOTKEY.EditHotKey = setmetatable(
	{},
	{
		__call = function(self, name, keys)
			if HOTKEY.List[name] ~= nil then
				HOTKEY.List[name].keys = keys
				return true
			end
			return false
		end
	}
)

HOTKEY.EditName = setmetatable(
	{},
	{
		__call = function(self, old_name, new_name)
			if HOTKEY.List[old_name] ~= nil and old_name ~= new_name then

				HOTKEY.List[new_name] = deepcopy(HOTKEY.List[old_name])
				HOTKEY.List[old_name] = nil
				
				return true
			end

			return false
		end
	}
)

HOTKEY.RemoveHotKey = setmetatable(
	{},
	{
		__call = function(self, name)
			HOTKEY.List[name] = nil
			return true
		end
	}
)

HOTKEY.ShowHotKey = setmetatable(
	{},
	{
		__call = function(self, name, sizeButton, button_col)
			if HOTKEY.List[name] ~= nil then
				local HotKeyText = #HOTKEY.List[name].keys == 0 and ((HOTKEY.HotKeyIsEdit ~= nil and HOTKEY.HotKeyIsEdit.NameHotKey == name) and HOTKEY.Text.WaitForKey or HOTKEY.Text.NoKey) or HOTKEY.getKeysText(name)
				if imgui.AnimButton(('%s##HK:%s'):format(HotKeyText, name), sizeButton, button_col) then
					HOTKEY.HotKeyIsEdit = {
						NameHotKey = name,
						BackupHotKeyKeys = HOTKEY.List[name].keys,
					}
					HOTKEY.ActiveKeys = {}
					HOTKEY.HotKeyIsEdit.ActiveKeys = {}
					HOTKEY.List[name].keys = {}
				end
				if HOTKEY.ReturnHotKeys == name then
					HOTKEY.ReturnHotKeys = nil
					return true
				end
			else
				imgui.AnimButton('Хоткей не найден', sizeButton, button_col)
			end
		end
	}
)

HOTKEY.GetHotKey = setmetatable(
	{},
	{
		__call = function(self, name)
			if HOTKEY.List[name] ~= nil then
				return HOTKEY.List[name].keys
			end
		end
	}
)

HOTKEY.GetHotKeyList = setmetatable(
	{},
	{
		__call = function(self)
			return HOTKEY.List
		end
	}
)
local key_translation = {
	[vk.VK_SHIFT] = vk.VK_MBUTTON,
	[65568] = vk.VK_XBUTTON1,
	[131136] = vk.VK_XBUTTON2
}
addEventHandler('onWindowMessage', function(msg, key, lparam)
	if msg == 641 or msg == 642 or lparam == -1073741809 then HOTKEY.ActiveKeys = {} end

	local isSpecMouseButton = false
	if msg == 0x0207 or msg == 0x020b then
		key = key_translation[key]
		isSpecMouseButton = true
	end

	if msg == 0x100 or msg == 260 or isSpecMouseButton or msg == 0x0201 or msg == 0x0204 then
		
		if HOTKEY.HotKeyIsEdit == nil then
			if key ~= HOTKEY.CancelKey and key ~= HOTKEY.RemoveKey and key ~= 0x1B and key ~= 0x08 and next(HOTKEY.List) then
				local found = false
				for k, v in ipairs(HOTKEY.ActiveKeys) do
					if v == key then
						found = true
						break
					end
				end
				if not found then
					table.insert(HOTKEY.ActiveKeys, key)
					if keyIsSpecial(key) then
						table.sort(HOTKEY.ActiveKeys)
					else
						searchHotKey(HOTKEY.ActiveKeys)
						table.remove(HOTKEY.ActiveKeys)
					end
				end
			end
		else
			if key == HOTKEY.CancelKey then
				HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].keys = HOTKEY.HotKeyIsEdit.BackupHotKeyKeys
				HOTKEY.HotKeyIsEdit = nil
			elseif key == HOTKEY.RemoveKey then
				HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].keys = {}
				HOTKEY.ReturnHotKeys = HOTKEY.HotKeyIsEdit.NameHotKey
				HOTKEY.HotKeyIsEdit = nil
			elseif key ~= 0x1B and key ~= 0x08 then
				local found = false
				for k, v in ipairs(HOTKEY.HotKeyIsEdit.ActiveKeys) do
					if v == key then
						found = true
						break
					end
				end
				if not found then
					if keyIsSpecial(key) then
						if not HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].soloKey then
							for k, v in ipairs(specialKeys) do
								if key == v then
									table.insert(HOTKEY.HotKeyIsEdit.ActiveKeys, v)
								end
							end
							table.sort(HOTKEY.HotKeyIsEdit.ActiveKeys)
							HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].keys = HOTKEY.HotKeyIsEdit.ActiveKeys
						end
					else
						table.insert(HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].keys, key)
						HOTKEY.ReturnHotKeys = HOTKEY.HotKeyIsEdit.NameHotKey
						HOTKEY.HotKeyIsEdit = nil
					end
				end
			end
			consumeWindowMessage(true, true)
		end
	elseif msg == 0x101 or msg == 261 then
		if keyIsSpecial(key) then
			local pizdec = HOTKEY.HotKeyIsEdit ~= nil and HOTKEY.HotKeyIsEdit.ActiveKeys or HOTKEY.ActiveKeys
			for k, v in ipairs(pizdec) do
				if v == key then
					table.remove(pizdec, k)
					break
				end
			end
		end
	end
end)

local function bringVec4To(from, to, start_time, duration)
	local timer = os.clock() - start_time
	if timer >= 0.00 and timer <= duration then
		local count = timer / (duration / 100)
		return imgui.ImVec4(
			from.x + (count * (to.x - from.x) / 100),
			from.y + (count * (to.y - from.y) / 100),
			from.z + (count * (to.z - from.z) / 100),
			from.w + (count * (to.w - from.w) / 100)
		), true
	end
	return (timer > duration) and to or from, false
end

imgui.AnimButton = {}
setmetatable(imgui.AnimButton, {
	__call = function(self, label, size)
		local duration = { 1.0, 0.3 }
    
		local cols = {
			default = imgui.ImVec4(0, 0, 0, 0),
			hovered = imgui.ImVec4(0.5, 0.5, 0.5, 0.2),
			active  = imgui.ImVec4(0.5, 0.5, 0.5, 0.3)
		}
	
		if not self[label] then
			self[label] = {
				color = cols.default,
				clicked = { nil, nil },
				cursor = nil,
				hovered = {
					cur = false,
					old = false,
					clock = nil,
				}
			}
		end
		local pool = self[label]
	
		if pool["clicked"][1] and pool["clicked"][2] then
			if os.clock() - pool["clicked"][1] <= duration[2] then
			pool["color"] = bringVec4To(
					pool["color"],
					cols.active,
					pool["clicked"][1],
					duration[2]
				)
				goto no_hovered
			end
				
			if os.clock() - pool["clicked"][2] <= duration[2] then
				pool["color"] = bringVec4To(
					pool["color"],
					pool["hovered"]["cur"] and cols.hovered or cols.default,
					pool["clicked"][2],
					duration[1]
				)
				goto no_hovered
			end
		end
	
		if pool["hovered"]["clock"] ~= nil then
			if os.clock() - pool["hovered"]["clock"] <= duration[1] then
				pool["color"] = bringVec4To(
					pool["color"],
					pool["hovered"]["cur"] and cols.hovered or cols.default,
					pool["hovered"]["clock"],
					duration[1]
				)
			else
				pool["color"] = pool["hovered"]["cur"] and cols.hovered or cols.default
			end
		end
	
		::no_hovered::
	
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(pool["color"]))
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(pool["color"]))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(pool["color"]))

		local result = imgui.Button(label, size or imgui.ImVec2(0, 0))
		imgui.PopStyleColor(3)
	
		if result then
			pool["clicked"] = {
				os.clock(),
				os.clock() + duration[2]
			}
			pool["cursor"] = imgui.GetMousePos()
		end
	
		pool["hovered"]["cur"] = imgui.IsItemHovered(imgui.HoveredFlags.AllowWhenBlockedByActiveItem)
		if pool["hovered"]["old"] ~= pool["hovered"]["cur"] then
			pool["hovered"]["old"] = pool["hovered"]["cur"]
			pool["hovered"]["clock"] = os.clock()
		end
	
		if imgui.IsItemHovered() then
			imgui.SetMouseCursor(7) -- hand
		end
		
		return result
	end
})



return HOTKEY