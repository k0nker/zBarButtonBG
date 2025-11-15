-- Utility helper functions for zBarButtonBG

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

-- Get mask texture path based on current button style
function Util.getMaskPath()
	local ButtonStyles = addonTable.Core.ButtonStyles
	local styleName = zBarButtonBG.charSettings.buttonStyle or "Round"
	return ButtonStyles.GetMaskPath(styleName)
end

-- Get border texture path based on current button style
function Util.getBorderPath()
	local ButtonStyles = addonTable.Core.ButtonStyles
	local styleName = zBarButtonBG.charSettings.buttonStyle or "Round"
	return ButtonStyles.GetBorderPath(styleName)
end

-- Check if current button style is "Square" (for positioning logic)
function Util.isSquareButtonStyle()
	return zBarButtonBG.charSettings.buttonStyle == "Square"
end

-- Helper to apply/remove a mask to a texture while tracking what mask is applied
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

-- Remove mask from texture
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

