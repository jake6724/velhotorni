class_name SpellBullet
extends Spell

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var area: Area2D = $Area2D
@onready var collider: CollisionShape2D = $Area2D/CollisionShape2D
# @onready var light: PointLight2D = %Light

var move_direction: Vector2
var active: bool = true
var pierce_count: int = 0
var speed: float

var original_position: Vector2

func _ready():
	ap.animation_finished.connect(on_animation_finished)
	area.area_entered.connect(on_area_entered)
	area.body_entered.connect(on_body_entered)

func initialize(_data: SpellDataBullet, cast_direction: Vector2, spell_element_damage_perk_modifier: float, _execution_threshold: float, _double_spell_mana_drop: bool, _perk_debuffs: Array[DebuffData], bullet_speed: float) -> void:
	data = _data
	original_position = global_position
	if cast_direction:
		move_direction = cast_direction
	else:
		move_direction = Vector2(1, 0) # Need to be the direction player is facing? 

	set_damage(data, spell_element_damage_perk_modifier)
	execution_threshold = _execution_threshold
	double_spell_mana_drop = _double_spell_mana_drop
	perk_debuffs = _perk_debuffs
	texture = data.atlas

	speed = bullet_speed

func move(delta) -> void:
	if active:
		global_position += move_direction * speed * delta

	check_max_distance_reached()

func _physics_process(delta):
	move(delta)

## Hit enemy
func on_area_entered(enemy: Enemy) -> void:
	if active:
		deal_damage(enemy)
		pierce_count += 1
		# AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.BULLET_IMPACT_FLESH)

	if pierce_count >= data.pierce:
		active = false
		# light.enabled = false
		ap.play("hit")


## Hit Terrain Obstacle
func on_body_entered(_intruder) -> void:
	active = false
	# light.enabled = false
	AudioManager.create_2d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.BULLET_IMPACT_TERRAIN)
	ap.play("hit")

func on_animation_finished(anim_name) -> void:
	if anim_name == "hit":
		queue_free()

func check_max_distance_reached() -> void:
	if active and abs(global_position.distance_to(original_position)) > data.max_distance:
		active = false
		# light.enabled = false
		ap.play("hit")
