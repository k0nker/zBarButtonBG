-- Global constants and configuration tables for zBarButtonBG

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.Constants = {}
local C = addonTable.Core.Constants

-- Developer toggle for cooldown overlay feature
-- This is NOT a SavedVariable - it's a developer-level control
C.MIDNIGHT_COOLDOWN = true

-- Asset paths
C.ASSETS_PATH = "Interface\\AddOns\\zBarButtonBG\\Assets\\"
C.MASK_SQUARE = C.ASSETS_PATH .. "ButtonIconMask_Square"
C.MASK_ROUNDED = C.ASSETS_PATH .. "ButtonIconMask_Rounded"
C.BORDER_SQUARE = C.ASSETS_PATH .. "ButtonIconBorder_Square"
C.BORDER_ROUNDED = C.ASSETS_PATH .. "ButtonIconBorder_Rounded"

-- Addon identifier for printing
C.ADDON_COLOR = "|cFF72B061"
C.ADDON_NAME = C.ADDON_COLOR .. "zBarButtonBG:|r"

-- Default positioning offsets (can be overridden by settings)
C.DEFAULT_MACRO_NAME_OFFSET_X = 0
C.DEFAULT_MACRO_NAME_OFFSET_Y = 2
C.DEFAULT_COUNT_OFFSET_X = 0
C.DEFAULT_COUNT_OFFSET_Y = 3
C.DEFAULT_KEYBIND_OFFSET_X = -1
C.DEFAULT_KEYBIND_OFFSET_Y = -2

-- Text alignment defaults
C.DEFAULT_TEXT_ALIGNMENT = "CENTER"
C.DEFAULT_TEXT_VERTICAL = "MIDDLE"
C.DEFAULT_MACRO_NAME_POSITION = "BOTTOM"
