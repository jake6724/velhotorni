class_name SpellDataBullet
extends SpellData

# TODO: Add options for burst mode config

@export var speed: float

## The number of bullets per shot
@export var num_bullets: int
@export var cooldown: float

## The angle of difference between each bullet per shot. 
@export var angle_seperation: float
@export var pierce: int
@export var max_distance: float

## Random spread +/- in either direction. A spread of 30 would allow for launch angles between -30 and 30 degrees.
@export var spread: float
@export var atlas: CompressedTexture2D
@export var sfx: AudioStreamOggVorbis