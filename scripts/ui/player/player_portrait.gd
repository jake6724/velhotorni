class_name PlayerPortrait
extends TextureRect

@export var portrait_full: AtlasTexture
@export var portrait_half: AtlasTexture
@export var portrait_low: AtlasTexture
@export var portrait_dead: AtlasTexture
@export var portrait_flash: AtlasTexture

const FLASH_TIME: float = .2

func set_texture_full() -> void:
    texture = portrait_full

func set_texture_half() -> void:
    texture = portrait_half

func set_texture_low() -> void:
    texture = portrait_low

func set_texture_dead() -> void:
    texture = portrait_dead

func flash() -> void:
    var prev_texture = texture
    texture = portrait_flash
    await get_tree().create_timer(FLASH_TIME).timeout
    texture = prev_texture