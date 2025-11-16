-- Portuguese (Brazil) Localization for zBarButtonBG
local L = LibStub("AceLocale-3.0"):NewLocale("zBarButtonBG", "ptBR")
if not L then return end

-- ############################################################
-- Core Interface Sections
-- ############################################################
L["General"] = "Geral"
L["Appearance"] = "Aparência"
L["Backdrop"] = "Fundo"
L["Button Background"] = "Fundo do Botão"
L["Border"] = "Borda"
L["Buttons"] = "Botões"
L["Indicators"] = "Indicadores"
L["Text Fields"] = "Campos de Texto"
L["Overlays"] = "Sobreposições"
L["Profiles"] = "Perfis"
L["Macro Name"] = "Nome da Macro"
L["Count/Charge"] = "Contador/Carga"
L["Keybind/Hotkey"] = "Tecla/Atalho"

-- ############################################################
-- Common Actions & Interface
-- ############################################################
L["Enable addon"] = "Ativar addon"
L["Turn the addon on or off"] = "Liga ou desliga o addon"
L["Create"] = "Criar"
L["Cancel"] = "Cancelar"
L["Create New Profile"] = "Criar Novo Perfil"
L["Create a new profile"] = "Criar um novo perfil"
L["New Profile"] = "Novo Perfil"
L["Current Profile"] = "Perfil Atual"
L["The currently active profile"] = "O perfil atualmente ativo"
L["Choose Profile"] = "Escolher Perfil"
L["Select a profile for copy/delete operations"] = "Selecione um perfil para operações de copiar/excluir"
L["Copy Profile"] = "Copiar Perfil"
L["Copy settings from the chosen profile to the current profile"] = "Copiar configurações do perfil escolhido para o perfil atual"
L["Modify Profiles"] = "Modificar Perfis"

-- ############################################################
-- Profile Management Messages
-- ############################################################
L["Profile Name:"] = "Nome do Perfil:"
L["Enter a name for the new profile"] = "Digite um nome para o novo perfil"
L["Profile created: "] = "Perfil criado: "
L["Profile deleted: "] = "Perfil excluído: "
L["Switched to profile: "] = "Mudou para o perfil: "
L["Settings copied from: "] = "Configurações copiadas de: "
L["Current profile reset to defaults!"] = "Perfil atual redefinido para os padrões!"

-- ############################################################
-- Reset Operations & Confirmations
-- ############################################################
L["Reset Profile"] = "Redefinir Perfil"
L["Reset current profile to defaults"] = "Redefinir perfil atual para os padrões"
L["Reset Button Settings"] = "Redefinir Configurações de Botões"
L["Reset all button-related settings to default values"] = "Redefinir todas as configurações relacionadas aos botões para valores padrão"
L["Reset Indicator Settings"] = "Redefinir Configurações de Indicadores"
L["Reset all indicator-related settings to default values"] = "Redefinir todas as configurações relacionadas aos indicadores para valores padrão"
L["Reset Macro Settings"] = "Redefinir Configurações de Macro"
L["Reset macro name text settings to default values"] = "Redefinir configurações de texto do nome da macro para valores padrão"
L["Reset Count Settings"] = "Redefinir Configurações de Contador"
L["Reset count/charge text settings to default values"] = "Redefinir configurações de texto contador/carga para valores padrão"
L["Reset Keybind Settings"] = "Redefinir Configurações de Teclas"
L["Reset keybind/hotkey text settings to default values"] = "Redefinir configurações de texto teclas/atalhos para valores padrão"

-- Reset Status Messages
L["Button settings reset to defaults!"] = "Configurações de botões redefinidas para padrão!"
L["Indicator settings reset to defaults!"] = "Configurações de indicadores redefinidas para padrão!"
L["Macro text settings reset to defaults!"] = "Configurações de texto de macro redefinidas para padrão!"
L["Count text settings reset to defaults!"] = "Configurações de texto de contador redefinidas para padrão!"
L["Keybind text settings reset to defaults!"] = "Configurações de texto de teclas redefinidas para padrão!"

-- ############################################################
-- Class & Color System (WoW Character Classes)
-- ############################################################
L["Use Class Color"] = "Usar Cor da Classe"
L["Use your class color"] = "Usar a cor da sua classe"
L["Color"] = "Cor"
L["Backdrop Color"] = "Cor do Fundo"
L["Border Color"] = "Cor da Borda"
L["Button Background Color"] = "Cor do Fundo do Botão"
L["Out of Range Color"] = "Cor Fora de Alcance"
L["Cooldown Color"] = "Cor do Tempo de Recarga"
L["Macro Name Color"] = "Cor do Nome da Macro"
L["Count Color"] = "Cor do Contador"
L["Keybind Text Color"] = "Cor do Texto das Teclas"

-- ############################################################
-- Size & Positioning
-- ############################################################
L["Size"] = "Tamanho"
L["Width"] = "Largura"
L["Height"] = "Altura"
-- Icon Padding Override
L["Override Icon Padding"] = "Substituir Preenchimento de Ícone"
L["Allow icon padding to be set below Blizzard's minimum (default: off)."] = "Permitir que o preenchimento de ícone seja definido abaixo do mínimo da Blizzard (padrão: desativado)."
L["Icon Padding Value"] = "Valor de Preenchimento de Ícone"
L["Set icon padding (0-20). Only applies if override is enabled."] = "Defina o preenchimento do ícone (0-20). Aplica-se apenas se a substituição estiver ativada."
L["Top Size"] = "Tamanho Superior"
L["Bottom Size"] = "Tamanho Inferior"
L["Left Size"] = "Tamanho Esquerdo"
L["Right Size"] = "Tamanho Direito"

-- ############################################################
-- Font System
-- ############################################################
L["Font family"] = "Família da fonte"
L["Font style flags"] = "Sinalizadores de estilo da fonte"
L["Font Size"] = "Tamanho da Fonte"
L["Font Flags"] = "Sinalizadores da Fonte"
L["None"] = "Nenhum"
L["Outline"] = "Contorno"
L["Thick Outline"] = "Contorno Grosso"
L["Monochrome"] = "Monocromático"

-- ############################################################
-- Specific Font Controls
-- ############################################################
L["Macro Name Font"] = "Fonte do Nome da Macro"
L["Count Font"] = "Fonte do Contador"
L["Count Font Size"] = "Tamanho da Fonte do Contador"
L["Count Font Style"] = "Estilo da Fonte do Contador"
L["Keybind Font"] = "Fonte das Teclas"
L["Keybind Font Size"] = "Tamanho da Fonte das Teclas"
L["Keybind Font Style"] = "Estilo da Fonte das Teclas"

-- ############################################################
-- Text Alignment & Position
-- ############################################################
L["Left"] = "Esquerda"
L["Center"] = "Centro"
L["Right"] = "Direita"
L["Top"] = "Superior"
L["Bottom"] = "Inferior"
L["Macro Text Justification"] = "Justificação do Texto da Macro"
L["Text alignment for macro names"] = "Alinhamento de texto para nomes de macro"
L["Macro Text Position"] = "Posição do Texto da Macro"

-- ############################################################
-- Dimensional Controls
-- ############################################################
L["Macro Name Width"] = "Largura do Nome da Macro"
L["Macro Name Height"] = "Altura do Nome da Macro"
L["Count Width"] = "Largura do Contador"
L["Count Height"] = "Altura do Contador"
L["Keybind Width"] = "Largura das Teclas"
L["Keybind Height"] = "Altura das Teclas"

-- ############################################################
-- Offset Controls
-- ############################################################
L["Macro Name X Offset"] = "Deslocamento X do Nome da Macro"
L["Macro Name Y Offset"] = "Deslocamento Y do Nome da Macro"
L["Count X Offset"] = "Deslocamento X do Contador"
L["Count Y Offset"] = "Deslocamento Y do Contador"
L["Keybind X Offset"] = "Deslocamento X das Teclas"
L["Keybind Y Offset"] = "Deslocamento Y das Teclas"

-- ############################################################
-- Appearance Controls
-- ############################################################
L["Button Style"] = "Estilo de Botão"
L["Choose button style"] = "Escolha o estilo do botão"
L["Round"] = "Redondo"
L["Square"] = "Quadrado"
L["Less rounded button style"] = "Estilo de botão redondo clássico"
L["Sharp square button style"] = "Estilo de botão quadrado agudo"
L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"] = "Tem certeza de que deseja redefinir todas as configurações no perfil atual para os valores padrão?\n\nIsso redefinirá todas as configurações de aparência, fundo, texto e indicador.\n\nEsta ação não pode ser desfeita!"
L["Show Backdrop"] = "Mostrar Fundo"
L["Show outer background frame"] = "Mostrar moldura de fundo externa"
L["Show Border"] = "Mostrar Borda"
L["Show border around buttons"] = "Mostrar borda ao redor dos botões"
L["Show Button Background"] = "Mostrar Fundo do Botão"
L["Show the button background fill behind each button icon"] = "Mostrar o preenchimento de fundo do botão atrás de cada ícone de botão"

-- ############################################################
-- Overlay System
-- ############################################################
L["Out of Range Overlay"] = "Sobreposição Fora de Alcance"
L["Show red overlay when abilities are out of range"] = "Mostrar sobreposição vermelha quando habilidades estão fora de alcance"
L["Cooldown Overlay"] = "Sobreposição de Tempo de Espera"
L["Show dark overlay during ability cooldowns"] = "Mostrar sobreposição escura durante o tempo de espera de habilidades"
L["Spell Alerts"] = "Alertas de Feitiço"
L["Show custom spell alert indicators"] = "Mostrar indicadores de alerta de feitiço personalizados"
L["Alert Color"] = "Cor de Alerta"
L["Color of spell proc alerts"] = "Cor dos alertas de ativação de feitiço"
L["Suggested Action Color"] = "Cor de Ação Sugerida"
L["Color of suggested action indicators"] = "Cor dos indicadores de ação sugerida"

-- ############################################################
-- Status Messages
-- ############################################################
L["Action bar backgrounds enabled"] = "Fundos das barras de ação ativados"
L["Action bar backgrounds disabled"] = "Fundos das barras de ação desativados"

-- ############################################################
-- Validation Messages
-- ############################################################
L["Value must be a number"] = "O valor deve ser um número"
L["Value must be between -50 and 50"] = "O valor deve estar entre -50 e 50"