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
var max_health: float # Do not set manually; used in health bar calc
var health: float
var speed: float
var element: GameManager.Element
var weak_against: GameManager.Element
var strong_against: GameManager.Element

var negative_modifier: float = .5
var positive_modifier: float = 2.0

var damage: int = 1
var can_attack: bool = true

var base: Base
var is_alive: bool = true

var walk_resume_pos: float

# Signals
signal is_dead

func _ready():
	# path = GameManager.active_path.duplicate() # Enemies MUST use their own local copy
	health = data.health

	# speed = data.speed
	speed = .1
	element = data.element

	set_resistances()

	max_health = health

	base = GameManager.base

	ap.animation_finished.connect(on_animation_finished)
	
## Reduce enemies `health` stat by `damage_recieved`. Return `true` if enemy died, `false` otherwise.
## Handles despawning enemy in the case of death.
func take_damage(damage_recieved: float, tower_element: GameManager.Element):
	# Hit by resisted element
	if tower_element == element or tower_element == strong_against:
		weak.hide()
		shield.show()
		damage_recieved *= negative_modifier

	# Hit by weak-to element
	else:
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

func _physics_process(delta):
	move(delta)

func move(delta) -> void:
	if is_alive and path_follow.progress_ratio < .99:
		path_follow.progress_ratio += (speed * delta)
		ap.play("walk")
	else:
		if is_alive:
			base.take_damage(damage)
			die()

func set_resistances() -> void:
	match element:
		GameManager.Element.FIRE: 
			strong_against = GameManager.Element.EARTH
			weak_against = GameManager.Element.WATER

		GameManager.Element.EARTH:
			strong_against = GameManager.Element.WATER
			weak_against = GameManager.Element.FIRE

		GameManager.Element.WATER:
			strong_against = GameManager.Element.FIRE
			weak_against = GameManager.Element.EARTH

func on_animation_finished(anim_name):
	if anim_name == "hit":
		ap.play("walk")
		ap.seek(walk_resume_pos)

	if anim_name == "die":
		ap.play("corpse")

	if anim_name == "corpse":
		queue_free()

func die() -> void:
	is_alive = false
	collider.disabled = true
	ap.play("die")
	play_explosion_sfx()
	is_dead.emit(self)

	# Hide graphics
	health_bar.hide()
	shield.hide()
	weak.hide()

func play_explosion_sfx(): # This could be simplified by passing the sfx thru data file and making it a member var
	match element:
		GameManager.Element.FIRE: SFXPlayer.play_sfx("fire_explosion")
		GameManager.Element.EARTH: SFXPlayer.play_sfx("water_explosion")
		GameManager.Element.WATER: SFXPlayer.play_sfx("earth_explosion")
