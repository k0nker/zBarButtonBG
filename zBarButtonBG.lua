zBarButtonBG = {}

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
		zBarButtonBG.charSettings.enabled = zBarButtonBG.charSettings.enabled or false
		-- For boolean settings that default to true, we need to check if they're nil specifically
		if zBarButtonBG.charSettings.squareButtons == nil then
			zBarButtonBG.charSettings.squareButtons = true
		end
		zBarButtonBG.charSettings.outerColor = zBarButtonBG.charSettings.outerColor or {r = 0, g = 0, b = 0, a = 1}
		zBarButtonBG.charSettings.innerColor = zBarButtonBG.charSettings.innerColor or {r = 0.1, g = 0.1, b = 0.1, a = 0.75}
		zBarButtonBG.charSettings.showBorder = zBarButtonBG.charSettings.showBorder ~= nil and zBarButtonBG.charSettings.showBorder or false
		zBarButtonBG.charSettings.borderWidth = zBarButtonBG.charSettings.borderWidth or 1
		zBarButtonBG.charSettings.borderColor = zBarButtonBG.charSettings.borderColor or {r = 1, g = 1, b = 1, a = 1}
		zBarButtonBG.charSettings.useClassColorBorder = zBarButtonBG.charSettings.useClassColorBorder or false
		zBarButtonBG.charSettings.useClassColorOuter = zBarButtonBG.charSettings.useClassColorOuter or false
		zBarButtonBG.charSettings.useClassColorInner = zBarButtonBG.charSettings.useClassColorInner or false

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
					
					-- Only hide the default border texture if we're using square buttons
					-- If using round buttons, we can use it for borders instead
					if button.NormalTexture and zBarButtonBG.charSettings.squareButtons then
						button.NormalTexture:Hide()
					end
					
					-- Square off the icons if that option is enabled
					if zBarButtonBG.charSettings.squareButtons then
						-- Remove the icon mask that makes it rounded
						if button.icon and button.IconMask then
							button.icon:RemoveMaskTexture(button.IconMask)
						end

						-- Scale up the icon and crop the edges to square it off
						if button.icon then
							-- Reset to 1.0 first to make sure we're starting from a consistent state
							button.icon:SetScale(1.0)
							-- Scale it up a bit to fill in where the rounded corners were
							button.icon:SetScale(1.08)
							-- Crop the edges to make it square instead of round
							button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						end
						
						-- Crop the highlight and other overlay textures to match our squared-off icon
						if button.HighlightTexture then
							button.HighlightTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						end
						if button.CheckedTexture then
							button.CheckedTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						end
						if button.PushedTexture then
							button.PushedTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						end
					end

					-- Make the cooldown spiral fill the whole button
					if button.cooldown then
						button.cooldown:SetAllPoints(button)
					end
					
					-- Replace the beveled SlotBackground with a flat texture if borders are enabled
					if button.SlotBackground then
						if zBarButtonBG.charSettings.showBorder then
							-- Use a flat white texture we can make transparent
							button.SlotBackground:SetTexture("Interface\\Buttons\\WHITE8X8")
							button.SlotBackground:SetVertexColor(0, 0, 0, 0)
							button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
						else
							-- Keep the default texture when borders are off
							button.SlotBackground:SetTexture(nil)
							button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
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
					if zBarButtonBG.charSettings.showBorder and button.icon then
						-- For round buttons, just use and color Blizzard's NormalTexture
						if not zBarButtonBG.charSettings.squareButtons and button.NormalTexture then
							button.NormalTexture:Show()
							
							-- Figure out what color to use for the border
							local borderColor
							if zBarButtonBG.charSettings.useClassColorBorder then
								local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
								borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
							else
								borderColor = zBarButtonBG.charSettings.borderColor
							end
							
							button.NormalTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						else
							-- For square buttons, create our custom 4-edge border
							-- Parent to UIParent so it doesn't get clipped by the action bar frames
							borderFrame = CreateFrame("Frame", nil, UIParent)
							borderFrame:SetFrameLevel(10000)
							borderFrame:SetFrameStrata("HIGH")
						
						local borderWidth = zBarButtonBG.charSettings.borderWidth or 1
						
						-- Position it to match the button's location on screen
						borderFrame:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
						borderFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
						
						-- Figure out what color to use for the border
						local borderColor
						if zBarButtonBG.charSettings.useClassColorBorder then
							local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
							borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
						else
							borderColor = zBarButtonBG.charSettings.borderColor
						end
						
						-- Create 4 separate textures for each edge of the border
						-- Using BACKGROUND layer so flyout arrows can render on top
						-- Top edge
						borderTop = borderFrame:CreateTexture(nil, "BACKGROUND")
						borderTop:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", 0, 0)
						borderTop:SetPoint("TOPRIGHT", borderFrame, "TOPRIGHT", 0, 0)
						borderTop:SetHeight(borderWidth)
						borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						
						-- Bottom edge
						borderBottom = borderFrame:CreateTexture(nil, "BACKGROUND")
						borderBottom:SetPoint("BOTTOMLEFT", borderFrame, "BOTTOMLEFT", 0, 0)
						borderBottom:SetPoint("BOTTOMRIGHT", borderFrame, "BOTTOMRIGHT", 0, 0)
						borderBottom:SetHeight(borderWidth)
						borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						
						-- Left edge
						borderLeft = borderFrame:CreateTexture(nil, "BACKGROUND")
						borderLeft:SetPoint("TOPLEFT", borderFrame, "TOPLEFT", 0, 0)
						borderLeft:SetPoint("BOTTOMLEFT", borderFrame, "BOTTOMLEFT", 0, 0)
						borderLeft:SetWidth(borderWidth)
						borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						
						-- Right edge
						borderRight = borderFrame:CreateTexture(nil, "BACKGROUND")
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
						button = button
					}
					-- Make sure the mask stays removed
					if button.icon and button.IconMask then
						button.icon:RemoveMaskTexture(button.IconMask)
					end
				else
					-- Button already has backgrounds, just update them with current settings
					local data = zBarButtonBG.frames[buttonName]
					
					-- Handle NormalTexture based on square buttons setting and border setting
					if button.NormalTexture then
						if zBarButtonBG.charSettings.squareButtons then
							-- Square buttons always hide the NormalTexture
							button.NormalTexture:Hide()
						elseif zBarButtonBG.charSettings.showBorder then
							-- Round buttons with borders: show and color the NormalTexture
							button.NormalTexture:Show()
							local borderColor
							if zBarButtonBG.charSettings.useClassColorBorder then
								local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
								borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
							else
								borderColor = zBarButtonBG.charSettings.borderColor
							end
							button.NormalTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
						else
							-- Round buttons without borders: hide NormalTexture
							button.NormalTexture:Hide()
						end
					end
					
					-- Apply or remove squared icon styling based on current setting
					if zBarButtonBG.charSettings.squareButtons then
						-- Remove the mask to square it off
						if button.icon and button.IconMask then
							button.icon:RemoveMaskTexture(button.IconMask)
						end
						
						-- Reapply the icon scaling and cropping
						if button.icon then
							-- Reset first to keep things consistent
							button.icon:SetScale(1.0)
							-- Then scale it up
							button.icon:SetScale(1.08)
							button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						end
						
						-- Update overlay textures too
						if button.HighlightTexture then
							button.HighlightTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						end
						if button.CheckedTexture then
							button.CheckedTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						end
						if button.PushedTexture then
							button.PushedTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
						end
					else
						-- Restore Blizzard's rounded icon appearance
						if button.icon and button.IconMask then
							button.icon:AddMaskTexture(button.IconMask)
						end
						
						-- Reset icon scale and texture coordinates to default
						if button.icon then
							button.icon:SetScale(1.0)
							button.icon:SetTexCoord(0, 1, 0, 1)
						end
						
						-- Reset overlay textures to default
						if button.HighlightTexture then
							button.HighlightTexture:SetTexCoord(0, 1, 0, 1)
						end
						if button.CheckedTexture then
							button.CheckedTexture:SetTexCoord(0, 1, 0, 1)
						end
						if button.PushedTexture then
							button.PushedTexture:SetTexCoord(0, 1, 0, 1)
						end
					end
					
					-- Update the SlotBackground based on whether borders are on or off
					if button.SlotBackground then
						if zBarButtonBG.charSettings.showBorder then
							-- Flat texture when borders are enabled
							button.SlotBackground:SetTexture("Interface\\Buttons\\WHITE8X8")
							button.SlotBackground:SetVertexColor(0, 0, 0, 0)
							button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
						else
							-- Put the default texture back when borders are off
							button.SlotBackground:SetTexture(nil)
							button.SlotBackground:SetVertexColor(1, 1, 1, 1)
							button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
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
							-- Parent to UIParent so it doesn't get clipped
							data.borderFrame = CreateFrame("Frame", nil, UIParent)
							data.borderFrame:SetFrameLevel(10000)
							data.borderFrame:SetFrameStrata("HIGH")
							
							-- Position to match the button
							data.borderFrame:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
							data.borderFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
							
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
		-- This keeps it hidden when we want it hidden, or properly colored when we're using it
		local function manageNormalTexture(button)
			if button and button.NormalTexture and button._zBBG_styled and zBarButtonBG.enabled then
				if zBarButtonBG.charSettings.squareButtons then
					-- Square buttons: always hide it
					button.NormalTexture:Hide()
				elseif zBarButtonBG.charSettings.showBorder then
					-- Round buttons with borders: show and color it
					button.NormalTexture:Show()
					local borderColor
					if zBarButtonBG.charSettings.useClassColorBorder then
						local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
						borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
					else
						borderColor = zBarButtonBG.charSettings.borderColor
					end
					button.NormalTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
				else
					-- Round buttons without borders: hide it
					button.NormalTexture:Hide()
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
						if data.button and data.button.NormalTexture and data.button._zBBG_styled then
							if zBarButtonBG.charSettings.squareButtons then
								-- Square buttons: hide NormalTexture
								data.button.NormalTexture:Hide()
							elseif zBarButtonBG.charSettings.showBorder then
								-- Round buttons with borders: show and color NormalTexture
								data.button.NormalTexture:Show()
								local borderColor
								if zBarButtonBG.charSettings.useClassColorBorder then
									local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
									borderColor = {r = classColor.r, g = classColor.g, b = classColor.b, a = 1}
								else
									borderColor = zBarButtonBG.charSettings.borderColor
								end
								data.button.NormalTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
							else
								-- Round buttons without borders: hide NormalTexture
								data.button.NormalTexture:Hide()
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
			
			-- Put the default border texture back
			if data.button and data.button.NormalTexture then
				data.button.NormalTexture:Show()
			end
			
			-- Restore the default SlotBackground texture
			if data.button and data.button.SlotBackground then
				data.button.SlotBackground:SetTexture(nil)
				data.button.SlotBackground:SetVertexColor(1, 1, 1, 1)
				data.button.SlotBackground:SetDrawLayer("BACKGROUND", 0)
			end
			
			-- Reset the icon back to normal size and coords
			if data.button and data.button.icon then
				data.button.icon:SetScale(1.0)
				data.button.icon:SetTexCoord(0, 1, 0, 1)
			end
			
			-- Reset overlay textures back to normal
			if data.button then
				if data.button.HighlightTexture then
					data.button.HighlightTexture:SetTexCoord(0, 1, 0, 1)
				end
				if data.button.CheckedTexture then
					data.button.CheckedTexture:SetTexCoord(0, 1, 0, 1)
				end
				if data.button.PushedTexture then
					data.button.PushedTexture:SetTexCoord(0, 1, 0, 1)
				end
			end
			
			-- Put the icon mask back on to make it round again
			if data.button and data.button.icon and data.button.IconMask then
				data.button.icon:AddMaskTexture(data.button.IconMask)
			end
		end
	end
end

-- Set up the /zbg slash command
SLASH_ZBARBUTTONBG1 = "/zbg"
SlashCmdList["ZBARBUTTONBG"] = function(msg)
	zBarButtonBG.toggle()
end
