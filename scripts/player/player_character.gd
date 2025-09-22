class_name PlayerCharacter
extends CharacterBody2D

# Components
@onready var player_aim: PlayerAim = $PlayerAim
@onready var player_animation: PlayerAnimation = $PlayerAnimation
@onready var player_input: PlayerCharacterInput = $PlayerCharacterInput
@onready var player_spell_spawner: PlayerSpellSpawner = $SpellSpawner

@onready var ap: AnimationPlayer = $AnimationPlayer

@onready var spell_spawn_point: Node2D = $StaffSprite/SpellSpawnPoint

@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var staff_sprite: AnimatedSprite2D = $StaffSprite
@onready var reticle_sprite: AnimatedSprite2D = $ReticleSprite

@onready var coin_collector: CoinCollector = $CoinCollector

var speed: float = 100.0

var move_input: Vector2
var aim_input: Vector2
var prev_aim_input: Vector2

var dashing: bool = false
var dash_velocity: float = 400.0

var prev_grid_position


## Emitted when the grid point the player position converts to changes.
## Specifically when `WorldGrid.world_to_grid(player.global_position)` != `player prev_grid_pos`
signal grid_position_changed

func _ready():
	player_input.spell_input_pressed.connect(on_spell_input_pressed)
	player_input.dash_input_pressed.connect(on_dash_input_pressed)

	player_spell_spawner.spell_cast.connect(on_spell_cast)
	staff_sprite.animation_finished.connect(on_staff_animation_finished)
	ap.animation_finished.connect(on_animation_finished)

func _physics_process(delta): # This can go in a state eventually
	aim_input = player_input.get_aim_input()
	update_player_aim(delta)

	if not dashing:	
		move_input = player_input.get_movement_input()
		if move_input:
			lock_move_input()
		velocity = move_input.normalized() * speed
		player_animation.update_animation(delta)
	
	move_and_slide()

	var grid_pos: Vector2 = WorldGrid.world_to_grid(global_position)
	if  grid_pos != prev_grid_position:
		grid_position_changed.emit()
		prev_grid_position = grid_pos

func update_player_aim(delta) -> void:
	if aim_input:
			player_aim.aim_input = aim_input						
	else:
		player_aim.reset_reticle_position(delta)

	player_aim.update_aim()

## Rounds move_input to whole numbers. Makes player move in only 8 directions. Creates a deadzone from 0 to .5, since all values below .5 round down to 0
func lock_move_input() -> void:
	move_input = move_input.round()

func on_spell_input_pressed() -> void: # Use a func ref for this
	player_spell_spawner.spawn_spell(player_aim.aim_input)

func on_dash_input_pressed() -> void:
	if not dashing:
		dashing = true
		ap.play("dash")
		
		if move_input:	
			velocity = move_input.normalized() * dash_velocity
		else:
			velocity = player_aim.aim_input.normalized() * dash_velocity

func on_staff_animation_finished() -> void:
	staff_sprite.play("idle")
	
func on_spell_cast() -> void: 
	staff_sprite.play("fire")

func on_animation_finished(anim_name) -> void:
	if anim_name == "dash":
		dashing = false
