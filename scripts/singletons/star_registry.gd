extends Node

## 0: Locked
## 1: Unlocked, unplayed
## 2: 1 star
## 3: 2 star
## 4: 3 star
var stars: Dictionary[PackedScene, int] = {
	LevelManager.level_0: 1, 
	LevelManager.level_1: 0, 
	LevelManager.level_2: 0, 
	LevelManager.level_3a: 0, 
	LevelManager.level_3b: 0, 
	LevelManager.level_4: 0, 
	LevelManager.level_5: 0, 
	LevelManager.level_6a: 0, 
	LevelManager.level_6b: 0, 
	LevelManager.level_7: 0, 
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
	LevelManager.level_18b: 0,
	LevelManager.level_19: 0,
	LevelManager.level_20: 0,
	LevelManager.level_21: 0,
	LevelManager.level_22: 0,
}