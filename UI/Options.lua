-- Options.lua - Ace3 Configuration following SorhaQuestLog pattern

-- Get localization table
local L = LibStub("AceLocale-3.0"):GetLocale("zBarButtonBG")

-- Register custom fonts with LibSharedMedia
local LSM = LibStub("LibSharedMedia-3.0")
if LSM then
	-- Register default WoW fonts if not already registered (ensures dropdown works)
	if not LSM:IsValid("font", "Friz Quadrata TT") then
		LSM:Register("font", "Friz Quadrata TT", [[Fonts\FRIZQT__.TTF]])
	end
	if not LSM:IsValid("font", "Arial Narrow") then
		LSM:Register("font", "Arial Narrow", [[Fonts\ARIALN.TTF]])
	end
	if not LSM:IsValid("font", "Skurri") then
		LSM:Register("font", "Skurri", [[Fonts\skurri.ttf]])
	end

	-- Register custom addon fonts from Assets folder
	if not LSM:IsValid("font", "Champagne & Limousines Bold") then
		LSM:Register("font", "Champagne & Limousines Bold",
			[[Interface\AddOns\zBarButtonBG\Assets\Champagne & Limousines Bold.ttf]])
	end
	if not LSM:IsValid("font", "HOOGE") then
		LSM:Register("font", "HOOGE", [[Interface\AddOns\zBarButtonBG\Assets\HOOGE.TTF]])
	end
	if not LSM:IsValid("font", "OpenSans Condensed Bold") then
		LSM:Register("font", "OpenSans Condensed Bold", [[Interface\AddOns\zBarButtonBG\Assets\OpenSans-CondBold.ttf]])
	end
	if not LSM:IsValid("font", "OpenSans Condensed Light") then
		LSM:Register("font", "OpenSans Condensed Light", [[Interface\AddOns\zBarButtonBG\Assets\OpenSans-CondLight.ttf]])
	end
	if not LSM:IsValid("font", "OpenSans Condensed Light Italic") then
		LSM:Register("font", "OpenSans Condensed Light Italic",
			[[Interface\AddOns\zBarButtonBG\Assets\OpenSans-CondLightItalic.ttf]])
	end
	if not LSM:IsValid("font", "Vintage One") then
		LSM:Register("font", "Vintage One", [[Interface\AddOns\zBarButtonBG\Assets\VintageOne.ttf]])
	end
	if not LSM:IsValid("font", "Homespun") then
		LSM:Register("font", "Homespun", [[Interface\AddOns\zBarButtonBG\Assets\homespun.ttf]])
	end
end

-- Export/Import helper functions for settings
local function getDefaultProfile()
	-- Reference the default profile structure from the main addon (zBarButtonBG.lua)
	return zBarButtonBGAce.db.defaults.profile
end

local function exportProfile(profile)
	-- Serialize profile using AceSerializer
	local serialized = LibStub("AceSerializer-3.0"):Serialize(profile)

	-- Compress using LibDeflate
	local LibDeflate = LibStub:GetLibrary("LibDeflate")
	if not LibDeflate then
		-- Try direct global access
		LibDeflate = _G.LibDeflate
	end

	if LibDeflate then
		local compressed = LibDeflate:CompressDeflate(serialized)
		if compressed then
			local encoded = LibDeflate:EncodeForPrint(compressed)
			if encoded then
				return encoded
			end
		end
	end

	-- Fallback if LibDeflate not available or compression fails
	return serialized
end

local function importProfile(exportString)
	-- Validate that we have something
	if not exportString or exportString == "" then
		return nil, L["Invalid export string format"]
	end

	-- Trim whitespace from start and end
	exportString = exportString:gsub("^%s+", ""):gsub("%s+$", "")

	-- Try to decompress first (most recent format)
	local LibDeflate = LibStub:GetLibrary("LibDeflate")
	local decompressed = nil

	if LibDeflate then
		local decoded = LibDeflate:DecodeForPrint(exportString)
		if decoded then
			decompressed = LibDeflate:DecompressDeflate(decoded)
		end
	end

	-- If decompression failed, try raw deserialization (fallback for uncompressed exports)
	local dataToDeserialize = decompressed or exportString

	-- Decode using AceSerializer
	local success, profile = LibStub("AceSerializer-3.0"):Deserialize(dataToDeserialize)
	if not success then
		return nil, L["Failed to decode export string"]
	end

	-- Validate that it has the expected settings
	local defaults = getDefaultProfile()
	if not profile or type(profile) ~= "table" then
		return nil, L["Invalid export string - not a valid profile"]
	end

	-- Merge with defaults, ensuring all required keys exist
	local validatedProfile = {}
	for key, defaultValue in pairs(defaults) do
		if profile[key] ~= nil then
			validatedProfile[key] = profile[key]
		else
			validatedProfile[key] = defaultValue
		end
	end

	return validatedProfile
end

-- Order number helper function for dynamic ordering
local orderCounter = 0
local function nextOrderNumber()
	orderCounter = orderCounter + 1
	return orderCounter
end

-- Reset order counter (useful for different sections)
local function resetOrderCounter()
	orderCounter = 0
end

-- Function to show new profile dialog using AceGUI
function zBarButtonBGAce:ShowNewProfileDialog()
	local AceGUI = LibStub("AceGUI-3.0")

	-- Create the frame
	local frame = AceGUI:Create("Frame")
	frame:SetTitle(L["Create New Profile"])
	frame:SetStatusText(L["Enter a name for the new profile"])
	frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
	frame:SetLayout("Flow")
	frame:SetWidth(350)
	frame:SetHeight(150)

	-- Create the editbox
	local editbox = AceGUI:Create("EditBox")
	editbox:SetLabel(L["Profile Name:"])
	editbox:SetWidth(250)
	editbox:SetCallback("OnEnterPressed", function(widget)
		local profileName = widget:GetText()
		if profileName and profileName ~= "" then
			local success, message = self:CreateNewProfile(profileName)
			if success then
				zBarButtonBG.print(L["Profile created: "] .. profileName)
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
	createButton:SetText(L["Create"])
	createButton:SetWidth(80)
	createButton:SetCallback("OnClick", function()
		local profileName = editbox:GetText()
		if profileName and profileName ~= "" then
			local success, message = self:CreateNewProfile(profileName)
			if success then
				zBarButtonBG.print(L["Profile created: "] .. profileName)
				-- Refresh the config to update dropdowns
				LibStub("AceConfigRegistry-3.0"):NotifyChange("zBarButtonBG")
				frame:Hide()
			else
				zBarButtonBG.print("|cFFFF0000Error:|r " .. message)
			end
		end
	end)
	buttonGroup:AddChild(createButton)

	-- Focus the editbox
	editbox:SetFocus()
end

function zBarButtonBGAce:GetOptionsTable()
	local options = {
		type = "group",
		name = "zBarButtonBG",
		args = {
			--[[
			overrideIconPadding = {
				order = nextOrderNumber(),
				type = "toggle",
				name = L["Override Icon Padding"],
				desc = L["Allow icon padding to be set below Blizzard's minimum (default: off)."],
				get = function() return self.db.profile.overrideIconPadding end,
				set = function(_, value)
					self.db.profile.overrideIconPadding = value
					zBarButtonBG.charSettings.overrideIconPadding = value
					if zBarButtonBG.enabled then
						zBarButtonBG.removeActionBarBackgrounds()
						zBarButtonBG.createActionBarBackgrounds()
					end
				end,
			},
			iconPaddingValue = {
				order = nextOrderNumber(),
				type = "range",
				name = L["Icon Padding Value"],
				desc = L["Set icon padding (0-20). Only applies if override is enabled."],
				min = 0,
				max = 20,
				step = 1,
				disabled = function() return not self.db.profile.overrideIconPadding end,
				get = function() return self.db.profile.iconPaddingValue or 2 end,
				set = function(_, value)
					self.db.profile.iconPaddingValue = value
					zBarButtonBG.charSettings.iconPaddingValue = value
					if zBarButtonBG.enabled then
						zBarButtonBG.removeActionBarBackgrounds()
						zBarButtonBG.createActionBarBackgrounds()
					end
				end,
			},
			]]--
			general = {
				order = 1,
				type = "group",
				name = L["General"],
				args = {
					profilesHeader = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Profiles"],
					},
					selectedProfile = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Current Profile"],
						desc = L["The currently active profile"],
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
							zBarButtonBG.print(L["Switched to profile: "] .. value)
						end,
					},
					createProfile = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["New Profile"],
						desc = L["Create a new profile"],
						func = function()
							self:ShowNewProfileDialog()
						end,
					},
					spacer2 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					resetButton = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["Reset Profile"],
						desc = L["Reset current profile to defaults"],
						confirm = function()
							return L
							["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"]
						end,
						func = function()
							-- Reset current profile to defaults
							self.db:ResetProfile()
							zBarButtonBG.charSettings = self.db.profile
							-- Trigger rebuild
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
							zBarButtonBG.print(L["Current profile reset to defaults!"])
						end,
					},
					spacer3 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					modifyProfilesHeader = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Modify Profiles"],
					},
					chooseProfile = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Choose Profile"],
						desc = L["Select a profile for copy/delete operations"],
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
					spacer4 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					copyProfile = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["Copy Profile"],
						desc = L["Copy settings from the chosen profile to the current profile"],
						disabled = function() return not self.selectedProfileForActions end,
						confirm = function()
							return L["Copy settings from: "] ..
								(self.selectedProfileForActions or "") ..
								"' to '" ..
								self.db:GetCurrentProfile() .. "'?\n\n" .. L
								["This will overwrite all current settings!"]
						end,
						func = function()
							local success, message = self:CopyProfile(self.selectedProfileForActions,
								self.db:GetCurrentProfile())
							if success then
								zBarButtonBG.print(L["Settings copied from: "] ..
									self.selectedProfileForActions .. "' -> '" .. self.db:GetCurrentProfile())
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
						order = nextOrderNumber(),
						type = "execute",
						name = "Delete Profile",
						desc = "Delete the chosen profile",
						disabled = function()
							return not self.selectedProfileForActions or self.selectedProfileForActions == "Default"
						end,
						confirm = function()
							return L["Are you sure you want to delete the profile: "] ..
								(self.selectedProfileForActions or "") .. "'?\n\n" .. L["This action cannot be undone!"]
						end,
						func = function()
							local profileToDelete = self.selectedProfileForActions
							local success, message = self:DeleteProfile(profileToDelete)
							if success then
								zBarButtonBG.print(L["Profile deleted: "] .. profileToDelete)
								self.selectedProfileForActions = nil
							else
								zBarButtonBG.print("|cFFFF0000Error:|r " .. message)
							end
						end,
					},
					spacer5 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					exportProfileHeader = {
						order = nextOrderNumber(),
						type = "header",
						name = "Import/Export",
					},
					exportProfile = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["Export Profile"],
						desc = L["Export current profile settings as a string"],
						func = function()
							local exportString = exportProfile(self.db.profile)

							-- Create an AceGUI frame to display the export string
							local AceGUI = LibStub("AceGUI-3.0")
							local frame = AceGUI:Create("Frame")
							frame:SetTitle("Export Profile")
							frame:SetStatusText("Copy this string to share your settings")
							frame:SetLayout("Flow")
							frame:SetWidth(600)
							frame:SetHeight(250)

							-- Create a scrolling editbox for the export string
							local editbox = AceGUI:Create("MultiLineEditBox")
							editbox:SetLabel("Export String:")
							editbox:SetText(exportString)
							editbox:SetFullWidth(true)
							editbox:SetNumLines(10)
							editbox:DisableButton(true) -- Make it read-only
							frame:AddChild(editbox)

							-- Copy button (if clipboard available)
							if ClipboardFrame or CPOOL_CLIPBOARD_FRAME then
								local copyButton = AceGUI:Create("Button")
								copyButton:SetText("Copy to Clipboard")
								copyButton:SetWidth(150)
								copyButton:SetCallback("OnClick", function()
									ClipboardFrame:SetText(exportString)
									ClipboardFrame:Show()
									zBarButtonBG.print("Export string copied to clipboard!")
								end)
								frame:AddChild(copyButton)
							end
						end,
					},
					importProfile = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["Import Profile"],
						desc = L["Import profile settings from an export string"],
						func = function()
							local AceGUI = LibStub("AceGUI-3.0")

							-- Create frame for import input
							local frame = AceGUI:Create("Frame")
							frame:SetTitle("Import Profile")
							frame:SetStatusText("Paste an export string and click Import")
							frame:SetLayout("Flow")
							frame:SetWidth(600)
							frame:SetHeight(300)

							-- Create editbox for paste
							local editbox = AceGUI:Create("MultiLineEditBox")
							editbox:SetLabel("Paste Export String:")
							editbox:SetFullWidth(true)
							editbox:SetNumLines(8)
							editbox:DisableButton(true) -- Disable the built-in accept button
							frame:AddChild(editbox)

							-- Create Import button
							local importButton = AceGUI:Create("Button")
							importButton:SetText("Import")
							importButton:SetWidth(100)
							importButton:SetCallback("OnClick", function()
								local exportString = editbox:GetText()
								if not exportString or exportString == "" then
									zBarButtonBG.print("|cFFFF0000Error:|r Please paste an export string first")
									return
								end

								local profile, errorMsg = importProfile(exportString)
								if not profile then
									zBarButtonBG.print("|cFFFF0000Error:|r " .. (errorMsg or "Invalid export string"))
									return
								end

								-- Close the import window
								AceGUI:Release(frame)

								-- Ask for new profile name
								local nameDialog = AceGUI:Create("Frame")
								nameDialog:SetTitle("Create Profile from Import")
								nameDialog:SetStatusText("Enter a name for the new profile")
								nameDialog:SetLayout("Flow")
								nameDialog:SetWidth(350)
								nameDialog:SetHeight(150)

								local nameEditbox = AceGUI:Create("EditBox")
								nameEditbox:SetLabel("Profile Name:")
								nameEditbox:SetFullWidth(true)
								nameEditbox:DisableButton(true) -- Disable built-in button
								nameDialog:AddChild(nameEditbox)

								-- Create button
								local createButton = AceGUI:Create("Button")
								createButton:SetText("Create")
								createButton:SetWidth(100)
								createButton:SetCallback("OnClick", function()
									local profileName = nameEditbox:GetText()
									if not profileName or profileName == "" then
										zBarButtonBG.print("|cFFFF0000Error:|r Profile name cannot be empty")
										return
									end

									-- Check if profile already exists
									if zBarButtonBGAce.db.profiles[profileName] then
										zBarButtonBG.print("|cFFFF0000Error:|r Profile already exists")
										return
									end

									-- Create the profile
									zBarButtonBGAce.db:SetProfile(profileName)

									-- Import the settings
									for key, value in pairs(profile) do
										zBarButtonBGAce.db.profile[key] = value
									end

									zBarButtonBG.charSettings = zBarButtonBGAce.db.profile

									-- Rebuild the UI
									if zBarButtonBG.enabled then
										zBarButtonBG.removeActionBarBackgrounds()
										zBarButtonBG.createActionBarBackgrounds()
									end

									zBarButtonBG.print("Profile imported: " .. profileName)
									LibStub("AceConfigRegistry-3.0"):NotifyChange("zBarButtonBG")

									AceGUI:Release(nameDialog)
								end)
								nameDialog:AddChild(createButton)
							end)
							frame:AddChild(importButton)
						end,
					},
				},
			},
			buttonSettings = {
				order = 2,
				type = "group",
				name = "Buttons",
				args = {
					resetButtonSettings = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["Reset Button Settings"],
						desc = L["Reset all button-related settings to default values"],
						confirm = function()
							return L
							["Are you sure you want to reset all button settings to default values?\n\nThis will reset button shape, backdrop, slot background, and border settings.\n\nThis action cannot be undone!"]
						end,
						func = function()
							-- Reset button-specific settings to defaults from aceDefaults table
							local defaults = zBarButtonBGAce.db.defaults.profile
							self.db.profile.buttonStyle = defaults.buttonStyle
							self.db.profile.showBorder = defaults.showBorder
							self.db.profile.borderColor = { r = defaults.borderColor.r, g = defaults.borderColor.g, b =
							defaults.borderColor.b, a = defaults.borderColor.a }
							self.db.profile.useClassColorBorder = defaults.useClassColorBorder
							self.db.profile.showBackdrop = defaults.showBackdrop
							self.db.profile.outerColor = { r = defaults.outerColor.r, g = defaults.outerColor.g, b =
							defaults.outerColor.b, a = defaults.outerColor.a }
							self.db.profile.useClassColorOuter = defaults.useClassColorOuter
							self.db.profile.backdropTopAdjustment = defaults.backdropTopAdjustment
							self.db.profile.backdropBottomAdjustment = defaults.backdropBottomAdjustment
							self.db.profile.backdropLeftAdjustment = defaults.backdropLeftAdjustment
							self.db.profile.backdropRightAdjustment = defaults.backdropRightAdjustment
							self.db.profile.showSlotBackground = defaults.showSlotBackground
							self.db.profile.innerColor = { r = defaults.innerColor.r, g = defaults.innerColor.g, b =
							defaults.innerColor.b, a = defaults.innerColor.a }
							self.db.profile.useClassColorInner = defaults.useClassColorInner
							-- Update native settings
							zBarButtonBG.charSettings = self.db.profile
							-- Trigger rebuild
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
							zBarButtonBG.print(L["Button settings reset to defaults!"])
						end,
					},
					spacer0a = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					header0 = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Appearance"],
					},
					squareButtons = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Button Style"],
						desc = L["Choose button style"],
						values = function() return zBarButtonBG.ButtonStyles.GetStylesForDropdown() end,
						get = function() return self.db.profile.buttonStyle or "Square" end,
						set = function(_, value)
							self.db.profile.buttonStyle = value
							zBarButtonBG.charSettings.buttonStyle = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					spacer1 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					header1 = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Backdrop"],
					},
					showBackdrop = {
						order = nextOrderNumber(),
						type = "toggle",
						name = L["Show Backdrop"],
						desc = L["Show outer background frame"],
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
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					outerColor = {
						order = nextOrderNumber(),
						type = "color",
						name = L["Backdrop Color"],
						desc = L["Color of the outer backdrop frame"],
						disabled = function()
							return not self.db.profile.showBackdrop or
								self.db.profile.useClassColorOuter
						end,
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
						order = nextOrderNumber(),
						type = "toggle",
						name = L["Use Class Color"],
						desc = L["Use your class color"],
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
					spacerBackdrop1 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					backdropTopAdjustment = {
						order = nextOrderNumber(),
						type = "range",
						name = L["Top Size"],
						desc = L["How far the backdrop extends above the button (in pixels)"],
						disabled = function() return not self.db.profile.showBackdrop end,
						min = 0,
						max = 20,
						step = 1,
						get = function() return self.db.profile.backdropTopAdjustment end,
						set = function(_, value)
							self.db.profile.backdropTopAdjustment = value
							zBarButtonBG.charSettings.backdropTopAdjustment = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					backdropBottomAdjustment = {
						order = nextOrderNumber(),
						type = "range",
						name = L["Bottom Size"],
						desc = L["How far the backdrop extends below the button (in pixels)"],
						disabled = function() return not self.db.profile.showBackdrop end,
						min = 0,
						max = 20,
						step = 1,
						get = function() return self.db.profile.backdropBottomAdjustment end,
						set = function(_, value)
							self.db.profile.backdropBottomAdjustment = value
							zBarButtonBG.charSettings.backdropBottomAdjustment = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					spacerBackdrop2 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					backdropLeftAdjustment = {
						order = nextOrderNumber(),
						type = "range",
						name = L["Left Size"],
						desc = L["How far the backdrop extends to the left of the button (in pixels)"],
						disabled = function() return not self.db.profile.showBackdrop end,
						min = 0,
						max = 20,
						step = 1,
						get = function() return self.db.profile.backdropLeftAdjustment end,
						set = function(_, value)
							self.db.profile.backdropLeftAdjustment = value
							zBarButtonBG.charSettings.backdropLeftAdjustment = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					backdropRightAdjustment = {
						order = nextOrderNumber(),
						type = "range",
						name = L["Right Size"],
						desc = L["How far the backdrop extends to the right of the button (in pixels)"],
						disabled = function() return not self.db.profile.showBackdrop end,
						min = 0,
						max = 20,
						step = 1,
						get = function() return self.db.profile.backdropRightAdjustment end,
						set = function(_, value)
							self.db.profile.backdropRightAdjustment = value
							zBarButtonBG.charSettings.backdropRightAdjustment = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					spacer3 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					header2 = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Button Background"],
					},
					showSlotBackground = {
						order = nextOrderNumber(),
						type = "toggle",
						name = L["Show Button Background"],
						desc = L["Show the button background fill behind each button icon"],
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
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					innerColor = {
						order = nextOrderNumber(),
						type = "color",
						name = L["Button Background Color"],
						desc = L["Color of the button slot background"],
						disabled = function()
							return not self.db.profile.showSlotBackground or
								self.db.profile.useClassColorInner
						end,
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
						order = nextOrderNumber(),
						type = "toggle",
						name = L["Use Class Color"],
						desc = L["Use your class color"],
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
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					header3 = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Border"],
					},
					showBorder = {
						order = nextOrderNumber(),
						type = "toggle",
						name = L["Show Border"],
						desc = L["Show border around buttons"],
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
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					borderColor = {
						order = nextOrderNumber(),
						type = "color",
						name = L["Border Color"],
						desc = L["Color of the button border"],
						disabled = function()
							return not self.db.profile.showBorder or
								self.db.profile.useClassColorBorder
						end,
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
						order = nextOrderNumber(),
						type = "toggle",
						name = L["Use Class Color"],
						desc = L["Use your class color"],
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
					resetIndicatorSettings = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["Reset Indicator Settings"],
						desc = L["Reset all indicator-related settings to default values"],
						confirm = function()
							return L
							["Are you sure you want to reset all indicator settings to default values?\n\nThis will reset range indicator, cooldown fade, and spell alert color settings.\n\nThis action cannot be undone!"]
						end,
						func = function()
							-- Reset indicator-specific settings to defaults from aceDefaults table
							local defaults = zBarButtonBGAce.db.defaults.profile
							self.db.profile.showRangeIndicator = defaults.showRangeIndicator
							self.db.profile.rangeIndicatorColor = { r = defaults.rangeIndicatorColor.r, g = defaults
							.rangeIndicatorColor.g, b = defaults.rangeIndicatorColor.b, a = defaults.rangeIndicatorColor
							.a }
							self.db.profile.fadeCooldown = defaults.fadeCooldown
							self.db.profile.cooldownColor = { r = defaults.cooldownColor.r, g = defaults.cooldownColor.g, b =
							defaults.cooldownColor.b, a = defaults.cooldownColor.a }
							self.db.profile.spellAlertColor = { r = defaults.spellAlertColor.r, g = defaults.spellAlertColor.g, b = defaults.spellAlertColor.b, a = defaults.spellAlertColor.a }
							self.db.profile.suggestedActionColor = { r = defaults.suggestedActionColor.r, g = defaults.suggestedActionColor.g, b = defaults.suggestedActionColor.b, a = defaults.suggestedActionColor.a }
							-- Update native settings
							zBarButtonBG.charSettings = self.db.profile
							-- Trigger rebuild
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
							zBarButtonBG.print(L["Indicator settings reset to defaults!"])
						end,
					},
					spacer0a = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					header = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Overlays"],
					},
					showRangeIndicator = {
						order = nextOrderNumber(),
						type = "toggle",
						name = L["Out of Range Overlay"],
						desc = L["Show red overlay when abilities are out of range"],
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
						order = nextOrderNumber(),
						type = "color",
						name = L["Out of Range Color"],
						desc = L["Color of the out of range indicator"],
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
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					fadeCooldown = {
						order = nextOrderNumber(),
						type = "toggle",
						name = L["Cooldown Overlay"],
						desc = L["Show dark overlay during ability cooldowns"],
						hidden = function() return not zBarButtonBG.midnightCooldown end,
						disabled = function() return not zBarButtonBG.midnightCooldown end,
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
						order = nextOrderNumber(),
						type = "color",
						name = L["Cooldown Color"],
						desc = L["Color of the cooldown overlay"],
						hidden = function() return not zBarButtonBG.midnightCooldown end,
						disabled = function() return not zBarButtonBG.midnightCooldown or
							not self.db.profile.fadeCooldown end,
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
					spacer1a = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					--[[ showSpellAlerts = {
						order = nextOrderNumber(),
						type = "toggle",
						name = L["Spell Alerts"],
						desc = L["Show custom spell alert indicators"],
						get = function() return self.db.profile.showSpellAlerts end,
						set = function(_, value)
							self.db.profile.showSpellAlerts = value
							zBarButtonBG.charSettings.showSpellAlerts = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},]]--
					spellAlertColor = {
						order = nextOrderNumber(),
						type = "color",
						name = L["Proc Alt Glow Color"],
						desc = L["Color of spell proc alerts"],
						disabled = function() return not self.db.profile.showSpellAlerts end,
						hasAlpha = true,
						get = function()
							local c = self.db.profile.spellAlertColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.spellAlertColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.spellAlertColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					suggestedActionColor = {
						order = nextOrderNumber(),
						type = "color",
						name = L["Suggested Action Color"],
						desc = L["Color of suggested action indicators"],
						disabled = function() return not self.db.profile.showSpellAlerts end,
						hasAlpha = true,
						get = function()
							local c = self.db.profile.suggestedActionColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a)
							self.db.profile.suggestedActionColor = { r = r, g = g, b = b, a = a }
							zBarButtonBG.charSettings.suggestedActionColor = { r = r, g = g, b = b, a = a }
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					spacer2 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
				},
			},
			textSettings = {
				order = 4,
				type = "group",
				name = "Text Fields",
				args = {
					macroNameHeader = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Macro Name"],
					},
					resetMacroSettings = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["Reset Macro Settings"],
						desc = L["Reset macro name text settings to default values"],
						confirm = function()
							return L
							["Are you sure you want to reset all macro text settings to default values?\n\nThis will reset font, size, color, positioning, and justification settings for macro names.\n\nThis action cannot be undone!"]
						end,
						func = function()
							-- Reset macro-specific settings to defaults from aceDefaults table
							local defaults = zBarButtonBGAce.db.defaults.profile
							self.db.profile.macroNameFont = defaults.macroNameFont
							self.db.profile.macroNameFontSize = defaults.macroNameFontSize
							self.db.profile.macroNameFontFlags = defaults.macroNameFontFlags
							self.db.profile.macroNameWidth = defaults.macroNameWidth
							self.db.profile.macroNameHeight = defaults.macroNameHeight
							self.db.profile.macroNameColor = { r = defaults.macroNameColor.r, g = defaults
							.macroNameColor.g, b = defaults.macroNameColor.b, a = defaults.macroNameColor.a }
							self.db.profile.macroNameJustification = defaults.macroNameJustification
							self.db.profile.macroNamePosition = defaults.macroNamePosition
							self.db.profile.macroNameOffsetX = defaults.macroNameOffsetX
							self.db.profile.macroNameOffsetY = defaults.macroNameOffsetY
							-- Update native settings
							zBarButtonBG.charSettings = self.db.profile
							-- Trigger font update
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
							zBarButtonBG.print(L["Macro text settings reset to defaults!"])
						end,
					},
					spacerReset1 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					macroNameFont = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Macro Name Font"],
						desc = L["Font family for macro names"],
						values = function()
							local fontList = LSM:List("font")
							local result = {}
							if fontList then
								for _, fontName in ipairs(fontList) do
									result[fontName] = fontName
								end
							end
							return result
						end,
						get = function() return self.db.profile.macroNameFont end,
						set = function(_, value)
							self.db.profile.macroNameFont = value
							zBarButtonBG.charSettings.macroNameFont = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								-- Add small delay to allow LibSharedMedia to load the font
								C_Timer.After(0.1, function()
									zBarButtonBG.updateFonts()
								end)
							end
						end,
					},
					macroNameFontFlags = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Font Flags"],
						desc = L["Font style flags for macro names"],
						values = {
							[""] = L["None"],
							["OUTLINE"] = L["Outline"],
							["THICKOUTLINE"] = L["Thick Outline"],
							["MONOCHROME"] = L["Monochrome"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Font Size"],
						desc = L["Size of the macro name text"],
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
						order = nextOrderNumber(),
						type = "color",
						name = L["Macro Name Color"],
						desc = L["Color of the macro name text"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Macro Name Width"],
						desc = L["Width of the macro name text frame"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Macro Name Height"],
						desc = L["Height of the macro name text frame"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Macro Name X Offset"],
						desc = L["Horizontal positioning offset for macro name text"],
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
								return L["Value must be a number"]
							end
							if num < -50 or num > 50 then
								return L["Value must be between -50 and 50"]
							end
							return true
						end,
					},
					macroNameOffsetY = {
						order = nextOrderNumber(),
						type = "range",
						name = L["Macro Name Y Offset"],
						desc = L["Vertical positioning offset for macro name text"],
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
								return L["Value must be a number"]
							end
							if num < -50 or num > 50 then
								return L["Value must be between -50 and 50"]
							end
							return true
						end,
					},
					spacer1 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					macroNameJustification = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Macro Text Justification"],
						desc = L["Text alignment for macro names"],
						values = {
							["LEFT"] = L["Left"],
							["CENTER"] = L["Center"],
							["RIGHT"] = L["Right"],
						},
						get = function() return self.db.profile.macroNameJustification end,
						set = function(_, value)
							self.db.profile.macroNameJustification = value
							zBarButtonBG.charSettings.macroNameJustification = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNamePosition = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Macro Text Position"],
						desc = L["Vertical position of macro text within the text frame"],
						values = {
							["TOP"] = L["Top"],
							["MIDDLE"] = L["Center"],
							["BOTTOM"] = L["Bottom"],
						},
						get = function() return self.db.profile.macroNamePosition end,
						set = function(_, value)
							self.db.profile.macroNamePosition = value
							zBarButtonBG.charSettings.macroNamePosition = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					spacer1a = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					countHeader = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Count/Charge"],
					},
					resetCountSettings = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["Reset Count Settings"],
						desc = L["Reset count/charge text settings to default values"],
						confirm = function()
							return L
							["Are you sure you want to reset all count/charge text settings to default values?\n\nThis will reset font, size, color, and positioning settings for count/charge numbers.\n\nThis action cannot be undone!"]
						end,
						func = function()
							-- Reset count-specific settings to defaults from aceDefaults table
							local defaults = zBarButtonBGAce.db.defaults.profile
							self.db.profile.countFont = defaults.countFont
							self.db.profile.countFontSize = defaults.countFontSize
							self.db.profile.countFontFlags = defaults.countFontFlags
							self.db.profile.countWidth = defaults.countWidth
							self.db.profile.countHeight = defaults.countHeight
							self.db.profile.countColor = { r = defaults.countColor.r, g = defaults.countColor.g, b =
							defaults.countColor.b, a = defaults.countColor.a }
							self.db.profile.countOffsetX = defaults.countOffsetX
							self.db.profile.countOffsetY = defaults.countOffsetY
							-- Update native settings
							zBarButtonBG.charSettings = self.db.profile
							-- Trigger font update
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
							zBarButtonBG.print(L["Count text settings reset to defaults!"])
						end,
					},
					spacerReset2 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					countFont = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Count Font"],
						desc = L["Font family for count/charge numbers"],
						values = function()
							local fontList = LSM:List("font")
							local result = {}
							if fontList then
								for _, fontName in ipairs(fontList) do
									result[fontName] = fontName
								end
							end
							return result
						end,
						get = function() return self.db.profile.countFont end,
						set = function(_, value)
							self.db.profile.countFont = value
							zBarButtonBG.charSettings.countFont = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								-- Add small delay to allow LibSharedMedia to load the font
								C_Timer.After(0.1, function()
									zBarButtonBG.updateFonts()
								end)
							end
						end,
					},
					countFontFlags = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Count Font Style"],
						desc = L["Font style flags for count/charge numbers"],
						values = {
							[""] = L["None"],
							["OUTLINE"] = L["Outline"],
							["THICKOUTLINE"] = L["Thick Outline"],
							["MONOCHROME"] = L["Monochrome"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Count Font Size"],
						desc = L["Size of the count/charge text"],
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
						order = nextOrderNumber(),
						type = "color",
						name = L["Count Color"],
						desc = L["Color of the count/charge text"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Count Width"],
						desc = L["Width of the count text frame"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Count Height"],
						desc = L["Height of the count text frame"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Count X Offset"],
						desc = L["Horizontal positioning offset for count/charge text"],
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
								return L["Value must be a number"]
							end
							if num < -50 or num > 50 then
								return L["Value must be between -50 and 50"]
							end
							return true
						end,
					},
					countOffsetY = {
						order = nextOrderNumber(),
						type = "range",
						name = L["Count Y Offset"],
						desc = L["Vertical positioning offset for count/charge text"],
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
								return L["Value must be a number"]
							end
							if num < -50 or num > 50 then
								return L["Value must be between -50 and 50"]
							end
							return true
						end,
					},
					spacer4 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					keybindHeader = {
						order = nextOrderNumber(),
						type = "header",
						name = L["Keybind/Hotkey"],
					},
					resetKeybindSettings = {
						order = nextOrderNumber(),
						type = "execute",
						name = L["Reset Keybind Settings"],
						desc = L["Reset keybind/hotkey text settings to default values"],
						confirm = function()
							return L
							["Are you sure you want to reset all keybind/hotkey text settings to default values?\n\nThis will reset font, size, color, and positioning settings for keybind/hotkey text.\n\nThis action cannot be undone!"]
						end,
						func = function()
							-- Reset keybind-specific settings to defaults from aceDefaults table
							local defaults = zBarButtonBGAce.db.defaults.profile
							self.db.profile.keybindFont = defaults.keybindFont
							self.db.profile.keybindFontSize = defaults.keybindFontSize
							self.db.profile.keybindFontFlags = defaults.keybindFontFlags
							self.db.profile.keybindWidth = defaults.keybindWidth
							self.db.profile.keybindHeight = defaults.keybindHeight
							self.db.profile.keybindColor = { r = defaults.keybindColor.r, g = defaults.keybindColor.g, b =
							defaults.keybindColor.b, a = defaults.keybindColor.a }
							self.db.profile.keybindOffsetX = defaults.keybindOffsetX
							self.db.profile.keybindOffsetY = defaults.keybindOffsetY
							-- Update native settings
							zBarButtonBG.charSettings = self.db.profile
							-- Trigger font update
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
							zBarButtonBG.print(L["Keybind text settings reset to defaults!"])
						end,
					},
					spacerReset3 = {
						order = nextOrderNumber(),
						type = "description",
						name = " ",
					},
					keybindFont = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Keybind Font"],
						desc = L["Font family for keybind/hotkey text"],
						values = function()
							local fontList = LSM:List("font")
							local result = {}
							if fontList then
								for _, fontName in ipairs(fontList) do
									result[fontName] = fontName
								end
							end
							return result
						end,
						get = function() return self.db.profile.keybindFont end,
						set = function(_, value)
							self.db.profile.keybindFont = value
							zBarButtonBG.charSettings.keybindFont = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								-- Add small delay to allow LibSharedMedia to load the font
								C_Timer.After(0.1, function()
									zBarButtonBG.updateFonts()
								end)
							end
						end,
					},
					keybindFontFlags = {
						order = nextOrderNumber(),
						type = "select",
						name = L["Keybind Font Style"],
						desc = L["Font style flags for keybind/hotkey text"],
						values = {
							[""] = L["None"],
							["OUTLINE"] = L["Outline"],
							["THICKOUTLINE"] = L["Thick Outline"],
							["MONOCHROME"] = L["Monochrome"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Keybind Font Size"],
						desc = L["Size of the keybind/hotkey text"],
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
						order = nextOrderNumber(),
						type = "color",
						name = L["Keybind Text Color"],
						desc = L["Color of the keybind/hotkey text"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Keybind Width"],
						desc = L["Width of the keybind text frame"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Keybind Height"],
						desc = L["Height of the keybind text frame"],
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
						order = nextOrderNumber(),
						type = "range",
						name = L["Keybind X Offset"],
						desc = L["Horizontal positioning offset for keybind/hotkey text"],
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
								return L["Value must be a number"]
							end
							if num < -50 or num > 50 then
								return L["Value must be between -50 and 50"]
							end
							return true
						end,
					},
					keybindOffsetY = {
						order = nextOrderNumber(),
						type = "range",
						name = L["Keybind Y Offset"],
						desc = L["Vertical positioning offset for keybind/hotkey text"],
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
								return L["Value must be a number"]
							end
							if num < -50 or num > 50 then
								return L["Value must be between -50 and 50"]
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

-- Initialize the Ace config interface
function zBarButtonBGAce:InitializeOptions()
	-- Get the options table
	local optionsTable = self:GetOptionsTable()

	-- Register with AceConfig (note: AceConfig-3.0 not AceConfigRegistry)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("zBarButtonBG", optionsTable)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("zBarButtonBG", "zBarButtonBG")
end
