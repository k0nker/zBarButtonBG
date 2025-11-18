-- Button skinning functions - modular approach to avoid code duplication
-- Handles all overlay, mask, and background setup for action bar buttons

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.ButtonSkinning = {}
local ButtonSkinning = addonTable.Core.ButtonSkinning
local Utilities = addonTable.Core.Utilities
local Styling = addonTable.Core.Styling
local ButtonStyles = addonTable.Core.ButtonStyles
local Overlays = addonTable.Core.Overlays

-- Local aliases for utility functions
local applyMaskToTexture = Utilities.applyMaskToTexture
local removeMaskFromTexture = Utilities.removeMaskFromTexture
local getMaskPath = Utilities.getMaskPath
local getBorderPath = Utilities.getBorderPath
local getColorTable = Utilities.getColorTable
local applyBackdropPositioning = Styling.applyBackdropPositioning
local applyAllTextStyling = Styling.applyAllTextStyling
local applyTextPositioning = Styling.applyTextPositioning

-- ############################################################
-- BUTTON INITIALIZATION
-- ############################################################

-- Complete button setup - called once when button is first created
-- Applies all initial styling, overlays, backgrounds, and interactions
function ButtonSkinning.setupButton(button, barName)
	if not button or not button.icon then return end
	
	-- Mark as styled
	button._zBBG_styled = true
	
	-- Core setup
	ButtonSkinning.setBlizzardTextureHiding(button, barName)
	ButtonSkinning.setEquipmentBorder(button, barName)
	ButtonSkinning.setSpellCastAnimHiding(button, barName)
	ButtonSkinning.setInterruptDisplayHiding(button, barName)
	
	-- Button mask and textures
	ButtonSkinning.setButtonMask(button, barName)
	ButtonSkinning.setCooldownSwipeTexture(button, barName)
	
	-- Overlays
	Overlays.setHighlightOverlay(button, barName)
	Overlays.setCheckedOverlay(button, barName)
	Overlays.setRangeOverlay(button, barName)
	Overlays.setCooldownOverlay(button, barName)
	
	-- Force initial range check so overlay starts in correct state (not stuck on)
	zBarButtonBG.updateRangeOverlay(button)
	
	-- Backgrounds
	ButtonSkinning.setSlotBackground(button, barName)
	ButtonSkinning.setOuterBackground(button, barName)
	ButtonSkinning.setInnerBackground(button, barName)
	ButtonSkinning.setBorder(button, barName)
	
	-- Text
	Styling.setTextStyling(button, barName)
	applyTextPositioning(button, barName)
	
	-- Interactions
	ButtonSkinning.setupHighlightInteractions(button, barName)
	ButtonSkinning.setupCheckedInteractions(button, barName)
	ButtonSkinning.setAnimationMasks(button, barName)
end

-- Update button - called when settings change or button needs refresh
-- Re-applies styling based on current per-bar settings
function ButtonSkinning.updateButton(button, barName)
	if not button or not button._zBBG_styled then return end
	
	-- Clear all flipbook setup flags so they reconfigure on next show/update
	-- (button style or other settings may have changed)
	button._zBBG_assistedSetup = false
	button._zBBG_spellAlertSetup = false
	button._zBBG_procAlertSetup = false
	
	-- Update flipbook textures for animations that are currently visible or might be visible
	-- These functions will update textures and reconfigure as needed
	Overlays.updateEquipmentBorderFlipbook(button, barName)
	Overlays.updateAssistedHighlightFlipbook(button, barName)
	Overlays.updateSpellAlertFlipbooks(button, barName)
	
	-- Update mask first (affects all overlays)
	ButtonSkinning.setButtonMask(button, barName)
	ButtonSkinning.setCooldownSwipeTexture(button, barName)
	
	-- Update overlays
	Overlays.setHighlightOverlay(button, barName)
	Overlays.setCheckedOverlay(button, barName)
	Overlays.setRangeOverlay(button, barName)
	Overlays.setCooldownOverlay(button, barName)
	
	-- Force range check so overlay shows correct state
	zBarButtonBG.updateRangeOverlay(button)
	
	-- Update backgrounds
	ButtonSkinning.setSlotBackground(button, barName)
	ButtonSkinning.setOuterBackground(button, barName)
	ButtonSkinning.setInnerBackground(button, barName)
	ButtonSkinning.setBorder(button, barName)
	
	-- Update text
	Styling.setTextStyling(button, barName)
	applyTextPositioning(button, barName)
end

-- ############################################################
-- LOCAL SETUP HELPERS
-- ############################################################

-- Set up the button's mask texture based on per-bar button style
function ButtonSkinning.setButtonMask(button, barName)
	if not button or not button.icon then return end
	
	if button.IconMask then
		button.icon:RemoveMaskTexture(button.IconMask)
	end
	
	local styleName = zBarButtonBG.GetSettingInfo(barName, "buttonStyle") or "Square"
	-- createAndApplyMask is a local function in zBarButtonBG.lua, so we recreate the logic here
	if not button._zBBG_customMask then
		button._zBBG_customMask = button:CreateMaskTexture()
	end
	button._zBBG_customMask:SetTexture(getMaskPath(styleName))
	button._zBBG_customMask:SetAllPoints(button)
	
	-- Create swipe mask for overlays (range, highlight, cooldown)
	if not button._zBBG_swipeMask then
		button._zBBG_swipeMask = button:CreateMaskTexture()
	end
	button._zBBG_swipeMask:SetTexture(ButtonStyles.GetSwipeMaskPath(styleName))
	button._zBBG_swipeMask:SetAllPoints(button)
	
	-- Apply mask to all maskable elements
	if button.icon then
		applyMaskToTexture(button.icon, button._zBBG_customMask)
	end
	if button.SlotBackground then
		applyMaskToTexture(button.SlotBackground, button._zBBG_customMask)
	end
end

-- Set cooldown swipe texture based on per-bar button style
function ButtonSkinning.setCooldownSwipeTexture(button, barName)
	if not button or not button.cooldown then return end
	
	local styleName = zBarButtonBG.GetSettingInfo(barName, "buttonStyle") or "Square"
	local swipeMaskPath = ButtonStyles.GetSwipeMaskPath(styleName)
	if swipeMaskPath then
		button.cooldown:SetSwipeTexture(swipeMaskPath, 1, 1, 1, 0.8)
	end
end

-- ############################################################
-- OVERLAY SETUP
-- ############################################################

-- NOTE: Overlay setup functions are in Core/Overlays.lua:
-- - Overlays.setHighlightOverlay(button, barName)
-- - Overlays.setCheckedOverlay(button, barName)
-- - Overlays.setRangeOverlay(button, barName)
-- - Overlays.setCooldownOverlay(button, barName)

-- ############################################################
-- BACKGROUND SETUP
-- ############################################################

-- Create inner slot background
function ButtonSkinning.setSlotBackground(button, barName)
	if not button then return end
	
	local showSlotBackground = zBarButtonBG.GetSettingInfo(barName, "showSlotBackground")
	
	if button.SlotBackground then
		local showBorderSlot = zBarButtonBG.GetSettingInfo(barName, "showBorder")
		if showBorderSlot then
			button.SlotBackground:SetTexture("Interface/Buttons/WHITE8X8")
			button.SlotBackground:SetVertexColor(0, 0, 0, 0)
			button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
			button.SlotBackground:ClearAllPoints()
			button.SlotBackground:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
			button.SlotBackground:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
		else
			button.SlotBackground:SetTexture(nil)
			button.SlotBackground:SetVertexColor(1, 1, 1, 1)
			button.SlotBackground:SetDrawLayer("BACKGROUND", -1)
			button.SlotBackground:ClearAllPoints()
			button.SlotBackground:SetAllPoints(button)
		end
		
		if button._zBBG_customMask then
			applyMaskToTexture(button.SlotBackground, button._zBBG_customMask)
		end
	end
end

-- Create outer background frame
function ButtonSkinning.setOuterBackground(button, barName)
	if not button then return end
	
	local showBackdrop = zBarButtonBG.GetSettingInfo(barName, "showBackdrop")
	
	if showBackdrop then
		if not button._zBBG_outerFrame then
			button._zBBG_outerFrame = CreateFrame("Frame", nil, button)
			button._zBBG_outerFrame:SetFrameLevel(0)
			button._zBBG_outerFrame:SetFrameStrata("BACKGROUND")
			
			button._zBBG_outerBg = button._zBBG_outerFrame:CreateTexture(nil, "BACKGROUND", nil, -8)
			button._zBBG_outerBg:SetAllPoints(button._zBBG_outerFrame)
		end
		
		button._zBBG_outerFrame:Show()
		applyBackdropPositioning(button._zBBG_outerFrame, button, barName)
		
		local outerColor = getColorTable("outerColor", "useClassColorOuter", barName)
		button._zBBG_outerBg:SetColorTexture(outerColor.r, outerColor.g, outerColor.b, outerColor.a)
	elseif button._zBBG_outerFrame then
		button._zBBG_outerFrame:Hide()
	end
end

-- Create inner background frame
function ButtonSkinning.setInnerBackground(button, barName)
	if not button then return end
	
	local showSlotBackground = zBarButtonBG.GetSettingInfo(barName, "showSlotBackground")
	local innerColor = getColorTable("innerColor", "useClassColorInner", barName)
	
	if showSlotBackground then
		if not button._zBBG_bgFrame then
			button._zBBG_bgFrame = CreateFrame("Frame", nil, button)
			button._zBBG_bgFrame:SetAllPoints(button)
			button._zBBG_bgFrame:SetFrameLevel(0)
			button._zBBG_bgFrame:SetFrameStrata("BACKGROUND")
			
			button._zBBG_bg = button._zBBG_bgFrame:CreateTexture(nil, "BACKGROUND", nil, -7)
			button._zBBG_bg:SetAllPoints(button._zBBG_bgFrame)
		end
		
		button._zBBG_bgFrame:Show()
		button._zBBG_bg:SetColorTexture(innerColor.r, innerColor.g, innerColor.b, innerColor.a)
		
		if button._zBBG_customMask then
			applyMaskToTexture(button._zBBG_bg, button._zBBG_customMask)
		end
	elseif button._zBBG_bgFrame then
		button._zBBG_bgFrame:Hide()
	end
end

-- Create and manage border
function ButtonSkinning.setBorder(button, barName)
	if not button or not button.icon then return end
	
	local showBorder = zBarButtonBG.GetSettingInfo(barName, "showBorder")
	local borderColor = getColorTable("borderColor", "useClassColorBorder", barName)
	
	-- Cache the border setting on the button for fast lookup in frequently-called hooks
	button._zBBG_showBorder = showBorder
	button._zBBG_borderBarName = barName
	
	if showBorder then
		if not button._zBBG_borderFrame then
			button._zBBG_borderFrame = CreateFrame("Frame", nil, button)
			button._zBBG_borderFrame:SetAllPoints(button)
			button._zBBG_borderFrame:SetFrameLevel(button:GetFrameLevel() + 1)
			
			button._zBBG_customBorderTexture = button._zBBG_borderFrame:CreateTexture(nil, "OVERLAY")
			button._zBBG_customBorderTexture:SetAllPoints(button._zBBG_borderFrame)
			button._zBBG_customBorderTexture:SetBlendMode("ADD")
		end
		
		button._zBBG_borderFrame:Show()
		button._zBBG_customBorderTexture:SetTexture(getBorderPath(barName))
		button._zBBG_customBorderTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
	elseif button._zBBG_borderFrame then
		button._zBBG_borderFrame:Hide()
	end
end

-- ############################################################
-- TEXT AND VISUAL SETUP
-- ############################################################

-- NOTE: Text setup functions are in Core/Styling.lua:
-- - Styling.setTextStyling(button, barName)
-- - Styling.setTextPositioning(button, barName)

-- ############################################################
-- BLIZZARD UI HIDING
-- ############################################################
function ButtonSkinning.setBlizzardTextureHiding(button, barName)
	if not button or button._zBBG_blizzardTexturesHooked then return end
	
	if button.SuggestedActionIconTexture then
		button.SuggestedActionIconTexture:SetAlpha(0)
		button.SuggestedActionIconTexture:Hide()
		button.SuggestedActionIconTexture:SetTexture("")
	end
	
	if button.NormalTexture then
		button.NormalTexture:SetAlpha(0)
		button.NormalTexture:Hide()
		button.NormalTexture:SetScript("OnShow", function(self)
			self:Hide()
			self:SetAlpha(0)
		end)
	end
	
	button._zBBG_blizzardTexturesHooked = true
end

-- Set up equipment border with proc flipbook
function ButtonSkinning.setEquipmentBorder(button, barName)
	if not button or not button.Border or button._zBBG_borderTextureSwapped then return end
	
	button.Border:SetTexture(ButtonStyles.GetProcFlipbookPath(barName))
	button.Border:SetTexCoord(0, 1 / 5, 0, 1 / 6)
	button.Border:SetVertexColor(0, 1.0, 0, 0.5)
	
	if not InCombatLockdown() then
		button.Border:SetDrawLayer("BACKGROUND", 2)
	end
	
	button._zBBG_borderTextureSwapped = true
end

-- Hide spell cast animations
function ButtonSkinning.setSpellCastAnimHiding(button, barName)
	if not button or not button.SpellCastAnimFrame then return end
	
	button.SpellCastAnimFrame:SetScript("OnShow", function(self) self:Hide() end)
end

-- Hide interrupt display
function ButtonSkinning.setInterruptDisplayHiding(button, barName)
	if not button or not button.InterruptDisplay then return end
	
	button.InterruptDisplay:SetScript("OnShow", function(self) self:Hide() end)
end

-- ############################################################
-- INTERACTION HOOKS
-- ############################################################

-- Set up highlight hover/click interactions
function ButtonSkinning.setupHighlightInteractions(button, barName)
	if not button or button._zBBG_highlightHooked then return end
	
	button:HookScript("OnEnter", function(self)
		if self._zBBG_customHighlight and self:GetButtonState() ~= "PUSHED" then
			if not self._zBBG_customHighlight:IsShown() then
				self._zBBG_customHighlight:Show()
			end
		end
	end)
	button:HookScript("OnLeave", function(self)
		if self._zBBG_customHighlight and self:GetButtonState() ~= "PUSHED" then
			if self._zBBG_customHighlight:IsShown() then
				self._zBBG_customHighlight:Hide()
			end
		end
	end)
	
	button:HookScript("OnMouseDown", function(self)
		if self._zBBG_customHighlight then
			if not self._zBBG_customHighlight:IsShown() then
				self._zBBG_customHighlight:Show()
			end
		end
	end)
	button:HookScript("OnMouseUp", function(self)
		if self._zBBG_customHighlight then
			local cursorType = GetCursorInfo()
			if (not self:IsMouseOver() or cursorType) and self._zBBG_customHighlight:IsShown() then
				self._zBBG_customHighlight:Hide()
			end
		end
	end)
	
	hooksecurefunc(button, "SetButtonState", function(self, state)
		if self._zBBG_customHighlight then
			if state == "PUSHED" then
				if not self._zBBG_customHighlight:IsShown() then
					self._zBBG_customHighlight:Show()
				end
			elseif state == "NORMAL" and not self:IsMouseOver() then
				if self._zBBG_customHighlight:IsShown() then
					self._zBBG_customHighlight:Hide()
				end
			end
		end
	end)
	
	button._zBBG_highlightHooked = true
end

-- Set up pet button checked state interactions
function ButtonSkinning.setupCheckedInteractions(button, barName)
	if not button or not button._zBBG_customChecked or button._zBBG_checkedHooked then return end
	
	local function updateCheckedState(self)
		if self._zBBG_customChecked then
			local shouldShow = self:GetChecked()
			local isShown = self._zBBG_customChecked:IsShown()
			
			if shouldShow and not isShown then
				self._zBBG_customChecked:Show()
			elseif not shouldShow and isShown then
				self._zBBG_customChecked:Hide()
			end
		end
	end
	
	hooksecurefunc(button, "SetChecked", updateCheckedState)
	updateCheckedState(button)
	
	button._zBBG_checkedHooked = true
end

-- Set up animation masks for spell alerts and assisted combat
function ButtonSkinning.setAnimationMasks(button, barName)
	if not button or button._zBBG_animationHooked then return end
	
	local function setupAnimationMasks()
		if button.AssistedCombatHighlightFrame and button.AssistedCombatHighlightFrame.Flipbook then
			local flipbook = button.AssistedCombatHighlightFrame.Flipbook
			if not flipbook._zBBG_maskHooked then
				flipbook:SetScript("OnShow", function(self)
					if button._zBBG_customMask then
						applyMaskToTexture(self, button._zBBG_customMask)
					end
				end)
				flipbook._zBBG_maskHooked = true
				if flipbook:IsShown() and button._zBBG_customMask then
					applyMaskToTexture(flipbook, button._zBBG_customMask)
				end
			end
		end
	end
	
	setupAnimationMasks()
	button:HookScript("OnShow", setupAnimationMasks)
	
	button._zBBG_animationHooked = true
end
