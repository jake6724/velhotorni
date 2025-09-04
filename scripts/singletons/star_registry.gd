extends Node

## 0: Locked
## 1: Unlocked, unplayed
## 2: 1 star
## 3: 2 star
## 4: 3 star
var stars: Dictionary[PackedScene, int] = {
	LevelManager.level_0: 0, 
	LevelManager.level_1: 0, 
	LevelManager.level_2: 0, 
	LevelManager.level_3a: 0, 
	LevelManager.level_3b: 0, 
	LevelManager.level_4: 1, 
	LevelManager.level_5: 1, 
	LevelManager.level_6a: 1, 
	LevelManager.level_6b: 1, 
	LevelManager.level_7: 1, 
	LevelManager.level_8: 0, 
	LevelManager.level_9a: 0, 
	LevelManager.level_9b: 0, 
	LevelManager.level_10: 0,
	LevelManager.level_11: 0, 
	LevelManager.level_12a: 0, 
	LevelManager.level_12b: 0,
	LevelManager.level_13: 0,
	LevelManager.level_14: 0, 
	LevelManager.level_15a: 0, 
	LevelManager.level_15b: 0,
	LevelManager.level_16: 0,
	LevelManager.level_17: 0, 
	LevelManager.level_18a: 0, 
	LevelManager.level_18b: 1,
	LevelManager.level_19: 0,
	LevelManager.level_20: 0,
	LevelManager.level_21: 0,
	LevelManager.level_22: 0,
}

var region_stars: Array[int] = [0, 0, 0 ,0 ,0 ,0, 0, 0]

func _ready():
	update_star_progress()
	print("Region stars: ", region_stars)

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
