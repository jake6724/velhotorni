class_name SpellDataMeleeBullet
extends SpellData

@export_category("Melee Config")
## The usual damage value below is NOT used in this type of spell
@export var melee_damage: float = 0.0
@export var melee_spell_scene: PackedScene
@export var melee_sfx: SoundEffect

@export_category("Bullet Config")
## The usual damage value below is NOT used in this type of spell
@export var bullet_damage: float = 0.0
## Speed the bullet travels (not the cooldown between firing!)
@export var speed: float
## The number of bullets per shot
@export var num_bullets: int
## The angle of difference between each bullet per shot. 
@export var angle_seperation: float
@export var pierce: int
@export var max_distance: float

@export var bullet_atlas: CompressedTexture2D
@export var bullet_sfx: SoundEffect