-- Utility helper functions for zBarButtonBG
-- Provides centralized sizing, positioning, masking, and color management

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.Utilities = {}
local Util = addonTable.Core.Utilities
local C = addonTable.Core.Constants

-- Print helper that prefixes our addon name
function Util.print(arg)
	if arg == "" or arg == nil then
		return
	else
		print(C.ADDON_NAME .. " " .. arg)
	end
	return false
end

-- Get color table with optional class color override
function Util.getColorTable(colorKey, useClassColorKey)
	if zBarButtonBG.charSettings[useClassColorKey] then
		local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
		return { r = classColor.r, g = classColor.g, b = classColor.b, a = 1 }
	else
		local c = zBarButtonBG.charSettings[colorKey]
		return { r = c.r, g = c.g, b = c.b, a = c.a }
	end
end

-- Get all texture paths (mask, border, highlight) for current button style
-- Consolidated from three separate functions to reduce duplication
function Util.getTexturePaths(styleName)
	local ButtonStyles = addonTable.Core.ButtonStyles
	return ButtonStyles.GetPaths(styleName)
end

-- Get mask texture path based on current button style
function Util.getMaskPath(styleName)
	local paths = Util.getTexturePaths(styleName)
	return paths.mask
end

-- Get border texture path based on current button style
function Util.getBorderPath(styleName)
	local paths = Util.getTexturePaths(styleName)
	return paths.border
end

-- Get highlight texture path based on current button style
function Util.getHighlightPath(styleName)
	local paths = Util.getTexturePaths(styleName)
	return paths.highlight
end

-- Check if current button style is "Square" (for positioning logic)
function Util.isSquareButtonStyle()
	return zBarButtonBG.charSettings.buttonStyle == "Square"
end

-- Helper to apply/remove a mask to a texture while tracking what mask is applied
-- Prevents duplicate mask applications and tracks mask state
function Util.applyMaskToTexture(tex, mask)
	if not tex then return end
	-- If the mask is already applied to this texture, do nothing
	if tex._zBBG_appliedMask == mask then return end
	-- If there is a different mask applied, remove it first
	if tex._zBBG_appliedMask then
		tex:RemoveMaskTexture(tex._zBBG_appliedMask)
		tex._zBBG_appliedMask = nil
	end
	if mask then
		tex:AddMaskTexture(mask)
		tex._zBBG_appliedMask = mask
	end
end

-- Remove mask from texture and clear tracking
function Util.removeMaskFromTexture(tex)
	if not tex then return end
	if tex._zBBG_appliedMask then
		tex:RemoveMaskTexture(tex._zBBG_appliedMask)
		tex._zBBG_appliedMask = nil
	end
end

-- Helper function to get font path from LibSharedMedia
function Util.getFontPath(fontName)
	local LSM = LibStub("LibSharedMedia-3.0", true)
	if LSM then
		return LSM:Fetch("font", fontName) or fontName
	end
	return fontName
end

-- Unified function to apply mask to a set of textures
-- Eliminates repeated mask application code scattered throughout
function Util.applyMaskToSet(mask, ...)
	for i = 1, select("#", ...) do
		local tex = select(i, ...)
		if tex then
			Util.applyMaskToTexture(tex, mask)
		end
	end
end

-- Unified function to remove mask from a set of textures
function Util.removeMaskFromSet(...)
	for i = 1, select("#", ...) do
		local tex = select(i, ...)
		if tex then
			Util.removeMaskFromTexture(tex)
		end
	end
end