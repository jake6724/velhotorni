class_name PlayerPortrait
extends TextureRect

@export var portrait_full: AtlasTexture
@export var portrait_firing: AtlasTexture
@export var portrait_hit: AtlasTexture
@export var portrait_dead: AtlasTexture
@export var portrait_flash_white: AtlasTexture
@export var portrait_flash_black: AtlasTexture

const FLASH_TIME: float = .1
const HIT_PORTRAIT_TIME: float = 1.5 # This is manually set to match player_data.tres - hurtbox iframe durations

@onready var active_portrait: AtlasTexture = portrait_full

func set_texture_full() -> void:
    texture = portrait_full

func set_texture_firing() -> void:
    texture = portrait_firing

func set_texture_hit() -> void:
    texture = portrait_hit

func set_texture_dead() -> void:
    texture = portrait_dead

func on_hit() -> void:
    texture = portrait_flash_black
    await get_tree().create_timer(FLASH_TIME).timeout
    texture = portrait_flash_white
    await get_tree().create_timer(FLASH_TIME).timeout
    texture = portrait_hit
    await get_tree().create_timer(HIT_PORTRAIT_TIME).timeout
    texture = active_portrait

func reset_portrait() -> void:
    texture = active_portrait