# Autoloader
extends Node

var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var bus_volume_linear: float = .4
var bus_index: int
var prev_player_volume_linear = .4

var track_1: AudioStreamOggVorbis = preload("res://assets/audio/music/Theme-1_Auto.ogg")
var track_2: AudioStreamOggVorbis = preload("res://assets/audio/music/Theme_2_8bit.ogg")
var tracks: Array[AudioStreamOggVorbis] = [track_1, track_1, track_2]
var active_track: AudioStreamOggVorbis = track_1

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

	# Configure tracks to play back-to-back
	music_player.finished.connect(on_track_finished)

	# Start
	music_player.stream = active_track
	music_player.play()

func update_bus_volume(new_bus_volume_linear: float):
	AudioServer.set_bus_volume_linear(bus_index, new_bus_volume_linear)

func on_track_finished():
	if active_track == track_1:
		active_track = track_2
		music_player.stream = active_track
		await get_tree().create_timer(.5).timeout
		music_player.play()
	else:
		active_track = track_1
		music_player.stream = active_track
		await get_tree().create_timer(.5).timeout
		music_player.play()

func fade_out(fade_duration: float=.25) -> void:
	# Make sure vars for subsequent fade in are 0 if required
	if bus_volume_linear == 0:
		prev_player_volume_linear = 0
	else:
		prev_player_volume_linear = music_player.volume_linear
	
	var fade_tween = create_tween()
	AudioServer.set_bus_volume_linear(bus_index, bus_volume_linear)
	fade_tween.tween_property(music_player, "volume_linear", 0, fade_duration)
	await fade_tween.finished
	fade_out_complete.emit()

func fade_in(fade_duration: float=.25) -> void:
	var fade_tween = create_tween()
	fade_tween.tween_property(music_player, "volume_linear", prev_player_volume_linear, fade_duration).from(0)
	await fade_tween.finished
	fade_in_complete.emit()

# func update_active_track():
# 	fade_out()
# 	await fade_out_complete
# 	active_track = tracks[LevelManager.level_index]
# 	music_player.stream = active_track
# 	music_player.play()
# 	fade_in()
# 	await fade_in_complete
