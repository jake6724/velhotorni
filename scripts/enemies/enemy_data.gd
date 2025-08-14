class_name EnemyData
extends Resource

@export var size: Enemy.Size
@export var element: Constants.Element
@export var strong_against_element: Constants.Element
@export var weak_against_element: Constants.Element
@export var health: float
@export var speed: float
@export var damage: int = 1
@export var atlas: Texture
@export var explosion_sfx: AudioStreamOggVorbis

@export_category("Boon")
@export var boon_data: BoonData