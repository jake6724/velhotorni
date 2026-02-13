class_name SpellMelee
extends Spell

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox

# TODO: Add collision detection + particles when hitting terrain obstacles

func _ready():
	ap.animation_finished.connect(on_animation_finished)
	hitbox.area_entered.connect(on_enemy_hit)
	z_index = Constants.z_index_map["melee_spell"]

func initialize(_data: SpellData, _spell_spawn_point: Node2D, spell_element_damage_perk_modifier: float, _execution_threshold: float, _double_spell_mana_drop: bool, _perk_debuffs: Array[DebuffData]) -> void:
	data = _data
	execution_threshold = _execution_threshold
	double_spell_mana_drop = _double_spell_mana_drop
	perk_debuffs = _perk_debuffs
	set_damage(data, spell_element_damage_perk_modifier)

func on_enemy_hit(enemy: Enemy) -> void:
	deal_damage(enemy)
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.BULLET_IMPACT_FLESH)

func on_animation_finished(_anim_name) -> void:
	queue_free()
