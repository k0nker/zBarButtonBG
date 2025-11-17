-- Cooldown and range overlay management for zBarButtonBG
-- Refactored with metadata-driven approach and centralized overlay creation

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.Overlays = {}
local Overlays = addonTable.Core.Overlays
local Util = addonTable.Core.Utilities

-- ############################################################
-- OVERLAY METADATA
-- ############################################################

Overlays.overlayTypes = {
	CooldownOverlay = {
		key = "_zBBG_cooldownOverlay",
		enabledKey = "fadeCooldown",
		colorKey = "cooldownColor",
		layer = "OVERLAY",
		order = 2,
		description = "Cooldown overlay fade effect",
	},
	RangeOverlay = {
		key = "_zBBG_rangeOverlay",
		enabledKey = "showRangeIndicator",
		colorKey = "rangeIndicatorColor",
		layer = "OVERLAY",
		order = 1,
		description = "Out-of-range indicator overlay",
	},
	CustomHighlight = {
		key = "_zBBG_customHighlight",
		enabledKey = nil,
		colorKey = nil,
		layer = "OVERLAY",
		order = 0,
		description = "Custom hover/highlight overlay",
	},
}

-- ############################################################
-- CENTRALIZED OVERLAY CREATION
-- ############################################################

-- Create an overlay texture on a button
function Overlays.CreateOverlay(button, overlayType, colorData)
	if not button or not overlayType then return end

	local metadata = Overlays.overlayTypes[overlayType]
	if not metadata then return end

	local overlayKey = metadata.key
	local existing = button[overlayKey]

	-- Return existing overlay if already created
	if existing then return existing end

	-- Create new overlay texture
	local overlay = button:CreateTexture(nil, metadata.layer, nil, metadata.order)
	
	-- Apply color if provided
	if colorData then
		overlay:SetColorTexture(colorData.r, colorData.g, colorData.b, colorData.a)
	end

	overlay:Hide() -- Hidden by default
	button[overlayKey] = overlay

	return overlay
end

-- ############################################################
-- COOLDOWN OVERLAY MANAGEMENT
-- ############################################################

-- Update cooldown overlay visibility based on Blizzard cooldown frame
function Overlays.updateCooldownOverlay(button)
	if not button or not button._zBBG_cooldownOverlay or not button._zBBG_styled or not zBarButtonBG.enabled then
		return
	end

	if not zBarButtonBG.charSettings.fadeCooldown or not button.cooldown then
		button._zBBG_cooldownOverlay:Hide()
		return
	end

	-- Check if the Blizzard cooldown frame is visible
	-- If the built-in cooldown is showing, display our overlay; otherwise hide it
	if button.cooldown:IsShown() then
		button._zBBG_cooldownOverlay:Show()
	else
		button._zBBG_cooldownOverlay:Hide()
	end
end

-- ############################################################
-- RANGE OVERLAY MANAGEMENT
-- ############################################################

-- Update range overlay visibility based on action range
function Overlays.updateRangeOverlay(button)
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

-- ############################################################
-- OVERLAY SETUP FUNCTIONS (per-bar skinning)
-- ############################################################

-- Create and position custom highlight overlay
function Overlays.setHighlightOverlay(button, barName)
	if not button then return end
	
	if not button._zBBG_customHighlight then
		button._zBBG_customHighlight = button:CreateTexture(nil, "OVERLAY")
		button._zBBG_customHighlight:SetColorTexture(1, 0.82, 0, 0.5) -- Golden highlight
		button._zBBG_customHighlight:Hide()
	end
	
	button._zBBG_customHighlight:ClearAllPoints()
	button._zBBG_customHighlight:SetAllPoints(button.icon)
	
	-- Mask is automatically applied via button._zBBG_customMask
	if button._zBBG_customMask then
		Util.applyMaskToTexture(button._zBBG_customHighlight, button._zBBG_customMask)
	end
end

-- Create and position custom checked overlay (pet buttons only)
function Overlays.setCheckedOverlay(button, barName)
	if not button then return end
	
	local buttonName = button:GetName()
	local baseName = zBarButtonBG.GetBarNameFromButton(buttonName)
	if baseName ~= "PetActionButton" then return end
	
	if not button._zBBG_customChecked then
		button._zBBG_customChecked = button:CreateTexture(nil, "OVERLAY", nil, 3)
		button._zBBG_customChecked:SetColorTexture(0, 1, 0, 0.3) -- Green checked state
		button._zBBG_customChecked:Hide()
	end
	
	button._zBBG_customChecked:ClearAllPoints()
	button._zBBG_customChecked:SetAllPoints(button.icon)
	
	if button._zBBG_customMask then
		Util.applyMaskToTexture(button._zBBG_customChecked, button._zBBG_customMask)
	end
end

-- Create and position range indicator overlay
function Overlays.setRangeOverlay(button, barName)
	if not button then return end
	
	local showRangeIndicator = zBarButtonBG.GetSettingInfo(barName, "showRangeIndicator")
	
	if showRangeIndicator then
		if not button._zBBG_rangeOverlay then
			button._zBBG_rangeOverlay = button:CreateTexture(nil, "OVERLAY", nil, 1)
			local c = zBarButtonBG.GetSettingInfo(barName, "rangeIndicatorColor")
			button._zBBG_rangeOverlay:SetColorTexture(c.r, c.g, c.b, c.a)
			button._zBBG_rangeOverlay:Hide()
		end
		
		button._zBBG_rangeOverlay:ClearAllPoints()
		button._zBBG_rangeOverlay:SetAllPoints(button.icon)
		
		if button._zBBG_customMask then
			Util.applyMaskToTexture(button._zBBG_rangeOverlay, button._zBBG_customMask)
		end
	elseif button._zBBG_rangeOverlay then
		button._zBBG_rangeOverlay:Hide()
		button._zBBG_rangeOverlay = nil
	end
end

-- Create and position cooldown overlay
function Overlays.setCooldownOverlay(button, barName)
	if not button then return end
	
	local fadeCooldown = zBarButtonBG.GetSettingInfo(barName, "fadeCooldown")
	
	if zBarButtonBG.midnightCooldown and fadeCooldown then
		if not button._zBBG_cooldownOverlay then
			button._zBBG_cooldownOverlay = button:CreateTexture(nil, "BACKGROUND", nil, 1)
			local c = zBarButtonBG.GetSettingInfo(barName, "cooldownColor")
			button._zBBG_cooldownOverlay:SetColorTexture(c.r, c.g, c.b, c.a)
			button._zBBG_cooldownOverlay:Hide()
			
			-- Hook cooldown show/hide to sync overlay
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
		
		button._zBBG_cooldownOverlay:ClearAllPoints()
		button._zBBG_cooldownOverlay:SetAllPoints(button.icon)
		
		if button._zBBG_customMask then
			Util.applyMaskToTexture(button._zBBG_cooldownOverlay, button._zBBG_customMask)
		end
	elseif button._zBBG_cooldownOverlay then
		button._zBBG_cooldownOverlay:Hide()
		button._zBBG_cooldownOverlay = nil
	end
end

