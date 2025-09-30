class_name SpellDataBullet
extends SpellData

# TODO: Add options for burst mode config

@export var element: Constants.Element
@export var damage: float
@export var speed: float
@export var num_bullets: int
@export var cooldown: float
@export var angle_seperation: float
@export var pierce: int
@export var max_distance: float
@export var spread: float
@export var atlas: CompressedTexture2D
@export var sfx: AudioStreamOggVorbis