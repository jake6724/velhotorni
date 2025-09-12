class_name PlayerCharacter
extends CharacterBody2D

# Components
@onready var player_aim: PlayerAim = $PlayerAim
@onready var player_animation: PlayerAnimation = $PlayerAnimation
@onready var player_input: PlayerCharacterInput = $PlayerCharacterInput

@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var staff_sprite: AnimatedSprite2D = $StaffSprite
@onready var reticle_sprite: AnimatedSprite2D = $ReticleSprite

@onready var spell_spawner: PlayerSpellSpawner = $SpellSpawner

var speed: float = 100.0

var move_direction: Vector2
var aim_direction: Vector2

var dashing: bool = false
var dash_speed: float = 400.0
var dash_timer: Timer = Timer.new()
var dash_time: float = .1

func _ready():
	player_input.spell_cast.connect(on_spell_cast)
	player_input.dash_cast.connect(on_dash_cast)

	dash_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
	dash_timer.autostart = false
	dash_timer.timeout.connect(on_dash_timer_timeout)
	add_child(dash_timer)

func _physics_process(delta): # This can go in a state eventually
	if not dashing:
		aim_direction = player_input.get_aim_input()
		move_direction = player_input.get_movement_input()

		velocity = move_direction * speed
		player_aim.update_aim(delta)
		player_animation.update_animation(delta)

	move_and_slide()

func on_spell_cast() -> void: # Use a func ref for this
	spell_spawner.spawn_spell(aim_direction)

func on_dash_cast() -> void:
	dashing = true
	dash_timer.start(dash_time)

	if move_direction:
		if abs(move_direction.x) > abs(move_direction.y):
			var dash_direction: Vector2 = Vector2(1 * sign(move_direction.x), 0)
			velocity = dash_direction * dash_speed
			print("dash_direction: ", dash_direction)

		else:
			var dash_direction: Vector2 = Vector2(0, 1 * sign(move_direction.y))
			velocity = dash_direction * dash_speed

			print("dash_direction: ", dash_direction)

	else:
		velocity = Vector2(1,0) * dash_speed

func on_dash_timer_timeout() -> void:
	dashing = false
