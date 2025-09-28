extends EnemyData
class_name EnemyDataRanged

@export_category("Ranged Enemy Attack Data")
@export var attack_cooldown: float = 1.0
@export var burst_cooldown: float = 0.0
@export var num_bursts: int = 1

@export_category("Bullet Pattern Data")
@export var num_bullets_per_burst: int
@export var angle_increment: float

@export_category("Ranged Enemy Bullet Data")
@export var bullet_damage: float
@export var bullet_speed: float
@export var bullet_max_distance: float
@export var bullet_follow_on_hit: bool
@export var bullet_atlas: CompressedTexture2D