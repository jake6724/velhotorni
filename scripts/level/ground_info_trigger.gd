class_name GroundInfoTrigger
extends Area2D

@export var footstep_type: SoundEffect.SOUND_EFFECT_TYPE

func _ready():
    area_entered.connect(on_area_entered)
    area_exited.connect(on_area_exited)
    

func on_area_entered(player_ground_beacon: Area2D) -> void:
    print("Player entered")
    var player: PlayerCharacter = player_ground_beacon.owner
    player.player_audio.sfx_tpye_footstep = footstep_type

func on_area_exited(player_ground_beacon: Area2D) -> void:
    print("Calling area exited")
    var player: PlayerCharacter = player_ground_beacon.owner
    player.player_audio.set_deferred("sfx_tpye_footstep", player.player_audio.sfx_tpye_footstep_default) # TODO: Let player audio do this