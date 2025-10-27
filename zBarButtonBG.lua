zBarButtonBG = {}

-- ############################################################
-- Init on login
-- ############################################################
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		-- Ensure global table exists
		zBarButtonBGSaved = zBarButtonBGSaved or {}

		-- Get player identity
		local realmName = GetRealmName()
		local charName = UnitName("player")

		-- Create character-specific entry inside the global saved var
		zBarButtonBGSaved[realmName] = zBarButtonBGSaved[realmName] or {}
		zBarButtonBGSaved[realmName][charName] = zBarButtonBGSaved[realmName][charName] or {}

		-- Shortcut for this char's settings
		zBarButtonBG.charSettings = zBarButtonBGSaved[realmName][charName]

		-- Action bar background settings
		zBarButtonBG.charSettings.enabled = zBarButtonBG.charSettings.enabled or false

		-- Apply saved action bar background settings
		if zBarButtonBG.charSettings.enabled then
			zBarButtonBG.enabled = true
			-- Delay creation slightly to ensure action bars are loaded
			C_Timer.After(3.5, function()
				zBarButtonBG.createActionBarBackgrounds()
			end)
		end
	end
end)

-- Action Bar Background Toggle
zBarButtonBG.enabled = false
zBarButtonBG.frames = {}

-- Function to print messages from this addon
function zBarButtonBG.print(arg)
	if arg == "" or arg == nil then
		return
	else
		print("|cFF72B061zBarButtonBG:|r " .. arg)
	end
	-- End print()
	return false
end

-- Replacement texture and atlas data for rounded buttons
local replacementTexture = "Interface/Addons/zBarButtonBG/Assets/uiactionbar2x"
local replacementAtlas = {
	["UI-HUD-ActionBar-IconFrame-Slot"] = { 64, 31, 0.701172, 0.951172, 0.102051, 0.162598, false, false, "2x" },
	["UI-HUD-ActionBar-IconFrame"] = { 46, 22, 0.701172, 0.880859, 0.316895, 0.36084, false, false, "2x" },
	["UI-HUD-ActionBar-IconFrame-AddRow"] = { 51, 25, 0.701172, 0.900391, 0.215332, 0.265137, false, false, "2x" },
	["UI-HUD-ActionBar-IconFrame-Down"] = { 46, 22, 0.701172, 0.880859, 0.430176, 0.474121, false, false, "2x" },
	["UI-HUD-ActionBar-IconFrame-Flash"] = { 46, 22, 0.701172, 0.880859, 0.475098, 0.519043, false, false, "2x" },
	["UI-HUD-ActionBar-IconFrame-FlyoutBorderShadow"] = { 52, 26, 0.701172, 0.904297, 0.163574, 0.214355, false, false, "2x" },
	["UI-HUD-ActionBar-IconFrame-Mouseover"] = { 46, 22, 0.701172, 0.880859, 0.52002, 0.563965, false, false, "2x" },
	["UI-HUD-ActionBar-IconFrame-Border"] = { 46, 22, 0.701172, 0.880859, 0.361816, 0.405762, false, false, "2x" },
	["UI-HUD-ActionBar-IconFrame-AddRow-Down"] = { 51, 25, 0.701172, 0.900391, 0.266113, 0.315918, false, false, "2x" },
}

local function RemapTexture(texture, replacementTexture)
	if not texture then return end
	local atlasId = texture:GetAtlas()
	local atlas = replacementAtlas[atlasId]

	-- don't even attempt to remap if the atlas is missing
	if atlas == nil then
		zBarButtonBG.print("Missing atlas for: " .. tostring(atlasId))
		return
	else
		zBarButtonBG.print("Remapping atlas: " .. tostring(atlasId))
	end

	local width = texture:GetWidth()
	local height = texture:GetHeight()
	texture:SetTexture(replacementTexture)
	texture:SetTexCoord(atlas[3], atlas[4], atlas[5], atlas[6])
	texture:SetWidth(width)
	texture:SetHeight(height)
end

function zBarButtonBG.toggle()
	zBarButtonBG.enabled = not zBarButtonBG.enabled

	if zBarButtonBG.enabled then
		zBarButtonBG.createActionBarBackgrounds()
		zBarButtonBG.print("Action bar backgrounds |cFF00FF00enabled|r")
	else
		zBarButtonBG.removeActionBarBackgrounds()
		zBarButtonBG.print("Action bar backgrounds |cFFFF0000disabled|r")
	end

	-- Save settings to character-specific saved variables
	if zBarButtonBG.charSettings then
		zBarButtonBG.charSettings.enabled = zBarButtonBG.enabled
	end
end

function zBarButtonBG.createActionBarBackgrounds()
	-- List of action bar button names to check
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
		local maxButtons = (baseName == "PetActionButton" or baseName == "StanceButton") and 10 or 12
		for i = 1, maxButtons do
			local buttonName = baseName .. i
			local button = _G[buttonName]

			if button and button:IsVisible() then
				-- Check if we already created a background for this button
				if not zBarButtonBG.frames[buttonName] then
					-- Hide the default button border and remove icon mask
					if button.NormalTexture then
						button.NormalTexture:Hide()
					end
					if button.icon and button.IconMask then
						button.icon:RemoveMaskTexture(button.IconMask)
					end

					-- Make the icon slightly larger and clip it to button bounds
					if button.icon then
						-- Reset to base scale first to ensure consistent behavior
						button.icon:SetScale(0.7)
						-- Scale up the icon slightly to fill rounded corners
						--button.icon:SetScale(1.08)
						-- Ensure icon is clipped to button bounds - crop a bit more from edges
						button.icon:SetTexCoord(0.8, 0.92, 0.8, 0.92)
					end

					-- Hide normal texture on show
					if button.NormalTexture then
						button.NormalTexture:HookScript("OnShow", function(self) self:Hide() end)
					end

					-- Adjust button overlays with rounded texture
					if button.cooldown then
						button.cooldown:SetAllPoints(button)
					end
					RemapTexture(button.HighlightTexture, replacementTexture)
					RemapTexture(button.CheckedTexture, replacementTexture)
					RemapTexture(button.SpellHighlightTexture, replacementTexture)
					RemapTexture(button.NewActionTexture, replacementTexture)
					RemapTexture(button.PushedTexture, replacementTexture)
					RemapTexture(button.Border, replacementTexture)

					if button.SlotBackground then
						button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
					end

					-- Hide spell cast animations
					if button.SpellCastAnimFrame then
						button.SpellCastAnimFrame:SetScript("OnShow", function(self) self:Hide() end)
					end
					if button.InterruptDisplay then
						button.InterruptDisplay:SetScript("OnShow", function(self) self:Hide() end)
					end

					-- Create the outer black background frame (extends 5px beyond button)
					local outerFrame = CreateFrame("Frame", nil, button)
					outerFrame:SetPoint("TOPLEFT", button, "TOPLEFT", -5, 5)
					outerFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 5, -5)
					outerFrame:SetFrameLevel(0)  -- Very back layer
					outerFrame:SetFrameStrata("BACKGROUND")

					-- Create solid black background texture for outer frame
					local outerBg = outerFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
					outerBg:SetAllPoints(outerFrame)
					outerBg:SetColorTexture(0, 0, 0, 1) -- Solid black

					-- Create a frame for the dark grey button background
					local bgFrame = CreateFrame("Frame", nil, button)
					bgFrame:SetAllPoints(button)
					bgFrame:SetFrameLevel(0)  -- Very back layer
					bgFrame:SetFrameStrata("BACKGROUND")

					-- Create dark grey background texture
					local bg = bgFrame:CreateTexture(nil, "BACKGROUND", nil, -7)
					bg:SetAllPoints(bgFrame)
					bg:SetColorTexture(0.1, 0.1, 0.1, 0.75) -- Dark grey

					-- Store the references
					zBarButtonBG.frames[buttonName] = {
						outerFrame = outerFrame,
						outerBg = outerBg,
						frame = bgFrame,
						bg = bg,
						button = button
					}
					if button.icon and button.IconMask then
						button.icon:RemoveMaskTexture(button.IconMask)
					end
				else
					-- Update existing frames - make sure everything is reapplied
					local data = zBarButtonBG.frames[buttonName]
					
					-- Reapply icon modifications (reset scale first for consistency)
					if button.icon then
						-- Reset scale first to ensure consistent behavior
						button.icon:SetScale(0.7)
						-- Then apply our desired scale
						--button.icon:SetScale(1.08)
						button.icon:SetTexCoord(0.8, 0.92, 0.8, 0.92)
					end
					if button.icon and button.IconMask then
						button.icon:RemoveMaskTexture(button.IconMask)
					end
					
					-- Show frames
					if data.outerFrame then
						data.outerFrame:Show()
					end
					if data.frame then
						data.frame:Show()
					end
				end
			end
		end
	end

	-- Hook into action bar visibility changes to add backgrounds dynamically
	if not zBarButtonBG.hookInstalled then
		-- Create a frame to listen for action bar updates
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
		zBarButtonBG.hookInstalled = true
	end
end

function zBarButtonBG.removeActionBarBackgrounds()
	for buttonName, data in pairs(zBarButtonBG.frames) do
		if data then
			-- Hide the outer black frame
			if data.outerFrame then
				data.outerFrame:Hide()
			end
			-- Hide the grey button frame
			if data.frame then
				data.frame:Hide()
			end
			-- Restore button normal texture
			if data.button and data.button.NormalTexture then
				data.button.NormalTexture:Show()
			end
			-- Restore icon to normal size and texture coords
			if data.button and data.button.icon then
				data.button.icon:SetScale(1.0)
				data.button.icon:SetTexCoord(0, 1, 0, 1)
			end
			-- Restore icon mask if it was removed
			if data.button and data.button.icon and data.button.IconMask then
				data.button.icon:AddMaskTexture(data.button.IconMask)
			end
		end
	end
end

-- Slash command registration
SLASH_ZBARBUTTONBG1 = "/zbg"
SlashCmdList["ZBARBUTTONBG"] = function(msg)
	zBarButtonBG.toggle()
end
