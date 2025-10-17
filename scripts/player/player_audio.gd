class_name PlayerAudio
extends AudioStreamPlayer2D

var bus_index: int

var audio: Dictionary[String, AudioStreamOggVorbis] = {
	"basic": preload("res://assets/audio/sfx/player/spells/player_basic_arcane.ogg")
}

func _ready():
	# Connect to Bus
	bus_index = AudioServer.get_bus_index("sfx")
	max_polyphony = 64
	bus = "sfx"

func play_audio_stream(_stream: AudioStreamOggVorbis) -> void:
	stream = _stream
	play()

func play_audio_by_name(audio_name: String) -> void:
	stream = audio[audio_name]
	play()