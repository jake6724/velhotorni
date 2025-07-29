class_name EnemyData
extends Resource

@export var element: Constants.Element
@export var strong_against_element: Constants.Element
@export var weak_against_element: Constants.Element
@export var health: float
@export var speed: float
@export var atlas: Texture
@export var explosion_sfx: AudioStreamOggVorbis

@export_category("Debuff Cooldowns")
## Cooldown time after being frozen that `Enemy` can be frozen again. In seconds.
@export var freeze_cooldown: float
## Cooldown time after being stunned that `Enemy` can be stunned again. In seconds.
@export var stun_cooldown: float 
## Cooldown time after being knockbacked that `Enemy` can be knockbacked again. In seconds.
@export var knockback_cooldown: float