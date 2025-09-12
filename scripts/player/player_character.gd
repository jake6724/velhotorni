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

var speed: float = 100.0

var move_direction: Vector2
var aim_direction: Vector2
var prev_aim_direction: Vector2

var dashing: bool = false
var dash_speed: float = 400.0

func _ready():
	player_input.spell_input_pressed.connect(on_spell_input_pressed)
	player_input.dash_input_pressed.connect(on_dash_input_pressed)

	player_spell_spawner.spell_cast.connect(on_spell_cast)

	staff_sprite.animation_finished.connect(on_staff_animation_finished)

	ap.animation_finished.connect(on_animation_finished)

func _physics_process(delta): # This can go in a state eventually
	if not dashing:
		move_direction = player_input.get_movement_input()
		aim_direction = player_input.get_aim_input()

		if aim_direction:
			prev_aim_direction = aim_direction

		velocity = move_direction * speed
		player_aim.update_aim(delta)
		player_animation.update_animation(delta)
	
	move_and_slide()

func on_spell_input_pressed() -> void: # Use a func ref for this
	if aim_direction:
		player_spell_spawner.spawn_spell(aim_direction)
	else:
		player_spell_spawner.spawn_spell(prev_aim_direction)

func on_dash_input_pressed() -> void:
	if not dashing:
		dashing = true
		ap.play("dash")

		if move_direction:
			if abs(move_direction.x) > abs(move_direction.y):
				var dash_direction: Vector2 = Vector2(1 * sign(move_direction.x), 0)
				velocity = dash_direction * dash_speed

			else:
				var dash_direction: Vector2 = Vector2(0, 1 * sign(move_direction.y))
				velocity = dash_direction * dash_speed

		else:
			velocity = Vector2(1,0) * dash_speed

func on_staff_animation_finished() -> void:
	staff_sprite.play("idle")
	
func on_spell_cast() -> void: 
	staff_sprite.play("fire")

func on_animation_finished(anim_name) -> void:
	print("test")
	if anim_name == "dash":
		dashing = false
