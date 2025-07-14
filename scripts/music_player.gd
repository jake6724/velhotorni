# Autoloader
extends Node

var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var bus_volume_linear: float = .4
var bus_index: int
var prev_player_volume_linear = .4

var track_1: AudioStreamOggVorbis = preload("res://audio/music/Theme-1_Auto.ogg")
var track_2: AudioStreamOggVorbis = preload("res://audio/music/Theme_2_8bit.ogg")
var tracks: Array[AudioStreamOggVorbis] = [track_1, track_1, track_2]
var active_track: AudioStreamOggVorbis

signal fade_out_complete
signal fade_in_complete

func _ready():
	# Keep music running MusicPlayer on pause
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Configure music audio bus
	bus_index = AudioServer.get_bus_index("music")
	AudioServer.set_bus_volume_linear(bus_index, bus_volume_linear)

	# Configure AudioStreamPlayer
	music_player.bus = "music"
	add_child(music_player)
	update_active_track()

func update_active_track():
	fade_out()
	await fade_out_complete
	active_track = tracks[GameManager.level_index]
	music_player.stream = active_track
	music_player.play()
	fade_in()
	await fade_in_complete

func update_bus_volume(new_bus_volume_linear: float):
	AudioServer.set_bus_volume_linear(bus_index, new_bus_volume_linear)

func fade_out(fade_duration: float=.25) -> void:
	if bus_volume_linear == 0:
		prev_player_volume_linear = 0
	else:
		prev_player_volume_linear = music_player.volume_linear
	
	var fade_tween = create_tween()
	AudioServer.set_bus_volume_linear(bus_index, bus_volume_linear)
	fade_tween.tween_property(music_player, "volume_linear", 0, fade_duration)
	await fade_tween.finished
	fade_out_complete.emit()

# The problem is I want to tween a property of AudioServer that can't really be tweened the normal way

func fade_in(fade_duration: float=.25) -> void:
	var fade_tween = create_tween()
	fade_tween.tween_property(music_player, "volume_linear", bus_volume_linear, fade_duration).from(0)
	await fade_tween.finished
	fade_in_complete.emit()
