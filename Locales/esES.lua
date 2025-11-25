-- Spanish Localization for zBarButtonBG
local L = LibStub("AceLocale-3.0"):NewLocale("zBarButtonBG", "esES")

if not L then return end

-- ############################################################
L["General"] = "General"
L["Appearance"] = "Apariencia"
L["Backdrop"] = "Fondo"
L["Button Background"] = "Fondo de Botón"
L["Border"] = "Borde"
L["Buttons"] = "Botones"
L["Indicators"] = "Indicadores"
L["Text Fields"] = "Campos de Texto"
L["Overlays"] = "Superposiciones"
L["Profiles"] = "Perfiles"
L["Profile"] = "Perfil"
L["Macro Name"] = "Nombre de Macro"
L["Count/Charge"] = "Contador/Carga"
L["Keybind/Hotkey"] = "Atajo de Teclado"

-- ############################################################
-- Common Actions & Interface
-- ############################################################
L["Enable addon"] = "Habilitar complemento"
L["Turn the addon on or off"] = "Activar o desactivar el complemento"
L["Create"] = "Crear"
L["Cancel"] = "Cancelar"
L["Create New Profile"] = "Crear Nuevo Perfil"
L["Create a new profile"] = "Crear un nuevo perfil"
L["New Profile"] = "Nuevo Perfil"
L["Current Profile"] = "Perfil Actual"
L["The currently active profile"] = "El perfil actualmente activo"
L["Choose Profile"] = "Elegir Perfil"
L["Select a profile for copy/delete operations"] = "Seleccionar un perfil para operaciones de copiar/eliminar"
L["Copy Profile"] = "Copiar Perfil"
L["Copy settings from the chosen profile to the current profile"] = "Copiar configuración del perfil elegido al perfil actual"
L["Modify Profiles"] = "Modificar Perfiles"

-- ############################################################
-- Profile Management Messages
-- ############################################################
L["Profile Name"] = "Nombre de Perfil"
L["Enter a name for the new profile"] = "Introduce un nombre para el nuevo perfil"
L["Profile created"] = "Perfil creado"
L["Profile deleted"] = "Perfil eliminado"
L["Enter a profile name and press Enter to create it"] = "Introduce un nombre de perfil y presiona Enter para crearlo"
L["Switched to profile"] = "Cambiado a perfil"
L["Settings copied from"] = "Configuración copiada de"
L["Current profile reset to defaults!"] = "¡Perfil actual restablecido a valores predeterminados!"
L["Use Combat Profile"] = "Usar Perfil de Combate"
L["Combat Profile"] = "Perfil de Combate"
L["Profile to replace all bars when in combat"] = "Perfil para reemplazar todas las barras en combate"
L["Enabled"] = "Habilitado"
L["Disabled"] = "Deshabilitado"
L["Error"] = "Error"
L["Profile name cannot be empty"] = "El nombre del perfil no puede estar vacío"
L["Profile already exists"] = "El perfil ya existe"
L["Profile created successfully"] = "Perfil creado exitosamente"
L["Profile deleted successfully"] = "Perfil eliminado exitosamente"
L["Profile copied successfully"] = "Perfil copiado exitosamente"
L["Profile does not exist"] = "El perfil no existe"
L["Source profile does not exist"] = "El perfil de origen no existe"
L["Cannot delete Default profile"] = "No se puede eliminar el perfil predeterminado"

-- ############################################################
-- Profile Import/Export
-- ############################################################
L["Export Profile"] = "Exportar Perfil"
L["Export current profile settings as a string"] = "Exportar configuración del perfil actual como cadena"
L["Import Profile"] = "Importar Perfil"
L["Import profile settings from an export string"] = "Importar configuración del perfil desde una cadena de exportación"
L["Invalid export string format"] = "Formato de cadena de exportación inválido"
L["Failed to decode export string"] = "Error al decodificar la cadena de exportación"
L["Invalid export string - not a valid profile"] = "Cadena de exportación inválida - no es un perfil válido"
L["Export string copied to clipboard!"] = "¡Cadena de exportación copiada al portapapeles!"
L["Invalid export string"] = "Cadena de exportación inválida"
L["Please paste an export string first"] = "Por favor, pega primero una cadena de exportación"
L["Create Profile from Import"] = "Crear Perfil desde Importación"
L["Profile imported"] = "Perfil importado"

-- ############################################################
-- Reset Operations & Confirmations
-- ############################################################
L["Reset Profile"] = "Restablecer Perfil"
L["Reset current profile to defaults"] = "Restablecer perfil actual a valores predeterminados"
L["Reset Button Settings"] = "Restablecer Configuración de Botones"
L["Reset all button-related settings to default values"] = "Restablecer toda la configuración relacionada con botones a valores predeterminados"
L["Reset Indicator Settings"] = "Restablecer Configuración de Indicadores"
L["Reset all indicator-related settings to default values"] = "Restablecer toda la configuración relacionada con indicadores a valores predeterminados"
L["Reset Macro Settings"] = "Restablecer Configuración de Macros"
L["Reset macro name text settings to default values"] = "Restablecer configuración de texto de nombre de macro a valores predeterminados"
L["Reset Count Settings"] = "Restablecer Configuración de Contador"
L["Reset count/charge text settings to default values"] = "Restablecer configuración de texto de contador/carga a valores predeterminados"
L["Reset Keybind Settings"] = "Restablecer Configuración de Atajos"
L["Reset keybind/hotkey text settings to default values"] = "Restablecer configuración de texto de atajos de teclado a valores predeterminados"

-- Reset Status Messages
L["Button settings reset to defaults!"] = "¡Configuración de botones restablecida a valores predeterminados!"
L["Indicator settings reset to defaults!"] = "¡Configuración de indicadores restablecida a valores predeterminados!"
L["Macro text settings reset to defaults!"] = "¡Configuración de texto de macro restablecida a valores predeterminados!"
L["Count text settings reset to defaults!"] = "¡Configuración de texto de contador restablecida a valores predeterminados!"
L["Keybind text settings reset to defaults!"] = "¡Configuración de texto de atajos restablecida a valores predeterminados!"

-- ############################################################
-- Confirmation Dialogs
-- ############################################################
L["Are you sure you want to delete the profile"] = "¿Estás seguro de que quieres eliminar el perfil"
L["This action cannot be undone!"] = "¡Esta acción no se puede deshacer!"
L["This will overwrite all current settings!"] = "¡Esto sobrescribirá toda la configuración actual!"
L["Copy settings from"] = "Copiar configuración de"

-- Multi-line confirmations
L["Are you sure you want to reset all button settings to default values?\n\nThis will reset button shape, backdrop, slot background, and border settings.\n\nThis action cannot be undone!"] = "¿Estás seguro de que quieres restablecer toda la configuración de botones a valores predeterminados?\n\nEsto restablecerá la forma del botón, fondo, fondo de ranura y configuración de borde.\n\n¡Esta acción no se puede deshacer!"
L["Are you sure you want to reset all indicator settings to default values?\n\nThis will reset range indicator, cooldown fade, and spell alert color settings.\n\nThis action cannot be undone!"] = "¿Estás seguro de que quieres restablecer toda la configuración de indicadores a valores predeterminados?\n\nEsto restablecerá el indicador de alcance, desvanecimiento de enfriamiento y configuración de colores de alerta de hechizos.\n\n¡Esta acción no se puede deshacer!"
L["Are you sure you want to reset all macro text settings to default values?\n\nThis will reset font, size, color, positioning, and justification settings for macro names.\n\nThis action cannot be undone!"] = "¿Estás seguro de que quieres restablecer toda la configuración de texto de macro a valores predeterminados?\n\nEsto restablecerá la fuente, tamaño, color, posicionamiento y configuración de justificación para nombres de macro.\n\n¡Esta acción no se puede deshacer!"
L["Are you sure you want to reset all count/charge text settings to default values?\n\nThis will reset font, size, color, and positioning settings for count/charge numbers.\n\nThis action cannot be undone!"] = "¿Estás seguro de que quieres restablecer toda la configuración de texto de contador/carga a valores predeterminados?\n\nEsto restablecerá la fuente, tamaño, color y configuración de posicionamiento para números de contador/carga.\n\n¡Esta acción no se puede deshacer!"
L["Are you sure you want to reset all keybind/hotkey text settings to default values?\n\nThis will reset font, size, color, and positioning settings for keybind/hotkey text.\n\nThis action cannot be undone!"] = "¿Estás seguro de que quieres restablecer toda la configuración de texto de atajos a valores predeterminados?\n\nEsto restablecerá la fuente, tamaño, color y configuración de posicionamiento para texto de atajos de teclado.\n\n¡Esta acción no se puede deshacer!"

-- ############################################################
-- Class & Color System (WoW Character Classes)
-- ############################################################
L["Use Class Color"] = "Usar Color de Clase"
L["Use your class color"] = "Usar el color de tu clase"
L["Color"] = "Color"
L["Backdrop Color"] = "Color de Fondo"
L["Border Color"] = "Color de Borde"
L["Button Background Color"] = "Color de Fondo de Botón"
L["Out of Range Color"] = "Color Fuera de Alcance"
L["Cooldown Color"] = "Color de Enfriamiento"
L["Macro Name Color"] = "Color de Nombre de Macro"
L["Count Color"] = "Color de Contador"
L["Keybind Text Color"] = "Color de Texto de Atajo"

-- Color descriptions
L["Color of the outer backdrop frame"] = "Color del marco de fondo exterior"
L["Color of the button slot background"] = "Color del fondo de ranura de botón"
L["Color of the button border"] = "Color del borde del botón"
L["Color of the out of range indicator"] = "Color del indicador fuera de alcance"
L["Color of the cooldown overlay"] = "Color de la superposición de enfriamiento"
L["Color of the macro name text"] = "Color del texto de nombre de macro"
L["Color of the count/charge text"] = "Color del texto de contador/carga"
L["Color of the keybind/hotkey text"] = "Color del texto de atajo de teclado"

-- ############################################################
L["Size"] = "Tamaño"
L["Width"] = "Ancho"
L["Height"] = "Alto"
-- Icon Padding Override
L["Override Icon Padding"] = "Anular Relleno de Icono"
L["Allow icon padding to be set below Blizzard's minimum (default: off)."] = "Permitir que el relleno del icono se establezca por debajo del mínimo de Blizzard (predeterminado: desactivado)."
L["Icon Padding Value"] = "Valor de Relleno de Icono"
L["Set icon padding (0-20). Only applies if override is enabled."] = "Establecer relleno de icono (0-20). Solo se aplica si la anulación está habilitada."
L["Top Size"] = "Tamaño Superior"
L["Bottom Size"] = "Tamaño Inferior"
L["Left Size"] = "Tamaño Izquierdo"
L["Right Size"] = "Tamaño Derecho"

-- Size descriptions
L["How far the backdrop extends above the button (in pixels)"] = "Qué tan lejos se extiende el fondo por encima del botón (en píxeles)"
L["How far the backdrop extends below the button (in pixels)"] = "Qué tan lejos se extiende el fondo por debajo del botón (en píxeles)"
L["How far the backdrop extends to the left of the button (in pixels)"] = "Qué tan lejos se extiende el fondo a la izquierda del botón (en píxeles)"
L["How far the backdrop extends to the right of the button (in pixels)"] = "Qué tan lejos se extiende el fondo a la derecha del botón (en píxeles)"

-- ############################################################
-- Font System
-- ############################################################
L["Font family"] = "Familia de fuente"
L["Font style flags"] = "Indicadores de estilo de fuente"
L["Font Size"] = "Tamaño de Fuente"
L["Font Flags"] = "Indicadores de Fuente"
L["None"] = "Ninguno"
L["Outline"] = "Contorno"
L["Thick Outline"] = "Contorno Grueso"
L["Monochrome"] = "Monocromo"

-- Font family descriptions
L["Font family for macro names"] = "Familia de fuente para nombres de macro"
L["Font family for count/charge numbers"] = "Familia de fuente para números de contador/carga"
L["Font family for keybind/hotkey text"] = "Familia de fuente para texto de atajos de teclado"

-- Font style descriptions
L["Font style flags for macro names"] = "Indicadores de estilo de fuente para nombres de macro"
L["Font style flags for count/charge numbers"] = "Indicadores de estilo de fuente para números de contador/carga"
L["Font style flags for keybind/hotkey text"] = "Indicadores de estilo de fuente para texto de atajos de teclado"

-- Size descriptions
L["Size of the macro name text"] = "Tamaño del texto de nombre de macro"
L["Size of the count/charge text"] = "Tamaño del texto de contador/carga"
L["Size of the keybind/hotkey text"] = "Tamaño del texto de atajo de teclado"

-- ############################################################
-- Specific Font Controls
-- ############################################################
L["Macro Name Font"] = "Fuente de Nombre de Macro"
L["Count Font"] = "Fuente de Contador"
L["Count Font Size"] = "Tamaño de Fuente de Contador"
L["Count Font Style"] = "Estilo de Fuente de Contador"
L["Keybind Font"] = "Fuente de Atajo"
L["Keybind Font Size"] = "Tamaño de Fuente de Atajo"
L["Keybind Font Style"] = "Estilo de Fuente de Atajo"

-- ############################################################
-- Text Alignment & Position
-- ############################################################
L["Left"] = "Izquierda"
L["Center"] = "Centro"
L["Right"] = "Derecha"
L["Top"] = "Arriba"
L["Bottom"] = "Abajo"
L["Macro Text Justification"] = "Justificación de Texto de Macro"
L["Text alignment for macro names"] = "Alineación de texto para nombres de macro"
L["Macro Text Position"] = "Posición de Texto de Macro"
L["Vertical position of macro text within the text frame"] = "Posición vertical del texto de macro dentro del marco de texto"

-- ############################################################
-- Dimensional Controls
-- ############################################################
L["Macro Name Width"] = "Ancho de Nombre de Macro"
L["Macro Name Height"] = "Alto de Nombre de Macro"
L["Count Width"] = "Ancho de Contador"
L["Count Height"] = "Alto de Contador"
L["Keybind Width"] = "Ancho de Atajo"
L["Keybind Height"] = "Alto de Atajo"

-- Dimension descriptions
L["Width of the macro name text frame"] = "Ancho del marco de texto de nombre de macro"
L["Height of the macro name text frame"] = "Alto del marco de texto de nombre de macro"
L["Width of the count text frame"] = "Ancho del marco de texto de contador"
L["Height of the count text frame"] = "Alto del marco de texto de contador"
L["Width of the keybind text frame"] = "Ancho del marco de texto de atajo"
L["Height of the keybind text frame"] = "Alto del marco de texto de atajo"

-- ############################################################
-- Offset Controls
-- ############################################################
L["Macro Name X Offset"] = "Desplazamiento X de Nombre de Macro"
L["Macro Name Y Offset"] = "Desplazamiento Y de Nombre de Macro"
L["Count X Offset"] = "Desplazamiento X de Contador"
L["Count Y Offset"] = "Desplazamiento Y de Contador"
L["Keybind X Offset"] = "Desplazamiento X de Atajo"
L["Keybind Y Offset"] = "Desplazamiento Y de Atajo"

-- Offset descriptions
L["Horizontal positioning offset for macro name text"] = "Desplazamiento de posicionamiento horizontal para texto de nombre de macro"
L["Vertical positioning offset for macro name text"] = "Desplazamiento de posicionamiento vertical para texto de nombre de macro"
L["Horizontal positioning offset for count/charge text"] = "Desplazamiento de posicionamiento horizontal para texto de contador/carga"
L["Vertical positioning offset for count/charge text"] = "Desplazamiento de posicionamiento vertical para texto de contador/carga"
L["Horizontal positioning offset for keybind/hotkey text"] = "Desplazamiento de posicionamiento horizontal para texto de atajo de teclado"
L["Vertical positioning offset for keybind/hotkey text"] = "Desplazamiento de posicionamiento vertical para texto de atajo de teclado"

-- ############################################################
-- Appearance Controls
-- ############################################################
L["Button Style"] = "Estilo de Botón"
L["Choose button style"] = "Elegir estilo de botón"
L["Rounded"] = "Redondeado"
L["Square"] = "Cuadrado"
L["Circle"] = "Círculo"
L["Octagon"] = "Octágono"
L["Octagon Flipped"] = "Octágono Volteado"
L["Hexagon"] = "Hexágono"
L["Rhomboid"] = "Romboide"
L["Rhomboid Flipped"] = "Romboide Volteado"
L["Rhomboid Tall"] = "Romboide Alto"
L["Rhomboid Tall Flipped"] = "Romboide Alto Volteado"
L["Hexagon Flipped"] = "Hexágono Volteado"
L["Sharp square button style"] = "Estilo de botón cuadrado afilado"
L["Circle button style"] = "Estilo de botón circular"
L["Rounded button style"] = "Estilo de botón redondeado"
L["Octagon button style"] = "Estilo de botón octagonal"
L["Octagon flipped button style"] = "Estilo de botón octagonal volteado"
L["Hexagon button style"] = "Estilo de botón hexagonal"
L["Hexagon flipped button style"] = "Estilo de botón hexagonal volteado"
L["Rhomboid button style"] = "Estilo de botón romboide"
L["Rhomboid flipped button style"] = "Estilo de botón romboide volteado"
L["Rhomboid tall button style"] = "Estilo de botón romboide alto"
L["Rhomboid tall flipped button style"] = "Estilo de botón romboide alto volteado"
L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"] = "¿Estás seguro de que quieres restablecer toda la configuración en el perfil actual a valores predeterminados?\n\nEsto restablecerá toda la configuración de apariencia, fondo, texto e indicadores.\n\n¡Esta acción no se puede deshacer!"
L["Show Backdrop"] = "Mostrar Fondo"
L["Mask Backdrop"] = "Enmascarar Fondo"
L["Mask outer background frame"] = "Enmascarar marco de fondo exterior"
L["Show outer background frame"] = "Mostrar marco de fondo exterior"
L["Show Border"] = "Mostrar Borde"
L["Show border around buttons"] = "Mostrar borde alrededor de botones"
L["Show Button Background"] = "Mostrar Fondo de Botón"
L["Show the button background fill behind each button icon"] = "Mostrar el relleno de fondo de botón detrás de cada icono de botón"

-- ############################################################
-- Overlay System
-- ############################################################
L["Out of Range Overlay"] = "Superposición Fuera de Alcance"
L["Show red overlay when abilities are out of range"] = "Mostrar superposición roja cuando las habilidades están fuera de alcance"
L["Cooldown Overlay"] = "Superposición de Enfriamiento"
L["Show dark overlay during ability cooldowns"] = "Mostrar superposición oscura durante los enfriamientos de habilidad"
L["Spell Alerts"] = "Alertas de Hechizos"
L["Show custom spell alert indicators"] = "Mostrar indicadores de alerta de hechizos personalizados"
L["Proc Alt Glow Color"] = "Color de Brillo Alt de Proc"
L["Color of spell proc alerts"] = "Color de alertas de proc de hechizos"
L["Suggested Action Color"] = "Color de Acción Sugerida"
L["Color of suggested action indicators"] = "Color de indicadores de acción sugerida"
L["Equipment Outline"] = "Contorno de Equipamiento"
L["Color of the equipment item border outline"] = "Color del contorno del borde del artículo de equipamiento"

-- ############################################################
-- Status Messages
-- ############################################################
L["Action bar backgrounds enabled"] = "Fondos de barra de acción habilitados"
L["Action bar backgrounds disabled"] = "Fondos de barra de acción deshabilitados"

-- ############################################################
-- Validation Messages
-- ############################################################
L["Value must be a number"] = "El valor debe ser un número"
L["Value must be between -50 and 50"] = "El valor debe estar entre -50 y 50"

-- ############################################################
-- Bar Settings
-- ############################################################
L["Action Bars"] = "Barras de Acción"
L["Here you can select action bars to have their own profiles applied independent of the currently selected profile."] = "Aquí puedes seleccionar barras de acción para aplicar sus propios perfiles independientemente del perfil actualmente seleccionado."
L["Main Action Bar"] = "Barra de Acción Principal"
L["Bottom Left Bar"] = "Barra Inferior Izquierda"
L["Bottom Right Bar"] = "Barra Inferior Derecha"
L["Right Bar 1"] = "Barra Derecha 1"
L["Right Bar 2"] = "Barra Derecha 2"
L["Bar 5"] = "Barra 5"
L["Bar 6"] = "Barra 6"
L["Bar 7"] = "Barra 7"
L["Pet Action Bar"] = "Barra de Acción de Mascota"
L["Stance Bar"] = "Barra de Postura"
L["Use Different Profile"] = "Usar Perfil Diferente"
L["Select which profile to use"] = "Seleccionar qué perfil usar"
