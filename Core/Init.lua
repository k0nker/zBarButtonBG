-- Ace addon initialization for zBarButtonBG

---@class addonTableZBarButtonBG
local addonTable = select(2, ...)

addonTable.Core.Init = {}
local Init = addonTable.Core.Init

-- Initialize the Ace addon
function Init.setupAce()
	-- Create Ace addon with defaults
	zBarButtonBGAce = LibStub("AceAddon-3.0"):NewAddon("zBarButtonBG")

	-- Initialize AceDB with profile support
	zBarButtonBGAce.db = LibStub("AceDB-3.0"):New("zBarButtonBGDB", addonTable.Core.Defaults, true)

	-- Make Ace the single source of truth - native system points to Ace profile
	zBarButtonBG.charSettings = zBarButtonBGAce.db.profile
end

-- Called when addon first initializes
function Init.onInitialize()
	-- AceDB automatically handles profile creation and management
	-- No need to force creation of "Default" profile - let AceDB handle it naturally
end

-- Register slash commands
function Init.registerCommands()
	SLASH_ZBBGDEBUG1 = "/zbbg"
	SlashCmdList["ZBBGDEBUG"] = function(msg)
		if msg == "debug" then
			zBarButtonBG._debug = not zBarButtonBG._debug
			zBarButtonBG.print("Debug mode " .. (zBarButtonBG._debug and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
		elseif msg == "hooks" then
			zBarButtonBG.print("Hook status: " ..
				(zBarButtonBG.hooksInstalled and "|cFF00FF00installed|r" or "|cFFFF0000not installed|r"))
		elseif msg == "hookstats" then
			zBarButtonBG.printHookStats()
		else
			zBarButtonBG.print("Available commands: /zbbg debug, /zbbg hooks, /zbbg hookstats")
		end
	end

	-- Add /zbg command for opening options
	SLASH_ZBARBUTTONBGOPTIONS1 = "/zbg"
	SlashCmdList["ZBARBUTTONBGOPTIONS"] = function(msg)
		if msg == "debug" then
			zBarButtonBG._debugGCD = not zBarButtonBG._debugGCD
			zBarButtonBG.print("GCD debug " .. (zBarButtonBG._debugGCD and "|cFF00FF00enabled|r" or "|cFFFF0000disabled|r"))
		else
			-- Open the options panel using Ace Config Dialog
			LibStub("AceConfigDialog-3.0"):Open("zBarButtonBG")
		end
	end
end
