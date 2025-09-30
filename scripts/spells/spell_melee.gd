class_name SpellMelee
extends Spell

@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area2D = $Hitbox

var spell_spawn_point: Node2D # Used to constantly move with player

# TODO: Add collision detection + particles when hitting terrain obstacles

func _ready():
	ap.animation_finished.connect(on_animation_finished)
	hitbox.area_entered.connect(on_enemy_hit)

func initialize(_data: SpellDataMelee, _spell_spawn_point: Node2D) -> void:
	data = _data
	spell_spawn_point = _spell_spawn_point

func _physics_process(_delta):
	global_position = spell_spawn_point.global_position

func on_enemy_hit(enemy: Enemy) -> void:
	deal_damage(enemy)

func on_animation_finished(_anim_name) -> void:
	queue_free()
