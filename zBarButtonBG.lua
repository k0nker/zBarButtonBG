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
local ButtonSkinning = addonTable.Core.ButtonSkinning
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
-- Checks per-bar profile first, then falls back to defaults.lua (not saved profiles)
function zBarButtonBG.GetSettingInfo(barName, settingName)
	if not settingName then return nil end

	local value = nil
	local defaults = addonTable.Core.Defaults.profile

	-- Check for per-bar override first
	if barName and zBarButtonBGAce.db.char and zBarButtonBGAce.db.char.barSettings and zBarButtonBGAce.db.char.barSettings[barName] then
		local barSetting = zBarButtonBGAce.db.char.barSettings[barName]
		
		-- Check if bar has a different profile assigned
		if barSetting.differentProfile and barSetting.profileName then
			local profile
			-- Try to get the named profile from saved profiles
			if zBarButtonBGAce.db.profiles and zBarButtonBGAce.db.profiles[barSetting.profileName] then
				profile = zBarButtonBGAce.db.profiles[barSetting.profileName]
			end
			
			if profile then
				value = profile[settingName]
				-- If value exists and is a table (like colors), fill in missing components from defaults
				if value ~= nil and type(value) == "table" and type(defaults[settingName]) == "table" then
					local defaultTable = defaults[settingName]
					for key, defaultVal in pairs(defaultTable) do
						if value[key] == nil then
							value[key] = defaultVal
						end
					end
				end
			end
			
			-- If still not found, use defaults
			if value == nil then
				value = defaults[settingName]
			end
			
			return value
		end
	end
	
	-- No different profile assigned - use user's current global profile
	local profileToUse = zBarButtonBGAce.db:GetCurrentProfile()
	local profile = zBarButtonBGAce.db.profiles[profileToUse]
	if not profile then
		profile = zBarButtonBGAce.db.profile
	end
	
	value = profile[settingName]
	-- If value exists and is a table (like colors), fill in missing components from defaults
	if value ~= nil and type(value) == "table" and type(defaults[settingName]) == "table" then
		local defaultTable = defaults[settingName]
		for key, defaultVal in pairs(defaultTable) do
			if value[key] == nil then
				value[key] = defaultVal
			end
		end
	end
	
	-- If still not found, use defaults
	if value == nil then
		value = defaults[settingName]
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
			-- Use modular function to update all color-related elements
			ButtonSkinning.setOuterBackground(data.button, barName)
			ButtonSkinning.setInnerBackground(data.button, barName)
			ButtonSkinning.setBorder(data.button, barName)
			Overlays.setRangeOverlay(data.button, barName)
			Overlays.setCooldownOverlay(data.button, barName)
		end
	end
end

-- Update fonts on existing buttons without rebuilding everything
function zBarButtonBG.updateFonts()
	if not zBarButtonBG.enabled then return end

	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data and data.button then
			local barName = zBarButtonBG.buttonGroups[buttonName]
			if barName then
				Styling.setTextStyling(data.button, barName)
			end
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
-- Local alias for updateButtonNormalTexture used in button creation loop
local updateButtonNormalTexture = Styling.updateButtonNormalTexture

-- Initialize all button regions from metadata
local function initializeButtonRegions(button)
	ButtonStyles.InitializeButton(button)
end

function zBarButtonBG.removeActionBarBackgrounds()
	-- Hide and destroy all our custom frames and clean up button masks
	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data then
			if data.button then
				-- Clean up the mask texture so it gets reapplied with the new setting
				if data.button._zBBG_customMask then
					Utilities.removeMaskFromTexture(data.button.icon)
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
				local barName = baseName

				-- Check if we've already set this button up
				if not zBarButtonBG.frames[buttonName] then
					-- Initial setup: mark button and initialize everything
					button._zBBG_styled = true
					initializeButtonRegions(button)
					updateButtonNormalTexture(button)

					-- Call the consolidated setup function to handle all skinning
					ButtonSkinning.setupButton(button, barName)

					-- Store frame references for future updates
					zBarButtonBG.frames[buttonName] = { button = button }
				else
					-- Button already set up, just refresh with current settings
					ButtonSkinning.updateButton(button, barName)
				end
			end
		end
	end
	--[[
	-- Override action bar container buttonPadding if enabled (per-bar)
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
		local barName = containerName -- assuming containerName matches barName
		local overrideIconPadding = zBarButtonBG.GetSettingInfo(barName, "overrideIconPadding")
		local iconPaddingValue = zBarButtonBG.GetSettingInfo(barName, "iconPaddingValue")
		local container = _G[containerName]
		if overrideIconPadding and iconPaddingValue ~= nil and container and container.buttonPadding ~= nil then
			container.buttonPadding = iconPaddingValue
			if container.UpdateGridLayout then
				container:UpdateGridLayout()
			end
		end
	end
	]] --
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

				if showBorderForButton then
					-- Round buttons with borders: make visible and color it
					local borderColor = Utilities.getColorTable("borderColor", "useClassColorBorder", barName)
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
					local suggestedColor = zBarButtonBG.GetSettingInfo(barNameForStyle, "suggestedActionColor") or
						{ r = 0.2, g = 0.8, b = 1.0, a = 0.8 }
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
					local alertColor = zBarButtonBG.GetSettingInfo(barNameForAlert, "spellAlertColor") or
						{ r = 1.0, g = 0.5, b = 0.0, a = 0.8 }
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
					altGlowTexture:SetTexCoord(0, 1 / 5, 0, 1 / 6)
				end
			end)
		end -- Hook HideAlert to also hide our proc indicator, glow, and alt glow
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
