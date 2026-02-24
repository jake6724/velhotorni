class_name SpellExplosion
extends Spell

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var area: Area2D = $Area2D
@onready var collider: CollisionShape2D = $Area2D/CollisionShape2D
var scorchmark: Texture2D = preload("res://assets/art/sprites/environment/spr_environment_scorchmark.png")
signal explosion_complete

func _ready():
	z_as_relative = false
	z_index = Constants.z_index_map["explosion"]
	ap.animation_finished.connect(on_animation_finished)
	area.area_entered.connect(on_area_entered)
	scale *= randf_range(1, 1.5)

func initialize(spell_data: SpellData, spell_element_damage_perk_modifier: float) -> void:
	data = spell_data
	set_damage(spell_data, spell_element_damage_perk_modifier)

func on_area_entered(intruder: Area2D) -> void:
	var enemy = intruder as Enemy
	if enemy:
		deal_damage(enemy)

func on_animation_finished(_anim_name: String) -> void:
	if _anim_name == "explode":
		var new_sprite: Sprite2D = Sprite2D.new()
		collider.set_deferred("disabled", true)
		# add_child(new_sprite)
		# new_sprite.texture = scorchmark
		# new_sprite.hframes = 2
		# new_sprite.frame = 1
		# new_sprite.global_position = global_position
		# new_sprite.z_as_relative = false
		# new_sprite.z_index = Constants.z_index_map["scorchmark"]
		explosion_complete.emit(new_sprite)
		self_modulate.a = 0
	
# func on_despawn_timer_timeout() -> void:
# 	queue_free()
