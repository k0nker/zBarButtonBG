-- Text styling and positioning functions for zBarButtonBG buttons

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.Styling = {}
local Styling = addonTable.Core.Styling
local Util = addonTable.Core.Utilities

-- Apply macro name text styling
function Styling.applyMacroNameStyling(button)
	if not button or not button.Name then return end

	button.Name:SetFont(
		Util.getFontPath(zBarButtonBG.charSettings.macroNameFont),
		zBarButtonBG.charSettings.macroNameFontSize,
		zBarButtonBG.charSettings.macroNameFontFlags
	)
	button.Name:SetSize(
		zBarButtonBG.charSettings.macroNameWidth,
		zBarButtonBG.charSettings.macroNameHeight
	)
	local c = zBarButtonBG.charSettings.macroNameColor
	button.Name:SetTextColor(c.r, c.g, c.b, c.a)
	button.Name:SetJustifyH(zBarButtonBG.charSettings.macroNameJustification or "CENTER")
	button.Name:SetJustifyV(zBarButtonBG.charSettings.macroNamePosition or "MIDDLE")
	-- Set draw layer to appear behind Blizzard's cooldown text
	button.Name:SetDrawLayer("BORDER", 1)
	local xOffset = zBarButtonBG.charSettings.macroNameOffsetX or 0
	local yOffset = zBarButtonBG.charSettings.macroNameOffsetY or 0
	button.Name:ClearAllPoints()
	button.Name:SetPoint("BOTTOM", button, "BOTTOM", 0 + xOffset, 2 + yOffset)
end

-- Apply count text styling
function Styling.applyCountStyling(button)
	if not button or not button.Count then return end

	button.Count:SetFont(
		Util.getFontPath(zBarButtonBG.charSettings.countFont),
		zBarButtonBG.charSettings.countFontSize,
		zBarButtonBG.charSettings.countFontFlags
	)
	button.Count:SetSize(
		zBarButtonBG.charSettings.countWidth,
		zBarButtonBG.charSettings.countHeight
	)
	local c = zBarButtonBG.charSettings.countColor
	button.Count:SetTextColor(c.r, c.g, c.b, c.a)
	local xOffset = zBarButtonBG.charSettings.countOffsetX or 0
	local yOffset = zBarButtonBG.charSettings.countOffsetY or 0
	button.Count:ClearAllPoints()
	button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0 + xOffset, 3 + yOffset)
end

-- Apply keybind text styling
function Styling.applyKeybindStyling(button)
	if not button or not button.HotKey then return end

	button.HotKey:SetFont(
		Util.getFontPath(zBarButtonBG.charSettings.keybindFont),
		zBarButtonBG.charSettings.keybindFontSize,
		zBarButtonBG.charSettings.keybindFontFlags
	)
	button.HotKey:SetSize(
		zBarButtonBG.charSettings.keybindWidth,
		zBarButtonBG.charSettings.keybindHeight
	)
	local c = zBarButtonBG.charSettings.keybindColor
	button.HotKey:SetTextColor(c.r, c.g, c.b, c.a)
	local xOffset = zBarButtonBG.charSettings.keybindOffsetX or 0
	local yOffset = zBarButtonBG.charSettings.keybindOffsetY or 0
	button.HotKey:ClearAllPoints()
	button.HotKey:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1 + xOffset, -2 + yOffset)
end

-- Apply all text styling to a button
function Styling.applyAllTextStyling(button)
	if not button then return end

	Styling.applyMacroNameStyling(button)
	Styling.applyCountStyling(button)
	Styling.applyKeybindStyling(button)
end

-- Manage NormalTexture consistently
function Styling.updateButtonNormalTexture(button)
	if not button or not button.NormalTexture then return end

	-- Always keep it transparent for our custom styling
	button.NormalTexture:SetAlpha(0)
end

-- Apply backdrop positioning with adjustable offsets
function Styling.applyBackdropPositioning(outerFrame, button)
	if not outerFrame or not button then return end

	local topAdj = zBarButtonBG.charSettings.backdropTopAdjustment or 5
	local bottomAdj = zBarButtonBG.charSettings.backdropBottomAdjustment or 5
	local leftAdj = zBarButtonBG.charSettings.backdropLeftAdjustment or 5
	local rightAdj = zBarButtonBG.charSettings.backdropRightAdjustment or 5

	outerFrame:ClearAllPoints()
	outerFrame:SetPoint("TOPLEFT", button, "TOPLEFT", -leftAdj, topAdj)
	outerFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", rightAdj, -bottomAdj)
end

-- Apply text positioning with offsets
function Styling.applyTextPositioning(button)
	if not button then return end

	-- Apply text positioning after button data is stored
	if button.Name then
		button.Name:SetJustifyH(zBarButtonBG.charSettings.macroNameJustification or "CENTER")
		button.Name:SetJustifyV(zBarButtonBG.charSettings.macroNamePosition or "MIDDLE")
		-- Set draw layer to appear behind Blizzard's cooldown text
		button.Name:SetDrawLayer("BORDER", 1)
		local xOffset = zBarButtonBG.charSettings.macroNameOffsetX or 0
		local yOffset = zBarButtonBG.charSettings.macroNameOffsetY or 0
		button.Name:ClearAllPoints()
		button.Name:SetPoint("BOTTOM", button, "BOTTOM", 0 + xOffset, 2 + yOffset)
	end
	if button.Count then
		local xOffset = zBarButtonBG.charSettings.countOffsetX or 0
		local yOffset = zBarButtonBG.charSettings.countOffsetY or 0
		button.Count:ClearAllPoints()
		button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0 + xOffset, 3 + yOffset)
	end
	if button.HotKey then
		local xOffset = zBarButtonBG.charSettings.keybindOffsetX or 0
		local yOffset = zBarButtonBG.charSettings.keybindOffsetY or 0
		button.HotKey:ClearAllPoints()
		button.HotKey:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1 + xOffset, -2 + yOffset)
	end
end
