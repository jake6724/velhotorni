# Autoloader
extends Node

var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var track_1: AudioStreamOggVorbis = preload("res://audio/music/Theme-1_Auto.ogg")
# var track_2: AudioStreamOggVorbis = preload("res://audio/music/Theme-2_Auto.ogg")
var start_track = track_1

var volume_linear: float = .2
var bus_index: int

func _ready():
	# Configure music audio bus
	bus_index = AudioServer.get_bus_index("music")
	AudioServer.set_bus_volume_linear(bus_index, volume_linear)

	# Configure AudioStreamPlayer
	music_player.bus = "music"
	add_child(music_player)
	music_player.stream = track_1

	# Keep music running on pause
	process_mode = Node.PROCESS_MODE_ALWAYS

func update_bus_volume(new_volume_linear: float):
	AudioServer.set_bus_volume_linear(bus_index, new_volume_linear)