-- Options.lua - Ace3 Configuration following SorhaQuestLog pattern

-- Function to show new profile dialog using AceGUI
function zBarButtonBGAce:ShowNewProfileDialog()
	local AceGUI = LibStub("AceGUI-3.0")

	-- Create the frame
	local frame = AceGUI:Create("Frame")
	frame:SetTitle("Create New Profile")
	frame:SetStatusText("Enter a name for the new profile")
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	frame:SetLayout("Flow")
	frame:SetWidth(350)
	frame:SetHeight(150)

	-- Create the editbox
	local editbox = AceGUI:Create("EditBox")
	editbox:SetLabel("Profile Name:")
	editbox:SetWidth(250)
	editbox:SetCallback("OnEnterPressed", function(widget)
		local profileName = widget:GetText()
		if profileName and profileName ~= "" then
			local success, message = self:CreateNewProfile(profileName)
			if success then
				zBarButtonBG.print("Profile '" .. profileName .. "' created and activated!")
				-- Refresh the config to update dropdowns
				LibStub("AceConfigRegistry-3.0"):NotifyChange("zBarButtonBG")
				frame:Hide()
			else
				zBarButtonBG.print("|cFFFF0000Error:|r " .. message)
			end
		end
	end)
	frame:AddChild(editbox)

	-- Create buttons group
	local buttonGroup = AceGUI:Create("SimpleGroup")
	buttonGroup:SetLayout("Flow")
	buttonGroup:SetWidth(250)
	frame:AddChild(buttonGroup)

	-- Create button
	local createButton = AceGUI:Create("Button")
	createButton:SetText("Create")
	createButton:SetWidth(80)
	createButton:SetCallback("OnClick", function()
		local profileName = editbox:GetText()
		if profileName and profileName ~= "" then
			local success, message = self:CreateNewProfile(profileName)
			if success then
				zBarButtonBG.print("Profile '" .. profileName .. "' created and activated!")
				-- Refresh the config to update dropdowns
				LibStub("AceConfigRegistry-3.0"):NotifyChange("zBarButtonBG")
				frame:Hide()
			else
				zBarButtonBG.print("|cFFFF0000Error:|r " .. message)
			end
		end
	end)
	buttonGroup:AddChild(createButton)

	-- Cancel button
	local cancelButton = AceGUI:Create("Button")
	cancelButton:SetText("Cancel")
	cancelButton:SetWidth(80)
	cancelButton:SetCallback("OnClick", function()
		frame:Hide()
	end)
	buttonGroup:AddChild(cancelButton)

	-- Focus the editbox
	editbox:SetFocus()
end

function zBarButtonBGAce:GetOptionsTable()
	local options = {
		type = "group",
		name = "zBarButtonBG",
		args = {
			general = {
				order = 1,
				type = "group",
				name = "General",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "General Settings",
					},
					enabled = {
						order = 2,
						type = "toggle",
						name = "Enable Skinning",
						desc =
						"Toggle action bar skinning on/off. Note: /reload may be required when disabling to restore default borders.",
						get = function() return self.db.profile.enabled end,
						set = function(_, value)
							self.db.profile.enabled = value
							-- Update native system
							zBarButtonBG.charSettings.enabled = value
							if value and not zBarButtonBG.enabled then
								zBarButtonBG.enabled = true
								zBarButtonBG.createActionBarBackgrounds()
								zBarButtonBG.print("Action bar backgrounds |cFF00FF00enabled|r")
							elseif not value and zBarButtonBG.enabled then
								zBarButtonBG.enabled = false
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.print("Action bar backgrounds |cFFFF0000disabled|r")
							end
						end,
					},
					resetButton = {
						order = 3,
						type = "execute",
						name = "Reset to Default",
						desc = "Reset the currently selected profile to default values",
						func = function()
							-- Reset current profile to defaults
							self.db:ResetProfile()
							zBarButtonBG.charSettings = self.db.profile
							-- Trigger rebuild
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
							zBarButtonBG.print("Current profile reset to defaults!")
						end,
					},
					spacer1 = {
						order = 4,
						type = "description",
						name = " ",
					},
					profilesHeader = {
						order = 5,
						type = "header",
						name = "Profiles",
					},
					selectedProfile = {
						order = 6,
						type = "select",
						name = "Active Profile",
						desc = "Choose the active profile. Changing this will switch to that profile's settings.",
						values = function()
							local profiles = {}
							for name, _ in pairs(self.db.profiles) do
								profiles[name] = name
							end
							return profiles
						end,
						get = function()
							return self.db:GetCurrentProfile()
						end,
						set = function(_, value)
							-- Switch to the selected profile
							self.db:SetProfile(value)
							zBarButtonBG.charSettings = self.db.profile
							-- Rebuild action bars with new settings
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
							zBarButtonBG.print("Switched to profile: |cFF00FF00" .. value .. "|r")
						end,
					},
					createProfile = {
						order = 7,
						type = "execute",
						name = "New Profile",
						desc = "Create a new profile with default settings",
						func = function()
							self:ShowNewProfileDialog()
						end,
					},
					spacer2 = {
						order = 9,
						type = "description",
						name = " ",
					},
					spacer3 = {
						order = 10,
						type = "description",
						name = "Modify Profiles",
					},
					chooseProfile = {
						order = 11,
						type = "select",
						name = "Choose Profile",
						desc = "Select a profile for copy/delete operations",
						values = function()
							local profiles = {}
							for name, _ in pairs(self.db.profiles) do
								if name ~= self.db:GetCurrentProfile() then
									profiles[name] = name
								end
							end
							return profiles
						end,
						get = function() return self.selectedProfileForActions end,
						set = function(_, value) self.selectedProfileForActions = value end,
					},
					copyProfile = {
						order = 13,
						type = "execute",
						name = "Copy Profile",
						desc = "Copy settings from the chosen profile to the current profile",
						disabled = function() return not self.selectedProfileForActions end,
						confirm = function()
							return "Copy settings from '" ..
							(self.selectedProfileForActions or "") ..
							"' to '" .. self.db:GetCurrentProfile() .. "'?\n\nThis will overwrite all current settings!"
						end,
						func = function()
							local success, message = self:CopyProfile(self.selectedProfileForActions,
								self.db:GetCurrentProfile())
							if success then
								zBarButtonBG.print("Settings copied from '" ..
								self.selectedProfileForActions .. "' to '" .. self.db:GetCurrentProfile() .. "'!")
								-- Rebuild action bars with updated settings
								if zBarButtonBG.enabled then
									zBarButtonBG.removeActionBarBackgrounds()
									zBarButtonBG.createActionBarBackgrounds()
								end
							else
								zBarButtonBG.print("|cFFFF0000Error:|r " .. message)
							end
						end,
					},
					deleteProfile = {
						order = 14,
						type = "execute",
						name = "Delete Profile",
						desc = "Delete the chosen profile",
						disabled = function()
							return not self.selectedProfileForActions or self.selectedProfileForActions == "Default"
						end,
						confirm = function()
							return "Are you sure you want to delete the profile '" ..
							(self.selectedProfileForActions or "") .. "'?\n\nThis action cannot be undone!"
						end,
						func = function()
							local profileToDelete = self.selectedProfileForActions
							local success, message = self:DeleteProfile(profileToDelete)
							if success then
								zBarButtonBG.print("Profile '" .. profileToDelete .. "' deleted!")
								self.selectedProfileForActions = nil
							else
								zBarButtonBG.print("|cFFFF0000Error:|r " .. message)
							end
						end,
					},
					spacer4 = {
						order = 13,
						type = "description",
						name = " ",
					},
				},
			},
			buttonSettings = {
				order = 2,
				type = "group",
				name = "Button Settings",
				args = {
					squareButtons = {
						order = 1,
						type = "toggle",
						name = "Square Buttons",
						desc = "Make action buttons square instead of rounded",
						get = function() return self.db.profile.squareButtons end,
						set = function(_, value)
							self.db.profile.squareButtons = value
							zBarButtonBG.charSettings.squareButtons = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					spacer1 = {
						order = 2,
						type = "description",
						name = " ",
					},
					header = {
						order = 3,
						type = "header",
						name = "Button Background Settings",
					},
					showBackdrop = {
						order = 4,
						type = "toggle",
						name = "Show Backdrop",
						desc = "Show the outer backdrop frame behind each button",
						get = function() return self.db.profile.showBackdrop end,
						set = function(_, value)
							self.db.profile.showBackdrop = value
							zBarButtonBG.charSettings.showBackdrop = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					spacer2 = {
						order = 5,
						type = "description",
						name = " ",
					},
					outerColor = {
						order = 6,
						type = "color",
						name = "Backdrop Color",
						desc = "Color of the outer backdrop frame",
						disabled = function() return not self.db.profile.showBackdrop or
							self.db.profile.useClassColorOuter end,
						hasAlpha = true,
						get = function()
							local c = self.db.profile.outerColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.outerColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.outerColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					useClassColorOuter = {
						order = 7,
						type = "toggle",
						name = "Use Class Color for Backdrop",
						desc = "Use your class color for the outer backdrop",
						disabled = function() return not self.db.profile.showBackdrop end,
						get = function() return self.db.profile.useClassColorOuter end,
						set = function(_, value)
							self.db.profile.useClassColorOuter = value
							zBarButtonBG.charSettings.useClassColorOuter = value
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					spacer3 = {
						order = 8,
						type = "description",
						name = " ",
					},
					showSlotBackground = {
						order = 9,
						type = "toggle",
						name = "Show Slot Background",
						desc = "Show the slot background fill behind each button icon",
						get = function() return self.db.profile.showSlotBackground end,
						set = function(_, value)
							self.db.profile.showSlotBackground = value
							zBarButtonBG.charSettings.showSlotBackground = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					spacer4 = {
						order = 10,
						type = "description",
						name = " ",
					},
					innerColor = {
						order = 11,
						type = "color",
						name = "Button Background Color",
						desc = "Color of the button slot background",
						disabled = function() return not self.db.profile.showSlotBackground or
							self.db.profile.useClassColorInner end,
						hasAlpha = true,
						get = function()
							local c = self.db.profile.innerColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.innerColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.innerColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					useClassColorInner = {
						order = 12,
						type = "toggle",
						name = "Use Class Color for Button Background",
						desc = "Use your class color for the button background",
						disabled = function() return not self.db.profile.showSlotBackground end,
						get = function() return self.db.profile.useClassColorInner end,
						set = function(_, value)
							self.db.profile.useClassColorInner = value
							zBarButtonBG.charSettings.useClassColorInner = value
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					spacer5 = {
						order = 13,
						type = "description",
						name = " ",
					},
					showBorder = {
						order = 14,
						type = "toggle",
						name = "Enable Button Border",
						desc = "Add a border around each action button icon",
						get = function() return self.db.profile.showBorder end,
						set = function(_, value)
							self.db.profile.showBorder = value
							zBarButtonBG.charSettings.showBorder = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					spacer6 = {
						order = 15,
						type = "description",
						name = " ",
					},
					borderColor = {
						order = 16,
						type = "color",
						name = "Button Border Color",
						desc = "Color of the button icon border",
						disabled = function() return not self.db.profile.showBorder or
							self.db.profile.useClassColorBorder end,
						hasAlpha = true,
						get = function()
							local c = self.db.profile.borderColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.borderColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.borderColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					useClassColorBorder = {
						order = 17,
						type = "toggle",
						name = "Use Class Color for Button Border",
						desc = "Use your class color for the icon border",
						disabled = function() return not self.db.profile.showBorder end,
						get = function() return self.db.profile.useClassColorBorder end,
						set = function(_, value)
							self.db.profile.useClassColorBorder = value
							zBarButtonBG.charSettings.useClassColorBorder = value
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
				},
			},
			indicators = {
				order = 3,
				type = "group",
				name = "Indicators",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Visual Indicators",
					},
					showRangeIndicator = {
						order = 2,
						type = "toggle",
						name = "Show Out-of-Range Highlight",
						desc = "Show a colored overlay on buttons when the ability is out of range",
						get = function() return self.db.profile.showRangeIndicator end,
						set = function(_, value)
							self.db.profile.showRangeIndicator = value
							zBarButtonBG.charSettings.showRangeIndicator = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					rangeIndicatorColor = {
						order = 3,
						type = "color",
						name = "Range Indicator Color",
						desc = "Color of the out-of-range overlay",
						disabled = function() return not self.db.profile.showRangeIndicator end,
						hasAlpha = true,
						get = function()
							local c = self.db.profile.rangeIndicatorColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.rangeIndicatorColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.rangeIndicatorColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					spacer1 = {
						order = 4,
						type = "description",
						name = " ",
					},
					fadeCooldown = {
						order = 5,
						type = "toggle",
						name = "Fade On Cooldown",
						desc = "Add a dark overlay to buttons while on cooldown",
						get = function() return self.db.profile.fadeCooldown end,
						set = function(_, value)
							self.db.profile.fadeCooldown = value
							zBarButtonBG.charSettings.fadeCooldown = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					cooldownColor = {
						order = 6,
						type = "color",
						name = "Cooldown Overlay Color",
						desc = "Color of the cooldown overlay",
						disabled = function() return not self.db.profile.fadeCooldown end,
						hasAlpha = true,
						get = function()
							local c = self.db.profile.cooldownColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.cooldownColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.cooldownColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
				},
			},
			textSettings = {
				order = 4,
				type = "group",
				name = "Text Settings",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Font and Text Configuration",
					},
					macroNameHeader = {
						order = 2,
						type = "header",
						name = "Macro Name Font",
					},
					macroNameFont = {
						order = 3,
						type = "select",
						name = "Macro Name Font",
						desc = "Font family for macro names",
						dialogControl = 'LSM30_Font',
						values = AceGUIWidgetLSMlists.font,
						get = function() return self.db.profile.macroNameFont end,
						set = function(_, value)
							self.db.profile.macroNameFont = value
							zBarButtonBG.charSettings.macroNameFont = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameFontFlags = {
						order = 4,
						type = "select",
						name = "Macro Name Font Style",
						desc = "Font style flags for macro names",
						values = {
							[""] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome",
						},
						get = function() return self.db.profile.macroNameFontFlags end,
						set = function(_, value)
							self.db.profile.macroNameFontFlags = value
							zBarButtonBG.charSettings.macroNameFontFlags = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameFontSize = {
						order = 5,
						type = "range",
						name = "Macro Name Font Size",
						desc = "Size of the macro name text",
						min = 6,
						max = 24,
						step = 1,
						get = function() return self.db.profile.macroNameFontSize end,
						set = function(_, value)
							self.db.profile.macroNameFontSize = value
							zBarButtonBG.charSettings.macroNameFontSize = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameColor = {
						order = 6,
						type = "color",
						name = "Macro Name Color",
						desc = "Color of the macro name text",
						hasAlpha = true,
						get = function()
							local c = self.db.profile.macroNameColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.macroNameColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.macroNameColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameWidth = {
						order = 7,
						type = "range",
						name = "Macro Name Width",
						desc = "Width of the macro name text frame",
						min = 20,
						max = 200,
						step = 1,
						get = function() return self.db.profile.macroNameWidth end,
						set = function(_, value)
							self.db.profile.macroNameWidth = value
							zBarButtonBG.charSettings.macroNameWidth = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameHeight = {
						order = 8,
						type = "range",
						name = "Macro Name Height",
						desc = "Height of the macro name text frame",
						min = 8,
						max = 50,
						step = 1,
						get = function() return self.db.profile.macroNameHeight end,
						set = function(_, value)
							self.db.profile.macroNameHeight = value
							zBarButtonBG.charSettings.macroNameHeight = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameOffsetX = {
						order = 9,
						type = "range",
						name = "Macro Name X Offset",
						desc = "Horizontal positioning offset for macro name text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.macroNameOffsetX end,
						set = function(_, value)
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.macroNameOffsetX = value
							zBarButtonBG.charSettings.macroNameOffsetX = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
					macroNameOffsetY = {
						order = 10,
						type = "range",
						name = "Macro Name Y Offset",
						desc = "Vertical positioning offset for macro name text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.macroNameOffsetY end,
						set = function(_, value)
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.macroNameOffsetY = value
							zBarButtonBG.charSettings.macroNameOffsetY = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
					spacer1 = {
						order = 11,
						type = "description",
						name = " ",
					},
					countHeader = {
						order = 12,
						type = "header",
						name = "Count/Charge Font",
					},
					countFont = {
						order = 13,
						type = "select",
						name = "Count Font",
						desc = "Font family for count/charge numbers",
						dialogControl = 'LSM30_Font',
						values = AceGUIWidgetLSMlists.font,
						get = function() return self.db.profile.countFont end,
						set = function(_, value)
							self.db.profile.countFont = value
							zBarButtonBG.charSettings.countFont = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countFontFlags = {
						order = 14,
						type = "select",
						name = "Count Font Style",
						desc = "Font style flags for count/charge numbers",
						values = {
							[""] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome",
						},
						get = function() return self.db.profile.countFontFlags end,
						set = function(_, value)
							self.db.profile.countFontFlags = value
							zBarButtonBG.charSettings.countFontFlags = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countFontSize = {
						order = 15,
						type = "range",
						name = "Count Font Size",
						desc = "Size of the count/charge text",
						min = 6,
						max = 24,
						step = 1,
						get = function() return self.db.profile.countFontSize end,
						set = function(_, value)
							self.db.profile.countFontSize = value
							zBarButtonBG.charSettings.countFontSize = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countColor = {
						order = 16,
						type = "color",
						name = "Count Color",
						desc = "Color of the count/charge text",
						hasAlpha = true,
						get = function()
							local c = self.db.profile.countColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.countColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.countColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countWidth = {
						order = 17,
						type = "range",
						name = "Count Width",
						desc = "Width of the count text frame",
						min = 10,
						max = 100,
						step = 1,
						get = function() return self.db.profile.countWidth end,
						set = function(_, value)
							self.db.profile.countWidth = value
							zBarButtonBG.charSettings.countWidth = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countHeight = {
						order = 18,
						type = "range",
						name = "Count Height",
						desc = "Height of the count text frame",
						min = 8,
						max = 50,
						step = 1,
						get = function() return self.db.profile.countHeight end,
						set = function(_, value)
							self.db.profile.countHeight = value
							zBarButtonBG.charSettings.countHeight = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countOffsetX = {
						order = 19,
						type = "range",
						name = "Count X Offset",
						desc = "Horizontal positioning offset for count/charge text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.countOffsetX end,
						set = function(_, value)
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.countOffsetX = value
							zBarButtonBG.charSettings.countOffsetX = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
					countOffsetY = {
						order = 20,
						type = "range",
						name = "Count Y Offset",
						desc = "Vertical positioning offset for count/charge text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.countOffsetY end,
						set = function(_, value)
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.countOffsetY = value
							zBarButtonBG.charSettings.countOffsetY = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
					spacer4 = {
						order = 21,
						type = "description",
						name = " ",
					},
					keybindHeader = {
						order = 22,
						type = "header",
						name = "Keybind/Hotkey Font",
					},
					keybindFont = {
						order = 23,
						type = "select",
						name = "Keybind Font",
						desc = "Font family for keybind/hotkey text",
						dialogControl = 'LSM30_Font',
						values = AceGUIWidgetLSMlists.font,
						get = function() return self.db.profile.keybindFont end,
						set = function(_, value)
							self.db.profile.keybindFont = value
							zBarButtonBG.charSettings.keybindFont = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					keybindFontFlags = {
						order = 24,
						type = "select",
						name = "Keybind Font Style",
						desc = "Font style flags for keybind/hotkey text",
						values = {
							[""] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome",
						},
						get = function() return self.db.profile.keybindFontFlags end,
						set = function(_, value)
							self.db.profile.keybindFontFlags = value
							zBarButtonBG.charSettings.keybindFontFlags = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					keybindFontSize = {
						order = 25,
						type = "range",
						name = "Keybind Font Size",
						desc = "Size of the keybind/hotkey text",
						min = 6,
						max = 24,
						step = 1,
						get = function() return self.db.profile.keybindFontSize end,
						set = function(_, value)
							self.db.profile.keybindFontSize = value
							zBarButtonBG.charSettings.keybindFontSize = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					keybindColor = {
						order = 26,
						type = "color",
						name = "Keybind Text Color",
						desc = "Color of the keybind/hotkey text",
						hasAlpha = true,
						get = function()
							local c = self.db.profile.keybindColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.keybindColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.keybindColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					keybindWidth = {
						order = 27,
						type = "range",
						name = "Keybind Width",
						desc = "Width of the keybind text frame",
						min = 10,
						max = 100,
						step = 1,
						get = function() return self.db.profile.keybindWidth end,
						set = function(_, value)
							self.db.profile.keybindWidth = value
							zBarButtonBG.charSettings.keybindWidth = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					keybindHeight = {
						order = 28,
						type = "range",
						name = "Keybind Height",
						desc = "Height of the keybind text frame",
						min = 8,
						max = 50,
						step = 1,
						get = function() return self.db.profile.keybindHeight end,
						set = function(_, value)
							self.db.profile.keybindHeight = value
							zBarButtonBG.charSettings.keybindHeight = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					keybindOffsetX = {
						order = 29,
						type = "range",
						name = "Keybind X Offset",
						desc = "Horizontal positioning offset for keybind/hotkey text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.keybindOffsetX end,
						set = function(_, value)
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.keybindOffsetX = value
							zBarButtonBG.charSettings.keybindOffsetX = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
					keybindOffsetY = {
						order = 30,
						type = "range",
						name = "Keybind Y Offset",
						desc = "Vertical positioning offset for keybind/hotkey text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.keybindOffsetY end,
						set = function(_, value)
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.keybindOffsetY = value
							zBarButtonBG.charSettings.keybindOffsetY = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
				},
			},
		},
	}

	return options
end
