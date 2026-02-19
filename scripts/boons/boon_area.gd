class_name BoonArea
extends Area2D

@onready var boon_collider: CollisionShape2D = $BoonCollider

var boon_data: BoonData
var cast_timer: Timer
var can_show_boon_range: bool = false

var greyscale_shader = preload("res://shader/cut_ripple.gdshader")
var greyscale_shader_material = ShaderMaterial.new()
var circle_mask: CompressedTexture2D = load("res://assets/placeholders/snake_node_placeholder.png")

func set_shader_properties() -> void:
	pass
	# greyscale_shader_material.shader = greyscale_shader
	# greyscale_shader_material.set("shader_parameter/invert_mask",bool(true))
	# greyscale_shader_material.set("shader_parameter/mask_texture",(circle_mask))
	# greyscale_shader_material.set("shader_parameter/use_different_texture",(true))
	# greyscale_shader_material.set("shader_parameter/mask_size",Vector2(boon_collider.shape.radius * 2, boon_collider.shape.radius * 2))
	# greyscale_shader_material.set("shader_parameter/wave_amplitude",float(0.1))
	# greyscale_shader_material.set("shader_parameter/ripple_rate",float(12))

	# greyscale_shader_material.set("shader_parameter/amplitude",float(1.6));
	# greyscale_shader_material.set("shader_parameter/ripple_rate",float(4.0));
	# greyscale_shader_material.set("shader_parameter/wave_amplitude",float(0.018));
	# greyscale_shader_material.set("shader_parameter/wave_amplitude",float(15.0));

func _process(_delta):
	queue_redraw()

func initialize(_boon_data: BoonData):
	boon_data = _boon_data
	boon_collider.shape.radius = _boon_data.cast_radius
	if boon_data.type == Boon.Type.STEALTH:
		# set_shader_properties()
		can_show_boon_range = true
		# show_boon_range()
	match boon_data.mode:
		Boon.Mode.TIMER: 
			cast_timer = Timer.new()
			add_child(cast_timer)
			cast_timer.timeout.connect(on_cast_timer_timeout)
			cast_timer.start(boon_data.cast_speed)

		Boon.Mode.COLLISION:
			area_entered.connect(on_buff_area_entered)
			area_exited.connect(on_buff_area_exited)

func on_cast_timer_timeout() -> void:
	var allies: Array[Area2D] = get_overlapping_areas()
	for ally in allies:
		connect_boon(ally.owner)
	cast_timer.start(boon_data.cast_speed)

func on_buff_area_entered(intruder) -> void:
	# print("Buff area entered")
	connect_boon(intruder.owner)

func on_buff_area_exited(intruder) -> void:
	if intruder.owner:
		intruder.owner.boon_manager.expire_boon_by_source(self)

## Handle the logic for determining if an boon should be connected to self or enemy
func connect_boon(enemy: Enemy) -> void: 
	# print("Connect boon")
	if enemy:
		if boon_data.ally_cast and enemy != self.owner:
			enemy.boon_manager.connect_boon(create_boon(boon_data))

		elif boon_data.self_cast and enemy == self.owner:
			enemy.boon_manager.connect_boon(create_boon(boon_data))

func disconnect_boon(enemy: Enemy) -> void:
	if boon_data.ally_cast and enemy != self.owner:
		enemy.owner.boon_manager.expire_boon_by_source(self)

	elif boon_data.self_cast and enemy == self.owner:
		enemy.owner.boon_manager.expire_boon_by_source(self)

func create_boon(_boon_data) -> Boon:
	var new_boon: Boon = Boon.new(_boon_data)
	new_boon.source = self
	return new_boon

func _draw():
	if can_show_boon_range:
		draw_circle(to_local(global_position + Vector2(8,8)), boon_collider.shape.radius, Color(1,1,1,.3), false, 1.0, false)

func show_boon_range() -> void:
	pass
	# draw_circle(to_local(global_position + Vector2(8,8)), boon_collider.shape.radius, Color(1,1,1,.3), true)

	# var radius = boon_collider.shape.radius
	# var num_points = 32 # Higher number = smoother circle
	# # var circle_color = Color(1,1,1,.3)
	# var circle_color = Color.RED
	# var polygon_points = PackedVector2Array()
	# var offset: Vector2 = Vector2(8,8)
	
	# # Generate points around the circumference
	# for i in range(num_points):
	# 	var angle = (float(i) / num_points) * PI * 2
	# 	var point = (Vector2(cos(angle), sin(angle)) * radius) + offset
	# 	polygon_points.append(point)

	# var new_polygon: Polygon2D = Polygon2D.new()
	# new_polygon.polygon = polygon_points
	# new_polygon.color = circle_color
	# new_polygon.material = greyscale_shader_material
	# add_child(new_polygon)
	
	# # Draw the filled polygon
	# draw_polygon(polygon_points, PackedColorArray([circle_color]))


	# var new_color_rect: ColorRect = ColorRect.new()
	# add_child(new_color_rect)
	# new_color_rect.size = Vector2(boon_collider.shape.radius * 2, boon_collider.shape.radius * 2) # Set size to fit circle
	# new_color_rect.pivot_offset = new_color_rect.size / 2
	# new_color_rect.global_position = (global_position - (new_color_rect.size/2)) + Vector2(8,8)
	# new_color_rect.color = Color.RED
	# new_color_rect.material = greyscale_shader_material
	# new_color_rect.material


