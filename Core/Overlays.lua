-- Cooldown and range overlay management for zBarButtonBG

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.Overlays = {}
local Overlays = addonTable.Core.Overlays

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
