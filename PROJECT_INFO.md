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

---

## 🤖 INSTRUCTIONS FOR AI ASSISTANTS

**CRITICAL: Read this section carefully before helping with this project!**

### How to Deliver Code Changes

**ALWAYS follow this workflow:**

1. **Read the current code** from GitHub first:
   - Fetch and read `library-project-/main.gd` from the repository
   - Understand what the user wants to change/fix

2. **Make ALL changes** to the code

3. **Provide the COMPLETE file** to the user:
   - ✅ **DO:** Create a full, complete `.gd` file with ALL the code (all ~400+ lines)
   - ✅ **DO:** Use the `create_file` tool and save to `/mnt/user-data/outputs/`
   - ✅ **DO:** Give the user a downloadable file they can copy/paste entirely
   - ❌ **DON'T:** Show just snippets or "replace line X with Y" instructions
   - ❌ **DON'T:** Show partial code that requires the user to find and edit specific lines
   - ❌ **DON'T:** Give inline code examples in the chat without a complete downloadable file

4. **AUTOMATICALLY create an UPDATE_NOTES file** (see section below)

5. **Explain briefly** what changed:
   - List the bugs/features you addressed
   - Mention which functions were modified
   - Keep it short and friendly

### ⚠️ MANDATORY: Always Create Update Notes

**EVERY TIME you make changes to the code, you MUST create an UPDATE_NOTES.md file.**

This is NOT optional - the user needs this to track changes over time.

**Format for UPDATE_NOTES.md:**

```markdown
# Update Notes - [Date]

## What Was Changed
- [List each change made]
- [Be specific about which functions/features were modified]

## What Was Fixed
- [List bugs that were fixed]
- [Explain what the bug was and how it was solved]

## What Was Added
- [List new features added]
- [Explain what they do]

## Future Plans / Next Steps
- [Suggest what could be done next]
- [List any known issues that still need fixing]

## Files Modified
- `library-project-/main.gd` - [brief description of changes]

## Instructions for User
1. Download the updated `main.gd` file
2. Replace the old file in your Godot project
3. Upload this UPDATE_NOTES.md to your GitHub repository for future reference
4. Update the "Recent Fixes & Changes" section in PROJECT_INFO.md if needed

---
**Previous State:** [Brief description of code before changes]
**New State:** [Brief description of code after changes]
```

**Important:**
- Create this file using `create_file` tool
- Save it to `/mnt/user-data/outputs/UPDATE_NOTES.md`
- Use `present_files` to share it with the user
- Do NOT make the user ask for this - ALWAYS include it automatically
- This keeps everyone on the same page about what's been done

### Why This Matters

The user needs to:
- Track what has been changed over time
- Know what to do with the update notes (upload to GitHub)
- Have a record of all modifications
- Not have to ask in a separate chat about what changed

By providing update notes automatically, you help the user maintain a clear history of the project's evolution.

### Response Template

```
**Fixed! Here's the complete updated code:**

[create_file tool with complete main.gd code]
[create_file tool with UPDATE_NOTES.md]
[present_files tool to share both files]

**What I changed:**
- Fixed [bug name]
- Added [feature name]

**What to do:**
1. Download main.gd - copy/paste into Godot
2. Download UPDATE_NOTES.md - upload to GitHub for your records
3. Test the changes!
```

### Why Complete Files Matter

The user has difficulty finding and editing specific lines in code. They need the complete file so they can:
- Select all (Ctrl+A)
- Copy (Ctrl+C)  
- Paste into Godot script editor
- Done!

### Common User Requests

- **"Fix this bug"** → Read code from GitHub, fix it, provide complete file + update notes
- **"Add this feature"** → Read code, add feature, provide complete file + update notes
- **"Something isn't working"** → Ask for clarification, then read code, fix, provide complete file + update notes

### Communication Style
- Be friendly and conversational
- Keep explanations brief
- Don't overwhelm with technical details
- Focus on making it easy for the user to implement changes
- Always provide update notes automatically

### When User Uploads Code vs. GitHub
- **If user uploads code directly:** Work with that version
- **If user shares GitHub link:** Fetch the latest version from GitHub first
- **If unsure which is current:** Ask the user or check GitHub

---

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

**For AI Assistants:**
1. Always provide complete downloadable files, not code snippets!
2. Always create UPDATE_NOTES.md automatically with every code change!
3. Keep the user informed about what to do with the files!
