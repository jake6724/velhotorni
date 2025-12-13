class_name PlayerClone
extends Node2D

"""
Steals a bunch of data from player character and its children to mimic the player
"""

var player: PlayerCharacter # Set manually by PlayerSpecial
@onready var clone_sprite: Sprite2D = %CloneSprite
@onready var ap: AnimationPlayer = %AnimationPlayer
@onready var staff_sprite: StaffSprite = %StaffSprite
@onready var clone_staff_ap: AnimationPlayer = %StaffAnimationPlayer
@onready var spell_spawn_point: Node2D = %SpellSpawnPoint

var reset_timer: Timer = Timer.new()

func _ready():
	ap.play("idle")
	staff_sprite.switch_staff_texture(player.player_spell_spawner.curr_spell_data.staff_type)
	clone_staff_ap.animation_finished.connect(on_staff_animation_finished)

	add_child(reset_timer)
	reset_timer.autostart = false
	reset_timer.one_shot = true

func _physics_process(_delta):
	rotate_staff()
	flip_sprite()
	update_spell_spawn_point()

func rotate_staff() -> void:
	if player.player_aim.aim_input:
		# Rotate staff to point at aim direction
		staff_sprite.rotation = player.player_aim.aim_input.angle() + deg_to_rad(player.player_aim.staff_rotation_offset_degrees) * player.player_aim.staff_rotation_sign

		# Set staff render order based on aim direction and horizontal axis
		if player.player_aim.aim_input.normalized().y < 0:
			staff_sprite.z_index = player.character_sprite.z_index - 1
		else:
			staff_sprite.z_index = player.character_sprite.z_index + 1

	# Render staff behind player if moving up in all cases
	if player.velocity.y < 0:
		staff_sprite.z_index = player.character_sprite.z_index - 1

	if not player.can_fire:
		staff_sprite.z_index = player.character_sprite.z_index + 1

func swing_staff() -> void:
	var tween: Tween = get_tree().create_tween()
	var target = staff_sprite.rotation_degrees + player.player_aim.SWING_DEGREE_INCREMENT
	tween.tween_property(staff_sprite, "rotation_degrees", target, player.player_aim.SWING_ROTATION_SPEED)

func flip_sprite() -> void:
	if player.player_aim.aim_input:
		var flip = player.player_aim.aim_input.x <= -0.001
		clone_sprite.flip_h = flip
		staff_sprite.flip_v = flip

func update_spell_spawn_point() -> void:
	if player.player_aim.aim_input:
		spell_spawn_point.global_position = global_position + (player.player_aim.aim_input.normalized() * player.player_aim.SPELL_SPAWN_POINT_DISTANCE)

func on_spell_cast() -> void:
	clone_staff_ap.play("fire")

func on_staff_switched(_spell_type: SpellData.StaffType) -> void:
	clone_staff_ap.play("switch")
	await clone_staff_ap.animation_finished
	staff_sprite.switch_staff_texture(_spell_type)

func show_staff_sprite_custom(): 
	if player.staff_sprite.visible:
		staff_sprite.show()

func on_staff_animation_finished(_anim_name) -> void:
	if _anim_name == "switch":
		clone_staff_ap.play("idle")

	if _anim_name == "fire":
		clone_staff_ap.play("idle")
