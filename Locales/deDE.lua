-- German Localization for zBarButtonBG
local L = LibStub("AceLocale-3.0"):NewLocale("zBarButtonBG", "deDE")
if not L then return end

-- ############################################################
-- Core Interface Sections
-- ############################################################
L["General"] = "Allgemein"
L["Appearance"] = "Aussehen"
L["Backdrop"] = "Hintergrund"
L["Button Background"] = "Schaltflächen-Hintergrund"
L["Border"] = "Rand"
L["Buttons"] = "Schaltflächen"
L["Indicators"] = "Indikatoren"
L["Text Fields"] = "Textfelder"
L["Overlays"] = "Überlagerungen"
L["Profiles"] = "Profile"
L["Macro Name"] = "Makroname"
L["Count/Charge"] = "Anzahl/Aufladung"
L["Keybind/Hotkey"] = "Tastenbelegung/Hotkey"

-- ############################################################
-- Common Actions & Interface
-- ############################################################
L["Enable addon"] = "Addon aktivieren"
L["Turn the addon on or off"] = "Aktiviert oder deaktiviert das Addon"
L["Create"] = "Erstellen"
L["Cancel"] = "Abbrechen"
L["Create New Profile"] = "Neues Profil erstellen"
L["Create a new profile"] = "Ein neues Profil erstellen"
L["New Profile"] = "Neues Profil"
L["Current Profile"] = "Aktuelles Profil"
L["The currently active profile"] = "Das derzeit aktive Profil"
L["Choose Profile"] = "Profil wählen"
L["Select a profile for copy/delete operations"] = "Wählen Sie ein Profil für Kopier-/Löschvorgänge"
L["Copy Profile"] = "Profil kopieren"
L["Copy settings from the chosen profile to the current profile"] = "Einstellungen vom gewählten Profil zum aktuellen Profil kopieren"
L["Modify Profiles"] = "Profile bearbeiten"

-- ############################################################
-- Profile Management Messages
-- ############################################################
L["Profile Name:"] = "Profilname:"
L["Enter a name for the new profile"] = "Geben Sie einen Namen für das neue Profil ein"
L["Profile created: "] = "Profil erstellt: "
L["Profile deleted: "] = "Profil gelöscht: "
L["Switched to profile: "] = "Zu Profil gewechselt: "
L["Settings copied from: "] = "Einstellungen kopiert von: "
L["Current profile reset to defaults!"] = "Aktuelles Profil auf Standardwerte zurückgesetzt!"

-- ############################################################
-- Reset Operations & Confirmations
-- ############################################################
L["Reset Profile"] = "Profil zurücksetzen"
L["Reset current profile to defaults"] = "Aktuelles Profil auf Standardwerte zurücksetzen"
L["Reset Button Settings"] = "Schaltflächen-Einstellungen zurücksetzen"
L["Reset all button-related settings to default values"] = "Alle schaltflächenbezogenen Einstellungen auf Standardwerte zurücksetzen"
L["Reset Indicator Settings"] = "Indikator-Einstellungen zurücksetzen"
L["Reset all indicator-related settings to default values"] = "Alle indikatorbezogenen Einstellungen auf Standardwerte zurücksetzen"
L["Reset Macro Settings"] = "Makro-Einstellungen zurücksetzen"
L["Reset macro name text settings to default values"] = "Makroname-Texteinstellungen auf Standardwerte zurücksetzen"
L["Reset Count Settings"] = "Anzahl-Einstellungen zurücksetzen"
L["Reset count/charge text settings to default values"] = "Anzahl-/Aufladungs-Texteinstellungen auf Standardwerte zurücksetzen"
L["Reset Keybind Settings"] = "Tastenbelegungs-Einstellungen zurücksetzen"
L["Reset keybind/hotkey text settings to default values"] = "Tastenbelegungs-/Hotkey-Texteinstellungen auf Standardwerte zurücksetzen"

-- Reset Status Messages
L["Button settings reset to defaults!"] = "Schaltflächen-Einstellungen auf Standard zurückgesetzt!"
L["Indicator settings reset to defaults!"] = "Indikator-Einstellungen auf Standard zurückgesetzt!"
L["Macro text settings reset to defaults!"] = "Makrotext-Einstellungen auf Standard zurückgesetzt!"
L["Count text settings reset to defaults!"] = "Anzahltext-Einstellungen auf Standard zurückgesetzt!"
L["Keybind text settings reset to defaults!"] = "Tastenbelegungstext-Einstellungen auf Standard zurückgesetzt!"

-- ############################################################
-- Confirmation Dialogs
-- ############################################################
L["Are you sure you want to delete the profile: "] = "Sind Sie sicher, dass Sie das Profil löschen möchten: "
L["This action cannot be undone!"] = "Diese Aktion kann nicht rückgängig gemacht werden!"
L["This will overwrite all current settings!"] = "Dies wird alle aktuellen Einstellungen überschreiben!"
L["Copy settings from: "] = "Einstellungen kopieren von: "

-- Multi-line confirmations
L["Are you sure you want to reset all button settings to default values?\n\nThis will reset button shape, backdrop, slot background, and border settings.\n\nThis action cannot be undone!"] = "Sind Sie sicher, dass Sie alle Schaltflächen-Einstellungen auf Standardwerte zurücksetzen möchten?\n\nDies setzt Schaltflächenform, Hintergrund, Slot-Hintergrund und Rand-Einstellungen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all indicator settings to default values?\n\nThis will reset range indicator and cooldown fade settings.\n\nThis action cannot be undone!"] = "Sind Sie sicher, dass Sie alle Indikator-Einstellungen auf Standardwerte zurücksetzen möchten?\n\nDies setzt Reichweiten-Indikator und Abklingzeit-Fade-Einstellungen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all macro text settings to default values?\n\nThis will reset font, size, color, positioning, and justification settings for macro names.\n\nThis action cannot be undone!"] = "Sind Sie sicher, dass Sie alle Makrotext-Einstellungen auf Standardwerte zurücksetzen möchten?\n\nDies setzt Schriftart, Größe, Farbe, Positionierung und Ausrichtungseinstellungen für Makronamen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all count/charge text settings to default values?\n\nThis will reset font, size, color, and positioning settings for count/charge numbers.\n\nThis action cannot be undone!"] = "Sind Sie sicher, dass Sie alle Anzahl-/Aufladungstext-Einstellungen auf Standardwerte zurücksetzen möchten?\n\nDies setzt Schriftart, Größe, Farbe und Positionierungseinstellungen für Anzahl-/Aufladungszahlen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all keybind/hotkey text settings to default values?\n\nThis will reset font, size, color, and positioning settings for keybind/hotkey text.\n\nThis action cannot be undone!"] = "Sind Sie sicher, dass Sie alle Tastenbelegungs-/Hotkey-Texteinstellungen auf Standardwerte zurücksetzen möchten?\n\nDies setzt Schriftart, Größe, Farbe und Positionierungseinstellungen für Tastenbelegungs-/Hotkey-Text zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"

-- ############################################################
-- Class & Color System (WoW Character Classes)
-- ############################################################
L["Use Class Color"] = "Klassenfarbe verwenden"
L["Use your class color"] = "Ihre Klassenfarbe verwenden"
L["Color"] = "Farbe"
L["Backdrop Color"] = "Hintergrundfarbe"
L["Border Color"] = "Randfarbe"
L["Button Background Color"] = "Schaltflächen-Hintergrundfarbe"
L["Out of Range Color"] = "Außer-Reichweite-Farbe"
L["Cooldown Color"] = "Abklingzeit-Farbe"
L["Macro Name Color"] = "Makroname-Farbe"
L["Count Color"] = "Anzahl-Farbe"
L["Keybind Text Color"] = "Tastenbelegungstext-Farbe"

-- Color descriptions
L["Color of the outer backdrop frame"] = "Farbe des äußeren Hintergrundrahmens"
L["Color of the button slot background"] = "Farbe des Schaltflächen-Slot-Hintergrunds"
L["Color of the button border"] = "Farbe des Schaltflächenrands"
L["Color of the out of range indicator"] = "Farbe des Außer-Reichweite-Indikators"
L["Color of the cooldown overlay"] = "Farbe der Abklingzeit-Überlagerung"
L["Color of the macro name text"] = "Farbe des Makroname-Texts"
L["Color of the count/charge text"] = "Farbe des Anzahl-/Aufladungstexts"
L["Color of the keybind/hotkey text"] = "Farbe des Tastenbelegungs-/Hotkey-Texts"

-- ############################################################
-- Size & Positioning
-- ############################################################
L["Size"] = "Größe"
L["Width"] = "Breite"
L["Height"] = "Höhe"
-- Icon Padding Override
L["Override Icon Padding"] = "Schaltflächen-Abstand überschreiben"
L["Allow icon padding to be set below Blizzard's minimum (default: off)."] = "Ermöglicht das Festlegen des Schaltflächenabstands unter dem Minimum von Blizzard (Standard: aus)."
L["Icon Padding Value"] = "Wert des Schaltflächenabstands"
L["Set icon padding (0-20). Only applies if override is enabled."] = "Legen Sie den Schaltflächenabstand fest (0-20). Gilt nur, wenn die Außerkraftsetzung aktiviert ist."
L["Top Size"] = "Obere Größe"
L["Bottom Size"] = "Untere Größe"
L["Left Size"] = "Linke Größe"
L["Right Size"] = "Rechte Größe"

-- Size descriptions
L["How far the backdrop extends above the button (in pixels)"] = "Wie weit sich der Hintergrund über die Schaltfläche erstreckt (in Pixeln)"
L["How far the backdrop extends below the button (in pixels)"] = "Wie weit sich der Hintergrund unter die Schaltfläche erstreckt (in Pixeln)"
L["How far the backdrop extends to the left of the button (in pixels)"] = "Wie weit sich der Hintergrund links von der Schaltfläche erstreckt (in Pixeln)"
L["How far the backdrop extends to the right of the button (in pixels)"] = "Wie weit sich der Hintergrund rechts von der Schaltfläche erstreckt (in Pixeln)"

-- ############################################################
-- Font System
-- ############################################################
L["Font family"] = "Schriftfamilie"
L["Font style flags"] = "Schriftstil-Flags"
L["Font Size"] = "Schriftgröße"
L["Font Flags"] = "Schrift-Flags"
L["None"] = "Keine"
L["Outline"] = "Umriss"
L["Thick Outline"] = "Dicker Umriss"
L["Monochrome"] = "Monochrom"

-- Font family descriptions
L["Font family for macro names"] = "Schriftfamilie für Makronamen"
L["Font family for count/charge numbers"] = "Schriftfamilie für Anzahl-/Aufladungszahlen"
L["Font family for keybind/hotkey text"] = "Schriftfamilie für Tastenbelegungs-/Hotkey-Text"

-- Font style descriptions
L["Font style flags for macro names"] = "Schriftstil-Flags für Makronamen"
L["Font style flags for count/charge numbers"] = "Schriftstil-Flags für Anzahl-/Aufladungszahlen"
L["Font style flags for keybind/hotkey text"] = "Schriftstil-Flags für Tastenbelegungs-/Hotkey-Text"

-- Size descriptions
L["Size of the macro name text"] = "Größe des Makroname-Texts"
L["Size of the count/charge text"] = "Größe des Anzahl-/Aufladungstexts"
L["Size of the keybind/hotkey text"] = "Größe des Tastenbelegungs-/Hotkey-Texts"

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
L["Vertical position of macro text within the text frame"] = "Vertikale Position des Makrotexts innerhalb des Textrahmens"

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
L["Keybind X Offset"] = "Tastenbelegung X-Versatz"
L["Keybind Y Offset"] = "Tastenbelegung Y-Versatz"

-- Offset descriptions
L["Horizontal positioning offset for macro name text"] = "Horizontaler Positionsversatz für Makroname-Text"
L["Vertical positioning offset for macro name text"] = "Vertikaler Positionsversatz für Makroname-Text"
L["Horizontal positioning offset for count/charge text"] = "Horizontaler Positionsversatz für Anzahl-/Aufladungstext"
L["Vertical positioning offset for count/charge text"] = "Vertikaler Positionsversatz für Anzahl-/Aufladungstext"
L["Horizontal positioning offset for keybind/hotkey text"] = "Horizontaler Positionsversatz für Tastenbelegungs-/Hotkey-Text"
L["Vertical positioning offset for keybind/hotkey text"] = "Vertikaler Positionsversatz für Tastenbelegungs-/Hotkey-Text"

-- ############################################################
-- Appearance Controls
-- ############################################################
L["Button Style"] = "Schaltflächenart"
L["Choose button style"] = "Wählen Sie die Schaltflächenart"
L["Rounded"] = "Rund"
L["Square"] = "Eckig"
L["Less rounded button style"] = "Klassischer abgerundeter Schaltflächenart"
L["Sharp square button style"] = "Scharfer eckiger Schaltflächenart"
L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"] = "Sind Sie sicher, dass Sie alle Einstellungen im aktuellen Profil auf Standardwerte zurücksetzen möchten?\n\nDies setzt alle Erscheinungs-, Hintergrund-, Text- und Indikatoreinstellungen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Show Backdrop"] = "Hintergrund anzeigen"
L["Show outer background frame"] = "Äußeren Hintergrundrahmen anzeigen"
L["Show Border"] = "Rand anzeigen"
L["Show border around buttons"] = "Rand um Schaltflächen anzeigen"
L["Show Button Background"] = "Schaltflächen-Hintergrund anzeigen"
L["Show the button background fill behind each button icon"] = "Die Schaltflächen-Hintergrundfüllung hinter jedem Schaltflächensymbol anzeigen"

-- ############################################################
-- Overlay System
-- ############################################################
L["Out of Range Overlay"] = "Außer-Reichweite-Überlagerung"
L["Show red overlay when abilities are out of range"] = "Rote Überlagerung anzeigen, wenn Fähigkeiten außer Reichweite sind"
L["Cooldown Overlay"] = "Abklingzeit-Überlagerung"
L["Show dark overlay during ability cooldowns"] = "Dunkle Überlagerung während Fähigkeits-Abklingzeiten anzeigen"
L["Spell Alerts"] = "Zauberalerts"
L["Show custom spell alert indicators"] = "Benutzerdefinierte Zauberalert-Indikatoren anzeigen"
L["Proc Alt Glow Color"] = "Alert-Farbe"
L["Color of spell proc alerts"] = "Farbe der Zauberproc-Alerts"
L["Suggested Action Color"] = "Empfohlene Aktion Farbe"
L["Color of suggested action indicators"] = "Farbe der Indikatoren für empfohlene Aktionen"

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
L["Action Bars"] = "Aktionsleisten"
L["Are you sure you want to reset all button settings to default values?\n\nThis will reset button shape, backdrop, slot background, and border settings.\n\nThis action cannot be undone!"] = "Bist du dir sicher, dass du alle Button-Einstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Button-Form, Hintergrund, Slot-Hintergrund und Rahmen-Einstellungen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all count/charge text settings to default values?\n\nThis will reset font, size, color, and positioning settings for count/charge numbers.\n\nThis action cannot be undone!"] = "Bist du dir sicher, dass du alle Zähler-/Aufladungs-Texteinstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Schriftart, Größe, Farbe und Positionierungseinstellungen für Zähler-/Aufladungsnummern zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all indicator settings to default values?\n\nThis will reset range indicator, cooldown fade, and spell alert color settings.\n\nThis action cannot be undone!"] = "Bist du dir sicher, dass du alle Indikatoren-Einstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Reichweiten-Indikator, Cooldown-Überblendungs- und Zauber-Alarm-Farbeinstellungen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all keybind/hotkey text settings to default values?\n\nThis will reset font, size, color, and positioning settings for keybind/hotkey text.\n\nThis action cannot be undone!"] = "Bist du dir sicher, dass du alle Tastenbindungs-/Hotkey-Texteinstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Schriftart-, Größen-, Farb- und Positionierungseinstellungen für Tastenbindungs-/Hotkey-Text zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Are you sure you want to reset all macro text settings to default values?\n\nThis will reset font, size, color, positioning, and justification settings for macro names.\n\nThis action cannot be undone!"] = "Bist du dir sicher, dass du alle Makro-Texteinstellungen auf Standardwerte zurücksetzen möchtest?\n\nDies setzt Schriftart-, Größen-, Farb-, Positionierungs- und Ausrichtungseinstellungen für Makronamen zurück.\n\nDiese Aktion kann nicht rückgängig gemacht werden!"
L["Bar 5"] = "Leiste 5"
L["Bar 6"] = "Leiste 6"
L["Bar 7"] = "Leiste 7"
L["Bottom Left Bar"] = "Untere linke Leiste"
L["Bottom Right Bar"] = "Untere rechte Leiste"
L["Circle"] = "Kreis"
L["Circle button style"] = "Kreisförmiger Button-Stil"
L["Color of the equipment item border outline"] = "Farbe der Ausrüstungsgegenstand-Rahmen-Umrisse"
L["Equipment Outline"] = "Ausrüstungs-Umrisse"
L["Export Profile"] = "Profil exportieren"
L["Export current profile settings as a string"] = "Aktuelle Profileinstellungen als String exportieren"
L["Failed to decode export string"] = "Export-String konnte nicht decodiert werden"
