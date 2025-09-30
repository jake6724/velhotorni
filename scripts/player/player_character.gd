class_name PlayerCharacter
extends CharacterBody2D

# Components
@onready var player_aim: PlayerAim = $PlayerAim
@onready var player_animation: PlayerAnimation = $PlayerAnimation
@onready var player_input: PlayerCharacterInput = $PlayerCharacterInput
@onready var player_spell_spawner: PlayerSpellSpawner = $SpellSpawner
@onready var player_stats: PlayerCharacterStats = $PlayerCharacterStats
@onready var player_hurtbox: Area2D = $PlayerHurtbox
@onready var player_camera: PlayerCamera = %PlayerCamera
@onready var player_audio: PlayerAudio = %PlayerAudio

# # State Machines
# @onready var player_movement_state_machine: PlayerStateMachineMovement = %PlayerMovementStateMachine

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var staff_ap: AnimationPlayer = $StaffAnimationPlayer

@onready var spell_spawn_point: Node2D = $StaffSprite/SpellSpawnPoint

@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var staff_sprite: Sprite2D = $StaffSprite
@onready var reticle_sprite: AnimatedSprite2D = $ReticleSprite
@onready var coin_collector: CoinCollector = $CoinCollector

var move_input: Vector2
var aim_input: Vector2
var prev_aim_input: Vector2

var dashing: bool = false
var dash_velocity: float = 400.0

var hit: bool = false

func _ready():
	player_input.spell_input_pressed.connect(on_spell_input_pressed)
	player_input.dash_input_pressed.connect(on_dash_input_pressed)
	player_input.switch_selection_pressed.connect(on_switch_selection_pressed)

	player_spell_spawner.spell_cast.connect(on_spell_cast)
	player_spell_spawner.staff_switched.connect(on_staff_switched)

	staff_ap.animation_finished.connect(on_staff_animation_finished)
	ap.animation_finished.connect(on_animation_finished)

	player_hurtbox.damage_recieved.connect(on_damage_recieved)
	player_hurtbox.hit.connect(on_hit)

func _physics_process(delta): # This can go in a state eventually
	aim_input = player_input.get_aim_input()
	update_player_aim(delta)

	if not hit:
		if not dashing:	
			move_input = player_input.get_movement_input()
			if move_input:
				lock_move_input()
			velocity = move_input.normalized() * player_stats.speed
			player_animation.update_animation(delta)

	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta*300)
		if velocity == Vector2.ZERO:
			hit = false
			player_hurtbox.collider.set_deferred("disabled", false)
	
	move_and_slide()

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
		player_camera.apply_shake(.8)
		player_hurtbox.collider.set_deferred("disabled", true)
		
		if move_input:	
			velocity = move_input.normalized() * dash_velocity
		elif player_aim.aim_input:
			velocity = player_aim.aim_input.round().normalized() * dash_velocity
		else:
			velocity = Vector2(1,0) * dash_velocity

func on_switch_selection_pressed(_switch_direction) -> void:
	player_spell_spawner.switch_spell(_switch_direction)

func on_staff_animation_finished(_anim_name) -> void:
	staff_ap.play("idle")
	
func on_spell_cast() -> void: 
	staff_ap.play("fire")

func on_staff_switched(_spell_type: SpellData.Type) -> void:
	match _spell_type:
		SpellData.StaffType.ARCANE: 
			staff_sprite.texture.region = Rect2(0,0,217,15)
			staff_sprite.rotation_degrees = 0
			staff_sprite.offset += Vector2(4, 0)

		SpellData.StaffType.WATER_SWORD: 
			staff_sprite.texture.region = Rect2(0,15,217,15)
			# staff_sprite.rotation_degrees = -90
			# staff_sprite.offset = Vector2(8, .5)

	staff_ap.play("idle")

func on_animation_finished(anim_name) -> void:
	if anim_name == "dash":
		dashing = false
		player_hurtbox.collider.set_deferred("disabled", false)

func on_damage_recieved(_damage) -> void:
	player_stats.health -= _damage

func on_hit(_direction) -> void:
	if not hit:
		player_hurtbox.collider.set_deferred("disabled", true)
		hit = true
		velocity = _direction * player_stats.knockback_multiplier

		player_camera.apply_shake(1)
		TimeManager.apply_hitstop()
