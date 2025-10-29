-- Options.lua
local ADDON_NAME = ...
local zBBG = zBarButtonBG -- local alias

-- Centralized setting setter with event trigger
function zBBG.SetSetting(key, value)
	if zBBG.charSettings[key] ~= value then
		zBBG.charSettings[key] = value
		
		if zBBG.Events then
			zBBG.Events:Trigger("SETTING_CHANGED", key, value)
		end
	end
end

-- Simple events system
zBBG.Events = zBBG.Events or {}
function zBBG.Events:Trigger(event, ...)
	if self[event] then
		for _, cb in ipairs(self[event]) do
			cb(...)
		end
	end
end

function zBBG.Events:Register(event, cb)
	self[event] = self[event] or {}
	table.insert(self[event], cb)
end

-- Register event listeners for settings changes
zBBG.Events:Register("SETTING_CHANGED", function(key, value)
	if key == "enabled" then
		if value and not zBBG.enabled then
			zBBG.enabled = true
			zBBG.createActionBarBackgrounds()
			zBBG.print("Action bar backgrounds |cFF00FF00enabled|r")
		elseif not value and zBBG.enabled then
			zBBG.enabled = false
			zBBG.removeActionBarBackgrounds()
			zBBG.print("Action bar backgrounds |cFFFF0000disabled|r")
		end
	elseif key == "squareButtons" or key == "showBorder" or 
	       key == "useClassColorBorder" or key == "useClassColorOuter" or key == "useClassColorInner" or
	       key == "showRangeIndicator" or key == "fadeCooldown" or
	       key == "showBackdrop" or key == "showSlotBackground" then
		-- Structural changes need full rebuild
		if zBBG.enabled then
			zBBG.removeActionBarBackgrounds()
			zBBG.createActionBarBackgrounds()
		end
	elseif key == "outerColor" or key == "innerColor" or key == "borderColor" or key == "rangeIndicatorColor" or key == "cooldownColor" then
		-- Color changes can be applied to existing frames without rebuilding
		if zBBG.enabled and zBBG.updateColors then
			zBBG.updateColors()
		end
	elseif key == "macroNameFont" or key == "macroNameFontSize" or key == "macroNameFontFlags" or
	       key == "macroNameWidth" or key == "macroNameHeight" or key == "macroNameColor" or
	       key == "countFont" or key == "countFontSize" or key == "countFontFlags" or
	       key == "countWidth" or key == "countHeight" or key == "countColor" then
		-- Font changes can be applied to existing frames without rebuilding
		if zBBG.enabled and zBBG.updateFonts then
			zBBG.updateFonts()
		end
	end
end)

-- ############################################################
-- Build the options panels with subcategories
-- ############################################################
function zBBG.BuildOptionsPanels()
	if zBBG._optionsBuilt then return end
	zBBG._optionsBuilt = true
	
	-- Store widgets for conditional visibility
	local widgets = {}
	
	-- Create main category
	local mainPanel = CreateFrame("Frame")
	mainPanel.name = "zBarButtonBG"
	mainPanel:Hide()
	
	-- Create Button Settings subcategory
	local buttonPanel = CreateFrame("Frame")
	buttonPanel.name = "Button Settings"
	buttonPanel.parent = "zBarButtonBG"
	buttonPanel:Hide()
	
	-- Create Indicators subcategory
	local indicatorPanel = CreateFrame("Frame")
	indicatorPanel.name = "Indicators" 
	indicatorPanel.parent = "zBarButtonBG"
	indicatorPanel:Hide()
	
	-- Create Text subcategory
	local textPanel = CreateFrame("Frame")
	textPanel.name = "Text"
	textPanel.parent = "zBarButtonBG"
	textPanel:Hide()
	
	-- Helper: checkbox
	local function MakeCheckbox(parent, label, tooltip, key, y)
		local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
		cb:SetPoint("TOPLEFT", 16, y)
		cb.Text:SetText(label)
		cb:SetChecked(zBBG.charSettings[key] or false)
		cb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		cb:GetCheckedTexture():SetVertexColor(0, 0.6, 1)
		
		if tooltip and tooltip ~= "" then
			cb:SetScript("OnEnter", function(btn)
				GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
				GameTooltip:SetText(label)
				GameTooltip:AddLine(tooltip, 1, 1, 1, true)
				GameTooltip:Show()
			end)
			cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
		end
		
		cb:SetScript("OnClick", function(btn)
			local val = btn:GetChecked() and true or false
			zBBG.SetSetting(key, val)
		end)
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == key then cb:SetChecked(val) end
		end)
		
		return cb, y - 28
	end
	
	-- Helper: number slider
	local function MakeSlider(parent, label, key, min, max, y)
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetSize(300, 32)
		frame:SetPoint("TOPLEFT", 16, y)
		
		local slider = CreateFrame("Slider", nil, frame, "OptionsSliderTemplate")
		slider:SetPoint("LEFT", frame, "LEFT", 0, 0)
		slider:SetWidth(150)
		slider:SetMinMaxValues(min, max)
		slider:SetValueStep(1)
		slider:SetObeyStepOnDrag(true)
		slider:SetValue(zBBG.charSettings[key] or min)
		
		slider.Text = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		slider.Text:SetPoint("TOP", slider, "BOTTOM", 0, -2)
		slider.Text:SetText(tostring(slider:GetValue()))
		
		local eb = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
		eb:SetSize(40, 20)
		eb:SetPoint("LEFT", slider, "RIGHT", 8, 0)
		eb:SetAutoFocus(false)
		eb:SetText(tostring(slider:GetValue()))
		
		local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		lbl:SetPoint("LEFT", eb, "RIGHT", 8, 0)
		lbl:SetText(label)
		
		slider:SetScript("OnValueChanged", function(self, val)
			val = math.floor(val + 0.5)
			slider.Text:SetText(tostring(val))
			eb:SetText(tostring(val))
			zBBG.SetSetting(key, val)
		end)
		
		eb:SetScript("OnEnterPressed", function(self)
			local val = tonumber(self:GetText()) or min
			val = math.floor(math.max(min, math.min(max, val)))
			slider:SetValue(val)
			zBBG.SetSetting(key, val)
			self:ClearFocus()
		end)
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == key then
				slider:SetValue(val)
				eb:SetText(tostring(val))
			end
		end)
		
		return frame, y - 40
	end

	-- Helper: dropdown for font selection
	local function MakeDropdown(parent, label, key, options, y)
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetSize(300, 32)
		frame:SetPoint("TOPLEFT", 16, y)
		
		local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		lbl:SetPoint("LEFT", frame, "LEFT", 0, 0)
		lbl:SetText(label)
		
		local dropdown = CreateFrame("Button", nil, frame, "UIDropDownMenuTemplate")
		dropdown:SetPoint("LEFT", lbl, "RIGHT", 10, 0)
		UIDropDownMenu_SetWidth(dropdown, 200)
		UIDropDownMenu_SetText(dropdown, zBBG.charSettings[key] or options[1].value)
		
		UIDropDownMenu_Initialize(dropdown, function(self, level)
			for _, option in ipairs(options) do
				local info = UIDropDownMenu_CreateInfo()
				info.text = option.text
				info.value = option.value
				info.func = function()
					zBBG.SetSetting(key, option.value)
					UIDropDownMenu_SetText(dropdown, option.value)
				end
				info.checked = (zBBG.charSettings[key] == option.value)
				UIDropDownMenu_AddButton(info, level)
			end
		end)
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == key then
				UIDropDownMenu_SetText(dropdown, val)
			end
		end)
		
		return frame, y - 40
	end

	-- Helper: text input for font paths
	local function MakeTextInput(parent, label, key, width, y)
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetSize(300, 32)
		frame:SetPoint("TOPLEFT", 16, y)
		
		local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		lbl:SetPoint("LEFT", frame, "LEFT", 0, 0)
		lbl:SetText(label)
		
		local eb = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
		eb:SetSize(width or 200, 20)
		eb:SetPoint("LEFT", lbl, "RIGHT", 10, 0)
		eb:SetAutoFocus(false)
		eb:SetText(zBBG.charSettings[key] or "")
		
		eb:SetScript("OnEnterPressed", function(self)
			zBBG.SetSetting(key, self:GetText())
			self:ClearFocus()
		end)
		
		eb:SetScript("OnEditFocusLost", function(self)
			zBBG.SetSetting(key, self:GetText())
		end)
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == key then
				eb:SetText(val or "")
			end
		end)
		
		return frame, y - 40
	end
	
	-- Helper: color picker
	local function MakeColorPicker(parent, label, key, y, disableKey)
		local lbl = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		lbl:SetPoint("TOPLEFT", 16, y)
		lbl:SetText(label)
		
		local btn = CreateFrame("Button", nil, parent)
		btn:SetPoint("LEFT", lbl, "RIGHT", 10, 0)
		btn:SetSize(40, 20)
		
		-- Border frame underneath everything
		local border = btn:CreateTexture(nil, "BACKGROUND")
		border:SetAllPoints()
		border:SetColorTexture(0.5, 0.5, 0.5, 1)
		
		-- Color texture on top with slight inset
		local tex = btn:CreateTexture(nil, "BORDER")
		tex:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
		tex:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
		local c = zBBG.charSettings[key]
		tex:SetColorTexture(c.r, c.g, c.b, c.a)
		
		local function UpdateEnabled()
			local isDisabled = disableKey and zBBG.charSettings[disableKey]
			btn:SetEnabled(not isDisabled)
			if isDisabled then
				tex:SetDesaturated(true)
				lbl:SetTextColor(0.5, 0.5, 0.5)
			else
				tex:SetDesaturated(false)
				lbl:SetTextColor(1, 1, 1)
			end
		end
		
		UpdateEnabled()
		
		btn:SetScript("OnEnter", function(self)
			if self:IsEnabled() then
				border:SetColorTexture(1, 1, 0, 1)
			end
		end)
		btn:SetScript("OnLeave", function(self)
			border:SetColorTexture(0.5, 0.5, 0.5, 1)
		end)
		
		btn:SetScript("OnClick", function()
			if not btn:IsEnabled() then return end
			local currentColor = zBBG.charSettings[key]
			
			-- Store original values for cancel
			local originalColor = {
				r = currentColor.r,
				g = currentColor.g,
				b = currentColor.b,
				a = currentColor.a
			}
			
			ColorPickerFrame:SetupColorPickerAndShow({
				r = currentColor.r,
				g = currentColor.g,
				b = currentColor.b,
				opacity = currentColor.a,
				hasOpacity = true,
				swatchFunc = function()
					local r, g, b = ColorPickerFrame:GetColorRGB()
					local a = ColorPickerFrame:GetColorAlpha()
					if a then
						zBBG.SetSetting(key, {r = r, g = g, b = b, a = a})
						tex:SetColorTexture(r, g, b, a)
					end
				end,
				opacityFunc = function()
					local r, g, b = ColorPickerFrame:GetColorRGB()
					local a = ColorPickerFrame:GetColorAlpha()
					if a then
						zBBG.SetSetting(key, {r = r, g = g, b = b, a = a})
						tex:SetColorTexture(r, g, b, a)
					end
				end,
				cancelFunc = function(restore)
					-- Use original values if restore is invalid
					if restore and restore.r and restore.opacity then
						zBBG.SetSetting(key, {r = restore.r, g = restore.g, b = restore.b, a = restore.opacity})
						tex:SetColorTexture(restore.r, restore.g, restore.b, restore.opacity)
					else
						zBBG.SetSetting(key, originalColor)
						tex:SetColorTexture(originalColor.r, originalColor.g, originalColor.b, originalColor.a)
					end
				end,
			})
		end)
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == key then
				tex:SetColorTexture(val.r, val.g, val.b, val.a)
			elseif disableKey and k == disableKey then
				UpdateEnabled()
			end
		end)
		
		return lbl, btn, y - 28
	end
	
	-- Create main panel
	local mainPanel = CreateFrame("Frame")
	mainPanel.name = "zBarButtonBG"
	mainPanel:Hide()
	
	mainPanel:SetScript("OnShow", function(self)
		if self._built then return end
		self._built = true
		
		local y = -16
		
		-- Title
		local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", 16, y)
		title:SetText("zBarButtonBG Settings")
		y = y - 32
		
		-- Reset Options button (moved to top)
		local resetBtn = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
		resetBtn:SetPoint("TOPLEFT", 16, y)
		resetBtn:SetSize(120, 25)
		resetBtn:SetText("Reset Options")
		resetBtn:SetScript("OnClick", function()
			-- Show confirmation dialog
			StaticPopupDialogs["ZBARBUTTONBG_RESET_CONFIRM"] = {
				text = "Are you sure you want to reset all zBarButtonBG settings to their defaults?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function()
					-- Reset all settings to defaults
					for key, value in pairs(zBBG.defaultSettings) do
						if type(value) == "table" then
							-- Deep copy color tables
							zBBG.charSettings[key] = {}
							for k, v in pairs(value) do
								zBBG.charSettings[key][k] = v
							end
						else
							zBBG.charSettings[key] = value
						end
					end
					
					-- Trigger setting changes to update UI and rebuild
					zBBG.Events:Trigger("SETTING_CHANGED", "enabled", zBBG.charSettings.enabled)
					zBBG.Events:Trigger("SETTING_CHANGED", "squareButtons", zBBG.charSettings.squareButtons)
					zBBG.Events:Trigger("SETTING_CHANGED", "showBorder", zBBG.charSettings.showBorder)
					zBBG.Events:Trigger("SETTING_CHANGED", "showBackdrop", zBBG.charSettings.showBackdrop)
					zBBG.Events:Trigger("SETTING_CHANGED", "showSlotBackground", zBBG.charSettings.showSlotBackground)
					zBBG.Events:Trigger("SETTING_CHANGED", "outerColor", zBBG.charSettings.outerColor)
					zBBG.Events:Trigger("SETTING_CHANGED", "innerColor", zBBG.charSettings.innerColor)
					zBBG.Events:Trigger("SETTING_CHANGED", "borderColor", zBBG.charSettings.borderColor)
					zBBG.Events:Trigger("SETTING_CHANGED", "useClassColorBorder", zBBG.charSettings.useClassColorBorder)
					zBBG.Events:Trigger("SETTING_CHANGED", "useClassColorOuter", zBBG.charSettings.useClassColorOuter)
					zBBG.Events:Trigger("SETTING_CHANGED", "useClassColorInner", zBBG.charSettings.useClassColorInner)
					zBBG.Events:Trigger("SETTING_CHANGED", "showRangeIndicator", zBBG.charSettings.showRangeIndicator)
					zBBG.Events:Trigger("SETTING_CHANGED", "rangeIndicatorColor", zBBG.charSettings.rangeIndicatorColor)
					zBBG.Events:Trigger("SETTING_CHANGED", "fadeCooldown", zBBG.charSettings.fadeCooldown)
					zBBG.Events:Trigger("SETTING_CHANGED", "cooldownColor", zBBG.charSettings.cooldownColor)
					zBBG.Events:Trigger("SETTING_CHANGED", "macroNameFont", zBBG.charSettings.macroNameFont)
					zBBG.Events:Trigger("SETTING_CHANGED", "macroNameFontSize", zBBG.charSettings.macroNameFontSize)
					zBBG.Events:Trigger("SETTING_CHANGED", "macroNameFontFlags", zBBG.charSettings.macroNameFontFlags)
					zBBG.Events:Trigger("SETTING_CHANGED", "macroNameWidth", zBBG.charSettings.macroNameWidth)
					zBBG.Events:Trigger("SETTING_CHANGED", "macroNameHeight", zBBG.charSettings.macroNameHeight)
					zBBG.Events:Trigger("SETTING_CHANGED", "macroNameColor", zBBG.charSettings.macroNameColor)
					zBBG.Events:Trigger("SETTING_CHANGED", "countFont", zBBG.charSettings.countFont)
					zBBG.Events:Trigger("SETTING_CHANGED", "countFontSize", zBBG.charSettings.countFontSize)
					zBBG.Events:Trigger("SETTING_CHANGED", "countFontFlags", zBBG.charSettings.countFontFlags)
					zBBG.Events:Trigger("SETTING_CHANGED", "countWidth", zBBG.charSettings.countWidth)
					zBBG.Events:Trigger("SETTING_CHANGED", "countHeight", zBBG.charSettings.countHeight)
					zBBG.Events:Trigger("SETTING_CHANGED", "macroNameColor", zBBG.charSettings.macroNameColor)
					zBBG.Events:Trigger("SETTING_CHANGED", "countColor", zBBG.charSettings.countColor)
					
					zBBG.print("Settings reset to defaults!")
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("ZBARBUTTONBG_RESET_CONFIRM")
		end)
		resetBtn:SetScript("OnEnter", function(btn)
			GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
			GameTooltip:SetText("Reset Options")
			GameTooltip:AddLine("Reset all settings to their default values", 1, 1, 1, true)
			GameTooltip:Show()
		end)
		resetBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
		y = y - 40
		
		-- Enable checkbox
		local enableCb, newY = MakeCheckbox(self, "Enable Action Bar Backgrounds", "Toggle action bar backgrounds on/off. Note: /reload may be required when disabling to restore default borders.", "enabled", y)
		y = newY
		
		-- Backdrop (outer) settings
		y = y - 10
		local backdropCb, newY = MakeCheckbox(contentFrame, "Show Backdrop", "Show the outer backdrop frame behind each button", "showBackdrop", y)
		y = newY
		widgets.backdropCb = backdropCb
		
		local outerClassColorCb, newY = MakeCheckbox(contentFrame, "Use Class Color for Backdrop", "Use your class color for the outer backdrop", "useClassColorOuter", y)
		y = newY
		widgets.outerClassColorCb = outerClassColorCb
		
		local outerLbl, outerBtn, newY = MakeColorPicker(contentFrame, "Backdrop Color:", "outerColor", y, "useClassColorOuter")
		y = newY
		widgets.outerLbl = outerLbl
		widgets.outerBtn = outerBtn
		
		-- Button background (inner) settings
		y = y - 10
		local slotBgCb, newY = MakeCheckbox(contentFrame, "Show Slot Background", "Show the slot background fill behind each button icon", "showSlotBackground", y)
		y = newY
		widgets.slotBgCb = slotBgCb
		
		local innerClassColorCb, newY = MakeCheckbox(contentFrame, "Use Class Color for Button Background", "Use your class color for the button background", "useClassColorInner", y)
		y = newY
		widgets.innerClassColorCb = innerClassColorCb
		
		local innerLbl, innerBtn, newY = MakeColorPicker(contentFrame, "Button Background Color:", "innerColor", y, "useClassColorInner")
		y = newY
		widgets.innerLbl = innerLbl
		widgets.innerBtn = innerBtn
		
		-- Border section
		y = y - 10
		local borderCb, newY = MakeCheckbox(contentFrame, "Enable Button Border", "Add a border around each action button icon", "showBorder", y)
		y = newY
		widgets.borderCb = borderCb
		
		-- Border settings
		y = y - 10
		local borderClassColorCb, newY = MakeCheckbox(contentFrame, "Use Class Color for Button Border", "Use your class color for the icon border", "useClassColorBorder", y)
		y = newY
		widgets.borderClassColorCb = borderClassColorCb
		
		local borderLbl, borderBtn, newY = MakeColorPicker(contentFrame, "Button Border Color:", "borderColor", y, "useClassColorBorder")
		y = newY
		widgets.borderLbl = borderLbl
		widgets.borderBtn = borderBtn
		
		-- Update visibility based on showBorder setting
		local function UpdateBorderWidgets()
			local showBorder = zBBG.charSettings.showBorder
			borderClassColorCb:SetShown(showBorder)
			borderLbl:SetShown(showBorder)
			borderBtn:SetShown(showBorder)
		end
		
		UpdateBorderWidgets()
		
		-- Update visibility based on showBackdrop setting
		local function UpdateBackdropWidgets()
			local showBackdrop = zBBG.charSettings.showBackdrop
			outerClassColorCb:SetShown(showBackdrop)
			outerLbl:SetShown(showBackdrop)
			outerBtn:SetShown(showBackdrop)
		end
		
		UpdateBackdropWidgets()
		
		-- Update visibility based on showSlotBackground setting
		local function UpdateSlotBackgroundWidgets()
			local showSlotBg = zBBG.charSettings.showSlotBackground
			innerClassColorCb:SetShown(showSlotBg)
			innerLbl:SetShown(showSlotBg)
			innerBtn:SetShown(showSlotBg)
		end
		
		UpdateSlotBackgroundWidgets()
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == "showBorder" or k == "squareButtons" then
				UpdateBorderWidgets()
			elseif k == "showBackdrop" then
				UpdateBackdropWidgets()
			elseif k == "showSlotBackground" then
				UpdateSlotBackgroundWidgets()
			end
		end)
		
		-- Range Indicator section
		y = y - 10
		local rangeCb, newY = MakeCheckbox(contentFrame, "Show Out-of-Range Highlight", "Show a colored overlay on buttons when the ability is out of range", "showRangeIndicator", y)
		y = newY
		widgets.rangeCb = rangeCb
		
		local rangeLbl, rangeBtn, newY = MakeColorPicker(contentFrame, "Range Indicator Color:", "rangeIndicatorColor", y)
		y = newY
		widgets.rangeLbl = rangeLbl
		widgets.rangeBtn = rangeBtn
		
		-- Cooldown Fade section
		y = y - 10
		local cooldownCb, newY = MakeCheckbox(contentFrame, "Fade On Cooldown", "Add a dark overlay to buttons while on cooldown", "fadeCooldown", y)
		y = newY
		widgets.cooldownCb = cooldownCb
		
		local cooldownLbl, cooldownBtn, newY = MakeColorPicker(contentFrame, "Cooldown Overlay Color:", "cooldownColor", y)
		y = newY
		widgets.cooldownLbl = cooldownLbl
		widgets.cooldownBtn = cooldownBtn
		
		-- Update visibility based on showRangeIndicator setting
		local function UpdateRangeWidgets()
			local showRange = zBBG.charSettings.showRangeIndicator
			rangeLbl:SetShown(showRange)
			rangeBtn:SetShown(showRange)
		end
		
		UpdateRangeWidgets()
		
		-- Update visibility based on fadeCooldown setting
		local function UpdateCooldownWidgets()
			local fadeCooldown = zBBG.charSettings.fadeCooldown
			cooldownLbl:SetShown(fadeCooldown)
			cooldownBtn:SetShown(fadeCooldown)
		end
		
		UpdateCooldownWidgets()
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == "showRangeIndicator" then
				UpdateRangeWidgets()
			elseif k == "fadeCooldown" then
				UpdateCooldownWidgets()
			end
		end)
		
		-- Font Settings section
		y = y - 10
		local fontHeader = contentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		fontHeader:SetPoint("TOPLEFT", 16, y)
		fontHeader:SetText("Font Settings")
		y = y - 30

		-- Font options
		local fontOptions = {
			{text = "Default UI Font", value = "Fonts\\FRIZQT__.TTF"},
			{text = "Arial Bold", value = "Fonts\\ARIALN.TTF"},
			{text = "Morpheus", value = "Fonts\\MORPHEUS.TTF"},
			{text = "Skurri", value = "Fonts\\skurri.TTF"},
			{text = "Custom Path", value = "CUSTOM"}
		}

		-- Font flag options  
		local fontFlagOptions = {
			{text = "None", value = ""},
			{text = "Outline", value = "OUTLINE"},
			{text = "Thick Outline", value = "THICKOUTLINE"},
			{text = "Monochrome", value = "MONOCHROME"}
		}
		
		-- Macro Name Font settings
		local macroFontDropdown, newY = MakeDropdown(contentFrame, "Macro Name Font:", "macroNameFont", fontOptions, y)
		y = newY
		
		local macroFontSizeSlider, newY = MakeSlider(contentFrame, "Macro Name Font Size", "macroNameFontSize", 6, 24, y)
		y = newY
		
		local macroFontFlagsDropdown, newY = MakeDropdown(contentFrame, "Macro Name Font Style:", "macroNameFontFlags", fontFlagOptions, y)
		y = newY
		
		local macroWidthSlider, newY = MakeSlider(contentFrame, "Macro Name Width", "macroNameWidth", 20, 200, y)
		y = newY
		
		local macroHeightSlider, newY = MakeSlider(contentFrame, "Macro Name Height", "macroNameHeight", 8, 50, y)
		y = newY
		
		local macroColorLbl, macroColorBtn, newY = MakeColorPicker(contentFrame, "Macro Name Color:", "macroNameColor", y)
		y = newY
		
		-- Add custom font path input (initially hidden)
		local macroCustomFontInput, newY = MakeTextInput(contentFrame, "Custom Font Path:", "macroNameFont", 250, y)
		y = newY
		macroCustomFontInput:Hide() -- Hidden by default
		
		-- Show/hide custom input based on dropdown selection
		local function UpdateMacroFontVisibility()
			if zBBG.charSettings.macroNameFont == "CUSTOM" then
				macroCustomFontInput:Show()
			else
				macroCustomFontInput:Hide()
			end
		end
		UpdateMacroFontVisibility()
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == "macroNameFont" then
				UpdateMacroFontVisibility()
			end
		end)
		
		y = y - 10 -- Add some space
		
		-- Count Font settings
		local countFontDropdown, newY = MakeDropdown(contentFrame, "Count/Charge Font:", "countFont", fontOptions, y)
		y = newY
		
		local countFontSizeSlider, newY = MakeSlider(contentFrame, "Count Font Size", "countFontSize", 6, 24, y)
		y = newY
		
		local countFontFlagsDropdown, newY = MakeDropdown(contentFrame, "Count Font Style:", "countFontFlags", fontFlagOptions, y)
		y = newY
		
		local countWidthSlider, newY = MakeSlider(contentFrame, "Count Width", "countWidth", 10, 100, y)
		y = newY
		
		local countHeightSlider, newY = MakeSlider(contentFrame, "Count Height", "countHeight", 8, 50, y)
		y = newY
		
		local countColorLbl, countColorBtn, newY = MakeColorPicker(contentFrame, "Count Color:", "countColor", y)
		y = newY
		
		-- Add custom font path input for count font (initially hidden)
		local countCustomFontInput, newY = MakeTextInput(contentFrame, "Custom Font Path:", "countFont", 250, y)
		y = newY
		countCustomFontInput:Hide() -- Hidden by default
		
		-- Show/hide custom input based on dropdown selection
		local function UpdateCountFontVisibility()
			if zBBG.charSettings.countFont == "CUSTOM" then
				countCustomFontInput:Show()
			else
				countCustomFontInput:Hide()
			end
		end
		UpdateCountFontVisibility()
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == "countFont" then
				UpdateCountFontVisibility()
			end
		end)


	end)
	
	-- Register parent
	local mainCategory = Settings.RegisterCanvasLayoutCategory(mainPanel, mainPanel.name)
	Settings.RegisterAddOnCategory(mainCategory)
	zBBG.settingsCategory = mainCategory
end

-- Wait until SavedVariables are ready
local optEvt = CreateFrame("Frame")
optEvt:RegisterEvent("ADDON_LOADED")
optEvt:SetScript("OnEvent", function(_, evt, name)
	if name ~= "zBarButtonBG" then return end
	
	-- Ensure charSettings exists
	if not zBBG.charSettings then
		zBBG.charSettings = {}
	end
	
	zBBG.BuildOptionsPanels()
end)
