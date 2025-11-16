-- Spanish Localization for zBarButtonBG
local L = LibStub("AceLocale-3.0"):NewLocale("zBarButtonBG", "esES")
if not L then return end

-- ############################################################
-- Core Interface Sections
-- ############################################################
L["General"] = "General"
L["Appearance"] = "Apariencia"
L["Backdrop"] = "Fondo"
L["Button Background"] = "Fondo del Botón"
L["Border"] = "Borde"
L["Buttons"] = "Botones"
L["Indicators"] = "Indicadores"
L["Text Fields"] = "Campos de Texto"
L["Overlays"] = "Superposiciones"
L["Profiles"] = "Perfiles"
L["Macro Name"] = "Nombre de Macro"
L["Count/Charge"] = "Contador/Carga"
L["Keybind/Hotkey"] = "Tecla/Atajo"

-- ############################################################
-- Common Actions & Interface
-- ############################################################
L["Enable addon"] = "Habilitar addon"
L["Turn the addon on or off"] = "Activa o desactiva el addon"
L["Create"] = "Crear"
L["Cancel"] = "Cancelar"
L["Create New Profile"] = "Crear Nuevo Perfil"
L["Create a new profile"] = "Crear un nuevo perfil"
L["New Profile"] = "Nuevo Perfil"
L["Current Profile"] = "Perfil Actual"
L["The currently active profile"] = "El perfil actualmente activo"
L["Choose Profile"] = "Elegir Perfil"
L["Select a profile for copy/delete operations"] = "Selecciona un perfil para operaciones de copiar/eliminar"
L["Copy Profile"] = "Copiar Perfil"
L["Copy settings from the chosen profile to the current profile"] = "Copiar ajustes del perfil elegido al perfil actual"
L["Modify Profiles"] = "Modificar Perfiles"

-- ############################################################
-- Profile Management Messages
-- ############################################################
L["Profile Name:"] = "Nombre del Perfil:"
L["Enter a name for the new profile"] = "Introduce un nombre para el nuevo perfil"
L["Profile created: "] = "Perfil creado: "
L["Profile deleted: "] = "Perfil eliminado: "
L["Switched to profile: "] = "Cambiado al perfil: "
L["Settings copied from: "] = "Ajustes copiados de: "
L["Current profile reset to defaults!"] = "¡Perfil actual restablecido a valores predeterminados!"

-- ############################################################
-- Reset Operations & Confirmations
-- ############################################################
L["Reset Profile"] = "Restablecer Perfil"
L["Reset current profile to defaults"] = "Restablecer perfil actual a valores predeterminados"
L["Reset Button Settings"] = "Restablecer Ajustes de Botones"
L["Reset all button-related settings to default values"] = "Restablecer todos los ajustes relacionados con botones a valores predeterminados"
L["Reset Indicator Settings"] = "Restablecer Ajustes de Indicadores"
L["Reset all indicator-related settings to default values"] = "Restablecer todos los ajustes relacionados con indicadores a valores predeterminados"
L["Reset Macro Settings"] = "Restablecer Ajustes de Macro"
L["Reset macro name text settings to default values"] = "Restablecer ajustes de texto de nombres de macro a valores predeterminados"
L["Reset Count Settings"] = "Restablecer Ajustes de Contador"
L["Reset count/charge text settings to default values"] = "Restablecer ajustes de texto contador/carga a valores predeterminados"
L["Reset Keybind Settings"] = "Restablecer Ajustes de Teclas"
L["Reset keybind/hotkey text settings to default values"] = "Restablecer ajustes de texto teclas/atajos a valores predeterminados"

-- Reset Status Messages
L["Button settings reset to defaults!"] = "¡Ajustes de botones restablecidos por defecto!"
L["Indicator settings reset to defaults!"] = "¡Ajustes de indicadores restablecidos por defecto!"
L["Macro text settings reset to defaults!"] = "¡Ajustes de texto de macro restablecidos por defecto!"
L["Count text settings reset to defaults!"] = "¡Ajustes de texto de contador restablecidos por defecto!"
L["Keybind text settings reset to defaults!"] = "¡Ajustes de texto de teclas restablecidos por defecto!"

-- ############################################################
-- Class & Color System (WoW Character Classes)
-- ############################################################
L["Use Class Color"] = "Usar Color de Clase"
L["Use your class color"] = "Usar el color de tu clase"
L["Color"] = "Color"
L["Backdrop Color"] = "Color del Fondo"
L["Border Color"] = "Color del Borde"
L["Button Background Color"] = "Color del Fondo del Botón"
L["Out of Range Color"] = "Color Fuera de Alcance"
L["Cooldown Color"] = "Color de Enfriamiento"
L["Macro Name Color"] = "Color del Nombre de Macro"
L["Count Color"] = "Color del Contador"
L["Keybind Text Color"] = "Color del Texto de Teclas"

-- ############################################################
-- Size & Positioning
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

-- ############################################################
-- Font System
-- ############################################################
L["Font family"] = "Familia de fuente"
L["Font style flags"] = "Banderas de estilo de fuente"
L["Font Size"] = "Tamaño de Fuente"
L["Font Flags"] = "Banderas de Fuente"
L["None"] = "Ninguno"
L["Outline"] = "Contorno"
L["Thick Outline"] = "Contorno Grueso"
L["Monochrome"] = "Monocromo"

-- ############################################################
-- Specific Font Controls
-- ############################################################
L["Macro Name Font"] = "Fuente del Nombre de Macro"
L["Count Font"] = "Fuente del Contador"
L["Count Font Size"] = "Tamaño de Fuente del Contador"
L["Count Font Style"] = "Estilo de Fuente del Contador"
L["Keybind Font"] = "Fuente de Teclas"
L["Keybind Font Size"] = "Tamaño de Fuente de Teclas"
L["Keybind Font Style"] = "Estilo de Fuente de Teclas"

-- ############################################################
-- Text Alignment & Position
-- ############################################################
L["Left"] = "Izquierda"
L["Center"] = "Centro"
L["Right"] = "Derecha"
L["Top"] = "Arriba"
L["Bottom"] = "Abajo"
L["Macro Text Justification"] = "Justificación del Texto de Macro"
L["Text alignment for macro names"] = "Alineación de texto para nombres de macro"
L["Macro Text Position"] = "Posición del Texto de Macro"

-- ############################################################
-- Dimensional Controls
-- ############################################################
L["Macro Name Width"] = "Ancho del Nombre de Macro"
L["Macro Name Height"] = "Alto del Nombre de Macro"
L["Count Width"] = "Ancho del Contador"
L["Count Height"] = "Alto del Contador"
L["Keybind Width"] = "Ancho de Teclas"
L["Keybind Height"] = "Alto de Teclas"

-- ############################################################
-- Offset Controls
-- ############################################################
L["Macro Name X Offset"] = "Desplazamiento X del Nombre de Macro"
L["Macro Name Y Offset"] = "Desplazamiento Y del Nombre de Macro"
L["Count X Offset"] = "Desplazamiento X del Contador"
L["Count Y Offset"] = "Desplazamiento Y del Contador"
L["Keybind X Offset"] = "Desplazamiento X de Teclas"
L["Keybind Y Offset"] = "Desplazamiento Y de Teclas"

-- ############################################################
-- Appearance Controls
-- ############################################################
L["Button Style"] = "Estilo de Botón"
L["Choose button style"] = "Elige el estilo de botón"
L["Round"] = "Redondeado"
L["Square"] = "Cuadrado"
L["Less rounded button style"] = "Estilo clásico de botón redondeado"
L["Sharp square button style"] = "Estilo de botón cuadrado agudo"
L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"] = "¿Está seguro de que desea restablecer todos los ajustes del perfil actual a los valores predeterminados?\n\nEsto restablecerá todos los ajustes de apariencia, fondo, texto e indicador.\n\n¡Esta acción no se puede deshacer!"
L["Show Backdrop"] = "Mostrar fondo"
L["Show outer background frame"] = "Mostrar marco de fondo exterior"
L["Show Border"] = "Mostrar Borde"
L["Show border around buttons"] = "Mostrar borde alrededor de los botones"
L["Show Button Background"] = "Mostrar Fondo del Botón"
L["Show the button background fill behind each button icon"] = "Mostrar el relleno de fondo del botón detrás de cada icono de botón"

-- ############################################################
-- Overlay System
-- ############################################################
L["Out of Range Overlay"] = "Superposición Fuera de Alcance"
L["Show red overlay when abilities are out of range"] = "Mostrar superposición roja cuando las habilidades están fuera de alcance"
L["Cooldown Overlay"] = "Superposición de enfriamiento"
L["Show dark overlay during ability cooldowns"] = "Mostrar superposición oscura durante los tiempos de enfriamiento de habilidades"
L["Spell Alerts"] = "Alertas de hechizo"
L["Show custom spell alert indicators"] = "Mostrar indicadores de alerta de hechizo personalizados"
L["Alert Color"] = "Color de alerta"
L["Color of spell proc alerts"] = "Color de las alertas de proc de hechizo"
L["Suggested Action Color"] = "Color de acción sugerida"
L["Color of suggested action indicators"] = "Color de los indicadores de acción sugerida"

-- ############################################################
-- Status Messages
-- ############################################################
L["Action bar backgrounds enabled"] = "Fondos de barras de acción habilitados"
L["Action bar backgrounds disabled"] = "Fondos de barras de acción deshabilitados"

-- ############################################################
-- Validation Messages
-- ############################################################
L["Value must be a number"] = "El valor debe ser un número"
L["Value must be between -50 and 50"] = "El valor debe estar entre -50 y 50"