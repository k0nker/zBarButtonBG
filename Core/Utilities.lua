-- Utility helper functions for zBarButtonBG
-- Handles sizing, positioning, masking, coloring, and font management

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.Utilities = {}
local Util = addonTable.Core.Utilities
local C = addonTable.Core.Constants

-- ############################################################
-- DEBUG & PRINT
-- ############################################################

-- Print helper that prefixes our addon name
function Util.print(arg)
	if arg == "" or arg == nil then
		return
	else
		print(C.ADDON_NAME .. " " .. arg)
	end
	return false
end

-- ############################################################
-- COLOR MANAGEMENT
-- ############################################################

-- Get color values as individual components or table
function Util.GetColor(colorData, alpha)
	if type(colorData) == "table" then
		return colorData.r or 1, colorData.g or 1, colorData.b or 1, alpha or colorData.a or 1
	else
		return 1, 1, 1, alpha or 1
	end
end

-- Get color table with optional class color override
-- Returns normalized color table with r, g, b, a components
-- barName parameter (optional) enables per-bar profile lookup
function Util.getColorTable(colorKey, useClassColorKey, barName)
	local useClassColor = zBarButtonBG.GetSettingInfo(barName, useClassColorKey)
	if useClassColor then
		local classColor = C_ClassColor.GetClassColor(select(2, UnitClass("player")))
		return { 
			r = classColor.r, 
			g = classColor.g, 
			b = classColor.b, 
			a = 1 
		}
	else
		local c = zBarButtonBG.GetSettingInfo(barName, colorKey)
		if not c or not c.r then
			c = addonTable.Core.Defaults.profile[colorKey] or { r = 1, g = 1, b = 1, a = 1 }
		end
		return { 
			r = c.r, 
			g = c.g, 
			b = c.b, 
			a = c.a 
		}
	end
end

-- ############################################################
-- TEXTURE PATH UTILITIES
-- ############################################################
-- Consolidated texture path lookups

-- Get all texture paths for current button style
function Util.getTexturePaths(styleName)
	local ButtonStyles = addonTable.Core.ButtonStyles
	return ButtonStyles.GetPaths(styleName)
end

-- Get mask texture path based on current button style
function Util.getMaskPath(styleName)
	local ButtonStyles = addonTable.Core.ButtonStyles
	return ButtonStyles.GetMaskPath(styleName)
end

-- Get border texture path based on current button style
function Util.getBorderPath(styleName)
	local ButtonStyles = addonTable.Core.ButtonStyles
	return ButtonStyles.GetBorderPath(styleName)
end

-- Get highlight texture path based on current button style
function Util.getHighlightPath(styleName)
	local ButtonStyles = addonTable.Core.ButtonStyles
	return ButtonStyles.GetHighlightPath(styleName)
end

-- ############################################################
-- POSITIONING UTILITIES
-- ############################################################

-- Clear all points and set a single point
function Util.ClearSetPoint(region, point, anchor, relPoint, offsetX, offsetY, setAllPoints)
	if not region then return end
	anchor = anchor or region:GetParent()
	
	region:ClearAllPoints()
	
	if setAllPoints then
		region:SetAllPoints(anchor)
	else
		region:SetPoint(
			point or "CENTER",
			anchor,
			relPoint or "CENTER",
			offsetX or 0,
			offsetY or 0
		)
	end
end

-- ############################################################
-- MASKING UTILITIES
-- ############################################################
-- Centralized mask application and removal

-- Apply mask to a texture, tracking it to prevent duplicates
function Util.applyMaskToTexture(tex, mask)
	if not tex then return end
	
	-- If this mask is already applied, do nothing
	if tex._zBBG_appliedMask == mask then return end
	
	-- Remove previous mask if different one is applied
	if tex._zBBG_appliedMask then
		tex:RemoveMaskTexture(tex._zBBG_appliedMask)
		tex._zBBG_appliedMask = nil
	end
	
	-- Apply new mask if provided
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

-- Apply mask to multiple textures in one call (batch operation)
function Util.applyMaskToSet(mask, ...)
	for i = 1, select("#", ...) do
		local tex = select(i, ...)
		if tex then
			Util.applyMaskToTexture(tex, mask)
		end
	end
end

-- Remove mask from multiple textures in one call
function Util.removeMaskFromSet(...)
	for i = 1, select("#", ...) do
		local tex = select(i, ...)
		if tex then
			Util.removeMaskFromTexture(tex)
		end
	end
end

-- ############################################################
-- FONT UTILITIES
-- ############################################################

-- Get font path from LibSharedMedia
function Util.getFontPath(fontName)
	local LSM = LibStub("LibSharedMedia-3.0", true)
	if LSM then
		return LSM:Fetch("font", fontName) or fontName
	end
	return fontName
end
