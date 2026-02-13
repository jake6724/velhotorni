class_name PlayerHeart
extends TextureRect

@export var full_heart: AtlasTexture
@export var half_heart: AtlasTexture
@export var empty_heart: AtlasTexture
@export var white_heart: AtlasTexture

const FLASH_TIME: float = .2

func _ready():
    texture = full_heart

func set_texture_full() -> void:
    texture = full_heart

func set_texture_half() -> void:
    texture = half_heart

func set_texture_empty() -> void:
    texture = empty_heart

func flash() -> void:
    var prev_texture = texture
    texture = white_heart
    await get_tree().create_timer(FLASH_TIME).timeout
    texture = prev_texture