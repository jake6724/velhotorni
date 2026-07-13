class_name AreaSceneTransition extends Area2D

@export var collider: CollisionShape2D

var main_scene: PackedScene = load("res://scenes/Main.tscn")

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(_player: PlayerCharacter) -> void:
	LevelManager.level_index = 3
	EnemySpawner.reset()
	WaveManager.reset()
	SceneTransition.change_scene(main_scene)