extends Sprite2D

var speed: float = 1

func _process(_delta):
	if Input.is_action_pressed("move_up"):
		global_position -= Vector2(0, speed)
	if Input.is_action_pressed("move_down"):
		global_position += Vector2(0, speed)
	if Input.is_action_pressed("move_left"):
		global_position -= Vector2(speed, 0)
	if Input.is_action_pressed("move_right"):
		global_position += Vector2(speed, 0)