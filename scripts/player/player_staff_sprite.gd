class_name StaffSprite
extends Sprite2D

@onready var muzzle_flash: AnimatedSprite2D = $MuzzleFlash

# func _ready():
# 	print(muzzle_flash)

# func _ready():
# 	texture = AtlasTexture.new()
# 	texture.atlas = load("res://assets/art/atlases/atl_player_mage_staff.png")

## Update the region of the staff atlas, changing the staff graphic. Return the corresponding value for
## player_aim.staff_rotation_offset_degrees


# TODO: Rework this to just check if it is melee or not, and then assign texture. Enums are not needed here
func switch_staff_texture(_spell_data: SpellData) -> int:
	if _spell_data:
		if _spell_data is SpellDataBullet:
			texture = _spell_data.staff_texture
			position = Vector2(0, 5) 
			offset = Vector2(4, 0.5)
			return 0
		elif _spell_data is SpellDataMelee:
			texture = _spell_data.staff_texture
			offset = Vector2(8, .5)
			return -120
		elif _spell_data is SpellDataMeleeBullet:
			texture = _spell_data.staff_texture
			offset = Vector2(8, .5)
			return -120
		elif _spell_data is SpellData:
			texture = null
			return 0
		else:
			push_error("Staff Type not matched correctly. typeof(_spell_data): ", typeof(_spell_data), ". _spell_data.spell_name: ", _spell_data.spell_name)
			return 0
	else:
		return 0
	# match _spell_data.staff_type:
	# 	SpellData.StaffType.ARCANE: 
	# 		texture = _spell_data.staff_texture
	# 		position = Vector2(0, 5) 
	# 		offset = Vector2(4, 0.5) # TODO: Broke.
	# 		return 0

	# 	SpellData.StaffType.FIRE_STAFF:
	# 		texture = _spell_data.staff_texture
	# 		position = Vector2(0, 5) 
	# 		offset = Vector2(4, 0.5) # TODO: Broke.
	# 		return 0

	# 	SpellData.StaffType.WATER_SWORD: 
	# 		texture = _spell_data.staff_texture
	# 		offset = Vector2(8, .5)
	# 		return -120

	# 	SpellData.StaffType.TRIPLE_STAFF: 
	# 		texture = _spell_data.staff_texture
	# 		offset = Vector2(4, 0.5)
	# 		return 0
		
	# 	SpellData.StaffType.LIGHT_UMBRELLA:
	# 		texture = _spell_data.staff_texture
	# 		offset = Vector2(4, 0.5)
	# 		return 0

	# 	SpellData.StaffType.FEATHER:
	# 		texture = _spell_data.staff_texture
	# 		offset = Vector2(8, .5)
	# 		return -120

	# 	SpellData.StaffType.DARK_REVOLVER:
	# 		texture = _spell_data.staff_texture
	# 		position = Vector2(0, 5) 
	# 		offset = Vector2(4, 0.5) # TODO: Broke.
	# 		return 0

	# 	SpellData.StaffType.EMPTY:
	# 		texture = _spell_data.staff_texture
	# 		offset = Vector2(4, 0.5)
	# 		return 0

	# 	_: return 0

func display_muzzle_flash() -> void:

	muzzle_flash.play("flash")
