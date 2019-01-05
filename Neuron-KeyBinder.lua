--Neuron, a World of Warcraft® user interface addon.

--This file is part of Neuron.
--
--Neuron is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--Neuron is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
--
--Copyright for portions of Neuron are held by Connor Chenoweth,
--a.k.a Maul, 2014 as part of his original project, Ion. All other
--copyrights for Neuron are held by Britt Yazel, 2017-2018.

local DEFAULT_VIRTUAL_KEY = "LeftButton"
local NEURON_VIRTUAL_KEY = "Hotkey"

local VIRTUAL_KEY_LIST = {
	DEFAULT_VIRTUAL_KEY,
	NEURON_VIRTUAL_KEY
}

local NeuronBinder = {}
Neuron.NeuronBinder = NeuronBinder



local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")


--- Returns a list of the available spell icon filenames for use in macros
-- @param N/A
-- @return text field of the key modifiers currently being pressed
function NeuronBinder:GetModifier()
	local modifier

	if (IsAltKeyDown()) then
		modifier = "ALT-"
	end

	if (IsControlKeyDown()) then
		if (modifier) then
			modifier = modifier.."CTRL-";
		else
			modifier = "CTRL-";
		end
	end

	if (IsShiftKeyDown()) then
		if (modifier) then
			modifier = modifier.."SHIFT-";
		else
			modifier = "SHIFT-";
		end
	end

	return modifier
end


--- Returns the keybind for a given button
-- @param Button: The button to keybindings to look up
-- @return bindkeys: The current key that is bound to the selected button
function NeuronBinder:GetBindkeyList(button)

	if (not button.data) then return L["None"] end

	local bindkeys = button.keys.hotKeyText:gsub(":", ", ")

	bindkeys = bindkeys:gsub("^, ", "")
	bindkeys = bindkeys:gsub(", $", "")

	if (strlen(bindkeys) < 1) then
		bindkeys = L["None"]
	end

	return bindkeys
end


--- Returns the text value of a keybind
-- @param key: The key to look up
-- @return keytext: The text value for the key
function NeuronBinder:GetKeyText(key)
	local keytext

	if (key:find("Button")) then
		keytext = key:gsub("([Bb][Uu][Tt][Tt][Oo][Nn])(%d+)","m%2")
	elseif (key:find("NUMPAD")) then
		keytext = key:gsub("NUMPAD","n")
		keytext = keytext:gsub("DIVIDE","/")
		keytext = keytext:gsub("MULTIPLY","*")
		keytext = keytext:gsub("MINUS","-")
		keytext = keytext:gsub("PLUS","+")
		keytext = keytext:gsub("DECIMAL",".")
	elseif (key:find("MOUSEWHEEL")) then
		keytext = key:gsub("MOUSEWHEEL","mw")
		keytext = keytext:gsub("UP","U")
		keytext = keytext:gsub("DOWN","D")
	else
		keytext = key
	end

	keytext = keytext:gsub("ALT%-","a")
	keytext = keytext:gsub("CTRL%-","c")
	keytext = keytext:gsub("SHIFT%-","s")
	keytext = keytext:gsub("INSERT","Ins")
	keytext = keytext:gsub("DELETE","Del")
	keytext = keytext:gsub("HOME","Home")
	keytext = keytext:gsub("END","End")
	keytext = keytext:gsub("PAGEUP","PgUp")
	keytext = keytext:gsub("PAGEDOWN","PgDn")
	keytext = keytext:gsub("BACKSPACE","Bksp")
	keytext = keytext:gsub("SPACE","Spc")

	return keytext
end


--- Clears the bindings of a given button
-- @param button: The button to clear
-- @param key: ?
function NeuronBinder:ClearBindings(button, key)
	if (key) then
		SetOverrideBinding(button, true, key, nil)

		local newkey = key:gsub("%-", "%%-")
		button.keys.hotKeys = button.keys.hotKeys:gsub(newkey..":", "")

		local keytext = NeuronBinder:GetKeyText(key)
		button.keys.hotKeyText = button.keys.hotKeyText:gsub(keytext..":", "")
	else
		local bindCmdPrefix = "CLICK " .. button:GetName()

		---clear bindings for all virtual keys (LeftButton, Hotkey, ...)
		---using the bindCmdPrefix and concatenating it with each virtual key
		for _, virtualKey in ipairs(VIRTUAL_KEY_LIST) do
			local bindCmd = bindCmdPrefix .. ":" .. virtualKey

			while (GetBindingKey(bindCmd)) do
				SetBinding(GetBindingKey(bindCmd), nil)
			end
		end

		ClearOverrideBindings(button)
		button.keys.hotKeys = ":"
		button.keys.hotKeyText = ":"
	end

	NeuronBinder:ApplyBindings(button)
end


--- Sets a keybinding to a button
-- @param button: The button to set keybinding for
-- @param key: The key to be used
function NeuronBinder:SetNeuronBinding(button, key)
	local found

	gsub(button.keys.hotKeys, "[^:]+", function(binding) if(binding == key) then found = true end end)

	if (not found) then
		local keytext = NeuronBinder:GetKeyText(key)

		button.keys.hotKeys = button.keys.hotKeys..key..":"
		button.keys.hotKeyText = button.keys.hotKeyText..keytext..":"
	end

	NeuronBinder:ApplyBindings(button)
end


--- Applys binding to button
-- @param button: The button to apply settings go
function NeuronBinder:ApplyBindings(button)
	button:SetAttribute("hotkeypri", button.keys.hotKeyPri)

	---TODO: Fix this better
	------weird fix during the database migration with these values not getting assigned
	if not button.keys.hotKeys then
		button.keys.hotKeys = ":"
	end

	if not button.keys.hotKeyText then
		button.keys.hotKeyText = ":"
	end
	------------------------------

	local virtualKey

	---checks if the button is a Neuron action or a special Blizzard action (such as a zone ability)
	---this is necessary because Blizzard buttons usually won't work and can give very weird results
	---if clicked with a virtual key other than the default "LeftButton"
	if (button:GetName():find("NeuronActionBar%d+")) then
		virtualKey = NEURON_VIRTUAL_KEY
	else
		virtualKey = DEFAULT_VIRTUAL_KEY
	end

	if (button:IsVisible() or button:GetParent():GetAttribute("concealed")) then
		gsub(button.keys.hotKeys, "[^:]+", function(key) SetOverrideBindingClick(button, button.keys.hotKeyPri, key, button:GetName(), virtualKey) end)
	end

	button:SetAttribute("hotkeys", button.keys.hotKeys)

	button.hotkey:SetText(button.keys.hotKeyText:match("^:([^:]+)") or "")

	if (button.bindText) then
		button.hotkey:Show()
	else
		button.hotkey:Hide()
	end

	if (GetCurrentBindingSet() > 0 and GetCurrentBindingSet() < 3) then SaveBindings(GetCurrentBindingSet()) end
end


--- Processes the change to a key bind  (i think)
-- @param button: The button to set keybinding for
-- @param key: The key to be used
function NeuronBinder:ProcessBinding(binder, key, button)
	if (button and button.keys and button.keys.hotKeyLock) then
		UIErrorsFrame:AddMessage(L["Bindings_Locked_Notice"], 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME)
		return
	end

	if (key == "ESCAPE") then
		NeuronBinder:ClearBindings(button)
	elseif (key) then
		for _,binder in pairs(Neuron.BINDIndex) do
			if (button ~= binder.button and binder.button.keys and not binder.button.keys.hotKeyLock) then
				binder.button.keys.hotKeys:gsub("[^:]+", function(binding) if (key == binding) then NeuronBinder:ClearBindings(binder.button, binding) NeuronBinder:ApplyBindings(binder.button) end end)
			end
		end

		NeuronBinder:SetNeuronBinding(button, key)
	end

	if (binder:IsVisible()) then
		NeuronBinder:OnEnter(binder)
	end

end


--- OnShow Event handler
function NeuronBinder:OnShow(binder)
	local button = binder.button

	if (button) then

		if (button.bar) then
			binder:SetFrameLevel(button.bar:GetFrameLevel()+1)
		end

		local priority = ""

		if (button.keys.hotKeyPri) then
			priority = "|cff00ff00"..L["Priority"].."|r\n"
		end

		if (button.keys.hotKeyLock) then
			binder.type:SetText(priority.."|cfff00000"..L["Locked"].."|r")
		else
			binder.type:SetText(priority.."|cffffffff"..L["Bind"].."|r")
		end
	end
end


--- OnHide Event handler
function NeuronBinder:OnHide(binder)
end


--- OnEnter Event handler
function NeuronBinder:OnEnter(binder)

	local button = binder.button

	local name = binder.bindType:gsub("^%l", string.upper).. " " .. button.id --default to "button #" in the case that a button is empty

	---TODO:we should definitely added name strings for pets/companions as well. This was just to get it going
	if binder.button.spellID then
		name = GetSpellInfo(binder.button.spellID)
	elseif binder.button.actionSpell then
		name = binder.button.actionSpell
	elseif binder.button.macroitem then
		name = binder.button.macroitem
	elseif binder.button.macrospell then
		name = binder.button.macrospell --this is kind of a catch-all
	end

	if not name then
		name = "Button"
	end

	binder.select:Show()

	GameTooltip:SetOwner(binder, "ANCHOR_RIGHT")

	GameTooltip:ClearLines()
	GameTooltip:SetText("Neuron", 1.0, 1.0, 1.0)
	GameTooltip:AddLine(L["Keybind_Tooltip_1"] .. ": |cffffffff" .. name  .. "|r")
	GameTooltip:AddLine(L["Keybind_Tooltip_2"] .. ": |cffffffff" .. NeuronBinder:GetBindkeyList(button) .. "|r")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["Keybind_Tooltip_3"])
	GameTooltip:AddLine(L["Keybind_Tooltip_4"])
	GameTooltip:AddLine(L["Keybind_Tooltip_5"])

	GameTooltip:Show()
end


--- OnLeave Event handler
function NeuronBinder:OnLeave(binder)
	binder.select:Hide()
	GameTooltip:Hide()
end


--- OnUpdate Event handler
function NeuronBinder:OnUpdate(binder)
	if(Neuron.enteredWorld) then
		if (binder:IsMouseOver()) then
			binder:EnableKeyboard(true)
		else
			binder:EnableKeyboard(false)
		end
	end
end


--- OnClick Event handler
-- @param button: The button that was clicked
function NeuronBinder:OnClick(binder, buttonpressed)

	if (buttonpressed == "LeftButton") then

		if (binder.button.keys.hotKeyLock) then
			binder.button.keys.hotKeyLock = false
		else
			binder.button.keys.hotKeyLock = true
		end

		NeuronBinder:OnShow(binder)

		return
	end

	if (buttonpressed == "RightButton") then
		if (binder.button.keys.hotKeyPri) then
			binder.button.keys.hotKeyPri = false
		else
			binder.button.keys.hotKeyPri = true
		end

		NeuronBinder:ApplyBindings(binder.button)

		NeuronBinder:OnShow(binder)

		return
	end

	local modifier, key = NeuronBinder:GetModifier()

	if (buttonpressed == "MiddleButton") then
		key = "Button3"
	else
		key = buttonpressed
	end

	if (modifier) then
		key = modifier..key
	end

	NeuronBinder:ProcessBinding(binder, key, binder.button)
end


--- OnKeyDown Event handler
-- @param key: The key that was pressed
function NeuronBinder:OnKeyDown(binder, key)
	if (key:find("ALT") or key:find("SHIFT") or key:find("CTRL") or key:find("PRINTSCREEN")) then
		return
	end

	local modifier = NeuronBinder:GetModifier()

	if (modifier) then
		key = modifier..key
	end

	NeuronBinder:ProcessBinding(binder, key, binder.button)
end


--- OnMouseWheel Event handler
-- @param delta: direction mouse wheel moved
function NeuronBinder:OnMouseWheel(binder, delta)
	local modifier, key, action = NeuronBinder:GetModifier()

	if (delta > 0) then
		key = "MOUSEWHEELUP"
		action = "MousewheelUp"
	else
		key = "MOUSEWHEELDOWN"
		action = "MousewheelDown"
	end

	if (modifier) then
		key = modifier..key
	end

	NeuronBinder:ProcessBinding(binder, key, binder.button)
end

function NeuronBinder:CreateBindFrame(button)
	local binder = CreateFrame("Button", button:GetName().."BindFrame", button, "NeuronBindFrameTemplate")

	setmetatable(binder, { __index = CreateFrame("Button") })

	binder:EnableMouseWheel(true)
	binder:RegisterForClicks("AnyDown")
	binder:SetAllPoints(button)
	binder:SetScript("OnShow", function(self) NeuronBinder:OnShow(self) end)
	binder:SetScript("OnHide", function(self) NeuronBinder:OnHide(self) end)
	binder:SetScript("OnEnter", function(self) NeuronBinder:OnEnter(self) end)
	binder:SetScript("OnLeave", function(self) NeuronBinder:OnLeave(self) end)
	binder:SetScript("OnClick", function(self, button) NeuronBinder:OnClick(self, button) end)
	binder:SetScript("OnKeyDown", function(self, key) NeuronBinder:OnKeyDown(self, key) end)
	binder:SetScript("OnMouseWheel", function(self, delta) NeuronBinder:OnMouseWheel(self, delta) end)
	binder:SetScript("OnUpdate", function(self) NeuronBinder:OnUpdate(self) end)

	binder.type:SetText(L["Bind"])
	binder.button = button
	binder.bindType = "button"

	button.binder = binder
	button:SetAttribute("hotkeypri", button.keys.hotKeyPri)
	button:SetAttribute("hotkeys", button.keys.hotKeys)

	Neuron.BINDIndex[button.class..button.bar.DB.id.."_"..button.id] = binder

	binder:Hide()
end
