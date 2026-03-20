-- Core/SettingsState.lua
-- Reactive settings store: wraps AceDB with zSignalReact-1.0 signals.

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

local lib = LibStub("zSignalReact-1.0")

-- Proxy that always delegates to the live AceDB profile.
-- Safe before OnInitialize — returns nil for any key until the db exists.
local charSettingsProxy = setmetatable({}, {
    __index = function(_, key)
        if zBarButtonBGAce and zBarButtonBGAce.db then
            return zBarButtonBGAce.db.profile[key]
        end
    end,
    __newindex = function(_, key, value)
        if zBarButtonBGAce and zBarButtonBGAce.db then
            zBarButtonBGAce.db.profile[key] = value
        end
    end,
})

zBarButtonBG.charSettings = charSettingsProxy

-- Create the store: signals start at defaults; proxy is the live settings source.
-- SyncAllSignals() is called in OnInitialize to update signals with real saved values.
zBarButtonBG.settingsStore = lib:NewStore(addonTable.Core.Defaults.profile, charSettingsProxy)

--- Sync all signal values from the current AceDB profile.
--- Call after OnInitialize and on every profile switch.
function zBarButtonBG.SyncAllSignals()
    zBarButtonBG.settingsStore:Sync()
end

--- Write a setting through the store (propagates to AceDB and fires signals).
function zBarButtonBG.SetSetting(key, value)
    zBarButtonBG.settingsStore:Set(key, value)
end

--- Reset a list of keys to their stored defaults.
function zBarButtonBG.ApplyDefaults(keys)
    zBarButtonBG.settingsStore:ApplyDefaults(keys)
end

-- ── Effect routing ─────────────────────────────────────────────────────────────
-- Debouncing here batches multiple signal changes (e.g. from SyncAllSignals)
-- into a single rebuild or refresh within the same frame.

local _rebuildPending = false
local function ScheduleRebuild()
    if _rebuildPending then return end
    _rebuildPending = true
    C_Timer.After(0, function()
        _rebuildPending = false
        if not zBarButtonBG.enabled then return end
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
        -- Force range indicators to re-evaluate immediately after rebuild.
        if zBarButtonBG.charSettings.showRangeIndicator then
            for _, data in pairs(zBarButtonBG.frames) do
                local button = data and data.button
                if button and button.action then
                    local r = IsActionInRange(button.action, "target")
                    ActionButton_UpdateRangeIndicator(button, r ~= nil, r ~= false)
                end
            end
        end
    end)
end

local _colorUpdatePending = false
local function ScheduleColorUpdate()
    if _colorUpdatePending then return end
    _colorUpdatePending = true
    C_Timer.After(0, function()
        _colorUpdatePending = false
        if zBarButtonBG.enabled then
            zBarButtonBG.updateColors()
        end
    end)
end

local _fontUpdatePending = false
local function ScheduleFontUpdate()
    if _fontUpdatePending then return end
    _fontUpdatePending = true
    -- 0.1s delay lets LibSharedMedia finish registering newly loaded fonts.
    C_Timer.After(0.1, function()
        _fontUpdatePending = false
        if zBarButtonBG.enabled and zBarButtonBG.updateFonts then
            zBarButtonBG.updateFonts()
        end
    end)
end

-- Keys that require a full button rebuild (geometry / structural changes).
local REBUILD_KEYS = {
    buttonStyle               = true,
    showBorder                = true,
    showBackdrop              = true,
    backdropMaskedToButton    = true,
    backdropTopAdjustment     = true,
    backdropBottomAdjustment  = true,
    backdropLeftAdjustment    = true,
    backdropRightAdjustment   = true,
    showSlotBackground        = true,
    showHighlightHover        = true,
    showRangeIndicator        = true,
    fadeCooldown              = true,
    procGlowColorStyle        = true,
    procAltGlowColorStyle     = true,
    suggestedActionColorStyle = true,
}

-- Keys that only need an in-place color/appearance refresh.
local COLOR_KEYS = {
    borderColor          = true,
    useClassColorBorder  = true,
    outerColor           = true,
    useClassColorOuter   = true,
    innerColor           = true,
    useClassColorInner   = true,
    hoverOverlayColor    = true,
    rangeIndicatorColor  = true,
    cooldownColor        = true,
    procGlowColor        = true,
    procAltGlowColor     = true,
    suggestedActionColor = true,
}

-- Keys that only need a font/text refresh.
local FONT_KEYS = {
    macroNameFont          = true,
    macroNameFontSize      = true,
    macroNameFontFlags     = true,
    macroNameColor         = true,
    macroNameWidth         = true,
    macroNameHeight        = true,
    macroNameJustification = true,
    macroNamePosition      = true,
    macroNameOffsetX       = true,
    macroNameOffsetY       = true,
    countFont              = true,
    countFontSize          = true,
    countFontFlags         = true,
    countColor             = true,
    countWidth             = true,
    countHeight            = true,
    countOffsetX           = true,
    countOffsetY           = true,
    keybindFont            = true,
    keybindFontSize        = true,
    keybindFontFlags       = true,
    keybindColor           = true,
    keybindWidth           = true,
    keybindHeight          = true,
    keybindOffsetX         = true,
    keybindOffsetY         = true,
    keybindShortenText     = true,
    showMacroName          = true,
    showKeybindText        = true,
}

zBarButtonBG.settingsStore:RegisterEffectMap(REBUILD_KEYS, function(key, value)
    ScheduleRebuild()
end)

zBarButtonBG.settingsStore:RegisterEffectMap(COLOR_KEYS, function(key, value)
    ScheduleColorUpdate()
end)

zBarButtonBG.settingsStore:RegisterEffectMap(FONT_KEYS, function(key, value)
    ScheduleFontUpdate()
end)
