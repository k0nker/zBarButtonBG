-- UI/Options.lua
-- zSettingsFrame-1.0 options panel for zBarButtonBG.

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

local L          = LibStub("AceLocale-3.0"):GetLocale("zBarButtonBG")
local LSM        = LibStub("LibSharedMedia-3.0")

-- ── Font registrations ─────────────────────────────────────────────────────────
LSM:Register("font", "Homespun", "Interface\\AddOns\\zBarButtonBG\\Assets\\Fonts\\Homespun.ttf")
LSM:Register("font", "Celestia", "Interface\\AddOns\\zBarButtonBG\\Assets\\Fonts\\Celestia.ttf")
LSM:Register("font", "Morpheus", "Fonts\\MORPHEUS.TTF")
LSM:Register("font", "Arial", "Fonts\\ARIALN.TTF")
LSM:Register("font", "Friz Quadrata", "Fonts\\FRIZQT__.TTF")
LSM:Register("font", "Skelefont", "Interface\\AddOns\\zBarButtonBG\\Assets\\Fonts\\Skelefont.ttf")

-- ── Serialize helpers ──────────────────────────────────────────────────────────
local function exportProfile(profile)
    local serialized = LibStub("AceSerializer-3.0"):Serialize(profile)
    local compressed = LibDeflate:CompressDeflate(serialized)
    return LibDeflate:EncodeForPrint(compressed)
end

local function importProfile(exportString)
    local decoded = LibDeflate:DecodeForPrint(exportString)
    if not decoded then return nil, L["Failed to decode export string"] end
    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return nil, L["Invalid export string format"] end
    local success, profile = LibStub("AceSerializer-3.0"):Deserialize(decompressed)
    if not success or type(profile) ~= "table" then
        return nil, L["Invalid export string - not a valid profile"]
    end
    return profile
end

-- ── Color helpers ──────────────────────────────────────────────────────────────
-- zSF color widgets use indexed {r,g,b,a}; zBarButtonBG stores named {r=,g=,b=,a=}.
local function getColor(key)
    local c = zBarButtonBG.settingsStore:Get(key)
    if not c then
        local d = addonTable.Core.Defaults.profile[key]
        return { d.r or 1, d.g or 1, d.b or 1, d.a or 1 }
    end
    return { c.r or 1, c.g or 1, c.b or 1, c.a or 1 }
end

local function setColor(key, value)
    zBarButtonBG.SetSetting(key, {
        r = value[1] or 1,
        g = value[2] or 1,
        b = value[3] or 1,
        a = value[4] or 1,
    })
end

-- ── Profile action state ───────────────────────────────────────────────────────
local selectedProfileForActions = nil

-- ── Schema helpers ─────────────────────────────────────────────────────────────
local function extend(t, entries)
    for _, v in ipairs(entries) do
        t[#t + 1] = v
    end
end

local function BarEntries(displayName, barKey)
    return {
        {
            widgetType = "header",
            name       = displayName,
        },
        {
            widgetType = "toggle",
            width      = "half",
            name       = L["Use Different Profile"],
            desc       = L["Use a different profile for this action bar"],
            get        = function()
                local bs = zBarButtonBGAce.db.char.barSettings[barKey]
                return bs and bs.differentProfile or false
            end,
            set        = function(value)
                zBarButtonBGAce.db.char.barSettings[barKey].differentProfile = value
                if zBarButtonBG.enabled then
                    zBarButtonBG.removeActionBarBackgrounds()
                    zBarButtonBG.createActionBarBackgrounds()
                end
            end,
        },
        {
            widgetType  = "select",
            width       = "half",
            name        = L["Profile"],
            desc        = L["Profile to use for this action bar"],
            get         = function()
                local bs = zBarButtonBGAce.db.char.barSettings[barKey]
                return bs and bs.profileName or "Default"
            end,
            set         = function(value)
                zBarButtonBGAce.db.char.barSettings[barKey].profileName = value
                if zBarButtonBG.enabled then
                    zBarButtonBG.removeActionBarBackgrounds()
                    zBarButtonBG.createActionBarBackgrounds()
                end
            end,
            values      = function()
                local p = {}
                for n, _ in pairs(zBarButtonBGAce.db.profiles) do p[n] = n end
                return p
            end,
            disableWhen = function()
                local bs = zBarButtonBGAce.db.char.barSettings[barKey]
                return not (bs and bs.differentProfile)
            end,
        },
    }
end

-- ── Action Bars content ────────────────────────────────────────────────────────
local actionBarsContent = {
    {
        widgetType = "text",
        name       = L["Here you can select action bars to have their own profiles applied independent of the currently selected profile."],
    },
}
extend(actionBarsContent, BarEntries(L["Main Action Bar"], "ActionButton"))
extend(actionBarsContent, BarEntries(L["Bottom Left Bar"], "MultiBarBottomLeftButton"))
extend(actionBarsContent, BarEntries(L["Bottom Right Bar"], "MultiBarBottomRightButton"))
extend(actionBarsContent, BarEntries(L["Right Bar 1"], "MultiBarRightButton"))
extend(actionBarsContent, BarEntries(L["Right Bar 2"], "MultiBarLeftButton"))
extend(actionBarsContent, BarEntries(L["Bar 5"], "MultiBar5Button"))
extend(actionBarsContent, BarEntries(L["Bar 6"], "MultiBar6Button"))
extend(actionBarsContent, BarEntries(L["Bar 7"], "MultiBar7Button"))
extend(actionBarsContent, BarEntries(L["Pet Action Bar"], "PetActionButton"))
extend(actionBarsContent, BarEntries(L["Stance Bar"], "StanceButton"))

-- ── Schema ─────────────────────────────────────────────────────────────────────
local ZBBG_SCHEMA = {

    -- ── General ──────────────────────────────────────────────────────────────
    {
        widgetType = "nav",
        name       = L["General"],
        children   = {
            { widgetType = "header", name = L["Profiles"] },
            {
                widgetType = "select",
                name       = L["Current Profile"],
                desc       = L["The currently active profile"],
                get        = function()
                    return zBarButtonBGAce.db:GetCurrentProfile()
                end,
                set        = function(value)
                    zBarButtonBGAce.db:SetProfile(value)
                    zBarButtonBG.SyncAllSignals()
                    zBarButtonBG.print(L["Switched to profile"] .. ": " .. value)
                end,
                values     = function()
                    local p = {}
                    for n, _ in pairs(zBarButtonBGAce.db.profiles) do p[n] = n end
                    return p
                end,
            },
            {
                widgetType = "button",
                name       = L["New Profile"],
                desc       = L["Create a new profile"],
                func       = function()
                    zBarButtonBG.zSFCtx:ShowInput({
                        title    = L["Create New Profile"],
                        body     = L["Enter a name for the new profile"],
                        mode     = "single",
                        onAccept = function(name)
                            if not name or name == "" then
                                zBarButtonBG.print("|cFFFF0000" .. L["Error"] .. ":|r " .. L["Profile name cannot be empty"])
                                return
                            end
                            local success, message = zBarButtonBGAce:CreateNewProfile(name)
                            if success then
                                zBarButtonBG.print(L["Profile created"] .. ": " .. name)
                                zSettingsFrame.RefreshAll(true, "zBarButtonBG")
                            else
                                zBarButtonBG.print("|cFFFF0000" .. L["Error"] .. ":|r " .. message)
                            end
                        end,
                    })
                end,
            },
            {
                widgetType = "button",
                name       = L["Reset Profile"],
                desc       = L["Reset current profile to defaults"],
                confirm    = L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"],
                func       = function()
                    zBarButtonBGAce.db:ResetProfile()
                    zBarButtonBG.SyncAllSignals()
                    zBarButtonBG.print(L["Current profile reset to defaults!"])
                end,
            },
            { widgetType = "spacer" },
            { widgetType = "header", name = L["Use Combat Profile"] },
            {
                widgetType = "toggle",
                name       = L["Use Combat Profile"],
                get        = function()
                    return zBarButtonBGAce.db.char.useCombatProfile or false
                end,
                set        = function(value)
                    zBarButtonBGAce.db.char.useCombatProfile = value
                    if zBarButtonBG.enabled then
                        zBarButtonBG.removeActionBarBackgrounds()
                        zBarButtonBG.createActionBarBackgrounds()
                    end
                end,
            },
            {
                widgetType  = "select",
                name        = L["Combat Profile"],
                desc        = L["Profile to replace all bars when in combat"],
                get         = function()
                    return zBarButtonBGAce.db.char.combatProfileName or "Default"
                end,
                set         = function(value)
                    zBarButtonBGAce.db.char.combatProfileName = value
                end,
                values      = function()
                    local p = {}
                    for n, _ in pairs(zBarButtonBGAce.db.profiles) do p[n] = n end
                    return p
                end,
                disableWhen = function()
                    return not zBarButtonBGAce.db.char.useCombatProfile
                end,
            },
            { widgetType = "spacer" },
            { widgetType = "header", name = L["Modify Profiles"] },
            {
                widgetType = "select",
                name       = L["Choose Profile"],
                desc       = L["Select a profile for copy/delete operations"],
                get        = function() return selectedProfileForActions end,
                set        = function(value)
                    selectedProfileForActions = value
                    zSettingsFrame.RefreshAll(true, "zBarButtonBG")
                end,
                values     = function()
                    local p = {}
                    for n, _ in pairs(zBarButtonBGAce.db.profiles) do
                        if n ~= zBarButtonBGAce.db:GetCurrentProfile() then
                            p[n] = n
                        end
                    end
                    return p
                end,
            },
            {
                widgetType = "button",
                name       = L["Copy Profile"],
                desc       = L["Copy settings from the chosen profile to the current profile"],
                func       = function()
                    if not selectedProfileForActions then return end
                    local confirmText = L["Copy settings from"] .. ": '" ..
                        selectedProfileForActions .. "' -> '" ..
                        zBarButtonBGAce.db:GetCurrentProfile() .. "'?\n\n" ..
                        L["This will overwrite all current settings!"]
                    zBarButtonBG.zSFCtx:ShowConfirm(confirmText, function()
                        local success, message = zBarButtonBGAce:CopyProfile(
                            selectedProfileForActions,
                            zBarButtonBGAce.db:GetCurrentProfile()
                        )
                        if success then
                            zBarButtonBG.print(L["Settings copied from"] .. ": '" ..
                                selectedProfileForActions .. "' -> '" ..
                                zBarButtonBGAce.db:GetCurrentProfile() .. "'")
                        else
                            zBarButtonBG.print("|cFFFF0000" .. L["Error"] .. ":|r " .. message)
                        end
                    end)
                end,
            },
            {
                widgetType = "button",
                name       = L["Delete Profile"],
                desc       = L["Delete the chosen profile"],
                func       = function()
                    if not selectedProfileForActions or selectedProfileForActions == "Default" then return end
                    local profileToDelete = selectedProfileForActions
                    local confirmText = L["Are you sure you want to delete the profile"] ..
                        ": '" .. profileToDelete .. "'?\n\n" ..
                        L["This action cannot be undone!"]
                    zBarButtonBG.zSFCtx:ShowConfirm(confirmText, function()
                        local success, message = zBarButtonBGAce:DeleteProfile(profileToDelete)
                        if success then
                            zBarButtonBG.print(L["Profile deleted"] .. ": " .. profileToDelete)
                            selectedProfileForActions = nil
                            zSettingsFrame.RefreshAll(true, "zBarButtonBG")
                        else
                            zBarButtonBG.print("|cFFFF0000" .. L["Error"] .. ":|r " .. message)
                        end
                    end)
                end,
            },
            { widgetType = "spacer" },
            { widgetType = "header", name = L["Import / Export"] },
            {
                widgetType = "button",
                name       = L["Export Profile"],
                desc       = L["Export current profile settings as a string"],
                func       = function()
                    local str = exportProfile(zBarButtonBGAce.db.profile)
                    zBarButtonBG.zSFCtx:ShowOutput({
                        title = L["Export Profile"],
                        body  = L["Export current profile settings as a string"],
                        text  = str,
                    })
                end,
            },
            {
                widgetType = "button",
                name       = L["Import Profile"],
                desc       = L["Import profile settings from an export string"],
                func       = function()
                    zBarButtonBG.zSFCtx:ShowInput({
                        title      = L["Import Profile"],
                        body       = L["Import profile settings from an export string"],
                        acceptText = L["Import"],
                        mode       = "multi",
                        onAccept   = function(text)
                            if not text or text == "" then
                                zBarButtonBG.print("|cFFFF0000" .. L["Error"] .. ":|r " ..
                                    L["Please paste an export string first"])
                                return
                            end
                            local profile, errorMsg = importProfile(text)
                            if not profile then
                                zBarButtonBG.print("|cFFFF0000" .. L["Error"] .. ":|r " ..
                                    (errorMsg or L["Invalid export string"]))
                                return
                            end
                            zBarButtonBG.zSFCtx:ShowInput({
                                title    = L["Create Profile from Import"],
                                body     = L["Enter a name for the new imported profile"],
                                mode     = "single",
                                onAccept = function(profileName)
                                    if not profileName or profileName == "" then
                                        zBarButtonBG.print("|cFFFF0000" .. L["Error"] .. ":|r " ..
                                            L["Profile name cannot be empty"])
                                        return
                                    end
                                    if zBarButtonBGAce.db.profiles[profileName] then
                                        zBarButtonBG.print("|cFFFF0000" .. L["Error"] .. ":|r " ..
                                            L["Profile already exists"])
                                        return
                                    end
                                    zBarButtonBGAce.db:SetProfile(profileName)
                                    for key, value in pairs(profile) do
                                        zBarButtonBGAce.db.profile[key] = value
                                    end
                                    zBarButtonBG.SyncAllSignals()
                                    if zBarButtonBG.enabled then
                                        zBarButtonBG.removeActionBarBackgrounds()
                                        zBarButtonBG.createActionBarBackgrounds()
                                    end
                                    zBarButtonBG.print(L["Profile imported"] .. ": " .. profileName)
                                    zSettingsFrame.RefreshAll(true, "zBarButtonBG")
                                end,
                            })
                        end,
                    })
                end,
            },
        },
    },

    -- ── Buttons ───────────────────────────────────────────────────────────────
    {
        widgetType = "nav",
        name       = L["Buttons"],
        children   = {
            { widgetType = "header", name = L["Appearance"] },
            {
                widgetType = "select",
                key        = "buttonStyle",
                name       = L["Button Style"],
                desc       = L["Choose button style"],
                values     = function()
                    return zBarButtonBG.ButtonStyles.GetStylesForDropdown()
                end,
            },
            { widgetType = "header", name = L["Backdrop"] },
            {
                widgetType = "toggle",
                key        = "showBackdrop",
                width      = "half",
                name       = L["Show Backdrop"],
                desc       = L["Show outer background frame"],
            },
            {
                widgetType  = "toggle",
                key         = "backdropMaskedToButton",
                width       = "half",
                name        = L["Mask Backdrop"],
                desc        = L["Mask outer background frame to button shape"],
                showWhen    = function() return zBarButtonBG.charSettings.showBackdrop end,
                disableWhen = function() return not zBarButtonBG.charSettings.showBackdrop end,
            },
            {
                widgetType  = "toggle",
                key         = "useClassColorOuter",
                width       = "half",
                name        = L["Use Class Color"],
                desc        = L["Tint the backdrop with your class color"],
                showWhen    = function() return zBarButtonBG.charSettings.showBackdrop end,
                disableWhen = function() return not zBarButtonBG.charSettings.showBackdrop end,
            },
            {
                widgetType  = "colorAlpha",
                width       = "half",
                name        = L["Backdrop Color"],
                desc        = L["Color of the outer backdrop frame"],
                get         = function() return getColor("outerColor") end,
                set         = function(value) setColor("outerColor", value) end,
                showWhen    = function() return zBarButtonBG.charSettings.showBackdrop end,
                disableWhen = function()
                    return not zBarButtonBG.charSettings.showBackdrop
                        or zBarButtonBG.charSettings.useClassColorOuter
                end,
            },
            {
                widgetType  = "range",
                key         = "backdropTopAdjustment",
                width       = "half",
                name        = L["Top Size"],
                desc        = L["How far the backdrop extends above the button (in pixels)"],
                min         = 0,
                max         = 20,
                step        = 1,
                showWhen    = function() return zBarButtonBG.charSettings.showBackdrop end,
                disableWhen = function() return not zBarButtonBG.charSettings.showBackdrop end,
            },
            {
                widgetType  = "range",
                key         = "backdropBottomAdjustment",
                width       = "half",
                name        = L["Bottom Size"],
                desc        = L["How far the backdrop extends below the button (in pixels)"],
                min         = 0,
                max         = 20,
                step        = 1,
                showWhen    = function() return zBarButtonBG.charSettings.showBackdrop end,
                disableWhen = function() return not zBarButtonBG.charSettings.showBackdrop end,
            },
            {
                widgetType  = "range",
                key         = "backdropLeftAdjustment",
                width       = "half",
                name        = L["Left Size"],
                desc        = L["How far the backdrop extends to the left of the button (in pixels)"],
                min         = 0,
                max         = 20,
                step        = 1,
                showWhen    = function() return zBarButtonBG.charSettings.showBackdrop end,
                disableWhen = function() return not zBarButtonBG.charSettings.showBackdrop end,
            },
            {
                widgetType  = "range",
                key         = "backdropRightAdjustment",
                width       = "half",
                name        = L["Right Size"],
                desc        = L["How far the backdrop extends to the right of the button (in pixels)"],
                min         = 0,
                max         = 20,
                step        = 1,
                showWhen    = function() return zBarButtonBG.charSettings.showBackdrop end,
                disableWhen = function() return not zBarButtonBG.charSettings.showBackdrop end,
            },
            { widgetType = "header", name = L["Button Background"] },
            {
                widgetType = "toggle",
                key        = "showSlotBackground",
                width      = "full",
                name       = L["Show Button Background"],
                desc       = L["Show the slot background fill behind each button icon"],
            },
            {
                widgetType  = "toggle",
                key         = "useClassColorInner",
                width       = "half",
                name        = L["Use Class Color"],
                desc        = L["Tint the slot background with your class color"],
                disableWhen = function()
                    return not zBarButtonBG.charSettings.showSlotBackground
                end,
            },
            {
                widgetType  = "colorAlpha",
                width       = "half",
                name        = L["Button Background Color"],
                desc        = L["Color of the button slot background"],
                get         = function() return getColor("innerColor") end,
                set         = function(value) setColor("innerColor", value) end,
                disableWhen = function()
                    return not zBarButtonBG.charSettings.showSlotBackground
                        or zBarButtonBG.charSettings.useClassColorInner
                end,
            },
            { widgetType = "header", name = L["Border"] },
            {
                widgetType = "toggle",
                key        = "showBorder",
                width      = "full",
                name       = L["Show Border"],
                desc       = L["Show border around buttons"],
            },
            {
                widgetType  = "toggle",
                key         = "useClassColorBorder",
                width       = "half",
                name        = L["Use Class Color"],
                desc        = L["Tint the border with your class color"],
                disableWhen = function() return not zBarButtonBG.charSettings.showBorder end,
            },
            {
                widgetType  = "colorAlpha",
                width       = "half",
                name        = L["Border Color"],
                desc        = L["Color of the button border"],
                get         = function() return getColor("borderColor") end,
                set         = function(value) setColor("borderColor", value) end,
                disableWhen = function()
                    return not zBarButtonBG.charSettings.showBorder
                        or zBarButtonBG.charSettings.useClassColorBorder
                end,
            },
            { widgetType = "header" },
            { widgetType = "filler", width = "third", divider = false },
            { widgetType = "filler", width = "third", divider = false },
            {
                widgetType = "button",
                width      = "third",
                name       = L["Reset Button Settings"],
                desc       = L["Reset all button-related settings to default values"],
                confirm    = L["Are you sure you want to reset all button settings to default values?\n\nThis will reset button shape, backdrop, slot background, and border settings.\n\nThis action cannot be undone!"],
                resetKeys  = {
                    "buttonStyle",
                    "showBorder", "borderColor", "useClassColorBorder",
                    "showBackdrop", "outerColor", "useClassColorOuter",
                    "backdropMaskedToButton",
                    "backdropTopAdjustment", "backdropBottomAdjustment",
                    "backdropLeftAdjustment", "backdropRightAdjustment",
                    "showSlotBackground", "innerColor", "useClassColorInner",
                },
            },
        },
    },

    -- ── Indicators ────────────────────────────────────────────────────────────
    {
        widgetType = "nav",
        name       = L["Indicators"],
        children   = {
            { widgetType = "header", name = L["Overlays"] },
            {
                widgetType = "toggle",
                key        = "showHighlightHover",
                width      = "half",
                name       = L["Hover Overlay"],
                desc       = L["Show color overlay when hovering over buttons"],
            },
            {
                widgetType  = "colorAlpha",
                width      = "half",
                name        = L["Hover Overlay Color"],
                desc        = L["Color of the hover overlay"],
                get         = function() return getColor("hoverOverlayColor") end,
                set         = function(value) setColor("hoverOverlayColor", value) end,
                disableWhen = function() return not zBarButtonBG.charSettings.showHighlightHover end,
            },
            {
                widgetType = "toggle",
                key        = "showRangeIndicator",
                width      = "half",
                name       = L["Out of Range Overlay"],
                desc       = L["Show red overlay when abilities are out of range"],
            },
            {
                widgetType  = "colorAlpha",
                width      = "half",
                name        = L["Out of Range Color"],
                desc        = L["Color of the out of range indicator"],
                get         = function() return getColor("rangeIndicatorColor") end,
                set         = function(value) setColor("rangeIndicatorColor", value) end,
                disableWhen = function() return not zBarButtonBG.charSettings.showRangeIndicator end,
            },
            {
                widgetType  = "toggle",
                key         = "fadeCooldown",
                width      = "half",
                name        = L["Cooldown Overlay"],
                desc        = L["Show dark overlay during ability cooldowns"],
                showWhen    = function() return zBarButtonBG.midnightCooldown end,
                disableWhen = function() return not zBarButtonBG.midnightCooldown end,
            },
            {
                widgetType  = "colorAlpha",
                width      = "half",
                name        = L["Cooldown Color"],
                desc        = L["Color of the cooldown overlay"],
                get         = function() return getColor("cooldownColor") end,
                set         = function(value) setColor("cooldownColor", value) end,
                showWhen    = function() return zBarButtonBG.midnightCooldown end,
                disableWhen = function()
                    return not zBarButtonBG.midnightCooldown
                        or not zBarButtonBG.charSettings.fadeCooldown
                end,
            },
            { widgetType = "header" },
            {
                widgetType = "colorAlpha",
                width      = "half",
                name       = L["Proc Alt Glow Color"],
                desc       = L["Color of spell proc alerts"],
                get        = function() return getColor("procAltGlowColor") end,
                set        = function(value) setColor("procAltGlowColor", value) end,
            },
            {
                widgetType = "colorAlpha",
                width      = "half",
                name       = L["Suggested Action Color"],
                desc       = L["Color of suggested action indicators"],
                get        = function() return getColor("suggestedActionColor") end,
                set        = function(value) setColor("suggestedActionColor", value) end,
            },
            { widgetType = "header" },
            { widgetType = "filler", width = "third",     divider = false },
            { widgetType = "filler", width = "third",     divider = false },
            {
                widgetType = "button",
                width      = "third",
                name       = L["Reset Indicator Settings"],
                desc       = L["Reset all indicator-related settings to default values"],
                confirm    = L["Are you sure you want to reset all indicator settings to default values?\n\nThis will reset range indicator, cooldown fade, and spell alert color settings.\n\nThis action cannot be undone!"],
                resetKeys  = {
                    "showHighlightHover", "hoverOverlayColor",
                    "showRangeIndicator", "rangeIndicatorColor",
                    "fadeCooldown", "cooldownColor",
                    "procAltGlowColor", "suggestedActionColor",
                },
            },
        },
    },

    -- ── Text Fields ───────────────────────────────────────────────────────────
    {
        widgetType = "nav",
        name       = L["Text Fields"],
        children   = {
            -- Macro Name
            {
                widgetType = "navChild",
                name       = L["Macro Name"],
                children   = {
                    { widgetType = "header", name = L["Macro Name"] },
                    {
                        widgetType = "toggle",
                        key        = "showMacroName",
                        name       = L["Show Macro Text"],
                        desc       = L["Show or hide the macro name label on buttons"],
                    },
                    { widgetType = "spacer" },
                    {
                        widgetType = "select",
                        key        = "macroNameFont",
                        width      = "half",
                        name       = L["Macro Name Font"],
                        desc       = L["Font family for macro names"],
                        values     = function()
                            local r = {}
                            for _, n in ipairs(LSM:List("font")) do r[n] = n end
                            return r
                        end,
                    },
                    {
                        widgetType = "select",
                        key        = "macroNameFontFlags",
                        width      = "half",
                        name       = L["Font Flags"],
                        desc       = L["Font style flags for macro names"],
                        values     = {
                            [""]             = L["None"],
                            ["OUTLINE"]      = L["Outline"],
                            ["THICKOUTLINE"] = L["Thick Outline"],
                        },
                    },
                    {
                        widgetType = "range",
                        key        = "macroNameFontSize",
                        width      = "half",
                        name       = L["Font Size"],
                        desc       = L["Font size for macro names"],
                        min        = 6,
                        max        = 40,
                        step       = 1,
                    },
                    {
                        widgetType = "colorAlpha",
                        width      = "half",
                        name       = L["Macro Name Color"],
                        get        = function() return getColor("macroNameColor") end,
                        set        = function(v) setColor("macroNameColor", v) end,
                    },
                    {
                        widgetType = "range",
                        key        = "macroNameWidth",
                        width      = "half",
                        name       = L["Width"],
                        desc       = L["Width of the macro name text frame"],
                        min        = 1,
                        max        = 100,
                        step       = 1,
                    },
                    {
                        widgetType = "range",
                        key        = "macroNameHeight",
                        width      = "half",
                        name       = L["Height"],
                        desc       = L["Height of the macro name text frame"],
                        min        = 1,
                        max        = 60,
                        step       = 1,
                    },
                    {
                        widgetType = "range",
                        key        = "macroNameOffsetX",
                        width      = "half",
                        name       = L["Offset X"],
                        desc       = L["Horizontal positioning offset for macro name text"],
                        min        = -30,
                        max        = 30,
                        step       = 1,
                    },
                    {
                        widgetType = "range",
                        key        = "macroNameOffsetY",
                        width      = "half",
                        name       = L["Offset Y"],
                        desc       = L["Vertical positioning offset for macro name text"],
                        min        = -30,
                        max        = 30,
                        step       = 1,
                    },
                    {
                        widgetType = "select",
                        key        = "macroNameJustification",
                        width      = "half",
                        name       = L["Macro Text Justification"],
                        desc       = L["Horizontal text alignment for macro names"],
                        values     = {
                            ["LEFT"]   = L["Left"],
                            ["CENTER"] = L["Center"],
                            ["RIGHT"]  = L["Right"],
                        },
                    },
                    {
                        widgetType = "select",
                        key        = "macroNamePosition",
                        width      = "half",
                        name       = L["Macro Text Position"],
                        desc       = L["Vertical position of macro text within the text frame"],
                        values     = {
                            ["TOP"]    = L["Top"],
                            ["BOTTOM"] = L["Bottom"],
                        },
                    },
                    { widgetType = "header" },
                    { widgetType = "filler", width = "third", divider = false },
                    { widgetType = "filler", width = "third", divider = false },
                    {
                        widgetType = "button",
                        width      = "third",
                        name       = L["Reset Macro Settings"],
                        desc       = L["Reset macro name text settings to default values"],
                        confirm    = L["Are you sure you want to reset all macro text settings to default values?\n\nThis will reset font, size, color, positioning, and justification settings for macro names.\n\nThis action cannot be undone!"],
                        resetKeys  = {
                            "macroNameFont", "macroNameFontSize", "macroNameFontFlags",
                            "macroNameColor", "macroNameWidth", "macroNameHeight",
                            "macroNameJustification", "macroNamePosition",
                            "macroNameOffsetX", "macroNameOffsetY",
                            "showMacroName",
                        },
                    },
                },
            },
            -- Count / Charge
            {
                widgetType = "navChild",
                name       = L["Count / Charge"],
                children   = {
                    { widgetType = "header", name = L["Count / Charge"] },
                    {
                        widgetType = "select",
                        key        = "countFont",
                        width      = "half",
                        name       = L["Count Font"],
                        desc       = L["Font family for count/charge numbers"],
                        values     = function()
                            local r = {}
                            for _, n in ipairs(LSM:List("font")) do r[n] = n end
                            return r
                        end,
                    },
                    {
                        widgetType = "select",
                        key        = "countFontFlags",
                        width      = "half",
                        name       = L["Font Flags"],
                        desc       = L["Font style flags for count/charge numbers"],
                        values     = {
                            [""]             = L["None"],
                            ["OUTLINE"]      = L["Outline"],
                            ["THICKOUTLINE"] = L["Thick Outline"],
                        },
                    },
                    {
                        widgetType = "range",
                        key        = "countFontSize",
                        width      = "half",
                        name       = L["Count Font Size"],
                        desc       = L["Font size for count/charge numbers"],
                        min        = 6,
                        max        = 40,
                        step       = 1,
                    },
                    {
                        widgetType = "colorAlpha",
                        width      = "half",
                        name       = L["Count Color"],
                        get        = function() return getColor("countColor") end,
                        set        = function(v) setColor("countColor", v) end,
                    },
                    {
                        widgetType = "range",
                        key        = "countWidth",
                        width      = "half",
                        name       = L["Width"],
                        desc       = L["Width of the count text frame"],
                        min        = 1,
                        max        = 100,
                        step       = 1,
                    },
                    {
                        widgetType = "range",
                        key        = "countHeight",
                        width      = "half",
                        name       = L["Height"],
                        desc       = L["Height of the count text frame"],
                        min        = 1,
                        max        = 60,
                        step       = 1,
                    },
                    {
                        widgetType = "range",
                        key        = "countOffsetX",
                        width      = "half",
                        name       = L["Offset X"],
                        desc       = L["Horizontal positioning offset for count/charge text"],
                        min        = -30,
                        max        = 30,
                        step       = 1,
                    },
                    {
                        widgetType = "range",
                        key        = "countOffsetY",
                        width      = "half",
                        name       = L["Offset Y"],
                        desc       = L["Vertical positioning offset for count/charge text"],
                        min        = -30,
                        max        = 30,
                        step       = 1,
                    },
                    { widgetType = "header" },
                    { widgetType = "filler", width = "third",           divider = false },
                    { widgetType = "filler", width = "third",           divider = false },
                    {
                        widgetType = "button",
                        name       = L["Reset Count Settings"],
                        desc       = L["Reset count/charge text settings to default values"],
                        confirm    = L["Are you sure you want to reset all count/charge text settings to default values?\n\nThis will reset font, size, color, and positioning settings for count/charge numbers.\n\nThis action cannot be undone!"],
                        resetKeys  = {
                            "countFont", "countFontSize", "countFontFlags",
                            "countColor", "countWidth", "countHeight",
                            "countOffsetX", "countOffsetY",
                        },
                    },
                },
            },
            -- Keybind / Hotkey
            {
                widgetType = "navChild",
                name       = L["Keybind / Hotkey"],
                children   = {
                    { widgetType = "header", name = L["Keybind / Hotkey"] },
                    {
                        widgetType = "toggle",
                        key        = "showKeybindText",
                        width      = "half",
                        name       = L["Show Keybind Text"],
                        desc       = L["Show or hide the keybind/hotkey label on buttons"],
                    },
                    {
                        widgetType = "toggle",
                        key        = "keybindShortenText",
                        width      = "half",
                        name       = L["Shorten Keybind"],
                        desc       = L["Abbreviate modifier keys in keybind text (e.g. Ctrl-Shift-Alt-1 becomes CSA1)"],
                    },
                    {
                        widgetType = "select",
                        key        = "keybindFont",
                        width      = "half",
                        name       = L["Keybind Font"],
                        desc       = L["Font family for keybind/hotkey text"],
                        values     = function()
                            local r = {}
                            for _, n in ipairs(LSM:List("font")) do r[n] = n end
                            return r
                        end,
                    },
                    {
                        widgetType = "select",
                        key        = "keybindFontFlags",
                        width      = "half",
                        name       = L["Font Flags"],
                        desc       = L["Font style flags for keybind/hotkey text"],
                        values     = {
                            [""]             = L["None"],
                            ["OUTLINE"]      = L["Outline"],
                            ["THICKOUTLINE"] = L["Thick Outline"],
                        },
                    },
                    {
                        widgetType = "range",
                        key        = "keybindFontSize",
                        width      = "half",
                        name       = L["Keybind Font Size"],
                        desc       = L["Font size for keybind/hotkey text"],
                        min        = 6,
                        max        = 40,
                        step       = 1,
                    },
                    {
                        widgetType = "colorAlpha",
                        width      = "half",
                        name       = L["Keybind Color"],
                        get        = function() return getColor("keybindColor") end,
                        set        = function(v) setColor("keybindColor", v) end,
                    },
                    {
                        widgetType = "range",
                        key        = "keybindWidth",
                        width      = "half",
                        name       = L["Width"],
                        desc       = L["Width of the keybind text frame"],
                        min        = 1,
                        max        = 100,
                        step       = 1,
                    },
                    {
                        widgetType = "range",
                        key        = "keybindHeight",
                        width      = "half",
                        name       = L["Height"],
                        desc       = L["Height of the keybind text frame"],
                        min        = 1,
                        max        = 60,
                        step       = 1,
                    },
                    {
                        widgetType = "range",
                        key        = "keybindOffsetX",
                        width      = "half",
                        name       = L["Offset X"],
                        desc       = L["Horizontal positioning offset for keybind/hotkey text"],
                        min        = -30,
                        max        = 30,
                        step       = 1,
                    },
                    {
                        widgetType = "range",
                        key        = "keybindOffsetY",
                        width      = "half",
                        name       = L["Offset Y"],
                        desc       = L["Vertical positioning offset for keybind/hotkey text"],
                        min        = -30,
                        max        = 30,
                        step       = 1,
                    },
                    { widgetType = "header" },
                    { widgetType = "filler", width = "third",             divider = false },
                    { widgetType = "filler", width = "third",             divider = false },
                    {
                        widgetType = "button",
                        name       = L["Reset Keybind Settings"],
                        desc       = L["Reset keybind/hotkey text settings to default values"],
                        confirm    = L["Are you sure you want to reset all keybind/hotkey text settings to default values?\n\nThis will reset font, size, color, positioning, and shortening settings for keybind/hotkey text.\n\nThis action cannot be undone!"],
                        resetKeys  = {
                            "keybindFont", "keybindFontSize", "keybindFontFlags",
                            "keybindColor", "keybindWidth", "keybindHeight",
                            "keybindOffsetX", "keybindOffsetY",
                            "keybindShortenText",
                            "showKeybindText",
                        },
                    },
                },
            },
        },
    },

    -- ── Action Bars ───────────────────────────────────────────────────────────
    {
        widgetType = "nav",
        name       = L["Action Bars"],
        children   = actionBarsContent,
    },
}

-- ── Registration ───────────────────────────────────────────────────────────────
zBarButtonBG.zSFCtx = zSettingsFrame.Register({
    addonName   = "zBarButtonBG",
    schema      = ZBBG_SCHEMA,
    get         = function(key) return zBarButtonBG.settingsStore:Get(key) end,
    set         = function(key, value) zBarButtonBG.SetSetting(key, value) end,
    getDefault  = function(key) return addonTable.Core.Defaults.profile[key] end,
    reset       = function(keys) zBarButtonBG.ApplyDefaults(keys) end,
    subscribe   = function(cb) zBarButtonBG.settingsStore:SubscribeAll(cb) end,
    onPanelShow = function() zBarButtonBG.SyncAllSignals() end,
    themeColors = { primary = RAID_CLASS_COLORS["WARRIOR"], secondary = RAID_CLASS_COLORS["EVOKER"] },

})
