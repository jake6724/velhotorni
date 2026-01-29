class_name PlayerAudio
extends AudioStreamPlayer2D

var bus_index: int

var audio: Dictionary[String, AudioStreamOggVorbis] = {
	"basic": preload("res://assets/audio/sfx/player/spells/player_basic_arcane.ogg")
}

var sfx_tpye_footstep_default: SoundEffect.SOUND_EFFECT_TYPE = SoundEffect.SOUND_EFFECT_TYPE.FOOTSTEP_GRASS
var sfx_tpye_footstep: SoundEffect.SOUND_EFFECT_TYPE = sfx_tpye_footstep_default:
	set(value):
		print("Setting sfx_tpye_footstep to: ", value)
		sfx_tpye_footstep = value

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

func play_footstep() -> void:
	print("sfx_tpye_footstep: ", sfx_tpye_footstep)
	AudioManager.create_audio(sfx_tpye_footstep)
