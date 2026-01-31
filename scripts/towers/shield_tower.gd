class_name ShieldTower
extends Tower

@onready var tower_shield_parent: Node2D = %TowerShieldParent

const TOWER_SHIELD_SCENE: PackedScene = preload("res://scenes/towers/TowerShield.tscn")
const ROTATION_SPEED_MULTIPLIER: float = 40.0
const NUM_OF_SHIELDS: int = 4

var shield_spawn_position_modifiers: Array[Vector2] = [Vector2(30,0), Vector2(-30,0), Vector2(0,30), Vector2(0,-30)]

func child_initialize() -> void:
	print("Test!")
	for i in range(NUM_OF_SHIELDS):
		var new_shield: TowerShield = TOWER_SHIELD_SCENE.instantiate()
		new_shield.global_position = (global_position + shield_spawn_position_modifiers[i])
		tower_shield_parent.add_child(new_shield)
		new_shield.z_index -= 1
		new_shield.ap.play("spawn")

		match i:
			0: pass
			1: new_shield.sprite.flip_h = true
			2: new_shield.rotation_degrees = 90
			3: new_shield.rotation_degrees = -90

func child_physics_process(delta: float) -> void:
	tower_shield_parent.rotation_degrees += (delta * ROTATION_SPEED_MULTIPLIER)

	if tower_shield_parent.rotation_degrees >= 360:
		tower_shield_parent.rotation_degrees -= 360
