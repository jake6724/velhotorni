class_name UnitWaveInfo
extends MarginContainer

@onready var enemy_icon: TextureRect = %EnemyIcon
@onready var enemy_count_label: Label = %EnemyCountLabel

func initialize(_enemy_icon: AtlasTexture, _count: int):
	enemy_icon.texture = _enemy_icon
	enemy_count_label.text = str(_count)
