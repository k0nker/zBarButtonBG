-- zBarButtonBG - Action bar button background customization addon

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

-- Initialize global namespace
zBarButtonBG = {}

-- Get module references
local Init = addonTable.Core.Init
local Overlays = addonTable.Core.Overlays
local Constants = addonTable.Core.Constants
local Utilities = addonTable.Core.Utilities
local Styling = addonTable.Core.Styling
local ProfileManager = addonTable.Profile.Manager
local ButtonStyles = addonTable.Core.ButtonStyles

-- Re-export commonly used functions to global zBarButtonBG namespace for backward compatibility
zBarButtonBG.print = Utilities.print
zBarButtonBG.updateCooldownOverlay = Overlays.updateCooldownOverlay
zBarButtonBG.updateRangeOverlay = Overlays.updateRangeOverlay
zBarButtonBG.ButtonStyles = ButtonStyles

-- Developer toggle for cooldown overlay feature
zBarButtonBG.midnightCooldown = Constants.MIDNIGHT_COOLDOWN

-- Track whether we're enabled and store our custom frames
zBarButtonBG.enabled = false
zBarButtonBG.frames = {}

-- Organize buttons into groups by their bar
-- Format: buttonName -> barName (e.g., "ActionButton5" -> "ActionButton")
zBarButtonBG.buttonGroups = {}

-- Create the Ace addon instance FIRST so we can attach methods to it
zBarButtonBGAce = LibStub("AceAddon-3.0"):NewAddon("zBarButtonBG")

-- Set up Ace addon with proper lifecycle methods
function zBarButtonBGAce:OnInitialize()
	-- Initialize AceDB with profile support
	self.db = LibStub("AceDB-3.0"):New("zBarButtonBGDB", addonTable.Core.Defaults, true)

	-- Make Ace the single source of truth - native system points to Ace profile
	zBarButtonBG.charSettings = self.db.profile
end

function zBarButtonBGAce:OnEnable()
	-- Register slash commands when enabled
	Init.registerCommands()

	-- Initialize options UI
	C_Timer.After(0.1, function()
		if self and type(self.InitializeOptions) == "function" then
			self:InitializeOptions()
		end
	end)
end

-- ############################################################
-- Profile management methods (attached to zBarButtonBGAce)
-- ############################################################

-- Create a new profile
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

-- Switch to an existing profile
function zBarButtonBGAce:SwitchProfile(profileName)
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

-- Copy profile data from one profile to another
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

-- Delete a profile
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
	end

	-- Delete the profile
	self.db:DeleteProfile(profileName)

	-- Update the action bars
	if zBarButtonBG.enabled then
		zBarButtonBG.removeActionBarBackgrounds()
		zBarButtonBG.createActionBarBackgrounds()
	end

	return true, "Profile deleted successfully"
end

-- ############################################################
-- Setting retrieval with per-bar profile support
-- ############################################################

-- Main helper: Get a setting value for a specific bar
-- Checks if bar has a different profile assigned, otherwise uses global profile
function zBarButtonBG.GetSettingInfo(barName, settingName)
	-- Start with the global profile
	local profileToUse = zBarButtonBGAce.db:GetCurrentProfile()
	
	-- Check if this bar has been set to use a different profile
	if zBarButtonBGAce.db.char and zBarButtonBGAce.db.char.barSettings and zBarButtonBGAce.db.char.barSettings[barName] then
		local barSetting = zBarButtonBGAce.db.char.barSettings[barName]
		if barSetting.differentProfile then
			-- This bar uses a custom profile
			profileToUse = barSetting.profileName
		end
	end
	
	-- Get the profile object
	local profile = zBarButtonBGAce.db.profiles[profileToUse]
	
	-- If profile doesn't exist, fall back to current profile
	if not profile then
		profile = zBarButtonBGAce.db.profile
	end
	
	-- Get the setting from the profile
	local value = profile[settingName]
	
	-- If setting is nil, fall back to defaults
	if value == nil then
		value = addonTable.Core.Defaults.profile[settingName]
	end
	
	return value
end

-- Helper: Extract bar base name from button name
-- e.g. "ActionButton5" -> "ActionButton", "MultiBarBottomLeftButton3" -> "MultiBarBottomLeftButton"
function zBarButtonBG.GetBarNameFromButton(buttonName)
	if not buttonName then return nil end
	
	local barBases = {
		"ActionButton",
		"MultiBarBottomLeftButton",
		"MultiBarBottomRightButton",
		"MultiBarRightButton",
		"MultiBarLeftButton",
		"MultiBar5Button",
		"MultiBar6Button",
		"MultiBar7Button",
		"PetActionButton",
		"StanceButton",
	}
	
	for _, baseName in ipairs(barBases) do
		if buttonName:sub(1, #baseName) == baseName then
			return baseName
		end
	end
	
	return nil
end

-- ############################################################
-- Command and toggle functions
-- ############################################################

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

	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data and data.button then
			-- Get per-bar settings for this button
			local barName = zBarButtonBG.buttonGroups[buttonName]
			local outerColor = Utilities.getColorTable("outerColor", "useClassColorOuter", barName)
			local innerColor = Utilities.getColorTable("innerColor", "useClassColorInner", barName)
			local borderColor = Utilities.getColorTable("borderColor", "useClassColorBorder", barName)
			local rangeColor = zBarButtonBG.GetSettingInfo(barName, "rangeIndicatorColor")
			local cooldownColor = zBarButtonBG.GetSettingInfo(barName, "cooldownColor")
			local showBorder = zBarButtonBG.GetSettingInfo(barName, "showBorder")

			-- Update outer background color
			if data.outerBg then
				data.outerBg:SetColorTexture(outerColor.r, outerColor.g, outerColor.b, outerColor.a)
			end

			-- Update inner background color
			if data.bg then
				data.bg:SetColorTexture(innerColor.r, innerColor.g, innerColor.b, innerColor.a)
			end

			-- Update border color
			if showBorder and data.customBorderTexture then
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

-- Update fonts on existing buttons without rebuilding everything
function zBarButtonBG.updateFonts()
	if not zBarButtonBG.enabled then return end

	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data and data.button then
			local barName = zBarButtonBG.buttonGroups[buttonName]
			Styling.applyAllTextStyling(data.button, barName)
		end
	end
end

-- ############################################################
-- Load settings when we log in
-- ############################################################
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		-- If we had this enabled before, turn it back on after a short delay
		if zBarButtonBG.charSettings.enabled then
			zBarButtonBG.enabled = true
			C_Timer.After(3.5, function()
				zBarButtonBG.createActionBarBackgrounds()
			end)
		end
	end
end)

-- ############################################################
-- ACTION BAR BACKGROUNDS
-- ############################################################
-- Local aliases for module functions to work within this file
local applyMaskToTexture = Utilities.applyMaskToTexture
local removeMaskFromTexture = Utilities.removeMaskFromTexture
local applyMaskToSet = Utilities.applyMaskToSet
local removeMaskFromSet = Utilities.removeMaskFromSet
local getMaskPath = Utilities.getMaskPath
local getBorderPath = Utilities.getBorderPath
local getHighlightPath = Utilities.getHighlightPath
local getColorTable = Utilities.getColorTable
local getFontPath = Utilities.getFontPath
local ClearSetPoint = Utilities.ClearSetPoint
local updateButtonNormalTexture = Styling.updateButtonNormalTexture
local applyAllTextStyling = Styling.applyAllTextStyling
local applyBackdropPositioning = Styling.applyBackdropPositioning
local applyTextPositioning = Styling.applyTextPositioning

-- Initialize all button regions from metadata
local function initializeButtonRegions(button)
	ButtonStyles.InitializeButton(button)
end

-- Create and apply button mask efficiently
local function createAndApplyMask(button, maskTexture)
	if not button then return end
	if not button._zBBG_customMask then
		button._zBBG_customMask = button:CreateMaskTexture()
	end
	button._zBBG_customMask:SetTexture(maskTexture)
	button._zBBG_customMask:SetAllPoints(button)
	
	-- Apply mask to all maskable elements
	if button.icon then
		applyMaskToTexture(button.icon, button._zBBG_customMask)
	end
	if button.SlotBackground then
		applyMaskToTexture(button.SlotBackground, button._zBBG_customMask)
	end
	return button._zBBG_customMask
end

-- Create a background layer frame with texture and optional mask
-- Consolidates the duplicated background creation logic
local function createBackgroundLayer(button, colorData, drawLayer, drawOrder)
	local bgFrame = CreateFrame("Frame", nil, button)
	bgFrame:SetAllPoints(button)
	bgFrame:SetFrameLevel(0)
	bgFrame:SetFrameStrata("BACKGROUND")

	local bgTexture = bgFrame:CreateTexture(nil, "BACKGROUND", nil, drawOrder)
	bgTexture:SetAllPoints(bgFrame)
	bgTexture:SetColorTexture(colorData.r, colorData.g, colorData.b, colorData.a)

	return { frame = bgFrame, texture = bgTexture }
end

-- Recreate and reapply mask when button style changes
local function updateButtonMask(button, maskTexture, ...)
	if not button or not button._zBBG_customMask then return end
	
	-- Remove old masks from all maskable textures
	removeMaskFromSet(button.icon, button.SlotBackground, ...)
	
	-- Destroy and recreate mask with new texture
	button._zBBG_customMask = button:CreateMaskTexture()
	button._zBBG_customMask:SetTexture(maskTexture)
	button._zBBG_customMask:SetAllPoints(button)
	
	-- Reapply mask to all maskable elements
	applyMaskToSet(button._zBBG_customMask, button.icon, button.SlotBackground, ...)
	
	-- Update cooldown swipe texture when button style changes
	if button.cooldown then
		local buttonName = button:GetName()
		local barName = zBarButtonBG.buttonGroups[buttonName]
		local swipeMaskPath = ButtonStyles.GetSwipeMaskPath(barName)
		if swipeMaskPath then
			button.cooldown:SetSwipeTexture(swipeMaskPath, 1, 1, 1, 0.8)
		end
	end
end

function zBarButtonBG.removeActionBarBackgrounds()
	-- Hide and destroy all our custom frames and clean up button masks
	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data then
			if data.button then
				-- Clean up the mask texture so it gets reapplied with the new setting
				if data.button._zBBG_customMask then
					removeMaskFromTexture(data.button.icon)
					data.button._zBBG_customMask = nil
				end
				-- Clear the styled flag so button gets reprocessed
				data.button._zBBG_styled = false
			end
			if data.outerFrame then
				data.outerFrame:Hide()
			end
			if data.frame then
				data.frame:Hide()
			end
			if data.borderFrame then
				data.borderFrame:Hide()
			end
		end
	end

	-- Clear the frames table but keep button tracking
	zBarButtonBG.frames = {}
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
				-- Register this button to its bar group
				zBarButtonBG.buttonGroups[buttonName] = baseName

				-- Check if we've already set this button up
				if not zBarButtonBG.frames[buttonName] then
					-- Mark this button as having our custom styling applied
					button._zBBG_styled = true

					-- Process all button regions in one pass using consolidated helper
					initializeButtonRegions(button)

				-- Handle the default border texture based on settings
				updateButtonNormalTexture(button)

				-- Create and apply mask to icon and other maskable elements
				if button.icon then
					if button.IconMask then
						button.icon:RemoveMaskTexture(button.IconMask)
					end
					createAndApplyMask(button, getMaskPath(baseName))
				end

			-- Apply full mask texture to cooldown swipe (must be done immediately during button setup)
			if button.cooldown then
				local swipeMaskPath = ButtonStyles.GetSwipeMaskPath(baseName)
				if swipeMaskPath then
					-- SetSwipeTexture requires all 5 parameters: texture path, R, G, B, A
					-- Using white color (1,1,1) with 0.8 alpha to match default Blizzard cooldown appearance
					button.cooldown:SetSwipeTexture(swipeMaskPath, 1, 1, 1, 0.8)
				end
				end				-- Create custom highlight overlay
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
					local showRangeIndicator = zBarButtonBG.GetSettingInfo(baseName, "showRangeIndicator")
					if showRangeIndicator then
						if not button._zBBG_rangeOverlay then
							button._zBBG_rangeOverlay = button:CreateTexture(nil, "BACKGROUND", nil, 0)
							local barName = zBarButtonBG.buttonGroups[buttonName]
							local c = zBarButtonBG.GetSettingInfo(barName, "rangeIndicatorColor")
							button._zBBG_rangeOverlay:SetColorTexture(c.r, c.g, c.b, c.a)
							button._zBBG_rangeOverlay:Hide() -- Hidden by default
						end
					elseif button._zBBG_rangeOverlay then
						-- Range indicators disabled, hide and remove overlay
						button._zBBG_rangeOverlay:Hide()
						button._zBBG_rangeOverlay = nil
					end

				-- Apply swipe texture to cooldown frame (same as icon mask, matches button shape)
				-- This must be done immediately during button setup, not in a hook
				if button.cooldown and button._zBBG_swipeTexturePath then
					-- SetSwipeTexture requires all 5 parameters: texture path, R, G, B, A
					-- Using white color (1,1,1) with 0.8 alpha to match default Blizzard cooldown appearance
					button.cooldown:SetSwipeTexture(button._zBBG_swipeTexturePath, 1, 1, 1, 0.8)
				end					-- Create custom cooldown fade overlay (only if enabled and developer flag allows it)
					local fadeCooldown = zBarButtonBG.GetSettingInfo(baseName, "fadeCooldown")
					if zBarButtonBG.midnightCooldown and fadeCooldown then
					if not button._zBBG_cooldownOverlay then
						button._zBBG_cooldownOverlay = button:CreateTexture(nil, "BACKGROUND", nil, 1)
						local barName = zBarButtonBG.buttonGroups[buttonName]
						local c = zBarButtonBG.GetSettingInfo(barName, "cooldownColor")
						button._zBBG_cooldownOverlay:SetColorTexture(c.r, c.g, c.b, c.a)
						button._zBBG_cooldownOverlay:Hide() -- Hidden by default							-- Hook the cooldown frame's Show/Hide scripts to instantly sync our overlay
							-- This fires immediately when the Blizzard cooldown shows/hides
							if button.cooldown and not button.cooldown._zBBG_hooked then
								local originalShow = button.cooldown:GetScript("OnShow") or function() end
								local originalHide = button.cooldown:GetScript("OnHide") or function() end

								button.cooldown:SetScript("OnShow", function(self)
									originalShow(self)
									if self:GetParent() and self:GetParent()._zBBG_cooldownOverlay then
										self:GetParent()._zBBG_cooldownOverlay:Show()
									end
								end)

								button.cooldown:SetScript("OnHide", function(self)
									originalHide(self)
									if self:GetParent() and self:GetParent()._zBBG_cooldownOverlay then
										self:GetParent()._zBBG_cooldownOverlay:Hide()
									end
								end)

								button.cooldown._zBBG_hooked = true
							end
						end
					elseif button._zBBG_cooldownOverlay then
						-- Cooldown fade disabled, hide and remove overlay
						button._zBBG_cooldownOverlay:Hide()
						button._zBBG_cooldownOverlay = nil
					end

					-- Position the highlight based on square/round mode
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

					if Utilities.isSquareButtonStyle() then
						-- Square mode: highlight inset by 2px, overlays fill entire button
						button._zBBG_customHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
						button._zBBG_customHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
						button._zBBG_customHighlight:SetTexCoord(0, 1, 0, 1) -- Range, cooldown, and checked overlays fill the entire button (no inset)
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

					-- Hook to keep suggested action texture and NormalTexture hidden
					if (button.SuggestedActionIconTexture or button.NormalTexture) and not button._zBBG_blizzardTexturesHooked then
						-- Create a function that will keep hiding Blizzard textures
						local function hideBlizzardTextures(self)
							if self.SuggestedActionIconTexture then
								self.SuggestedActionIconTexture:SetAlpha(0)
								self.SuggestedActionIconTexture:Hide()
								self.SuggestedActionIconTexture:SetTexture("")
							end
							if self.NormalTexture then
								self.NormalTexture:SetAlpha(0)
								self.NormalTexture:Hide()
							end
						end

						-- Call once on setup
						hideBlizzardTextures(button)
						
						-- Hook NormalTexture's Show to keep it hidden
						if button.NormalTexture then
							button.NormalTexture:SetScript("OnShow", function(self)
								self:Hide()
								self:SetAlpha(0)
							end)
						end

						button._zBBG_blizzardTexturesHooked = true
					end

				-- Show equipment border with Blizzard's default green color
				if button.Border and not button._zBBG_borderTextureSwapped then
					-- Replace the border's texture with our proc flipbook
					button.Border:SetTexture(ButtonStyles.GetProcFlipbookPath())
					-- Show just the first frame of the flipbook
					button.Border:SetTexCoord(0, 1/5, 0, 1/6)
					-- Use Blizzard's default equipment border color (bright green, 0.5 alpha)
					button.Border:SetVertexColor(0, 1.0, 0, 0.5)
					-- Skip SetDrawLayer during combat to avoid protected function interference
					if not InCombatLockdown() then
						-- Move border to BACKGROUND layer so it's below macro text
						button.Border:SetDrawLayer("BACKGROUND", 2)
					end
					
					button._zBBG_borderTextureSwapped = true
				end
				if not button._zBBG_animationHooked then
					-- Function to apply mask to animation frames
					local function setupAnimationMasks()
						-- Check for AssistedCombatHighlightFrame and mask its flipbook
						if button.AssistedCombatHighlightFrame and button.AssistedCombatHighlightFrame.Flipbook then
							local flipbook = button.AssistedCombatHighlightFrame.Flipbook
							if not flipbook._zBBG_maskHooked then
								flipbook:SetScript("OnShow", function(self)
									applyMaskToTexture(self, button._zBBG_customMask)
								end)
								flipbook._zBBG_maskHooked = true
								-- Apply mask now if it's already shown
								if flipbook:IsShown() then
									applyMaskToTexture(flipbook, button._zBBG_customMask)
								end
							end
						end
					end

					-- Set up masks on first call
					setupAnimationMasks()
					
					-- Recheck when button shows in case frames are created dynamically
					button:HookScript("OnShow", setupAnimationMasks)

					button._zBBG_animationHooked = true
				end					-- Replace the beveled SlotBackground with a flat texture if borders are enabled
					if button.SlotBackground then
						local barNameForSlot = zBarButtonBG.buttonGroups[buttonName]
						if zBarButtonBG.GetSettingInfo(barNameForSlot, "showBorder") then
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

						-- Apply mask to clip the SlotBackground
						if button._zBBG_customMask then
							applyMaskToTexture(button.SlotBackground, button._zBBG_customMask)
						end
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
				local barName = zBarButtonBG.buttonGroups[buttonName]
				if zBarButtonBG.GetSettingInfo(barName, "showBackdrop") then
					outerFrame = CreateFrame("Frame", nil, button)
					applyBackdropPositioning(outerFrame, button, barName)
					outerFrame:SetFrameLevel(0)
					outerFrame:SetFrameStrata("BACKGROUND")

					-- Fill it with black (or class color if that's enabled)
					outerBg = outerFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
					outerBg:SetAllPoints(outerFrame)
					outerBg:SetColorTexture(outerColor.r, outerColor.g, outerColor.b, outerColor.a)
				end					-- Create the inner background that sits right behind the button (if enabled)
					local bgFrame, bg
					if zBarButtonBG.GetSettingInfo(barName, "showSlotBackground") then
						local bgData = createBackgroundLayer(button, innerColor, "BACKGROUND", -7)
						bgFrame = bgData.frame
						bg = bgData.texture

						-- Apply mask to inner background
						if button._zBBG_customMask then
							applyMaskToTexture(bg, button._zBBG_customMask)
						end
					end

					-- Create the border if that option is turned on
					local borderFrame, customBorderTexture
					if zBarButtonBG.GetSettingInfo(barName, "showBorder") and button.icon and button:IsShown() then
						-- Create a frame to hold the custom border texture
						borderFrame = CreateFrame("Frame", nil, button)
						borderFrame:SetAllPoints(button)
						borderFrame:SetFrameLevel(button:GetFrameLevel() + 1)

						-- Create the border texture with appropriate asset for current mode
						customBorderTexture = borderFrame:CreateTexture(nil, "OVERLAY")
						customBorderTexture:SetTexture(getBorderPath(barName))
						customBorderTexture:SetAllPoints(borderFrame)
						-- Use ADD blend mode which treats black as transparent
						customBorderTexture:SetBlendMode("ADD")

						-- Use color picker's alpha for overall border transparency (ADD mode handles black=transparent)
						customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
					end

				-- Apply custom fonts to button text elements using helper
				applyAllTextStyling(button, barName)					-- Store references to everything we created so we can update or remove it later
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
					local barName = zBarButtonBG.buttonGroups[buttonName]

					-- Handle NormalTexture - always keep it transparent
					updateButtonNormalTexture(button)

					-- Update icon mask when switching modes using consolidated helper
					if button.icon then
						-- Use the unified mask update function
						updateButtonMask(button, getMaskPath(barName), data.bg)

						-- Update icon scale and texcoords based on mode
						button.icon:SetScale(1.0)
						button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
					end

					-- Update custom highlight positioning based on current mode
					if button._zBBG_customHighlight then
						local inset = 2
						button._zBBG_customHighlight:ClearAllPoints()
						if Utilities.isSquareButtonStyle() then
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
					end -- Update range and cooldown overlays positioning
					if button._zBBG_rangeOverlay then
						button._zBBG_rangeOverlay:ClearAllPoints()
						button._zBBG_rangeOverlay:SetAllPoints(button.icon)

						if Utilities.isSquareButtonStyle() then
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

						if Utilities.isSquareButtonStyle() then
							-- Square mode: remove any mask we previously applied
							removeMaskFromTexture(button._zBBG_cooldownOverlay)
						else
							-- Round mode: apply mask
							if button._zBBG_customMask then
								applyMaskToTexture(button._zBBG_cooldownOverlay, button._zBBG_customMask)
							end
						end
					end -- Update the SlotBackground based on whether borders are on or off
					if button.SlotBackground then
						local barNameForSlotBg = zBarButtonBG.buttonGroups[buttonName]
						local showBorderSlot = zBarButtonBG.GetSettingInfo(barNameForSlotBg, "showBorder")
						if showBorderSlot then
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
					local showBackdrop = zBarButtonBG.GetSettingInfo(barName, "showBackdrop")
					local showSlotBackground = zBarButtonBG.GetSettingInfo(barName, "showSlotBackground")
					
					if data.outerFrame then
						if showBackdrop then
							data.outerFrame:Show()
							-- Update backdrop positioning in case adjustments changed
							applyBackdropPositioning(data.outerFrame, button)
						else
							data.outerFrame:Hide()
						end
					end
					if data.frame then
						if showSlotBackground then
							data.frame:Show()
						else
							data.frame:Hide()
						end
					end

					-- Update the colors (might have changed in settings or toggled class colors)
					if data.outerBg then
						data.outerBg:SetColorTexture(outerColor.r, outerColor.g, outerColor.b, outerColor.a)
					end
					if data.bg then
						data.bg:SetColorTexture(innerColor.r, innerColor.g, innerColor.b, innerColor.a)
					end

					-- Update fonts in case they changed using helper
					applyAllTextStyling(button)

					-- Handle border updates
					local showBorderFinal = zBarButtonBG.GetSettingInfo(barName, "showBorder")
					if showBorderFinal and button.icon then
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

							data.customBorderTexture:SetTexture(getBorderPath(barName))
							data.customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b,
								borderColor.a)
						else
							-- Border exists, update texture for current mode
							data.borderFrame:Show()

							data.customBorderTexture:SetTexture(getBorderPath(barName))
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
	--[[
	-- Override action bar container buttonPadding if enabled
	if zBarButtonBG.charSettings.overrideIconPadding and zBarButtonBG.charSettings.iconPaddingValue ~= nil then
		local containerNames = {
			"MainMenuBar",
			"MultiBarBottomLeft",
			"MultiBarBottomRight",
			"MultiBarRight",
			"MultiBarLeft",
			"MultiBar5",
			"MultiBar6",
			"MultiBar7"
		}
		for _, containerName in ipairs(containerNames) do
			local container = _G[containerName]
			if container and container.buttonPadding ~= nil then
				container.buttonPadding = zBarButtonBG.charSettings.iconPaddingValue
				if container.UpdateGridLayout then
					container:UpdateGridLayout()
				end
			end
		end
	end
	]]--
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
				local buttonName = button:GetName()
				local barName = zBarButtonBG.buttonGroups[buttonName]
				local showBorderForButton = zBarButtonBG.GetSettingInfo(barName, "showBorder")
				
				if Utilities.isSquareButtonStyle() then
					-- Square buttons: make it fully transparent
					button.NormalTexture:SetAlpha(0)
				elseif showBorderForButton then
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

		-- Hook AssistedCombatManager to replace suggested action flipbook textures and apply masks
		if AssistedCombatManager then
			hooksecurefunc(AssistedCombatManager, "SetAssistedHighlightFrameShown", function(self, actionButton, shown)
				if not actionButton or not actionButton._zBBG_styled then
					return
				end

				-- Get the highlight frame
				local highlightFrame = actionButton.AssistedCombatHighlightFrame
				if not highlightFrame or not highlightFrame.Flipbook then
					return
				end

				local flipbook = highlightFrame.Flipbook

				if shown then
					-- Use the same flipbook texture as procs (not a separate suggested texture)
					-- Get per-bar button style
					local buttonNameForStyle = actionButton:GetName()
					local barNameForStyle = zBarButtonBG.buttonGroups[buttonNameForStyle]
					local styleName = zBarButtonBG.GetSettingInfo(barNameForStyle, "buttonStyle") or "Square"
					local procFlipbookTexture = ButtonStyles.GetProcFlipbookPath(styleName)
					
					-- Replace texture with proc flipbook
					flipbook:SetTexture(procFlipbookTexture)
					
					-- Desaturate the flipbook to greyscale, then apply suggested action color
					flipbook:SetDesaturated(true)
					local suggestedColor = zBarButtonBG.GetSettingInfo(barNameForStyle, "suggestedActionColor") or { r = 0.2, g = 0.8, b = 1.0, a = 0.8 }
					flipbook:SetVertexColor(suggestedColor.r, suggestedColor.g, suggestedColor.b, suggestedColor.a)
					
					-- Ensure flipbook is visible and properly sized
					flipbook:Show()
					-- Match the button size (get from actionButton dimensions)
					local buttonWidth, buttonHeight = actionButton:GetSize()
					flipbook:SetSize(buttonWidth or 36, buttonHeight or 36)
					flipbook:SetPoint("CENTER", actionButton, "CENTER")
					
					-- Set to BACKGROUND layer so text stays on top
					flipbook:SetDrawLayer("BACKGROUND", 1)
					-- Also reparent to button to ensure proper layering
					flipbook:SetParent(actionButton)

					-- Configure the animation from the flipbook's nested AnimationGroup
					if highlightFrame.Flipbook.Anim then
						local flipbookAnim = nil
						local anims = highlightFrame.Flipbook.Anim:GetAnimations()
						if anims then
							for _, anim in ipairs(anims) do
								if anim:GetObjectType() == "FlipBook" then
									flipbookAnim = anim
									break
								end
							end
						end
						
						if flipbookAnim then
							flipbookAnim:SetFlipBookFrameHeight(64)
							flipbookAnim:SetFlipBookFrameWidth(64)
							flipbookAnim:SetFlipBookFrames(30)
							flipbookAnim:SetFlipBookRows(6)
							flipbookAnim:SetFlipBookColumns(5)
						end
					end
				else
					-- Hide the flipbook when suggested action is no longer active
					flipbook:Hide()
				end

			end)
		end

		-- Hook ActionButtonSpellAlertManager to replace spell activation flipbooks with custom ones
		if ActionButtonSpellAlertManager then
			hooksecurefunc(ActionButtonSpellAlertManager, "ShowAlert", function(self, actionButton, alertType)
				if not actionButton or not actionButton.SpellActivationAlert then
					return
				end
				
				-- Only modify spell alerts for our styled action bar buttons, not other addon windows
				if not actionButton._zBBG_styled then
					return
				end
				
				local alert = actionButton.SpellActivationAlert
				
			-- Get the button style's flipbook textures
			local styleName = zBarButtonBG.GetSettingInfo(barName, "buttonStyle") or "Square"
			local procFlipbookTexture = ButtonStyles.GetProcFlipbookPath(styleName)
				local buttonWidth, buttonHeight = actionButton:GetSize()
				-- Alert frame should be a little.. smaller, so the countdown covers it
				local alertWidth = buttonWidth or 36
				local alertHeight = buttonHeight or 36
				
				-- Resize the alert frame to match button size (don't make it bigger)
				alert:SetSize(alertWidth, alertHeight)
				
				-- Get animation objects (not flipbook textures - those are what have SetFlipBookFrame* methods)
				local loopAnimGroup = alert.ProcLoop
				local loopAnimation = nil
				
				if loopAnimGroup then
					if loopAnimGroup.FlipAnim then
						loopAnimation = loopAnimGroup.FlipAnim
					else
						local anims = loopAnimGroup:GetAnimations()
						if anims then
							for _, anim in ipairs(anims) do
								if anim:GetObjectType() == "FlipBook" then
									loopAnimation = anim
									break
								end
							end
						end
					end
				end
				
				local startAnimGroup = alert.ProcStartAnim
				local startAnimation = nil
				
				if startAnimGroup then
					if startAnimGroup.FlipAnim then
						startAnimation = startAnimGroup.FlipAnim
					else
						local anims = startAnimGroup:GetAnimations()
						if anims then
							for _, anim in ipairs(anims) do
								if anim:GetObjectType() == "FlipBook" then
									startAnimation = anim
									break
								end
							end
						end
					end
				end
				
				-- Replace ProcLoopFlipbook texture (no vertex color - it's baked into the texture)
				if alert.ProcLoopFlipbook then
					alert.ProcLoopFlipbook:SetTexture(procFlipbookTexture)
					-- Size the flipbook to fill the alert frame
					alert.ProcLoopFlipbook:SetAllPoints(alert)
					
					-- Reparent to button to ensure proper layering
					alert.ProcLoopFlipbook:SetParent(actionButton)
					
					-- Set to BACKGROUND layer so text stays on top
					alert.ProcLoopFlipbook:SetDrawLayer("BACKGROUND", 1)
				end
				
				if loopAnimation then
					loopAnimation:SetFlipBookFrameHeight(64)
					loopAnimation:SetFlipBookFrameWidth(64)
					loopAnimation:SetFlipBookFrames(30)
					loopAnimation:SetFlipBookRows(6)
					loopAnimation:SetFlipBookColumns(5)
				end
				
				-- Replace ProcStartFlipbook texture (no vertex color - it's baked into the texture)
				if alert.ProcStartFlipbook then
					alert.ProcStartFlipbook:SetTexture(procFlipbookTexture)
					-- Size the flipbook to fill the alert frame
					alert.ProcStartFlipbook:SetAllPoints(alert)
					
					-- Reparent to button to ensure proper layering
					alert.ProcStartFlipbook:SetParent(actionButton)
					
					-- Set to BACKGROUND layer so text stays on top
					alert.ProcStartFlipbook:SetDrawLayer("BACKGROUND", 1)
				end
				
			if startAnimation then
				startAnimation:SetFlipBookFrameHeight(64)
				startAnimation:SetFlipBookFrameWidth(64)
				startAnimation:SetFlipBookFrames(30)
				startAnimation:SetFlipBookRows(6)
				startAnimation:SetFlipBookColumns(5)
			end
			
			-- Replace ProcAltGlow with a static flipbook frame using the alert color
			if alert.ProcAltGlow then
				local altGlowTexture = alert.ProcAltGlow
				-- Set to static frame (first frame) of the flipbook using the alert color
				altGlowTexture:SetTexture(procFlipbookTexture)
				
				-- Apply alert color to the glow - get per-bar setting
				local buttonNameForAlert = actionButton:GetName()
				local barNameForAlert = zBarButtonBG.buttonGroups[buttonNameForAlert]
				local alertColor = zBarButtonBG.GetSettingInfo(barNameForAlert, "spellAlertColor") or { r = 1.0, g = 0.5, b = 0.0, a = 0.8 }
				altGlowTexture:SetVertexColor(alertColor.r, alertColor.g, alertColor.b, alertColor.a)
				
				-- Size it to fill the alert frame
				altGlowTexture:SetSize(alertWidth or 36, alertHeight or 36)
				altGlowTexture:SetAllPoints(alert)
				
				-- Reparent to button to ensure proper layering
				altGlowTexture:SetParent(actionButton)
				
				-- Set to BACKGROUND layer so text stays on top
				altGlowTexture:SetDrawLayer("BACKGROUND", 1)
				
				-- Set to show just the first frame (no animation)
				-- The flipbook is 64x64 with 6 rows x 5 columns, so just display frame 1
				altGlowTexture:SetTexCoord(0, 1/5, 0, 1/6)
			end
		end)
	end		-- Hook HideAlert to also hide our proc indicator, glow, and alt glow
		if ActionButtonSpellAlertManager then
			hooksecurefunc(ActionButtonSpellAlertManager, "HideAlert", function(self, actionButton)
				if actionButton then
					if actionButton._zBBG_procIndicator then
						actionButton._zBBG_procIndicator:Hide()
					end
					if actionButton._zBBG_procGlow then
						actionButton._zBBG_procGlow:Hide()
					end
					-- Also hide ProcAltGlow if it exists
					local alert = actionButton.SpellActivationAlert
					if alert and alert.ProcAltGlow then
						alert.ProcAltGlow:Hide()
					end
				end
			end)
		end

		zBarButtonBG.hookInstalled = true
	end
end
