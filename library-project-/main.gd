extends Control

var button_container = null
var navigation_stack = []
var layout_button = null
var add_button = null
var search_box = null
var search_text = ""

var library_data = {
	"root": {
		"children": [],
		"layout": "grid"
	}
}

func _ready():
	print("Library app started!")
	load_library()
	
	layout_button = Button.new()
	layout_button.text = "Change Layout"
	layout_button.position = Vector2(50, 20)
	layout_button.size = Vector2(150, 50)
	add_child(layout_button)
	layout_button.pressed.connect(_on_layout_button_pressed)
	
	add_button = Button.new()
	add_button.text = "+ New"
	add_button.position = Vector2(220, 20)
	add_button.size = Vector2(120, 50)
	add_child(add_button)
	add_button.pressed.connect(_on_add_button_pressed)
	
	search_box = LineEdit.new()
	search_box.placeholder_text = "Search..."
	search_box.position = Vector2(360, 20)
	search_box.size = Vector2(200, 50)
	search_box.text_changed.connect(_on_search_changed)
	add_child(search_box)
	
	show_level("root")

func show_level(level_name):
	if button_container != null:
		button_container.queue_free()
	
	if not library_data.has(level_name):
		library_data[level_name] = {
			"children": [],
			"layout": "grid"
		}
	
	var layout_type = library_data[level_name].get("layout", "grid")
	
	if layout_type == "grid":
		button_container = GridContainer.new()
		button_container.columns = 3
		button_container.add_theme_constant_override("h_separation", 20)
		button_container.add_theme_constant_override("v_separation", 20)
	elif layout_type == "list":
		button_container = VBoxContainer.new()
		button_container.add_theme_constant_override("separation", 10)
	elif layout_type == "large_grid":
		button_container = GridContainer.new()
		button_container.columns = 2
		button_container.add_theme_constant_override("h_separation", 30)
		button_container.add_theme_constant_override("v_separation", 30)
	
	button_container.position = Vector2(50, 100)
	add_child(button_container)
	
	if navigation_stack.size() > 0:
		create_button("← Back", true, layout_type)
	
	if library_data[level_name].has("children"):
		for child_name in library_data[level_name]["children"]:
			if search_text == "" or search_text in child_name.to_lower():
				create_button(child_name, false, layout_type)

func create_button(button_text, is_back_button, layout_type):
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 5)
	
	var btn = Panel.new()
	
	var block_width = 150
	var block_height = 120
	if layout_type == "list":
		block_width = 300
		block_height = 80
	elif layout_type == "large_grid":
		block_width = 250
		block_height = 180
	
	btn.custom_minimum_size = Vector2(block_width, block_height)
	container.custom_minimum_size = Vector2(block_width, block_height + 40)
	
	var item_data = library_data.get(button_text, {})
	var display_text = item_data.get("display_text", button_text)
	var bg_color = item_data.get("bg_color", Color(0.4, 0.5, 0.7))
	var image_path = item_data.get("image_path", "")
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = bg_color
	style_normal.corner_radius_top_left = 15
	style_normal.corner_radius_top_right = 15
	style_normal.corner_radius_bottom_left = 15
	style_normal.corner_radius_bottom_right = 15
	style_normal.border_width_left = 2
	style_normal.border_width_right = 2
	style_normal.border_width_top = 2
	style_normal.border_width_bottom = 2
	style_normal.border_color = Color(0.3, 0.4, 0.6)
	
	if is_back_button:
		style_normal.bg_color = Color(0.5, 0.5, 0.5)
	
	btn.add_theme_stylebox_override("panel", style_normal)
	
	# Display image or text
	if image_path != "" and FileAccess.file_exists(image_path):
		var texture_rect = TextureRect.new()
		var img = Image.load_from_file(image_path)
		if img:
			var texture = ImageTexture.create_from_image(img)
			texture_rect.texture = texture
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.custom_minimum_size = Vector2(block_width, block_height)
			texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.add_child(texture_rect)
	elif not is_back_button:
		var label = Label.new()
		label.text = display_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size = Vector2(block_width - 20, block_height)
		label.position = Vector2(10, 0)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 18)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(label)
	elif is_back_button:
		var label = Label.new()
		label.text = "← Back"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.custom_minimum_size = Vector2(block_width, block_height)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 18)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(label)
	
	# Three dots - FIXED
	var dots_container = Control.new()
	dots_container.size = Vector2(35, 35)
	dots_container.position = Vector2(block_width - 40, 5)
	dots_container.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var menu_label = Label.new()
	menu_label.text = "⋮"
	menu_label.size = Vector2(35, 35)
	menu_label.add_theme_font_size_override("font_size", 28)
	menu_label.add_theme_color_override("font_color", Color.WHITE)
	menu_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	menu_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dots_container.add_child(menu_label)
	dots_container.visible = false
	
	if not is_back_button:
		dots_container.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_show_edit_menu(button_text, dots_container)
		)
		btn.add_child(dots_container)
		
		# Show/hide dots - SIMPLE VERSION
		btn.mouse_entered.connect(func(): dots_container.visible = true)
		btn.mouse_exited.connect(func(): dots_container.visible = false)
		dots_container.mouse_entered.connect(func(): dots_container.visible = true)
		dots_container.mouse_exited.connect(func(): dots_container.visible = false)
	
	# Click to navigate
	btn.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if is_back_button:
				_on_back_pressed()
			else:
				_on_button_pressed(button_text)
	)
	
	container.add_child(btn)
	
	# Name under block
	if not is_back_button:
		var name_label = Label.new()
		var short_name = button_text
		if button_text.length() > 25:
			short_name = button_text.substr(0, 22) + "..."
		name_label.text = short_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		name_label.custom_minimum_size = Vector2(block_width, 35)
		name_label.add_theme_font_size_override("font_size", 12)
		container.add_child(name_label)
	
	button_container.add_child(container)

func _show_edit_menu(item_name, origin):
	var popup = Window.new()
	popup.title = ""
	popup.size = Vector2(180, 140)
	popup.unresizable = true
	popup.borderless = false
	popup.transient = true
	popup.exclusive = false
	popup.close_requested.connect(func(): popup.queue_free())
	
	var global_pos = origin.global_position
	popup.position = Vector2i(global_pos.x + 40, global_pos.y)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.position = Vector2(10, 10)
	
	var edit_btn = Button.new()
	edit_btn.text = "Edit Name"
	edit_btn.custom_minimum_size = Vector2(160, 35)
	edit_btn.pressed.connect(func():
		popup.queue_free()
		_edit_name_dialog(item_name)
	)
	vbox.add_child(edit_btn)
	
	var image_btn = Button.new()
	image_btn.text = "Add Image/Video"
	image_btn.custom_minimum_size = Vector2(160, 35)
	image_btn.pressed.connect(func():
		popup.queue_free()
		_add_image_dialog(item_name)
	)
	vbox.add_child(image_btn)
	
	var delete_btn = Button.new()
	delete_btn.text = "Delete"
	delete_btn.custom_minimum_size = Vector2(160, 35)
	var delete_style = StyleBoxFlat.new()
	delete_style.bg_color = Color(0.8, 0.2, 0.2)
	delete_style.corner_radius_top_left = 5
	delete_style.corner_radius_top_right = 5
	delete_style.corner_radius_bottom_left = 5
	delete_style.corner_radius_bottom_right = 5
	delete_btn.add_theme_stylebox_override("normal", delete_style)
	delete_btn.add_theme_color_override("font_color", Color.WHITE)
	delete_btn.pressed.connect(func():
		popup.queue_free()
		_on_delete_pressed(item_name)
	)
	vbox.add_child(delete_btn)
	
	popup.add_child(vbox)
	add_child(popup)
	popup.popup()

func _edit_name_dialog(item_name):
	var dialog = Window.new()
	dialog.title = "Edit Name"
	dialog.size = Vector2(350, 180)
	dialog.position = get_viewport().size / 2 - dialog.size / 2
	dialog.close_requested.connect(func(): dialog.queue_free())
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 40)
	vbox.add_theme_constant_override("separation", 10)
	
	var label = Label.new()
	label.text = "New name:"
	vbox.add_child(label)
	
	var input = LineEdit.new()
	input.text = item_name
	input.custom_minimum_size = Vector2(310, 35)
	vbox.add_child(input)
	
	var btn_container = HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 10)
	
	var save_btn = Button.new()
	save_btn.text = "Save"
	save_btn.custom_minimum_size = Vector2(150, 35)
	save_btn.pressed.connect(func():
		_rename_item(item_name, input.text)
		dialog.queue_free()
	)
	btn_container.add_child(save_btn)
	
	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(150, 35)
	cancel_btn.pressed.connect(func(): dialog.queue_free())
	btn_container.add_child(cancel_btn)
	
	vbox.add_child(btn_container)
	dialog.add_child(vbox)
	add_child(dialog)
	dialog.popup()

func _add_image_dialog(item_name):
	var file_dialog = FileDialog.new()
	file_dialog.title = "Select Image/Video"
	file_dialog.size = Vector2(600, 400)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.png, *.jpg, *.jpeg, *.gif, *.webp ; Images", "*.mp4, *.webm, *.mov ; Videos"]
	
	file_dialog.file_selected.connect(func(path):
		library_data[item_name]["image_path"] = path
		save_library()
		var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
		show_level(current_level)
		file_dialog.queue_free()
	)
	
	file_dialog.canceled.connect(func(): file_dialog.queue_free())
	
	add_child(file_dialog)
	file_dialog.popup_centered()

func _rename_item(old_name, new_name):
	if new_name == "" or new_name == old_name:
		return
	
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	var children = library_data[current_level]["children"]
	var index = children.find(old_name)
	if index != -1:
		children[index] = new_name
		library_data[new_name] = library_data[old_name]
		library_data[new_name]["display_text"] = new_name
		library_data.erase(old_name)
		save_library()
		show_level(current_level)

func _on_button_pressed(button_name):
	navigation_stack.append(button_name)
	show_level(button_name)

func _on_back_pressed():
	if navigation_stack.size() > 0:
		navigation_stack.pop_back()
		var previous_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
		show_level(previous_level)

func _on_layout_button_pressed():
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	var current_layout = library_data[current_level].get("layout", "grid")
	var layouts = ["grid", "list", "large_grid"]
	var next_index = (layouts.find(current_layout) + 1) % layouts.size()
	library_data[current_level]["layout"] = layouts[next_index]
	save_library()
	show_level(current_level)

func _on_add_button_pressed():
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	var counter = 1
	var new_item_name = "New " + str(counter)
	while library_data.has(new_item_name):
		counter += 1
		new_item_name = "New " + str(counter)
	
	library_data[current_level]["children"].append(new_item_name)
	library_data[new_item_name] = {
		"children": [],
		"layout": "grid",
		"display_text": new_item_name,
		"bg_color": Color(0.4, 0.5, 0.7)
	}
	save_library()
	show_level(current_level)

func _on_search_changed(new_text):
	search_text = new_text.to_lower()
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	show_level(current_level)

func _on_delete_pressed(item_name):
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	library_data[current_level]["children"].erase(item_name)
	library_data.erase(item_name)
	save_library()
	show_level(current_level)

func save_library():
	var save_data = {}
	for key in library_data:
		var item = library_data[key].duplicate(true)
		if item.has("bg_color") and item["bg_color"] is Color:
			var color = item["bg_color"]
			item["bg_color"] = {"r": color.r, "g": color.g, "b": color.b, "a": color.a}
		save_data[key] = item
	
	var save_file = FileAccess.open("user://library_data.json", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()

func load_library():
	if FileAccess.file_exists("user://library_data.json"):
		var save_file = FileAccess.open("user://library_data.json", FileAccess.READ)
		if save_file:
			var json = JSON.new()
			if json.parse(save_file.get_as_text()) == OK:
				library_data = json.data
				# Convert color dictionaries back to Color objects
				for key in library_data:
					if library_data[key].has("bg_color") and library_data[key]["bg_color"] is Dictionary:
						var c = library_data[key]["bg_color"]
						library_data[key]["bg_color"] = Color(c.get("r", 0.4), c.get("g", 0.5), c.get("b", 0.7), c.get("a", 1.0))
			save_file.close()
