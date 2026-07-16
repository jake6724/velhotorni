class_name ShieldTower
extends Tower

@onready var tower_shield_parent: Node2D = %TowerShieldParent

const TOWER_SHIELD_SCENE: PackedScene = preload("res://scenes/towers/TowerShield.tscn")
const NUM_OF_SHIELDS: int = 4

var rotation_speed_multiplier: float = 40.0
var shield_health: float 

var shield_spawn_position_modifiers: Array[Vector2] = [Vector2(30,0), Vector2(-30,0), Vector2(0,30), Vector2(0,-30)]
var shield_ready_count: int = 0

## Only used internally to ensure that disabling all shields only occurs after the shields have been created
signal shield_setup_complete

func child_initialize() -> void:
	update_shield_tower_data()
	WaveManager.wave_completed.connect(spawn_shields)
	await shield_setup_complete
	set_all_shield_colliders_disabled(true)

func child_physics_process(delta: float) -> void:
	tower_shield_parent.rotation_degrees += (delta * rotation_speed_multiplier)
	if tower_shield_parent.rotation_degrees >= 360:
		tower_shield_parent.rotation_degrees -= 360

func spawn_shields() -> void:
	shield_ready_count = 0
	# Kill all exists tower shields
	for i in range(tower_shield_parent.get_child_count()):
		var tower_shield: TowerShield = tower_shield_parent.get_children()[i]
		tower_shield.die()

	# Ensure tower_shield_parent has no references to its previous children
	for child in tower_shield_parent.get_children():
		tower_shield_parent.remove_child(child)

	# Spawn new shields and connect to ready signals
	for i in range(NUM_OF_SHIELDS):
		var new_shield: TowerShield = TOWER_SHIELD_SCENE.instantiate()
		new_shield.ready.connect(on_shield_ready)
		tower_shield_parent.call_deferred("add_child", new_shield)
	
## Called each time a new tower shield ready signal emits. Perform set up for all shields once the last one has emitted
## its ready signal
func on_shield_ready() -> void:
	shield_ready_count += 1
	if shield_ready_count == NUM_OF_SHIELDS:
		set_physics_process(false)
		tower_shield_parent.rotation_degrees = 0
		var shields = tower_shield_parent.get_children()
		for i in range(shields.size()):
			shields[i].z_index -= 1
			shields[i].initialize(shield_health)
			shields[i].global_position = (tower_shield_parent.global_position + shield_spawn_position_modifiers[i])
			match i:
				1: shields[i].sprite.flip_h = true
				2: shields[i].rotation_degrees = 90
				3: shields[i].rotation_degrees = -90
		set_physics_process(true)
		shield_setup_complete.emit()

func set_all_shield_colliders_disabled(_value: bool) -> void:
	for tower_shield: TowerShield in tower_shield_parent.get_children():
		tower_shield.collider.set_deferred("disabled", _value)

func update_shield_tower_data() -> void:
	shield_health = (data.shield_health + (level * data.shield_health_per_level))
	rotation_speed_multiplier = (data.rotation_speed_multiplier + (level * data.rotation_speed_per_level))
	spawn_shields()
