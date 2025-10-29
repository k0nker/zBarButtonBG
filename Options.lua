-- Options.lua - Ace3 Configuration following SorhaQuestLog pattern

function zBarButtonBGAce:GetOptionsTable()
	local options = {
		type = "group",
		name = "zBarButtonBG",
		args = {
			buttonSettings = {
				order = 1,
				type = "group",
				name = "Button Settings",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Button Background Settings",
					},
					enabled = {
						order = 2,
						type = "toggle",
						name = "Enable Action Bar Backgrounds",
						desc = "Toggle action bar backgrounds on/off. Note: /reload may be required when disabling to restore default borders.",
						get = function() return self.db.profile.enabled end,
						set = function(_, value) 
							self.db.profile.enabled = value
							-- Update native system
							zBarButtonBG.charSettings.enabled = value
							if value and not zBarButtonBG.enabled then
								zBarButtonBG.enabled = true
								zBarButtonBG.createActionBarBackgrounds()
								zBarButtonBG.print("Action bar backgrounds |cFF00FF00enabled|r")
							elseif not value and zBarButtonBG.enabled then
								zBarButtonBG.enabled = false
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.print("Action bar backgrounds |cFFFF0000disabled|r")
							end
						end,
					},
					spacer1 = {
						order = 3,
						type = "description",
						name = " ",
					},
					squareButtons = {
						order = 4,
						type = "toggle",
						name = "Square Buttons",
						desc = "Make action buttons square instead of rounded",
						get = function() return self.db.profile.squareButtons end,
						set = function(_, value) 
							self.db.profile.squareButtons = value
							zBarButtonBG.charSettings.squareButtons = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					showBackdrop = {
						order = 5,
						type = "toggle",
						name = "Show Backdrop",
						desc = "Show the outer backdrop frame behind each button",
						get = function() return self.db.profile.showBackdrop end,
						set = function(_, value) 
							self.db.profile.showBackdrop = value
							zBarButtonBG.charSettings.showBackdrop = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					useClassColorOuter = {
						order = 6,
						type = "toggle",
						name = "Use Class Color for Backdrop",
						desc = "Use your class color for the outer backdrop",
						disabled = function() return not self.db.profile.showBackdrop end,
						get = function() return self.db.profile.useClassColorOuter end,
						set = function(_, value) 
							self.db.profile.useClassColorOuter = value
							zBarButtonBG.charSettings.useClassColorOuter = value
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					outerColor = {
						order = 7,
						type = "color",
						name = "Backdrop Color",
						desc = "Color of the outer backdrop frame",
						disabled = function() return not self.db.profile.showBackdrop or self.db.profile.useClassColorOuter end,
						hasAlpha = true,
						get = function() 
							local c = self.db.profile.outerColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a) 
							self.db.profile.outerColor = {r = r, g = g, b = b, a = a}
							zBarButtonBG.charSettings.outerColor = {r = r, g = g, b = b, a = a}
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					spacer2 = {
						order = 8,
						type = "description",
						name = " ",
					},
					showSlotBackground = {
						order = 9,
						type = "toggle",
						name = "Show Slot Background",
						desc = "Show the slot background fill behind each button icon",
						get = function() return self.db.profile.showSlotBackground end,
						set = function(_, value) 
							self.db.profile.showSlotBackground = value
							zBarButtonBG.charSettings.showSlotBackground = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					useClassColorInner = {
						order = 10,
						type = "toggle",
						name = "Use Class Color for Button Background",
						desc = "Use your class color for the button background",
						disabled = function() return not self.db.profile.showSlotBackground end,
						get = function() return self.db.profile.useClassColorInner end,
						set = function(_, value) 
							self.db.profile.useClassColorInner = value
							zBarButtonBG.charSettings.useClassColorInner = value
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					innerColor = {
						order = 11,
						type = "color",
						name = "Button Background Color",
						desc = "Color of the button slot background",
						disabled = function() return not self.db.profile.showSlotBackground or self.db.profile.useClassColorInner end,
						hasAlpha = true,
						get = function() 
							local c = self.db.profile.innerColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a) 
							self.db.profile.innerColor = {r = r, g = g, b = b, a = a}
							zBarButtonBG.charSettings.innerColor = {r = r, g = g, b = b, a = a}
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					spacer3 = {
						order = 12,
						type = "description",
						name = " ",
					},
					showBorder = {
						order = 13,
						type = "toggle",
						name = "Enable Button Border",
						desc = "Add a border around each action button icon",
						get = function() return self.db.profile.showBorder end,
						set = function(_, value) 
							self.db.profile.showBorder = value
							zBarButtonBG.charSettings.showBorder = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					useClassColorBorder = {
						order = 14,
						type = "toggle",
						name = "Use Class Color for Button Border",
						desc = "Use your class color for the icon border",
						disabled = function() return not self.db.profile.showBorder end,
						get = function() return self.db.profile.useClassColorBorder end,
						set = function(_, value) 
							self.db.profile.useClassColorBorder = value
							zBarButtonBG.charSettings.useClassColorBorder = value
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					borderColor = {
						order = 15,
						type = "color",
						name = "Button Border Color",
						desc = "Color of the button icon border",
						disabled = function() return not self.db.profile.showBorder or self.db.profile.useClassColorBorder end,
						hasAlpha = true,
						get = function() 
							local c = self.db.profile.borderColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a) 
							self.db.profile.borderColor = {r = r, g = g, b = b, a = a}
							zBarButtonBG.charSettings.borderColor = {r = r, g = g, b = b, a = a}
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					spacer4 = {
						order = 16,
						type = "description",
						name = " ",
					},
					resetButton = {
						order = 17,
						type = "execute",
						name = "Reset to Defaults",
						desc = "Reset all settings to their default values",
						func = function()
							-- Reset profile to defaults (zBarButtonBG.charSettings points to profile, so it updates automatically)
							self.db:ResetProfile()
							-- Trigger rebuild
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
							zBarButtonBG.print("Settings reset to defaults!")
						end,
					},
				},
			},
			indicators = {
				order = 2,
				type = "group",
				name = "Indicators",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Visual Indicators",
					},
					showRangeIndicator = {
						order = 2,
						type = "toggle",
						name = "Show Out-of-Range Highlight",
						desc = "Show a colored overlay on buttons when the ability is out of range",
						get = function() return self.db.profile.showRangeIndicator end,
						set = function(_, value) 
							self.db.profile.showRangeIndicator = value
							zBarButtonBG.charSettings.showRangeIndicator = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					rangeIndicatorColor = {
						order = 3,
						type = "color",
						name = "Range Indicator Color",
						desc = "Color of the out-of-range overlay",
						disabled = function() return not self.db.profile.showRangeIndicator end,
						hasAlpha = true,
						get = function() 
							local c = self.db.profile.rangeIndicatorColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a) 
							self.db.profile.rangeIndicatorColor = {r = r, g = g, b = b, a = a}
							zBarButtonBG.charSettings.rangeIndicatorColor = {r = r, g = g, b = b, a = a}
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
					spacer1 = {
						order = 4,
						type = "description",
						name = " ",
					},
					fadeCooldown = {
						order = 5,
						type = "toggle",
						name = "Fade On Cooldown",
						desc = "Add a dark overlay to buttons while on cooldown",
						get = function() return self.db.profile.fadeCooldown end,
						set = function(_, value) 
							self.db.profile.fadeCooldown = value
							zBarButtonBG.charSettings.fadeCooldown = value
							if zBarButtonBG.enabled then
								zBarButtonBG.removeActionBarBackgrounds()
								zBarButtonBG.createActionBarBackgrounds()
							end
						end,
					},
					cooldownColor = {
						order = 6,
						type = "color",
						name = "Cooldown Overlay Color",
						desc = "Color of the cooldown overlay",
						disabled = function() return not self.db.profile.fadeCooldown end,
						hasAlpha = true,
						get = function() 
							local c = self.db.profile.cooldownColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a) 
							self.db.profile.cooldownColor = {r = r, g = g, b = b, a = a}
							zBarButtonBG.charSettings.cooldownColor = {r = r, g = g, b = b, a = a}
							if zBarButtonBG.enabled and zBarButtonBG.updateColors then
								zBarButtonBG.updateColors()
							end
						end,
					},
				},
			},
			textSettings = {
				order = 3,
				type = "group",
				name = "Text Settings",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Font and Text Configuration",
					},
					macroNameHeader = {
						order = 2,
						type = "header",
						name = "Macro Name Font",
					},
					macroNameFont = {
						order = 3,
						type = "select",
						name = "Macro Name Font",
						desc = "Font family for macro names",
						values = {
							["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata (Default)",
							["Fonts\\ARIALN.TTF"] = "Arial Narrow",
							["Fonts\\skurri.ttf"] = "Skurri",
							["Fonts\\MORPHEUS.ttf"] = "Morpheus",
							["Fonts\\NIM_____.ttf"] = "Nimrod MT",
							["Fonts\\FRIENDS.TTF"] = "Friends",
							["Interface\\AddOns\\SharedMedia\\fonts\\DIABLO.TTF"] = "Diablo (if available)",
							["Fonts\\2002.TTF"] = "2002",
							["Fonts\\2002B.TTF"] = "2002 Bold",
							["Fonts\\ARKAI_T.ttf"] = "AR Kai",
							["Fonts\\bHEI00M.ttf"] = "BHei",
							["Fonts\\bKAI00M.ttf"] = "BKai",
							["Fonts\\bLEI00D.ttf"] = "BLei",
							["Fonts\\K_Damage.TTF"] = "Damage Font",
							["Fonts\\K_Pagetext.TTF"] = "Page Text",
						},
						get = function() return self.db.profile.macroNameFont end,
						set = function(_, value) 
							self.db.profile.macroNameFont = value
							zBarButtonBG.charSettings.macroNameFont = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameFontFlags = {
						order = 4,
						type = "select",
						name = "Macro Name Font Style",
						desc = "Font style flags for macro names",
						values = {
							[""] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome",
						},
						get = function() return self.db.profile.macroNameFontFlags end,
						set = function(_, value) 
							self.db.profile.macroNameFontFlags = value
							zBarButtonBG.charSettings.macroNameFontFlags = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameColor = {
						order = 5,
						type = "color",
						name = "Macro Name Color",
						desc = "Color of the macro name text",
						hasAlpha = true,
						get = function() 
							local c = self.db.profile.macroNameColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a) 
							self.db.profile.macroNameColor = {r = r, g = g, b = b, a = a}
							zBarButtonBG.charSettings.macroNameColor = {r = r, g = g, b = b, a = a}
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameFontSize = {
						order = 6,
						type = "range",
						name = "Macro Name Font Size",
						desc = "Size of the macro name text",
						min = 6,
						max = 24,
						step = 1,
						get = function() return self.db.profile.macroNameFontSize end,
						set = function(_, value) 
							self.db.profile.macroNameFontSize = value
							zBarButtonBG.charSettings.macroNameFontSize = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameWidth = {
						order = 7,
						type = "range",
						name = "Macro Name Width",
						desc = "Width of the macro name text frame",
						min = 20,
						max = 200,
						step = 1,
						get = function() return self.db.profile.macroNameWidth end,
						set = function(_, value) 
							self.db.profile.macroNameWidth = value
							zBarButtonBG.charSettings.macroNameWidth = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameHeight = {
						order = 8,
						type = "range",
						name = "Macro Name Height",
						desc = "Height of the macro name text frame",
						min = 8,
						max = 50,
						step = 1,
						get = function() return self.db.profile.macroNameHeight end,
						set = function(_, value) 
							self.db.profile.macroNameHeight = value
							zBarButtonBG.charSettings.macroNameHeight = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					macroNameOffsetX = {
						order = 9,
						type = "range",
						name = "Macro Name X Offset",
						desc = "Horizontal positioning offset for macro name text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.macroNameOffsetX end,
						set = function(_, value) 
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.macroNameOffsetX = value
							zBarButtonBG.charSettings.macroNameOffsetX = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
					macroNameOffsetY = {
						order = 10,
						type = "range",
						name = "Macro Name Y Offset",
						desc = "Vertical positioning offset for macro name text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.macroNameOffsetY end,
						set = function(_, value) 
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.macroNameOffsetY = value
							zBarButtonBG.charSettings.macroNameOffsetY = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
					spacer1 = {
						order = 11,
						type = "description",
						name = " ",
					},
					countHeader = {
						order = 12,
						type = "header",
						name = "Count/Charge Font",
					},
					countFont = {
						order = 13,
						type = "select",
						name = "Count Font",
						desc = "Font family for count/charge numbers",
						values = {
							["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata (Default)",
							["Fonts\\ARIALN.TTF"] = "Arial Narrow",
							["Fonts\\skurri.ttf"] = "Skurri",
							["Fonts\\MORPHEUS.ttf"] = "Morpheus",
							["Fonts\\NIM_____.ttf"] = "Nimrod MT",
							["Fonts\\FRIENDS.TTF"] = "Friends",
							["Interface\\AddOns\\SharedMedia\\fonts\\DIABLO.TTF"] = "Diablo (if available)",
							["Fonts\\2002.TTF"] = "2002",
							["Fonts\\2002B.TTF"] = "2002 Bold",
							["Fonts\\ARKAI_T.ttf"] = "AR Kai",
							["Fonts\\bHEI00M.ttf"] = "BHei",
							["Fonts\\bKAI00M.ttf"] = "BKai",
							["Fonts\\bLEI00D.ttf"] = "BLei",
							["Fonts\\K_Damage.TTF"] = "Damage Font",
							["Fonts\\K_Pagetext.TTF"] = "Page Text",
						},
						get = function() return self.db.profile.countFont end,
						set = function(_, value) 
							self.db.profile.countFont = value
							zBarButtonBG.charSettings.countFont = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countFontSize = {
						order = 14,
						type = "range",
						name = "Count Font Size",
						desc = "Size of the count/charge text",
						min = 6,
						max = 24,
						step = 1,
						get = function() return self.db.profile.countFontSize end,
						set = function(_, value) 
							self.db.profile.countFontSize = value
							zBarButtonBG.charSettings.countFontSize = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countFontFlags = {
						order = 15,
						type = "select",
						name = "Count Font Style",
						desc = "Font style flags for count/charge numbers",
						values = {
							[""] = "None",
							["OUTLINE"] = "Outline",
							["THICKOUTLINE"] = "Thick Outline",
							["MONOCHROME"] = "Monochrome",
						},
						get = function() return self.db.profile.countFontFlags end,
						set = function(_, value) 
							self.db.profile.countFontFlags = value
							zBarButtonBG.charSettings.countFontFlags = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countWidth = {
						order = 16,
						type = "range",
						name = "Count Width",
						desc = "Width of the count text frame",
						min = 10,
						max = 100,
						step = 1,
						get = function() return self.db.profile.countWidth end,
						set = function(_, value) 
							self.db.profile.countWidth = value
							zBarButtonBG.charSettings.countWidth = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countHeight = {
						order = 17,
						type = "range",
						name = "Count Height",
						desc = "Height of the count text frame",
						min = 8,
						max = 50,
						step = 1,
						get = function() return self.db.profile.countHeight end,
						set = function(_, value) 
							self.db.profile.countHeight = value
							zBarButtonBG.charSettings.countHeight = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countColor = {
						order = 18,
						type = "color",
						name = "Count Color",
						desc = "Color of the count/charge text",
						hasAlpha = true,
						get = function() 
							local c = self.db.profile.countColor
							return c.r, c.g, c.b, c.a
						end,
						set = function(_, r, g, b, a) 
							self.db.profile.countColor = {r = r, g = g, b = b, a = a}
							zBarButtonBG.charSettings.countColor = {r = r, g = g, b = b, a = a}
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
					},
					countOffsetX = {
						order = 19,
						type = "range",
						name = "Count X Offset",
						desc = "Horizontal positioning offset for count/charge text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.countOffsetX end,
						set = function(_, value) 
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.countOffsetX = value
							zBarButtonBG.charSettings.countOffsetX = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
					countOffsetY = {
						order = 20,
						type = "range",
						name = "Count Y Offset",
						desc = "Vertical positioning offset for count/charge text",
						min = -50,
						max = 50,
						step = 1,
						bigStep = 5,
						get = function() return self.db.profile.countOffsetY end,
						set = function(_, value) 
							-- Clamp value to valid range
							value = math.max(-50, math.min(50, tonumber(value) or 0))
							self.db.profile.countOffsetY = value
							zBarButtonBG.charSettings.countOffsetY = value
							if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
								zBarButtonBG.updateFonts()
							end
						end,
						validate = function(_, value)
							local num = tonumber(value)
							if not num then
								return "Value must be a number"
							end
							if num < -50 or num > 50 then
								return "Value must be between -50 and 50"
							end
							return true
						end,
					},
				},
			},
		},
	}
	
	return options
end
