extends Node2D
## Audio manager node. Inteded to be globally loaded as a 2D Scene. Handles [method create_2d_audio_at_location()] and 
## [method create_audio()] to handle the playback and culling of simultaneous sound effects.
## To properly use, define [enum SoundEffect.SOUND_EFFECT_TYPE] for each unique sound effect, 
## create a Node2D scene for this AudioManager script add those SoundEffect resources to this globally loaded script's [member sound_effects], 
## and setup your individual SoundEffect resources. Then, use [method create_2d_audio_at_location()] and [method create_audio()]
## to play those sound effects either at a specific location or globally.

var music_track_dict: Dictionary[MusicData.MUSIC_TRACK, MusicData] = {} ## Loads all registered SoundEffects on ready as a reference.

@export var music_data: Array[MusicData] ## Stores all possible MusicData that can be played.

@export var music_player: AudioStreamPlayer

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for data: MusicData in music_data:
		music_track_dict[data.track] = data

## Creates a sound effect if the limit has not been reached. Pass [param type] for the SoundEffect to be queued.
func create_audio(track: MusicData.MUSIC_TRACK) -> void:
	if music_track_dict.has(track):
		var data: MusicData = music_track_dict[track]
		# var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		# add_child(new_audio)
		music_player.stream = data.sound
		music_player.volume_db = data.volume
		# # new_audio.finished.connect(data.on_audio_finished)
		# new_audio.finished.connect(new_audio.queue_free)
		music_player.play()
	else:
		push_error("Audio Manager failed to find setting for track ", track)

func fade(new_track: MusicData.MUSIC_TRACK) -> void:
	var fade_tween: Tween = get_tree().create_tween()
	fade_tween.tween_property(music_player, "volume_linear", 0.0, 1.0)
	await fade_tween.finished
	create_audio(new_track)
	# var fade_in_tween: Tween = get_tree().create_tween()
	# fade_in_tween.tween_property(music_player, "volume_linear", music_player.volume_linear, 0.0)
