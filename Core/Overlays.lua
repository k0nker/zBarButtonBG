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
