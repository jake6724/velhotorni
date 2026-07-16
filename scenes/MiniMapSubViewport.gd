extends SubViewport

func _ready() -> void:
    world_2d = get_tree().root.world_2d
    # Need to make the parents hve the same visibility layer