class_name Cat extends AnimatedSprite2D

@export var prompt_area: PromptArea

func _ready() -> void:
    prompt_area.activated.connect(on_prompt_area_activated)
    prompt_area.deactivated.connect(on_prompt_area_deactivated)
    play("idle")

func on_prompt_area_activated() -> void:
    play("alert")
    await animation_finished
    play("awake")

func on_prompt_area_deactivated() -> void:
    play("sleep")
    await animation_finished
    play("idle")
