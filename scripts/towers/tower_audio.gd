class_name TowerAudio
extends AudioStreamPlayer2D

var element: Constants.Element

var sfxs: Dictionary[String, AudioStreamOggVorbis] = {
	"fire_shot": preload("res://assets/audio/sfx/Fire_Shot.ogg"),
	"wind_shot": preload("res://assets/audio/sfx/Wind_Shot.ogg"),
	"water_shot": preload("res://assets/audio/sfx/Water_Shot.ogg"),
	"earth_shot": preload("res://assets/audio/sfx/Rock_Shoot.ogg"),
	"light_shot": preload("res://assets/audio/sfx/Light_Shoot.ogg"),
}

var shot_sfx: AudioStreamOggVorbis

func initialize():
	bus = "sfx"
	max_polyphony = 32

	match element:
		Constants.Element.FIRE: shot_sfx = sfxs["fire_shot"]
		Constants.Element.WIND: shot_sfx = sfxs["wind_shot"]
		Constants.Element.WATER: shot_sfx = sfxs["water_shot"]
		Constants.Element.EARTH: shot_sfx = sfxs["earth_shot"]
		Constants.Element.LIGHT: shot_sfx = sfxs["light_shot"]
		_: pass

func play_shot() -> void:
	stream = shot_sfx
	play()
