# Autoloader
extends Node

var num_players: int = 128
var players: Array[AudioStreamPlayer] = []
var volume_linear: float = .2
var bus_index: int
signal victory_sfx_complete
signal base_explosion_sfx_complete

var sfxs: Dictionary[String, AudioStreamOggVorbis] = {
	"fire_shot": preload("res://assets/audio/sfx/Fire_Shot.ogg"),
	"water_shot": preload("res://assets/audio/sfx/Water_Shot.ogg"),
	"wind_shot": preload("res://assets/audio/sfx/wind_Shot .ogg"),
	"go": preload("res://assets/audio/sfx/Go_2.ogg"),
	"fire_select": preload("res://assets/audio/sfx/Fire_Selection.ogg"),
	"wind_select": preload("res://assets/audio/sfx/Wind_Selection.ogg"),
	"water_select": preload("res://assets/audio/sfx/Water_Selection.ogg"),
	"fire_explosion": preload("res://assets/audio/sfx/Fire_Explosion.ogg"),
	"wind_explosion": preload("res://assets/audio/sfx/Wind_Explosion.ogg"),
	"water_explosion": preload("res://assets/audio/sfx/Water_Explosion.ogg"),
	"click_1": preload("res://assets/audio/sfx/Click_1_8bit.ogg"),
	"click_2": preload("res://assets/audio/sfx/Click_2_8bit.ogg"),
	"fire_click": preload("res://assets/audio/sfx/Fire_Click.ogg"),
	"wind_click": preload("res://assets/audio/sfx/Wind_Click.ogg"),
	"water_click": preload("res://assets/audio/sfx/Water_Click.ogg"),
	"base_explosion": preload("res://assets/audio/sfx/Tower_Explosion.ogg"),
	"victory": preload("res://assets/audio/sfx/Victory_8bit.ogg"),
}

func _ready():
	# Configure SFX audio bus
	bus_index = AudioServer.get_bus_index("sfx")
	AudioServer.set_bus_volume_linear(bus_index, volume_linear)

	# Create num_players amount of AudioStreamPlayers
	for i in range(num_players):
		var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
		# new_player.volume_db = volume
		new_player.bus = "sfx"
		add_child(new_player)
		players.append(new_player)

func play_sfx(sfx_name: String):
	var sfx_stream: AudioStreamOggVorbis = sfxs[sfx_name]
	var p: AudioStreamPlayer = get_best_player()
	p.stream = sfx_stream
	p.play()

	await p.finished
	if sfx_name == "victory":
		victory_sfx_complete.emit()
	elif sfx_name == "base_explosion":
		base_explosion_sfx_complete.emit()

func play_sfx_resource(sfx_res: AudioStreamOggVorbis):
	var p: AudioStreamPlayer = get_best_player()
	p.stream = sfx_res
	p.play()

## Return the first available or least recently used AudioStreamPlayer
func get_best_player() -> AudioStreamPlayer:
	# Check if there are any used players
	for p: AudioStreamPlayer in players:
		if not p.playing:
			return p

	# If none free, find the least recently used
	var max_playback_position: float = INF
	var lru_player: AudioStreamPlayer
	for p: AudioStreamPlayer in players:
		if p.get_playback_position() < max_playback_position:
			max_playback_position = p.get_playback_position()
			lru_player = p

	return lru_player

func update_bus_volume(new_volume_linear: float):
	AudioServer.set_bus_volume_linear(bus_index, new_volume_linear)
