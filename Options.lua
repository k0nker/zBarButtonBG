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
	elseif key == "squareButtons" or key == "showBorder" or key == "borderWidth" or 
	       key == "useClassColorBorder" or key == "useClassColorOuter" or key == "useClassColorInner" then
		-- Structural changes need full rebuild
		if zBBG.enabled then
			zBBG.removeActionBarBackgrounds()
			zBBG.createActionBarBackgrounds()
		end
	elseif key == "outerColor" or key == "innerColor" or key == "borderColor" then
		-- Color changes can be applied to existing frames without rebuilding
		if zBBG.enabled and zBBG.updateColors then
			zBBG.updateColors()
		end
	end
end)

-- ############################################################
-- Build the options panel dynamically
-- ############################################################
function zBBG.BuildOptionsPanels()
	if zBBG._optionsBuilt then return end
	zBBG._optionsBuilt = true
	
	-- Store widgets for conditional visibility
	local widgets = {}
	
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
	
	-- Create parent panel
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
		
		-- Enable checkbox
		local enableCb, newY = MakeCheckbox(self, "Enable Action Bar Backgrounds", "Toggle action bar backgrounds on/off. Note: /reload may be required when disabling to restore default borders.", "enabled", y)
		y = newY
		
		-- Square Buttons checkbox
		local squareCb, newY = MakeCheckbox(self, "Square Buttons", "Square off action button icons instead of keeping them round. This makes icons fill the button better when using borders.", "squareButtons", y)
		y = newY
		
		-- Backdrop (outer) settings
		y = y - 10
		local outerClassColorCb, newY = MakeCheckbox(self, "Use Class Color for Backdrop", "Use your class color for the outer backdrop", "useClassColorOuter", y)
		y = newY
		
		local outerLbl, outerBtn, newY = MakeColorPicker(self, "Backdrop Color:", "outerColor", y, "useClassColorOuter")
		y = newY
		
		-- Button background (inner) settings
		y = y - 10
		local innerClassColorCb, newY = MakeCheckbox(self, "Use Class Color for Button Background", "Use your class color for the button background", "useClassColorInner", y)
		y = newY
		
		local innerLbl, innerBtn, newY = MakeColorPicker(self, "Button Background Color:", "innerColor", y, "useClassColorInner")
		y = newY
		
		-- Border section
		y = y - 10
		local borderCb, newY = MakeCheckbox(self, "Enable Button Border", "Add a border around each action button icon", "showBorder", y)
		y = newY
		widgets.borderCb = borderCb
		
		-- Border width slider (only shown if showBorder is enabled)
		local borderWidthFrame, newY = MakeSlider(self, "Border Width (pixels)", "borderWidth", 1, 5, y)
		y = newY
		widgets.borderWidthFrame = borderWidthFrame
		
		-- Border settings
		y = y - 10
		local borderClassColorCb, newY = MakeCheckbox(self, "Use Class Color for Button Border", "Use your class color for the icon border", "useClassColorBorder", y)
		y = newY
		widgets.borderClassColorCb = borderClassColorCb
		
		local borderLbl, borderBtn, newY = MakeColorPicker(self, "Button Border Color:", "borderColor", y, "useClassColorBorder")
		y = newY
		widgets.borderLbl = borderLbl
		widgets.borderBtn = borderBtn
		
		-- Update visibility based on showBorder setting
		local function UpdateBorderWidgets()
			local showBorder = zBBG.charSettings.showBorder
			borderWidthFrame:SetShown(showBorder)
			borderClassColorCb:SetShown(showBorder)
			borderLbl:SetShown(showBorder)
			borderBtn:SetShown(showBorder)
		end
		
		UpdateBorderWidgets()
		
		zBBG.Events:Register("SETTING_CHANGED", function(k, val)
			if k == "showBorder" then
				UpdateBorderWidgets()
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
