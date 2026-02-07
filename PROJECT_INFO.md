# Godot Library App - Project Information

## 📋 Project Overview
This is a **Godot 4** library/media organization app with a visual block-based interface. Users can create nested categories, organize items, add images, and switch between different layout views.

## 🎯 Main Features
1. **Visual Block Interface** - Items displayed as colored blocks with images or text
2. **Nested Navigation** - Create folders/categories and navigate through them
3. **Three Layout Types:**
   - Grid (3 columns)
   - List (single column)
   - Large Grid (2 columns)
4. **Search Functionality** - Filter items by name
5. **Image Support** - Add images to blocks (supports .png, .jpg, .jpeg, .gif, .webp)
6. **Edit Menu** - Three-dot menu for renaming, adding images, or deleting items
7. **Persistent Storage** - Data saved to JSON file (`user://library_data.json`)

## 📁 File Structure
- **Main Script:** `library-project-/main.gd`
- **Data Storage:** Saves to `user://library_data.json` (Godot user data directory)
- **Project Files:** Complete Godot project included

## ✅ Recent Fixes & Changes

### Fixed Issues:
1. **Close Button Bug (Feb 7, 2026)** - The X button on the three-dots menu popup wasn't working
   - Solution: Added `popup.close_requested.connect(func(): popup.queue_free())`

2. **Black Background Bug (Feb 7, 2026)** - Blocks turned black after reloading the app
   - Solution: Implemented proper color serialization - colors now convert to dictionaries {r, g, b, a} when saving and back to Color objects when loading

3. **Display Text Not Updating (Feb 7, 2026)** - When renaming blocks, the name on the label below updated but the text inside the block didn't change
   - Solution: Added `library_data[new_name]["display_text"] = new_name` to the rename function

## 🔧 Current Code Structure

### Key Variables:
- `library_data` - Main data structure storing all items and their properties
- `navigation_stack` - Tracks current navigation path
- `button_container` - Holds all visible blocks
- `search_text` - Current search query

### Key Functions:
- `show_level(level_name)` - Displays blocks for current folder
- `create_button(button_text, is_back_button, layout_type)` - Creates individual blocks
- `_show_edit_menu(item_name, origin)` - Shows the three-dot popup menu
- `save_library()` - Saves data with proper color serialization
- `load_library()` - Loads data and converts color dictionaries back to Color objects

### Data Structure Example:
```gdscript
library_data = {
    "root": {
        "children": ["Item1", "Item2"],
        "layout": "grid"
    },
    "Item1": {
        "children": [],
        "layout": "grid",
        "display_text": "Item1",
        "bg_color": {"r": 0.4, "g": 0.5, "b": 0.7, "a": 1.0},
        "image_path": ""
    }
}
```

## 🐛 Known Issues / Future Improvements
- Image navigation could be smoother
- No video playback support yet (only image display)
- Could add color picker for custom block colors
- Could add drag-and-drop to reorder items
- Could add export/import functionality

## 💡 How to Help Me with This Project

When starting a new chat, please:
1. Read this file first to understand the project
2. Look at `main.gd` in the `library-project-` folder
3. For any changes:
   - Provide the **complete updated file** (not just snippets)
   - Explain what was changed and why
   - Save it so I can download it easily

### Common Requests:
- "Fix [describe bug]" - I'll need you to update the code
- "Add [new feature]" - Describe what you want to add
- "The [thing] isn't working" - Explain what's happening vs. what should happen

## 📝 Development Notes
- Built with Godot 4.x
- Uses GDScript
- All UI created programmatically (no scene files for the library interface)
- Uses FileAccess for JSON storage
- Mouse hover detection for three-dot menu

## 🔄 Version History
- **v1.0** - Initial release with basic functionality
- **v1.1** - Fixed close button, black background bug, and display text update issue

---

**Last Updated:** February 7, 2026  
**GitHub Repository:** https://github.com/NO-NAME-J7/godot-library-app  
**Main Script:** `library-project-/main.gd`
