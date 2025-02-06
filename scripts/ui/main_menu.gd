extends Control

@onready var background = $Background
@onready var buttons_container = $CenterContainer/ButtonsContainer
@onready var title_label = $TitleLabel

var background_images = []
var current_background_index = 0

func _ready():
	setup_backgrounds()
	setup_animations()
	setup_audio()

func setup_backgrounds():
	# Load background images
	var dir = DirAccess.open("res://assets/images/backgrounds")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".jpg") or file_name.ends_with(".png"):
				var texture = load("res://assets/images/backgrounds/" + file_name)
				if texture:
					background_images.append(texture)
			file_name = dir.get_next()
	
	if background_images.size() > 0:
		background.texture = background_images[0]

func setup_animations():
	# Title animation
	var title_tween = create_tween()
	title_tween.tween_property(title_label, "scale", Vector2(1.1, 1.1), 1.0)
	title_tween.tween_property(title_label, "scale", Vector2.ONE, 1.0)
	title_tween.set_loops()
	
	# Buttons animation
	for button in buttons_container.get_children():
		button.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(button, "modulate:a", 1.0, 0.5)
		tween.tween_interval(0.2)

func setup_audio():
	# Try to play menu music if it exists
	var music_path = "res://assets/audio/music/menu_theme.ogg"
	if ResourceLoader.exists(music_path):
		AudioManager.play_music(load(music_path))

func _on_play_button_pressed():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/game/game_board.tscn"))
	
	var sfx_path = "res://assets/audio/sfx/button_click.wav"
	if ResourceLoader.exists(sfx_path):
		AudioManager.play_sfx(load(sfx_path))

func _on_settings_button_pressed():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/ui/settings.tscn"))
	
	var sfx_path = "res://assets/audio/sfx/button_click.wav"
	if ResourceLoader.exists(sfx_path):
		AudioManager.play_sfx(load(sfx_path))

func _on_credits_button_pressed():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/ui/credits.tscn"))
	
	var sfx_path = "res://assets/audio/sfx/button_click.wav"
	if ResourceLoader.exists(sfx_path):
		AudioManager.play_sfx(load(sfx_path))

func _on_exit_button_pressed():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().quit())
	
	var sfx_path = "res://assets/audio/sfx/button_click.wav"
	if ResourceLoader.exists(sfx_path):
		AudioManager.play_sfx(load(sfx_path))

func _on_background_timer_timeout():
	var tween = create_tween()
	tween.tween_property(background, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func():
		current_background_index = (current_background_index + 1) % background_images.size()
		background.texture = background_images[current_background_index]
	)
	tween.tween_property(background, "modulate:a", 1.0, 1.0)

func _on_button_mouse_entered():
	var sfx_path = "res://assets/audio/sfx/button_hover.wav"
	if ResourceLoader.exists(sfx_path):
		AudioManager.play_sfx(load(sfx_path))
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
