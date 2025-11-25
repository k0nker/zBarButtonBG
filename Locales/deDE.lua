-- German Localization for zBarButtonBG
local L = LibStub("AceLocale-3.0"):NewLocale("zBarButtonBG", "deDE")

if not L then return end

-- ############################################################
L["General"] = "Allgemein"
L["Appearance"] = "Erscheinungsbild"
L["Backdrop"] = "Hintergrund"
L["Button Background"] = "Button-Hintergrund"
L["Border"] = "Rahmen"
L["Buttons"] = "Buttons"
L["Indicators"] = "Indikatoren"
L["Text Fields"] = "Textfelder"
L["Overlays"] = "Overlays"
L["Profiles"] = "Profile"
L["Profile"] = "Profil"
L["Macro Name"] = "Makroname"
L["Count/Charge"] = "Anzahl/Aufladung"
L["Keybind/Hotkey"] = "Tastenbelegung/Hotkey"

-- ############################################################
-- Common Actions & Interface
-- ############################################################
L["Enable addon"] = "Addon aktivieren"
L["Turn the addon on or off"] = "Addon ein- oder ausschalten"
L["Create"] = "Erstellen"
L["Cancel"] = "Abbrechen"
L["Create New Profile"] = "Neues Profil erstellen"
L["Create a new profile"] = "Ein neues Profil erstellen"
L["New Profile"] = "Neues Profil"
L["Current Profile"] = "Aktuelles Profil"
L["The currently active profile"] = "Das derzeit aktive Profil"
L["Choose Profile"] = "Profil wählen"
L["Select a profile for copy/delete operations"] = "Wähle ein Profil zum Kopieren/Löschen"
L["Copy Profile"] = "Profil kopieren"
L["Copy settings from the chosen profile to the current profile"] = "Einstellungen vom gewählten Profil zum aktuellen Profil kopieren"
L["Modify Profiles"] = "Profile bearbeiten"

-- ############################################################
-- Profile Management Messages
-- ############################################################
L["Profile Name"] = "Profilname"
L["Enter a name for the new profile"] = "Gib einen Namen für das neue Profil ein"
L["Profile created"] = "Profil erstellt"
L["Profile deleted"] = "Profil gelöscht"
L["Enter a profile name and press Enter to create it"] = "Gib einen Profilnamen ein und drücke Enter zum Erstellen"
L["Switched to profile"] = "Gewechselt zu Profil"
L["Settings copied from"] = "Einstellungen kopiert von"
L["Current profile reset to defaults!"] = "Aktuelles Profil auf Standardwerte zurückgesetzt!"
L["Use Combat Profile"] = "Kampfprofil verwenden"
L["Combat Profile"] = "Kampfprofil"
L["Profile to replace all bars when in combat"] = "Profil zum Ersetzen aller Leisten im Kampf"
L["Enabled"] = "Aktiviert"
L["Disabled"] = "Deaktiviert"
L["Error"] = "Fehler"
L["Profile name cannot be empty"] = "Profilname darf nicht leer sein"
L["Profile already exists"] = "Profil existiert bereits"
L["Profile created successfully"] = "Profil erfolgreich erstellt"
L["Profile deleted successfully"] = "Profil erfolgreich gelöscht"
L["Profile copied successfully"] = "Profil erfolgreich kopiert"
L["Profile does not exist"] = "Profil existiert nicht"
L["Source profile does not exist"] = "Quellprofil existiert nicht"
L["Cannot delete Default profile"] = "Standardprofil kann nicht gelöscht werden"

-- ############################################################
-- Profile Import/Export
-- ############################################################
L["Export Profile"] = "Profil exportieren"
L["Export current profile settings as a string"] = "Aktuelle Profileinstellungen als String exportieren"
L["Import Profile"] = "Profil importieren"
L["Import profile settings from an export string"] = "Profileinstellungen aus einem Export-String importieren"
L["Invalid export string format"] = "Ungültiges Export-String-Format"
L["Failed to decode export string"] = "Fehler beim Dekodieren des Export-Strings"
L["Invalid export string - not a valid profile"] = "Ungültiger Export-String - kein gültiges Profil"
L["Export string copied to clipboard!"] = "Export-String in Zwischenablage kopiert!"
L["Invalid export string"] = "Ungültiger Export-String"
L["Please paste an export string first"] = "Bitte zuerst einen Export-String einfügen"
L["Create Profile from Import"] = "Profil aus Import erstellen"
L["Profile imported"] = "Profil importiert"

-- ############################################################
-- Reset Operations & Confirmations
-- ############################################################
L["Reset Profile"] = "Profil zurücksetzen"
L["Reset current profile to defaults"] = "Aktuelles Profil auf Standardwerte zurücksetzen"
L["Reset Button Settings"] = "Button-Einstellungen zurücksetzen"
L["Reset all button-related settings to default values"] = "Alle Button-bezogenen Einstellungen auf Standardwerte zurücksetzen"
L["Reset Indicator Settings"] = "Indikator-Einstellungen zurücksetzen"
L["Reset all indicator-related settings to default values"] = "Alle Indikator-bezogenen Einstellungen auf Standardwerte zurücksetzen"
L["Reset Macro Settings"] = "Makro-Einstellungen zurücksetzen"
L["Reset macro name text settings to default values"] = "Makroname-Texteinstellungen auf Standardwerte zurücksetzen"
L["Reset Count Settings"] = "Anzahl-Einstellungen zurücksetzen"
L["Reset count/charge text settings to default values"] = "Anzahl/Aufladung-Texteinstellungen auf Standardwerte zurücksetzen"
L["Reset Keybind Settings"] = "Tastenbelegungs-Einstellungen zurücksetzen"
L["Reset keybind/hotkey text settings to default values"] = "Tastenbelegungs/Hotkey-Texteinstellungen auf Standardwerte zurücksetzen"

-- Reset Status Messages
L["Button settings reset to defaults!"] = "Button-Einstellungen auf Standardwerte zurückgesetzt!"
L["Indicator settings reset to defaults!"] = "Indikator-Einstellungen auf Standardwerte zurückgesetzt!"
L["Macro text settings reset to defaults!"] = "Makrotext-Einstellungen auf Standardwerte zurückgesetzt!"
L["Count text settings reset to defaults!"] = "Anzahltext-Einstellungen auf Standardwerte zurückgesetzt!"
L["Keybind text settings reset to defaults!"] = "Tastenbelegungstext-Einstellungen auf Standardwerte zurückgesetzt!"

-- ############################################################
-- Confirmation Dialogs
-- ############################################################
L["Are you sure you want to delete the profile"] = "Bist du sicher, dass du das Profil löschen möchtest"
L["This action cannot be undone!"] = "Diese Aktion kann nicht rückgängig gemacht werden!"
L["This will overwrite all current settings!"] = "Dies wird alle aktuellen Einstellungen überschreiben!"
L["Copy settings from"] = "Einstellungen kopieren von"

-- Multi-line confirmations
L["Are you sure you want to reset all button settings to default values?\n\nThis will reset button shape, backdrop, slot background, and border settings.\n\nThis action cannot be undone!"] = "Bist du sicher, dass du alle Button-Einstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Button-Form, Hintergrund, Slot-Hintergrund und Rahmen-Einstellungen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all indicator settings to default values?\n\nThis will reset range indicator, cooldown fade, and spell alert color settings.\n\nThis action cannot be undone!"] = "Bist du sicher, dass du alle Indikator-Einstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Reichweiten-Indikator, Cooldown-Verblassung und Zauber-Alarm-Farben zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all macro text settings to default values?\n\nThis will reset font, size, color, positioning, and justification settings for macro names.\n\nThis action cannot be undone!"] = "Bist du sicher, dass du alle Makrotext-Einstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Schriftart, Größe, Farbe, Positionierung und Ausrichtung für Makronamen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all count/charge text settings to default values?\n\nThis will reset font, size, color, and positioning settings for count/charge numbers.\n\nThis action cannot be undone!"] = "Bist du sicher, dass du alle Anzahl/Aufladung-Texteinstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Schriftart, Größe, Farbe und Positionierung für Anzahl/Aufladung-Zahlen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all keybind/hotkey text settings to default values?\n\nThis will reset font, size, color, and positioning settings for keybind/hotkey text.\n\nThis action cannot be undone!"] = "Bist du sicher, dass du alle Tastenbelegungs/Hotkey-Texteinstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Schriftart, Größe, Farbe und Positionierung für Tastenbelegungs/Hotkey-Text zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"

-- ############################################################
-- Class & Color System (WoW Character Classes)
-- ############################################################
L["Use Class Color"] = "Klassenfarbe verwenden"
L["Use your class color"] = "Deine Klassenfarbe verwenden"
L["Color"] = "Farbe"
L["Backdrop Color"] = "Hintergrundfarbe"
L["Border Color"] = "Rahmenfarbe"
L["Button Background Color"] = "Button-Hintergrundfarbe"
L["Out of Range Color"] = "Außer Reichweite Farbe"
L["Cooldown Color"] = "Cooldown-Farbe"
L["Macro Name Color"] = "Makroname-Farbe"
L["Count Color"] = "Anzahl-Farbe"
L["Keybind Text Color"] = "Tastenbelegungstext-Farbe"

-- Color descriptions
L["Color of the outer backdrop frame"] = "Farbe des äußeren Hintergrundrahmens"
L["Color of the button slot background"] = "Farbe des Button-Slot-Hintergrunds"
L["Color of the button border"] = "Farbe des Button-Rahmens"
L["Color of the out of range indicator"] = "Farbe des Außer-Reichweite-Indikators"
L["Color of the cooldown overlay"] = "Farbe des Cooldown-Overlays"
L["Color of the macro name text"] = "Farbe des Makroname-Textes"
L["Color of the count/charge text"] = "Farbe des Anzahl/Aufladung-Textes"
L["Color of the keybind/hotkey text"] = "Farbe des Tastenbelegungs/Hotkey-Textes"

-- ############################################################
L["Size"] = "Größe"
L["Width"] = "Breite"
L["Height"] = "Höhe"
-- Icon Padding Override
L["Override Icon Padding"] = "Icon-Abstand überschreiben"
L["Allow icon padding to be set below Blizzard's minimum (default: off)."] = "Erlaube Icon-Abstand unter Blizzards Minimum zu setzen (Standard: aus)."
L["Icon Padding Value"] = "Icon-Abstandswert"
L["Set icon padding (0-20). Only applies if override is enabled."] = "Icon-Abstand einstellen (0-20). Gilt nur wenn Überschreibung aktiviert ist."
L["Top Size"] = "Obere Größe"
L["Bottom Size"] = "Untere Größe"
L["Left Size"] = "Linke Größe"
L["Right Size"] = "Rechte Größe"

-- Size descriptions
L["How far the backdrop extends above the button (in pixels)"] = "Wie weit der Hintergrund über dem Button erstreckt (in Pixeln)"
L["How far the backdrop extends below the button (in pixels)"] = "Wie weit der Hintergrund unter dem Button erstreckt (in Pixeln)"
L["How far the backdrop extends to the left of the button (in pixels)"] = "Wie weit der Hintergrund links vom Button erstreckt (in Pixeln)"
L["How far the backdrop extends to the right of the button (in pixels)"] = "Wie weit der Hintergrund rechts vom Button erstreckt (in Pixeln)"

-- ############################################################
-- Font System
-- ############################################################
L["Font family"] = "Schriftart"
L["Font style flags"] = "Schriftstil-Flags"
L["Font Size"] = "Schriftgröße"
L["Font Flags"] = "Schrift-Flags"
L["None"] = "Keine"
L["Outline"] = "Umriss"
L["Thick Outline"] = "Dicker Umriss"
L["Monochrome"] = "Monochrom"

-- Font family descriptions
L["Font family for macro names"] = "Schriftart für Makronamen"
L["Font family for count/charge numbers"] = "Schriftart für Anzahl/Aufladung-Zahlen"
L["Font family for keybind/hotkey text"] = "Schriftart für Tastenbelegungs/Hotkey-Text"

-- Font style descriptions
L["Font style flags for macro names"] = "Schriftstil-Flags für Makronamen"
L["Font style flags for count/charge numbers"] = "Schriftstil-Flags für Anzahl/Aufladung-Zahlen"
L["Font style flags for keybind/hotkey text"] = "Schriftstil-Flags für Tastenbelegungs/Hotkey-Text"

-- Size descriptions
L["Size of the macro name text"] = "Größe des Makroname-Textes"
L["Size of the count/charge text"] = "Größe des Anzahl/Aufladung-Textes"
L["Size of the keybind/hotkey text"] = "Größe des Tastenbelegungs/Hotkey-Textes"

-- ############################################################
-- Specific Font Controls
-- ############################################################
L["Macro Name Font"] = "Makroname-Schriftart"
L["Count Font"] = "Anzahl-Schriftart"
L["Count Font Size"] = "Anzahl-Schriftgröße"
L["Count Font Style"] = "Anzahl-Schriftstil"
L["Keybind Font"] = "Tastenbelegungs-Schriftart"
L["Keybind Font Size"] = "Tastenbelegungs-Schriftgröße"
L["Keybind Font Style"] = "Tastenbelegungs-Schriftstil"

-- ############################################################
-- Text Alignment & Position
-- ############################################################
L["Left"] = "Links"
L["Center"] = "Mitte"
L["Right"] = "Rechts"
L["Top"] = "Oben"
L["Bottom"] = "Unten"
L["Macro Text Justification"] = "Makrotext-Ausrichtung"
L["Text alignment for macro names"] = "Textausrichtung für Makronamen"
L["Macro Text Position"] = "Makrotext-Position"
L["Vertical position of macro text within the text frame"] = "Vertikale Position des Makrotextes im Textrahmen"

-- ############################################################
-- Dimensional Controls
-- ############################################################
L["Macro Name Width"] = "Makroname-Breite"
L["Macro Name Height"] = "Makroname-Höhe"
L["Count Width"] = "Anzahl-Breite"
L["Count Height"] = "Anzahl-Höhe"
L["Keybind Width"] = "Tastenbelegungs-Breite"
L["Keybind Height"] = "Tastenbelegungs-Höhe"

-- Dimension descriptions
L["Width of the macro name text frame"] = "Breite des Makroname-Textrahmens"
L["Height of the macro name text frame"] = "Höhe des Makroname-Textrahmens"
L["Width of the count text frame"] = "Breite des Anzahl-Textrahmens"
L["Height of the count text frame"] = "Höhe des Anzahl-Textrahmens"
L["Width of the keybind text frame"] = "Breite des Tastenbelegungs-Textrahmens"
L["Height of the keybind text frame"] = "Höhe des Tastenbelegungs-Textrahmens"

-- ############################################################
-- Offset Controls
-- ############################################################
L["Macro Name X Offset"] = "Makroname X-Versatz"
L["Macro Name Y Offset"] = "Makroname Y-Versatz"
L["Count X Offset"] = "Anzahl X-Versatz"
L["Count Y Offset"] = "Anzahl Y-Versatz"
L["Keybind X Offset"] = "Tastenbelegungs X-Versatz"
L["Keybind Y Offset"] = "Tastenbelegungs Y-Versatz"

-- Offset descriptions
L["Horizontal positioning offset for macro name text"] = "Horizontaler Positions-Versatz für Makroname-Text"
L["Vertical positioning offset for macro name text"] = "Vertikaler Positions-Versatz für Makroname-Text"
L["Horizontal positioning offset for count/charge text"] = "Horizontaler Positions-Versatz für Anzahl/Aufladung-Text"
L["Vertical positioning offset for count/charge text"] = "Vertikaler Positions-Versatz für Anzahl/Aufladung-Text"
L["Horizontal positioning offset for keybind/hotkey text"] = "Horizontaler Positions-Versatz für Tastenbelegungs/Hotkey-Text"
L["Vertical positioning offset for keybind/hotkey text"] = "Vertikaler Positions-Versatz für Tastenbelegungs/Hotkey-Text"

-- ############################################################
-- Appearance Controls
-- ############################################################
L["Button Style"] = "Button-Stil"
L["Choose button style"] = "Button-Stil wählen"
L["Rounded"] = "Abgerundet"
L["Square"] = "Quadratisch"
L["Circle"] = "Kreis"
L["Octagon"] = "Achteck"
L["Octagon Flipped"] = "Achteck Gedreht"
L["Hexagon"] = "Sechseck"
L["Rhomboid"] = "Rhombus"
L["Rhomboid Flipped"] = "Rhombus Gedreht"
L["Rhomboid Tall"] = "Rhombus Hoch"
L["Rhomboid Tall Flipped"] = "Rhombus Hoch Gedreht"
L["Hexagon Flipped"] = "Sechseck Gedreht"
L["Sharp square button style"] = "Scharfer quadratischer Button-Stil"
L["Circle button style"] = "Kreis Button-Stil"
L["Rounded button style"] = "Abgerundeter Button-Stil"
L["Octagon button style"] = "Achteck Button-Stil"
L["Octagon flipped button style"] = "Achteck gedrehter Button-Stil"
L["Hexagon button style"] = "Sechseck Button-Stil"
L["Hexagon flipped button style"] = "Sechseck gedrehter Button-Stil"
L["Rhomboid button style"] = "Rhombus Button-Stil"
L["Rhomboid flipped button style"] = "Rhombus gedrehter Button-Stil"
L["Rhomboid tall button style"] = "Rhombus hoher Button-Stil"
L["Rhomboid tall flipped button style"] = "Rhombus hoher gedrehter Button-Stil"
L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"] = "Bist du sicher, dass du alle Einstellungen im aktuellen Profil auf Standardwerte zurücksetzen möchtest?\n\nDies setzt alle Erscheinungsbild-, Hintergrund-, Text- und Indikator-Einstellungen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Show Backdrop"] = "Hintergrund anzeigen"
L["Mask Backdrop"] = "Hintergrund maskieren"
L["Mask outer background frame"] = "Äußeren Hintergrundrahmen maskieren"
L["Show outer background frame"] = "Äußeren Hintergrundrahmen anzeigen"
L["Show Border"] = "Rahmen anzeigen"
L["Show border around buttons"] = "Rahmen um Buttons anzeigen"
L["Show Button Background"] = "Button-Hintergrund anzeigen"
L["Show the button background fill behind each button icon"] = "Button-Hintergrundfüllung hinter jedem Button-Icon anzeigen"

-- ############################################################
-- Overlay System
-- ############################################################
L["Out of Range Overlay"] = "Außer-Reichweite-Overlay"
L["Show red overlay when abilities are out of range"] = "Rotes Overlay anzeigen, wenn Fähigkeiten außer Reichweite sind"
L["Cooldown Overlay"] = "Cooldown-Overlay"
L["Show dark overlay during ability cooldowns"] = "Dunkles Overlay während Fähigkeiten-Cooldowns anzeigen"
L["Spell Alerts"] = "Zauber-Alarme"
L["Show custom spell alert indicators"] = "Benutzerdefinierte Zauber-Alarm-Indikatoren anzeigen"
L["Proc Alt Glow Color"] = "Proc-Alt-Leuchten-Farbe"
L["Color of spell proc alerts"] = "Farbe der Zauber-Proc-Alarme"
L["Suggested Action Color"] = "Vorgeschlagene Aktion Farbe"
L["Color of suggested action indicators"] = "Farbe der vorgeschlagenen Aktions-Indikatoren"
L["Equipment Outline"] = "Ausrüstungs-Umriss"
L["Color of the equipment item border outline"] = "Farbe des Ausrüstungsgegenstand-Rahmen-Umrisses"

-- ############################################################
-- Status Messages
-- ############################################################
L["Action bar backgrounds enabled"] = "Aktionsleisten-Hintergründe aktiviert"
L["Action bar backgrounds disabled"] = "Aktionsleisten-Hintergründe deaktiviert"

-- ############################################################
-- Validation Messages
-- ############################################################
L["Value must be a number"] = "Wert muss eine Zahl sein"
L["Value must be between -50 and 50"] = "Wert muss zwischen -50 und 50 liegen"

-- ############################################################
-- Bar Settings
-- ############################################################
L["Action Bars"] = "Aktionsleisten"
L["Here you can select action bars to have their own profiles applied independent of the currently selected profile."] = "Hier kannst du Aktionsleisten auswählen, um ihre eigenen Profile unabhängig vom aktuell ausgewählten Profil anzuwenden."
L["Main Action Bar"] = "Haupt-Aktionsleiste"
L["Bottom Left Bar"] = "Untere linke Leiste"
L["Bottom Right Bar"] = "Untere rechte Leiste"
L["Right Bar 1"] = "Rechte Leiste 1"
L["Right Bar 2"] = "Rechte Leiste 2"
L["Bar 5"] = "Leiste 5"
L["Bar 6"] = "Leiste 6"
L["Bar 7"] = "Leiste 7"
L["Pet Action Bar"] = "Begleiter-Aktionsleiste"
L["Stance Bar"] = "Haltungs-Leiste"
L["Use Different Profile"] = "Anderes Profil verwenden"
L["Select which profile to use"] = "Wähle welches Profil verwendet werden soll"
