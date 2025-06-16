
-- Код хоткеев от СоМиК переделан специально для Law Enforcer Assistant 

local imgui = require 'mimgui'
local wm = require 'windows.message'
local vk_inited, vk = pcall(require, 'LEA.vkeys')
if not vk_inited then
	vk = require 'vkeys'
end

local encoding = require('encoding')
encoding.default = 'CP1251'
local u8 = encoding.UTF8

HOTKEY = {
	version = 14,
	Text = {
		WaitForKey = 'Key...',
		NoKey = 'None'
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
	[vk.VK_SHIFT] = true,
	[vk.VK_CONTROL] = true,
	[vk.VK_MENU] = true,
	[vk.VK_LMENU] = true,
	[vk.VK_RMENU] = true
}

local keyIsSpecial = function(key)
	return specialKeys[key]
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

local function isValueInITable(value, t)
	for k, v in ipairs(t) do
		if v == value then
			return true, k
		end
	end

	return false
end

local function object_vs(o1, o2)
	if o1 == o2 then return true end
	local t1Type = type(o1)
	local t2Type = type(o2)
	if t1Type ~= t2Type then return false end
	if t1Type ~= 'table' then return false end

	local keySet = {}

	for key1, value1 in pairs(o1) do
		local value2 = o2[key1]
		if value2 == nil or object_vs(value1, value2) == false then
			return false
		end
		keySet[key1] = true
	end

	for key2, _ in pairs(o2) do
		if not keySet[key2] then return false end
	end

	return true
end

local searchHotKey = function(keys)
    local canTriggerHotkey = 
        ((imgui.Loaded and not imgui.IsAnyItemActive()) or not imgui.Loaded) and
        not sampIsDialogActive() and 
        not isSampfuncsConsoleActive()

    if not canTriggerHotkey then return end

	table.sort(keys)

    for k, v in pairs(HOTKEY.List) do
        -- Проверяем наличие ключей на соответствие
        if next(v.keys) and object_vs(keys, v.keys) and (v.inChat == sampIsChatInputActive()) and v.available() then
			consumeWindowMessage(true, false)
			v.callback(k)
        end
    end
end

---@param name string
---@param soloKey boolean
---@param keys table
---@param callback function
---@param available function
---@param inChat boolean
---@return metatable
HOTKEY.RegisterHotKey = function(name, soloKey, keys, callback, available, inChat)
	if HOTKEY.List[name] == nil then
		HOTKEY.List[name] = {
			soloKey = soloKey,
			keys = keys,
			callback = callback,
			inChat = inChat or false,
			name = name,
			available = available or function() return true end
		}

		return {
			name = name,
			['ShowHotKey'] = setmetatable({}, {__call = function(self, arg1, arg2) return HOTKEY.ShowHotKey(arg1.name, arg2) end}),
			['EditHotKey'] = setmetatable({}, {__call = function(self, arg1, arg2) return HOTKEY.EditHotKey(arg1.name, arg2) end}),
			['EditName'] = setmetatable({}, {__call = function(self, arg1, arg2) return HOTKEY.EditHotKey(arg1.name, arg2) end}),
			['RemoveHotKey'] = setmetatable({}, {__call = function(self, arg) return HOTKEY.RemoveHotKey(arg.name) end}),
			['GetHotKey'] = setmetatable({}, {__call = function(self, arg) return HOTKEY.GetHotKey(arg.name) end}),
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
				
				HOTKEY.List[new_name] = DeepCopy(HOTKEY.List[old_name])
				HOTKEY.List[old_name] = nil
				old_name = new_name
				HOTKEY.List[new_name].name = new_name
				
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
				imgui.AnimButton(u8'Хоткей не найден', sizeButton, button_col)
			end
		end
	}
)

HOTKEY.GetHotKey = setmetatable(
	{},
	{
		__call = function(self, name)
			return HOTKEY.List[name] ~= nil and HOTKEY.List[name].keys
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
	if msg == wm.WM_IME_SETCONTEXT or msg == wm.WM_IME_NOTIFY or lparam == -1073741809 or msg == wm.WM_LBUTTONDOWN then HOTKEY.ActiveKeys = {} end

	local isSpecMouseButton = false
	if msg == wm.WM_MBUTTONDOWN or msg == wm.WM_XBUTTONDOWN then
		key = key_translation[key]
		isSpecMouseButton = true
	end
	if msg == wm.WM_KEYDOWN or msg == wm.WM_SYSKEYDOWN or isSpecMouseButton then
		if HOTKEY.HotKeyIsEdit == nil then
			-- dbg("KEY DOWN:", vk.id_to_name(key), "HOTKEY.ActiveKeys:", encodeJson(HOTKEY.ActiveKeys))
			if key ~= HOTKEY.CancelKey and key ~= HOTKEY.RemoveKey and key ~= vk.VK_VK_ESCAPE and key ~= vk.VK_BACK and not isValueInITable(key, HOTKEY.ActiveKeys) then
				table.insert(HOTKEY.ActiveKeys, key)
				-- dbg("KEY ADD:", vk.id_to_name(key), "HOTKEY.ActiveKeys:", encodeJson(HOTKEY.ActiveKeys))
				if not keyIsSpecial(key) then
					-- table.sort(HOTKEY.ActiveKeys)
					searchHotKey(HOTKEY.ActiveKeys)
					local _, index = isValueInITable(key, HOTKEY.ActiveKeys)
					table.remove(HOTKEY.ActiveKeys, index)
					-- dbg("KEY REMOVE:", vk.id_to_name(key), "HOTKEY.ActiveKeys:", encodeJson(HOTKEY.ActiveKeys))
				end
			end
		else -- EDIT MODE
			if key == HOTKEY.CancelKey then
				HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].keys = HOTKEY.HotKeyIsEdit.BackupHotKeyKeys
				HOTKEY.HotKeyIsEdit = nil
			elseif key == HOTKEY.RemoveKey then
				HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].keys = {}
				HOTKEY.ReturnHotKeys = HOTKEY.HotKeyIsEdit.NameHotKey
				HOTKEY.HotKeyIsEdit = nil
			elseif key ~= vk.VK_ESCAPE and key ~= vk.VK_BACK and not isValueInITable(key, HOTKEY.HotKeyIsEdit.ActiveKeys) then
				if keyIsSpecial(key) then
					if not HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].soloKey then
						table.insert(HOTKEY.HotKeyIsEdit.ActiveKeys, key)
						table.sort(HOTKEY.HotKeyIsEdit.ActiveKeys)
						HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].keys = HOTKEY.HotKeyIsEdit.ActiveKeys
					end
				else
					table.insert(HOTKEY.List[HOTKEY.HotKeyIsEdit.NameHotKey].keys, key)
					HOTKEY.ReturnHotKeys = HOTKEY.HotKeyIsEdit.NameHotKey
					HOTKEY.HotKeyIsEdit = nil
				end
			end

			consumeWindowMessage(true, true)
		end
	elseif msg == wm.WM_KEYUP or msg == wm.WM_SYSKEYUP then
		-- dbg(vk.id_to_name(key), keyIsSpecial(key))
		if keyIsSpecial(key) then
			local current_table = HOTKEY.HotKeyIsEdit ~= nil and HOTKEY.HotKeyIsEdit.ActiveKeys or HOTKEY.ActiveKeys
			-- dbg("current_table:", current_table)
			local result, index = isValueInITable(key, current_table)
			-- dbg("isValueInITable:", result, index)
			if result then
				table.remove(current_table, index)
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

imgui.OnInitialize(function()
	imgui.Loaded = true
end)



return HOTKEY