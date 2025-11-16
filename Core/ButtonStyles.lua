-- Button style definitions for zBarButtonBG
-- Defines button shapes, regions, and asset paths
-- Follows data-driven architecture for easy extension

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.ButtonStyles = {}
local ButtonStyles = addonTable.Core.ButtonStyles

-- Get localization
local L = LibStub("AceLocale-3.0"):GetLocale("zBarButtonBG")

-- Base asset path
local ASSETS_PATH = "Interface\\AddOns\\zBarButtonBG\\Assets\\"

-- Define all available button styles with complete texture assets
ButtonStyles.styles = {
	["Round"] = {
		nameKey = "Round",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_Rounded",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_Rounded",
		highlightTexture = ASSETS_PATH .. "ButtonIconHighlight_Rounded",
		descriptionKey = "Rounded button style",
	},
	["Square"] = {
		nameKey = "Square",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_Square",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_Square",
		highlightTexture = ASSETS_PATH .. "ButtonIconHighlight_Square",
		descriptionKey = "Sharp square button style",
	},
	["Octagon"] = {
		nameKey = "Octagon",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_Octagon",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_Octagon",
		highlightTexture = ASSETS_PATH .. "ButtonIconHighlight_Octagon",
		descriptionKey = "Octagon button style",
	},
    ["OctagonFlipped"] = {
		nameKey = "Octagon Flipped",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_OctagonFlipped",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_OctagonFlipped",
		highlightTexture = ASSETS_PATH .. "ButtonIconHighlight_OctagonFlipped",
		descriptionKey = "Octagon flipped button style",
	},
	["Hexagon"] = {
		nameKey = "Hexagon",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_Hexagon",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_Hexagon",
		highlightTexture = ASSETS_PATH .. "ButtonIconHighlight_Hexagon",
		descriptionKey = "Hexagon button style",
	},
	["HexagonFlipped"] = {
		nameKey = "Hexagon Flipped",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_HexagonFlipped",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_HexagonFlipped",
		highlightTexture = ASSETS_PATH .. "ButtonIconHighlight_HexagonFlipped",
		descriptionKey = "Hexagon flipped button style",
	},
	["Circle"] = {
		nameKey = "Circle",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_Circle",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_Circle",
		highlightTexture = ASSETS_PATH .. "ButtonIconHighlight_Circle",
		descriptionKey = "Circle button style",
	},
}

-- Region definitions - describes all button sub-elements and their properties
-- This data-driven approach eliminates scattered conditionals and duplicated logic
ButtonStyles.regions = {
	-- Icon region: the actual spell/item icon image
	Icon = {
		propertyName = "icon",
		canMask = true,
		maskable = true,
		scale = 1.05,
		texCoordX = { 0.07, 0.93 },
		texCoordY = { 0.07, 0.93 },
	},
	-- Normal texture: Blizzard's default border (always hidden)
	Normal = {
		propertyName = "NormalTexture",
		canMask = false,
		hidden = true,
		alpha = 0,
	},
	-- Highlight texture: Blizzard's hover effect (always hidden)
	Highlight = {
		propertyName = "HighlightTexture",
		canMask = false,
		hidden = true,
		alpha = 0,
	},
	-- Pushed texture: Blizzard's click effect (always hidden)
	Pushed = {
		propertyName = "PushedTexture",
		canMask = false,
		hidden = true,
		alpha = 0,
	},
	-- Checked texture: Blizzard's toggled state (always hidden)
	Checked = {
		propertyName = "CheckedTexture",
		canMask = false,
		hidden = true,
		alpha = 0,
	},
	-- SlotBackground: the texture behind the icon
	SlotBackground = {
		propertyName = "SlotBackground",
		canMask = true,
		maskable = true,
	},
	-- Cooldown frame: the spiral that shows ability cooldowns
	Cooldown = {
		propertyName = "cooldown",
		canMask = false,
		fillsButton = true,
	},
}

-- Retrieve a specific style definition by name
function ButtonStyles.GetStyle(styleName)
	return ButtonStyles.styles[styleName]
end

-- Get all style names as a sorted list
function ButtonStyles.GetStyleList()
	local list = {}
	for styleName, _ in pairs(ButtonStyles.styles) do
		table.insert(list, styleName)
	end
	table.sort(list)
	return list
end

-- Get styles formatted for UI dropdown with localized names
function ButtonStyles.GetStylesForDropdown()
	local result = {}
	for styleName, styleData in pairs(ButtonStyles.styles) do
		local displayName = L[styleData.nameKey] or styleName
		result[styleName] = displayName
	end
	return result
end

-- Consolidated path getters: all return correct texture for current button style
-- This eliminates three separate functions with identical logic
function ButtonStyles.GetPaths(styleName)
	styleName = styleName or zBarButtonBG.charSettings.buttonStyle or "Square"
	local style = ButtonStyles.GetStyle(styleName)
	if not style then
		style = ButtonStyles.styles["Square"]
	end
	return {
		mask = style.maskTexture,
		border = style.borderTexture,
		highlight = style.highlightTexture,
	}
end

-- Get current mask path based on active button style
function ButtonStyles.GetMaskPath(styleName)
	local paths = ButtonStyles.GetPaths(styleName)
	return paths.mask
end

-- Get current border path based on active button style
function ButtonStyles.GetBorderPath(styleName)
	local paths = ButtonStyles.GetPaths(styleName)
	return paths.border
end

-- Get current highlight path based on active button style
function ButtonStyles.GetHighlightPath(styleName)
	local paths = ButtonStyles.GetPaths(styleName)
	return paths.highlight
end

-- Get a region definition by name
function ButtonStyles.GetRegion(regionName)
	return ButtonStyles.regions[regionName]
end

-- Get all regions as a list
function ButtonStyles.GetRegionList()
	return ButtonStyles.regions
end

-- Process a button region based on its definition
-- This consolidates all the scattered region-specific logic into one function
function ButtonStyles.ProcessRegion(button, regionName, regionDef)
	if not button or not regionDef then return end

	local element = button[regionDef.propertyName]
	if not element then return end

	-- Handle hidden regions (make them invisible and block Show calls)
	if regionDef.hidden then
		element:SetAlpha(regionDef.alpha or 0)
		element:Hide()
		element:SetScript("OnShow", function(self) self:Hide() end)
		return
	end

	-- Handle regions that fill the button (set full bounds)
	if regionDef.fillsButton then
		element:SetAllPoints(button)
		return
	end

	-- Handle icon-specific positioning
	if regionName == "Icon" and element then
		if button.IconMask then
			element:RemoveMaskTexture(button.IconMask)
		end
		element:SetScale(regionDef.scale or 1.0)
		local tcx = regionDef.texCoordX
		local tcy = regionDef.texCoordY
		element:SetTexCoord(tcx[1], tcx[2], tcy[1], tcy[2])
		element:ClearAllPoints()
		element:SetAllPoints(button)
	end
end