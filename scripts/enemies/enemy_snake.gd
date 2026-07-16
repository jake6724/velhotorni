class_name EnemySnake
extends Enemy

@onready var snake_node_parent: Node = %SnakeNodeParent

var player: PlayerCharacter
var spawn_pos: Vector2

var nodes: int = 40
var speed_offset: int = nodes

var enemy_snake_node_scene: PackedScene = preload("res://scenes/enemies/EnemySnakeNode.tscn")

func configure_snake_enemy() -> void:
	populate_nodes()

func populate_nodes() -> void:
	var prev_node: EnemySnakeNode = null
	for i in range(nodes):
		var new_node: EnemySnakeNode = enemy_snake_node_scene.instantiate()
		new_node.target = self

		if prev_node: # Add to a node
			prev_node.add_child(new_node)
			new_node.global_position = prev_node.global_position
			new_node.speed = (prev_node.speed - 10)
		else: # Add to head
			snake_node_parent.add_child(new_node)
			new_node.global_position = global_position
			new_node.speed = (data.speed - 10)

		prev_node = new_node
		speed_offset -= 2

func get_push_vector() -> Vector2:
	var areas = get_overlapping_areas()
	var push_vector: Vector2 = Vector2.ZERO
	if areas.size() > 0:
		var area = areas[0]
		push_vector = area.global_position.direction_to(global_position)	
	return push_vector

## Move to player
func move(delta) -> void:
	if is_alive:
		if not is_frozen and not is_stunned:
			if not is_taking_damage:
				ap.play("walk")
		
			var direction = global_position.direction_to(player.global_position)
			sprite.flip_h = direction.x < 0
			global_position += direction.round().normalized() * data.speed * delta
			global_position += get_push_vector() * .5
	else:
			ap.play("idle")
