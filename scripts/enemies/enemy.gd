class_name Enemy
extends Area2D

@export var data: EnemyData

# Child references
@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var ap: AnimationPlayer = $AnimationPlayer
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var shield: Sprite2D = $Shield
@onready var weak: Sprite2D = $Weak

# Pathing 
var path_follow: PathFollow2D # Update `progress_ration` to move along path

# var path: PackedVectprior2Array
var min_distance: float = 2

# Enemy Stats from Enemy Data Resource
var element: Constants.Element
var weak_against_element: Constants.Element
var strong_against_element: Constants.Element
var max_health: float # Do not set manually; used in health bar
var health: float
var speed: float
var atlas: Texture

var negative_modifier: float = .5
var positive_modifier: float = 2.0

var damage: int = 1
var can_attack: bool = true

var base: Base
var is_alive: bool = true

var walk_resume_pos: float

# Signals
signal died

func _ready():
	element = data.element
	strong_against_element = data.strong_against_element
	weak_against_element = data.weak_against_element 
	health = data.health
	speed = data.speed
	atlas = data.atlas
	max_health = health
	base = LevelManager.active_level.base # TODO: This is potentially bad; a collision box with layer that can only see base would be better ? 
	# set_resistances()
	sprite.texture = atlas
	ap.animation_finished.connect(on_animation_finished)

func _physics_process(delta):
	move(delta)

func move(delta) -> void:
	if is_alive and path_follow.progress_ratio < .99:
		path_follow.progress += (speed * delta)
		ap.play("walk")
	else:
		if is_alive:
			base.take_damage(damage)
			die()
	
## Reduce enemies `health` stat by `damage_recieved`. Return `true` if enemy died, `false` otherwise.
## Handles despawning enemy in the case of death.
func take_damage(damage_recieved: float, tower_element: Constants.Element):
	# Hit by resisted element
	if tower_element == element or tower_element == strong_against_element:
		weak.hide()
		shield.show()
		damage_recieved *= negative_modifier

	# Hit by weak-to element
	elif tower_element == weak_against_element:
		weak.show()
		shield.hide()
		damage_recieved *= positive_modifier

	if not health_bar.is_visible():
		health_bar.show()

	health -= damage_recieved
	var v = (health / max_health) * 100
	health_bar.value = v

	if health <= 0:
		die()
	else:
		walk_resume_pos = ap.get_current_animation_position()
		ap.play("hit")

func die() -> void:
	is_alive = false
	collider.disabled = true
	ap.play("die")
	SFXPlayer.play_sfx_resource(data.explosion_sfx)
	died.emit(self)

	# Hide graphics
	health_bar.hide()
	shield.hide()
	weak.hide()

# func set_resistances() -> void:
# 	# TODO: JUST DEFINE THESE IN THE RESOURCE!
# 	match element:
# 		Constants.Element.FIRE: 
# 			strong_against = Constants.Element.NATURE
# 			weak_against = Constants.Element.WATER

# 		Constants.Element.NATURE:
# 			strong_against = Constants.Element.WATER
# 			weak_against = Constants.Element.FIRE

# 		Constants.Element.WATER:
# 			strong_against = Constants.Element.FIRE
# 			weak_against = Constants.Element.NATURE

func on_animation_finished(anim_name):
	if anim_name == "hit":
		ap.play("walk")
		ap.seek(walk_resume_pos)

	if anim_name == "die":
		ap.play("corpse")

	if anim_name == "corpse":
		queue_free()
