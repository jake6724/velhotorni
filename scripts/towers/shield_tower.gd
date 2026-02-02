class_name ShieldTower
extends Tower

@onready var tower_shield_parent: Node2D = %TowerShieldParent

const TOWER_SHIELD_SCENE: PackedScene = preload("res://scenes/towers/TowerShield.tscn")
const ROTATION_SPEED_MULTIPLIER: float = 40.0
const NUM_OF_SHIELDS: int = 4

var shield_spawn_position_modifiers: Array[Vector2] = [Vector2(30,0), Vector2(-30,0), Vector2(0,30), Vector2(0,-30)]

func child_initialize() -> void:
	spawn_shields()
	WaveManager.wave_completed.connect(spawn_shields)
# func _input(event):
# 	if Input.is_action_just_pressed("g"):
# 		spawn_shields()

func child_physics_process(delta: float) -> void:
	tower_shield_parent.rotation_degrees += (delta * ROTATION_SPEED_MULTIPLIER)
	if tower_shield_parent.rotation_degrees >= 360:
		tower_shield_parent.rotation_degrees -= 360

func spawn_shields() -> void:
	for i in range(tower_shield_parent.get_child_count()):
		var tower_shield: TowerShield = tower_shield_parent.get_children()[i]
		tower_shield.die()

		if i == (tower_shield_parent.get_child_count() - 1):
			await tower_shield.tree_exited
			print("Child exited")

	for i in range(NUM_OF_SHIELDS):
		var new_shield: TowerShield = TOWER_SHIELD_SCENE.instantiate()
		if i == (NUM_OF_SHIELDS-1):
			new_shield.ready.connect(on_shield_ready)
		tower_shield_parent.call_deferred("add_child", new_shield)
	
func on_shield_ready() -> void:
	print("Last Shield is ready!")
	set_physics_process(false)
	tower_shield_parent.rotation_degrees = 0
	var shields = tower_shield_parent.get_children()
	
	print(shields)
	for i in range(NUM_OF_SHIELDS):
		shields[i].z_index -= 1
		shields[i].global_position = (tower_shield_parent.global_position + shield_spawn_position_modifiers[i])
		match i:
			1: shields[i].sprite.flip_h = true
			2: shields[i].rotation_degrees = 90
			3: shields[i].rotation_degrees = -90
	set_physics_process(true)
