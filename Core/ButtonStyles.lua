-- Button style definitions for zBarButtonBG
-- Each style defines its mask texture and border texture
-- Easy to add new styles: just add a new entry to the styles table

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.ButtonStyles = {}
local ButtonStyles = addonTable.Core.ButtonStyles

-- Get localization
local L = LibStub("AceLocale-3.0"):GetLocale("zBarButtonBG")

-- Base asset path
local ASSETS_PATH = "Interface\\AddOns\\zBarButtonBG\\Assets\\"

-- Define all available button styles
-- Format: styleName = { nameKey = "L key for name", maskTexture = "path", borderTexture = "path", descriptionKey = "L key for description" }
ButtonStyles.styles = {
	["Round"] = {
		nameKey = "Round",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_Rounded",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_Rounded",
		descriptionKey = "Rounded button style",
	},
	["LessRound"] = {
		nameKey = "Less Round",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_LessRound",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_LessRound",
		descriptionKey = "Less rounded button style",
	},
	["Square"] = {
		nameKey = "Square",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_Square",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_Square",
		descriptionKey = "Sharp square button style",
	},
	["Octagon"] = {
		nameKey = "Octagon",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_Octagon",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_Octagon",
		descriptionKey = "Octagon button style",
	},
    ["OctagonFlipped"] = {
		nameKey = "Octagon Flipped",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_OctagonFlipped",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_OctagonFlipped",
		descriptionKey = "Octagon flipped button style",
	},
	["Hexagon"] = {
		nameKey = "Hexagon",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_Hexagon",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_Hexagon",
		descriptionKey = "Hexagon button style",
	},
	["HexagonFlipped"] = {
		nameKey = "Hexagon Flipped",
		maskTexture = ASSETS_PATH .. "ButtonIconMask_HexagonFlipped",
		borderTexture = ASSETS_PATH .. "ButtonIconBorder_HexagonFlipped",
		descriptionKey = "Hexagon flipped button style",
	},
}

-- Get a specific style by name
function ButtonStyles.GetStyle(styleName)
	return ButtonStyles.styles[styleName]
end

-- Get all style names as a table (for dropdown)
function ButtonStyles.GetStyleList()
	local list = {}
	for styleName, _ in pairs(ButtonStyles.styles) do
		table.insert(list, styleName)
	end
	table.sort(list)
	return list
end

-- Get all styles as a formatted table for dropdowns
function ButtonStyles.GetStylesForDropdown()
	local result = {}
	for styleName, styleData in pairs(ButtonStyles.styles) do
		local displayName = L[styleData.nameKey] or styleName
		local description = L[styleData.descriptionKey] or styleData.descriptionKey
		result[styleName] = displayName
	end
	return result
end

-- Get mask texture path for a style
function ButtonStyles.GetMaskPath(styleName)
	local style = ButtonStyles.GetStyle(styleName)
	return style and style.maskTexture or ButtonStyles.styles["Round"].maskTexture
end

-- Get border texture path for a style
function ButtonStyles.GetBorderPath(styleName)
	local style = ButtonStyles.GetStyle(styleName)
	return style and style.borderTexture or ButtonStyles.styles["Round"].borderTexture
end
