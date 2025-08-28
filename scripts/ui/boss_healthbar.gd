class_name BossHealthbar
extends NinePatchRect

@onready var progress_bar: TextureProgressBar = %ProgressBar

var boss_max_health: float = 0
var boss_health: float:
	set(value):
		boss_health = value
		var ratio: float = boss_health / boss_max_health
		progress_bar.value = ratio * 100

func set_boss_max_health(_health: float) -> void:
	boss_max_health = _health

func set_boss_health(_health: float) -> void:
	boss_health = _health
