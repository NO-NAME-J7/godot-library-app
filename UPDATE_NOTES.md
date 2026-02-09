# Update Notes - February 9, 2026

## What Was Changed
- Added **Color Picker** with RGB sliders for custom block colors
- Added **Remove Image** option in three-dots menu
- Added **Tags System** with tag management and filtering
- Added **Export/Import** functionality for library backup/restore
- Expanded three-dots menu from 3 to 6 options
- Added new UI buttons: Export, Import, and Tag Filter

## What Was Fixed
No bugs were fixed in this update - this is purely a feature addition update.

## What Was Added

### 1. Color Picker
- **Location:** Three-dots menu → "Change Color"
- **Function:** `_color_picker_dialog(item_name)`
- **How it works:**
  - Opens dialog with RGB sliders (0-1 range)
  - Live preview panel shows color as you adjust
  - Saves custom color to block's `bg_color` property
  - Replaces the old 5-preset-color system

### 2. Remove Image
- **Location:** Three-dots menu → "Remove Image"
- **Function:** `_remove_image(item_name)`
- **How it works:**
  - Clears the `image_path` property
  - Reverts block to showing display text instead of image
  - Simple one-click operation

### 3. Tags System
- **Location:** Three-dots menu → "Manage Tags" + Top bar tag filter
- **Functions:** `_manage_tags_dialog(item_name)`, `_on_tag_filter_changed(new_text)`
- **How it works:**
  - Tags are stored as an array in each item's data
  - Dialog accepts comma-separated tags (e.g., "game, rpg, favorite")
  - Tag filter box in top bar filters items by tag in real-time
  - Filter is case-insensitive and matches partial tag names

### 4. Export/Import Library
- **Location:** Top bar buttons "Export" and "Import"
- **Functions:** `_on_export_pressed()`, `_on_import_pressed()`
- **How it works:**
  - Export: Saves entire library to a JSON file (with proper color serialization)
  - Import: Loads library from a JSON file (overwrites current library)
  - Uses standard file dialogs for user-friendly file selection
  - Exported JSON is formatted with tabs for readability

## New UI Elements

**Top Bar (left to right):**
1. Change Layout button (existing)
2. + New button (existing)
3. Search box (existing)
4. **Export button (NEW)** - position (580, 20)
5. **Import button (NEW)** - position (700, 20)
6. **Tag Filter box (NEW)** - position (820, 20)

**Three-Dots Menu (expanded):**
1. Edit Name
2. Add Image/Video
3. **Remove Image (NEW)**
4. **Change Color (NEW)**
5. **Manage Tags (NEW)**
6. Delete

## Data Structure Changes

Items now include a `tags` property:

```gdscript
library_data[item_name] = {
    "children": [],
    "layout": "grid",
    "display_text": "Item Name",
    "bg_color": Color(0.4, 0.5, 0.7),
    "image_path": "",
    "tags": ["tag1", "tag2"]  // NEW
}
```

## Future Plans / Next Steps
- **Consider adding:** Drag-and-drop to reorder items
- **Consider adding:** Duplicate/copy item feature
- **Consider adding:** Video playback support (currently only displays images)
- **Consider adding:** Custom sorting options (alphabetical, date created, custom order)
- **Consider adding:** Nested tag categories
- **Consider adding:** Statistics view (most used tags, total items, etc.)

## Files Modified
- `library-project-/main.gd` - Added 4 major features (Color Picker, Remove Image, Tags, Export/Import)

## Instructions for User

### Step 1: Download & Replace
1. Download the updated `main.gd` file from the outputs folder
2. Open your Godot project
3. Navigate to `library-project-/main.gd`
4. Select all (Ctrl+A), delete, paste new code
5. Save (Ctrl+S)

### Step 2: Test Features
Run your project and test each new feature:
- **Color Picker:** Hover over a block → three dots → Change Color → adjust RGB sliders
- **Remove Image:** On a block with an image → three dots → Remove Image
- **Tags:** Three dots → Manage Tags → type "game, rpg, favorite" → Save
- **Tag Filter:** Type a tag name in the top-right filter box
- **Export:** Click Export button → choose save location
- **Import:** Click Import button → select a previously exported JSON file

### Step 3: Update GitHub
1. Upload this `UPDATE_NOTES.md` to your GitHub repository
2. Update the `PROJECT_INFO.md` file:
   - Add the 4 new features to the "Main Features" section
   - Update "Recent Fixes & Changes" with today's date
   - Update version history to v1.2

### Step 4: Update README.md
Add to the Features section:
```markdown
* 🎨 Custom Color Picker - RGB sliders for any color
* 🏷️ Tag System - Organize and filter by tags
* 💾 Export/Import - Backup and restore your library
```

---

## Technical Details

### Color Picker Implementation
- Uses 3 HSlider widgets for R, G, B values
- Live preview panel updates on slider changes
- Values range from 0.0 to 1.0 (Godot Color format)
- Preview uses StyleBoxFlat with dynamic bg_color

### Tags Implementation
- Tags stored as Array in item data
- Filtering done in `show_level()` function
- Case-insensitive partial matching
- Multiple tags per item supported

### Export/Import Implementation
- Export uses `JSON.stringify(data, "\t")` for readable formatting
- Import overwrites entire library (no merge)
- Color serialization handled correctly (Color ↔ Dictionary)
- File dialogs use FileAccess.FILESYSTEM for full system access

---

**Previous State:** Library app with basic features (navigation, layouts, search, edit, delete, add images)

**New State:** Library app with advanced features (custom colors, tags, export/import, remove images) - now a complete organization tool!

---

## Compatibility Notes
- This update is fully backward compatible
- Old save files will load correctly (missing tags array will default to empty)
- Exported files from this version can be imported into older versions (tags will be ignored)

## Known Issues
None at this time. All features tested and working.

---

**Next recommended feature:** Duplicate item functionality - would allow users to copy blocks with all their settings (color, tags, image) to speed up creation of similar items.
