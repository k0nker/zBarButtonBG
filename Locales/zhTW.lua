-- Chinese (Traditional) Localization for zBarButtonBG
local L = LibStub("AceLocale-3.0"):NewLocale("zBarButtonBG", "zhTW")
if not L then return end

-- ############################################################
-- Core Interface Sections
-- ############################################################
L["General"] = "一般"
L["Appearance"] = "外觀"
L["Backdrop"] = "背景"
L["Button Background"] = "按鈕背景"
L["Border"] = "邊框"
L["Buttons"] = "按鈕"
L["Indicators"] = "指示器"
L["Text Fields"] = "文本字段"
L["Overlays"] = "覆蓋層"
L["Profiles"] = "設定檔"
L["Macro Name"] = "巨集名稱"
L["Count/Charge"] = "計數/充能"
L["Keybind/Hotkey"] = "按鍵綁定/熱鍵"

-- ############################################################
-- Common Actions & Interface
-- ############################################################
L["Enable addon"] = "啟用插件"
L["Turn the addon on or off"] = "開啟或關閉插件"
L["Create"] = "建立"
L["Cancel"] = "取消"
L["Create New Profile"] = "建立新設定檔"
L["Create a new profile"] = "建立一個新的設定檔"
L["New Profile"] = "新設定檔"
L["Current Profile"] = "目前設定檔"
L["The currently active profile"] = "目前啟用的設定檔"
L["Choose Profile"] = "選擇設定檔"
L["Select a profile for copy/delete operations"] = "選擇用於複製/刪除操作的設定檔"
L["Copy Profile"] = "複製設定檔"
L["Copy settings from the chosen profile to the current profile"] = "將所選設定檔的設定複製到目前設定檔"
L["Modify Profiles"] = "修改設定檔"

-- ############################################################
-- Profile Management Messages
-- ############################################################
L["Profile Name:"] = "設定檔名稱："
L["Enter a name for the new profile"] = "輸入新設定檔的名稱"
L["Profile created: "] = "設定檔已建立："
L["Profile deleted: "] = "設定檔已刪除："
L["Switched to profile: "] = "切換到設定檔："
L["Settings copied from: "] = "設定已從以下位置複製："
L["Current profile reset to defaults!"] = "目前設定檔已重設為預設值！"
L["Use Combat Profile"] = "使用戰鬥設定檔"
L["Combat Profile"] = "戰鬥設定檔"
L["Profile to replace all bars when in combat"] = "戰鬥中替換所有工具列的設定檔"

-- ############################################################
-- Reset Operations & Confirmations
-- ############################################################
L["Reset Profile"] = "重設設定檔"
L["Reset current profile to defaults"] = "將目前設定檔重設為預設值"
L["Reset Button Settings"] = "重設按鈕設定"
L["Reset all button-related settings to default values"] = "將所有按鈕相關設定重設為預設值"
L["Reset Indicator Settings"] = "重設指示器設定"
L["Reset all indicator-related settings to default values"] = "將所有指示器相關設定重設為預設值"
L["Reset Macro Settings"] = "重設巨集設定"
L["Reset macro name text settings to default values"] = "將巨集名稱文字設定重設為預設值"
L["Reset Count Settings"] = "重設計數設定"
L["Reset count/charge text settings to default values"] = "將計數/充能文字設定重設為預設值"
L["Reset Keybind Settings"] = "重設按鍵綁定設定"
L["Reset keybind/hotkey text settings to default values"] = "將按鍵綁定/熱鍵文字設定重設為預設值"

-- Reset Status Messages
L["Button settings reset to defaults!"] = "按鈕設定已重設為預設值！"
L["Indicator settings reset to defaults!"] = "指示器設定已重設為預設值！"
L["Macro text settings reset to defaults!"] = "巨集文字設定已重設為預設值！"
L["Count text settings reset to defaults!"] = "計數文字設定已重設為預設值！"
L["Keybind text settings reset to defaults!"] = "按鍵綁定文字設定已重設為預設值！"

-- ############################################################
-- Class & Color System (WoW Character Classes)
-- ############################################################
L["Use Class Color"] = "使用職業顏色"
L["Use your class color"] = "使用你的職業顏色"
L["Color"] = "顏色"
L["Backdrop Color"] = "背景顏色"
L["Border Color"] = "邊框顏色"
L["Button Background Color"] = "按鈕背景顏色"
L["Out of Range Color"] = "超出範圍顏色"
L["Cooldown Color"] = "冷卻時間顏色"
L["Macro Name Color"] = "巨集名稱顏色"
L["Count Color"] = "計數顏色"
L["Keybind Text Color"] = "按鍵綁定文字顏色"

-- ############################################################
-- Size & Positioning
-- ############################################################
L["Size"] = "大小"
L["Width"] = "寬度"
L["Height"] = "高度"
-- Icon Padding Override
L["Override Icon Padding"] = "覆蓋圖示填充"
L["Allow icon padding to be set below Blizzard's minimum (default: off)."] = "允許圖示填充設置在暴雪最小值以下(預設:關閉)。"
L["Icon Padding Value"] = "圖示填充值"
L["Set icon padding (0-20). Only applies if override is enabled."] = "設置圖示填充(0-20)。僅在啟用覆蓋時適用。"
L["Top Size"] = "頂部尺寸"
L["Bottom Size"] = "底部大小"
L["Left Size"] = "左側大小"
L["Right Size"] = "右側大小"

-- ############################################################
-- Font System
-- ############################################################
L["Font family"] = "字型系列"
L["Font style flags"] = "字型樣式旗標"
L["Font Size"] = "字型大小"
L["Font Flags"] = "字型旗標"
L["None"] = "無"
L["Outline"] = "輪廓"
L["Thick Outline"] = "粗輪廓"
L["Monochrome"] = "單色"

-- ############################################################
-- Specific Font Controls
-- ############################################################
L["Macro Name Font"] = "巨集名稱字型"
L["Count Font"] = "計數字型"
L["Count Font Size"] = "計數字型大小"
L["Count Font Style"] = "計數字型樣式"
L["Keybind Font"] = "按鍵綁定字型"
L["Keybind Font Size"] = "按鍵綁定字型大小"
L["Keybind Font Style"] = "按鍵綁定字型樣式"

-- ############################################################
-- Text Alignment & Position
-- ############################################################
L["Left"] = "左"
L["Center"] = "中"
L["Right"] = "右"
L["Top"] = "上"
L["Bottom"] = "下"
L["Macro Text Justification"] = "巨集文字對齊"
L["Text alignment for macro names"] = "巨集名稱的文字對齊"
L["Macro Text Position"] = "巨集文字位置"

-- ############################################################
-- Dimensional Controls
-- ############################################################
L["Macro Name Width"] = "巨集名稱寬度"
L["Macro Name Height"] = "巨集名稱高度"
L["Count Width"] = "計數寬度"
L["Count Height"] = "計數高度"
L["Keybind Width"] = "按鍵綁定寬度"
L["Keybind Height"] = "按鍵綁定高度"

-- ############################################################
-- Offset Controls
-- ############################################################
L["Macro Name X Offset"] = "巨集名稱X偏移"
L["Macro Name Y Offset"] = "巨集名稱Y偏移"
L["Count X Offset"] = "計數X偏移"
L["Count Y Offset"] = "計數Y偏移"
L["Keybind X Offset"] = "按鍵綁定X偏移"
L["Keybind Y Offset"] = "按鍵綁定Y偏移"

-- ############################################################
-- Appearance Controls
-- ############################################################
L["Button Style"] = "按鈕樣式"
L["Choose button style"] = "選擇按鈕樣式"
L["Rounded"] = "圓形"
L["Square"] = "方形"
L["Less rounded button style"] = "經典圓形按鈕樣式"
L["Sharp square button style"] = "銳利的方形按鈕樣式"
L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"] = "你確定要將當前設定檔中的所有設定重置爲預設值嗎？\n\n這將重置所有外观、背景、文字和指示器設定。\n\n此動作無法撤銷!"
L["Show Backdrop"] = "顯示背景"
L["Show outer background frame"] = "顯示外部背景框架"
L["Show Border"] = "顯示邊框"
L["Show border around buttons"] = "在按鈕周圍顯示邊框"
L["Show Button Background"] = "顯示按鈕背景"
L["Show the button background fill behind each button icon"] = "在每個按鈕圖示後面顯示按鈕背景填充"

-- ############################################################
-- Overlay System
-- ############################################################
L["Out of Range Overlay"] = "超出範圍覆蓋層"
L["Show red overlay when abilities are out of range"] = "當技能超出範圍時顯示紅色覆蓋層"
L["Cooldown Overlay"] = "冷卻時間覆蓋"
L["Show dark overlay during ability cooldowns"] = "在能力冷卻期間顯示深色覆蓋"
L["Spell Alerts"] = "法術警報"
L["Show custom spell alert indicators"] = "顯示自訂法術警報指示器"
L["Proc Alt Glow Color"] = "警報顏色"
L["Color of spell proc alerts"] = "法術觸發警報的顏色"
L["Suggested Action Color"] = "建議操作顏色"
L["Color of suggested action indicators"] = "建議操作指示器的顏色"

-- ############################################################
-- Status Messages
-- ############################################################
L["Action bar backgrounds enabled"] = "動作列背景已啟用"
L["Action bar backgrounds disabled"] = "動作列背景已停用"

-- ############################################################
-- Validation Messages
-- ############################################################
L["Value must be a number"] = "數值必須是數字"
L["Value must be between -50 and 50"] = "數值必須在-50和50之間"
L["Action Bars"] = "動作條"
L["Bar 5"] = "動作條 5"
L["Bar 6"] = "動作條 6"
L["Bar 7"] = "動作條 7"
L["Bottom Left Bar"] = "下左動作條"
L["Bottom Right Bar"] = "下右動作條"
L["Circle"] = "圓形"
L["Circle button style"] = "圓形按鈕樣式"
L["Color of the button border"] = "按鈕邊框的顏色"
L["Color of the button slot background"] = "按鈕槽背景的顏色"
L["Color of the cooldown overlay"] = "冷卻覆蓋的顏色"
L["Color of the count/charge text"] = "計數/充能文字的顏色"
L["Color of the equipment item border outline"] = "裝備物品邊框輪廓的顏色"
L["Color of the keybind/hotkey text"] = "快捷鍵文字的顏色"
L["Color of the macro name text"] = "巨集名稱文字的顏色"
L["Color of the out of range indicator"] = "超出範圍指示器的顏色"
L["Color of the outer backdrop frame"] = "外部背景框架的顏色"
