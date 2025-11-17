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

	local overlay = button._zBBG_cooldownOverlay

	if not zBarButtonBG.charSettings.fadeCooldown or not button.cooldown then
		-- Only call Hide if it's currently shown
		if overlay:IsShown() then
			overlay:Hide()
		end
		return
	end

	-- Check if the Blizzard cooldown frame is visible
	-- Only call Show/Hide if state needs to change
	local cooldownShown = button.cooldown:IsShown()
	if cooldownShown and not overlay:IsShown() then
		overlay:Show()
	elseif not cooldownShown and overlay:IsShown() then
		overlay:Hide()
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

	local overlay = button._zBBG_rangeOverlay
	local shouldShow = false

	-- Early exit if button has no action - most buttons are empty so this saves a lot of work
	if not button.action or button.action <= 0 then
		-- Empty button - just hide overlay if it's shown
		if overlay:IsShown() then
			overlay:Hide()
		end
		return
	end

	if zBarButtonBG.charSettings.showRangeIndicator and UnitExists("target") then
		local inRange = IsActionInRange(button.action, "target")

		if zBarButtonBG._debug then
			local actionType, id = GetActionInfo(button.action)
			zBarButtonBG.print("Button: " ..
				(button:GetName() or "Unknown") ..
				", Action: " ..
				button.action ..
				", Type: " .. tostring(actionType) .. ", ID: " .. tostring(id) .. ", InRange: " .. tostring(inRange))
		end

		-- IsActionInRange returns: true = in range, false = out of range, nil = no target/not applicable
		if inRange == false then
			shouldShow = true
			if zBarButtonBG._debug then
				zBarButtonBG.print("Showing range overlay for " .. (button:GetName() or "Unknown"))
			end
		elseif zBarButtonBG._debug and inRange == true then
			zBarButtonBG.print("Hiding range overlay for " .. (button:GetName() or "Unknown") .. " (in range)")
		end
	end

	-- Only call Show/Hide if state needs to change
	if shouldShow and not overlay:IsShown() then
		overlay:Show()
	elseif not shouldShow and overlay:IsShown() then
		overlay:Hide()
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
		button._zBBG_customHighlight:SetAllPoints(button.icon)
		button._zBBG_customHighlight:Hide()
	end
	
	-- Mask with swipe mask texture
	if button._zBBG_swipeMask then
		Util.applyMaskToTexture(button._zBBG_customHighlight, button._zBBG_swipeMask)
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
		button._zBBG_customChecked:SetAllPoints(button.icon)
		button._zBBG_customChecked:Hide()
	end
	
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
			button._zBBG_rangeOverlay:SetAllPoints(button.icon)
			button._zBBG_rangeOverlay:Hide()
		end
		
		if button._zBBG_swipeMask then
			Util.applyMaskToTexture(button._zBBG_rangeOverlay, button._zBBG_swipeMask)
		end
		button._zBBG_rangeOverlay:Show()
	elseif button._zBBG_rangeOverlay then
		button._zBBG_rangeOverlay:Hide()
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
		
		-- Position overlay over the icon
		button._zBBG_cooldownOverlay:ClearAllPoints()
		button._zBBG_cooldownOverlay:SetAllPoints(button.icon)
		
		-- Apply the button shape mask (uses customMask for the button shape)
		if button._zBBG_swipeMask then
			Util.applyMaskToTexture(button._zBBG_cooldownOverlay, button._zBBG_swipeMask)
		end
	elseif button._zBBG_cooldownOverlay then
		button._zBBG_cooldownOverlay:Hide()
	end
end

-- ############################################################
-- FLIPBOOK ANIMATION UPDATES (for dynamic style changes)
-- ############################################################

-- Setup and configure assisted highlight flipbook (called on first show)
function Overlays.setupAssistedHighlightFlipbook(button, barName)
	if not button or not button.AssistedCombatHighlightFrame then
		return
	end

	local highlightFrame = button.AssistedCombatHighlightFrame
	if not highlightFrame.Flipbook then
		return
	end

	local flipbook = highlightFrame.Flipbook
	local ButtonStyles = addonTable.Core.ButtonStyles

	-- Get the style
	local styleName = zBarButtonBG.GetSettingInfo(barName, "buttonStyle") or "Square"
	local procFlipbookTexture = ButtonStyles.GetProcFlipbookPath(styleName)

	-- Replace texture with proc flipbook
	flipbook:SetTexture(procFlipbookTexture)

	-- Desaturate the flipbook to greyscale, then apply suggested action color
	flipbook:SetDesaturated(true)
	local suggestedColor = zBarButtonBG.GetSettingInfo(barName, "suggestedActionColor") or
		{ r = 0.2, g = 0.8, b = 1.0, a = 0.8 }
	flipbook:SetVertexColor(suggestedColor.r, suggestedColor.g, suggestedColor.b, suggestedColor.a)

	-- Match the button size
	local buttonWidth, buttonHeight = button:GetSize()
	flipbook:SetSize(buttonWidth or 36, buttonHeight or 36)
	flipbook:SetPoint("CENTER", button, "CENTER")

	-- Set to BACKGROUND layer so text stays on top
	flipbook:SetDrawLayer("BACKGROUND", 1)
	flipbook:SetParent(button)

	-- Configure the animation frames
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
end

-- Setup and configure spell alert flipbooks (called on first show)
function Overlays.setupSpellAlertFlipbooks(button, barName)
	if not button or not button.SpellActivationAlert then
		return
	end

	local alert = button.SpellActivationAlert
	local ButtonStyles = addonTable.Core.ButtonStyles

	-- Get the style
	local styleName = zBarButtonBG.GetSettingInfo(barName, "buttonStyle") or "Square"
	local procFlipbookTexture = ButtonStyles.GetProcFlipbookPath(styleName)

	local buttonWidth, buttonHeight = button:GetSize()
	local alertWidth = buttonWidth or 36
	local alertHeight = buttonHeight or 36

	-- Resize the alert frame to match button size (MUST do this before setting up flipbooks!)
	alert:SetSize(alertWidth, alertHeight)

	-- Get animation objects
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

	-- Setup ProcLoopFlipbook
	if alert.ProcLoopFlipbook then
		alert.ProcLoopFlipbook:SetTexture(procFlipbookTexture)
		alert.ProcLoopFlipbook:SetSize(alertWidth or 36, alertHeight or 36)
		alert.ProcLoopFlipbook:SetAllPoints(alert)
		alert.ProcLoopFlipbook:SetParent(button)
		alert.ProcLoopFlipbook:SetDrawLayer("BACKGROUND", 1)
	end

	if loopAnimation then
		loopAnimation:SetFlipBookFrameHeight(64)
		loopAnimation:SetFlipBookFrameWidth(64)
		loopAnimation:SetFlipBookFrames(30)
		loopAnimation:SetFlipBookRows(6)
		loopAnimation:SetFlipBookColumns(5)
	end

	-- Setup ProcStartFlipbook
	if alert.ProcStartFlipbook then
		alert.ProcStartFlipbook:SetTexture(procFlipbookTexture)
		alert.ProcStartFlipbook:SetSize(alertWidth or 36, alertHeight or 36)
		alert.ProcStartFlipbook:SetAllPoints(alert)
		alert.ProcStartFlipbook:SetParent(button)
		alert.ProcStartFlipbook:SetDrawLayer("BACKGROUND", 1)
	end

	if startAnimation then
		startAnimation:SetFlipBookFrameHeight(64)
		startAnimation:SetFlipBookFrameWidth(64)
		startAnimation:SetFlipBookFrames(30)
		startAnimation:SetFlipBookRows(6)
		startAnimation:SetFlipBookColumns(5)
	end

	-- Setup ProcAltGlow
	if alert.ProcAltGlow then
		alert.ProcAltGlow:SetTexture(procFlipbookTexture)
		local alertColor = zBarButtonBG.GetSettingInfo(barName, "spellAlertColor") or
			{ r = 1.0, g = 0.5, b = 0.0, a = 0.8 }
		alert.ProcAltGlow:SetVertexColor(alertColor.r, alertColor.g, alertColor.b, alertColor.a)
		alert.ProcAltGlow:SetSize(alertWidth or 36, alertHeight or 36)
		alert.ProcAltGlow:SetAllPoints(alert)
		alert.ProcAltGlow:SetParent(button)
		alert.ProcAltGlow:SetDrawLayer("BACKGROUND", 1)
		alert.ProcAltGlow:SetTexCoord(0, 1 / 5, 0, 1 / 6)
	end
end

-- Update equipment border flipbook texture when button style changes
function Overlays.updateEquipmentBorderFlipbook(button, barName)
	if not button or not button.Border or not button._zBBG_borderTextureSwapped then
		return
	end

	local ButtonStyles = addonTable.Core.ButtonStyles
	local styleName = zBarButtonBG.GetSettingInfo(barName, "buttonStyle") or "Square"
	local newFlipbookPath = ButtonStyles.GetProcFlipbookPath(styleName)
	button.Border:SetTexture(newFlipbookPath)
	button.Border:SetTexCoord(0, 1 / 5, 0, 1 / 6)
end

-- Update assisted highlight (suggested action) flipbook texture and reconfigure when style changes
function Overlays.updateAssistedHighlightFlipbook(button, barName)
	if not button or not button.AssistedCombatHighlightFrame then
		return
	end

	local highlightFrame = button.AssistedCombatHighlightFrame
	if not highlightFrame.Flipbook then
		return
	end

	local flipbook = highlightFrame.Flipbook

	-- Get the new style
	local styleName = zBarButtonBG.GetSettingInfo(barName, "buttonStyle") or "Square"
	local ButtonStyles = addonTable.Core.ButtonStyles
	local procFlipbookTexture = ButtonStyles.GetProcFlipbookPath(styleName)

	-- Update texture
	flipbook:SetTexture(procFlipbookTexture)

	-- Reapply color
	local suggestedColor = zBarButtonBG.GetSettingInfo(barName, "suggestedActionColor") or
		{ r = 0.2, g = 0.8, b = 1.0, a = 0.8 }
	flipbook:SetVertexColor(suggestedColor.r, suggestedColor.g, suggestedColor.b, suggestedColor.a)

	-- Reconfigure animation frames
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

	-- Force animation restart if currently visible
	if highlightFrame:IsVisible() and highlightFrame.Anim then
		highlightFrame.Anim:Stop()
		highlightFrame.Anim:Play()
	end
end

-- Update spell alert flipbooks when button style changes
function Overlays.updateSpellAlertFlipbooks(button, barName)
	if not button or not button.SpellActivationAlert then
		return
	end

	local alert = button.SpellActivationAlert

	-- Get the new style
	local styleName = zBarButtonBG.GetSettingInfo(barName, "buttonStyle") or "Square"
	local ButtonStyles = addonTable.Core.ButtonStyles
	local procFlipbookTexture = ButtonStyles.GetProcFlipbookPath(styleName)

	-- Update all flipbook textures
	if alert.ProcLoopFlipbook then
		alert.ProcLoopFlipbook:SetTexture(procFlipbookTexture)
	end
	if alert.ProcStartFlipbook then
		alert.ProcStartFlipbook:SetTexture(procFlipbookTexture)
	end
	if alert.ProcAltGlow then
		alert.ProcAltGlow:SetTexture(procFlipbookTexture)
		-- Reapply color to alt glow
		local alertColor = zBarButtonBG.GetSettingInfo(barName, "spellAlertColor") or
			{ r = 1.0, g = 0.5, b = 0.0, a = 0.8 }
		alert.ProcAltGlow:SetVertexColor(alertColor.r, alertColor.g, alertColor.b, alertColor.a)
	end

	-- Force animation restart if alert is currently visible
	if alert:IsVisible() then
		if alert.ProcLoop and alert.ProcLoop.FlipAnim then
			alert.ProcLoop.FlipAnim:Stop()
			alert.ProcLoop.FlipAnim:Play()
		end
		if alert.ProcStart and alert.ProcStart.FlipAnim then
			alert.ProcStart.FlipAnim:Stop()
			alert.ProcStart.FlipAnim:Play()
		end
	end
end
