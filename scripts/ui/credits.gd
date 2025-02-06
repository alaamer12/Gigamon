extends Control

@onready var credits_container = $ScrollContainer/CreditsContainer
@onready var scroll_container = $ScrollContainer

var scroll_speed = 100
var auto_scroll = true
var credits_data = [
	{
		"title": "Game Design",
		"names": ["Your Name"]
	},
	{
		"title": "Programming",
		"names": ["Your Name"]
	},
	{
		"title": "Art Assets",
		"names": ["Your Name", "OpenGameArt Contributors"]
	},
	{
		"title": "Music",
		"names": ["Your Name", "OpenGameArt Contributors"]
	},
	{
		"title": "Sound Effects",
		"names": ["Your Name", "FreeSound Contributors"]
	},
	{
		"title": "Special Thanks",
		"names": ["Godot Engine", "The Godot Community", "Family & Friends"]
	}
]

func _ready():
	setup_credits()
	setup_animations()
	
	# Play credits music
	if FileAccess.file_exists("res://assets/audio/music/credits_theme.ogg"):
		AudioManager.play_music(preload("res://assets/audio/music/credits_theme.ogg"))

func _process(delta):
	if auto_scroll:
		scroll_container.scroll_vertical += scroll_speed * delta

func setup_credits():
	for section in credits_data:
		var title = Label.new()
		title.text = section.title
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 32)
		credits_container.add_child(title)
		
		for name in section.names:
			var name_label = Label.new()
			name_label.text = name
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_label.add_theme_font_size_override("font_size", 24)
			credits_container.add_child(name_label)
		
		# Add spacing
		var spacer = Control.new()
		spacer.custom_minimum_size.y = 50
		credits_container.add_child(spacer)

func setup_animations():
	# Fade in animation
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)
	
	# Add particle effects
	var particles = GPUParticles2D.new()
	add_child(particles)
	particles.position = Vector2(get_viewport_rect().size.x / 2, -50)
	
	# Setup particle material
	var particle_material = ParticleProcessMaterial.new()
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = get_viewport_rect().size.x / 2
	particle_material.direction = Vector3(0, 1, 0)
	particle_material.spread = 45.0
	particle_material.gravity = Vector3(0, 98, 0)
	particle_material.initial_velocity_min = 100.0
	particle_material.initial_velocity_max = 200.0
	particle_material.scale_min = 2.0
	particle_material.scale_max = 4.0
	particles.process_material = particle_material
	
	particles.amount = 50
	particles.lifetime = 5.0
	particles.emitting = true

func _on_back_button_pressed():
	auto_scroll = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))
	AudioManager.play_sfx(preload("res://assets/audio/sfx/button_click.wav"))

func _on_scroll_container_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			auto_scroll = !auto_scroll

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
