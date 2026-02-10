extends Node

var active_alerts: Array[Alert] = []

const ALERT_LIMIT: int = 3
const DEFAULT_ALERT_DURATION: float = 5.0

signal alert_created
signal alert_expired

func submit_new_alert(_alert_global_position, _alert_priority: Alert.Priority, _alert_duration=DEFAULT_ALERT_DURATION, _alert_text: String="") -> void:
    if active_alerts.size() < ALERT_LIMIT:
        print("Creating new alert!")
        var new_alert: Alert = Alert.new(_alert_global_position, _alert_priority, _alert_duration, _alert_text)
        active_alerts.append(new_alert)
        alert_created.emit(new_alert)
        var new_alert_timer: Timer = Timer.new()
        new_alert_timer.one_shot = true
        new_alert_timer.autostart = false
        add_child(new_alert_timer)
        new_alert_timer.timeout.connect(on_alert_timer_timeout.bind(new_alert))
        new_alert_timer.start(_alert_duration)

func on_alert_timer_timeout(_alert) -> void:
    print("Alert expired!")
    alert_expired.emit(_alert)