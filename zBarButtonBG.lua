-- zBarButtonBG - Action bar button background customization addon

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

-- Initialize global namespace
zBarButtonBG = {}
-- Get localization table
local L = LibStub("AceLocale-3.0"):GetLocale("zBarButtonBG")


-- Get module references
local Init = addonTable.Core.Init
local Overlays = addonTable.Core.Overlays
local Constants = addonTable.Core.Constants
local Utilities = addonTable.Core.Utilities
local Styling = addonTable.Core.Styling
local ButtonSkinning = addonTable.Core.ButtonSkinning
local ProfileManager = addonTable.Profile.Manager
local ButtonStyles = addonTable.Core.ButtonStyles

-- Re-export commonly used functions to global zBarButtonBG namespace for backward compatibility
zBarButtonBG.print = Utilities.print
zBarButtonBG.updateCooldownOverlay = Overlays.updateCooldownOverlay
zBarButtonBG.updateRangeOverlay = Overlays.updateRangeOverlay
zBarButtonBG.ButtonStyles = ButtonStyles

-- Developer toggle for cooldown overlay feature
zBarButtonBG.midnightCooldown = Constants.MIDNIGHT_COOLDOWN

-- Track whether we're enabled and store our custom frames
zBarButtonBG.enabled = false
zBarButtonBG.frames = {}

-- Debug hook call counters for performance profiling
zBarButtonBG._hookCallCounts = {
    rangeIndicator = 0,
    cooldown = 0,
    cooldownFrameSet = 0,
    usable = 0,
    update = 0,
    state = 0,
    onEvent = 0,
}
zBarButtonBG._lastHookReportTime = 0


-- Organize buttons into groups by their bar
-- Format: buttonName -> barName (e.g., "ActionButton5" -> "ActionButton")
zBarButtonBG.buttonGroups = {}

-- Create the Ace addon instance FIRST so we can attach methods to it
zBarButtonBGAce = LibStub("AceAddon-3.0"):NewAddon("zBarButtonBG")

-- Set up Ace addon with proper lifecycle methods
function zBarButtonBGAce:OnInitialize()
    -- Initialize AceDB with profile support
    self.db = LibStub("AceDB-3.0"):New("zBarButtonBGDB", addonTable.Core.Defaults, true)

    -- Re-sync signal values whenever the active profile changes.
    self.db.RegisterCallback(self, "OnProfileChanged", function() zBarButtonBG.SyncAllSignals() end)
    self.db.RegisterCallback(self, "OnProfileCopied",  function() zBarButtonBG.SyncAllSignals() end)
    self.db.RegisterCallback(self, "OnProfileReset",   function() zBarButtonBG.SyncAllSignals() end)

    -- Seed signals with the real saved values (defaults were used at store creation).
    zBarButtonBG.SyncAllSignals()
end

function zBarButtonBGAce:OnEnable()
    -- Register slash commands when enabled
    Init.registerCommands()
end

-- ############################################################
-- Profile management methods (attached to zBarButtonBGAce)
-- ############################################################

-- Create a new profile
function zBarButtonBGAce:CreateNewProfile(profileName)
    if not profileName or profileName == "" then
        return false, L["Profile name cannot be empty"]
    end

    if self.db.profiles[profileName] then
        return false, L["Profile already exists"]
    end

    -- Create new profile and switch to it
    self.db:SetProfile(profileName)
    zBarButtonBG.SyncAllSignals()

    -- Update the action bars
    if zBarButtonBG.enabled then
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
    end

    return true, L["Profile created"]
end

-- Switch to an existing profile
function zBarButtonBGAce:SwitchProfile(profileName)
    if not profileName or not self.db.profiles[profileName] then
        return false, L["Profile does not exist"]
    end

    -- Switch to profile
    self.db:SetProfile(profileName)
    zBarButtonBG.SyncAllSignals()

    -- Update the action bars
    if zBarButtonBG.enabled then
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
    end

    return true, L["Switched to profile"] .. ": " .. profileName
end

-- Copy profile data from one profile to another
function zBarButtonBGAce:CopyProfile(sourceProfile, targetProfile)
    if not sourceProfile or not self.db.profiles[sourceProfile] then
        return false, L["Source profile does not exist"]
    end

    if not targetProfile or targetProfile == "" then
        targetProfile = self.db:GetCurrentProfile()
    end

    -- Copy profile data
    self.db:CopyProfile(sourceProfile, targetProfile)
    zBarButtonBG.SyncAllSignals()

    -- Update the action bars
    if zBarButtonBG.enabled then
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
    end

    return true, L["Profile copied successfully"]
end

-- Delete a profile
function zBarButtonBGAce:DeleteProfile(profileName)
    if not profileName or profileName == "Default" then
        return false, L["Cannot delete Default profile"]
    end

    if not self.db.profiles[profileName] then
        return false, L["Profile does not exist"]
    end

    if self.db:GetCurrentProfile() == profileName then
        -- Switch to a safe profile before deleting
        -- Try to find an existing profile to switch to, preferring "Default"
        local targetProfile = "Default"
        if not self.db.profiles["Default"] then
            -- If no Default profile exists, find any other existing profile
            for existingProfile, _ in pairs(self.db.profiles) do
                if existingProfile ~= profileName then
                    targetProfile = existingProfile
                    break
                end
            end
        end

        self.db:SetProfile(targetProfile)
        zBarButtonBG.SyncAllSignals()
    end

    -- Delete the profile
    self.db:DeleteProfile(profileName)

    -- Update the action bars
    if zBarButtonBG.enabled then
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
    end

    return true, L["Profile deleted"]
end

-- ############################################################
-- Setting retrieval with per-bar profile support
-- ############################################################

-- Main helper: Get a setting value for a specific bar
-- Checks per-bar profile first, then falls back to defaults.lua (not saved profiles)
function zBarButtonBG.GetSettingInfo(barName, settingName)
    if not settingName then return nil end

    local value = nil
    local defaults = addonTable.Core.Defaults.profile

    -- Check for per-bar override first
    if barName and zBarButtonBGAce.db.char and zBarButtonBGAce.db.char.barSettings and zBarButtonBGAce.db.char.barSettings[barName] then
        local barSetting = zBarButtonBGAce.db.char.barSettings[barName]

        -- Check if bar has a different profile assigned
        if barSetting.differentProfile and barSetting.profileName then
            local profile
            -- Try to get the named profile from saved profiles
            if zBarButtonBGAce.db.profiles and zBarButtonBGAce.db.profiles[barSetting.profileName] then
                profile = zBarButtonBGAce.db.profiles[barSetting.profileName]
            end

            if profile then
                value = profile[settingName]
                -- If value exists and is a table (like colors), fill in missing components from defaults
                if value ~= nil and type(value) == "table" and type(defaults[settingName]) == "table" then
                    local defaultTable = defaults[settingName]
                    for key, defaultVal in pairs(defaultTable) do
                        if value[key] == nil then
                            value[key] = defaultVal
                        end
                    end
                end
            end

            -- If still not found, use defaults
            if value == nil then
                value = defaults[settingName]
            end

            return value
        end
    end

    -- No different profile assigned - use user's current global profile
    local profileToUse = zBarButtonBGAce.db:GetCurrentProfile()
    local profile = zBarButtonBGAce.db.profiles[profileToUse]
    if not profile then
        profile = zBarButtonBGAce.db.profile
    end

    value = profile[settingName]
    -- If value exists and is a table (like colors), fill in missing components from defaults
    if value ~= nil and type(value) == "table" and type(defaults[settingName]) == "table" then
        local defaultTable = defaults[settingName]
        for key, defaultVal in pairs(defaultTable) do
            if value[key] == nil then
                value[key] = defaultVal
            end
        end
    end

    -- If still not found, use defaults
    if value == nil then
        value = defaults[settingName]
    end

    return value
end

-- Helper: Extract bar base name from button name
-- e.g. "ActionButton5" -> "ActionButton", "MultiBarBottomLeftButton3" -> "MultiBarBottomLeftButton"
function zBarButtonBG.GetBarNameFromButton(buttonName)
    if not buttonName then return nil end

    local barBases = {
        "ActionButton",
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarRightButton",
        "MultiBarLeftButton",
        "MultiBar5Button",
        "MultiBar6Button",
        "MultiBar7Button",
        "PetActionButton",
        "StanceButton",
    }

    for _, baseName in ipairs(barBases) do
        if buttonName:sub(1, #baseName) == baseName then
            return baseName
        end
    end

    return nil
end

-- ############################################################
-- Command and toggle functions
-- ############################################################

-- Print hook call statistics for debugging performance
function zBarButtonBG.printHookStats()
    local now = GetTime()
    local elapsed = now - (zBarButtonBG._lastHookReportTime or 0)

    if elapsed < 1 then
        zBarButtonBG.print("Please wait at least 1 second between reports")
        return
    end

    zBarButtonBG._lastHookReportTime = now

    local counts = zBarButtonBG._hookCallCounts
    zBarButtonBG.print("=== Hook Call Counts (per second) ===")
    zBarButtonBG.print(string.format("ActionButton_UpdateRangeIndicator: %d/sec", counts.rangeIndicator / (elapsed or 1)))
    zBarButtonBG.print(string.format("ActionButton_UpdateCooldown: %d/sec", counts.cooldown / (elapsed or 1)))
    zBarButtonBG.print(string.format("CooldownFrame_Set: %d/sec", counts.cooldownFrameSet / (elapsed or 1)))
    zBarButtonBG.print(string.format("ActionButton_UpdateUsable: %d/sec", counts.usable / (elapsed or 1)))
    zBarButtonBG.print(string.format("ActionButton_Update: %d/sec", counts.update / (elapsed or 1)))
    zBarButtonBG.print(string.format("ActionButton_UpdateState: %d/sec", counts.state / (elapsed or 1)))
    zBarButtonBG.print(string.format("ActionButton_OnEvent: %d/sec", counts.onEvent / (elapsed or 1)))

    -- Reset counters
    for key in pairs(counts) do
        counts[key] = 0
    end
end

-- Toggle command - turn backgrounds on/off
function zBarButtonBG.toggle()
    zBarButtonBG.enabled = not zBarButtonBG.enabled

    if zBarButtonBG.enabled then
        zBarButtonBG.createActionBarBackgrounds()
        zBarButtonBG.print("|cFF00FF00" .. L["Enabled"] .. "|r")
    else
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.print("|cFFFF0000" .. L["Disabled"] .. "|r")
    end

    -- Save the enabled state (zBarButtonBG.charSettings points to Ace profile, so this automatically saves)
    if zBarButtonBG.charSettings then
        zBarButtonBG.charSettings.enabled = zBarButtonBG.enabled
    end
end

-- Update colors on existing frames without rebuilding everything
function zBarButtonBG.updateColors()
    if not zBarButtonBG.enabled then return end

    for buttonName, data in pairs(zBarButtonBG.frames) do
        if data and data.button then
            -- Get per-bar settings for this button
            local barName = zBarButtonBG.buttonGroups[buttonName]
            -- Use modular function to update all color-related elements
            ButtonSkinning.setOuterBackground(data.button, barName)
            ButtonSkinning.setInnerBackground(data.button, barName)
            ButtonSkinning.setBorder(data.button, barName)
            Overlays.setHighlightOverlay(data.button, barName)
            Overlays.setRangeOverlay(data.button, barName)
            Overlays.setCooldownOverlay(data.button, barName)
        end
    end
end

-- Update fonts on existing buttons without rebuilding everything
function zBarButtonBG.updateFonts()
    if not zBarButtonBG.enabled then return end

    for buttonName, data in pairs(zBarButtonBG.frames) do
        if data and data.button then
            local barName = zBarButtonBG.buttonGroups[buttonName]
            if barName then
                Styling.setTextStyling(data.button, barName)
            end
        end
    end
end

-- Update fonts on a single button without rebuilding everything
function zBarButtonBG.updateButtonFont(buttonName)
    if not zBarButtonBG.enabled then return end

    local data = zBarButtonBG.frames[buttonName]
    if data and data.button then
        local barName = zBarButtonBG.buttonGroups[buttonName]
        if barName then
            Styling.setTextStyling(data.button, barName)
        end
    end
end

-- ############################################################
-- COMBAT MODE PROFILE SWAPPING
-- ############################################################

-- Store the pre-combat bar profile settings
zBarButtonBG._preCombatBarSettings = {}
zBarButtonBG._combatModeActive = false

-- Get the combat profile name from character settings
function zBarButtonBG.getCombatProfile()
    local useCombatProfile = zBarButtonBGAce.db.char.useCombatProfile
    local combatProfileName = zBarButtonBGAce.db.char.combatProfileName

    if not useCombatProfile or not combatProfileName then
        return nil
    end

    -- Check if profile exists
    if not zBarButtonBGAce.db.profiles[combatProfileName] then
        return nil -- Profile doesn't exist, fall back to defaults
    end

    return combatProfileName
end

-- Enter combat mode - swap all bars to combat profile
function zBarButtonBG.enterCombatMode()
    if zBarButtonBG._combatModeActive or not zBarButtonBG.enabled then return end

    local combatProfile = zBarButtonBG.getCombatProfile()
    if not combatProfile then return end

    -- Initialize storage if needed
    if not zBarButtonBGAce.db.char.barSettings then
        zBarButtonBGAce.db.char.barSettings = {}
    end

    -- Get ALL possible bar base names from defaults
    local barBases = {
        "ActionButton",
        "MultiBarBottomLeftButton",
        "MultiBarBottomRightButton",
        "MultiBarRightButton",
        "MultiBarLeftButton",
        "MultiBar5Button",
        "MultiBar6Button",
        "MultiBar7Button",
        "PetActionButton",
        "StanceButton",
    }

    -- Store current settings for ALL bars before modifying
    for _, barBaseName in ipairs(barBases) do
        if not zBarButtonBGAce.db.char.barSettings[barBaseName] then
            zBarButtonBGAce.db.char.barSettings[barBaseName] = {}
        end

        -- Deep copy current settings
        zBarButtonBG._preCombatBarSettings[barBaseName] = {
            differentProfile = zBarButtonBGAce.db.char.barSettings[barBaseName].differentProfile,
            profileName = zBarButtonBGAce.db.char.barSettings[barBaseName].profileName
        }

        -- Apply combat profile to this bar
        zBarButtonBGAce.db.char.barSettings[barBaseName].differentProfile = true
        zBarButtonBGAce.db.char.barSettings[barBaseName].profileName = combatProfile
    end

    zBarButtonBG._combatModeActive = true
    zBarButtonBG.updateColors()
    -- Defer the rebuild by one event-batch tick, mirroring exitCombatMode.
    -- PLAYER_REGEN_DISABLED can fire in the same batch as bar-change events
    -- (e.g. entering stealth, a vehicle, or an override bar simultaneously
    -- triggers combat).  Running synchronously here would rebuild before WoW
    -- finishes updating button.action, leaving icons visually stale.
    C_Timer.After(0, function()
        if not zBarButtonBG.enabled then return end
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
    end)
end

-- Exit combat mode - restore pre-combat profiles
function zBarButtonBG.exitCombatMode()
    if not zBarButtonBG._combatModeActive or not zBarButtonBG.enabled then return end

    -- Restore previous profile assignments from stored snapshot
    for barBaseName, settings in pairs(zBarButtonBG._preCombatBarSettings) do
        if not zBarButtonBGAce.db.char.barSettings then
            zBarButtonBGAce.db.char.barSettings = {}
        end
        if not zBarButtonBGAce.db.char.barSettings[barBaseName] then
            zBarButtonBGAce.db.char.barSettings[barBaseName] = {}
        end

        zBarButtonBGAce.db.char.barSettings[barBaseName].differentProfile = settings.differentProfile
        zBarButtonBGAce.db.char.barSettings[barBaseName].profileName = settings.profileName
    end

    zBarButtonBG._preCombatBarSettings = {}
    zBarButtonBG._combatModeActive = false
    zBarButtonBG.updateColors()
    -- Defer the full rebuild by one event-batch tick.  When the player exits combat
    -- while dismounting (or changing form), WoW queues ACTIONBAR_PAGE_CHANGED in the
    -- same tick as PLAYER_REGEN_ENABLED.  Running synchronously here would rebuild
    -- before WoW has updated button.action for the new page, producing a frame where
    -- the wrong bar state is captured.  C_Timer.After(0) yields until all pending
    -- events in the current batch have been dispatched, so button.action is correct.
    C_Timer.After(0, function()
        if not zBarButtonBG.enabled then return end
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
    end)
end

-- ############################################################
-- Load settings when we log in
-- ############################################################
local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Enter combat
Frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Exit combat
Frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- If we had this enabled before, turn it back on after a short delay
        if zBarButtonBG.charSettings.enabled then
            zBarButtonBG.enabled = true
            C_Timer.After(3.5, function()
                -- Check if combat profile is stuck on but we're not in combat
                -- This handles the reload-while-stuck-in-combat case
                if not InCombatLockdown() and zBarButtonBGAce.db.char.useCombatProfile then
                    -- Check if any bar still has combat profile applied
                    local needsReset = false
                    local combatProfileName = zBarButtonBGAce.db.char.combatProfileName
                    if zBarButtonBGAce.db.char.barSettings then
                        for barBaseName, barSetting in pairs(zBarButtonBGAce.db.char.barSettings) do
                            if barSetting.profileName == combatProfileName and barSetting.differentProfile then
                                needsReset = true
                                break
                            end
                        end
                    end

                    if needsReset then
                        -- Reset all bars to default (not using different profile)
                        local barBases = {
                            "ActionButton",
                            "MultiBarBottomLeftButton",
                            "MultiBarBottomRightButton",
                            "MultiBarRightButton",
                            "MultiBarLeftButton",
                            "MultiBar5Button",
                            "MultiBar6Button",
                            "MultiBar7Button",
                            "PetActionButton",
                            "StanceButton",
                        }
                        if not zBarButtonBGAce.db.char.barSettings then
                            zBarButtonBGAce.db.char.barSettings = {}
                        end
                        for _, barBaseName in ipairs(barBases) do
                            if not zBarButtonBGAce.db.char.barSettings[barBaseName] then
                                zBarButtonBGAce.db.char.barSettings[barBaseName] = {}
                            end
                            zBarButtonBGAce.db.char.barSettings[barBaseName].differentProfile = false
                            zBarButtonBGAce.db.char.barSettings[barBaseName].profileName = "Default"
                        end
                        zBarButtonBG._combatModeActive = false
                    end
                end

                zBarButtonBG.createActionBarBackgrounds()
            end)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        -- Entering combat
        zBarButtonBG.enterCombatMode()
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Exiting combat
        zBarButtonBG.exitCombatMode()
    end
end)

-- ############################################################
-- ACTION BAR BACKGROUNDS
-- ############################################################
-- Local alias for updateButtonNormalTexture used in button creation loop
local updateButtonNormalTexture = Styling.updateButtonNormalTexture

-- Initialize all button regions from metadata
local function initializeButtonRegions(button)
    ButtonStyles.InitializeButton(button)
end

function zBarButtonBG.removeActionBarBackgrounds()
    -- Hide and destroy all our custom frames and clean up button masks
    for buttonName, data in pairs(zBarButtonBG.frames) do
        if data then
            if data.button then
                -- Clean up the mask texture so it gets reapplied with the new setting
                if data.button._zBBG_customMask then
                    Utilities.removeMaskFromTexture(data.button.icon)
                    data.button._zBBG_customMask = nil
                end

                -- Clear the styled flag so button gets reprocessed
                data.button._zBBG_styled = false
            end
            if data.outerFrame then
                data.outerFrame:Hide()
            end
            if data.frame then
                data.frame:Hide()
            end
            if data.borderFrame then
                data.borderFrame:Hide()
            end
        end
    end

    -- Clear the frames table but keep button tracking
    zBarButtonBG.frames = {}
end

-- Force update any currently visible flipbooks when settings change
-- Called after button style changes to ensure visible animations use new textures
function zBarButtonBG.forceUpdateVisibleFlipbooks()
    for buttonName, data in pairs(zBarButtonBG.frames) do
        if data and data.button then
            local button = data.button
            local barName = zBarButtonBG.buttonGroups[buttonName]

            if barName then
                -- Force update any visible flipbooks
                Overlays.updateEquipmentBorderFlipbook(button, barName)
                Overlays.updateAssistedHighlightFlipbook(button, barName)
                Overlays.updateSpellAlertFlipbooks(button, barName)
            end
        end
    end
end

function zBarButtonBG.createActionBarBackgrounds()
    -- All the different types of action bar buttons we want to modify
    local buttonBases = {
        "ActionButton",              -- Main action bar (1-12)
        "MultiBarBottomLeftButton",  -- Bottom left bar
        "MultiBarBottomRightButton", -- Bottom right bar
        "MultiBarRightButton",       -- Right bar 1
        "MultiBarLeftButton",        -- Right bar 2
        "MultiBar5Button",           -- Bar 5
        "MultiBar6Button",           -- Bar 6
        "MultiBar7Button",           -- Bar 7
        "PetActionButton",           -- Pet action bar
        "StanceButton",              -- Stance/form bar
    }

    for _, baseName in ipairs(buttonBases) do
        -- Pet and stance bars only have 10 buttons instead of 12
        local maxButtons = (baseName == "PetActionButton" or baseName == "StanceButton") and 10 or 12
        for i = 1, maxButtons do
            local buttonName = baseName .. i
            local button = _G[buttonName]

            -- Process the button whether it's visible or not
            -- This is important for pet bars that only show up when you summon a pet
            if button then
                -- Register this button to its bar group
                zBarButtonBG.buttonGroups[buttonName] = baseName
                local barName = baseName

                -- Check if we've already set this button up
                if not zBarButtonBG.frames[buttonName] then
                    -- Initial setup: mark button and initialize everything
                    button._zBBG_styled = true
                    initializeButtonRegions(button)
                    updateButtonNormalTexture(button)

                    -- Call the consolidated setup function to handle all skinning
                    ButtonSkinning.setupButton(button, barName)

                    -- Store frame references for future updates
                    zBarButtonBG.frames[buttonName] = { button = button }
                else
                    -- Button already set up, just refresh with current settings
                    ButtonSkinning.updateButton(button, barName)
                end
            end
        end
    end
    --[[
	-- Override action bar container buttonPadding if enabled (per-bar)
	local containerNames = {
		"MainMenuBar",
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"MultiBarRight",
		"MultiBarLeft",
		"MultiBar5",
		"MultiBar6",
		"MultiBar7"
	}
	for _, containerName in ipairs(containerNames) do
		local barName = containerName -- assuming containerName matches barName
		local overrideIconPadding = zBarButtonBG.GetSettingInfo(barName, "overrideIconPadding")
		local iconPaddingValue = zBarButtonBG.GetSettingInfo(barName, "iconPaddingValue")
		local container = _G[containerName]
		if overrideIconPadding and iconPaddingValue ~= nil and container and container.buttonPadding ~= nil then
			container.buttonPadding = iconPaddingValue
			if container.UpdateGridLayout then
				container:UpdateGridLayout()
			end
		end
	end
	]] --
    -- Hook into action bar stuff so we know when buttons change
    if not zBarButtonBG.hookInstalled then
        -- Listen for the important action bar changes - no more spam than we need
        local updateFrame = CreateFrame("Frame")
        updateFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
        updateFrame:RegisterEvent("UPDATE_BINDINGS")
        updateFrame:RegisterEvent("CURSOR_CHANGED")
        -- These fire when the effective action bar page changes (mounts, druid forms,
        -- vehicles, stances, override bars).  All need the same clear+re-eval treatment.
        updateFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
        updateFrame:RegisterEvent("UPDATE_BONUS_ACTIONBAR")   -- druid forms / stances
        updateFrame:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")  -- vehicles
        updateFrame:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR") -- override bars
        -- Clear and re-evaluate all range overlays when the target changes.
        -- This is the natural trigger point: a new target may be at a different
        -- range, and any previously-stuck overlays will be corrected here.
        updateFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

        -- Update HotKey color and zBBG range overlay for a button WITHOUT calling
        -- ActionButton_UpdateRangeIndicator.  Calling that global from insecure code
        -- triggers every hooksecurefunc chain (including other addons) from tainted
        -- context, which can propagate secret-value taint into Blizzard's own secure
        -- button update path.  This helper replicates only the HotKey and overlay logic.
        local function updateRangeStateForButton(button)
            local rangeResult = IsActionInRange(button.action, "target")
            local checksRange = rangeResult ~= nil
            local inRange     = rangeResult ~= false

            -- Mirror ActionButton_UpdateRangeIndicator HotKey coloring
            local hotkey = button.HotKey
            if hotkey then
                if hotkey:GetText() == RANGE_INDICATOR then
                    if checksRange then
                        hotkey:Show()
                        if inRange then
                            hotkey:SetVertexColor(ACTIONBAR_HOTKEY_FONT_COLOR:GetRGB())
                        else
                            hotkey:SetVertexColor(RED_FONT_COLOR:GetRGB())
                        end
                    else
                        hotkey:Hide()
                    end
                else
                    if checksRange and not inRange then
                        hotkey:SetVertexColor(RED_FONT_COLOR:GetRGB())
                    else
                        hotkey:SetVertexColor(ACTIONBAR_HOTKEY_FONT_COLOR:GetRGB())
                    end
                end
            end

            -- Update zBBG overlay directly
            local overlay = button._zBBG_rangeOverlay
            if overlay then
                local shouldShow = checksRange and (inRange == false)
                    and zBarButtonBG.charSettings.showRangeIndicator
                    and UnitExists("target")
                if shouldShow and not overlay:IsShown() then
                    overlay:Show()
                elseif not shouldShow and overlay:IsShown() then
                    overlay:Hide()
                    zBarButtonBG.updateButtonFont(button)
                end
            end
        end

        updateFrame:SetScript("OnEvent", function(self, event)
            if zBarButtonBG.enabled then
                if event == "PLAYER_TARGET_CHANGED" then
                    -- Target changed or dropped.  ACTION_RANGE_CHECK_UPDATE does NOT fire
                    -- when the target is cleared (nothing to measure range against), so
                    -- Blizzard's HotKey color reset never runs on target-drop.
                    -- Use the local helper to update HotKey and overlay directly, avoiding
                    -- a call to ActionButton_UpdateRangeIndicator from insecure context
                    -- (which would trigger other addons' hooksecurefunc chains).
                    for _, data in pairs(zBarButtonBG.frames) do
                        local button = data and data.button
                        if button and button.action and button._zBBG_rangeOverlay then
                            updateRangeStateForButton(button)
                        end
                    end
                elseif event == "CURSOR_CHANGED" then
                    -- Clear stuck highlights when dragging stuff around
                    local cursorType = GetCursorInfo()
                    if cursorType then -- Cursor picked something up
                        for buttonName, data in pairs(zBarButtonBG.frames) do
                            if data and data.button and data.button._zBBG_customHighlight then
                                data.button._zBBG_customHighlight:Hide()
                            end
                        end
                    end
                elseif event == "ACTIONBAR_PAGE_CHANGED"
                    or event == "PLAYER_MOUNT_DISPLAY_CHANGED"
                    or event == "UPDATE_BONUS_ACTIONBAR"
                    or event == "UPDATE_VEHICLE_ACTIONBAR"
                    or event == "UPDATE_OVERRIDE_ACTIONBAR" then
                    -- Proactively clear all range overlays before the bar data is replaced.
                    for _, data in pairs(zBarButtonBG.frames) do
                        local btn = data and data.button
                        if btn then
                            if btn._zBBG_rangeOverlay and btn._zBBG_rangeOverlay:IsShown() then
                                btn._zBBG_rangeOverlay:Hide()
                            end
                            if btn.HotKey then
                                btn.HotKey:SetVertexColor(ACTIONBAR_HOTKEY_FONT_COLOR:GetRGB())
                            end
                        end
                    end
                    if zBarButtonBG._debug then
                        zBarButtonBG.print("Action bar changed (" .. event .. ") - rebuilding skins")
                    end
                    zBarButtonBG.createActionBarBackgrounds()
                    -- ACTION_RANGE_CHECK_UPDATE does not automatically fire for the new
                    -- action slots after a bar change.  Without this deferred sweep the
                    -- range overlay would never show on the new bar if the target was
                    -- already selected before the form/page change.
                    -- C_Timer.After(0) yields until all pending events in this batch are
                    -- dispatched, so button.action is current when we read it.
                    if UnitExists("target") then
                        C_Timer.After(0, function()
                            if not zBarButtonBG.enabled then return end
                            for _, data in pairs(zBarButtonBG.frames) do
                                local button = data and data.button
                                if button and button.action and button._zBBG_rangeOverlay then
                                    updateRangeStateForButton(button)
                                end
                            end
                        end)
                    end
                else
                    -- UPDATE_BINDINGS or similar: keybind-only change, just rebuild
                    zBarButtonBG.createActionBarBackgrounds()
                end
            end
        end)

        -- Hook the button update functions so we can mess with NormalTexture
        -- Keep it invisible when we want square buttons, or color it when we need borders
        local function manageNormalTexture(button)
            if button and button.NormalTexture and button._zBBG_styled and zBarButtonBG.enabled then
                -- Use cached border setting from last setBorder call instead of calling GetSettingInfo every time
                local showBorderForButton = button._zBBG_showBorder

                -- If cache doesn't exist, fall back to GetSettingInfo (shouldn't happen but safe fallback)
                if showBorderForButton == nil then
                    local buttonName = button:GetName()
                    local barName = zBarButtonBG.buttonGroups[buttonName]
                    showBorderForButton = zBarButtonBG.GetSettingInfo(barName, "showBorder")
                end

                -- Cache current state to avoid redundant texture operations
                local normalTexture = button.NormalTexture
                local currentAlpha = normalTexture:GetAlpha()

                if showBorderForButton then
                    -- Round buttons with borders: make visible and color it
                    -- Only call Show if it's not already shown
                    if currentAlpha == 0 then
                        normalTexture:Show()
                    end

                    -- Get border color and update vertex color
                    local barName = button._zBBG_borderBarName
                    if not barName then
                        local buttonName = button:GetName()
                        barName = zBarButtonBG.buttonGroups[buttonName]
                    end
                    local borderColor = Utilities.getColorTable("borderColor", "useClassColorBorder", barName)

                    -- Cache previous color to avoid redundant SetVertexColor calls
                    if not button._zBBG_borderColorCache or
                        button._zBBG_borderColorCache.r ~= borderColor.r or
                        button._zBBG_borderColorCache.g ~= borderColor.g or
                        button._zBBG_borderColorCache.b ~= borderColor.b or
                        button._zBBG_borderColorCache.a ~= borderColor.a then
                        normalTexture:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
                        button._zBBG_borderColorCache = { r = borderColor.r, g = borderColor.g, b = borderColor.b, a = borderColor.a }
                    end

                    -- Set alpha to 1 if not already
                    if currentAlpha ~= 1 then
                        normalTexture:SetAlpha(1)
                    end
                else
                    -- Round buttons without borders: make it transparent
                    -- Only call SetAlpha if it's not already 0
                    if currentAlpha ~= 0 then
                        normalTexture:SetAlpha(0)
                    end
                end
            end
        end

        -- ActionButton_UpdateRangeIndicator(self, checksRange, inRange) is Blizzard's global
        -- function that colors the HotKey red when an ability is out of range.  It is called
        -- by the ACTION_RANGE_CHECK_UPDATE event handler on every button frame.
        -- checksRange = the ability has a range requirement (bool)
        -- inRange     = the current target is within range (bool)
        -- NOTE: button.outOfRange is a LibActionButton-1.0 field; native Blizzard buttons
        --       never set it.  We must read checksRange/inRange from the call args instead.
        hooksecurefunc("ActionButton_UpdateRangeIndicator", function(button, checksRange, inRange)
            if button and button._zBBG_styled and zBarButtonBG.enabled then
                if zBarButtonBG._debug then
                    zBarButtonBG._hookCallCounts.rangeIndicator = (zBarButtonBG._hookCallCounts.rangeIndicator or 0) + 1
                    zBarButtonBG.print("Range update for " .. (button:GetName() or "Unknown") ..
                        " - checksRange: " .. tostring(checksRange) .. ", inRange: " .. tostring(inRange))
                end
                manageNormalTexture(button)

                if button._zBBG_rangeOverlay then
                    -- Trust Blizzard's args directly.
                    -- checksRange=true + inRange=false is Blizzard's own OOR condition.
                    -- Proactive clearing on bar changes is handled by the event handler
                    -- loop, not here.  No IsActionInRange cross-verify: it returns nil
                    -- for many legitimately-ranged abilities (hostile-only spells, LoS,
                    -- etc.) which would cause false negatives.
                    local shouldShow = checksRange and (inRange == false)
                        and zBarButtonBG.charSettings.showRangeIndicator
                        and UnitExists("target")
                    local overlay = button._zBBG_rangeOverlay
                    if shouldShow and not overlay:IsShown() then
                        overlay:Show()
                    elseif not shouldShow and overlay:IsShown() then
                        overlay:Hide()
                        zBarButtonBG.updateButtonFont(button)
                    end
                end
            end
        end)

        -- Cooldown frame OnShow/OnHide hooks in setCooldownOverlay handle overlay visibility directly
        -- No need to throttle ActionButton_UpdateCooldown since the cooldown frame hooks are instant

        -- Hook usability updates to keep the NormalTexture in sync.
        -- Range is NOT derived here; ActionButton_UpdateRangeIndicator is the sole authority.
        if ActionButton_UpdateUsable then
            hooksecurefunc("ActionButton_UpdateUsable", function(button)
                if button and button._zBBG_styled and zBarButtonBG.enabled then
                    if zBarButtonBG._debug then
                        zBarButtonBG._hookCallCounts.usable = (zBarButtonBG._hookCallCounts.usable or 0) + 1
                    end
                    manageNormalTexture(button)
                end
            end)
        end

        -- Hook main action updates - fires when a button's action slot changes (bar page,
        -- form swap, mount, etc.).  We clear stale range state here so the overlay doesn't
        -- carry over from the previous action.  ActionButton_UpdateRangeIndicator (hooked
        -- above) is the SOLE authority for re-showing the overlay; WoW's range-check system
        -- will call it automatically once the new action's range is evaluated.
        if ActionButton_Update then
            hooksecurefunc("ActionButton_Update", function(button)
                if button and button._zBBG_styled and zBarButtonBG.enabled then
                    manageNormalTexture(button)
                end
            end)
        end

        -- Hook state updates for better highlight management
        if ActionButton_UpdateState then
            hooksecurefunc("ActionButton_UpdateState", function(button)
                if button and button._zBBG_styled and zBarButtonBG.enabled then
                    if zBarButtonBG._debug then
                        zBarButtonBG._hookCallCounts.state = (zBarButtonBG._hookCallCounts.state or 0) + 1
                    end
                    manageNormalTexture(button)
                end
            end)
        end

        -- Hook the main action button update function to catch page changes
        -- This should be called whenever a button's action changes
        if ActionButton_OnEvent then
            hooksecurefunc("ActionButton_OnEvent", function(button, event, ...)
                if button and button._zBBG_styled and zBarButtonBG.enabled then
                    if event == "ACTIONBAR_SLOT_CHANGED" or event == "UPDATE_BINDINGS" then
                        -- Just update normal texture state, range is handled by ActionButton_UpdateRangeIndicator
                        manageNormalTexture(button)
                    end
                end
            end)
        end

        -- Hook AssistedCombatManager to replace suggested action flipbook textures and apply masks
        if AssistedCombatManager then
            hooksecurefunc(AssistedCombatManager, "SetAssistedHighlightFrameShown", function(self, actionButton, shown)
                if not actionButton or not actionButton._zBBG_styled then
                    return
                end

                -- Get the highlight frame
                local highlightFrame = actionButton.AssistedCombatHighlightFrame
                if not highlightFrame or not highlightFrame.Flipbook then
                    return
                end

                local flipbook = highlightFrame.Flipbook

                -- Only do setup once - just toggle visibility on subsequent calls
                if not actionButton._zBBG_assistedSetup then
                    local buttonNameForStyle = actionButton:GetName()
                    local barNameForStyle = zBarButtonBG.buttonGroups[buttonNameForStyle]
                    Overlays.setupAssistedHighlightFlipbook(actionButton, barNameForStyle)
                    actionButton._zBBG_assistedSetup = true
                end

                -- Now just toggle visibility
                if shown then
                    flipbook:Show()
                else
                    flipbook:Hide()
                end
            end)
        end

        -- Hook ActionButtonSpellAlertManager to replace spell activation flipbooks with custom ones
        if ActionButtonSpellAlertManager then
            hooksecurefunc(ActionButtonSpellAlertManager, "ShowAlert", function(self, actionButton, alertType)
                if not actionButton or not actionButton.SpellActivationAlert then
                    return
                end

                -- Only modify spell alerts for our styled action bar buttons, not other addon windows
                if not actionButton._zBBG_styled then
                    return
                end

                local alert = actionButton.SpellActivationAlert

                -- Get the button's bar name for per-bar settings
                local buttonNameForStyle = actionButton:GetName()
                local barNameForStyle = zBarButtonBG.buttonGroups[buttonNameForStyle]

                -- Only configure animation frames once
                if not actionButton._zBBG_spellAlertConfigured then
                    Overlays.setupSpellAlertFlipbooks(actionButton, barNameForStyle)
                    actionButton._zBBG_spellAlertConfigured = true
                else
                    -- Already configured - just update textures if style changed
                    local styleName = zBarButtonBG.GetSettingInfo(barNameForStyle, "buttonStyle") or "Square"
                    if actionButton._zBBG_lastSpellAlertStyle ~= styleName then
                        Overlays.updateSpellAlertFlipbooks(actionButton, barNameForStyle)
                        actionButton._zBBG_lastSpellAlertStyle = styleName
                    end
                end
            end)
        end -- Hook HideAlert to also hide our proc indicator, glow, and alt glow
        if ActionButtonSpellAlertManager then
            hooksecurefunc(ActionButtonSpellAlertManager, "HideAlert", function(self, actionButton)
                if actionButton then
                    if actionButton._zBBG_procIndicator then
                        actionButton._zBBG_procIndicator:Hide()
                    end
                    if actionButton._zBBG_procGlow then
                        actionButton._zBBG_procGlow:Hide()
                    end
                    -- Also hide ProcAltGlow if it exists
                    local alert = actionButton.SpellActivationAlert
                    if alert and alert.ProcAltGlow then
                        alert.ProcAltGlow:Hide()
                    end
                end
            end)
        end

        zBarButtonBG.hookInstalled = true
    end

    -- Force update any currently visible flipbooks to use new style textures
    zBarButtonBG.forceUpdateVisibleFlipbooks()
end
