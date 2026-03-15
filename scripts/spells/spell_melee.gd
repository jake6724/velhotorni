class_name SpellMelee
extends Spell

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox
@onready var bullet_block_collider: CollisionShape2D = %BulletBlockCollider

var pre_bullet_stop_timer: Timer = Timer.new()
var post_bullet_stop_timer: Timer = Timer.new()

# TODO: Add collision detection + particles when hitting terrain obstacles

func _ready():
	ap.animation_finished.connect(on_animation_finished)
	hitbox.area_entered.connect(on_enemy_hit)
	z_index = Constants.z_index_map["melee_spell"]
	bullet_block_collider.disabled = true

func initialize(_data: SpellData, _spell_spawn_point: Node2D, spell_element_damage_perk_modifier: float, _execution_threshold: float, _double_spell_mana_drop: bool, _perk_debuffs: Array[DebuffData]) -> void:
	data = _data
	execution_threshold = _execution_threshold
	double_spell_mana_drop = _double_spell_mana_drop
	perk_debuffs = _perk_debuffs
	set_damage(data, spell_element_damage_perk_modifier)

	# Configure Timers
	pre_bullet_stop_timer.one_shot = true
	pre_bullet_stop_timer.autostart = true
	pre_bullet_stop_timer.wait_time = data.pre_swing_bullet_block_delay
	add_child(pre_bullet_stop_timer)
	pre_bullet_stop_timer.timeout.connect(on_pre_bullet_stop_timer_timeout)

	post_bullet_stop_timer.one_shot = true
	post_bullet_stop_timer.autostart = false
	add_child(post_bullet_stop_timer)
	post_bullet_stop_timer.timeout.connect(on_post_bullet_stop_timer_timeout)

func on_enemy_hit(enemy: Enemy) -> void:
	deal_damage(enemy)
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.BULLET_IMPACT_FLESH)

func on_animation_finished(_anim_name) -> void:
	queue_free()

func on_pre_bullet_stop_timer_timeout() -> void:
	bullet_block_collider.set_deferred("disabled", false)
	if data.post_swing_bullet_block_duration > 0:
		post_bullet_stop_timer.start(data.post_swing_bullet_block_duration)
	else:
		on_post_bullet_stop_timer_timeout()

func on_post_bullet_stop_timer_timeout() -> void:
	bullet_block_collider.set_deferred("disabled", true)
