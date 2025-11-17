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
-- barName parameter (optional) enables per-bar profile lookup
function Styling.SkinText(textElement, button, metadata, barName)
	if not textElement or not metadata then return end

	-- Helper to get setting value (per-bar if barName provided, else global)
	local function getSetting(key)
		return zBarButtonBG.GetSettingInfo(barName, key)
	end

	-- Apply font styling
	if metadata.fontSettingKey then
		local fontName = getSetting(metadata.fontSettingKey)
		if not fontName then fontName = addonTable.Core.Defaults.profile[metadata.fontSettingKey] end
		local fontPath = Util.getFontPath(fontName)
		local fontSize = getSetting(metadata.fontSizeKey)
		if not fontSize then fontSize = addonTable.Core.Defaults.profile[metadata.fontSizeKey] end
		local fontFlags = getSetting(metadata.fontFlagsKey)
		if not fontFlags then fontFlags = addonTable.Core.Defaults.profile[metadata.fontFlagsKey] end
		textElement:SetFont(fontPath, fontSize, fontFlags)
	end

	-- Apply size
	if metadata.widthKey and metadata.heightKey then
		local width = getSetting(metadata.widthKey)
		if not width then width = addonTable.Core.Defaults.profile[metadata.widthKey] end
		local height = getSetting(metadata.heightKey)
		if not height then height = addonTable.Core.Defaults.profile[metadata.heightKey] end
		textElement:SetSize(width, height)
	end

	-- Apply color
	if metadata.colorKey then
		local colorTbl = getSetting(metadata.colorKey)
		if not colorTbl or type(colorTbl) ~= "table" then
			colorTbl = addonTable.Core.Defaults.profile[metadata.colorKey]
			if not colorTbl or type(colorTbl) ~= "table" then
				colorTbl = { r = 1, g = 1, b = 1, a = 1 }
			end
		end
		-- Ensure all color components exist with safe defaults
		local r = (colorTbl.r ~= nil) and colorTbl.r or 1
		local g = (colorTbl.g ~= nil) and colorTbl.g or 1
		local b = (colorTbl.b ~= nil) and colorTbl.b or 1
		local a = (colorTbl.a ~= nil) and colorTbl.a or 1
		textElement:SetTextColor(r, g, b, a)
	end

	-- Apply justification
	if metadata.justifyHKey then
		local justifyH = getSetting(metadata.justifyHKey)
		if not justifyH then justifyH = addonTable.Core.Defaults.profile[metadata.justifyHKey] or "CENTER" end
		textElement:SetJustifyH(justifyH)
	end
	if metadata.justifyVKey then
		local justifyV = getSetting(metadata.justifyVKey)
		if not justifyV then justifyV = addonTable.Core.Defaults.profile[metadata.justifyVKey] or "MIDDLE" end
		textElement:SetJustifyV(justifyV)
	end

	-- Apply draw layer
	if metadata.drawLayer then
		textElement:SetDrawLayer(metadata.drawLayer, metadata.drawOrder or 0)
	end

	-- Apply positioning
	local offsetX = getSetting(metadata.offsetXKey)
	if offsetX == nil then offsetX = addonTable.Core.Defaults.profile[metadata.offsetXKey] or 0 end
	local offsetY = getSetting(metadata.offsetYKey)
	if offsetY == nil then offsetY = addonTable.Core.Defaults.profile[metadata.offsetYKey] or 0 end
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
function Styling.applyMacroNameStyling(button, barName)
	if not button or not button.Name then return end
	Styling.SkinText(button.Name, button, Styling.textElements.MacroName, barName)
end

-- Apply count text styling
function Styling.applyCountStyling(button, barName)
	if not button or not button.Count then return end
	Styling.SkinText(button.Count, button, Styling.textElements.Count, barName)
end

-- Apply keybind text styling
function Styling.applyKeybindStyling(button, barName)
	if not button or not button.HotKey then return end
	Styling.SkinText(button.HotKey, button, Styling.textElements.Keybind, barName)
end

-- Apply all text styling to a button using centralized approach
function Styling.applyAllTextStyling(button, barName)
	if not button then return end

	Styling.applyMacroNameStyling(button, barName)
	Styling.applyCountStyling(button, barName)
	Styling.applyKeybindStyling(button, barName)
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
-- barName parameter (optional) enables per-bar profile lookup
function Styling.applyBackdropPositioning(outerFrame, button, barName)
	if not outerFrame or not button then return end

	local topAdj = barName and zBarButtonBG.GetSettingInfo(barName, "backdropTopAdjustment") or zBarButtonBG.charSettings.backdropTopAdjustment or 5
	local bottomAdj = barName and zBarButtonBG.GetSettingInfo(barName, "backdropBottomAdjustment") or zBarButtonBG.charSettings.backdropBottomAdjustment or 5
	local leftAdj = barName and zBarButtonBG.GetSettingInfo(barName, "backdropLeftAdjustment") or zBarButtonBG.charSettings.backdropLeftAdjustment or 5
	local rightAdj = barName and zBarButtonBG.GetSettingInfo(barName, "backdropRightAdjustment") or zBarButtonBG.charSettings.backdropRightAdjustment or 5

	outerFrame:ClearAllPoints()
	outerFrame:SetPoint("TOPLEFT", button, "TOPLEFT", -leftAdj, topAdj)
	outerFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", rightAdj, -bottomAdj)
end

-- Apply text positioning with offsets
function Styling.applyTextPositioning(button, barName)
	if not button then return end

	-- Re-apply all text styling to ensure positioning is current
	Styling.applyAllTextStyling(button, barName)
end

-- ############################################################
-- TEXT SETUP FUNCTIONS (per-bar skinning)
-- ############################################################

-- Apply text styling
function Styling.setTextStyling(button, barName)
	if not button then return end
	
	Styling.applyAllTextStyling(button, barName)
end

-- Apply text positioning
function Styling.setTextPositioning(button, barName)
	if not button then return end
	
	Styling.applyTextPositioning(button, barName)
end
