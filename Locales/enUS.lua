-- English Localization for zBarButtonBG (Base locale)
local L = LibStub("AceLocale-3.0"):NewLocale("zBarButtonBG", "enUS", true)
if not L then return end

-- ############################################################
L["General"] = "General"
L["Appearance"] = "Appearance"
L["Backdrop"] = "Backdrop"
L["Button Background"] = "Button Background"
L["Border"] = "Border"
L["Buttons"] = "Buttons"
L["Indicators"] = "Indicators"
L["Text Fields"] = "Text Fields"
L["Overlays"] = "Overlays"
L["Profiles"] = "Profiles"
L["Profile"] = "Profile"
L["Macro Name"] = "Macro Name"
L["Count/Charge"] = "Count/Charge"
L["Keybind/Hotkey"] = "Keybind/Hotkey"

-- ############################################################
-- Common Actions & Interface
-- ############################################################
L["Enable addon"] = "Enable addon"
L["Turn the addon on or off"] = "Turn the addon on or off"
L["Create"] = "Create"
L["Cancel"] = "Cancel"
L["Create New Profile"] = "Create New Profile"
L["Create a new profile"] = "Create a new profile"
L["New Profile"] = "New Profile"
L["Current Profile"] = "Current Profile"
L["The currently active profile"] = "The currently active profile"
L["Choose Profile"] = "Choose Profile"
L["Select a profile for copy/delete operations"] = "Select a profile for copy/delete operations"
L["Copy Profile"] = "Copy Profile"
L["Copy settings from the chosen profile to the current profile"] = "Copy settings from the chosen profile to the current profile"
L["Modify Profiles"] = "Modify Profiles"

-- ############################################################
-- Profile Management Messages
-- ############################################################
L["Profile Name:"] = "Profile Name:"
L["Enter a name for the new profile"] = "Enter a name for the new profile"
L["Profile created: "] = "Profile created: "
L["Profile deleted: "] = "Profile deleted: "
L["Enter a profile name and press Enter to create it"] = "Enter a profile name and press Enter to create it"
L["Switched to profile: "] = "Switched to profile: "
L["Settings copied from: "] = "Settings copied from: "
L["Current profile reset to defaults!"] = "Current profile reset to defaults!"
L["Use Combat Profile"] = "Use Combat Profile"
L["Combat Profile"] = "Combat Profile"
L["Profile to replace all bars when in combat"] = "Profile to replace all bars when in combat"

-- ############################################################
-- Profile Import/Export
-- ############################################################
L["Export Profile"] = "Export Profile"
L["Export current profile settings as a string"] = "Export current profile settings as a string"
L["Import Profile"] = "Import Profile"
L["Import profile settings from an export string"] = "Import profile settings from an export string"
L["Invalid export string format"] = "Invalid export string format"
L["Failed to decode export string"] = "Failed to decode export string"
L["Invalid export string - not a valid profile"] = "Invalid export string - not a valid profile"

-- ############################################################
-- Reset Operations & Confirmations
-- ############################################################
L["Reset Profile"] = "Reset Profile"
L["Reset current profile to defaults"] = "Reset current profile to defaults"
L["Reset Button Settings"] = "Reset Button Settings"
L["Reset all button-related settings to default values"] = "Reset all button-related settings to default values"
L["Reset Indicator Settings"] = "Reset Indicator Settings"
L["Reset all indicator-related settings to default values"] = "Reset all indicator-related settings to default values"
L["Reset Macro Settings"] = "Reset Macro Settings"
L["Reset macro name text settings to default values"] = "Reset macro name text settings to default values"
L["Reset Count Settings"] = "Reset Count Settings"
L["Reset count/charge text settings to default values"] = "Reset count/charge text settings to default values"
L["Reset Keybind Settings"] = "Reset Keybind Settings"
L["Reset keybind/hotkey text settings to default values"] = "Reset keybind/hotkey text settings to default values"

-- Reset Status Messages
L["Button settings reset to defaults!"] = "Button settings reset to defaults!"
L["Indicator settings reset to defaults!"] = "Indicator settings reset to defaults!"
L["Macro text settings reset to defaults!"] = "Macro text settings reset to defaults!"
L["Count text settings reset to defaults!"] = "Count text settings reset to defaults!"
L["Keybind text settings reset to defaults!"] = "Keybind text settings reset to defaults!"

-- ############################################################
-- Confirmation Dialogs
-- ############################################################
L["Are you sure you want to delete the profile: "] = "Are you sure you want to delete the profile: "
L["This action cannot be undone!"] = "This action cannot be undone!"
L["This will overwrite all current settings!"] = "This will overwrite all current settings!"
L["Copy settings from: "] = "Copy settings from: "

-- Multi-line confirmations
L["Are you sure you want to reset all button settings to default values?\n\nThis will reset button shape, backdrop, slot background, and border settings.\n\nThis action cannot be undone!"] = "Are you sure you want to reset all button settings to default values?\n\nThis will reset button shape, backdrop, slot background, and border settings.\n\nThis action cannot be undone!"
L["Are you sure you want to reset all indicator settings to default values?\n\nThis will reset range indicator, cooldown fade, and spell alert color settings.\n\nThis action cannot be undone!"] = "Are you sure you want to reset all indicator settings to default values?\n\nThis will reset range indicator, cooldown fade, and spell alert color settings.\n\nThis action cannot be undone!"
L["Are you sure you want to reset all macro text settings to default values?\n\nThis will reset font, size, color, positioning, and justification settings for macro names.\n\nThis action cannot be undone!"] = "Are you sure you want to reset all macro text settings to default values?\n\nThis will reset font, size, color, positioning, and justification settings for macro names.\n\nThis action cannot be undone!"
L["Are you sure you want to reset all count/charge text settings to default values?\n\nThis will reset font, size, color, and positioning settings for count/charge numbers.\n\nThis action cannot be undone!"] = "Are you sure you want to reset all count/charge text settings to default values?\n\nThis will reset font, size, color, and positioning settings for count/charge numbers.\n\nThis action cannot be undone!"
L["Are you sure you want to reset all keybind/hotkey text settings to default values?\n\nThis will reset font, size, color, and positioning settings for keybind/hotkey text.\n\nThis action cannot be undone!"] = "Are you sure you want to reset all keybind/hotkey text settings to default values?\n\nThis will reset font, size, color, and positioning settings for keybind/hotkey text.\n\nThis action cannot be undone!"

-- ############################################################
-- Class & Color System (WoW Character Classes)
-- ############################################################
L["Use Class Color"] = "Use Class Color"
L["Use your class color"] = "Use your class color"
L["Color"] = "Color"
L["Backdrop Color"] = "Backdrop Color"
L["Border Color"] = "Border Color"
L["Button Background Color"] = "Button Background Color"
L["Out of Range Color"] = "Out of Range Color"
L["Cooldown Color"] = "Cooldown Color"
L["Macro Name Color"] = "Macro Name Color"
L["Count Color"] = "Count Color"
L["Keybind Text Color"] = "Keybind Text Color"

-- Color descriptions
L["Color of the outer backdrop frame"] = "Color of the outer backdrop frame"
L["Color of the button slot background"] = "Color of the button slot background"
L["Color of the button border"] = "Color of the button border"
L["Color of the out of range indicator"] = "Color of the out of range indicator"
L["Color of the cooldown overlay"] = "Color of the cooldown overlay"
L["Color of the macro name text"] = "Color of the macro name text"
L["Color of the count/charge text"] = "Color of the count/charge text"
L["Color of the keybind/hotkey text"] = "Color of the keybind/hotkey text"

-- ############################################################
L["Size"] = "Size"
L["Width"] = "Width"
L["Height"] = "Height"
-- Icon Padding Override
L["Override Icon Padding"] = "Override Icon Padding"
L["Allow icon padding to be set below Blizzard's minimum (default: off)."] = "Allow icon padding to be set below Blizzard's minimum (default: off)."
L["Icon Padding Value"] = "Icon Padding Value"
L["Set icon padding (0-20). Only applies if override is enabled."] = "Set icon padding (0-20). Only applies if override is enabled."
L["Top Size"] = "Top Size"
L["Bottom Size"] = "Bottom Size"
L["Left Size"] = "Left Size"
L["Right Size"] = "Right Size"

-- Size descriptions
L["How far the backdrop extends above the button (in pixels)"] = "How far the backdrop extends above the button (in pixels)"
L["How far the backdrop extends below the button (in pixels)"] = "How far the backdrop extends below the button (in pixels)"
L["How far the backdrop extends to the left of the button (in pixels)"] = "How far the backdrop extends to the left of the button (in pixels)"
L["How far the backdrop extends to the right of the button (in pixels)"] = "How far the backdrop extends to the right of the button (in pixels)"

-- ############################################################
-- Font System
-- ############################################################
L["Font family"] = "Font family"
L["Font style flags"] = "Font style flags"
L["Font Size"] = "Font Size"
L["Font Flags"] = "Font Flags"
L["None"] = "None"
L["Outline"] = "Outline"
L["Thick Outline"] = "Thick Outline"
L["Monochrome"] = "Monochrome"

-- Font family descriptions
L["Font family for macro names"] = "Font family for macro names"
L["Font family for count/charge numbers"] = "Font family for count/charge numbers"
L["Font family for keybind/hotkey text"] = "Font family for keybind/hotkey text"

-- Font style descriptions
L["Font style flags for macro names"] = "Font style flags for macro names"
L["Font style flags for count/charge numbers"] = "Font style flags for count/charge numbers"
L["Font style flags for keybind/hotkey text"] = "Font style flags for keybind/hotkey text"

-- Size descriptions
L["Size of the macro name text"] = "Size of the macro name text"
L["Size of the count/charge text"] = "Size of the count/charge text"
L["Size of the keybind/hotkey text"] = "Size of the keybind/hotkey text"

-- ############################################################
-- Specific Font Controls
-- ############################################################
L["Macro Name Font"] = "Macro Name Font"
L["Count Font"] = "Count Font"
L["Count Font Size"] = "Count Font Size"
L["Count Font Style"] = "Count Font Style"
L["Keybind Font"] = "Keybind Font"
L["Keybind Font Size"] = "Keybind Font Size"
L["Keybind Font Style"] = "Keybind Font Style"

-- ############################################################
-- Text Alignment & Position
-- ############################################################
L["Left"] = "Left"
L["Center"] = "Center"
L["Right"] = "Right"
L["Top"] = "Top"
L["Bottom"] = "Bottom"
L["Macro Text Justification"] = "Macro Text Justification"
L["Text alignment for macro names"] = "Text alignment for macro names"
L["Macro Text Position"] = "Macro Text Position"
L["Vertical position of macro text within the text frame"] = "Vertical position of macro text within the text frame"

-- ############################################################
-- Dimensional Controls
-- ############################################################
L["Macro Name Width"] = "Macro Name Width"
L["Macro Name Height"] = "Macro Name Height"
L["Count Width"] = "Count Width"
L["Count Height"] = "Count Height"
L["Keybind Width"] = "Keybind Width"
L["Keybind Height"] = "Keybind Height"

-- Dimension descriptions
L["Width of the macro name text frame"] = "Width of the macro name text frame"
L["Height of the macro name text frame"] = "Height of the macro name text frame"
L["Width of the count text frame"] = "Width of the count text frame"
L["Height of the count text frame"] = "Height of the count text frame"
L["Width of the keybind text frame"] = "Width of the keybind text frame"
L["Height of the keybind text frame"] = "Height of the keybind text frame"

-- ############################################################
-- Offset Controls
-- ############################################################
L["Macro Name X Offset"] = "Macro Name X Offset"
L["Macro Name Y Offset"] = "Macro Name Y Offset"
L["Count X Offset"] = "Count X Offset"
L["Count Y Offset"] = "Count Y Offset"
L["Keybind X Offset"] = "Keybind X Offset"
L["Keybind Y Offset"] = "Keybind Y Offset"

-- Offset descriptions
L["Horizontal positioning offset for macro name text"] = "Horizontal positioning offset for macro name text"
L["Vertical positioning offset for macro name text"] = "Vertical positioning offset for macro name text"
L["Horizontal positioning offset for count/charge text"] = "Horizontal positioning offset for count/charge text"
L["Vertical positioning offset for count/charge text"] = "Vertical positioning offset for count/charge text"
L["Horizontal positioning offset for keybind/hotkey text"] = "Horizontal positioning offset for keybind/hotkey text"
L["Vertical positioning offset for keybind/hotkey text"] = "Vertical positioning offset for keybind/hotkey text"

-- ############################################################
-- Appearance Controls
-- ############################################################
L["Button Style"] = "Button Style"
L["Choose button style"] = "Choose button style"
L["Rounded"] = "Rounded"
L["Square"] = "Square"
L["Circle"] = "Circle"
L["Octagon"] = "Octagon"
L["Octagon Flipped"] = "Octagon Flipped"
L["Hexagon"] = "Hexagon"
L["Hexagon Flipped"] = "Hexagon Flipped"
L["Sharp square button style"] = "Sharp square button style"
L["Circle button style"] = "Circle button style"
L["Rounded button style"] = "Rounded button style"
L["Octagon button style"] = "Octagon button style"
L["Octagon flipped button style"] = "Octagon flipped button style"
L["Hexagon button style"] = "Hexagon button style"
L["Hexagon flipped button style"] = "Hexagon flipped button style"
L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"] = "Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"
L["Show Backdrop"] = "Show Backdrop"
L["Show outer background frame"] = "Show outer background frame"
L["Show Border"] = "Show Border"
L["Show border around buttons"] = "Show border around buttons"
L["Show Button Background"] = "Show Button Background"
L["Show the button background fill behind each button icon"] = "Show the button background fill behind each button icon"

-- ############################################################
-- Overlay System
-- ############################################################
L["Out of Range Overlay"] = "Out of Range Overlay"
L["Show red overlay when abilities are out of range"] = "Show red overlay when abilities are out of range"
L["Cooldown Overlay"] = "Cooldown Overlay"
L["Show dark overlay during ability cooldowns"] = "Show dark overlay during ability cooldowns"
L["Spell Alerts"] = "Spell Alerts"
L["Show custom spell alert indicators"] = "Show custom spell alert indicators"
L["Proc Alt Glow Color"] = "Proc Alt Glow Color"
L["Color of spell proc alerts"] = "Color of spell proc alerts"
L["Suggested Action Color"] = "Suggested Action Color"
L["Color of suggested action indicators"] = "Color of suggested action indicators"
L["Equipment Outline"] = "Equipment Outline"
L["Color of the equipment item border outline"] = "Color of the equipment item border outline"

-- ############################################################
-- Status Messages
-- ############################################################
L["Action bar backgrounds enabled"] = "Action bar backgrounds enabled"
L["Action bar backgrounds disabled"] = "Action bar backgrounds disabled"

-- ############################################################
-- Validation Messages
-- ############################################################
L["Value must be a number"] = "Value must be a number"
L["Value must be between -50 and 50"] = "Value must be between -50 and 50"

-- ############################################################
-- Bar Settings
-- ############################################################
L["Action Bars"] = "Action Bars"
L["Here you can select action bars to have their own profiles applied independent of the currently selected profile."] = "Here you can select action bars to have their own profiles applied independent of the currently selected profile."
L["Main Action Bar"] = "Main Action Bar"
L["Bottom Left Bar"] = "Bottom Left Bar"
L["Bottom Right Bar"] = "Bottom Right Bar"
L["Right Bar 1"] = "Right Bar 1"
L["Right Bar 2"] = "Right Bar 2"
L["Bar 5"] = "Bar 5"
L["Bar 6"] = "Bar 6"
L["Bar 7"] = "Bar 7"
L["Pet Action Bar"] = "Pet Action Bar"
L["Stance Bar"] = "Stance Bar"
L["Use Different Profile"] = "Use Different Profile"
L["Select which profile to use"] = "Select which profile to use"
