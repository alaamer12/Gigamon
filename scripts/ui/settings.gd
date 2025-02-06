extends Control

@onready var master_slider = $SettingsContainer/AudioSettings/MasterSlider
@onready var music_slider = $SettingsContainer/AudioSettings/MusicSlider
@onready var sfx_slider = $SettingsContainer/AudioSettings/SFXSlider
@onready var fullscreen_check = $SettingsContainer/VideoSettings/FullscreenCheck
@onready var vsync_check = $SettingsContainer/VideoSettings/VSyncCheck
@onready var resolution_option = $SettingsContainer/VideoSettings/ResolutionOption

var config = ConfigFile.new()
var settings_path = "user://settings.cfg"

# Available resolutions
var resolutions = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

func _ready():
	setup_ui()
	load_settings()
	connect_signals()
	add_test_sound_effects()

func setup_ui():
	# Setup resolution options
	for resolution in resolutions:
		resolution_option.add_item("%dx%d" % [resolution.x, resolution.y])
	
	# Setup sliders
	master_slider.max_value = 1.0
	music_slider.max_value = 1.0
	sfx_slider.max_value = 1.0
	
	# Add hover effects to buttons
	for button in get_tree().get_nodes_in_group("settings_button"):
		button.mouse_entered.connect(_on_button_hover)

func connect_signals():
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)
	resolution_option.item_selected.connect(_on_resolution_selected)

func add_test_sound_effects():
	# Add a timer to play test sounds when adjusting volume
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)
	
	master_slider.drag_ended.connect(func(_value_changed): play_test_sound())
	music_slider.drag_ended.connect(func(_value_changed): play_test_music())
	sfx_slider.drag_ended.connect(func(_value_changed): play_test_sound())
	
	timer.timeout.connect(func(): AudioManager.stop_music())

func load_settings():
	var err = config.load(settings_path)
	if err == OK:
		# Audio settings
		master_slider.value = config.get_value("audio", "master_volume", 1.0)
		music_slider.value = config.get_value("audio", "music_volume", 1.0)
		sfx_slider.value = config.get_value("audio", "sfx_volume", 1.0)
		
		# Video settings
		var fullscreen = config.get_value("video", "fullscreen", false)
		fullscreen_check.button_pressed = fullscreen
		
		var vsync = config.get_value("video", "vsync", true)
		vsync_check.button_pressed = vsync
		
		var resolution_index = config.get_value("video", "resolution", 1)
		resolution_option.selected = resolution_index
		
		apply_video_settings()
	else:
		# Set default values
		master_slider.value = 1.0
		music_slider.value = 1.0
		sfx_slider.value = 1.0
		fullscreen_check.button_pressed = false
		vsync_check.button_pressed = true
		resolution_option.selected = 1

func save_settings():
	# Audio settings
	config.set_value("audio", "master_volume", master_slider.value)
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	
	# Video settings
	config.set_value("video", "fullscreen", fullscreen_check.button_pressed)
	config.set_value("video", "vsync", vsync_check.button_pressed)
	config.set_value("video", "resolution", resolution_option.selected)
	
	config.save(settings_path)

func apply_video_settings():
	if fullscreen_check.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	DisplayServer.window_set_vsync_mode(VSyncMode.ENABLED if vsync_check.button_pressed else VSyncMode.DISABLED)
	
	var selected_resolution = resolutions[resolution_option.selected]
	get_window().size = selected_resolution

func _on_master_volume_changed(value):
	AudioManager.set_master_volume(value)

func _on_music_volume_changed(value):
	AudioManager.set_music_volume(value)

func _on_sfx_volume_changed(value):
	AudioManager.set_sfx_volume(value)

func _on_fullscreen_toggled(button_pressed):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if button_pressed else DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()

func _on_vsync_toggled(button_pressed):
	DisplayServer.window_set_vsync_mode(VSyncMode.ENABLED if button_pressed else VSyncMode.DISABLED)
	save_settings()

func _on_resolution_selected(index):
	get_window().size = resolutions[index]
	save_settings()

func _on_back_button_pressed():
	save_settings()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))

func _on_button_hover():
	AudioManager.play_sfx(preload("res://assets/audio/sfx/button_hover.wav"))

func play_test_sound():
	AudioManager.play_sfx(preload("res://assets/audio/sfx/button_click.wav"))

func play_test_music():
	AudioManager.play_music(preload("res://assets/audio/music/menu_theme.ogg"))
	var timer = get_node_or_null("Timer")
	if timer:
		timer.start()
