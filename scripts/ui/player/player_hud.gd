class_name PlayerHUD
extends Control

@onready var weapons: Control = %Weapons

# @onready var active_spell_icon: TextureRect = %ActiveSpellIcon
@onready var active_spell_mana: TextureProgressBar = %ActiveSpellMana
@onready var active_spell_mana_label: RichTextLabel = %ActiveSpellManaLabel
@onready var tower_mana_label: RichTextLabel = %TowerManaLabel

@onready var active_mana_count: Label = %ManaCount
@onready var active_mana_total: Label = %ManaTotal
@onready var active_mana_progress_bar: TextureProgressBar = %ActiveSpellManaProgressBar

@onready var spell_1_icon: TextureRect = %InactiveSpell1Icon
@onready var spell_2_icon: TextureRect = %InactiveSpell2Icon
@onready var spell_3_icon: TextureRect = %InactiveSpell3Icon
@onready var spell_4_icon: TextureRect = %InactiveSpell4Icon
@onready var spell_icons_list: Array[TextureRect] = [spell_1_icon, spell_2_icon, spell_3_icon, spell_4_icon]
@onready var spell_icons: Dictionary[SpellData, TextureRect] = {}

@onready var spell_1_mana: TextureProgressBar = %InactiveSpell1Mana
@onready var spell_2_mana: TextureProgressBar = %InactiveSpell2Mana
@onready var spell_3_mana: TextureProgressBar = %InactiveSpell3Mana
@onready var spell_4_mana: TextureProgressBar = %InactiveSpell4Mana
@onready var spell_mana_list: Array[TextureProgressBar] = [spell_1_mana, spell_2_mana, spell_3_mana, spell_4_mana] # null is used to make array parallel in size to spell_data_list
@onready var spell_mana: Dictionary[SpellData, TextureProgressBar]


@onready var player_hearts: HBoxContainer = %PlayerHearts
@onready var player_portrait: PlayerPortrait = %PlayerPortrait

@onready var no_mana_label: Label = %NoManaLabel

@onready var perk_mini_icons: HBoxContainer = %PerkMiniIcons

@onready var spell_mana_drop_display: VBoxContainer = %SpellManaDropDisplay
@onready var spell_mana_popups: Dictionary[SpellData, SpellManaPopup]

@onready var wave_count: Label = %WaveCount
@onready var wave_total: Label = %WaveTotal
@onready var tower_count: Label = %TowerCount
@onready var tower_total: Label = %TowerTotal
@onready var enemy_count: Label = %EnemyCount
@onready var enemy_total: Label = %EnemyTotal
@onready var enemy_progress: TextureProgressBar = %EnemyProgressbar
var enemy_info_total: int
var enemy_info_count: int

@onready var banner_ap: AnimationPlayer = $BannerAnimationPlayer
@onready var banner: Sprite2D = %Banner
@onready var banner_label: Label = %BannerLabel

@onready var build_phase_buttons: VBoxContainer = %BuildPhaseButtons
@onready var start_wave_progress_bar: TextureProgressBar = %StartWaveProgressBar
@onready var heal_all_progress_bar: TextureProgressBar = %HealAllProgressBar
@onready var heal_all_cost: Label = %HealAllCost

var clear_spell_mana_drop_display_timer: Timer = Timer.new()
const CLEAR_SPELL_MANA_DROP_DISPLAY_DELAY: float = 3.0

const SPELL_MANA_POPUP_SCENE: PackedScene = preload("res://scenes/ui/player/SpellManaPopup.tscn")

const MAX_TOWER_MANA_DIGITS: int = 4
const MAX_ACTIVE_SPELL_MANA_DIGITS: int = 3
const PADDING_COLOR: String = "#adb5bd"
const LOW_MANA_COLOR: String = "#d63100"
var bbc_string: String = "[color=%s]"
var bbc_color_mana_text: String = "[color=%s]"

var blinking_no_mana: bool = false

const PLAYER_HUD_HEART_SCENE: PackedScene = preload("res://scenes/ui/player/PlayerHUDHeart.tscn")

signal active_spell_mana_value_calculated
signal wave_complete_banner_animation_finished
signal wave_start_banner_animation_finished
signal heal_all_requested

func _ready():
	active_spell_mana_label.bbcode_enabled = true
	tower_mana_label.bbcode_enabled = true
	no_mana_label.show()

	no_mana_label.add_theme_constant_override("outline_size", 0)

	for icon in spell_icons_list.slice(1,-1):
		icon.hide()

	clear_spell_mana_drop_display_timer.autostart = false
	clear_spell_mana_drop_display_timer.one_shot = true
	clear_spell_mana_drop_display_timer.timeout.connect(on_spell_mana_popup_timeout)
	add_child(clear_spell_mana_drop_display_timer)

func initialize(spell_data_list: Array[SpellData], player_mana: PlayerMana, player_stats: PlayerCharacterStats, player_build: PlayerBuild, player_input: PlayerInput) -> void:
	on_spell_loadout_updated(spell_data_list, player_mana)
	update_spells(spell_data_list)
	update_mana(spell_data_list, player_mana)
	update_tower_mana(player_mana)
	on_health_updated(player_stats.health)

	WaveManager.wave_started.connect(on_wave_started)
	WaveManager.wave_completed.connect(on_wave_complete)
	WaveManager.wave_total_updated.connect(func wave_total_updated(total: int): wave_total.text = str(total))
	wave_count.text = "1"

	player_build.tower_count_updated.connect(func on_tower_count_updated(count: int): tower_count.text = str(count))
	TowerGlobalData.tower_max_updated.connect(func on_tower_total_updated(total: int): tower_total.text = str(total))

	EnemySpawner.wave_enemy_total_updated.connect(on_enemy_total_updated)
	EnemySpawner.enemy_died.connect(on_enemy_count_decremented)

	player_input.start_wave_action_charge_updated.connect(on_player_input_start_wave_action_charge_updated)
	player_input.heal_all_action_charge_updated.connect(on_player_input_heal_all_action_charge_updated)

	build_phase_buttons.position.x = -104
	animate_show_build_phase_buttons()

	wave_complete_banner_animation_finished.connect(on_wave_complete_banner_animation_finished)

func on_spell_loadout_updated(spell_data_list: Array[SpellData], player_mana: PlayerMana) -> void:

	for i in range(spell_data_list.size()):
		spell_icons[spell_data_list[i]] = spell_icons_list[i]
		spell_mana[spell_data_list[i]] = spell_mana_list[i]

	update_spells(spell_data_list)
	update_mana(spell_data_list, player_mana)

func update_spells(spell_data_list: Array[SpellData]) -> void:
	if spell_data_list.size() > 0:
		weapons.show()

		# Hide all inactive spell icons. They will be shown below if required
		for key in spell_icons.keys():
			spell_icons[key].hide()

		# The first spell in the array will be active
		spell_icons[spell_data_list[0]].texture = spell_data_list[0].active_icon
		spell_icons[spell_data_list[0]].show()
		spell_icons[spell_data_list[0]].get_children()[0].hide()
		# active_spell_mana_label.global_position = spell_icons[spell_data_list[0]].global_position + Vector2(0, -30)
		
		for spell_data: SpellData in spell_data_list.slice(1, spell_data_list.size()):
			spell_icons[spell_data].texture = spell_data.inactive_icon
			spell_icons[spell_data].show()
			spell_icons[spell_data].get_children()[0].show()

	else:
		for icon in spell_icons_list.slice(1,spell_icons_list.size()):
			icon.hide()
		weapons.hide()

func update_mana(spell_data_list: Array[SpellData], player_mana: PlayerMana) -> void:
	if spell_data_list.size() > 0:
		var active_spell_mana_text: String = str(int(player_mana.spell_mana[spell_data_list[0]]))
		active_spell_mana.value = (player_mana.spell_mana[spell_data_list[0]] / player_mana.spell_mana_maxes[spell_data_list[0]]) * 100
		var zero_pad: String = get_zero_padding(MAX_ACTIVE_SPELL_MANA_DIGITS - len(active_spell_mana_text))
		active_spell_mana_value_calculated.emit(active_spell_mana.value)

		active_mana_progress_bar.value = active_spell_mana.value
		active_mana_count.text = str(int(player_mana.spell_mana[spell_data_list[0]]))
		active_mana_total.text = str(int(player_mana.spell_mana_maxes[spell_data_list[0]]))

		var mana_text_color: String
		if player_mana.spell_mana_low[spell_data_list[0]]:
			no_mana_label.show()
			mana_text_color = LOW_MANA_COLOR
			if player_mana.spell_mana[spell_data_list[0]] == 0:
				no_mana_label.text = "EMPTY"
			else:
				no_mana_label.text = "LOW"
		else:
			mana_text_color = "ffffff"
			no_mana_label.hide()

		active_spell_mana_label.text = bbc_string % PADDING_COLOR + zero_pad + "[/color]" + bbc_color_mana_text % mana_text_color + active_spell_mana_text + "[/color]"

		for spell_data: SpellData in spell_data_list.slice(1, spell_data_list.size()):
			spell_mana[spell_data].value =  (player_mana.spell_mana[spell_data] / player_mana.spell_mana_maxes[spell_data]) * 100

func update_tower_mana(player_mana) -> void:
	var text = str(int(player_mana.tower_mana))
	var zero_pad: String = get_zero_padding(MAX_TOWER_MANA_DIGITS - len(text))
	tower_mana_label.text = bbc_string % PADDING_COLOR + zero_pad + "[/color]" + text

func on_health_updated(_health: float) -> void:
	for heart: PlayerHUDHeart in player_hearts.get_children():
		
		if _health >= 2:
			heart.set_texture_full()
			_health -= 2

		elif _health == 1: 
			heart.set_texture_half()
			_health -= 1

		else:
			heart.set_texture_empty()

	for heart: PlayerHUDHeart in player_hearts.get_children():
		heart.flash()

func set_player_portrait(_health, _player_max_health) -> void:
	if _health > 1:
		player_portrait.on_hit()
		player_portrait.set_texture_full()
		player_portrait.active_portrait = player_portrait.portrait_full
	elif _health == 1:
		player_portrait.on_hit()
		player_portrait.set_texture_hit()
		player_portrait.active_portrait = player_portrait.portrait_hit
	else:
		player_portrait.set_texture_dead()

func set_player_portrait_firing() -> void:
	player_portrait.set_texture_firing()

func reset_player_portrait() -> void:
	player_portrait.reset_portrait()

func get_zero_padding(count: int):
	var zero: String = "0"
	var res: String = ""
	for i in range(count):
		res += zero
	return res

func blink_no_mana_label() -> void:
	if not blinking_no_mana:
		blinking_no_mana = true
		var blink_tween = get_tree().create_tween()
		blink_tween.set_loops(3)
		blink_tween.tween_property(no_mana_label, "modulate:a", 0.0, .01)
		blink_tween.tween_interval(.1)
		blink_tween.tween_property(no_mana_label, "modulate:a", 1.0, .01)
		blink_tween.tween_interval(.1)
		await blink_tween.finished
		blinking_no_mana = false

func blink_ui_element(_ui_element: Control, _blink_amount: int=3, hide_duration: float=0.1, show_duration:float=0.1, hide_on_finished: bool=true) -> void:
	var blink_tween: Tween = get_tree().create_tween()
	blink_tween.set_loops(_blink_amount)
	blink_tween.tween_property(_ui_element, "modulate:a", 0.0, .01)
	blink_tween.tween_interval(hide_duration)
	blink_tween.tween_property(_ui_element, "modulate:a", 1.0, .01)
	blink_tween.tween_interval(show_duration)
	await blink_tween.finished
	if hide_on_finished: _ui_element.hide()

func add_spell_mana_popup(spell_data: SpellData, _mana_amount: int) -> void:

	if spell_mana_popups.has(spell_data):
		spell_mana_popups[spell_data].set_text(_mana_amount)
		spell_mana_popups[spell_data].shake()

	else:
		var new_popup: SpellManaPopup = SPELL_MANA_POPUP_SCENE.instantiate()
		new_popup.spell_data = spell_data
		spell_mana_popups[spell_data] = new_popup
		spell_mana_drop_display.add_child(new_popup)
		new_popup.set_icon(spell_data.inactive_icon)
		new_popup.set_text(_mana_amount)

		# Move to start position (still hidden)
		var slide_out_tween: Tween = get_tree().create_tween()
		var target_out: float = new_popup.position.x + 51
		slide_out_tween.tween_property(new_popup, "position:x", target_out, 0)
		await slide_out_tween.finished

		# Ease into view
		var slide_in_tween: Tween = get_tree().create_tween()
		var target_in: float = new_popup.position.x - 22
		slide_in_tween.tween_property(new_popup, "position:x", target_in, .1)
		await slide_in_tween.finished

	clear_spell_mana_drop_display_timer.start(CLEAR_SPELL_MANA_DROP_DISPLAY_DELAY)

func on_spell_mana_popup_timeout() -> void:
	# Ease out popups
	for popup: SpellManaPopup in spell_mana_drop_display.get_children():
		var slide_tween: Tween = get_tree().create_tween()
		var target: float = popup.position.x + 51
		slide_tween.tween_property(popup, "position:x", target, .075)
		await slide_tween.finished

	for popup: SpellManaPopup in spell_mana_drop_display.get_children():
		spell_mana_drop_display.remove_child(popup)
		popup.queue_free()

	spell_mana_popups = {}

func get_spell_popup_by_spell_data(_spell_data: SpellData) -> void:
	pass

func on_enemy_total_updated(_total: int) -> void:
	enemy_info_count = _total
	enemy_info_total = _total
	enemy_progress.value = (float(enemy_info_count) / enemy_info_total) * 100* 100
	enemy_total.text = str(enemy_info_total)
	enemy_count.text = str(enemy_info_count)

func on_enemy_count_decremented() -> void:
	enemy_info_count -= 1
	enemy_count.text = str(enemy_info_count)
	enemy_progress.value = (float(enemy_info_count) / enemy_info_total) * 100

func on_wave_complete() -> void:
	wave_count.text = str(WaveManager.wave_index + 1)
	show_banner("Wave Complete", wave_complete_banner_animation_finished)

func on_wave_started() -> void:
	show_banner("Wave Started", wave_start_banner_animation_finished)
	animate_hide_build_phase_buttons()

func on_wave_complete_banner_animation_finished() -> void:
	WaveManager.can_start_wave = true
	start_wave_progress_bar.value = 0
	animate_show_build_phase_buttons()

func show_banner(text: String, completed_signal: Signal) -> void:
	banner_label.text = text
	banner.show()
	banner_ap.play("open")
	await banner_ap.animation_finished
	banner_ap.play("hold")
	await get_tree().create_timer(2).timeout
	banner_ap.play("close")
	await banner_ap.animation_finished
	banner.hide()
	completed_signal.emit()

func show_banner_label() -> void:
	banner_label.show()

func hide_banner_label() -> void:
	banner_label.hide()

func add_hearts(_count: int) -> void:
	for i in range(_count):
		var new_heart: PlayerHUDHeart = PLAYER_HUD_HEART_SCENE.instantiate()
		player_hearts.add_child(new_heart)

func add_perk_mini_icon(perk_mini_icon: AtlasTexture):
	print("PlayerHUD.add_perk_mini_icon()")
	var texture_rect: TextureRect = TextureRect.new()
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
	texture_rect.texture = perk_mini_icon
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	perk_mini_icons.add_child(texture_rect)

func on_weapon_max_mana_updated(player_spells: PlayerSpells, player_mana: PlayerMana) -> void:
	update_mana(player_spells.spells.array, player_mana)

func on_player_input_start_wave_action_charge_updated(_value: float) -> void:
	if start_wave_progress_bar.visible:
		start_wave_progress_bar.value = _value

func on_player_input_heal_all_action_charge_updated(_value) -> void:
	if heal_all_progress_bar.visible:
		heal_all_progress_bar.value = _value
		if _value >= 100:
			heal_all_requested.emit()

func animate_show_build_phase_buttons() -> void:
	build_phase_buttons.show()
	var tween = get_tree().create_tween()
	var target: float = 0
	tween.tween_property(build_phase_buttons, "position:x", target, .2)

func animate_hide_build_phase_buttons() -> void:
	build_phase_buttons.hide()
	var tween = get_tree().create_tween()
	var target: float = build_phase_buttons.position.x - 104
	tween.tween_property(build_phase_buttons, "position:x", target, .2)
