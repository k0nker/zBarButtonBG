# zBarButtonBG - Feature Summary

## Core Features

### Icon Appearance
- **Squared-off Icons**: Removes the default rounded corners from action button icons
  - Uses SetScale(1.08) + SetTexCoord(0.08, 0.92, 0.08, 0.92) for clean squared look
  - Applies to highlight, checked, and pushed textures for consistent appearance

### Background System
- **Two-Layer Backgrounds**:
  - **Outer Backdrop**: Extends 5px beyond button edges (default: black)
  - **Inner Button Background**: Matches button size (default: dark grey)
  - Both layers support custom colors with RGBA control

### Border System (NEW)
- **Optional Icon Borders**: Checkbox to enable borders around each action button
  - **Border Width**: Adjustable from 1-20 pixels via slider
  - **Border Color**: Full RGBA color picker for custom border colors
  - **Class Color Option**: Toggle to use your character's class color for borders

### Class Color Integration (NEW)
Three independent toggles for class color application:
- **Border**: Use class color for icon borders
- **Backdrop**: Use class color for outer backdrop
- **Button Background**: Use class color for button background

When a class color toggle is enabled, the corresponding color picker is automatically disabled.

## Settings Panel

### Access
- **In-Game**: ESC → Options → Add-Ons → zBarButtonBG
- **Chat Command**: `/zbg` to toggle on/off

### Options Available
1. **Enable Action Bar Backgrounds** - Master toggle for the entire addon
2. **Show Icon Border** - Enable/disable icon borders
   - Border Width slider (1-20 pixels)
   - Use Class Color for Border toggle
   - Border Color picker (disabled when class color is active)
3. **Use Class Color for Backdrop** - Apply class color to outer backdrop
4. **Backdrop Color** - RGBA color picker (disabled when class color is active)
5. **Use Class Color for Button Background** - Apply class color to button background
6. **Button Background Color** - RGBA color picker (disabled when class color is active)

### Settings System
- **Event-Driven**: All changes trigger immediate visual updates (no /reload required)
- **Per-Character**: Settings saved per realm/character in zBarButtonBGSaved
- **Live Updates**: Color changes apply instantly to all action bars

## Technical Details

### Supported Action Bars
- Main action bar (ActionButton 1-12)
- MultiBarBottomLeft/Right
- MultiBarRight/Left
- MultiBar5/6/7
- PetActionButton
- StanceButton

### Frame Layering
- Backgrounds: SetFrameStrata("BACKGROUND") with sublevels -8 (outer) and -7 (inner)
- Borders: SetFrameLevel(button:GetFrameLevel() + 1) for proper layering above backgrounds
- Icon: SetScale(1.08) applied after resetting to 1.0 for consistency

### Class Color Detection
Uses `C_ClassColor.GetClassColor(select(2, UnitClass("player")))` for accurate class colors.
Opacity (alpha) is preserved from the original color setting when applying class colors.

### Conditional UI
- Border width slider and border color picker only visible when "Show Icon Border" is checked
- Color pickers automatically disable (grey out) when corresponding "Use Class Color" toggle is enabled
- All widgets update dynamically when settings change

## Future Enhancements (Potential)
- Per-bar settings (different colors for different action bars)
- Border style options (solid, dotted, glow)
- Import/export settings profiles
- Macro-based color presets
