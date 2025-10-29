zBarButtonBG = {}

-- Default settings for new users and reset function
zBarButtonBG.defaultSettings = {
	enabled = true,
	squareButtons = true,
	showBorder = true,
	borderColor = { r = 0.2, g = 0.2, b = 0.2, a = 1 }, -- Slightly lighter grey than button background
	useClassColorBorder = false,
	showBackdrop = true,
	outerColor = { r = 0, g = 0, b = 0, a = 1 },   -- Black backdrop
	useClassColorOuter = false,
	showSlotBackground = true,
	innerColor = { r = 0.1, g = 0.1, b = 0.1, a = 1 }, -- Dark grey button background
	useClassColorInner = false,
	showRangeIndicator = false,
	rangeIndicatorColor = { r = .42, g = 0.07, b = .12, a = 0.75 }, -- Dark red at 75% opacity
	fadeCooldown = false,
	cooldownColor = { r = 0, g = 0, b = 0, a = 0.5 }, -- Black at 50% opacity
	-- Font settings
	macroNameFont = "Fonts\\FRIZQT__.TTF", -- Default UI font
	macroNameFontSize = 10,
	macroNameFontFlags = "OUTLINE",
	macroNameWidth = 60, -- Width of macro name text frame
	macroNameHeight = 12, -- Height of macro name text frame
	macroNameColor = { r = 1, g = 1, b = 1, a = 1 }, -- White text
	countFont = "Fonts\\FRIZQT__.TTF", -- Default UI font  
	countFontSize = 12,
	countFontFlags = "OUTLINE",
	countWidth = 20, -- Width of count text frame
	countHeight = 15, -- Height of count text frame
	countColor = { r = 1, g = 1, b = 1, a = 1 } -- White text
}

-- ############################################################
-- Load settings when we log in
-- ############################################################
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		-- Make sure the saved variables table exists
		zBarButtonBGSaved = zBarButtonBGSaved or {}

		-- Figure out who we are
		local realmName = GetRealmName()
		local charName = UnitName("player")

		-- Set up this character's settings table
		zBarButtonBGSaved[realmName] = zBarButtonBGSaved[realmName] or {}
		zBarButtonBGSaved[realmName][charName] = zBarButtonBGSaved[realmName][charName] or {}

		-- Make a shortcut so we don't have to type all that every time
		zBarButtonBG.charSettings = zBarButtonBGSaved[realmName][charName]

		-- Set up defaults for anything that doesn't exist yet
		for key, value in pairs(zBarButtonBG.defaultSettings) do
			if zBarButtonBG.charSettings[key] == nil then
				-- Deep copy color tables
				if type(value) == "table" then
					zBarButtonBG.charSettings[key] = {}
					for k, v in pairs(value) do
						zBarButtonBG.charSettings[key][k] = v
					end
				else
					zBarButtonBG.charSettings[key] = value
				end
			end
		end

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

	-- Save the enabled state
	if zBarButtonBG.charSettings then
		zBarButtonBG.charSettings.enabled = zBarButtonBG.enabled
	end
end

-- Update colors on existing frames without rebuilding everything
function zBarButtonBG.updateColors()
	if not zBarButtonBG.enabled then return end

	-- Get color tables once using helpers
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
				data.button._zBBG_cooldownOverlay:SetColorTexture(cooldownColor.r, cooldownColor.g, cooldownColor.b, cooldownColor.a)
			end
		end
	end
end

-- Update fonts on existing buttons without rebuilding everything
function zBarButtonBG.updateFonts()
	if not zBarButtonBG.enabled then return end

	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data and data.button then
			-- Update macro name font and size (button.Name)
			if data.button.Name then
				data.button.Name:SetFont(
					zBarButtonBG.charSettings.macroNameFont,
					zBarButtonBG.charSettings.macroNameFontSize,
					zBarButtonBG.charSettings.macroNameFontFlags
				)
				-- Set text frame dimensions
				data.button.Name:SetSize(
					zBarButtonBG.charSettings.macroNameWidth,
					zBarButtonBG.charSettings.macroNameHeight
				)
				-- Set text color
				local c = zBarButtonBG.charSettings.macroNameColor
				data.button.Name:SetTextColor(c.r, c.g, c.b, c.a)
			end

			-- Update count/charge font and size (button.Count)
			if data.button.Count then
				data.button.Count:SetFont(
					zBarButtonBG.charSettings.countFont,
					zBarButtonBG.charSettings.countFontSize,
					zBarButtonBG.charSettings.countFontFlags
				)
				-- Set text frame dimensions
				data.button.Count:SetSize(
					zBarButtonBG.charSettings.countWidth,
					zBarButtonBG.charSettings.countHeight
				)
				-- Set text color
				local c = zBarButtonBG.charSettings.countColor
				data.button.Count:SetTextColor(c.r, c.g, c.b, c.a)
			end
		end
	end
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
				-- Check if we've already set this button up
				if not zBarButtonBG.frames[buttonName] then
					-- Mark this button as having our custom styling applied
					button._zBBG_styled = true

					-- Handle the default border texture based on settings
					-- Always make Blizzard's NormalTexture fully transparent so it never shows
					if button.NormalTexture then
						button.NormalTexture:SetAlpha(0)
					end

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

					-- Create custom range indicator overlay
					if not button._zBBG_rangeOverlay then
						button._zBBG_rangeOverlay = button:CreateTexture(nil, "OVERLAY", nil, 1)
						local c = zBarButtonBG.charSettings.rangeIndicatorColor
						button._zBBG_rangeOverlay:SetColorTexture(c.r, c.g, c.b, c.a)
						button._zBBG_rangeOverlay:Hide() -- Hidden by default
					end

					-- Create custom cooldown fade overlay
					if not button._zBBG_cooldownOverlay then
						button._zBBG_cooldownOverlay = button:CreateTexture(nil, "OVERLAY", nil, 2)
						local c = zBarButtonBG.charSettings.cooldownColor
						button._zBBG_cooldownOverlay:SetColorTexture(c.r, c.g, c.b, c.a)
						button._zBBG_cooldownOverlay:Hide() -- Hidden by default
					end

					-- Position the highlight based on square/round mode
					local inset = 2
					button._zBBG_customHighlight:ClearAllPoints()
					button._zBBG_rangeOverlay:ClearAllPoints()
					button._zBBG_cooldownOverlay:ClearAllPoints()
					
					if zBarButtonBG.charSettings.squareButtons then
						-- Square mode: highlight inset by 2px, overlays fill entire button
						button._zBBG_customHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
						button._zBBG_customHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
						button._zBBG_customHighlight:SetTexCoord(0, 1, 0, 1)
						
						-- Range and cooldown overlays fill the entire button (no inset)
						button._zBBG_rangeOverlay:SetAllPoints(button.icon)
						button._zBBG_cooldownOverlay:SetAllPoints(button.icon)
						
						-- Remove masks for square mode
						if button._zBBG_customMask then
							removeMaskFromTexture(button._zBBG_customHighlight)
							removeMaskFromTexture(button._zBBG_rangeOverlay)
							removeMaskFromTexture(button._zBBG_cooldownOverlay)
						end
					else
						-- Round mode: use custom mask for rounded edges
						button._zBBG_customHighlight:SetAllPoints(button.icon)
						button._zBBG_rangeOverlay:SetAllPoints(button.icon)
						button._zBBG_cooldownOverlay:SetAllPoints(button.icon)
						
						if button._zBBG_customMask then
							-- Apply mask to highlight and overlays
							applyMaskToTexture(button._zBBG_customHighlight, button._zBBG_customMask)
							applyMaskToTexture(button._zBBG_rangeOverlay, button._zBBG_customMask)
							applyMaskToTexture(button._zBBG_cooldownOverlay, button._zBBG_customMask)
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
								if not self:IsMouseOver() then
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
						outerFrame:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5)
						outerFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 5, -5)
						outerFrame:SetFrameLevel(0)
						outerFrame:SetFrameStrata("BACKGROUND")

						-- Fill it with black (or class color if that's enabled)
						outerBg = outerFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
						outerBg:SetAllPoints(outerFrame)
						local outerColor = getColorTable("outerColor", "useClassColorOuter")
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
						local innerColor = getColorTable("innerColor", "useClassColorInner")
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

						-- Figure out what color to use for the border
						local borderColor = getColorTable("borderColor", "useClassColorBorder")

						-- Use color picker's alpha for overall border transparency (ADD mode handles black=transparent)
						customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
					end

					-- Apply custom fonts to button text elements
					if button.Name then
						button.Name:SetFont(
							zBarButtonBG.charSettings.macroNameFont,
							zBarButtonBG.charSettings.macroNameFontSize,
							zBarButtonBG.charSettings.macroNameFontFlags
						)
						-- Set text frame dimensions
						button.Name:SetSize(
							zBarButtonBG.charSettings.macroNameWidth,
							zBarButtonBG.charSettings.macroNameHeight
						)
						-- Set text color
						local c = zBarButtonBG.charSettings.macroNameColor
						button.Name:SetTextColor(c.r, c.g, c.b, c.a)
					end
					if button.Count then
						button.Count:SetFont(
							zBarButtonBG.charSettings.countFont,
							zBarButtonBG.charSettings.countFontSize,
							zBarButtonBG.charSettings.countFontFlags
						)
						-- Set text frame dimensions
						button.Count:SetSize(
							zBarButtonBG.charSettings.countWidth,
							zBarButtonBG.charSettings.countHeight
						)
						-- Set text color
						local c = zBarButtonBG.charSettings.countColor
						button.Count:SetTextColor(c.r, c.g, c.b, c.a)
					end

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
					-- Make sure the mask stays removed
					if button.icon and button.IconMask then
						button.icon:RemoveMaskTexture(button.IconMask)
					end
				else
					-- Button already has backgrounds, just update them with current settings
					local data = zBarButtonBG.frames[buttonName]

					-- Handle NormalTexture - always keep it transparent
					if button.NormalTexture then
						button.NormalTexture:SetAlpha(0)
					end

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
						]]--

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
					local outerColor = getColorTable("outerColor", "useClassColorOuter")
					local innerColor = getColorTable("innerColor", "useClassColorInner")

					if data.outerBg then
						data.outerBg:SetColorTexture(outerColor.r, outerColor.g, outerColor.b, outerColor.a)
					end
					if data.bg then
						data.bg:SetColorTexture(innerColor.r, innerColor.g, innerColor.b, innerColor.a)
					end

					-- Update fonts in case they changed
					if button.Name then
						button.Name:SetFont(
							zBarButtonBG.charSettings.macroNameFont,
							zBarButtonBG.charSettings.macroNameFontSize,
							zBarButtonBG.charSettings.macroNameFontFlags
						)
						-- Set text frame dimensions
						button.Name:SetSize(
							zBarButtonBG.charSettings.macroNameWidth,
							zBarButtonBG.charSettings.macroNameHeight
						)
						-- Set text color
						local c = zBarButtonBG.charSettings.macroNameColor
						button.Name:SetTextColor(c.r, c.g, c.b, c.a)
					end
					if button.Count then
						button.Count:SetFont(
							zBarButtonBG.charSettings.countFont,
							zBarButtonBG.charSettings.countFontSize,
							zBarButtonBG.charSettings.countFontFlags
						)
						-- Set text frame dimensions
						button.Count:SetSize(
							zBarButtonBG.charSettings.countWidth,
							zBarButtonBG.charSettings.countHeight
						)
						-- Set text color
						local c = zBarButtonBG.charSettings.countColor
						button.Count:SetTextColor(c.r, c.g, c.b, c.a)
					end

					-- Handle border updates
					if zBarButtonBG.charSettings.showBorder and button.icon then
						-- Figure out the border color
						local borderColor = getColorTable("borderColor", "useClassColorBorder")

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

	-- Hook into action bar events so we can update when buttons change
	if not zBarButtonBG.hookInstalled then
		-- Listen for action bar changes and reapply our backgrounds
		local updateFrame = CreateFrame("Frame")
		updateFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
		updateFrame:RegisterEvent("UPDATE_BINDINGS")
		updateFrame:SetScript("OnEvent", function(self, event)
			if zBarButtonBG.enabled then
				-- Only rebuild on page changes and binding updates, not on grid show/hide
				zBarButtonBG.createActionBarBackgrounds()
			end
		end)

		-- Hook into various action button update functions to manage NormalTexture
		-- This keeps it transparent when we want it hidden, or properly colored when we're using it
		local function manageNormalTexture(button)
			if button and button.NormalTexture and button._zBBG_styled and zBarButtonBG.enabled then
				if zBarButtonBG.charSettings.squareButtons then
					-- Square buttons: make it fully transparent
					button.NormalTexture:SetAlpha(0)
				elseif zBarButtonBG.charSettings.showBorder then
					-- Round buttons with borders: make visible and color it
					button.NormalTexture:Show()
					button.NormalTexture:SetAlpha(1)
					local borderColor = getColorTable("borderColor", "useClassColorBorder")
					button.NormalTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
				else
					-- Round buttons without borders: make it transparent
					button.NormalTexture:SetAlpha(0)
				end
			end
		end

		-- Hook the range indicator update (this one definitely exists)
		hooksecurefunc("ActionButton_UpdateRangeIndicator", manageNormalTexture)

		-- Hook range indicator to show/hide range overlay
		local function updateRangeOverlay(button)
			if not button or not button._zBBG_rangeOverlay or not button._zBBG_styled or not zBarButtonBG.enabled then
				return
			end
			
			if not zBarButtonBG.charSettings.showRangeIndicator then
				button._zBBG_rangeOverlay:Hide()
				return
			end
			
			-- Check if there's a valid target
			local hasTarget = UnitExists("target")
			if not hasTarget then
				button._zBBG_rangeOverlay:Hide()
				return
			end
			
			-- Check range based on button type
			local inRange = nil
			if button.action then
				-- Regular action buttons - check range against current target
				inRange = IsActionInRange(button.action, "target")
			elseif button.GetAction then
				-- Try to get action from the button
				local action = button:GetAction()
				if action then
					inRange = IsActionInRange(action, "target")
				end
			end
			
			-- inRange: true = in range, nil = out of range (when target exists)
			if inRange == false then
				-- Out of range - show overlay
				local c = zBarButtonBG.charSettings.rangeIndicatorColor
				button._zBBG_rangeOverlay:SetColorTexture(c.r, c.g, c.b, c.a)
				button._zBBG_rangeOverlay:Show()
			else
				-- In range - hide overlay
				button._zBBG_rangeOverlay:Hide()
			end
		end
		hooksecurefunc("ActionButton_UpdateRangeIndicator", updateRangeOverlay)

		-- Hook cooldown to show/hide cooldown fade overlay
		local function updateCooldownOverlay(button)
			if button and button._zBBG_cooldownOverlay and button._zBBG_styled and zBarButtonBG.enabled then
				if zBarButtonBG.charSettings.fadeCooldown and button.cooldown then
					local start, duration = button.cooldown:GetCooldownTimes()
					if start and duration and start > 0 and duration > 0 then
						-- Try to get GCD info - try both old and new API
						local gcdStart, gcdDuration = 0, 0
						
						-- Try the old API first (might still exist)
						if GetSpellCooldown then
							gcdStart, gcdDuration = GetSpellCooldown(61304)
							-- Old API returns seconds, convert to milliseconds to match button cooldown
							gcdDuration = gcdDuration * 1000
						else
							-- Use new API
							local gcdInfo = C_Spell.GetSpellCooldown(61304)
							if gcdInfo then
								gcdStart = gcdInfo.startTime or 0
								gcdDuration = (gcdInfo.duration or 0) * 1000 -- Convert seconds to milliseconds
							end
						end
						
						-- Debug: Add a test command to see what's happening
						if button == ActionButton1 and zBarButtonBG._debugGCD then
							print("Button CD:", duration, "GCD:", gcdDuration, "Diff:", math.abs(duration - gcdDuration))
						end
						
						-- Check if this looks like GCD by duration comparison
						-- GCD is typically 1000-1500ms, so if duration is close to that range and matches GCD, hide it
						if gcdDuration > 0 and duration > 800 and duration < 2000 then
							-- This could be GCD - check if duration is very close to GCD duration
							if math.abs(duration - gcdDuration) < 50 then -- Tighter tolerance (50ms)
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
				else
					button._zBBG_cooldownOverlay:Hide()
				end
			end
		end
		hooksecurefunc("ActionButton_UpdateCooldown", updateCooldownOverlay)
		hooksecurefunc("CooldownFrame_Set", function(cooldown)
			if cooldown and cooldown:GetParent() and cooldown:GetParent()._zBBG_styled then
				updateCooldownOverlay(cooldown:GetParent())
			end
		end)

		zBarButtonBG.hookInstalled = true
	end
end

-- Turn off our backgrounds and put everything back to normal
function zBarButtonBG.removeActionBarBackgrounds()
	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data then
			-- Clear the styling flag so the button can show its default textures
			if data.button then
				data.button._zBBG_styled = nil
			end

			-- Hide our custom background frames
			if data.outerFrame then
				data.outerFrame:Hide()
			end
			if data.frame then
				data.frame:Hide()
			end
			-- Hide the border frame if it exists
			if data.borderFrame then data.borderFrame:Hide() end

			-- Put the default border texture back and restore its alpha
			if data.button and data.button.NormalTexture then
				data.button.NormalTexture:SetAlpha(1)
				data.button.NormalTexture:Show()
			end

			-- Restore the default SlotBackground texture
			if data.button and data.button.SlotBackground then
				data.button.SlotBackground:SetTexture(nil)
				data.button.SlotBackground:SetVertexColor(1, 1, 1, 1)
				data.button.SlotBackground:SetDrawLayer("BACKGROUND", 0)
				-- Remove our custom masking
				if data.button._zBBG_customMask then
					removeMaskFromTexture(data.button.SlotBackground)
				end
			end

			-- Remove mask from inner background
			if data.bg and data.button and data.button._zBBG_customMask then
				removeMaskFromTexture(data.bg)
			end

			-- Remove custom mask from highlight
			if data.button and data.button._zBBG_customHighlight and data.button._zBBG_customMask then
				removeMaskFromTexture(data.button._zBBG_customHighlight)
			end

			-- Reset the icon back to normal size and coords
			if data.button and data.button.icon then
				data.button.icon:SetScale(1.0)
				data.button.icon:SetTexCoord(0, 1, 0, 1)
				-- Remove our custom mask and restore Blizzard's mask
				if data.button._zBBG_customMask then
					removeMaskFromTexture(data.button.icon)
					-- Destroy the mask object completely so it gets recreated fresh
					data.button._zBBG_customMask = nil
				end
				if data.button.IconMask then
					-- Reapply Blizzard's icon mask directly (not tracked by our helpers)
					data.button.icon:AddMaskTexture(data.button.IconMask)
				end
			end

			-- Remove custom highlight and restore Blizzard's default overlays
			if data.button then
				if data.button._zBBG_customHighlight then
					data.button._zBBG_customHighlight:Hide()
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

-- Set up the /zbg slash command
SLASH_ZBARBUTTONBG1 = "/zbg"
SlashCmdList["ZBARBUTTONBG"] = function(msg)
	msg = msg:lower():trim()
	if msg == "" or msg == "toggle" then
		zBarButtonBG.toggle()
	--[[
	elseif msg == "rangetest" then
		-- Debug range checking for first two action buttons
		local b1, b2 = ActionButton1, ActionButton2
		local a1, a2 = b1.action, b2.action
		
		zBarButtonBG.print("=== Range Test Debug ===")
		if UnitExists("target") then
			zBarButtonBG.print("Target: " .. UnitName("target") .. " (" .. UnitClass("target") .. ")")
		else
			zBarButtonBG.print("Target: None")
		end
		
		-- Button 1
		if a1 then
			local usable, nomana = IsUsableAction(a1)
			local range = IsActionInRange(a1, "target")
			zBarButtonBG.print("Button1 (action " .. a1 .. "): usable=" .. tostring(usable) .. ", nomana=" .. tostring(nomana) .. ", range=" .. tostring(range))
		else
			zBarButtonBG.print("Button1: No action assigned")
		end
		
		-- Button 2
		if a2 then
			local usable, nomana = IsUsableAction(a2)
			local range = IsActionInRange(a2, "target")
			zBarButtonBG.print("Button2 (action " .. a2 .. "): usable=" .. tostring(usable) .. ", nomana=" .. tostring(nomana) .. ", range=" .. tostring(range))
		else
			zBarButtonBG.print("Button2: No action assigned")
		end
	elseif msg == "gcdtest" then
		print("zBarButtonBG: GCD debug mode toggled")
		zBarButtonBG._debugGCD = not zBarButtonBG._debugGCD
	elseif msg == "fonttest" then
		-- Test fonts by cycling through different sizes on ActionButton1
		local button = ActionButton1
		if button and button.Name and button.Count then
			local newSize = (button.Count._testSize or 12) + 2
			if newSize > 20 then newSize = 8 end
			button.Count._testSize = newSize
			button.Name._testSize = newSize
			
			button.Name:SetFont("Fonts\\FRIZQT__.TTF", newSize, "OUTLINE")
			button.Count:SetFont("Fonts\\FRIZQT__.TTF", newSize, "OUTLINE")
			print("Font size changed to:", newSize)
		end
	elseif msg == "colortest" then
		-- Test colors by cycling through different colors on ActionButton1
		local button = ActionButton1
		if button and button.Name and button.Count then
			local colors = {
				{1, 1, 1, 1}, -- White
				{1, 0, 0, 1}, -- Red
				{0, 1, 0, 1}, -- Green
				{0, 0, 1, 1}, -- Blue
				{1, 1, 0, 1}, -- Yellow
				{1, 0, 1, 1}, -- Magenta
				{0, 1, 1, 1}  -- Cyan
			}
			local colorIndex = (button._testColorIndex or 0) + 1
			if colorIndex > #colors then colorIndex = 1 end
			button._testColorIndex = colorIndex
			
			local color = colors[colorIndex]
			button.Name:SetTextColor(color[1], color[2], color[3], color[4])
			button.Count:SetTextColor(color[1], color[2], color[3], color[4])
			print("Font color changed to:", color[1], color[2], color[3], color[4])
		end
		--]]
	end
end
