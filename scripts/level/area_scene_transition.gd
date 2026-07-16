class_name AreaSceneTransition extends Area2D

@export var collider: CollisionShape2D

var main_scene: PackedScene = load("res://scenes/Main.tscn")

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(_player: PlayerCharacter) -> void:
	LevelManager.load_level_from_index(PlayerLoadout.player_level_index	)
	# LevelManager.level_index = PlayerLoadout.player_level_index
	# EnemySpawner.reset()
	# WaveManager.reset()
	# SceneTransition.change_scene(main_scene)