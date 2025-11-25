-- Profile management functions for zBarButtonBG

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Profile = {}
addonTable.Profile.Manager = {}
local ProfileManager = addonTable.Profile.Manager

-- Get localization table
local L = LibStub("AceLocale-3.0"):GetLocale("zBarButtonBG")


-- Create a new profile
function ProfileManager.createProfile(profileName)
    if not profileName or profileName == "" then
        return false, L["Profile name cannot be empty"]
    end

    if zBarButtonBGAce.db.profiles[profileName] then
        return false, L["Profile already exists"]
    end

    -- Create new profile and switch to it
    zBarButtonBGAce.db:SetProfile(profileName)
    zBarButtonBG.charSettings = zBarButtonBGAce.db.profile

    -- Update the action bars
    if zBarButtonBG.enabled then
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
    end

    return true, L["Profile created"]
end

-- Switch to an existing profile
function ProfileManager.switchProfile(profileName)
    if not profileName or not zBarButtonBGAce.db.profiles[profileName] then
        return false, L["Profile does not exist"]
    end

    -- Switch to profile
    zBarButtonBGAce.db:SetProfile(profileName)
    zBarButtonBG.charSettings = zBarButtonBGAce.db.profile

    -- Update the action bars
    if zBarButtonBG.enabled then
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
    end

    return true, L["Switched to profile"] .. ": " .. profileName
end

-- Copy profile data from one profile to another
function ProfileManager.copyProfile(sourceProfile, targetProfile)
    if not sourceProfile or not zBarButtonBGAce.db.profiles[sourceProfile] then
        return false, L["Source profile does not exist"]
    end

    if not targetProfile or targetProfile == "" then
        targetProfile = zBarButtonBGAce.db:GetCurrentProfile()
    end

    -- Copy profile data
    zBarButtonBGAce.db:CopyProfile(sourceProfile, targetProfile)
    zBarButtonBG.charSettings = zBarButtonBGAce.db.profile

    -- Update the action bars
    if zBarButtonBG.enabled then
        zBarButtonBG.removeActionBarBackgrounds()
        zBarButtonBG.createActionBarBackgrounds()
    end

    return true, L["Profile copied successfully"]
end

-- Delete a profile
function ProfileManager.deleteProfile(profileName)
    if not profileName or profileName == "Default" then
        return false, L["Cannot delete Default profile"]
    end

    if not zBarButtonBGAce.db.profiles[profileName] then
        return false, L["Profile does not exist"]
    end

    if zBarButtonBGAce.db:GetCurrentProfile() == profileName then
        -- Switch to a safe profile before deleting
        -- Try to find an existing profile to switch to, preferring "Default"
        local targetProfile = "Default"
        if not zBarButtonBGAce.db.profiles["Default"] then
            -- If no Default profile exists, find any other existing profile
            for existingProfile, _ in pairs(zBarButtonBGAce.db.profiles) do
                if existingProfile ~= profileName then
                    targetProfile = existingProfile
                    break
                end
            end
        end

        zBarButtonBGAce.db:SetProfile(targetProfile)
        zBarButtonBG.charSettings = zBarButtonBGAce.db.profile

        -- Update the action bars
        if zBarButtonBG.enabled then
            zBarButtonBG.removeActionBarBackgrounds()
            zBarButtonBG.createActionBarBackgrounds()
        end
    end

    -- Delete the profile
    zBarButtonBGAce.db:DeleteProfile(profileName, true)

    return true, L["Profile deleted"]
end

-- Get list of all profiles
function ProfileManager.getProfileList()
    local profiles = { "Default" } -- Always include Default profile
    for name, _ in pairs(zBarButtonBGAce.db.profiles) do
        table.insert(profiles, name)
    end
    table.sort(profiles)
    return profiles
end
