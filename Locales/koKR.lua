-- Korean Localization for zBarButtonBG
local L = LibStub("AceLocale-3.0"):NewLocale("zBarButtonBG", "koKR")
if not L then return end

-- ############################################################
-- Core Interface Sections
-- ############################################################
L["General"] = "일반"
L["Appearance"] = "외형"
L["Backdrop"] = "배경"
L["Button Background"] = "버튼 배경"
L["Border"] = "테두리"
L["Buttons"] = "버튼"
L["Indicators"] = "지시자"
L["Text Fields"] = "텍스트 필드"
L["Overlays"] = "오버레이"
L["Profiles"] = "프로필"
L["Macro Name"] = "매크로 이름"
L["Count/Charge"] = "개수/충전"
L["Keybind/Hotkey"] = "단축키/핫키"

-- ############################################################
-- Common Actions & Interface
-- ############################################################
L["Enable addon"] = "애드온 활성화"
L["Turn the addon on or off"] = "애드온을 켜거나 끕니다"
L["Create"] = "생성"
L["Cancel"] = "취소"
L["Create New Profile"] = "새 프로필 생성"
L["Create a new profile"] = "새 프로필을 생성합니다"
L["New Profile"] = "새 프로필"
L["Current Profile"] = "현재 프로필"
L["The currently active profile"] = "현재 활성화된 프로필"
L["Choose Profile"] = "프로필 선택"
L["Select a profile for copy/delete operations"] = "복사/삭제 작업을 위한 프로필 선택"
L["Copy Profile"] = "프로필 복사"
L["Copy settings from the chosen profile to the current profile"] = "선택한 프로필에서 현재 프로필로 설정을 복사합니다"
L["Modify Profiles"] = "프로필 수정"

-- ############################################################
-- Profile Management Messages
-- ############################################################
L["Profile Name:"] = "프로필 이름:"
L["Enter a name for the new profile"] = "새 프로필의 이름을 입력하세요"
L["Profile created: "] = "프로필 생성됨: "
L["Profile deleted: "] = "프로필 삭제됨: "
L["Switched to profile: "] = "프로필로 변경됨: "
L["Settings copied from: "] = "설정이 복사됨: "
L["Current profile reset to defaults!"] = "현재 프로필이 기본값으로 재설정되었습니다!"

-- ############################################################
-- Reset Operations & Confirmations
-- ############################################################
L["Reset Profile"] = "프로필 재설정"
L["Reset current profile to defaults"] = "현재 프로필을 기본값으로 재설정"
L["Reset Button Settings"] = "버튼 설정 재설정"
L["Reset all button-related settings to default values"] = "모든 버튼 관련 설정을 기본값으로 재설정합니다"
L["Reset Indicator Settings"] = "표시기 설정 재설정"
L["Reset all indicator-related settings to default values"] = "모든 표시기 관련 설정을 기본값으로 재설정합니다"
L["Reset Macro Settings"] = "매크로 설정 재설정"
L["Reset macro name text settings to default values"] = "매크로 이름 텍스트 설정을 기본값으로 재설정합니다"
L["Reset Count Settings"] = "개수 설정 재설정"
L["Reset count/charge text settings to default values"] = "개수/충전 텍스트 설정을 기본값으로 재설정합니다"
L["Reset Keybind Settings"] = "단축키 설정 재설정"
L["Reset keybind/hotkey text settings to default values"] = "단축키/핫키 텍스트 설정을 기본값으로 재설정합니다"

-- Reset Status Messages
L["Button settings reset to defaults!"] = "버튼 설정이 기본값으로 재설정되었습니다!"
L["Indicator settings reset to defaults!"] = "표시기 설정이 기본값으로 재설정되었습니다!"
L["Macro text settings reset to defaults!"] = "매크로 텍스트 설정이 기본값으로 재설정되었습니다!"
L["Count text settings reset to defaults!"] = "개수 텍스트 설정이 기본값으로 재설정되었습니다!"
L["Keybind text settings reset to defaults!"] = "단축키 텍스트 설정이 기본값으로 재설정되었습니다!"

-- ############################################################
-- Class & Color System (WoW Character Classes)
-- ############################################################
L["Use Class Color"] = "직업 색상 사용"
L["Use your class color"] = "당신의 직업 색상을 사용합니다"
L["Color"] = "색상"
L["Backdrop Color"] = "배경 색상"
L["Border Color"] = "테두리 색상"
L["Button Background Color"] = "버튼 배경 색상"
L["Out of Range Color"] = "사거리 밖 색상"
L["Cooldown Color"] = "재사용 대기시간 색상"
L["Macro Name Color"] = "매크로 이름 색상"
L["Count Color"] = "개수 색상"
L["Keybind Text Color"] = "단축키 텍스트 색상"

-- ############################################################
-- Size & Positioning
-- ############################################################
L["Size"] = "크기"
L["Width"] = "너비"
L["Height"] = "높이"
-- Icon Padding Override
L["Override Icon Padding"] = "아이콘 패딩 무시"
L["Allow icon padding to be set below Blizzard's minimum (default: off)."] = "Blizzard의 최소값 이하로 아이콘 패딩을 설정하도록 허용(기본값: 비활성화)."
L["Icon Padding Value"] = "아이콘 패딩 값"
L["Set icon padding (0-20). Only applies if override is enabled."] = "아이콘 패딩 설정(0-20). 무시가 활성화된 경우에만 적용됩니다."
L["Top Size"] = "상단 크기"
L["Bottom Size"] = "하단 크기"
L["Left Size"] = "왼쪽 크기"
L["Right Size"] = "오른쪽 크기"

-- ############################################################
-- Font System
-- ############################################################
L["Font family"] = "글꼴 패밀리"
L["Font style flags"] = "글꼴 스타일 플래그"
L["Font Size"] = "글꼴 크기"
L["Font Flags"] = "글꼴 플래그"
L["None"] = "없음"
L["Outline"] = "외곽선"
L["Thick Outline"] = "두꺼운 외곽선"
L["Monochrome"] = "단색"

-- ############################################################
-- Specific Font Controls
-- ############################################################
L["Macro Name Font"] = "매크로 이름 글꼴"
L["Count Font"] = "개수 글꼴"
L["Count Font Size"] = "개수 글꼴 크기"
L["Count Font Style"] = "개수 글꼴 스타일"
L["Keybind Font"] = "단축키 글꼴"
L["Keybind Font Size"] = "단축키 글꼴 크기"
L["Keybind Font Style"] = "단축키 글꼴 스타일"

-- ############################################################
-- Text Alignment & Position
-- ############################################################
L["Left"] = "왼쪽"
L["Center"] = "가운데"
L["Right"] = "오른쪽"
L["Top"] = "상단"
L["Bottom"] = "하단"
L["Macro Text Justification"] = "매크로 텍스트 정렬"
L["Text alignment for macro names"] = "매크로 이름의 텍스트 정렬"
L["Macro Text Position"] = "매크로 텍스트 위치"

-- ############################################################
-- Dimensional Controls
-- ############################################################
L["Macro Name Width"] = "매크로 이름 너비"
L["Macro Name Height"] = "매크로 이름 높이"
L["Count Width"] = "개수 너비"
L["Count Height"] = "개수 높이"
L["Keybind Width"] = "단축키 너비"
L["Keybind Height"] = "단축키 높이"

-- ############################################################
-- Offset Controls
-- ############################################################
L["Macro Name X Offset"] = "매크로 이름 X 오프셋"
L["Macro Name Y Offset"] = "매크로 이름 Y 오프셋"
L["Count X Offset"] = "개수 X 오프셋"
L["Count Y Offset"] = "개수 Y 오프셋"
L["Keybind X Offset"] = "단축키 X 오프셋"
L["Keybind Y Offset"] = "단축키 Y 오프셋"

-- ############################################################
-- Appearance Controls
-- ############################################################
L["Button Style"] = "버튼 스타일"
L["Choose button style"] = "버튼 스타일 선택"
L["Round"] = "원형"
L["Square"] = "사각형"
L["Less rounded button style"] = "클래식 둥근 버튼 스타일"
L["Sharp square button style"] = "날카로운 사각형 버튼 스타일"
L["Are you sure you want to reset all settings in the current profile to default values?\n\nThis will reset all appearance, backdrop, text, and indicator settings.\n\nThis action cannot be undone!"] = "현재 프로필의 모든 설정을 기본값으로 초기화하시겠습니까?\n\n이것은 모든 모양, 배경, 테늤트 및 지시기 설정을 초기화합니다.\n\n이 동작은 되돌릴 수 없습니다!"
L["Show Backdrop"] = "배경 표시"
L["Show outer background frame"] = "외부 배경 프레임 표시"
L["Show Border"] = "테두리 표시"
L["Show border around buttons"] = "버튼 주위에 테두리 표시"
L["Show Button Background"] = "버튼 배경 표시"
L["Show the button background fill behind each button icon"] = "각 버튼 아이콘 뒤에 버튼 배경 채우기 표시"

-- ############################################################
-- Overlay System
-- ############################################################
L["Out of Range Overlay"] = "사거리 밖 오버레이"
L["Show red overlay when abilities are out of range"] = "기술이 사거리 밖에 있을 때 빨간색 오버레이 표시"
L["Cooldown Overlay"] = "재사용 대기시간 오버레이"
L["Show dark overlay during ability cooldowns"] = "능력 재사용 대기 시간 중 어두운 오버레이 표시"
L["Spell Alerts"] = "주문 알림"
L["Show custom spell alert indicators"] = "사용자 정의 주문 알림 표시기 표시"
L["Alert Color"] = "경고 색상"
L["Color of spell proc alerts"] = "주문 발동 경고 색상"
L["Suggested Action Color"] = "제안된 작업 색상"
L["Color of suggested action indicators"] = "제안된 작업 표시기의 색상"

-- ############################################################
-- Status Messages
-- ############################################################
L["Action bar backgrounds enabled"] = "행동 단축바 배경이 활성화되었습니다"
L["Action bar backgrounds disabled"] = "행동 단축바 배경이 비활성화되었습니다"

-- ############################################################
-- Validation Messages
-- ############################################################
L["Value must be a number"] = "값은 숫자여야 합니다"
L["Value must be between -50 and 50"] = "값은 -50과 50 사이여야 합니다"