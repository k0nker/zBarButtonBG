-- Text styling and positioning functions for zBarButtonBG buttons

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.Styling = {}
local Styling = addonTable.Core.Styling
local Util = addonTable.Core.Utilities

-- ############################################################
-- TEXT ELEMENT METADATA
-- ############################################################

Styling.textElements = {
	MacroName = {
		key = "Name",
		fontSettingKey = "macroNameFont",
		fontSizeKey = "macroNameFontSize",
		fontFlagsKey = "macroNameFontFlags",
		colorKey = "macroNameColor",
		widthKey = "macroNameWidth",
		heightKey = "macroNameHeight",
		justifyHKey = "macroNameJustification",
		justifyVKey = "macroNamePosition",
		offsetXKey = "macroNameOffsetX",
		offsetYKey = "macroNameOffsetY",
		point = "BOTTOM",
		relPoint = "BOTTOM",
		baseOffsetX = 0,
		baseOffsetY = 2,
		drawLayer = "BORDER",
		drawOrder = 1,
	},
	Count = {
		key = "Count",
		fontSettingKey = "countFont",
		fontSizeKey = "countFontSize",
		fontFlagsKey = "countFontFlags",
		colorKey = "countColor",
		widthKey = "countWidth",
		heightKey = "countHeight",
		offsetXKey = "countOffsetX",
		offsetYKey = "countOffsetY",
		point = "BOTTOMRIGHT",
		relPoint = "BOTTOMRIGHT",
		baseOffsetX = 0,
		baseOffsetY = 3,
		drawLayer = "OVERLAY",
		drawOrder = 0,
	},
	Keybind = {
		key = "HotKey",
		fontSettingKey = "keybindFont",
		fontSizeKey = "keybindFontSize",
		fontFlagsKey = "keybindFontFlags",
		colorKey = "keybindColor",
		widthKey = "keybindWidth",
		heightKey = "keybindHeight",
		justifyHKey = nil,
		justifyVKey = nil,
		offsetXKey = "keybindOffsetX",
		offsetYKey = "keybindOffsetY",
		point = "TOPRIGHT",
		relPoint = "TOPRIGHT",
		baseOffsetX = -1,
		baseOffsetY = -2,
		drawLayer = "OVERLAY",
		drawOrder = 0,
	},
}

-- ############################################################
-- CENTRALIZED TEXT SKINNING
-- ############################################################
-- Single function handles all text styling following metadata

-- Skin a text element using metadata definition
function Styling.SkinText(textElement, button, metadata)
	if not textElement or not metadata then return end

	-- Apply font styling
	if metadata.fontSettingKey then
		local fontPath = Util.getFontPath(zBarButtonBG.charSettings[metadata.fontSettingKey])
		local fontSize = zBarButtonBG.charSettings[metadata.fontSizeKey]
		local fontFlags = zBarButtonBG.charSettings[metadata.fontFlagsKey]
		textElement:SetFont(fontPath, fontSize, fontFlags)
	end

	-- Apply size
	if metadata.widthKey and metadata.heightKey then
		local width = zBarButtonBG.charSettings[metadata.widthKey]
		local height = zBarButtonBG.charSettings[metadata.heightKey]
		textElement:SetSize(width, height)
	end

	-- Apply color
	if metadata.colorKey then
		local colorTbl = zBarButtonBG.charSettings[metadata.colorKey]
		textElement:SetTextColor(colorTbl.r, colorTbl.g, colorTbl.b, colorTbl.a)
	end

	-- Apply justification
	if metadata.justifyHKey then
		textElement:SetJustifyH(zBarButtonBG.charSettings[metadata.justifyHKey] or "CENTER")
	end
	if metadata.justifyVKey then
		textElement:SetJustifyV(zBarButtonBG.charSettings[metadata.justifyVKey] or "MIDDLE")
	end

	-- Apply draw layer
	if metadata.drawLayer then
		textElement:SetDrawLayer(metadata.drawLayer, metadata.drawOrder or 0)
	end

	-- Apply positioning
	local offsetX = zBarButtonBG.charSettings[metadata.offsetXKey] or 0
	local offsetY = zBarButtonBG.charSettings[metadata.offsetYKey] or 0
	local finalOffsetX = (metadata.baseOffsetX or 0) + offsetX
	local finalOffsetY = (metadata.baseOffsetY or 0) + offsetY

	textElement:ClearAllPoints()
	textElement:SetPoint(metadata.point or "CENTER", button, metadata.relPoint or "CENTER", finalOffsetX, finalOffsetY)
end

-- ############################################################
-- LEGACY TEXT STYLING FUNCTIONS
-- ############################################################
-- Maintained for compatibility, but now use centralized SkinText()

-- Apply macro name text styling
function Styling.applyMacroNameStyling(button)
	if not button or not button.Name then return end
	Styling.SkinText(button.Name, button, Styling.textElements.MacroName)
end

-- Apply count text styling
function Styling.applyCountStyling(button)
	if not button or not button.Count then return end
	Styling.SkinText(button.Count, button, Styling.textElements.Count)
end

-- Apply keybind text styling
function Styling.applyKeybindStyling(button)
	if not button or not button.HotKey then return end
	Styling.SkinText(button.HotKey, button, Styling.textElements.Keybind)
end

-- Apply all text styling to a button using centralized approach
function Styling.applyAllTextStyling(button)
	if not button then return end

	Styling.applyMacroNameStyling(button)
	Styling.applyCountStyling(button)
	Styling.applyKeybindStyling(button)
end

-- ############################################################
-- BUTTON ELEMENT STYLING
-- ############################################################

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

	-- Re-apply all text styling to ensure positioning is current
	Styling.applyAllTextStyling(button)
end
