extends Node2D
## Audio manager node. Inteded to be globally loaded as a 2D Scene. Handles [method create_2d_audio_at_location()] and 
## [method create_audio()] to handle the playback and culling of simultaneous sound effects.
## To properly use, define [enum SoundEffect.SOUND_EFFECT_TYPE] for each unique sound effect, 
## create a Node2D scene for this AudioManager script add those SoundEffect resources to this globally loaded script's [member sound_effects], 
## and setup your individual SoundEffect resources. Then, use [method create_2d_audio_at_location()] and [method create_audio()]
## to play those sound effects either at a specific location or globally.

var music_track_dict: Dictionary[MusicData.MUSIC_TRACK, MusicData] = {} ## Loads all registered SoundEffects on ready as a reference.

@export var music_data: Array[MusicData] ## Stores all possible MusicData that can be played.



var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	print(music_data)
	for data: MusicData in music_data:
		music_track_dict[data.track] = data

## Creates a sound effect if the limit has not been reached. Pass [param type] for the SoundEffect to be queued.
func create_audio(track: MusicData.MUSIC_TRACK) -> void:
	if music_track_dict.has(track):
		var data: MusicData = music_track_dict[track]
		var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(new_audio)
		new_audio.stream = data.sound
		new_audio.volume_db = data.volume
		# # new_audio.finished.connect(data.on_audio_finished)
		# new_audio.finished.connect(new_audio.queue_free)
		new_audio.play()
	else:
		push_error("Audio Manager failed to find setting for track ", track)
