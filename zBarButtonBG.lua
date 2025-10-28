zBarButtonBG = {}

-- Default settings for new users and reset function
zBarButtonBG.defaultSettings = {
	enabled = true,
	squareButtons = true,
	showBorder = true,
	borderWidth = 1,
	borderColor = {r = 0.2, g = 0.2, b = 0.2, a = 1},  -- Slightly lighter grey than button background
	useClassColorBorder = false,
	outerColor = {r = 0, g = 0, b = 0, a = 1},  -- Black backdrop
	useClassColorOuter = false,
	innerColor = {r = 0.1, g = 0.1, b = 0.1, a = 1},  -- Dark grey button background
	useClassColorInner = false,
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
	
	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data then
			-- Update outer background color
			if data.outerBg then
				local outer
				if zBarButtonBG.charSettings.useClassColorOuter then
					local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
					outer = {r = classColor.r, g = classColor.g, b = classColor.b, a = zBarButtonBG.charSettings.outerColor.a}
				else
					outer = zBarButtonBG.charSettings.outerColor
				end
				data.outerBg:SetColorTexture(outer.r, outer.g, outer.b, outer.a)
			end
			
			-- Update inner background color
			if data.bg then
				local inner
				if zBarButtonBG.charSettings.useClassColorInner then
					local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
					inner = {r = classColor.r, g = classColor.g, b = classColor.b, a = zBarButtonBG.charSettings.innerColor.a}
				else
					inner = zBarButtonBG.charSettings.innerColor
				end
				data.bg:SetColorTexture(inner.r, inner.g, inner.b, inner.a)
			end
			
			-- Update border color
			if zBarButtonBG.charSettings.showBorder then
				local borderColor
				if zBarButtonBG.charSettings.useClassColorBorder then
					local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
					borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
				else
					borderColor = zBarButtonBG.charSettings.borderColor
				end
				
			-- Update custom border texture for round buttons
			if data.customBorderTexture and not zBarButtonBG.charSettings.squareButtons then
				-- Use color picker's alpha for overall border transparency (ADD mode handles black=transparent)
				data.customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
			end				-- Update pixel borders for square buttons
				if zBarButtonBG.charSettings.squareButtons then
					if data.borderTop then
						data.borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
					end
					if data.borderBottom then
						data.borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
					end
					if data.borderLeft then
						data.borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
					end
					if data.borderRight then
						data.borderRight:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
					end
				end
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
					
					-- Square off the icons if that option is enabled
					if zBarButtonBG.charSettings.squareButtons then
						-- Remove the icon mask that makes it rounded
						if button.icon and button.IconMask then
							button.icon:RemoveMaskTexture(button.IconMask)
						end

						-- Constrain and crop the icon to make it square and fit inside borders
						if button.icon then
							-- Reset scale to default
							button.icon:SetScale(1.0)
							-- Crop the edges to make it square instead of round
							button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							-- Constrain icon to be 2px smaller on all sides to prevent border clipping
							button.icon:ClearAllPoints()
							button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
							button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
						end
						
						-- Crop the highlight and other overlay textures to match our squared-off icon
						-- Constrain them to 2px smaller to prevent border clipping
						local inset = 2
						if button.HighlightTexture then
							button.HighlightTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							button.HighlightTexture:ClearAllPoints()
							button.HighlightTexture:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button.HighlightTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button.HighlightTexture:SetAlpha(1)
						end
						if button.CheckedTexture then
							button.CheckedTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							button.CheckedTexture:ClearAllPoints()
							button.CheckedTexture:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button.CheckedTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button.CheckedTexture:SetAlpha(1)
						end
						if button.PushedTexture then
							button.PushedTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							button.PushedTexture:ClearAllPoints()
							button.PushedTexture:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button.PushedTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button.PushedTexture:SetAlpha(1)
						end
						if button.Flash then
							button.Flash:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							button.Flash:ClearAllPoints()
							button.Flash:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button.Flash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button.Flash:SetAlpha(1)
						end
					else
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
								button._zBBG_customMask:SetTexture("Interface/AddOns/zBarButtonBG/Assets/ButtonIconMask")
								button._zBBG_customMask:SetAllPoints(button)
							end
							button.icon:AddMaskTexture(button._zBBG_customMask)
						end
					end

					-- Make the cooldown spiral fill the whole button
					if button.cooldown then
						button.cooldown:SetAllPoints(button)
					end
					
					-- Hide Blizzard's default highlight and create our own custom golden overlay
					-- Use SetAlpha(0) to make them invisible even if Blizzard tries to show them
					if button.HighlightTexture then
						button.HighlightTexture:SetAlpha(0)
					end
					if button.PushedTexture then
						button.PushedTexture:SetAlpha(0)
					end
					if button.CheckedTexture then
						button.CheckedTexture:SetAlpha(0)
					end
					
					-- Create custom highlight overlay
					if not button._zBBG_customHighlight then
						button._zBBG_customHighlight = button:CreateTexture(nil, "OVERLAY")
						button._zBBG_customHighlight:SetColorTexture(1, 0.82, 0, 0.5) -- Golden at 50% opacity
						button._zBBG_customHighlight:Hide() -- Hidden by default
					end
					
					-- Position the highlight based on square/round mode
					local inset = 2
					button._zBBG_customHighlight:ClearAllPoints()
					if zBarButtonBG.charSettings.squareButtons then
						-- Square mode: inset by 2px to match icon clipping
						button._zBBG_customHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
						button._zBBG_customHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
						button._zBBG_customHighlight:SetTexCoord(0, 1, 0, 1)
					else
						-- Round mode: use custom mask for rounded edges
						button._zBBG_customHighlight:SetAllPoints(button.icon)
						if button._zBBG_customMask then
							button._zBBG_customHighlight:AddMaskTexture(button._zBBG_customMask)
						end
					end
					
					-- Hook up hover and click events to show/hide custom highlight
					if not button._zBBG_highlightHooked then
						button:HookScript("OnEnter", function(self)
							if self._zBBG_customHighlight then
								self._zBBG_customHighlight:Show()
							end
						end)
						button:HookScript("OnLeave", function(self)
							if self._zBBG_customHighlight then
								self._zBBG_customHighlight:Hide()
							end
						end)
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
						
						-- For round buttons, apply our custom mask to clip the SlotBackground
						if not zBarButtonBG.charSettings.squareButtons then
							if not button._zBBG_customMask then
								button._zBBG_customMask = button:CreateMaskTexture()
								button._zBBG_customMask:SetTexture("Interface/AddOns/zBarButtonBG/Assets/ButtonIconMask")
								button._zBBG_customMask:SetAllPoints(button)
							end
							button.SlotBackground:AddMaskTexture(button._zBBG_customMask)
						else
							-- Remove mask for square buttons
							if button._zBBG_customMask then
								button.SlotBackground:RemoveMaskTexture(button._zBBG_customMask)
							end
						end
					end

					-- Hide those annoying spell cast animations
					if button.SpellCastAnimFrame then
						button.SpellCastAnimFrame:SetScript("OnShow", function(self) self:Hide() end)
					end
					if button.InterruptDisplay then
						button.InterruptDisplay:SetScript("OnShow", function(self) self:Hide() end)
					end

					-- Create the outer background frame that extends 5px past the button edges
					local outerFrame = CreateFrame("Frame", nil, button)
					outerFrame:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5)
					outerFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 5, -5)
					outerFrame:SetFrameLevel(0)
					outerFrame:SetFrameStrata("BACKGROUND")

					-- Fill it with black (or class color if that's enabled)
					local outerBg = outerFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
					outerBg:SetAllPoints(outerFrame)
					local outer
					if zBarButtonBG.charSettings.useClassColorOuter then
						local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
						outer = {r = classColor.r, g = classColor.g, b = classColor.b, a = zBarButtonBG.charSettings.outerColor.a}
					else
						outer = zBarButtonBG.charSettings.outerColor
					end
					outerBg:SetColorTexture(outer.r, outer.g, outer.b, outer.a)

					-- Create the inner background that sits right behind the button
					local bgFrame = CreateFrame("Frame", nil, button)
					bgFrame:SetAllPoints(button)
					bgFrame:SetFrameLevel(0)
					bgFrame:SetFrameStrata("BACKGROUND")

					-- Fill it with dark grey (or class color)
					local bg = bgFrame:CreateTexture(nil, "BACKGROUND", nil, -7)
					bg:SetAllPoints(bgFrame)
					local inner
					if zBarButtonBG.charSettings.useClassColorInner then
						local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
						inner = {r = classColor.r, g = classColor.g, b = classColor.b, a = zBarButtonBG.charSettings.innerColor.a}
					else
						inner = zBarButtonBG.charSettings.innerColor
					end
					bg:SetColorTexture(inner.r, inner.g, inner.b, inner.a)

					-- Create the border if that option is turned on
					local borderFrame, borderTop, borderBottom, borderLeft, borderRight
					local borderTopBG, borderBottomBG, borderLeftBG, borderRightBG
					local customBorderTexture
					if zBarButtonBG.charSettings.showBorder and button.icon and button:IsShown() then
						-- For round buttons, use our custom border texture
						if not zBarButtonBG.charSettings.squareButtons then
							-- Create a frame to hold the custom border texture
							borderFrame = CreateFrame("Frame", nil, button)
							borderFrame:SetAllPoints(button)
							borderFrame:SetFrameLevel(button:GetFrameLevel() + 1)
							
						-- Create the border texture
						customBorderTexture = borderFrame:CreateTexture(nil, "OVERLAY")
						customBorderTexture:SetTexture("Interface/AddOns/zBarButtonBG/Assets/ButtonIconBorder")
						customBorderTexture:SetAllPoints(borderFrame)
						-- Use ADD blend mode which treats black as transparent
						customBorderTexture:SetBlendMode("ADD")							-- Figure out what color to use for the border
							local borderColor
							if zBarButtonBG.charSettings.useClassColorBorder then
								local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
								borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
							else
								borderColor = zBarButtonBG.charSettings.borderColor
							end
							
							-- Use color picker's alpha for overall border transparency (ADD mode handles black=transparent)
							customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						else
							-- For square buttons, create our custom 4-edge border
							-- Parent to button's parent to avoid inheriting button's clipping region
							borderFrame = CreateFrame("Frame", nil, UIParent)
							-- Use MEDIUM strata to stay below other UI elements
							borderFrame:SetFrameStrata("MEDIUM")
							borderFrame:SetFrameLevel(button:GetFrameLevel() + 10)
							-- Disable clipping on the border frame
							borderFrame:SetClipsChildren(false)
						
						local borderWidth = zBarButtonBG.charSettings.borderWidth or 1
						
						-- Position it to match the button exactly
						borderFrame:SetAllPoints(button)
						
						-- Figure out what color to use for the border
						local borderColor
						if zBarButtonBG.charSettings.useClassColorBorder then
							local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
							borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
						else
							borderColor = zBarButtonBG.charSettings.borderColor
						end
						
						-- First create solid black backing layers to prevent transparency overlap at corners
						borderTopBG = borderFrame:CreateTexture(nil, "OVERLAY", nil, -1)
						borderTopBG:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", borderWidth, 0)
						borderTopBG:SetPoint("TOPRIGHT", borderFrame, "TOPRIGHT", -borderWidth, 0)
						borderTopBG:SetHeight(borderWidth)
						borderTopBG:SetColorTexture(0, 0, 0, 1)
						
						borderBottomBG = borderFrame:CreateTexture(nil, "OVERLAY", nil, -1)
						borderBottomBG:SetPoint("BOTTOMLEFT", borderFrame, "BOTTOMLEFT", borderWidth, 0)
						borderBottomBG:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", -borderWidth, 0)
						borderBottomBG:SetHeight(borderWidth)
						borderBottomBG:SetColorTexture(0, 0, 0, 1)
						
						borderLeftBG = borderFrame:CreateTexture(nil, "OVERLAY", nil, -1)
						borderLeftBG:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", 0, 0)
						borderLeftBG:SetPoint("BOTTOMLEFT", borderFrame, "BOTTOMLEFT", 0, 0)
						borderLeftBG:SetWidth(borderWidth)
						borderLeftBG:SetColorTexture(0, 0, 0, 1)
						
						borderRightBG = borderFrame:CreateTexture(nil, "OVERLAY", nil, -1)
						borderRightBG:SetPoint("TOPRIGHT", borderFrame, "TOPRIGHT", 0, 0)
						borderRightBG:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", 0, 0)
						borderRightBG:SetWidth(borderWidth)
						borderRightBG:SetColorTexture(0, 0, 0, 1)
						
						-- Create 4 separate textures for each edge of the border (colored layer on top)
						-- Using OVERLAY layer to prevent clipping by bar artwork
						-- Top edge
						borderTop = borderFrame:CreateTexture(nil, "OVERLAY")
						borderTop:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", borderWidth, 0)
						borderTop:SetPoint("TOPRIGHT", borderFrame, "TOPRIGHT", -borderWidth, 0)
						borderTop:SetHeight(borderWidth)
						borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						
						-- Bottom edge
						borderBottom = borderFrame:CreateTexture(nil, "OVERLAY")
						borderBottom:SetPoint("BOTTOMLEFT", borderFrame, "BOTTOMLEFT", borderWidth, 0)
						borderBottom:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", -borderWidth, 0)
						borderBottom:SetHeight(borderWidth)
						borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						
						-- Left edge
						borderLeft = borderFrame:CreateTexture(nil, "OVERLAY")
						borderLeft:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", 0, 0)
						borderLeft:SetPoint("BOTTOMLEFT", borderFrame, "BOTTOMLEFT", 0, 0)
						borderLeft:SetWidth(borderWidth)
						borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						
						-- Right edge
						borderRight = borderFrame:CreateTexture(nil, "OVERLAY")
						borderRight:SetPoint("TOPRIGHT", borderFrame, "TOPRIGHT", 0, 0)
						borderRight:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", 0, 0)
						borderRight:SetWidth(borderWidth)
						borderRight:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						end -- end of else block for square button borders
					end

					-- Store references to everything we created so we can update or remove it later
					zBarButtonBG.frames[buttonName] = {
						outerFrame = outerFrame,
						outerBg = outerBg,
						frame = bgFrame,
						bg = bg,
						borderFrame = borderFrame,
						borderTop = borderTop,
						borderBottom = borderBottom,
						borderLeft = borderLeft,
						borderRight = borderRight,
						borderTopBG = borderTopBG,
						borderBottomBG = borderBottomBG,
						borderLeftBG = borderLeftBG,
						borderRightBG = borderRightBG,
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
					
					-- Apply or remove squared icon styling based on current setting
					if zBarButtonBG.charSettings.squareButtons then
						-- Remove the mask to square it off
						if button.icon and button.IconMask then
							button.icon:RemoveMaskTexture(button.IconMask)
						end
						
						-- Reapply the icon scaling and cropping
						if button.icon then
							-- Reset scale to default
							button.icon:SetScale(1.0)
							button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							-- Constrain icon to be 2px smaller on all sides to prevent border clipping
							button.icon:ClearAllPoints()
							button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
							button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
						end
						
						-- Update overlay textures too
						local inset = 2
						if button.HighlightTexture then
							button.HighlightTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							button.HighlightTexture:ClearAllPoints()
							button.HighlightTexture:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button.HighlightTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button.HighlightTexture:SetAlpha(1)
						end
						if button.CheckedTexture then
							button.CheckedTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							button.CheckedTexture:ClearAllPoints()
							button.CheckedTexture:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button.CheckedTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button.CheckedTexture:SetAlpha(1)
						end
						if button.PushedTexture then
							button.PushedTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							button.PushedTexture:ClearAllPoints()
							button.PushedTexture:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button.PushedTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button.PushedTexture:SetAlpha(1)
						end
						if button.Flash then
							button.Flash:SetTexCoord(0.08, 0.92, 0.08, 0.92)
							button.Flash:ClearAllPoints()
							button.Flash:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button.Flash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button.Flash:SetAlpha(1)
						end
					else
						-- Restore rounded icon appearance with custom mask
						if button.icon then
							-- Remove Blizzard's mask
							if button.IconMask then
								button.icon:RemoveMaskTexture(button.IconMask)
							end
							
							-- Scale up slightly to zoom in and hide any icon border
							button.icon:SetScale(1.05)
							
							-- Crop the texture coordinates to remove edges
							button.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
							
							-- Restore default positioning
							button.icon:ClearAllPoints()
							button.icon:SetAllPoints(button)
							
							-- Apply our custom mask texture
							if not button._zBBG_customMask then
								button._zBBG_customMask = button:CreateMaskTexture()
								button._zBBG_customMask:SetTexture("Interface/AddOns/zBarButtonBG/Assets/ButtonIconMask")
								button._zBBG_customMask:SetAllPoints(button)
							end
							button.icon:AddMaskTexture(button._zBBG_customMask)
						end
						
						-- Reset overlay textures to default (clear custom anchors)
						-- Also ensure they're fully visible for round buttons
						if button.HighlightTexture then
							button.HighlightTexture:SetTexCoord(0, 1, 0, 1)
							button.HighlightTexture:ClearAllPoints()
							button.HighlightTexture:SetAlpha(1)
							-- Let Blizzard's default anchors take over
						end
						if button.CheckedTexture then
							button.CheckedTexture:SetTexCoord(0, 1, 0, 1)
							button.CheckedTexture:ClearAllPoints()
							button.CheckedTexture:SetAlpha(1)
						end
						if button.PushedTexture then
							button.PushedTexture:SetTexCoord(0, 1, 0, 1)
							button.PushedTexture:ClearAllPoints()
							button.PushedTexture:SetAlpha(1)
						end
						if button.Flash then
							button.Flash:SetTexCoord(0, 1, 0, 1)
							button.Flash:ClearAllPoints()
							button.Flash:SetAlpha(1)
						end
					end
					
					-- Update custom highlight positioning based on current mode
					if button._zBBG_customHighlight then
						local inset = zBarButtonBG.charSettings.showBorder and (zBarButtonBG.charSettings.borderWidth or 1) or 0
						button._zBBG_customHighlight:ClearAllPoints()
						if zBarButtonBG.charSettings.squareButtons then
							-- Square mode: inset by border width
							button._zBBG_customHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", inset, -inset)
							button._zBBG_customHighlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -inset, inset)
							button._zBBG_customHighlight:SetTexCoord(0, 1, 0, 1)
							-- Remove mask for square
							if button.IconMask then
								button._zBBG_customHighlight:RemoveMaskTexture(button.IconMask)
							end
						else
							-- Round mode: follow icon and use mask
							button._zBBG_customHighlight:SetAllPoints(button.icon)
							if button.IconMask then
								button._zBBG_customHighlight:AddMaskTexture(button.IconMask)
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
						
						-- Apply custom mask for round buttons to clip the SlotBackground
						if not zBarButtonBG.charSettings.squareButtons then
							if button._zBBG_customMask then
								button.SlotBackground:AddMaskTexture(button._zBBG_customMask)
							end
						else
							-- Remove mask for square buttons
							if button._zBBG_customMask then
								button.SlotBackground:RemoveMaskTexture(button._zBBG_customMask)
							end
						end
					end
					
					-- Make sure our background frames are visible
					if data.outerFrame then
						data.outerFrame:Show()
					end
					if data.frame then
						data.frame:Show()
					end
					
					-- Update the colors (might have changed in settings or toggled class colors)
					local outer, inner
					if zBarButtonBG.charSettings.useClassColorOuter then
						local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
						outer = {r = classColor.r, g = classColor.g, b = classColor.b, a = zBarButtonBG.charSettings.outerColor.a}
					else
						outer = zBarButtonBG.charSettings.outerColor
					end
					
					if zBarButtonBG.charSettings.useClassColorInner then
						local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
						inner = {r = classColor.r, g = classColor.g, b = classColor.b, a = zBarButtonBG.charSettings.innerColor.a}
					else
						inner = zBarButtonBG.charSettings.innerColor
					end
					
					if data.outerBg then
						data.outerBg:SetColorTexture(outer.r, outer.g, outer.b, outer.a)
					end
					if data.bg then
						data.bg:SetColorTexture(inner.r, inner.g, inner.b, inner.a)
					end
					
					-- Handle border updates
					if zBarButtonBG.charSettings.showBorder and button.icon then
						-- For round buttons, just use the NormalTexture (handled elsewhere)
						-- For square buttons, create/update custom borders
						if zBarButtonBG.charSettings.squareButtons then
							local borderWidth = zBarButtonBG.charSettings.borderWidth or 1
							
							-- Figure out the border color
							local borderColor
							if zBarButtonBG.charSettings.useClassColorBorder then
								local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
								borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
							else
								borderColor = zBarButtonBG.charSettings.borderColor
							end
							
							if not data.borderFrame then
							-- Border wasn't created initially, make it now
							-- Parent to button so it follows but stays just above the icon
							data.borderFrame = CreateFrame("Frame", nil, UIParent)
							data.borderFrame:SetFrameLevel(button:GetFrameLevel() + 1)
							
							-- Position to fill the button
							data.borderFrame:SetAllPoints(button)
							
							-- Create the four edges using BACKGROUND layer so flyout arrows render on top
							-- Top edge
							data.borderTop = data.borderFrame:CreateTexture(nil, "BACKGROUND")
							data.borderTop:SetPoint("TOPLEFT", data.borderFrame, "TOPLEFT", 0, 0)
							data.borderTop:SetPoint("TOPRIGHT", data.borderFrame, "TOPRIGHT", 0, 0)
							data.borderTop:SetHeight(borderWidth)
							data.borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
							
							-- Bottom edge
							data.borderBottom = data.borderFrame:CreateTexture(nil, "BACKGROUND")
							data.borderBottom:SetPoint("BOTTOMLEFT", data.borderFrame, "BOTTOMLEFT", 0, 0)
							data.borderBottom:SetPoint("BOTTOMRIGHT", data.borderFrame, "BOTTOMRIGHT", 0, 0)
							data.borderBottom:SetHeight(borderWidth)
							data.borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
							
							-- Left edge
							data.borderLeft = data.borderFrame:CreateTexture(nil, "BACKGROUND")
							data.borderLeft:SetPoint("TOPLEFT", data.borderFrame, "TOPLEFT", 0, 0)
							data.borderLeft:SetPoint("BOTTOMLEFT", data.borderFrame, "BOTTOMLEFT", 0, 0)
							data.borderLeft:SetWidth(borderWidth)
							data.borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
							
							-- Right edge
							data.borderRight = data.borderFrame:CreateTexture(nil, "BACKGROUND")
							data.borderRight:SetPoint("TOPRIGHT", data.borderFrame, "TOPRIGHT", 0, 0)
							data.borderRight:SetPoint("BOTTOMRIGHT", data.borderFrame, "BOTTOMRIGHT", 0, 0)
							data.borderRight:SetWidth(borderWidth)
							data.borderRight:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						else
							-- Border already exists, just update it
							data.borderFrame:Show()
							
							-- Update the sizes and colors of each edge
							if data.borderTop then
								data.borderTop:SetHeight(borderWidth)
								data.borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
							end
							if data.borderBottom then
								data.borderBottom:SetHeight(borderWidth)
								data.borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
							end
							if data.borderLeft then
								data.borderLeft:SetWidth(borderWidth)
								data.borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
							end
							if data.borderRight then
								data.borderRight:SetWidth(borderWidth)
								data.borderRight:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
							end
						end
						end -- end of squareButtons check for custom borders
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
		updateFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
		updateFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
		updateFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
		updateFrame:RegisterEvent("UPDATE_BINDINGS")
		updateFrame:SetScript("OnEvent", function()
			if zBarButtonBG.enabled then
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
					local borderColor
					if zBarButtonBG.charSettings.useClassColorBorder then
						local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
						borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
					else
						borderColor = zBarButtonBG.charSettings.borderColor
					end
					button.NormalTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
				else
					-- Round buttons without borders: make it transparent
					button.NormalTexture:SetAlpha(0)
				end
			end
		end
		
		-- Hook the range indicator update (this one definitely exists)
		hooksecurefunc("ActionButton_UpdateRangeIndicator", manageNormalTexture)
		
		-- Also set up a periodic check to manage NormalTextures consistently
		local manageFrame = CreateFrame("Frame")
		manageFrame:SetScript("OnUpdate", function(self, elapsed)
			self.timer = (self.timer or 0) + elapsed
			if self.timer >= 0.5 then  -- Check twice per second
				self.timer = 0
				if zBarButtonBG.enabled then
					for buttonName, data in pairs(zBarButtonBG.frames) do
						if data.button and data.button._zBBG_styled then
							local buttonShown = data.button:IsShown()
							
							-- Always keep NormalTexture invisible (we use custom textures now)
							if data.button.NormalTexture then
								data.button.NormalTexture:SetAlpha(0)
							end
							
							-- Manage border frame visibility for square buttons
							if data.borderFrame and zBarButtonBG.charSettings.squareButtons then
								if buttonShown then
									data.borderFrame:Show()
								else
									data.borderFrame:Hide()
								end
							end
						end
					end
				end
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
			-- Hide the border frames if they exist
			if data.borderTop then data.borderTop:Hide() end
			if data.borderBottom then data.borderBottom:Hide() end
			if data.borderLeft then data.borderLeft:Hide() end
			if data.borderRight then data.borderRight:Hide() end
			-- Hide the border backing layers too
			if data.borderTopBG then data.borderTopBG:Hide() end
			if data.borderBottomBG then data.borderBottomBG:Hide() end
			if data.borderLeftBG then data.borderLeftBG:Hide() end
			if data.borderRightBG then data.borderRightBG:Hide() end
			-- Hide the custom border frame for round buttons
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
					data.button.SlotBackground:RemoveMaskTexture(data.button._zBBG_customMask)
				end
			end
			
			-- Reset the icon back to normal size and coords
			if data.button and data.button.icon then
				data.button.icon:SetScale(1.0)
				data.button.icon:SetTexCoord(0, 1, 0, 1)
				-- Remove our custom mask and restore Blizzard's mask
				if data.button._zBBG_customMask then
					data.button.icon:RemoveMaskTexture(data.button._zBBG_customMask)
				end
				if data.button.IconMask then
					data.button.icon:AddMaskTexture(data.button.IconMask)
				end
			end
			
			-- Remove custom highlight and restore Blizzard's default
			if data.button then
				if data.button._zBBG_customHighlight then
					data.button._zBBG_customHighlight:Hide()
					-- Remove our custom mask from the highlight
					if data.button._zBBG_customMask then
						data.button._zBBG_customHighlight:RemoveMaskTexture(data.button._zBBG_customMask)
					end
				end
				if data.button.HighlightTexture then
					data.button.HighlightTexture:SetAlpha(1)
				end
				if data.button.PushedTexture then
					data.button.PushedTexture:SetAlpha(1)
				end
				if data.button.CheckedTexture then
					data.button.CheckedTexture:SetAlpha(1)
				end
			end
			
			-- Reset overlay textures back to normal
			if data.button then
				if data.button.HighlightTexture then
					data.button.HighlightTexture:SetTexCoord(0, 1, 0, 1)
					data.button.HighlightTexture:ClearAllPoints()
					data.button.HighlightTexture:SetAlpha(1)
				end
				if data.button.CheckedTexture then
					data.button.CheckedTexture:SetTexCoord(0, 1, 0, 1)
					data.button.CheckedTexture:ClearAllPoints()
					data.button.CheckedTexture:SetAlpha(1)
				end
				if data.button.PushedTexture then
					data.button.PushedTexture:SetTexCoord(0, 1, 0, 1)
					data.button.PushedTexture:ClearAllPoints()
					data.button.PushedTexture:SetAlpha(1)
				end
				if data.button.Flash then
					data.button.Flash:SetTexCoord(0, 1, 0, 1)
					data.button.Flash:ClearAllPoints()
					data.button.Flash:SetAlpha(1)
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
	
	if msg == "test" or msg == "debug" then
		-- Test if custom textures can be loaded
		zBarButtonBG.print("Testing custom texture loading...")
		
		-- Test mask texture (no extension)
		local testFrame1 = CreateFrame("Frame", nil, UIParent)
		local testTex1 = testFrame1:CreateTexture()
		testTex1:SetTexture("Interface/AddOns/zBarButtonBG/Assets/ButtonIconMask")
		local result1 = testTex1:GetTexture()
		if result1 then
			zBarButtonBG.print("|cFF00FF00SUCCESS:|r ButtonIconMask loaded: " .. tostring(result1))
		else
			zBarButtonBG.print("|cFFFF0000FAILED:|r ButtonIconMask returned nil")
		end
		
		-- Test border texture (no extension)
		local testFrame2 = CreateFrame("Frame", nil, UIParent)
		local testTex2 = testFrame2:CreateTexture()
		testTex2:SetTexture("Interface/AddOns/zBarButtonBG/Assets/ButtonIconBorder")
		local result2 = testTex2:GetTexture()
		if result2 then
			zBarButtonBG.print("|cFF00FF00SUCCESS:|r ButtonIconBorder loaded: " .. tostring(result2))
		else
			zBarButtonBG.print("|cFFFF0000FAILED:|r ButtonIconBorder returned nil")
		end
		
		-- Check if any buttons have the custom mask applied
		local maskCount = 0
		for buttonName, data in pairs(zBarButtonBG.frames) do
			if data.button and data.button._zBBG_customMask then
				maskCount = maskCount + 1
				local maskTex = data.button._zBBG_customMask:GetTexture()
				if maskCount == 1 then
					zBarButtonBG.print("First button (" .. buttonName .. ") mask: " .. tostring(maskTex or "nil"))
				end
			end
		end
		zBarButtonBG.print("Buttons with custom mask: " .. maskCount)
		
		-- Check if any buttons have the custom border texture
		local borderCount = 0
		for buttonName, data in pairs(zBarButtonBG.frames) do
			if data.customBorderTexture then
				borderCount = borderCount + 1
				local borderTex = data.customBorderTexture:GetTexture()
				if borderCount == 1 then
					zBarButtonBG.print("First button (" .. buttonName .. ") border: " .. tostring(borderTex or "nil"))
				end
			end
		end
		zBarButtonBG.print("Buttons with custom border: " .. borderCount)
		
	elseif msg == "show" or msg == "visual" then
		-- Visual test: display the mask and border textures on screen
		zBarButtonBG.print("Displaying test textures (type '/zbg hide' to remove)")
		
		-- Create mask display frame
		if not _G["ZBBG_TEST_MASK"] then
			local f = CreateFrame("Frame", "ZBBG_TEST_MASK", UIParent)
			f:SetSize(128, 128)
			f:SetPoint("CENTER", -80, 0)
			local t = f:CreateTexture(nil, "ARTWORK")
			t:SetAllPoints(f)
			t:SetTexture("Interface/AddOns/zBarButtonBG/Assets/ButtonIconMask")
			f.tex = t
			local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetPoint("TOP", f, "BOTTOM", 0, -5)
			label:SetText("Mask (white=show, black=hide)")
		end
		_G["ZBBG_TEST_MASK"]:Show()
		
		-- Create border display frame with ADD blend mode
		if not _G["ZBBG_TEST_BORDER"] then
			local f = CreateFrame("Frame", "ZBBG_TEST_BORDER", UIParent)
			f:SetSize(128, 128)
			f:SetPoint("CENTER", 80, 0)
			local t = f:CreateTexture(nil, "ARTWORK")
			t:SetAllPoints(f)
			t:SetTexture("Interface/AddOns/zBarButtonBG/Assets/ButtonIconBorder")
			t:SetBlendMode("ADD")
			-- Color it red so we can see SetVertexColor works
			t:SetVertexColor(1, 0, 0, 1)
			f.tex = t
			local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			label:SetPoint("TOP", f, "BOTTOM", 0, -5)
			label:SetText("Border (ADD mode, colored red)")
		end
		_G["ZBBG_TEST_BORDER"]:Show()
		
	elseif msg == "hide" then
		-- Hide visual test frames
		if _G["ZBBG_TEST_MASK"] then _G["ZBBG_TEST_MASK"]:Hide() end
		if _G["ZBBG_TEST_BORDER"] then _G["ZBBG_TEST_BORDER"]:Hide() end
		zBarButtonBG.print("Test textures hidden")
		
	else
		zBarButtonBG.toggle()
	end
end
