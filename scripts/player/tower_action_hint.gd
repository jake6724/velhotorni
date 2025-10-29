class_name TowerActionHint
extends TextureRect

func _ready():
	z_index = Constants.z_index_map["top"]

func display_tower_action_hint(tower_action: PlayerBuild.TowerAction) -> void:
	match tower_action:
		PlayerBuild.TowerAction.HEAL: display_heal()
		PlayerBuild.TowerAction.UPGRADE: display_upgrade()
		PlayerBuild.TowerAction.SELL: display_sell()

func display_heal() -> void:
	texture.region = Rect2(8,0,8,8)

func display_upgrade() -> void:
	texture.region = Rect2(0,0,8,8)

func display_sell() -> void:
	texture.region = Rect2(16,0,8,8)