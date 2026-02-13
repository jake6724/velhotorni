class_name Alert
extends Object

enum Priority {LOWEST, LOW, MED, HIGH, HIGHEST}

var global_position: Vector2
var priority: Alert.Priority
var duration: float
var text: String

func _init(_global_position: Vector2, _priority: Priority, _duration: float, _text: String):
    global_position = _global_position
    priority = _priority
    duration = _duration
    text = _text