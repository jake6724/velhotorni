extends Node

signal player_star_count_updated

var player_star_count: int = 44:
	set(value):
		player_star_count = value
		player_star_count_updated.emit()

## 0: Locked
## 1: Unlocked, unplayed
## 2: 1 star
## 3: 2 star
## 4: 3 star
var stars: Dictionary[PackedScene, int] = {
	LevelManager.level_1: 0,
	LevelManager.level_2: 0,
	LevelManager.level_3: 0,
}

var region_stars: Array[int] = [0, 0, 0 ,0 ,0 ,0, 0, 0]

func _ready():
	pass
	#update_star_progress()

func update_star_progress() -> void:
	var i: int = 0
	while i < (LevelManager.levels.size() - 1):

		if i > 0 and i % 3 == 0 and i <= 18:
			if stars[LevelManager.levels[i]] > 1 and stars[LevelManager.levels[i+2]] == 0:
				stars[LevelManager.levels[i+2]] = 1

		if stars[LevelManager.levels[i]] > 1 and stars[LevelManager.levels[i+1]] == 0:
			stars[LevelManager.levels[i+1]] = 1

		var star_count: int = stars[LevelManager.levels[i]]
		update_region_stars(i, star_count)
		i += 1

func update_region_stars(index: int, star_count: int) -> void:

	var region_index: int = get_region_index(index)
	if region_index != -1:
		region_stars[region_index] += star_count
	else:
		push_error("Region index invalid")

func get_region_index(index: int) -> int:
	if index == 0:
		return 0
	elif index <= 4:
		return 1
	elif index <= 8:
		return 2
	elif index <= 12:
		return 3
	elif index <= 16:
		return 4
	elif index <= 20:
		return 5
	elif index <= 24:
		return 6
	elif index <= 28:
		return 7
	else:
		return -1
