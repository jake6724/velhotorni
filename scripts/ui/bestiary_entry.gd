class_name BestiaryEntry
extends TextureButton

@onready var hidden_icon: TextureRect = %HiddenIcon

@export var data: EnemyData

func _ready():
	texture_normal = AtlasTexture.new()
	texture_normal = texture_normal as AtlasTexture
	texture_normal.atlas = data.atlas
	
	stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
	custom_minimum_size = Vector2(32,32)
	size = Vector2(32,32)
	size_flags_horizontal = 4
	size_flags_vertical = 4
	mouse_filter = Control.MOUSE_FILTER_PASS

	if texture_normal is AtlasTexture:
		if data.size == Enemy.Size.SMALL:
			texture_normal.region = Rect2(0, 0, 16, 16)
		elif data.size == Enemy.Size.LARGE:
			texture_normal.region = Rect2(0, 0, 32, 32)
