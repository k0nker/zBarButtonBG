# Custom Texture Implementation

## Overview
Replaced Blizzard's problematic NormalTexture and IconMask with custom TGA textures to gain complete control over button borders and icon clipping for round buttons.

## Custom Assets
Located in `Assets/` folder:
- **ButtonIconMask.tga** - Mask texture applied to both icon and SlotBackground to clip them to round shape
- **ButtonIconBorder.tga** - Border ring texture displayed around round buttons

## Key Changes Made

### 1. NormalTexture Handling
**Always invisible**: `button.NormalTexture:SetAlpha(0)` in all code paths
- Initial creation (line ~191-197)
- Update path (line ~549-552)
- Periodic checker (line ~880-882)
- On cleanup/disable: restore to `SetAlpha(1)` and `Show()` (line ~950-953)

### 2. Custom Mask System
**Created once per button**: `button._zBBG_customMask`
```lua
button._zBBG_customMask = button:CreateMaskTexture()
button._zBBG_customMask:SetTexture("Interface\\AddOns\\zBarButtonBG\\Assets\\ButtonIconMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
button._zBBG_customMask:SetAllPoints(button)
```

**Applied to multiple targets**:
- Icon texture (line ~253-267, ~605-632)
- SlotBackground (line ~358-370, ~681-703)
- Custom highlight overlay (line ~303-308)

**Cleanup**: Remove mask from all targets and restore Blizzard's IconMask to icon (line ~970-978, ~980-988)

### 3. Custom Border Texture (Round Buttons Only)
**Created in borderFrame**:
```lua
local borderFrame = CreateFrame("Frame", nil, button)
local customBorderTexture = borderFrame:CreateTexture(nil, "ARTWORK")
customBorderTexture:SetTexture("Interface\\AddOns\\zBarButtonBG\\Assets\\ButtonIconBorder")
customBorderTexture:SetAllPoints(button)
```

**Color updates**: `data.customBorderTexture:SetVertexColor(r, g, b, a)` (line ~137)

**Storage**: Stored in frames table as `customBorderTexture = customBorderTexture` (line ~543)

**Cleanup**: Hide borderFrame (line ~948)

### 4. Border Width Control
**Square buttons only**: Border width slider now hidden for round buttons since custom texture has fixed width
- Updated visibility logic in `Options.lua` (line ~318-326)
- Event handler responds to both "showBorder" and "squareButtons" changes (line ~330-334)

## File Structure Changes

### zBarButtonBG.lua (~1016 lines)
Modified sections:
- **updateColors()** (line 97-143): Changed to use customBorderTexture for round buttons
- **createActionBarBackgrounds()** (line 145+):
  - NormalTexture always SetAlpha(0) (line ~191-197)
  - Custom mask creation for round icons (line ~253-267)
  - SlotBackground custom mask application (line ~358-370)
  - Custom border texture creation (line ~420-442)
  - Custom highlight uses custom mask (line ~303-308)
  - frames table stores customBorderTexture (line ~543)
- **Update path** (line 545+):
  - NormalTexture simplified to always alpha 0 (line ~549-552)
  - Round icon restoration uses custom mask (line ~605-632)
  - SlotBackground mask application in update path (line ~681-703)
  - Custom highlight positioning (line ~659-677)
- **Periodic checker** (line ~870-897): Simplified NormalTexture handling, removed color management
- **removeActionBarBackgrounds()** (line ~921-1016):
  - Hide borderFrame (line ~948)
  - Restore NormalTexture alpha and Show() (line ~950-953)
  - Remove custom mask from SlotBackground (line ~956-964)
  - Remove custom mask from icon, restore Blizzard's mask (line ~967-978)
  - Remove custom mask from highlight (line ~980-988)

### Options.lua (~412 lines)
Modified sections:
- **UpdateBorderWidgets()** (line ~318-326): Border width only shown for square buttons
- **Event handler** (line ~330-334): Responds to "squareButtons" changes to update widget visibility

## Technical Notes

### Custom Mask Path
```lua
"Interface\\AddOns\\zBarButtonBG\\Assets\\ButtonIconMask"
```
Filter mode: `"CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE"`

### Custom Border Path
```lua
"Interface\\AddOns\\zBarButtonBG\\Assets\\ButtonIconBorder"
```

### Round Button Icon Setup
- Scale: 1.05x (reduced from 1.08x to prevent overflow)
- TexCoord crop: 0.07 to 0.93 on both axes
- Custom mask applied for round clipping
- Blizzard's IconMask removed

### Square Button Icon Setup
- Scale: 1.0x
- TexCoord: 0 to 1 (full texture)
- No mask applied
- Blizzard's IconMask removed

## Testing Checklist

- [ ] Round buttons: custom border visible and colored correctly
- [ ] Round buttons: icon clipped to round shape
- [ ] Round buttons: SlotBackground clipped to round shape
- [ ] Round buttons: highlight overlay clipped to round shape
- [ ] Round buttons: border color changes work (class color toggle, manual color)
- [ ] Round buttons: border width slider hidden in settings
- [ ] Square buttons: pixel borders visible and colored correctly
- [ ] Square buttons: border width slider visible and functional
- [ ] Square buttons: no clipping/masking artifacts
- [ ] Disable addon: all Blizzard defaults restored (NormalTexture visible, IconMask restored)
- [ ] Enable addon: custom textures load and display correctly
- [ ] Settings changes: round/square toggle updates borders immediately
- [ ] Settings changes: border on/off toggle works correctly

## Known Limitations

1. **Fixed border width for round buttons**: Custom texture has baked-in width, not adjustable by user
2. **Custom texture requirements**: If TGA files are missing, addon may show errors or broken visuals
3. **Texture loading**: If textures fail to load, buttons may appear without borders/clipping

## Future Enhancements

- Add fallback behavior if custom textures fail to load
- Consider multiple border texture variations for different widths
- Add validation to ensure TGA files exist on load
