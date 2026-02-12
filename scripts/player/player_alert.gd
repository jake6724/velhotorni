class_name PlayerAlert
extends Node

@onready var player: PlayerCharacter = get_owner()

## Tracks each sprite and their target as (arrow, target pos)
var arrow_and_alert: Array[Array] = [] 
var arrow_data: Dictionary[Alert, Sprite2D] = {}

const ALERT_ARROW_TEXTURE: Texture2D = preload("res://assets/art/sprites/ui/spr_ui_notification_arrow.png")
const ALERT_ARROW_OFFSET_X: float = 32.0

func _process(_delta):
	for pair: Array in arrow_and_alert:
		pair[0].look_at(pair[1].global_position)

func create_alert_arrow(_alert: Alert) -> void:
	var new_arrow: Sprite2D = Sprite2D.new()
	arrow_data[_alert] = new_arrow
	arrow_and_alert.append([new_arrow, _alert])
	new_arrow.texture = ALERT_ARROW_TEXTURE
	new_arrow.z_index = Constants.z_index_map["popup"]
	add_child(new_arrow)
	new_arrow.global_position = player.global_position
	new_arrow.offset.x = ALERT_ARROW_OFFSET_X
	new_arrow.look_at(_alert.global_position)
	AudioManager.create_2d_audio_at_location(player.global_position, SoundEffect.SOUND_EFFECT_TYPE.ALERT)

func remove_alert_arrow(_alert: Alert) -> void:
	if arrow_data.has(_alert):
		arrow_data[_alert].queue_free()
		arrow_data.erase(_alert)
		for pair: Array in arrow_and_alert:
			if pair[1] == _alert:
				arrow_and_alert.remove_at(arrow_and_alert.find(pair))