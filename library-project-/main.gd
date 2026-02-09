extends Control

var button_container = null
var navigation_stack = []
var layout_button = null
var add_button = null
var search_box = null
var search_text = ""
var current_menu = null
var export_button = null
var import_button = null
var tag_filter_box = null
var active_tag_filter = ""
var sort_button = null
var stats_button = null

# Drag and drop variables
var dragging_item = null
var drag_start_pos = Vector2.ZERO
var drag_threshold = 10.0
var is_dragging = false
var drag_visual = null

var library_data = {
	"root": {
		"children": [],
		"layout": "grid",
		"sort_type": "none"
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
	
	# Export button
	export_button = Button.new()
	export_button.text = "Export"
	export_button.position = Vector2(580, 20)
	export_button.size = Vector2(100, 50)
	add_child(export_button)
	export_button.pressed.connect(_on_export_pressed)
	
	# Import button
	import_button = Button.new()
	import_button.text = "Import"
	import_button.position = Vector2(700, 20)
	import_button.size = Vector2(100, 50)
	add_child(import_button)
	import_button.pressed.connect(_on_import_pressed)
	
	# Sort button
	sort_button = Button.new()
	sort_button.text = "Sort: None"
	sort_button.position = Vector2(820, 20)
	sort_button.size = Vector2(150, 50)
	add_child(sort_button)
	sort_button.pressed.connect(_on_sort_button_pressed)
	
	# Stats button
	stats_button = Button.new()
	stats_button.text = "Statistics"
	stats_button.position = Vector2(990, 20)
	stats_button.size = Vector2(120, 50)
	add_child(stats_button)
	stats_button.pressed.connect(_show_statistics)
	
	# Tag filter box
	tag_filter_box = LineEdit.new()
	tag_filter_box.placeholder_text = "Filter by tag..."
	tag_filter_box.position = Vector2(1130, 20)
	tag_filter_box.size = Vector2(200, 50)
	tag_filter_box.text_changed.connect(_on_tag_filter_changed)
	add_child(tag_filter_box)
	
	show_level("root")

func _process(_delta):
	if is_dragging and dragging_item != null:
		if drag_visual:
			drag_visual.global_position = get_global_mouse_position() - Vector2(75, 60)

func show_level(level_name):
	if button_container != null:
		button_container.queue_free()
	
	if not library_data.has(level_name):
		library_data[level_name] = {
			"children": [],
			"layout": "grid",
			"sort_type": "none"
		}
	
	var layout_type = library_data[level_name].get("layout", "grid")
	var sort_type = library_data[level_name].get("sort_type", "none")
	
	# Update sort button text
	var sort_text = "Sort: "
	if sort_type == "none":
		sort_text += "None"
	elif sort_type == "alphabetical":
		sort_text += "A-Z"
	elif sort_type == "date":
		sort_text += "Date"
	sort_button.text = sort_text
	
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
		var children_list = library_data[level_name]["children"].duplicate()
		
		# Apply sorting
		if sort_type == "alphabetical":
			children_list.sort()
		elif sort_type == "date":
			children_list.sort_custom(func(a, b):
				var date_a = library_data.get(a, {}).get("date_created", 0)
				var date_b = library_data.get(b, {}).get("date_created", 0)
				return date_a > date_b
			)
		
		for child_name in children_list:
			# Filter by search text
			if search_text != "" and not search_text in child_name.to_lower():
				continue
			
			# Filter by tag (including nested tags)
			if active_tag_filter != "":
				var item_tags = library_data.get(child_name, {}).get("tags", [])
				var has_tag = false
				for tag in item_tags:
					if active_tag_filter.to_lower() in tag.to_lower():
						has_tag = true
						break
					# Check parent tags for nested structure
					var tag_parts = tag.split("/")
					for part in tag_parts:
						if active_tag_filter.to_lower() in part.to_lower():
							has_tag = true
							break
					if has_tag:
						break
				if not has_tag:
					continue
			
			create_button(child_name, false, layout_type)

func create_button(button_text, is_back_button, layout_type):
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 5)
	container.set_meta("item_name", button_text)
	
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
	
	# Display video, image, or text
	if image_path != "" and FileAccess.file_exists(image_path):
		var file_ext = image_path.get_extension().to_lower()
		
		if file_ext in ["mp4", "webm", "mov", "ogv"]:
			# Video file - create video player
			var video_player = VideoStreamPlayer.new()
			video_player.custom_minimum_size = Vector2(block_width, block_height)
			video_player.expand = true
			
			# Try to load video
			var video_stream = load(image_path)
			if video_stream:
				video_player.stream = video_stream
				video_player.autoplay = true
				video_player.loop = true
				video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE
				btn.add_child(video_player)
			else:
				# Fallback: show "Video" text with play icon
				var video_label = Label.new()
				video_label.text = "▶ VIDEO"
				video_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				video_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				video_label.custom_minimum_size = Vector2(block_width, block_height)
				video_label.add_theme_color_override("font_color", Color.WHITE)
				video_label.add_theme_font_size_override("font_size", 24)
				video_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
				btn.add_child(video_label)
				
				# Add click to open externally
				btn.gui_input.connect(func(event):
					if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
						OS.shell_open(image_path)
				)
		else:
			# Image file
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
	
	# Three dots menu
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
		
		# Show/hide dots on hover
		btn.mouse_entered.connect(func(): dots_container.visible = true)
		btn.mouse_exited.connect(func(): dots_container.visible = false)
		dots_container.mouse_entered.connect(func(): dots_container.visible = true)
		dots_container.mouse_exited.connect(func(): dots_container.visible = false)
		
		# Drag and drop functionality
		btn.gui_input.connect(func(event):
			if event is InputEventMouseButton:
				if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					dragging_item = button_text
					drag_start_pos = event.global_position
					is_dragging = false
				elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					if is_dragging and dragging_item == button_text:
						_handle_drop(container)
					elif dragging_item == button_text and not is_dragging:
						# Regular click - navigate
						_on_button_pressed(button_text)
					dragging_item = null
					is_dragging = false
					if drag_visual:
						drag_visual.queue_free()
						drag_visual = null
			elif event is InputEventMouseMotion and dragging_item == button_text:
				if drag_start_pos.distance_to(event.global_position) > drag_threshold and not is_dragging:
					is_dragging = true
					_create_drag_visual(btn)
		)
	else:
		# Back button - regular click only
		btn.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_back_pressed()
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

func _create_drag_visual(source_panel):
	drag_visual = Panel.new()
	drag_visual.custom_minimum_size = source_panel.custom_minimum_size
	drag_visual.modulate = Color(1, 1, 1, 0.7)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.5, 0.5, 1.0, 0.8)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.3, 0.3, 0.8)
	drag_visual.add_theme_stylebox_override("panel", style)
	
	add_child(drag_visual)
	drag_visual.global_position = get_global_mouse_position() - Vector2(75, 60)

func _handle_drop(target_container):
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	var children = library_data[current_level]["children"]
	
	# Find which item we're hovering over
	var drop_target = null
	var mouse_pos = get_global_mouse_position()
	
	for child in button_container.get_children():
		if child.has_meta("item_name") and child.get_global_rect().has_point(mouse_pos):
			drop_target = child.get_meta("item_name")
			break
	
	if drop_target and drop_target != dragging_item and drop_target != "← Back":
		# Reorder
		var drag_index = children.find(dragging_item)
		var drop_index = children.find(drop_target)
		
		if drag_index != -1 and drop_index != -1:
			children.remove_at(drag_index)
			if drag_index < drop_index:
				drop_index -= 1
			children.insert(drop_index, dragging_item)
			
			# Override sort to custom when manually reordering
			library_data[current_level]["sort_type"] = "none"
			save_library()
			show_level(current_level)

func _show_edit_menu(item_name, origin):
	var popup = Window.new()
	popup.title = ""
	popup.size = Vector2(180, 220)
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
	
	# Edit Name
	var edit_btn = Button.new()
	edit_btn.text = "Edit Name"
	edit_btn.custom_minimum_size = Vector2(160, 30)
	edit_btn.pressed.connect(func():
		popup.queue_free()
		_edit_name_dialog(item_name)
	)
	vbox.add_child(edit_btn)
	
	# Add Image/Video
	var image_btn = Button.new()
	image_btn.text = "Add Image/Video"
	image_btn.custom_minimum_size = Vector2(160, 30)
	image_btn.pressed.connect(func():
		popup.queue_free()
		_add_image_dialog(item_name)
	)
	vbox.add_child(image_btn)
	
	# Remove Image
	var remove_image_btn = Button.new()
	remove_image_btn.text = "Remove Image"
	remove_image_btn.custom_minimum_size = Vector2(160, 30)
	remove_image_btn.pressed.connect(func():
		popup.queue_free()
		_remove_image(item_name)
	)
	vbox.add_child(remove_image_btn)
	
	# Change Color
	var color_btn = Button.new()
	color_btn.text = "Change Color"
	color_btn.custom_minimum_size = Vector2(160, 30)
	color_btn.pressed.connect(func():
		popup.queue_free()
		_color_picker_dialog(item_name)
	)
	vbox.add_child(color_btn)
	
	# Manage Tags
	var tags_btn = Button.new()
	tags_btn.text = "Manage Tags"
	tags_btn.custom_minimum_size = Vector2(160, 30)
	tags_btn.pressed.connect(func():
		popup.queue_free()
		_manage_tags_dialog(item_name)
	)
	vbox.add_child(tags_btn)
	
	# Duplicate
	var duplicate_btn = Button.new()
	duplicate_btn.text = "Duplicate"
	duplicate_btn.custom_minimum_size = Vector2(160, 30)
	duplicate_btn.pressed.connect(func():
		popup.queue_free()
		_duplicate_item(item_name)
	)
	vbox.add_child(duplicate_btn)
	
	# Delete
	var delete_btn = Button.new()
	delete_btn.text = "Delete"
	delete_btn.custom_minimum_size = Vector2(160, 30)
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

func _duplicate_item(item_name):
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	
	# Generate unique name for duplicate
	var counter = 1
	var new_name = item_name + " Copy"
	while library_data.has(new_name):
		counter += 1
		new_name = item_name + " Copy " + str(counter)
	
	# Copy all data
	var original_data = library_data[item_name]
	library_data[new_name] = {
		"children": original_data.get("children", []).duplicate(true),
		"layout": original_data.get("layout", "grid"),
		"display_text": new_name,
		"bg_color": original_data.get("bg_color", Color(0.4, 0.5, 0.7)),
		"image_path": original_data.get("image_path", ""),
		"tags": original_data.get("tags", []).duplicate(),
		"date_created": Time.get_unix_time_from_system()
	}
	
	library_data[current_level]["children"].append(new_name)
	save_library()
	show_level(current_level)

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
	file_dialog.filters = ["*.png, *.jpg, *.jpeg, *.gif, *.webp ; Images", "*.mp4, *.webm, *.mov, *.ogv ; Videos"]
	
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

func _remove_image(item_name):
	library_data[item_name]["image_path"] = ""
	save_library()
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	show_level(current_level)

func _color_picker_dialog(item_name):
	var dialog = Window.new()
	dialog.title = "Change Color"
	dialog.size = Vector2(400, 350)
	dialog.position = get_viewport().size / 2 - dialog.size / 2
	dialog.close_requested.connect(func(): dialog.queue_free())
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 40)
	vbox.add_theme_constant_override("separation", 15)
	
	var current_color = library_data[item_name].get("bg_color", Color(0.4, 0.5, 0.7))
	
	# Red slider
	var r_label = Label.new()
	r_label.text = "Red: " + str(current_color.r)
	vbox.add_child(r_label)
	
	var r_slider = HSlider.new()
	r_slider.custom_minimum_size = Vector2(360, 30)
	r_slider.min_value = 0.0
	r_slider.max_value = 1.0
	r_slider.step = 0.01
	r_slider.value = current_color.r
	vbox.add_child(r_slider)
	
	# Green slider
	var g_label = Label.new()
	g_label.text = "Green: " + str(current_color.g)
	vbox.add_child(g_label)
	
	var g_slider = HSlider.new()
	g_slider.custom_minimum_size = Vector2(360, 30)
	g_slider.min_value = 0.0
	g_slider.max_value = 1.0
	g_slider.step = 0.01
	g_slider.value = current_color.g
	vbox.add_child(g_slider)
	
	# Blue slider
	var b_label = Label.new()
	b_label.text = "Blue: " + str(current_color.b)
	vbox.add_child(b_label)
	
	var b_slider = HSlider.new()
	b_slider.custom_minimum_size = Vector2(360, 30)
	b_slider.min_value = 0.0
	b_slider.max_value = 1.0
	b_slider.step = 0.01
	b_slider.value = current_color.b
	vbox.add_child(b_slider)
	
	# Preview panel
	var preview_label = Label.new()
	preview_label.text = "Preview:"
	vbox.add_child(preview_label)
	
	var preview_panel = Panel.new()
	preview_panel.custom_minimum_size = Vector2(360, 60)
	var preview_style = StyleBoxFlat.new()
	preview_style.bg_color = current_color
	preview_panel.add_theme_stylebox_override("panel", preview_style)
	vbox.add_child(preview_panel)
	
	# Update preview on slider changes
	r_slider.value_changed.connect(func(value):
		r_label.text = "Red: " + str(snapped(value, 0.01))
		var new_color = Color(value, g_slider.value, b_slider.value)
		preview_style.bg_color = new_color
	)
	
	g_slider.value_changed.connect(func(value):
		g_label.text = "Green: " + str(snapped(value, 0.01))
		var new_color = Color(r_slider.value, value, b_slider.value)
		preview_style.bg_color = new_color
	)
	
	b_slider.value_changed.connect(func(value):
		b_label.text = "Blue: " + str(snapped(value, 0.01))
		var new_color = Color(r_slider.value, g_slider.value, value)
		preview_style.bg_color = new_color
	)
	
	# Buttons
	var btn_container = HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 10)
	
	var save_btn = Button.new()
	save_btn.text = "Save"
	save_btn.custom_minimum_size = Vector2(150, 35)
	save_btn.pressed.connect(func():
		var new_color = Color(r_slider.value, g_slider.value, b_slider.value)
		library_data[item_name]["bg_color"] = new_color
		save_library()
		var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
		show_level(current_level)
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

func _manage_tags_dialog(item_name):
	var dialog = Window.new()
	dialog.title = "Manage Tags"
	dialog.size = Vector2(400, 350)
	dialog.position = get_viewport().size / 2 - dialog.size / 2
	dialog.close_requested.connect(func(): dialog.queue_free())
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 40)
	vbox.add_theme_constant_override("separation", 10)
	
	var label = Label.new()
	label.text = "Tags (comma separated):"
	vbox.add_child(label)
	
	# Get current tags
	var current_tags = library_data[item_name].get("tags", [])
	var tags_text = ", ".join(current_tags)
	
	var input = TextEdit.new()
	input.text = tags_text
	input.custom_minimum_size = Vector2(360, 120)
	vbox.add_child(input)
	
	var info_label = Label.new()
	info_label.text = "Example: game, rpg, favorite\nNested: Games/RPG/Fantasy, Media/Videos"
	info_label.add_theme_font_size_override("font_size", 10)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_label.custom_minimum_size = Vector2(360, 40)
	vbox.add_child(info_label)
	
	var btn_container = HBoxContainer.new()
	btn_container.add_theme_constant_override("separation", 10)
	
	var save_btn = Button.new()
	save_btn.text = "Save"
	save_btn.custom_minimum_size = Vector2(150, 35)
	save_btn.pressed.connect(func():
		var tags_string = input.text.strip_edges()
		var tags_array = []
		if tags_string != "":
			for tag in tags_string.split(","):
				var clean_tag = tag.strip_edges()
				if clean_tag != "":
					tags_array.append(clean_tag)
		library_data[item_name]["tags"] = tags_array
		save_library()
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

func _show_statistics():
	var dialog = Window.new()
	dialog.title = "Library Statistics"
	dialog.size = Vector2(500, 600)
	dialog.position = get_viewport().size / 2 - dialog.size / 2
	dialog.close_requested.connect(func(): dialog.queue_free())
	
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(480, 560)
	scroll.position = Vector2(10, 10)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	
	# Calculate statistics
	var total_items = 0
	var items_with_images = 0
	var items_with_videos = 0
	var tag_counts = {}
	var items_with_tags = 0
	
	for key in library_data:
		if key == "root":
			continue
		total_items += 1
		
		var item = library_data[key]
		var image_path = item.get("image_path", "")
		
		if image_path != "":
			var ext = image_path.get_extension().to_lower()
			if ext in ["mp4", "webm", "mov", "ogv"]:
				items_with_videos += 1
			else:
				items_with_images += 1
		
		var tags = item.get("tags", [])
		if tags.size() > 0:
			items_with_tags += 1
			for tag in tags:
				if tag_counts.has(tag):
					tag_counts[tag] += 1
				else:
					tag_counts[tag] = 1
	
	# Title
	var title = Label.new()
	title.text = "📊 Library Statistics"
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var separator1 = HSeparator.new()
	vbox.add_child(separator1)
	
	# General Stats
	var general_label = Label.new()
	general_label.text = "General Statistics"
	general_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(general_label)
	
	var total_label = Label.new()
	total_label.text = "Total Items: " + str(total_items)
	vbox.add_child(total_label)
	
	var images_label = Label.new()
	images_label.text = "Items with Images: " + str(items_with_images)
	vbox.add_child(images_label)
	
	var videos_label = Label.new()
	videos_label.text = "Items with Videos: " + str(items_with_videos)
	vbox.add_child(videos_label)
	
	var text_only_label = Label.new()
	var text_only = total_items - items_with_images - items_with_videos
	text_only_label.text = "Text-only Items: " + str(text_only)
	vbox.add_child(text_only_label)
	
	var separator2 = HSeparator.new()
	vbox.add_child(separator2)
	
	# Tag Stats
	var tag_label = Label.new()
	tag_label.text = "Tag Statistics"
	tag_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(tag_label)
	
	var total_tags_label = Label.new()
	total_tags_label.text = "Unique Tags: " + str(tag_counts.size())
	vbox.add_child(total_tags_label)
	
	var tagged_items_label = Label.new()
	tagged_items_label.text = "Items with Tags: " + str(items_with_tags)
	vbox.add_child(tagged_items_label)
	
	# Most used tags
	if tag_counts.size() > 0:
		var most_used_label = Label.new()
		most_used_label.text = "\nMost Used Tags:"
		most_used_label.add_theme_font_size_override("font_size", 16)
		vbox.add_child(most_used_label)
		
		# Sort tags by count
		var sorted_tags = []
		for tag in tag_counts:
			sorted_tags.append({"tag": tag, "count": tag_counts[tag]})
		
		sorted_tags.sort_custom(func(a, b): return a["count"] > b["count"])
		
		# Show top 10
		var top_count = min(10, sorted_tags.size())
		for i in range(top_count):
			var tag_info = sorted_tags[i]
			var tag_item_label = Label.new()
			tag_item_label.text = str(i + 1) + ". " + tag_info["tag"] + " (" + str(tag_info["count"]) + " items)"
			vbox.add_child(tag_item_label)
	
	var separator3 = HSeparator.new()
	vbox.add_child(separator3)
	
	# Layout Stats
	var layout_label = Label.new()
	layout_label.text = "Layout Statistics"
	layout_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(layout_label)
	
	var grid_count = 0
	var list_count = 0
	var large_grid_count = 0
	
	for key in library_data:
		var layout = library_data[key].get("layout", "grid")
		if layout == "grid":
			grid_count += 1
		elif layout == "list":
			list_count += 1
		elif layout == "large_grid":
			large_grid_count += 1
	
	var grid_label = Label.new()
	grid_label.text = "Grid Layout: " + str(grid_count) + " folders"
	vbox.add_child(grid_label)
	
	var list_label = Label.new()
	list_label.text = "List Layout: " + str(list_count) + " folders"
	vbox.add_child(list_label)
	
	var large_label = Label.new()
	large_label.text = "Large Grid Layout: " + str(large_grid_count) + " folders"
	vbox.add_child(large_label)
	
	# Close button
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(200, 40)
	close_btn.pressed.connect(func(): dialog.queue_free())
	vbox.add_child(close_btn)
	
	scroll.add_child(vbox)
	dialog.add_child(scroll)
	add_child(dialog)
	dialog.popup()

func _on_export_pressed():
	var file_dialog = FileDialog.new()
	file_dialog.title = "Export Library"
	file_dialog.size = Vector2(600, 400)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.filters = ["*.json ; JSON Files"]
	
	file_dialog.file_selected.connect(func(path):
		var save_data = {}
		for key in library_data:
			var item = library_data[key].duplicate(true)
			if item.has("bg_color") and item["bg_color"] is Color:
				var color = item["bg_color"]
				item["bg_color"] = {"r": color.r, "g": color.g, "b": color.b, "a": color.a}
			save_data[key] = item
		
		var export_file = FileAccess.open(path, FileAccess.WRITE)
		if export_file:
			export_file.store_string(JSON.stringify(save_data, "\t"))
			export_file.close()
			print("Library exported to: " + path)
		file_dialog.queue_free()
	)
	
	file_dialog.canceled.connect(func(): file_dialog.queue_free())
	
	add_child(file_dialog)
	file_dialog.popup_centered()

func _on_import_pressed():
	var file_dialog = FileDialog.new()
	file_dialog.title = "Import Library"
	file_dialog.size = Vector2(600, 400)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.json ; JSON Files"]
	
	file_dialog.file_selected.connect(func(path):
		var import_file = FileAccess.open(path, FileAccess.READ)
		if import_file:
			var json = JSON.new()
			if json.parse(import_file.get_as_text()) == OK:
				library_data = json.data
				# Convert color dictionaries back to Color objects
				for key in library_data:
					if library_data[key].has("bg_color") and library_data[key]["bg_color"] is Dictionary:
						var c = library_data[key]["bg_color"]
						library_data[key]["bg_color"] = Color(c.get("r", 0.4), c.get("g", 0.5), c.get("b", 0.7), c.get("a", 1.0))
				save_library()
				show_level("root")
				navigation_stack.clear()
				print("Library imported from: " + path)
			import_file.close()
		file_dialog.queue_free()
	)
	
	file_dialog.canceled.connect(func(): file_dialog.queue_free())
	
	add_child(file_dialog)
	file_dialog.popup_centered()

func _on_tag_filter_changed(new_text):
	active_tag_filter = new_text.strip_edges()
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	show_level(current_level)

func _on_sort_button_pressed():
	var current_level = "root" if navigation_stack.size() == 0 else navigation_stack[-1]
	var current_sort = library_data[current_level].get("sort_type", "none")
	
	var sorts = ["none", "alphabetical", "date"]
	var current_index = sorts.find(current_sort)
	var next_index = (current_index + 1) % sorts.size()
	
	library_data[current_level]["sort_type"] = sorts[next_index]
	save_library()
	show_level(current_level)

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
		"bg_color": Color(0.4, 0.5, 0.7),
		"tags": [],
		"sort_type": "none",
		"date_created": Time.get_unix_time_from_system()
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
