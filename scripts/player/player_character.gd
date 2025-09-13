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
var dash_speed: float = 400.0

func _ready():
	player_input.spell_input_pressed.connect(on_spell_input_pressed)
	player_input.dash_input_pressed.connect(on_dash_input_pressed)

	player_spell_spawner.spell_cast.connect(on_spell_cast)

	staff_sprite.animation_finished.connect(on_staff_animation_finished)

	ap.animation_finished.connect(on_animation_finished)

func _physics_process(delta): # This can go in a state eventually
	aim_input = player_input.get_aim_input()

	update_player_aim()

	if not dashing:	
		move_input = player_input.get_movement_input()
		velocity = move_input * speed
		player_animation.update_animation(delta)
	
	move_and_slide()

func update_player_aim() -> void:
	if aim_input:
		player_aim.aim_input = aim_input
		player_aim.reticle_reset_timer.stop()
	else:
		player_aim.start_reticle_reset_timer()

	player_aim.update_aim()

func on_spell_input_pressed() -> void: # Use a func ref for this
	player_spell_spawner.spawn_spell(player_aim.aim_input)

func on_dash_input_pressed() -> void:
	if not dashing:
		dashing = true
		ap.play("dash")

		if move_input:
			if abs(move_input.x) > abs(move_input.y):
				var dash_direction: Vector2 = Vector2(1 * sign(move_input.x), 0)
				velocity = dash_direction * dash_speed

			else:
				var dash_direction: Vector2 = Vector2(0, 1 * sign(move_input.y))
				velocity = dash_direction * dash_speed

		else:
			velocity = Vector2(1,0) * dash_speed

func on_staff_animation_finished() -> void:
	staff_sprite.play("idle")
	
func on_spell_cast() -> void: 
	staff_sprite.play("fire")

func on_animation_finished(anim_name) -> void:
	if anim_name == "dash":
		dashing = false
