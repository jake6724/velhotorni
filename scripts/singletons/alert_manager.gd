extends Node

var active_alerts: Array[Alert] = []

const ALERT_LIMIT: int = 3
const DEFAULT_ALERT_DURATION: float = 5.0

signal alert_created
signal alert_expired
signal player_hud_hint_requested

func configure_level() -> void:
	active_alerts = []

func submit_new_alert(_alert_global_position, _alert_priority: Alert.Priority, _alert_duration=DEFAULT_ALERT_DURATION, _alert_text: String="") -> void:
	var new_alert: Alert = Alert.new(_alert_global_position, _alert_priority, _alert_duration, _alert_text)
	if active_alerts.size() < ALERT_LIMIT:
		add_alert(new_alert)
	else:
		replace_alert(new_alert)

func add_alert(new_alert: Alert) -> void:
	active_alerts.append(new_alert)
	alert_created.emit(new_alert)
	var new_alert_timer: Timer = Timer.new()
	new_alert_timer.one_shot = true
	new_alert_timer.autostart = false
	add_child(new_alert_timer)
	new_alert_timer.timeout.connect(on_alert_timer_timeout.bind(new_alert))
	new_alert_timer.start(new_alert.duration)
	player_hud_hint_requested.emit(new_alert.text, new_alert.duration)

## Will replace the first instance of a lower priority alert with the newer incoming alert, if there
## is a lower priority alert to replace. If there is none, do nothing
## Calls add_alert internally
func replace_alert(_incoming_alert: Alert) -> void:
	for _alert: Alert in active_alerts:
		if _incoming_alert.priority > _alert.priority:
			alert_expired.emit(_alert)
			add_alert(_incoming_alert)
			return

func on_alert_timer_timeout(_alert) -> void:
	active_alerts.erase(_alert)
	alert_expired.emit(_alert)
