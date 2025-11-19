-- Russian Localization for zBarButtonBG
local L = LibStub("AceLocale-3.0"):NewLocale("zBarButtonBG", "ruRU")
if not L then return end

-- ############################################################
L["General"] = "Общие"
L["Appearance"] = "Внешний вид"
L["Backdrop"] = "Фон"
L["Button Background"] = "Фон кнопки"
L["Border"] = "Граница"
L["Buttons"] = "Кнопки"
L["Indicators"] = "Индикаторы"
L["Text Fields"] = "Текстовые поля"
L["Overlays"] = "Наложения"
L["Profiles"] = "Профили"
L["Macro Name"] = "Имя макроса"
L["Count/Charge"] = "Счётчик/Заряд"
L["Keybind/Hotkey"] = "Клавиша/Хоткей"

-- ############################################################
-- Common Actions & Interface
-- ############################################################
L["Enable addon"] = "Включить аддон"
L["Turn the addon on or off"] = "Включить или отключить аддон"
L["Create"] = "Создать"
L["Cancel"] = "Отмена"
L["Create New Profile"] = "Создать новый профиль"
L["Create a new profile"] = "Создать новый профиль"
L["New Profile"] = "Новый профиль"
L["Current Profile"] = "Текущий профиль"
L["The currently active profile"] = "Текущий активный профиль"
L["Choose Profile"] = "Выбрать профиль"
L["Select a profile for copy/delete operations"] = "Выберите профиль для операций копирования/удаления"
L["Copy Profile"] = "Копировать профиль"
L["Copy settings from the chosen profile to the current profile"] = "Копировать настройки из выбранного профиля в текущий профиль"
L["Modify Profiles"] = "Изменить профили"

-- ############################################################
-- Profile Management Messages
-- ############################################################
L["Profile Name:"] = "Имя профиля:"
L["Enter a name for the new profile"] = "Введите имя для нового профиля"
L["Profile created: "] = "Профиль создан: "
L["Profile deleted: "] = "Профиль удалён: "
L["Switched to profile: "] = "Переключился на профиль: "
L["Settings copied from: "] = "Настройки скопированы из: "
L["Current profile reset to defaults!"] = "Текущий профиль сброшен к настройкам по умолчанию!"
L["Use Combat Profile"] = "Использовать боевой профиль"
L["Combat Profile"] = "Боевой профиль"
L["Profile to replace all bars when in combat"] = "Профиль для замены всех панелей в бою"

-- ############################################################
-- Reset Operations & Confirmations
-- ############################################################
L["Reset Profile"] = "Сбросить профиль"
L["Reset current profile to defaults"] = "Сбросить текущий профиль к настройкам по умолчанию"
L["Reset Button Settings"] = "Сбросить настройки кнопок"
L["Reset all button-related settings to default values"] = "Сбросить все настройки, связанные с кнопками, к значениям по умолчанию"
L["Reset Indicator Settings"] = "Сбросить настройки индикаторов"
L["Reset all indicator-related settings to default values"] = "Сбросить все настройки, связанные с индикаторами, к значениям по умолчанию"
L["Reset Macro Settings"] = "Сбросить настройки макросов"
L["Reset macro name text settings to default values"] = "Сбросить настройки текста имён макросов к значениям по умолчанию"
L["Reset Count Settings"] = "Сбросить настройки счётчика"
L["Reset count/charge text settings to default values"] = "Сбросить настройки текста счётчика/зарядов к значениям по умолчанию"
L["Reset Keybind Settings"] = "Сбросить настройки клавиш"
L["Reset keybind/hotkey text settings to default values"] = "Сбросить настройки текста клавиш/хоткеев к значениям по умолчанию"

-- Reset Status Messages
L["Button settings reset to defaults!"] = "Настройки кнопок сброшены по умолчанию!"
L["Indicator settings reset to defaults!"] = "Настройки индикаторов сброшены по умолчанию!"
L["Macro text settings reset to defaults!"] = "Настройки текста макросов сброшены по умолчанию!"
L["Count text settings reset to defaults!"] = "Настройки текста счётчика сброшены по умолчанию!"
L["Keybind text settings reset to defaults!"] = "Настройки текста клавиш сброшены по умолчанию!"

-- ############################################################
-- Class & Color System (WoW Character Classes)
-- ############################################################
L["Use Class Color"] = "Использовать цвет класса"
L["Use your class color"] = "Использовать цвет вашего класса"
L["Color"] = "Цвет"
L["Backdrop Color"] = "Цвет фона"
L["Border Color"] = "Цвет границы"
L["Button Background Color"] = "Цвет фона кнопки"
L["Out of Range Color"] = "Цвет вне дистанции"
L["Cooldown Color"] = "Цвет перезарядки"
L["Macro Name Color"] = "Цвет имени макроса"
L["Count Color"] = "Цвет счётчика"
L["Keybind Text Color"] = "Цвет текста клавиш"

-- ############################################################
L["Size"] = "Размер"
L["Width"] = "Ширина"
L["Height"] = "Высота"
-- Icon Padding Override
L["Override Icon Padding"] = "Переопределить отступ иконки"
L["Allow icon padding to be set below Blizzard's minimum (default: off)."] = "Позволяет установить отступ иконки ниже минимального значения Blizzard (по умолчанию: выкл.)"
L["Icon Padding Value"] = "Значение отступа иконки"
L["Set icon padding (0-20). Only applies if override is enabled."] = "Установите отступ иконки (0-20). Применяется только при включённом переопределении."
L["Top Size"] = "Верхний размер"
L["Bottom Size"] = "Нижний размер"
L["Left Size"] = "Левый размер"
L["Right Size"] = "Правый размер"

-- ############################################################
-- Font System
-- ############################################################
L["Font family"] = "Семейство шрифтов"
L["Font style flags"] = "Флаги стиля шрифта"
L["Font Size"] = "Размер шрифта"
L["Font Flags"] = "Флаги шрифта"
L["None"] = "Нет"
L["Outline"] = "Контур"
L["Thick Outline"] = "Толстый контур"
L["Monochrome"] = "Монохромный"

-- ############################################################
-- Specific Font Controls
-- ############################################################
L["Macro Name Font"] = "Шрифт имени макроса"
L["Count Font"] = "Шрифт счётчика"
L["Count Font Size"] = "Размер шрифта счётчика"
L["Count Font Style"] = "Стиль шрифта счётчика"
L["Keybind Font"] = "Шрифт клавиш"
L["Keybind Font Size"] = "Размер шрифта клавиш"
L["Keybind Font Style"] = "Стиль шрифта клавиш"

-- ############################################################
-- Text Alignment & Position
-- ############################################################
L["Left"] = "Слева"
L["Center"] = "По центру"
L["Right"] = "Справа"
L["Top"] = "Сверху"
L["Bottom"] = "Снизу"
L["Macro Text Justification"] = "Выравнивание текста макроса"
L["Text alignment for macro names"] = "Выравнивание текста для имён макросов"
L["Macro Text Position"] = "Позиция текста макроса"

-- ############################################################
-- Dimensional Controls
-- ############################################################
L["Macro Name Width"] = "Ширина имени макроса"
L["Macro Name Height"] = "Высота имени макроса"
L["Count Width"] = "Ширина счётчика"
L["Count Height"] = "Высота счётчика"
L["Keybind Width"] = "Ширина клавиш"
L["Keybind Height"] = "Высота клавиш"

-- ############################################################
-- Offset Controls
-- ############################################################
L["Macro Name X Offset"] = "Смещение X имени макроса"
L["Macro Name Y Offset"] = "Смещение Y имени макроса"
L["Count X Offset"] = "Смещение X счётчика"
L["Count Y Offset"] = "Смещение Y счётчика"
L["Keybind X Offset"] = "Смещение X клавиш"
L["Keybind Y Offset"] = "Смещение Y клавиш"

-- ############################################################
-- Appearance Controls
-- ############################################################
L["Button Style"] = "Стиль кнопок"
L["Choose button style"] = "Выберите стиль кнопок"
L["Rounded"] = "Круглый"
L["Square"] = "Квадратный"
L["Less rounded button style"] = "Классический стиль округленной кнопки"
L["Sharp square button style"] = "Острый стиль квадратной кнопки"
L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"] = "Вы уверены, что хотите сбросить все параметры текущего профиля на стандартные значения?\n\nЭто сбросит все внешние виды, внешние параметры текста и данные индикатора.\n\nЭто действие не может быть аннулировано!"
L["Show Backdrop"] = "Показать фон"
L["Show outer background frame"] = "Показать внешнюю рамку фона"
L["Show Border"] = "Показать границу"
L["Show border around buttons"] = "Показать границу вокруг кнопок"
L["Show Button Background"] = "Показать фон кнопки"
L["Show the button background fill behind each button icon"] = "Показать заливку фона кнопки за каждым значком кнопки"

-- ############################################################
-- Overlay System
-- ############################################################
L["Out of Range Overlay"] = "Наложение вне дистанции"
L["Show red overlay when abilities are out of range"] = "Показать красное наложение, когда способности вне дистанции"
L["Cooldown Overlay"] = "Оверлей времени восстановления"
L["Show dark overlay during ability cooldowns"] = "Показывать темный оверлей во время восстановления способностей"
L["Spell Alerts"] = "Оповещения о заклинаниях"
L["Show custom spell alert indicators"] = "Показывать пользовательские индикаторы оповещений о заклинаниях"
L["Proc Alt Glow Color"] = "Цвет оповещения"
L["Color of spell proc alerts"] = "Цвет оповещений о срабатывании заклинания"
L["Suggested Action Color"] = "Цвет рекомендуемого действия"
L["Color of suggested action indicators"] = "Цвет индикаторов рекомендуемого действия"

-- ############################################################

-- ############################################################
-- Status Messages
-- ############################################################
L["Action bar backgrounds enabled"] = "Фоны панелей действий включены"
L["Action bar backgrounds disabled"] = "Фоны панелей действий отключены"

-- ############################################################
-- Validation Messages
-- ############################################################
L["Value must be a number"] = "Значение должно быть числом"
L["Value must be between -50 and 50"] = "Значение должно быть между -50 и 50"
L["Action Bars"] = "Панели действий"
L["Bar 5"] = "Панель 5"
L["Bar 6"] = "Панель 6"
L["Bar 7"] = "Панель 7"
L["Bottom Left Bar"] = "Нижняя левая панель"
L["Bottom Right Bar"] = "Нижняя правая панель"
L["Circle"] = "Круг"
L["Circle button style"] = "Круглый стиль кнопки"
L["Color of the button border"] = "Цвет границы кнопки"
L["Color of the button slot background"] = "Цвет фона слота кнопки"
L["Color of the cooldown overlay"] = "Цвет наложения перезарядки"
L["Color of the count/charge text"] = "Цвет текста счетчика/заряда"
L["Color of the equipment item border outline"] = "Цвет контура границы предмета снаряжения"
L["Color of the keybind/hotkey text"] = "Цвет текста клавиши быстрого доступа"
L["Color of the macro name text"] = "Цвет текста имени макроса"
L["Color of the out of range indicator"] = "Цвет индикатора вне досягаемости"
L["Color of the outer backdrop frame"] = "Цвет внешнего фрейма фона"
