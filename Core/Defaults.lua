-- Default profile settings for zBarButtonBG
-- This is the single source of truth for all default values

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.Defaults = {
	profile = {
		enabled = true,
		buttonStyle = "Square",
		showBorder = false,
		borderColor = { r = 0.2, g = 0.2, b = 0.2, a = 1 },
		useClassColorBorder = false,
		showBackdrop = true,
		outerColor = { r = 0.08, g = 0.08, b = 0.08, a = 1 },
		useClassColorOuter = false,
		backdropTopAdjustment = 3,
		backdropBottomAdjustment = 3,
		backdropLeftAdjustment = 3,
		backdropRightAdjustment = 3,
		showSlotBackground = true,
		innerColor = { r = 0.1, g = 0.1, b = 0.1, a = 1 },
		useClassColorInner = false,
		showRangeIndicator = true,
		rangeIndicatorColor = { r = .42, g = 0.07, b = .12, a = 0.75 },
		fadeCooldown = false,
		cooldownColor = { r = 0, g = 0, b = 0, a = 0.5 },
		macroNameFont = "Homespun",
		macroNameFontSize = 12,
		macroNameFontFlags = "OUTLINE",
		macroNameWidth = 42,
		macroNameHeight = 30,
		macroNameColor = { r = 1, g = 1, b = 1, a = 1 },
		macroNameJustification = "LEFT",
		macroNamePosition = "BOTTOM",
		macroNameOffsetX = 0,
		macroNameOffsetY = 0,
		countFont = "Homespun",
		countFontSize = 16,
		countFontFlags = "OUTLINE",
		countWidth = 42,
		countHeight = 15,
		countColor = { r = 1, g = 1, b = 1, a = 1 },
		countOffsetX = 0,
		countOffsetY = 0,
		keybindFont = "Homespun",
		keybindFontSize = 12,
		keybindFontFlags = "OUTLINE",
		keybindWidth = 42,
		keybindHeight = 12,
		keybindColor = { r = 1, g = 1, b = 1, a = 1 },
		keybindOffsetX = 0,
		keybindOffsetY = 0
	}
}
