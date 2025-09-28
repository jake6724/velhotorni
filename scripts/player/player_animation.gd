class_name PlayerAnimation
extends Node2D

# This implementation is based on this video: https://www.youtube.com/watch?v=iElHZhOxGYA

@export var animation_tree: AnimationTree
@onready var player: PlayerCharacter = get_owner()

var last_facing_direction: Vector2 = Vector2(0, -1)

func _ready():
	animation_tree.active = true

func update_animation(_delta):
	var idle = !player.velocity

	if !idle:
		last_facing_direction = player.velocity.normalized()

	animation_tree.set("parameters/Walk/blend_position", last_facing_direction)
	animation_tree.set("parameters/Idle/blend_position", last_facing_direction)