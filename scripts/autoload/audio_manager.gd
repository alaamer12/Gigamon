extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const SFX_PLAYERS_COUNT = 8

# Audio bus indices
const MASTER_BUS = 0
const MUSIC_BUS = 1
const SFX_BUS = 2

# Volume settings
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

func _ready():
	setup_audio_system()

func setup_audio_system():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create SFX players pool
	for i in SFX_PLAYERS_COUNT:
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

func play_music(stream: AudioStream):
	if music_player.stream != stream:
		music_player.stream = stream
	if !music_player.playing:
		music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(stream: AudioStream):
	for player in sfx_players:
		if !player.playing:
			player.stream = stream
			player.play()
			return
	# If all players are busy, use the first one
	sfx_players[0].stream = stream
	sfx_players[0].play()

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(MASTER_BUS, linear_to_db(master_volume))

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(MUSIC_BUS, linear_to_db(music_volume))

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(SFX_BUS, linear_to_db(sfx_volume))

func save_audio_settings() -> Dictionary:
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}

func load_audio_settings(settings: Dictionary):
	if settings.has("master_volume"):
		set_master_volume(settings.master_volume)
	if settings.has("music_volume"):
		set_music_volume(settings.music_volume)
	if settings.has("sfx_volume"):
		set_sfx_volume(settings.sfx_volume)
