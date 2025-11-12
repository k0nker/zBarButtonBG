-- Initialize Ace addon for options only
zBarButtonBGAce = LibStub("AceAddon-3.0"):NewAddon("zBarButtonBG")

-- AceDB defaults structure
local aceDefaults = {
	profile = {
		enabled = true,
		squareButtons = true,
		showBorder = false,
		borderColor = { r = 0.2, g = 0.2, b = 0.2, a = 1 },
		useClassColorBorder = false,
		showBackdrop = true,
		outerColor = { r = 0.08, g = 0.08, b = 0.08, a = 1 },
		useClassColorOuter = false,
		backdropTopAdjustment = 3,
		backdropBottomAdjustment = 3,
		backdropLeftAdjustment = 3,
		backdropRightAdjustment = 3,
		showSlotBackground = true,
		innerColor = { r = 0.1, g = 0.1, b = 0.1, a = 1 },
		useClassColorInner = false,
		showRangeIndicator = true,
		rangeIndicatorColor = { r = .42, g = 0.07, b = .12, a = 0.75 },
		fadeCooldown = false,
		cooldownColor = { r = 0, g = 0, b = 0, a = 0.5 },
		macroNameFont = "Homespun",
		macroNameFontSize = 12,
		macroNameFontFlags = "OUTLINE",
		macroNameWidth = 42,
		macroNameHeight = 30,
		macroNameColor = { r = 1, g = 1, b = 1, a = 1 },
		macroNameJustification = "LEFT",
		macroNamePosition = "BOTTOM",
		macroNameOffsetX = 0,
		macroNameOffsetY = 0,
		countFont = "Homespun",
		countFontSize = 16,
		countFontFlags = "OUTLINE",
		countWidth = 42,
		countHeight = 15,
		countColor = { r = 1, g = 1, b = 1, a = 1 },
		countOffsetX = 0,
		countOffsetY = 0,
		keybindFont = "Homespun",
		keybindFontSize = 12,
		keybindFontFlags = "OUTLINE",
		keybindWidth = 42,
		keybindHeight = 12,
		keybindColor = { r = 1, g = 1, b = 1, a = 1 },
		keybindOffsetX = 0,
		keybindOffsetY = 0
	}
}

function zBarButtonBGAce:OnInitialize()
	-- Initialize AceDB with profile support
	self.db = LibStub("AceDB-3.0"):New("zBarButtonBGDB", aceDefaults, true)

	-- Make Ace the single source of truth - native system points to Ace profile
	zBarButtonBG.charSettings = self.db.profile

	-- AceDB automatically handles profile creation and management
	-- No need to force creation of "Default" profile - let AceDB handle it naturally
end

-- Profile management functions
function zBarButtonBGAce:CreateNewProfile(profileName)
	if not profileName or profileName == "" then
		return false, "Profile name cannot be empty"
	end

	if self.db.profiles[profileName] then
		return false, "Profile already exists"
	end

	-- Create new profile and switch to it
	self.db:SetProfile(profileName)
	zBarButtonBG.charSettings = self.db.profile

	-- Update the action bars
	if zBarButtonBG.enabled then
		zBarButtonBG.removeActionBarBackgrounds()
		zBarButtonBG.createActionBarBackgrounds()
	end

	return true, "Profile created successfully"
end

function zBarButtonBGAce:SwitchToProfile(profileName)
	if not profileName or not self.db.profiles[profileName] then
		return false, "Profile does not exist"
	end

	-- Switch to profile
	self.db:SetProfile(profileName)
	zBarButtonBG.charSettings = self.db.profile

	-- Update the action bars
	if zBarButtonBG.enabled then
		zBarButtonBG.removeActionBarBackgrounds()
		zBarButtonBG.createActionBarBackgrounds()
	end

	return true, "Switched to profile: " .. profileName
end

function zBarButtonBGAce:CopyProfile(sourceProfile, targetProfile)
	if not sourceProfile or not self.db.profiles[sourceProfile] then
		return false, "Source profile does not exist"
	end

	if not targetProfile or targetProfile == "" then
		targetProfile = self.db:GetCurrentProfile()
	end

	-- Copy profile data
	self.db:CopyProfile(sourceProfile, targetProfile)
	zBarButtonBG.charSettings = self.db.profile

	-- Update the action bars
	if zBarButtonBG.enabled then
		zBarButtonBG.removeActionBarBackgrounds()
		zBarButtonBG.createActionBarBackgrounds()
	end

	return true, "Profile copied successfully"
end

function zBarButtonBGAce:DeleteProfile(profileName)
	if not profileName or profileName == "Default" then
		return false, "Cannot delete Default profile"
	end

	if not self.db.profiles[profileName] then
		return false, "Profile does not exist"
	end

	if self.db:GetCurrentProfile() == profileName then
		-- Switch to a safe profile before deleting
		-- Try to find an existing profile to switch to, preferring "Default"
		local targetProfile = "Default"
		if not self.db.profiles["Default"] then
			-- If no Default profile exists, find any other existing profile
			for existingProfile, _ in pairs(self.db.profiles) do
				if existingProfile ~= profileName then
					targetProfile = existingProfile
					break
				end
			end
		end

		self.db:SetProfile(targetProfile)
		zBarButtonBG.charSettings = self.db.profile

		-- Update the action bars
		if zBarButtonBG.enabled then
			zBarButtonBG.removeActionBarBackgrounds()
			zBarButtonBG.createActionBarBackgrounds()
		end
	end

	-- Delete the profile
	self.db:DeleteProfile(profileName, true)

	return true, "Profile deleted successfully"
end

function zBarButtonBGAce:GetProfileList()
	local profiles = {}
	for name, _ in pairs(self.db.profiles) do
		table.insert(profiles, name)
	end
	table.sort(profiles)
	return profiles
end

function zBarButtonBGAce:InitializeOptions()
	-- Register options with Ace Config
	LibStub("AceConfig-3.0"):RegisterOptionsTable("zBarButtonBG", self:GetOptionsTable())
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("zBarButtonBG", "zBarButtonBG")

	-- Register slash command to open options
	SLASH_ZBARBUTTONBGOPTIONS1 = "/zbg"
	SlashCmdList["ZBARBUTTONBGOPTIONS"] = function(msg)
		if msg == "debug" then
			zBarButtonBG._debugGCD = not zBarButtonBG._debugGCD
			print("zBarButtonBG: GCD debug", zBarButtonBG._debugGCD and "enabled" or "disabled")
		else
			-- Open the options panel using Ace Config Dialog
			LibStub("AceConfigDialog-3.0"):Open("zBarButtonBG")
		end
	end
end

-- Keep main functionality in global namespace (native WoW API)
zBarButtonBG = {}

-- Developer toggle for cooldown overlay feature (set to false to disable, true to enable)
-- This is NOT a SavedVariable - it's a developer-level control
zBarButtonBG.midnightCooldown = false

-- ############################################################
-- Load settings when we log in
-- ############################################################
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		-- Settings are now handled entirely by Ace - zBarButtonBG.charSettings already points to Ace profile
		-- No need for native SavedVariables system anymore

		-- Initialize Ace options after settings are loaded
		-- Debug: Check if LSM30_Font widget is registered before options
		local AceGUI = LibStub("AceGUI-3.0", true)
		C_Timer.After(0.5, function()
			zBarButtonBGAce:InitializeOptions()
		end)

		-- If we had this enabled before, turn it back on after a short delay
		-- (need to wait for action bars to actually load first)
		if zBarButtonBG.charSettings.enabled then
			zBarButtonBG.enabled = true
			C_Timer.After(3.5, function()
				zBarButtonBG.createActionBarBackgrounds()
			end)
		end
	end
end)

-- Track whether we're enabled and store our custom frames
zBarButtonBG.enabled = false
zBarButtonBG.frames = {}

-- ############################################################
-- Helper Functions
-- ############################################################

-- Get color table with optional class color override
local function getColorTable(colorKey, useClassColorKey)
	if zBarButtonBG.charSettings[useClassColorKey] then
		local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
		return { r = classColor.r, g = classColor.g, b = classColor.b, a = 1 }
	else
		local c = zBarButtonBG.charSettings[colorKey]
		return { r = c.r, g = c.g, b = c.b, a = c.a }
	end
end

-- Get mask texture path based on square/round setting
local function getMaskPath()
	return zBarButtonBG.charSettings.squareButtons
		and "Interface\\AddOns\\zBarButtonBG\\Assets\\ButtonIconMask_Square"
		or "Interface\\AddOns\\zBarButtonBG\\Assets\\ButtonIconMask_Rounded"
end

-- Get border texture path based on square/round setting
local function getBorderPath()
	return zBarButtonBG.charSettings.squareButtons
		and "Interface\\AddOns\\zBarButtonBG\\Assets\\ButtonIconBorder_Square"
		or "Interface\\AddOns\\zBarButtonBG\\Assets\\ButtonIconBorder_Rounded"
end

-- Helper to apply/remove a mask to a texture while tracking what mask is applied
local function applyMaskToTexture(tex, mask)
	if not tex then return end
	-- If the mask is already applied to this texture, do nothing
	if tex._zBBG_appliedMask == mask then return end
	-- If there is a different mask applied, remove it first
	if tex._zBBG_appliedMask then
		tex:RemoveMaskTexture(tex._zBBG_appliedMask)
		tex._zBBG_appliedMask = nil
	end
	if mask then
		tex:AddMaskTexture(mask)
		tex._zBBG_appliedMask = mask
	end
end

local function removeMaskFromTexture(tex)
	if not tex then return end
	if tex._zBBG_appliedMask then
		tex:RemoveMaskTexture(tex._zBBG_appliedMask)
		tex._zBBG_appliedMask = nil
	end
end

-- ############################################################
-- Main Functions
-- ############################################################

-- Print helper that prefixes our addon name
function zBarButtonBG.print(arg)
	if arg == "" or arg == nil then
		return
	else
		print("|cFF72B061zBarButtonBG:|r " .. arg)
	end
	return false
end

-- Toggle command - turn backgrounds on/off
function zBarButtonBG.toggle()
	zBarButtonBG.enabled = not zBarButtonBG.enabled

	if zBarButtonBG.enabled then
		zBarButtonBG.createActionBarBackgrounds()
		zBarButtonBG.print("Action bar backgrounds |cFF00FF00enabled|r")
	else
		zBarButtonBG.removeActionBarBackgrounds()
		zBarButtonBG.print("Action bar backgrounds |cFFFF0000disabled|r")
	end

	-- Save the enabled state (zBarButtonBG.charSettings points to Ace profile, so this automatically saves)
	if zBarButtonBG.charSettings then
		zBarButtonBG.charSettings.enabled = zBarButtonBG.enabled
	end
end

-- Update colors on existing frames without rebuilding everything
function zBarButtonBG.updateColors()
	if not zBarButtonBG.enabled then return end

	-- Get color tables once using helpers to eliminate repetitive calls
	local outerColor = getColorTable("outerColor", "useClassColorOuter")
	local innerColor = getColorTable("innerColor", "useClassColorInner")
	local borderColor = getColorTable("borderColor", "useClassColorBorder")
	local rangeColor = zBarButtonBG.charSettings.rangeIndicatorColor
	local cooldownColor = zBarButtonBG.charSettings.cooldownColor

	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data and data.button then
			-- Update outer background color
			if data.outerBg then
				data.outerBg:SetColorTexture(outerColor.r, outerColor.g, outerColor.b, outerColor.a)
			end

			-- Update inner background color
			if data.bg then
				data.bg:SetColorTexture(innerColor.r, innerColor.g, innerColor.b, innerColor.a)
			end

			-- Update border color
			if zBarButtonBG.charSettings.showBorder and data.customBorderTexture then
				-- Use color picker's alpha for overall border transparency (ADD mode handles black=transparent)
				data.customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
			end

			-- Update range indicator color
			if data.button._zBBG_rangeOverlay then
				data.button._zBBG_rangeOverlay:SetColorTexture(rangeColor.r, rangeColor.g, rangeColor.b, rangeColor.a)
			end

			-- Update cooldown overlay color
			if data.button._zBBG_cooldownOverlay then
				data.button._zBBG_cooldownOverlay:SetColorTexture(cooldownColor.r, cooldownColor.g, cooldownColor.b,
					cooldownColor.a)
			end
		end
	end
end

-- Helper function to get font path from LibSharedMedia
local function getFontPath(fontName)
	local LSM = LibStub("LibSharedMedia-3.0", true)
	if LSM then
		return LSM:Fetch("font", fontName) or fontName
	end
	return fontName
end

-- ############################################################
-- Helper Functions to Eliminate Duplication
-- ############################################################

-- Apply macro name text styling (extracted from repeated pattern)
local function applyMacroNameStyling(button)
	if not button or not button.Name then return end

	button.Name:SetFont(
		getFontPath(zBarButtonBG.charSettings.macroNameFont),
		zBarButtonBG.charSettings.macroNameFontSize,
		zBarButtonBG.charSettings.macroNameFontFlags
	)
	button.Name:SetSize(
		zBarButtonBG.charSettings.macroNameWidth,
		zBarButtonBG.charSettings.macroNameHeight
	)
	local c = zBarButtonBG.charSettings.macroNameColor
	button.Name:SetTextColor(c.r, c.g, c.b, c.a)
	button.Name:SetJustifyH(zBarButtonBG.charSettings.macroNameJustification or "CENTER")
	button.Name:SetJustifyV(zBarButtonBG.charSettings.macroNamePosition or "MIDDLE")
	-- Set draw layer to appear behind Blizzard's cooldown text
	button.Name:SetDrawLayer("BORDER", 1)
	local xOffset = zBarButtonBG.charSettings.macroNameOffsetX or 0
	local yOffset = zBarButtonBG.charSettings.macroNameOffsetY or 0
	button.Name:ClearAllPoints()
	button.Name:SetPoint("BOTTOM", button, "BOTTOM", 0 + xOffset, 2 + yOffset)
end

-- Apply count text styling (extracted from repeated pattern)
local function applyCountStyling(button)
	if not button or not button.Count then return end

	button.Count:SetFont(
		getFontPath(zBarButtonBG.charSettings.countFont),
		zBarButtonBG.charSettings.countFontSize,
		zBarButtonBG.charSettings.countFontFlags
	)
	button.Count:SetSize(
		zBarButtonBG.charSettings.countWidth,
		zBarButtonBG.charSettings.countHeight
	)
	local c = zBarButtonBG.charSettings.countColor
	button.Count:SetTextColor(c.r, c.g, c.b, c.a)
	local xOffset = zBarButtonBG.charSettings.countOffsetX or 0
	local yOffset = zBarButtonBG.charSettings.countOffsetY or 0
	button.Count:ClearAllPoints()
	button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0 + xOffset, 3 + yOffset)
end

-- Apply keybind text styling (extracted from repeated pattern)
local function applyKeybindStyling(button)
	if not button or not button.HotKey then return end

	button.HotKey:SetFont(
		getFontPath(zBarButtonBG.charSettings.keybindFont),
		zBarButtonBG.charSettings.keybindFontSize,
		zBarButtonBG.charSettings.keybindFontFlags
	)
	button.HotKey:SetSize(
		zBarButtonBG.charSettings.keybindWidth,
		zBarButtonBG.charSettings.keybindHeight
	)
	local c = zBarButtonBG.charSettings.keybindColor
	button.HotKey:SetTextColor(c.r, c.g, c.b, c.a)
	local xOffset = zBarButtonBG.charSettings.keybindOffsetX or 0
	local yOffset = zBarButtonBG.charSettings.keybindOffsetY or 0
	button.HotKey:ClearAllPoints()
	button.HotKey:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1 + xOffset, -2 + yOffset)
end

-- Apply all text styling to a button (eliminates 60+ lines of duplication)
local function applyAllTextStyling(button)
	if not button then return end

	applyMacroNameStyling(button)
	applyCountStyling(button)
	applyKeybindStyling(button)
end

-- Manage NormalTexture consistently (extracted from repeated calls)
local function updateButtonNormalTexture(button)
	if not button or not button.NormalTexture then return end

	-- Always keep it transparent for our custom styling
	button.NormalTexture:SetAlpha(0)
end

-- Apply backdrop positioning with adjustable offsets
local function applyBackdropPositioning(outerFrame, button)
	if not outerFrame or not button then return end

	local topAdj = zBarButtonBG.charSettings.backdropTopAdjustment or 5
	local bottomAdj = zBarButtonBG.charSettings.backdropBottomAdjustment or 5
	local leftAdj = zBarButtonBG.charSettings.backdropLeftAdjustment or 5
	local rightAdj = zBarButtonBG.charSettings.backdropRightAdjustment or 5

	outerFrame:ClearAllPoints()
	outerFrame:SetPoint("TOPLEFT", button, "TOPLEFT", -leftAdj, topAdj)
	outerFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", rightAdj, -bottomAdj)
end

-- Apply text positioning with offsets (eliminates repetitive positioning code)
local function applyTextPositioning(button)
	if not button then return end

	-- Apply text positioning after button data is stored
	if button.Name then
		button.Name:SetJustifyH(zBarButtonBG.charSettings.macroNameJustification or "CENTER")
		button.Name:SetJustifyV(zBarButtonBG.charSettings.macroNamePosition or "MIDDLE")
		-- Set draw layer to appear behind Blizzard's cooldown text
		button.Name:SetDrawLayer("BORDER", 1)
		local xOffset = zBarButtonBG.charSettings.macroNameOffsetX or 0
		local yOffset = zBarButtonBG.charSettings.macroNameOffsetY or 0
		button.Name:ClearAllPoints()
		button.Name:SetPoint("BOTTOM", button, "BOTTOM", 0 + xOffset, 2 + yOffset)
	end
	if button.Count then
		local xOffset = zBarButtonBG.charSettings.countOffsetX or 0
		local yOffset = zBarButtonBG.charSettings.countOffsetY or 0
		button.Count:ClearAllPoints()
		button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0 + xOffset, 3 + yOffset)
	end
	if button.HotKey then
		local xOffset = zBarButtonBG.charSettings.keybindOffsetX or 0
		local yOffset = zBarButtonBG.charSettings.keybindOffsetY or 0
		button.HotKey:ClearAllPoints()
		button.HotKey:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1 + xOffset, -2 + yOffset)
	end
end

-- Update fonts on existing buttons without rebuilding everything
function zBarButtonBG.updateFonts()
	if not zBarButtonBG.enabled then return end

	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data and data.button then
			-- Use helper function to eliminate 60+ lines of duplicated code
			applyAllTextStyling(data.button)
		end
	end
end

function zBarButtonBG.createActionBarBackgrounds()
	-- Get colors once at the top to eliminate repeated getColorTable calls
	local outerColor = getColorTable("outerColor", "useClassColorOuter")
	local innerColor = getColorTable("innerColor", "useClassColorInner")
	local borderColor = getColorTable("borderColor", "useClassColorBorder")

	-- All the different types of action bar buttons we want to modify
	local buttonBases = {
		"ActionButton",        -- Main action bar (1-12)
		"MultiBarBottomLeftButton", -- Bottom left bar
		"MultiBarBottomRightButton", -- Bottom right bar
		"MultiBarRightButton", -- Right bar 1
		"MultiBarLeftButton",  -- Right bar 2
		"MultiBar5Button",     -- Bar 5
		"MultiBar6Button",     -- Bar 6
		"MultiBar7Button",     -- Bar 7
		"PetActionButton",     -- Pet action bar
		"StanceButton",        -- Stance/form bar
	}

	for _, baseName in ipairs(buttonBases) do
		-- Pet and stance bars only have 10 buttons instead of 12
		local maxButtons = (baseName == "PetActionButton" or baseName == "StanceButton") and 10 or 12
		for i = 1, maxButtons do
			local buttonName = baseName .. i
			local button = _G[buttonName]

			-- Process the button whether it's visible or not
			-- This is important for pet bars that only show up when you summon a pet
			if button then
				-- Check if we've already set this button up
				if not zBarButtonBG.frames[buttonName] then
					-- Mark this button as having our custom styling applied
					button._zBBG_styled = true

					-- Handle the default border texture based on settings
					-- Always make Blizzard's NormalTexture fully transparent so it never shows
					updateButtonNormalTexture(button)

					-- Apply icon styling based on square/round mode

					-- Round button mode: zoom in and use custom mask for clipping
					if button.icon then
						-- Remove Blizzard's mask
						if button.IconMask then
							button.icon:RemoveMaskTexture(button.IconMask)
						end

						-- Scale up slightly to zoom in and hide any icon border
						button.icon:SetScale(1.05)

						-- Crop the texture coordinates to remove edges
						button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

						-- Apply our custom mask texture (BLEND mode uses the alpha channel)
						if not button._zBBG_customMask then
							button._zBBG_customMask = button:CreateMaskTexture()
							-- Use BLEND mode which respects alpha: transparent=hide, opaque=show
							button._zBBG_customMask:SetTexture(getMaskPath())
							button._zBBG_customMask:SetAllPoints(button)
						end
						applyMaskToTexture(button.icon, button._zBBG_customMask)
					end

					-- Make the cooldown spiral fill the whole button
					if button.cooldown then
						button.cooldown:SetAllPoints(button)
					end

					-- Hide Blizzard's default highlight and create our own custom golden overlay
					-- Use SetAlpha(0) to make them invisible even if Blizzard tries to show them
					if button.HighlightTexture then
						button.HighlightTexture:SetAlpha(0)
						button.HighlightTexture:Hide()
						button.HighlightTexture:SetScript("OnShow", function(self) self:Hide() end)
					end
					if button.PushedTexture then
						button.PushedTexture:SetAlpha(0)
						button.PushedTexture:Hide()
						button.PushedTexture:SetScript("OnShow", function(self) self:Hide() end)
					end
					if button.CheckedTexture then
						button.CheckedTexture:SetAlpha(0)
						button.CheckedTexture:Hide()
						button.CheckedTexture:SetScript("OnShow", function(self) self:Hide() end)
					end

					-- Create custom highlight overlay
					if not button._zBBG_customHighlight then
						button._zBBG_customHighlight = button:CreateTexture(nil, "OVERLAY")
						button._zBBG_customHighlight:SetColorTexture(1, 0.82, 0, 0.5) -- Golden at 50% opacity
						button._zBBG_customHighlight:Hide()         -- Hidden by default
					end

					-- Create custom checked state indicator for pet buttons (shows when abilities are active/toggled on)
					if baseName == "PetActionButton" then
						if not button._zBBG_customChecked then
							button._zBBG_customChecked = button:CreateTexture(nil, "OVERLAY", nil, 3)
							button._zBBG_customChecked:SetColorTexture(0, 1, 0, 0.3) -- Green at 30% opacity for active state
							button._zBBG_customChecked:Hide()   -- Hidden by default
						end
					end

					-- Create custom range indicator overlay (only if enabled)
					if zBarButtonBG.charSettings.showRangeIndicator then
						if not button._zBBG_rangeOverlay then
							button._zBBG_rangeOverlay = button:CreateTexture(nil, "OVERLAY", nil, 1)
							local c = zBarButtonBG.charSettings.rangeIndicatorColor
							button._zBBG_rangeOverlay:SetColorTexture(c.r, c.g, c.b, c.a)
							button._zBBG_rangeOverlay:Hide() -- Hidden by default
						end
					elseif button._zBBG_rangeOverlay then
						-- Range indicators disabled, hide and remove overlay
						button._zBBG_rangeOverlay:Hide()
						button._zBBG_rangeOverlay = nil
					end

				-- Create custom cooldown fade overlay (only if enabled and developer flag allows it)
				if zBarButtonBG.midnightCooldown and zBarButtonBG.charSettings.fadeCooldown then
					if not button._zBBG_cooldownOverlay then
						button._zBBG_cooldownOverlay = button:CreateTexture(nil, "OVERLAY", nil, 2)
						local c = zBarButtonBG.charSettings.cooldownColor
						button._zBBG_cooldownOverlay:SetColorTexture(c.r, c.g, c.b, c.a)
						button._zBBG_cooldownOverlay:Hide() -- Hidden by default
					end
				elseif button._zBBG_cooldownOverlay then
					-- Cooldown fade disabled, hide and remove overlay
					button._zBBG_cooldownOverlay:Hide()
					button._zBBG_cooldownOverlay = nil
				end					-- Position the highlight based on square/round mode
					local inset = 2
					button._zBBG_customHighlight:ClearAllPoints()
					if button._zBBG_rangeOverlay then
						button._zBBG_rangeOverlay:ClearAllPoints()
					end
					if button._zBBG_cooldownOverlay then
						button._zBBG_cooldownOverlay:ClearAllPoints()
					end
					if button._zBBG_customChecked then
						button._zBBG_customChecked:ClearAllPoints()
					end

					if zBarButtonBG.charSettings.squareButtons then
						-- Square mode: highlight inset by 2px, overlays fill entire button
						button._zBBG_customHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
						button._zBBG_customHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
						button._zBBG_customHighlight:SetTexCoord(0, 1, 0, 1)

						-- Range, cooldown, and checked overlays fill the entire button (no inset)
						if button._zBBG_rangeOverlay then
							button._zBBG_rangeOverlay:SetAllPoints(button.icon)
						end
						if button._zBBG_cooldownOverlay then
							button._zBBG_cooldownOverlay:SetAllPoints(button.icon)
						end
						if button._zBBG_customChecked then
							button._zBBG_customChecked:SetAllPoints(button.icon)
						end

						-- Remove masks for square mode
						if button._zBBG_customMask then
							removeMaskFromTexture(button._zBBG_customHighlight)
							if button._zBBG_rangeOverlay then
								removeMaskFromTexture(button._zBBG_rangeOverlay)
							end
							if button._zBBG_cooldownOverlay then
								removeMaskFromTexture(button._zBBG_cooldownOverlay)
							end
							if button._zBBG_customChecked then
								removeMaskFromTexture(button._zBBG_customChecked)
							end
						end
					else
						-- Round mode: use custom mask for rounded edges
						button._zBBG_customHighlight:SetAllPoints(button.icon)
						if button._zBBG_rangeOverlay then
							button._zBBG_rangeOverlay:SetAllPoints(button.icon)
						end
						if button._zBBG_cooldownOverlay then
							button._zBBG_cooldownOverlay:SetAllPoints(button.icon)
						end
						if button._zBBG_customChecked then
							button._zBBG_customChecked:SetAllPoints(button.icon)
						end

						if button._zBBG_customMask then
							-- Apply mask to highlight and overlays
							applyMaskToTexture(button._zBBG_customHighlight, button._zBBG_customMask)
							if button._zBBG_rangeOverlay then
								applyMaskToTexture(button._zBBG_rangeOverlay, button._zBBG_customMask)
							end
							if button._zBBG_cooldownOverlay then
								applyMaskToTexture(button._zBBG_cooldownOverlay, button._zBBG_customMask)
							end
							if button._zBBG_customChecked then
								applyMaskToTexture(button._zBBG_customChecked, button._zBBG_customMask)
							end
						end
					end

					-- Hook up hover and click events to show/hide custom highlight
					if not button._zBBG_highlightHooked then
						-- Mouse hover events
						button:HookScript("OnEnter", function(self)
							if self._zBBG_customHighlight and self:GetButtonState() ~= "PUSHED" then
								self._zBBG_customHighlight:Show()
							end
						end)
						button:HookScript("OnLeave", function(self)
							if self._zBBG_customHighlight and self:GetButtonState() ~= "PUSHED" then
								self._zBBG_customHighlight:Hide()
							end
						end)

						-- Mouse click events
						button:HookScript("OnMouseDown", function(self)
							if self._zBBG_customHighlight then
								self._zBBG_customHighlight:Show()
							end
						end)
						button:HookScript("OnMouseUp", function(self)
							if self._zBBG_customHighlight then
								-- Keep showing if mouse is still over button, hide otherwise
								-- Also hide if cursor is in a drag state (fixes stuck highlights during icon dragging)
								local cursorType = GetCursorInfo()
								if not self:IsMouseOver() or cursorType then
									self._zBBG_customHighlight:Hide()
								end
							end
						end)

						-- Hook SetButtonState to catch keybind presses
						hooksecurefunc(button, "SetButtonState", function(self, state)
							if self._zBBG_customHighlight then
								if state == "PUSHED" then
									self._zBBG_customHighlight:Show()
								elseif state == "NORMAL" and not self:IsMouseOver() then
									self._zBBG_customHighlight:Hide()
								end
							end
						end)

						button._zBBG_highlightHooked = true
					end

					-- Special handling for pet action buttons - hook checked state changes
					if baseName == "PetActionButton" and button._zBBG_customChecked and not button._zBBG_checkedHooked then
						-- Function to update the checked state overlay
						local function updateCheckedState(self)
							if self._zBBG_customChecked then
								if self:GetChecked() then
									self._zBBG_customChecked:Show()
								else
									self._zBBG_customChecked:Hide()
								end
							end
						end

						-- Hook the SetChecked function to catch state changes
						hooksecurefunc(button, "SetChecked", updateCheckedState)

						-- Also update state immediately in case it's already checked
						updateCheckedState(button)

						button._zBBG_checkedHooked = true
					end

					-- Replace the beveled SlotBackground with a flat texture if borders are enabled
					if button.SlotBackground then
						if zBarButtonBG.charSettings.showBorder then
							-- Use a flat white texture we can make transparent
							button.SlotBackground:SetTexture("Interface/Buttons/WHITE8X8")
							button.SlotBackground:SetVertexColor(0, 0, 0, 0)
							button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
							-- Make SlotBackground 2px smaller on all sides to prevent clipping borders
							button.SlotBackground:ClearAllPoints()
							button.SlotBackground:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
							button.SlotBackground:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
						else
							-- Keep the default texture when borders are off
							button.SlotBackground:SetTexture(nil)
							button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
							button.SlotBackground:ClearAllPoints()
							button.SlotBackground:SetAllPoints(button)
						end

						-- Apply appropriate mask to clip the SlotBackground
						if not button._zBBG_customMask then
							button._zBBG_customMask = button:CreateMaskTexture()
							button._zBBG_customMask:SetTexture(getMaskPath())
							button._zBBG_customMask:SetAllPoints(button)
						end
						applyMaskToTexture(button.SlotBackground, button._zBBG_customMask)
					end

					-- Hide those annoying spell cast animations
					if button.SpellCastAnimFrame then
						button.SpellCastAnimFrame:SetScript("OnShow", function(self) self:Hide() end)
					end
					if button.InterruptDisplay then
						button.InterruptDisplay:SetScript("OnShow", function(self) self:Hide() end)
					end

					-- Create the outer background frame that extends 5px past the button edges (if enabled)
					local outerFrame, outerBg
					if zBarButtonBG.charSettings.showBackdrop then
						outerFrame = CreateFrame("Frame", nil, button)
						applyBackdropPositioning(outerFrame, button)
						outerFrame:SetFrameLevel(0)
						outerFrame:SetFrameStrata("BACKGROUND")

						-- Fill it with black (or class color if that's enabled)
						outerBg = outerFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
						outerBg:SetAllPoints(outerFrame)
						outerBg:SetColorTexture(outerColor.r, outerColor.g, outerColor.b, outerColor.a)
					end

					-- Create the inner background that sits right behind the button (if enabled)
					local bgFrame, bg
					if zBarButtonBG.charSettings.showSlotBackground then
						bgFrame = CreateFrame("Frame", nil, button)
						bgFrame:SetAllPoints(button)
						bgFrame:SetFrameLevel(0)
						bgFrame:SetFrameStrata("BACKGROUND")

						-- Fill it with dark grey (or class color)
						bg = bgFrame:CreateTexture(nil, "BACKGROUND", nil, -7)
						bg:SetAllPoints(bgFrame)
						bg:SetColorTexture(innerColor.r, innerColor.g, innerColor.b, innerColor.a)

						-- Apply appropriate mask to inner background
						if not button._zBBG_customMask then
							button._zBBG_customMask = button:CreateMaskTexture()
							button._zBBG_customMask:SetTexture(getMaskPath())
							button._zBBG_customMask:SetAllPoints(button)
						end
						applyMaskToTexture(bg, button._zBBG_customMask)
					end

					-- Create the border if that option is turned on
					local borderFrame, customBorderTexture
					if zBarButtonBG.charSettings.showBorder and button.icon and button:IsShown() then
						-- Create a frame to hold the custom border texture
						borderFrame = CreateFrame("Frame", nil, button)
						borderFrame:SetAllPoints(button)
						borderFrame:SetFrameLevel(button:GetFrameLevel() + 1)

						-- Create the border texture with appropriate asset for current mode
						customBorderTexture = borderFrame:CreateTexture(nil, "OVERLAY")
						customBorderTexture:SetTexture(getBorderPath())
						customBorderTexture:SetAllPoints(borderFrame)
						-- Use ADD blend mode which treats black as transparent
						customBorderTexture:SetBlendMode("ADD")

						-- Use color picker's alpha for overall border transparency (ADD mode handles black=transparent)
						customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
					end

					-- Apply custom fonts to button text elements using helper
					applyAllTextStyling(button)

					-- Store references to everything we created so we can update or remove it later
					zBarButtonBG.frames[buttonName] = {
						outerFrame = outerFrame,
						outerBg = outerBg,
						frame = bgFrame,
						bg = bg,
						borderFrame = borderFrame,
						customBorderTexture = customBorderTexture,
						button = button
					}

					-- Apply text positioning after button data is stored using helper
					applyTextPositioning(button)

					-- Make sure the mask stays removed
					if button.icon and button.IconMask then
						button.icon:RemoveMaskTexture(button.IconMask)
					end
				else
					-- Button already has backgrounds, just update them with current settings
					local data = zBarButtonBG.frames[buttonName]

					-- Handle NormalTexture - always keep it transparent
					updateButtonNormalTexture(button)

					-- Update icon mask when switching modes
					if button.icon then
						-- Remove old mask completely from ALL elements
						if button._zBBG_customMask then
							-- Use helper removal to safely clear any masks we applied
							removeMaskFromTexture(button.icon)
							removeMaskFromTexture(button.SlotBackground)
							removeMaskFromTexture(data.bg)
							removeMaskFromTexture(button._zBBG_customHighlight)
							removeMaskFromTexture(button._zBBG_rangeOverlay)
							removeMaskFromTexture(button._zBBG_cooldownOverlay)
							-- Destroy the old mask to force texture reload
							button._zBBG_customMask = nil
						end

						-- Update icon scale and texcoords based on mode
						button.icon:SetScale(1.0)
						button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						--[[
							if zBarButtonBG.charSettings.squareButtons then
							-- Square mode: normal scale
							button.icon:SetScale(1.0)
							button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						else
							-- Round mode: zoom in slightly
							button.icon:SetScale(1.05)
							button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
						end
						]] --

						-- Create new mask with correct texture for current mode
						button._zBBG_customMask = button:CreateMaskTexture()
						button._zBBG_customMask:SetTexture(getMaskPath())
						button._zBBG_customMask:SetAllPoints(button)

						-- Apply new mask to all elements (use helpers to avoid duplicate adds)
						applyMaskToTexture(button.icon, button._zBBG_customMask)
						if button.SlotBackground then
							applyMaskToTexture(button.SlotBackground, button._zBBG_customMask)
						end
						if data.bg then
							applyMaskToTexture(data.bg, button._zBBG_customMask)
						end
					end

					-- Update custom highlight positioning based on current mode
					if button._zBBG_customHighlight then
						local inset = 2
						button._zBBG_customHighlight:ClearAllPoints()
						if zBarButtonBG.charSettings.squareButtons then
							-- Square mode: inset by 2px
							button._zBBG_customHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button._zBBG_customHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button._zBBG_customHighlight:SetTexCoord(0, 1, 0, 1)
						else
							-- Round mode: use custom mask
							button._zBBG_customHighlight:SetAllPoints(button.icon)
							if button._zBBG_customMask then
								applyMaskToTexture(button._zBBG_customHighlight, button._zBBG_customMask)
							end
						end
					end

					-- Update range and cooldown overlays positioning
					if button._zBBG_rangeOverlay then
						button._zBBG_rangeOverlay:ClearAllPoints()
						button._zBBG_rangeOverlay:SetAllPoints(button.icon)

						if zBarButtonBG.charSettings.squareButtons then
							-- Square mode: remove any mask we previously applied
							removeMaskFromTexture(button._zBBG_rangeOverlay)
						else
							-- Round mode: apply mask
							if button._zBBG_customMask then
								applyMaskToTexture(button._zBBG_rangeOverlay, button._zBBG_customMask)
							end
						end
					end

					if button._zBBG_cooldownOverlay then
						button._zBBG_cooldownOverlay:ClearAllPoints()
						button._zBBG_cooldownOverlay:SetAllPoints(button.icon)

						if zBarButtonBG.charSettings.squareButtons then
							-- Square mode: remove any mask we previously applied
							removeMaskFromTexture(button._zBBG_cooldownOverlay)
						else
							-- Round mode: apply mask
							if button._zBBG_customMask then
								applyMaskToTexture(button._zBBG_cooldownOverlay, button._zBBG_customMask)
							end
						end
					end

					-- Update the SlotBackground based on whether borders are on or off
					if button.SlotBackground then
						if zBarButtonBG.charSettings.showBorder then
							-- Flat texture when borders are enabled
							button.SlotBackground:SetTexture("Interface/Buttons/WHITE8X8")
							button.SlotBackground:SetVertexColor(0, 0, 0, 0)
							button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
						else
							-- Put the default texture back when borders are off
							button.SlotBackground:SetTexture(nil)
							button.SlotBackground:SetVertexColor(1, 1, 1, 1)
							button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
						end
					end

					-- Make sure our background frames are visible (or hidden if disabled)
					if data.outerFrame then
						if zBarButtonBG.charSettings.showBackdrop then
							data.outerFrame:Show()
							-- Update backdrop positioning in case adjustments changed
							applyBackdropPositioning(data.outerFrame, button)
						else
							data.outerFrame:Hide()
						end
					end
					if data.frame then
						if zBarButtonBG.charSettings.showSlotBackground then
							data.frame:Show()
						else
							data.frame:Hide()
						end
					end

					-- Update the colors (might have changed in settings or toggled class colors)
					-- Use colors already calculated at function start

					if data.outerBg then
						data.outerBg:SetColorTexture(outerColor.r, outerColor.g, outerColor.b, outerColor.a)
					end
					if data.bg then
						data.bg:SetColorTexture(innerColor.r, innerColor.g, innerColor.b, innerColor.a)
					end

					-- Update fonts in case they changed using helper
					applyAllTextStyling(button)

					-- Handle border updates
					if zBarButtonBG.charSettings.showBorder and button.icon then
						-- Use border color already calculated at function start

						if not data.customBorderTexture then
							-- Border wasn't created initially, make it now
							if not data.borderFrame then
								data.borderFrame = CreateFrame("Frame", nil, button)
								data.borderFrame:SetAllPoints(button)
								data.borderFrame:SetFrameLevel(button:GetFrameLevel() + 1)
							end

							data.customBorderTexture = data.borderFrame:CreateTexture(nil, "OVERLAY")
							data.customBorderTexture:SetAllPoints(data.borderFrame)
							data.customBorderTexture:SetBlendMode("ADD")

							data.customBorderTexture:SetTexture(getBorderPath())
							data.customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b,
								borderColor.a)
						else
							-- Border exists, update texture for current mode
							data.borderFrame:Show()

							data.customBorderTexture:SetTexture(getBorderPath())
							data.customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b,
								borderColor.a)
						end
					else
						-- Borders are disabled, hide them if they exist
						if data.borderFrame then
							data.borderFrame:Hide()
						end
					end
				end
			end
		end
	end

	-- Hook into action bar stuff so we know when buttons change
	if not zBarButtonBG.hookInstalled then
		-- Listen for the important action bar changes - no more spam than we need
		local updateFrame = CreateFrame("Frame")
		updateFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
		updateFrame:RegisterEvent("UPDATE_BINDINGS")
		updateFrame:RegisterEvent("CURSOR_CHANGED")
		-- These fire when mounting/dismounting messes with the action bars
		updateFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
		updateFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
		updateFrame:SetScript("OnEvent", function(self, event)
			if zBarButtonBG.enabled then
				if event == "CURSOR_CHANGED" then
					-- Clear stuck highlights when dragging stuff around
					local cursorType = GetCursorInfo()
					if cursorType then -- Cursor picked something up
						for buttonName, data in pairs(zBarButtonBG.frames) do
							if data and data.button and data.button._zBBG_customHighlight then
								data.button._zBBG_customHighlight:Hide()
							end
						end
					end
				elseif event == "ACTIONBAR_PAGE_CHANGED" or event == "ACTIONBAR_SLOT_CHANGED" or event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
					-- Action bars changed - need to update our range overlays since buttons might have different spells now
					if zBarButtonBG._debug then
						zBarButtonBG.print("Action bar changed (" .. event .. ") - fixing up range overlays")
					end
					if event == "ACTIONBAR_PAGE_CHANGED" or event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
						-- Page changes and mounting need a full rebuild
						zBarButtonBG.createActionBarBackgrounds()
					end
					-- Update range overlays since buttons probably have different actions now
					for buttonName, data in pairs(zBarButtonBG.frames) do
						if data and data.button and data.button._zBBG_rangeOverlay then
							zBarButtonBG.updateRangeOverlay(data.button)
						end
					end
				else
					-- Just keybinding changes, rebuild everything
					zBarButtonBG.createActionBarBackgrounds()
				end
			end
		end)

		-- Hook the button update functions so we can mess with NormalTexture
		-- Keep it invisible when we want square buttons, or color it when we need borders
		local function manageNormalTexture(button)
			if button and button.NormalTexture and button._zBBG_styled and zBarButtonBG.enabled then
				if zBarButtonBG.charSettings.squareButtons then
					-- Square buttons: make it fully transparent
					button.NormalTexture:SetAlpha(0)
				elseif zBarButtonBG.charSettings.showBorder then
					-- Round buttons with borders: make visible and color it
					button.NormalTexture:Show()
					button.NormalTexture:SetAlpha(1)
					button.NormalTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
				else
					-- Round buttons without borders: make it transparent
					button.NormalTexture:SetAlpha(0)
				end
			end
		end

		-- Hook the range indicator function - this runs whenever WoW checks range
		hooksecurefunc("ActionButton_UpdateRangeIndicator", manageNormalTexture)

		-- Piggyback on WoW's range checking instead of doing our own
		hooksecurefunc("ActionButton_UpdateRangeIndicator", function(button)
			if button and button._zBBG_styled and zBarButtonBG.enabled then
				-- Debug spam to see what's happening
				if zBarButtonBG._debug then
					local buttonName = button:GetName() or "Unknown"
					local hasTarget = UnitExists("target")
					local action = button.action
					local inRange = action and IsActionInRange(action, "target")
					zBarButtonBG.print("Range update for " ..
						buttonName ..
						" - Target: " ..
						tostring(hasTarget) .. ", Action: " .. tostring(action) .. ", InRange: " .. tostring(inRange))
				end
				zBarButtonBG.updateRangeOverlay(button)
			end
		end)

		-- Hook cooldown updates so we can show/hide our fade overlay
		hooksecurefunc("ActionButton_UpdateCooldown", function(button)
			if button and button._zBBG_cooldownOverlay and button._zBBG_styled and zBarButtonBG.enabled then
				zBarButtonBG.updateCooldownOverlay(button)
			end
		end)

		-- Also catch the general cooldown frame stuff
		hooksecurefunc("CooldownFrame_Set", function(cooldown, start, duration, enable, forceShowDrawEdge, modRate)
			if cooldown and cooldown:GetParent() and cooldown:GetParent()._zBBG_styled and zBarButtonBG.enabled then
				zBarButtonBG.updateCooldownOverlay(cooldown:GetParent())
			end
		end)

		-- Hook usability updates - way better than spamming events everywhere
		-- WoW calls this when stuff like mana or range changes
		if ActionButton_UpdateUsable then
			hooksecurefunc("ActionButton_UpdateUsable", function(button)
				if button and button._zBBG_styled and zBarButtonBG.enabled then
					-- Fix range overlay when usability changes
					if button._zBBG_rangeOverlay then
						zBarButtonBG.updateRangeOverlay(button)
					end
					-- Keep normal texture in line
					manageNormalTexture(button)
				end
			end)
		end

		-- Hook main action updates - catches when buttons get new spells (like mounting)
		if ActionButton_Update then
			hooksecurefunc("ActionButton_Update", function(button)
				if button and button._zBBG_styled and zBarButtonBG.enabled then
					-- Update range overlay since the action probably changed
					if button._zBBG_rangeOverlay then
						zBarButtonBG.updateRangeOverlay(button)
					end
					-- Fix normal texture too
					manageNormalTexture(button)
				end
			end)
		end

		-- Hook state updates for better highlight management
		if ActionButton_UpdateState then
			hooksecurefunc("ActionButton_UpdateState", function(button)
				if button and button._zBBG_styled and zBarButtonBG.enabled then
					manageNormalTexture(button)
				end
			end)
		end

		-- Hook the main action button update function to catch page changes
		-- This should be called whenever a button's action changes
		if ActionButton_OnEvent then
			hooksecurefunc("ActionButton_OnEvent", function(button, event, ...)
				if button and button._zBBG_styled and zBarButtonBG.enabled then
					if event == "ACTIONBAR_SLOT_CHANGED" or event == "UPDATE_BINDINGS" then
						-- Update range when the button's action or bindings change
						if button._zBBG_rangeOverlay then
							zBarButtonBG.updateRangeOverlay(button)
						end
						manageNormalTexture(button)
					end
				end
			end)
		end

		zBarButtonBG.hookInstalled = true
	end
end

-- ############################################################
-- Cooldown Overlay Update Function
-- ############################################################
function zBarButtonBG.updateCooldownOverlay(button)
	if not button or not button._zBBG_cooldownOverlay or not button._zBBG_styled or not zBarButtonBG.enabled then
		return
	end

	if not zBarButtonBG.charSettings.fadeCooldown or not button.cooldown then
		button._zBBG_cooldownOverlay:Hide()
		return
	end

	-- To test midnight remove FROM HERE
	local start, duration = button.cooldown:GetCooldownTimes()
	if start and duration and start > 0 and duration > 0 then
		-- Convert to seconds for easier comparison (GetCooldownTimes returns milliseconds)
		local durationSec = duration / 1000

		-- Get GCD duration in seconds
		local gcdDuration = 0
		if C_Spell and C_Spell.GetSpellCooldown then
			-- Use new API
			local gcdInfo = C_Spell.GetSpellCooldown(61304)
			if gcdInfo and gcdInfo.duration then
				gcdDuration = gcdInfo.duration
			end
		elseif GetSpellCooldown then
			-- Fallback to old API
			local gcdStart, gcdDur = GetSpellCooldown(61304)
			gcdDuration = gcdDur or 0
		end

	-- TO HERE

	-- The below is the Midnight API test block to replace above
	--[[
	-- Get cooldown info using the new C_ActionBar API
	local action = button.action
	if not action or action == 0 then
		button._zBBG_cooldownOverlay:Hide()
		return
	end

	local cooldownInfo = C_ActionBar.GetActionCooldown(action)
	if cooldownInfo and cooldownInfo.startTime and cooldownInfo.duration and cooldownInfo.duration > 0 then
		-- C_ActionBar.GetActionCooldown returns seconds directly (not milliseconds)
		local durationSec = cooldownInfo.duration

		-- Get GCD duration using C_Spell API
		local gcdDuration = 0
		if C_Spell and C_Spell.GetSpellCooldown then
			local gcdInfo = C_Spell.GetSpellCooldown(61304)
			if gcdInfo and gcdInfo.duration then
				gcdDuration = gcdInfo.duration
			end
		end
		--]]

		
		-- Check if this looks like GCD by duration comparison
		-- GCD is typically 1.0-1.5 seconds, so if duration is close to that range and matches GCD, hide it
		if gcdDuration > 0 and durationSec > 0.8 and durationSec < 2.0 then
			-- This could be GCD - check if duration is very close to GCD duration
			if math.abs(durationSec - gcdDuration) < 0.05 then -- 50ms tolerance
				-- Duration matches GCD closely - hide overlay (just GCD)
				button._zBBG_cooldownOverlay:Hide()
			else
				-- Duration doesn't match GCD - show overlay (real cooldown)
				button._zBBG_cooldownOverlay:Show()
			end
		else
			-- Duration is outside GCD range or no GCD detected - show overlay
			button._zBBG_cooldownOverlay:Show()
		end
	else
		-- Not on cooldown - hide overlay
		button._zBBG_cooldownOverlay:Hide()
	end
end

-- ############################################################
-- Range Overlay Update Function
-- ############################################################
function zBarButtonBG.updateRangeOverlay(button)
	if not button or not button._zBBG_rangeOverlay or not button._zBBG_styled or not zBarButtonBG.enabled then
		return
	end

	if not zBarButtonBG.charSettings.showRangeIndicator then
		button._zBBG_rangeOverlay:Hide()
		return
	end

	-- Check if we have a valid target first
	if not UnitExists("target") then
		button._zBBG_rangeOverlay:Hide()
		return
	end

	local inRange = nil

	-- Get the action from the button - this is key!
	local action = button.action
	if action and action > 0 then
		-- Regular action buttons - use WoW's native range checking
		inRange = IsActionInRange(action, "target")

		if zBarButtonBG._debug then
			local actionType, id = GetActionInfo(action)
			zBarButtonBG.print("Button: " ..
				(button:GetName() or "Unknown") ..
				", Action: " ..
				action ..
				", Type: " .. tostring(actionType) .. ", ID: " .. tostring(id) .. ", InRange: " .. tostring(inRange))
		end
	elseif button.GetAction then
		-- Try to get action from the button (some addon buttons)
		action = button:GetAction()
		if action and action > 0 then
			inRange = IsActionInRange(action, "target")
		end
	elseif button.spellID then
		-- Direct spell buttons
		if IsSpellInRange then
			inRange = IsSpellInRange(button.spellID, "target")
		end
	end

	-- IsActionInRange returns: true = in range, false = out of range, nil = no target/not applicable
	if inRange == false then
		-- Out of range - show overlay
		button._zBBG_rangeOverlay:Show()
		if zBarButtonBG._debug then
			zBarButtonBG.print("Showing range overlay for " .. (button:GetName() or "Unknown"))
		end
	else
		-- In range or no valid range check - hide overlay
		button._zBBG_rangeOverlay:Hide()
		if zBarButtonBG._debug and inRange == true then
			zBarButtonBG.print("Hiding range overlay for " .. (button:GetName() or "Unknown") .. " (in range)")
		end
	end
end

-- Debug command to test the new efficient hooking
SLASH_ZBBGDEBUG1 = "/zbbg"
SlashCmdList["ZBBGDEBUG"] = function(msg)
	if msg == "debug" then
		zBarButtonBG._debug = not zBarButtonBG._debug
		zBarButtonBG.print("Debug mode " .. (zBarButtonBG._debug and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
	elseif msg == "hooks" then
		zBarButtonBG.print("Hook status: " ..
			(zBarButtonBG.hookInstalled and "|cFF00FF00installed|r" or "|cFFFF0000not installed|r"))
		local count = 0
		for _ in pairs(zBarButtonBG.frames) do count = count + 1 end
		zBarButtonBG.print("Styled buttons: " .. count)
	elseif msg == "range" then
		local button = ActionButton1
		if button and button._zBBG_styled then
			zBarButtonBG.print("Testing range on ActionButton1...")
			local hasTarget = UnitExists("target")
			local action = button.action
			local inRange = action and IsActionInRange(action, "target")
			zBarButtonBG.print("Target exists: " ..
				tostring(hasTarget) .. ", Action: " .. tostring(action) .. ", InRange: " .. tostring(inRange))

			if button._zBBG_rangeOverlay then
				local points = button._zBBG_rangeOverlay:GetNumPoints()
				local alpha = button._zBBG_rangeOverlay:GetAlpha()
				local shown = button._zBBG_rangeOverlay:IsShown()
				zBarButtonBG.print("Overlay - Points: " ..
					points .. ", Alpha: " .. alpha .. ", Shown: " .. tostring(shown))

				-- Force update
				zBarButtonBG.updateRangeOverlay(button)
				zBarButtonBG.print("After update - Shown: " .. tostring(button._zBBG_rangeOverlay:IsShown()))
			else
				zBarButtonBG.print("Range overlay not created!")
			end
		else
			zBarButtonBG.print("ActionButton1 not styled or not found")
		end
	elseif msg == "cooldown" then
		local button = ActionButton1
		if button and button._zBBG_styled then
			zBarButtonBG.print("Testing cooldown on ActionButton1...")
			zBarButtonBG.updateCooldownOverlay(button)
			zBarButtonBG.print("Cooldown overlay: " ..
				(button._zBBG_cooldownOverlay and (button._zBBG_cooldownOverlay:IsShown() and "shown" or "hidden") or "not created"))
		else
			zBarButtonBG.print("ActionButton1 not styled or not found")
		end
	else
		zBarButtonBG.print("Usage: /zbbg debug|hooks|range|cooldown|reload")
	end
end

-- Turn off our backgrounds and put everything back to normal
function zBarButtonBG.removeActionBarBackgrounds()
	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data then
			-- Remove our styling flag so the button goes back to normal
			if data.button then
				data.button._zBBG_styled = nil
			end

			-- Hide our background stuff
			if data.outerFrame then
				data.outerFrame:Hide()
			end
			if data.frame then
				data.frame:Hide()
			end
			-- Get rid of border frame too
			if data.borderFrame then data.borderFrame:Hide() end

			-- Put the normal border back how it was
			if data.button and data.button.NormalTexture then
				data.button.NormalTexture:SetAlpha(1)
				data.button.NormalTexture:Show()
			end

			-- Fix the slot background back to normal
			if data.button and data.button.SlotBackground then
				data.button.SlotBackground:SetTexture(nil)
				data.button.SlotBackground:SetVertexColor(1, 1, 1, 1)
				data.button.SlotBackground:SetDrawLayer("BACKGROUND", 0)
				-- Undo our custom masking
				if data.button._zBBG_customMask then
					removeMaskFromTexture(data.button.SlotBackground)
				end
			end

			-- Fix mask on inner background too
			if data.bg and data.button and data.button._zBBG_customMask then
				removeMaskFromTexture(data.bg)
			end

			-- Fix highlight mask too
			if data.button and data.button._zBBG_customHighlight and data.button._zBBG_customMask then
				removeMaskFromTexture(data.button._zBBG_customHighlight)
			end

			-- Put icon back to normal size
			if data.button and data.button.icon then
				data.button.icon:SetScale(1.0)
				data.button.icon:SetTexCoord(0, 1, 0, 1)
				-- Undo our mask and put Blizzard's back
				if data.button._zBBG_customMask then
					removeMaskFromTexture(data.button.icon)
					-- Nuke the mask so it gets made fresh next time
					data.button._zBBG_customMask = nil
				end
				if data.button.IconMask then
					-- Reapply Blizzard's icon mask directly (not tracked by our helpers)
					data.button.icon:AddMaskTexture(data.button.IconMask)
				end
			end

			-- Remove custom highlight and overlays, restore Blizzard's default overlays
			if data.button then
				if data.button._zBBG_customHighlight then
					data.button._zBBG_customHighlight:Hide()
				end
				if data.button._zBBG_customChecked then
					data.button._zBBG_customChecked:Hide()
				end
				-- Restore default overlay textures (highlight, pushed, checked, flash)
				local overlays = {
					data.button.HighlightTexture,
					data.button.PushedTexture,
					data.button.CheckedTexture,
					data.button.Flash
				}
				for _, overlay in ipairs(overlays) do
					if overlay then
						overlay:SetTexCoord(0, 1, 0, 1)
						overlay:ClearAllPoints()
						overlay:SetAlpha(1)
					end
				end
			end
		end
	end

	-- CRITICAL: Clear the frames table so next createActionBarBackgrounds() starts fresh
	wipe(zBarButtonBG.frames)
end

-- Slash command now handled in InitializeOptions() function
