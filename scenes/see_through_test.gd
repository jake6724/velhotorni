extends ColorRect

var see_thru_mat: ShaderMaterial

func _ready():
	see_thru_mat = material

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = get_viewport().get_final_transform() * event.position
		see_thru_mat.set_shader_parameter( "CircleCentre", mouse_pos )

# func _process(delta):
	# var mouse_pos = get_global_mouse_position()
	# see_thru_mat.set_shader_parameter( "CircleCentre", mouse_pos )
