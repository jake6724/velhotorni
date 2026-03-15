class_name SpellDataMelee
extends SpellData

@export var atlas: CompressedTexture2D
@export var sfx: AudioStreamOggVorbis
@export var melee_spell_scene: PackedScene
## How long until bullet block hitbox is ACTIVATED after the melee spell spawns. 
## This value CANNOT be 0.
@export var pre_swing_bullet_block_delay: float = .001
## How long the bullet block hitbox REMAINS ACTIVATED. If this value is greater than the lifespan of the melee spell, 
## the extra time won't matter and the block will be killed with the parent melee spell
@export var post_swing_bullet_block_duration: float = .2
