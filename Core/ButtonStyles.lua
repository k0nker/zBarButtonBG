-- Button style definitions for zBarButtonBG
-- Defines button shapes, regions with metadata, and asset paths

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.ButtonStyles = {}
local ButtonStyles = addonTable.Core.ButtonStyles

-- Get localization
local L = LibStub("AceLocale-3.0"):GetLocale("zBarButtonBG")

-- Base asset path
local ASSETS_PATH = "Interface\\AddOns\\zBarButtonBG\\Assets\\"

-- ############################################################
-- REGION METADATA SYSTEM
-- ############################################################
-- Defines all button regions with their properties
-- This drives all region processing instead of scattered conditionals
--
-- Properties:
--   * key - The property name on the button object (button.icon, button.NormalTexture, etc.)
--   * canMask - Whether this region can have a mask applied
--   * canHide - Whether this region can be hidden
--   * canColor - Whether this region can be color-tinted
--   * canTexture - Whether this region can have a new texture applied
--   * hideByDefault - Whether to hide this region during initial setup
--   * scale - Default scale for this region
--   * texCoord - Default texture coordinates { x1, x2, y1, y2 }

ButtonStyles.regions = {
    -- Icon: The actual spell/ability icon
    Icon = {
        key = "icon",
        canMask = true,
        canHide = true,
        canColor = false,
        canTexture = false,
        scale = 1.05,
        texCoord = { 0.07, 0.93, 0.07, 0.93 },
        description = "Spell/ability icon image",
    },

    -- Normal: Blizzard's default border texture
    Normal = {
        key = "NormalTexture",
        canMask = false,
        canHide = true,
        canColor = true,
        canTexture = false,
        hideByDefault = true,
        alpha = 0,
        description = "Default border (always hidden)",
    },

    -- Highlight: Blizzard's hover effect
    Highlight = {
        key = "HighlightTexture",
        canMask = false,
        canHide = true,
        canColor = true,
        canTexture = false,
        hideByDefault = true,
        alpha = 0,
        description = "Hover/highlight effect (always hidden)",
    },

    -- Pushed: Blizzard's click effect
    Pushed = {
        key = "PushedTexture",
        canMask = false,
        canHide = true,
        canColor = true,
        canTexture = false,
        hideByDefault = true,
        alpha = 0,
        description = "Pushed/clicked effect (always hidden)",
    },

    -- Checked: Blizzard's toggled state
    Checked = {
        key = "CheckedTexture",
        canMask = false,
        canHide = true,
        canColor = true,
        canTexture = false,
        hideByDefault = true,
        alpha = 0,
        description = "Checked/active state (always hidden)",
    },

    -- SlotBackground: Background texture behind the icon
    SlotBackground = {
        key = "SlotBackground",
        canMask = true,
        canHide = true,
        canColor = true,
        canTexture = true,
        description = "Background texture behind icon",
    },

    -- Cooldown: Spiral showing ability cooldown
    Cooldown = {
        key = "cooldown",
        canMask = false,
        canHide = false,
        canColor = false,
        canTexture = false,
        fillsButton = true,
        description = "Cooldown spiral (fills button)",
    },

    -- SpellCastAnimFrame: Spell cast animation
    SpellCastAnimFrame = {
        key = "SpellCastAnimFrame",
        canMask = false,
        canHide = true,
        canColor = false,
        canTexture = false,
        hideByDefault = true,
        description = "Spell cast animation (hidden)",
    },

    -- InterruptDisplay: Interrupt display
    InterruptDisplay = {
        key = "InterruptDisplay",
        canMask = false,
        canHide = true,
        canColor = false,
        canTexture = false,
        hideByDefault = true,
        description = "Interrupt display (hidden)",
    },

    -- IconMask: Blizzard's original mask (should be removed)
    IconMask = {
        key = "IconMask",
        canMask = false,
        canHide = true,
        canColor = false,
        canTexture = false,
        hideByDefault = true,
        description = "Blizzard's original mask (removed)",
    },
}

-- ############################################################
-- BUTTON STYLES (Shape Definitions)
-- ############################################################
-- Each style defines the textures for its button shape
-- Organized separately from region metadata for clarity

ButtonStyles.styles = {
    ["Rounded"] = {
        nameKey = "Rounded",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_Rounded",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_Rounded",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_Rounded",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_Rounded",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_Rounded",
        descriptionKey = "Rounded button style",
        flipbookIncluded = true,
    },
    ["Square"] = {
        nameKey = "Square",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_Square",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_Square",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_Square",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_Square",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_Square",
        descriptionKey = "Sharp square button style",
        flipbookIncluded = true,
    },
    ["Octagon"] = {
        nameKey = "Octagon",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_Octagon",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_Octagon",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_Octagon",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_Octagon",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_Octagon",
        descriptionKey = "Octagon button style",
        flipbookIncluded = true,
    },
    ["OctagonFlipped"] = {
        nameKey = "Octagon Flipped",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_OctagonFlipped",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_OctagonFlipped",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_OctagonFlipped",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_OctagonFlipped",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_OctagonFlipped",
        descriptionKey = "Octagon flipped button style",
        flipbookIncluded = true,
    },
    ["Hexagon"] = {
        nameKey = "Hexagon",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_Hexagon",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_Hexagon",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_Hexagon",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_Hexagon",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_Hexagon",
        descriptionKey = "Hexagon button style",
        flipbookIncluded = true,
    },
    ["HexagonFlipped"] = {
        nameKey = "Hexagon Flipped",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_HexagonFlipped",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_HexagonFlipped",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_HexagonFlipped",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_HexagonFlipped",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_HexagonFlipped",
        descriptionKey = "Hexagon flipped button style",
        flipbookIncluded = true,
    },
    ["Circle"] = {
        nameKey = "Circle",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_Circle",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_Circle",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_Circle",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_Circle",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_Circle",
        descriptionKey = "Circle button style",
        flipbookIncluded = true,
    },
    ["Rhomboid"] = {
        nameKey = "Rhomboid",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_Rhomboid",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_Rhomboid",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_Rhomboid",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_Rhomboid",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_Rhomboid",
        descriptionKey = "Rhomboid button style",
        flipbookIncluded = true,
    },
    ["RhomboidFlipped"] = {
        nameKey = "Rhomboid Flipped",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_RhomboidFlipped",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_RhomboidFlipped",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_RhomboidFlipped",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_RhomboidFlipped",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_RhomboidFlipped",
        descriptionKey = "Rhomboid flipped button style",
        flipbookIncluded = true,
    },
    ["RhomboidTall"] = {
        nameKey = "Rhomboid Tall",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_RhomboidTall",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_RhomboidTall",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_RhomboidTall",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_RhomboidTall",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_RhomboidTall",
        descriptionKey = "Rhomboid tall button style",
        flipbookIncluded = true,
    },
    ["RhomboidTallFlipped"] = {
        nameKey = "Rhomboid Tall Flipped",
        maskTexture = ASSETS_PATH .. "ButtonIconMask_RhomboidTallFlipped",
        swipeMaskTexture = ASSETS_PATH .. "ButtonIconSwipe_RhomboidTallFlipped",
        borderTexture = ASSETS_PATH .. "ButtonIconBorder_RhomboidTallFlipped",
        procFlipbookTexture = ASSETS_PATH .. "FlipbookSheet_RhomboidTallFlipped",
        fullMaskTexture = ASSETS_PATH .. "ButtonIconFullMask_RhomboidTallFlipped",
        descriptionKey = "Rhomboid tall flipped button style",
        flipbookIncluded = true,
    },

}

-- ############################################################
-- ACCESSOR FUNCTIONS
-- ############################################################

-- Get a region definition by name
function ButtonStyles.GetRegion(regionName)
    return ButtonStyles.regions[regionName]
end

-- Get all regions (for iteration)
function ButtonStyles.GetRegions()
    return ButtonStyles.regions
end

-- Get a specific style by name
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

-- ############################################################
-- CONSOLIDATED TEXTURE PATH GETTERS
-- ############################################################
-- These replace scattered texture lookups throughout the codebase

-- Get all texture paths (mask, border, highlight) for a button style
-- Returns table: { mask = ..., border = ..., highlight = ... }
-- Accepts either styleName (string) or barName (gets style from per-bar profile)
function ButtonStyles.GetPaths(styleOrBarName)
    local styleName

    -- If it looks like a bar name, get the style from GetSettingInfo
    if styleOrBarName and not ButtonStyles.styles[styleOrBarName] then
        -- Likely a bar name, get style from per-bar profile
        if zBarButtonBG.GetSettingInfo then
            styleName = zBarButtonBG.GetSettingInfo(styleOrBarName, "buttonStyle")
        end
    end

    styleName = styleName or styleOrBarName or zBarButtonBG.charSettings.buttonStyle or "Square"
    local style = ButtonStyles.GetStyle(styleName)
    if not style then
        style = ButtonStyles.styles["Square"]
    end
    return {
        mask = style.maskTexture,
        border = style.borderTexture,
    }
end

-- Get mask texture path based on button style
function ButtonStyles.GetMaskPath(styleName)
    local paths = ButtonStyles.GetPaths(styleName)
    return paths.mask
end

-- Get border texture path based on button style
function ButtonStyles.GetBorderPath(styleName)
    local paths = ButtonStyles.GetPaths(styleName)
    return paths.border
end

-- Get highlight texture path based on button style
function ButtonStyles.GetHighlightPath(styleName)
    local paths = ButtonStyles.GetPaths(styleName)
    return paths.highlight
end

-- Get full mask texture path based on button style (can be used for various overlay purposes)
-- Accepts either styleName (string) or barName (gets style from per-bar profile)
function ButtonStyles.GetSwipeMaskPath(styleOrBarName)
    local styleName

    -- If it looks like a bar name, get the style from GetSettingInfo
    if styleOrBarName and not ButtonStyles.styles[styleOrBarName] then
        -- Likely a bar name, get style from per-bar profile
        if zBarButtonBG.GetSettingInfo then
            styleName = zBarButtonBG.GetSettingInfo(styleOrBarName, "buttonStyle")
        end
    end

    styleName = styleName or styleOrBarName or zBarButtonBG.charSettings.buttonStyle or "Square"
    local style = ButtonStyles.GetStyle(styleName)
    if not style then
        style = ButtonStyles.styles["Square"]
    end
    return style.swipeMaskTexture
end

-- Get proc flipbook texture path based on button style
-- Accepts either styleName (string) or barName (gets style from per-bar profile)
function ButtonStyles.GetProcFlipbookPath(styleOrBarName)
    local styleName

    -- If it looks like a bar name, get the style from GetSettingInfo
    if styleOrBarName and not ButtonStyles.styles[styleOrBarName] then
        -- Likely a bar name, get style from per-bar profile
        if zBarButtonBG.GetSettingInfo then
            styleName = zBarButtonBG.GetSettingInfo(styleOrBarName, "buttonStyle")
        end
    end

    styleName = styleName or styleOrBarName or zBarButtonBG.charSettings.buttonStyle or "Square"
    local style = ButtonStyles.GetStyle(styleName)
    if not style then
        style = ButtonStyles.styles["Square"]
    end
    return style.procFlipbookTexture
end

-- Get suggested flipbook texture path based on button style
function ButtonStyles.GetFullMaskPath(styleName)
    styleName = styleName or zBarButtonBG.charSettings.buttonStyle or "Square"
    local style = ButtonStyles.GetStyle(styleName)
    if not style then
        style = ButtonStyles.styles["Square"]
    end
    return style.fullMaskTexture
end

-- REGION PROCESSING
-- ############################################################
-- REGION SKINNING
-- ############################################################
-- Process regions using metadata instead of scattered conditionals

-- Process a single region based on its metadata definition
-- This function encapsulates all logic for region handling
function ButtonStyles.SkinRegion(button, regionName, regionDef)
    if not button or not regionDef then return end

    local region = button[regionDef.key]
    if not region then return end

    -- Hide regions that should be hidden by default
    if regionDef.hideByDefault then
        region:SetAlpha(regionDef.alpha or 0)
        region:Hide()
        -- Prevent Blizzard from showing these
        region:SetScript("OnShow", function(self) self:Hide() end)
        return
    end

    -- Handle regions that fill the button (like Cooldown)
    if regionDef.fillsButton then
        region:SetAllPoints(button)
        return
    end

    -- Handle Icon-specific positioning and texture coordinates
    if regionName == "Icon" and region then
        -- Remove Blizzard's original mask
        if button.IconMask then
            region:RemoveMaskTexture(button.IconMask)
        end

        -- Apply scale and texture coordinates from metadata
        region:SetScale(regionDef.scale or 1.0)
        local tc = regionDef.texCoord
        region:SetTexCoord(tc[1], tc[2], tc[3], tc[4])

        -- Position to fill button
        region:ClearAllPoints()
        region:SetAllPoints(button)
    end
end

-- Initialize all button regions in a single pass using metadata
-- This replaces scattered region-specific code throughout
function ButtonStyles.InitializeButton(button)
    for regionName, regionDef in pairs(ButtonStyles.regions) do
        ButtonStyles.SkinRegion(button, regionName, regionDef)
    end
end
