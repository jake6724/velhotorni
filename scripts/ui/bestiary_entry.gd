class_name BestiaryEntry
extends TextureButton

@export var data: EnemyData

func _ready():
	texture_normal = AtlasTexture.new()
	texture_normal = texture_normal as AtlasTexture
	texture_normal.atlas = data.atlas
	
	if texture_normal is AtlasTexture:
		if data.size == Enemy.Size.MEDIUM:
			texture_normal.region = Rect2(0, 0, 16, 16)
		elif data.size == Enemy.Size.LARGE:
			texture_normal.region = Rect2(0, 0, 32, 32)
