class_name SpellMelee
extends Spell

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox

# TODO: Add collision detection + particles when hitting terrain obstacles

func _ready():
	ap.animation_finished.connect(on_animation_finished)
	hitbox.area_entered.connect(on_enemy_hit)
	z_index = Constants.z_index_map["melee_spell"]

func initialize(_data: SpellDataMelee, _spell_spawn_point: Node2D, spell_element_damage_perk_modifier: float) -> void:
	data = _data
	set_damage(data, spell_element_damage_perk_modifier)

func on_enemy_hit(enemy: Enemy) -> void:
	deal_damage(enemy)

func on_animation_finished(_anim_name) -> void:
	queue_free()
